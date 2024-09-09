require("stategraphs/commonstates")

local TIMEOUT = 2

local function DoEquipmentFoleySounds(inst)
    local inventory = inst.replica.inventory
    if inventory ~= nil then
        for k, v in pairs(inventory:GetEquips()) do
            if v.foleysound ~= nil then
                inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
            end
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local function DoMountedFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    local rider = inst.replica.rider
    local saddle = rider ~= nil and rider:GetSaddle() or nil
    if saddle ~= nil and saddle.mounted_foleysound ~= nil then
        inst.SoundEmitter:PlaySound(saddle.mounted_foleysound, nil, nil, true)
    end
end

local function DoRunSounds(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

local function PlayMooseFootstep(inst, volume, ispredicted)
    --moose footstep always full volume
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep", nil, nil, ispredicted)
    PlayFootstep(inst, volume, ispredicted)
end

local function DoMooseRunSounds(inst)
    --moose footstep always full volume
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep", nil, nil, true)
    DoRunSounds(inst)
end

local function DoMountSound(inst, mount, sound)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, true)
    end
end

--------------------------------------------------------------------------

local CheckPreviewChannelCastAction --forward declare

local function StopPreviewChannelCast(inst)
	if inst.sg.mem.preview_channelcast_task then
		inst.sg.mem.preview_channelcast_task:Cancel()
		inst.sg.mem.preview_channelcast_task = nil
		inst.sg.mem.preview_channelcast_action = nil
		inst:RemoveEventCallback("performaction", CheckPreviewChannelCastAction)
		inst.components.locomotor:RemovePredictExternalSpeedMultiplier(inst, "preview_channelcast")
	end
end

CheckPreviewChannelCastAction = function(inst)
	if inst:IsChannelCasting() == (inst.sg.mem.preview_channelcast_action.action == ACTIONS.START_CHANNELCAST) then
		StopPreviewChannelCast(inst)
	end
end

--Used for both START_CHANNELCAST and STOP_CHANNELCAST
local function StartPreviewChannelCast(inst, buffaction)
	if buffaction.action == ACTIONS.START_CHANNELCAST then
		if inst:IsChannelCasting() then
			StopPreviewChannelCast(inst)
			return
		end
		inst.components.locomotor:SetPredictExternalSpeedMultiplier(inst, "preview_channelcast", TUNING.CHANNELCAST_SPEED_MOD)
	elseif buffaction.action == ACTIONS.STOP_CHANNELCAST then
		if not inst:IsChannelCasting() then
			StopPreviewChannelCast(inst)
			return
		end
		inst.components.locomotor:SetPredictExternalSpeedMultiplier(inst, "preview_channelcast", 1 / TUNING.CHANNELCAST_SPEED_MOD)
	else
		StopPreviewChannelCast(inst)
		return
	end

	if inst.sg.mem.preview_channelcast_task then
		inst.sg.mem.preview_channelcast_task:Cancel()
	else
		inst:ListenForEvent("performaction", CheckPreviewChannelCastAction)
	end
	inst.sg.mem.preview_channelcast_task = inst:DoTaskInTime(TIMEOUT, StopPreviewChannelCast)
	inst.sg.mem.preview_channelcast_action = buffaction
end

local function IsChannelCasting(inst)
	--essentially prediction, since the actions aren't busy w/ lag states
	local buffaction = inst.sg.mem.preview_channelcast_action
	if buffaction then
		return buffaction.action == ACTIONS.START_CHANNELCAST
		--Don't use "or inst:IsChannelCasting()"
		--We want to be able to return false here when predicting!
	end
	--otherwise return server state
	return inst:IsChannelCasting()
end

local function IsChannelCastingItem(inst)
	--essentially prediction, since the actions aren't busy w/ lag states
	local buffaction = inst.sg.mem.preview_channelcast_action
	if buffaction then
		return buffaction.invobject ~= nil
		--Don't use "or inst:IsChannelCastingItem()"
		--We want to be able to return false here when predicting!
	end
	--otherwise return server state
	return inst:IsChannelCastingItem()
end

--------------------------------------------------------------------------

local function ConfigureRunState(inst)
    if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
        inst.sg.statemem.riding = true
        inst.sg.statemem.groggy = inst:HasTag("groggy")

        local mount = inst.replica.rider:GetMount()
        inst.sg.statemem.ridingwoby = mount and mount:HasTag("woby")

    elseif inst.replica.inventory:IsHeavyLifting() then
        inst.sg.statemem.heavy = true
		inst.sg.statemem.heavy_fast = inst:HasTag("mightiness_mighty")
	elseif IsChannelCasting(inst) then
		inst.sg.statemem.channelcast = true
		inst.sg.statemem.channelcastitem = IsChannelCastingItem(inst)
    elseif inst:HasTag("wereplayer") then
        inst.sg.statemem.iswere = true
        if inst:HasTag("weremoose") then
            if inst:HasTag("groggy") then
                inst.sg.statemem.moosegroggy = true
            else
                inst.sg.statemem.moose = true
            end
        elseif inst:HasTag("weregoose") then
            if inst:HasTag("groggy") then
                inst.sg.statemem.goosegroggy = true
            else
                inst.sg.statemem.goose = true
            end
        elseif inst:HasTag("groggy") then
            inst.sg.statemem.groggy = true
        else
            inst.sg.statemem.normal = true
        end
	elseif inst:IsInAnyStormOrCloud() and not inst.components.playervision:HasGoggleVision() then
        inst.sg.statemem.sandstorm = true
    elseif inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    elseif inst:IsCarefulWalking() then
        inst.sg.statemem.careful = true
    else
        inst.sg.statemem.normal = true
        inst.sg.statemem.normalwonkey = inst:HasTag("wonkey") or nil
    end
end

local function GetRunStateAnim(inst)
    return ((inst.sg.statemem.heavy and inst.sg.statemem.heavy_fast) and "heavy_walk_fast")
		or (inst.sg.statemem.heavy and "heavy_walk")
		or (inst.sg.statemem.channelcastitem and "channelcast_walk")
		or (inst.sg.statemem.channelcast and "channelcast_oh_walk")
        or (inst.sg.statemem.sandstorm and "sand_walk")
        or ((inst.sg.statemem.groggy or inst.sg.statemem.moosegroggy or inst.sg.statemem.goosegroggy) and "idle_walk")
        or (inst.sg.statemem.careful and "careful_walk")
        or (inst.sg.statemem.ridingwoby and "run_woby")
        or "run"
end

--#V2C #client_prediction
--Clear locally, and on server force dirty when setting new state, even if it was
--same as previous state. Avoid false positives when repeating same action state.
--See playercontroller -> OnNewState
local function ClearCachedServerState(inst)
	if inst.player_classified ~= nil then
		inst.player_classified.currentstate:set_local(0)
	end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.CHOP,
        function(inst)
            if inst:HasTag("beaver") then
				return not (inst.sg:HasStateTag("gnawing") or inst:HasTag("gnawing")) and "gnaw" or nil
            end
			return not (inst.sg:HasStateTag("prechop") or inst:HasTag("prechop")) and "chop_start" or nil
        end),
    ActionHandler(ACTIONS.MINE,
        function(inst)
            if inst:HasTag("beaver") then
				return not (inst.sg:HasStateTag("gnawing") or inst:HasTag("gnawing")) and "gnaw" or nil
            end
			return not (inst.sg:HasStateTag("premine") or inst:HasTag("premine")) and "mine_start" or nil
        end),
    ActionHandler(ACTIONS.HAMMER,
        function(inst)
            if inst:HasTag("beaver") then
				return not (inst.sg:HasStateTag("gnawing") or inst:HasTag("gnawing")) and "gnaw" or nil
            end
			return not (inst.sg:HasStateTag("prehammer") or inst:HasTag("prehammer")) and "hammer_start" or nil
        end),
    ActionHandler(ACTIONS.TERRAFORM, "terraform"),
    ActionHandler(ACTIONS.DIG,
        function(inst)
            if inst:HasTag("beaver") then
				return not (inst.sg:HasStateTag("gnawing") or inst:HasTag("gnawing")) and "gnaw" or nil
            end
			return not (inst.sg:HasStateTag("predig") or inst:HasTag("predig")) and "dig_start" or nil
        end),
    ActionHandler(ACTIONS.NET,
        function(inst, action)
            if action.invobject == nil or not action.invobject:HasTag(ACTIONS.NET.id.."_tool") then
                return "doshortaction"
            end

            return not inst.sg:HasStateTag("prenet") and (inst.sg:HasStateTag("netting") and "bugnet" or "bugnet_start") or nil
        end),
    ActionHandler(ACTIONS.FISH, "fishing_pre"),
    ActionHandler(ACTIONS.OCEAN_FISHING_CAST, "oceanfishing_cast"),
    ActionHandler(ACTIONS.OCEAN_FISHING_REEL,
        function(inst, action)
            local fishable = action.invobject ~= nil and action.invobject.replica.oceanfishingrod:GetTarget() or nil
            if fishable ~= nil and fishable:HasTag("partiallyhooked") then
                return "oceanfishing_sethook"
            elseif inst:HasTag("fishing_idle") then
                return "oceanfishing_reel"
            end
            return nil
        end),
    ActionHandler(ACTIONS.FERTILIZE,
        function(inst, action)
            return (action.target ~= nil and action.target ~= inst and "doshortaction")
                or (action.invobject ~= nil and action.invobject:HasTag("slowfertilize") and "fertilize")
                or "fertilize_short"
        end),
    ActionHandler(ACTIONS.SMOTHER,
        function(inst)
            return inst:HasTag("pyromaniac") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.MANUALEXTINGUISH,
        function(inst)
            return inst:HasTag("pyromaniac") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.TRAVEL, "doshortaction"),
    ActionHandler(ACTIONS.LIGHT, "catchonfire"),
    ActionHandler(ACTIONS.UNLOCK, "give"),
    ActionHandler(ACTIONS.USEKLAUSSACKKEY,
        function(inst)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.TURNOFF, "give"),
    ActionHandler(ACTIONS.TURNON, "give"),
    ActionHandler(ACTIONS.YOTB_UNLOCKSKIN, "dolongaction"),
    ActionHandler(ACTIONS.YOTB_SEW, "dolongaction"),
    ActionHandler(ACTIONS.ADDFUEL, "doshortaction"),
    ActionHandler(ACTIONS.ADDWETFUEL, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR, function(inst, action)
        return action.target:HasTag("repairshortaction") and "doshortaction" or "dolongaction"
    end),
    ActionHandler(ACTIONS.READ,
        function(inst, action)
			return	(action.invobject ~= nil and action.invobject:HasTag("simplebook")) and "cookbook_open"
					or inst:HasTag("aspiring_bookworm") and "book_peruse"
					or "book"
        end),
	ActionHandler(ACTIONS.MAKEBALLOON, "dolongaction"),
	ActionHandler(ACTIONS.DEPLOY, function(inst, action) return action.invobject and action.invobject:HasTag("projectile") and "throw_deploy" or "doshortaction" end),
    ActionHandler(ACTIONS.DEPLOY_TILEARRIVE, "doshortaction"),
    ActionHandler(ACTIONS.STORE, "doshortaction"),
    ActionHandler(ACTIONS.DROP,
        function(inst)
            return inst.replica.inventory:IsHeavyLifting()
                and not (inst.replica.rider ~= nil and inst.replica.rider:IsRiding())
                and "heavylifting_drop"
                or "doshortaction"
        end),
    ActionHandler(ACTIONS.MURDER,
        function(inst)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.UPGRADE, "dolongaction"),
    ActionHandler(ACTIONS.ACTIVATE,
        function(inst, action)
			return (	action.target:HasTag("engineering") and (
							(inst:HasTag("scientist") and "dolongaction") or
							(not inst:HasTag("handyperson") and "dolongestaction")
						)
					)
				or (action.target:HasTag("standingactivation") and "dostandingaction")
                or (action.target:HasTag("quickactivation") and "doshortaction")
                or "dolongaction"
        end),
    ActionHandler(ACTIONS.OPEN_CRAFTING, "dostandingaction"),
    ActionHandler(ACTIONS.PICK,
        function(inst, action)
			return (action.target:HasTag("noquickpick") and "dolongaction")
				or (inst:HasTag("farmplantfastpicker") and action.target:HasTag("farm_plant") and "domediumaction")
				or (inst.replica.rider ~= nil and inst.replica.rider:IsRiding() and (
						(inst:HasTag("woodiequickpicker") and "dowoodiefastpick") or
						"dolongaction"
					))
                or (action.target:HasAnyTag("jostlepick", "jostlerummage", "jostlesearch") and "dojostleaction")
                or (action.target:HasAnyTag("quickpick", "quickrummage", "quicksearch") and "doshortaction")
                or (inst:HasTag("fastpicker") and "doshortaction")
				or (inst:HasTag("woodiequickpicker") and "dowoodiefastpick")
                or (inst:HasTag("quagmire_fasthands") and "domediumaction")
                or "dolongaction"
        end),
    ActionHandler(ACTIONS.CARNIVALGAME_FEED,
        function(inst, action)
            return (inst.replica.rider ~= nil and inst.replica.rider:IsRiding() and "dolongaction")
				or "doequippedaction"
        end),
    ActionHandler(ACTIONS.SLEEPIN,
        function(inst, action)
            return action.invobject ~= nil and "bedroll" or "tent"
        end),
    ActionHandler(ACTIONS.TAKEITEM,
        function(inst, action)
            return action.target ~= nil
                and action.target.takeitem ~= nil --added for quagmire
                and "give"
                or "dolongaction"
        end),
    ActionHandler(ACTIONS.BUILD,
        function(inst, action)
            local rec = GetValidRecipe(action.recipe)
            return (rec ~= nil and rec.sg_state)
                or (inst:HasTag("hungrybuilder") and "dohungrybuild")
                or (inst:HasTag("fastbuilder") and "domediumaction")
                or (inst:HasTag("slowbuilder") and "dolongestaction")
                or "dolongaction"
        end),
	ActionHandler(ACTIONS.SHAVE, "dolongaction"),
    ActionHandler(ACTIONS.COOK,
        function(inst, action)
            return inst:HasTag("expertchef") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.FILL, "dolongaction"),
    ActionHandler(ACTIONS.FILL_OCEAN, "dolongaction"),

    ActionHandler(ACTIONS.PICKUP, function(inst, action)
            return (inst.replica.rider ~= nil and inst.replica.rider:IsRiding()
                    and (action.target ~= nil and action.target:HasTag("heavy") and "dodismountaction"
                        or "domediumaction")
                    )
                or "doshortaction"
        end),
    ActionHandler(ACTIONS.CHECKTRAP,
        function(inst, action)
            return (inst.replica.rider ~= nil and inst.replica.rider:IsRiding() and "domediumaction")
                or "doshortaction"
        end),
	ActionHandler(ACTIONS.RUMMAGE,
		function(inst, action)
			if action.invobject and action.invobject:HasTag("portablestorage") then
				local container = action.invobject.replica.container
				if container then
					return container:IsOpenedBy(inst) and "stop_pocket_rummage" or "start_pocket_rummage"
				end
			end
			return "doshortaction"
		end),
    ActionHandler(ACTIONS.BAIT, "doshortaction"),
    ActionHandler(ACTIONS.HEAL, "dolongaction"),
    ActionHandler(ACTIONS.SEW, "dolongaction"),
    ActionHandler(ACTIONS.TEACH, "dolongaction"),
    ActionHandler(ACTIONS.RESETMINE, "dolongaction"),
    ActionHandler(ACTIONS.EAT,
        function(inst, action)
            if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
                return
            end
            local obj = action.target or action.invobject
            if obj == nil then
                return
            elseif obj:HasTag("soul") then
                return "eat"
            end
            for k, v in pairs(FOODTYPE) do
                if obj:HasTag("edible_"..v) then
                    return v == FOODTYPE.MEAT and "eat" or "quickeat"
                end
            end
        end),
    ActionHandler(ACTIONS.GIVE,
        function(inst, action)
            return action.invobject ~= nil
                and action.target ~= nil
                and (   (action.target:HasTag("moonportal") and action.invobject:HasTag("moonportalkey") and "dochannelaction") or
                        (action.invobject.prefab == "quagmire_portal_key" and action.target:HasTag("quagmire_altar") and "dolongaction") or
                        (action.target:HasTag("give_dolongaction") and "dolongaction")
                    )
                or "give"
        end),
    ActionHandler(ACTIONS.APPRAISE, "give"),
    ActionHandler(ACTIONS.GIVETOPLAYER, "give"),
    ActionHandler(ACTIONS.GIVEALLTOPLAYER, "give"),
    ActionHandler(ACTIONS.FEEDPLAYER, "give"),
    ActionHandler(ACTIONS.DECORATEVASE, "dolongaction"),
    ActionHandler(ACTIONS.PLANT, "doshortaction"),
    ActionHandler(ACTIONS.HARVEST,
        function(inst)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
	ActionHandler(ACTIONS.PLAY,
		function(inst, action)
			if action.invobject ~= nil then
				return (action.invobject:HasTag("flute") and "play_flute")
					or (action.invobject:HasTag("horn") and "play_horn")
					or (action.invobject:HasTag("bell") and "play_bell")
					or (action.invobject:HasTag("whistle") and "play_whistle")
					or nil
			end
		end),
    ActionHandler(ACTIONS.JUMPIN, "jumpin_pre"),
    ActionHandler(ACTIONS.JUMPIN_MAP, "jumpin_pre"),
    ActionHandler(ACTIONS.TELEPORT,
        function(inst, action)
            return action.invobject ~= nil and "dolongaction" or "give"
        end),
    ActionHandler(ACTIONS.FAN, "use_fan"),
    ActionHandler(ACTIONS.ERASE_PAPER, "dolongaction"),
    ActionHandler(ACTIONS.DRY, "doshortaction"),
    ActionHandler(ACTIONS.CASTSPELL,
        function(inst, action)
            return action.invobject ~= nil
                and ((action.invobject:HasTag("gnarwail_horn") and "play_gnarwail_horn")
                    or (action.invobject:HasTag("guitar") and "play_strum")
                    or (action.invobject:HasTag("cointosscast") and "cointosscastspell")
                    or (action.invobject:HasTag("quickcast") and "quickcastspell")
                    or (action.invobject:HasTag("veryquickcast") and "veryquickcastspell")
                    or (action.invobject:HasTag("mermbuffcast") and "mermbuffcastspell")
                    )
                or "castspell"
        end),
    ActionHandler(ACTIONS.CASTAOE,
        function(inst, action)
            return action.invobject ~= nil
				and (	(action.invobject:HasTag("book") and "book") or
						(action.invobject:HasTag("willow_ember") and "castspellmind") or
						(action.invobject:HasTag("remotecontrol") and "remotecast") or
						(action.invobject:HasTag("aoeweapon_lunge") and "combat_lunge_start") or
						(action.invobject:HasTag("aoeweapon_leap") and (action.invobject:HasTag("superjump") and "combat_superjump_start" or "combat_leap_start")) or
						(action.invobject:HasTag("parryweapon") and "parry_pre") or
						(action.invobject:HasTag("blowdart") and "blowdart_special") or
						(action.invobject:HasTag("throw_line") and "throw_line")
                    )
                or "castspell"
        end),
    ActionHandler(ACTIONS.CAST_POCKETWATCH,
        function(inst, action)
            return action.invobject ~= nil
                and (   action.invobject:HasTag("recall_unmarked") and "dolongaction"
						or action.invobject:HasTag("pocketwatch_warp_casting") and "pocketwatch_warpback_pre"
						or action.invobject.prefab == "pocketwatch_portal" and "pocketwatch_openportal"
                    )
				or "pocketwatch_cast"
        end),
    ActionHandler(ACTIONS.BLINK,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("soulstealer") and "portal_jumpin_pre" or "quicktele"
        end),
    ActionHandler(ACTIONS.BLINK_MAP,
        function(inst, action)
            return action.invobject == nil and inst:HasTag("soulstealer") and "portal_jumpin_pre" or "quicktele"
        end),
    ActionHandler(ACTIONS.CASTSUMMON,
        function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "summon_abigail" or "castspell"
        end),
    ActionHandler(ACTIONS.CASTUNSUMMON,
        function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "unsummon_abigail" or "castspell"
        end),
    ActionHandler(ACTIONS.COMMUNEWITHSUMMONED,
        function(inst, action)
            return action.invobject ~= nil and action.invobject:HasTag("abigail_flower") and "commune_with_abigail" or "dolongaction"
        end),
    ActionHandler(ACTIONS.SING, "sing_pre"),
    ActionHandler(ACTIONS.SING_FAIL, "sing_fail"),
    ActionHandler(ACTIONS.COMBINESTACK, "doshortaction"),
    ActionHandler(ACTIONS.FEED, "dolongaction"),
    ActionHandler(ACTIONS.ATTACK,
        function(inst, action)
            if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or IsEntityDead(inst)) then
                local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip == nil then
                    return "attack"
                end
                local inventoryitem = equip.replica.inventoryitem
                return (not (inventoryitem ~= nil and inventoryitem:IsWeapon()) and "attack")
                    or (equip:HasOneOfTags({"blowdart", "blowpipe"}) and "blowdart")
					or (equip:HasTag("slingshot") and "slingshot_shoot")
                    or (equip:HasTag("thrown") and "throw")
                    or (equip:HasTag("pillow") and "attack_pillow_pre")
                    or (equip:HasTag("propweapon") and "attack_prop_pre")
                    or "attack"
            end
        end),
	ActionHandler(ACTIONS.TOSS,
		function(inst, action)
			local projectile = action.invobject
			if projectile == nil then
				--for Special action TOSS, we can also use equipped item.
				projectile = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
				if projectile ~= nil and not projectile:HasTag("special_action_toss") then
					projectile = nil
				end
			end
			return projectile ~= nil and projectile:HasTag("keep_equip_toss") and "throw_keep_equip" or "throw"
		end),
        ActionHandler(ACTIONS.TOSS_MAP,
            function(inst, action)
                local projectile = action.invobject
                if projectile == nil then
                    --for Special action TOSS, we can also use equipped item.
                    projectile = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if projectile ~= nil and not projectile:HasTag("special_action_toss") then
                        projectile = nil
                    end
                end
                return projectile ~= nil and projectile:HasTag("keep_equip_toss") and "throw_keep_equip" or "throw"
            end),
    ActionHandler(ACTIONS.UNPIN, "doshortaction"),
    ActionHandler(ACTIONS.CATCH, "catch_pre"),
    ActionHandler(ACTIONS.CHANGEIN, "usewardrobe"),
    ActionHandler(ACTIONS.HITCHUP, "usewardrobe"),
    ActionHandler(ACTIONS.UNHITCH, "usewardrobe"),
    ActionHandler(ACTIONS.MARK, "doshortaction"),
    ActionHandler(ACTIONS.WRITE, "doshortaction"),
    ActionHandler(ACTIONS.ATTUNE, "dolongaction"),
    ActionHandler(ACTIONS.MIGRATE, "migrate"),
    ActionHandler(ACTIONS.MOUNT, "doshortaction"),
    ActionHandler(ACTIONS.SADDLE, "doshortaction"),
    ActionHandler(ACTIONS.UNSADDLE, "unsaddle"),
    ActionHandler(ACTIONS.BRUSH, "dolongaction"),
    ActionHandler(ACTIONS.ABANDON, "dolongaction"),
    ActionHandler(ACTIONS.PET, "dolongaction"),
    ActionHandler(ACTIONS.DRAW, "dolongaction"),
    ActionHandler(ACTIONS.BUNDLE, "bundle"),
    ActionHandler(ACTIONS.RAISE_SAIL, "dostandingaction"),
	ActionHandler(ACTIONS.LOWER_SAIL_BOOST, "furl_boost"),
    ActionHandler(ACTIONS.LOWER_SAIL_FAIL, "furl_fail"),
    ActionHandler(ACTIONS.RAISE_ANCHOR, "dolongaction"),
    ActionHandler(ACTIONS.LOWER_ANCHOR, "dolongaction"),
    ActionHandler(ACTIONS.STEER_BOAT, "steer_boat_idle_pre"),
    ActionHandler(ACTIONS.ROTATE_BOAT_CLOCKWISE, "doshortaction"),
    ActionHandler(ACTIONS.ROTATE_BOAT_COUNTERCLOCKWISE, "doshortaction"),
    ActionHandler(ACTIONS.ROTATE_BOAT_STOP, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_ACTIVATE, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_DEACTIVATE, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_BEACON_TURN_ON, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_BEACON_TURN_OFF, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR_LEAK, "dolongaction"),
    ActionHandler(ACTIONS.SET_HEADING, function(inst, action) inst:PerformPreviewBufferedAction() end),
    ActionHandler(ACTIONS.CAST_NET, "doshortaction"),
    ActionHandler(ACTIONS.ROW_FAIL, "row_fail"),
    ActionHandler(ACTIONS.ROW, "row"),
    ActionHandler(ACTIONS.ROW_CONTROLLER, "row"),
    ActionHandler(ACTIONS.EXTEND_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.RETRACT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.ABANDON_SHIP, "abandon_ship_pre"),
    ActionHandler(ACTIONS.MOUNT_PLANK, "mount_plank"),
    ActionHandler(ACTIONS.DISMOUNT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_CANNON_LOAD_AMMO, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_CANNON_START_AIMING, "aim_cannon_pre"),
    ActionHandler(ACTIONS.BOAT_CANNON_SHOOT, function(inst, action) inst:PerformPreviewBufferedAction() end),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_LOWER, "doshortaction"),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_RAISE, "doshortaction"),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_FIX, "dolongaction"),

    ActionHandler(ACTIONS.UNWRAP,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.CONSTRUCT,
        function(inst, action)
            return (action.target == nil or not action.target:HasTag("constructionsite")) and "startconstruct" or "construct"
        end),
    ActionHandler(ACTIONS.STARTCHANNELING, function(inst,action)
        if action.target and action.target:HasTag("use_channel_longaction") then
                return "channel_longaction"
            else
                return "startchanneling"
            end
        end),
	ActionHandler(ACTIONS.START_CHANNELCAST, "start_channelcast"),
	ActionHandler(ACTIONS.STOP_CHANNELCAST, "stop_channelcast"),
    ActionHandler(ACTIONS.REVIVE_CORPSE, "dolongaction"),
	ActionHandler(ACTIONS.DISMANTLE,
		function(inst, action)
			return (inst:HasTag("hungrybuilder") and "dohungrybuild")
				or (inst:HasTag("fastbuilder") and "domediumaction")
				or (inst:HasTag("slowbuilder") and "dolongestaction")
				or "dolongaction"
		end),
    ActionHandler(ACTIONS.TACKLE, "tackle_pre"),
    ActionHandler(ACTIONS.HALLOWEENMOONMUTATE, "give"),

    --Quagmire
    ActionHandler(ACTIONS.TILL, "till_start"),
    ActionHandler(ACTIONS.PLANTSOIL,
        function(inst, action)
            return (inst:HasTag("quagmire_farmhand") and "doshortaction")
                or (inst:HasTag("quagmire_fasthands") and "domediumaction")
                or "dolongaction"
        end),
    ActionHandler(ACTIONS.INSTALL,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.TAPTREE,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.SLAUGHTER,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.REPLATE,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.SALT,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.BATHBOMB, "doshortaction"),
    ActionHandler(ACTIONS.APPLYPRESERVATIVE, "doshortaction"),
    ActionHandler(ACTIONS.COMPARE_WEIGHABLE, "give"),
    ActionHandler(ACTIONS.WEIGH_ITEM, "use_pocket_scale"),
    ActionHandler(ACTIONS.GIVE_TACKLESKETCH, "give"),
    ActionHandler(ACTIONS.REMOVE_FROM_TROPHYSCALE, "dolongaction"),
    ActionHandler(ACTIONS.CYCLE, "give"),
    ActionHandler(ACTIONS.OCEAN_TOSS, "throw"),

    ActionHandler(ACTIONS.WINTERSFEAST_FEAST, "winters_feast_eat"),
    ActionHandler(ACTIONS.START_CARRAT_RACE, "give"),

    ActionHandler(ACTIONS.BEGIN_QUEST, "doshortaction"),
    ActionHandler(ACTIONS.ABANDON_QUEST, "dolongaction"),
    ActionHandler(ACTIONS.TELLSTORY, "dostorytelling"),

    ActionHandler(ACTIONS.POUR_WATER, "pour"),
    ActionHandler(ACTIONS.POUR_WATER_GROUNDTILE, "pour"),

    ActionHandler(ACTIONS.INTERACT_WITH,
        function(inst, action)
            return inst:HasTag("plantkin") and "domediumaction" or
                   action.target:HasTag("yotb_stage") and "doshortaction" or
                   "dolongaction"
        end),
    ActionHandler(ACTIONS.PLANTREGISTRY_RESEARCH_FAIL, "dolongaction"),
    ActionHandler(ACTIONS.PLANTREGISTRY_RESEARCH, "dolongaction"),
    ActionHandler(ACTIONS.ASSESSPLANTHAPPINESS, "dolongaction"),
    ActionHandler(ACTIONS.ADDCOMPOSTABLE, "give"),
    ActionHandler(ACTIONS.WAX,
        function(inst, action)
            return
                action.invobject ~= nil and action.invobject:HasTag("waxspray") and "spray_wax"
                or "dolongaction"
        end
    ),

    ActionHandler(ACTIONS.USEITEMON, function(inst, action)
        if action.invobject == nil then
            return "dolongaction"
        elseif action.invobject:HasTag("bell") then
			return "use_beef_bell"
        else
            return "dolongaction"
        end
    end),

    ActionHandler(ACTIONS.STOPUSINGITEM, "dolongaction"),

    ActionHandler(ACTIONS.YOTB_STARTCONTEST, "doshortaction"),
    ActionHandler(ACTIONS.CARNIVAL_HOST_SUMMON, "give"),

    ActionHandler(ACTIONS.MUTATE_SPIDER, "give"),
    ActionHandler(ACTIONS.HERD_FOLLOWERS, "herd_followers"),
    ActionHandler(ACTIONS.REPEL, "repel_followers"),
    ActionHandler(ACTIONS.BEDAZZLE, "dolongaction"),
    ActionHandler(ACTIONS.UNLOAD_WINCH, "give"),
    ActionHandler(ACTIONS.USE_HEAVY_OBSTACLE, "dolongaction"),
    ActionHandler(ACTIONS.ADVANCE_TREE_GROWTH, "dolongaction"),

    ActionHandler(ACTIONS.HIDEANSEEK_FIND, "dolongaction"),
    ActionHandler(ACTIONS.RETURN_FOLLOWER, "dolongaction"),

    ActionHandler(ACTIONS.DISMANTLE_POCKETWATCH, "dolongaction"),

    ActionHandler(ACTIONS.LIFT_DUMBBELL, function(inst, action)
        if inst:HasTag("liftingdumbbell") then
            return "use_dumbbell_pst"
        else
            return "use_dumbbell_pre"
        end
    end),

    ActionHandler(ACTIONS.ENTER_GYM, "give"),
    ActionHandler(ACTIONS.LIFT_GYM_FAIL, "mighty_gym_workout_fail"),
    ActionHandler(ACTIONS.LIFT_GYM_SUCCEED_PERFECT, "mighty_gym_success_perfect"),
    ActionHandler(ACTIONS.LIFT_GYM_SUCCEED, "mighty_gym_success"),

    ActionHandler(ACTIONS.APPLYMODULE, "applyupgrademodule"),
    ActionHandler(ACTIONS.REMOVEMODULES, "removeupgrademodules"),
    ActionHandler(ACTIONS.CHARGE_FROM, "doshortaction"),

    ActionHandler(ACTIONS.ROTATE_FENCE, "doswipeaction"),

	ActionHandler(ACTIONS.USEMAGICTOOL, "start_using_tophat"),
	ActionHandler(ACTIONS.STOPUSINGMAGICTOOL, "stop_using_tophat"),
	ActionHandler(ACTIONS.CAST_SPELLBOOK, "book"),
	ActionHandler(ACTIONS.SCYTHE, "scythe"),
	ActionHandler(ACTIONS.SITON, "start_sitting"),

	ActionHandler(ACTIONS.USE_WEREFORM_SKILL, function(inst)
		return (inst:HasTag("beaver") and "beaver_tailslap_pre")
			or (inst:HasTag("weregoose") and "weregoose_takeoff_pre")
			or nil
    end),

	ActionHandler(ACTIONS.REMOTE_TELEPORT, "remote_teleport_pre"),
	ActionHandler(ACTIONS.LOOKAT, "closeinspect"),

    ActionHandler(ACTIONS.INCINERATE, "doshortaction"),
}

local events =
{
	EventHandler("sg_cancelmovementprediction", function(inst)
		inst.sg:GoToState("idle", "cancel")
	end),
	EventHandler("locomote", function(inst, data)
		--#HACK for hopping prediction: ignore busy when boathopping... (?_?)
		if (inst.sg:HasStateTag("busy") or inst:HasTag("busy")) and
			not (inst.sg:HasStateTag("boathopping") or inst:HasTag("boathopping")) then
			return
		elseif inst.sg:HasStateTag("overridelocomote") then
			return
		end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if inst:HasTag("ingym") then
            if should_move and not inst.sg:HasStateTag("exiting_gym") then
                inst.sg:GoToState("mighty_gym_exit")
            end
        elseif inst:HasTag("sleeping") then
            if should_move and not inst.sg:HasStateTag("waking") then
                inst.sg:GoToState("wakeup")
            end
        elseif not inst.entity:CanPredictMovement() then
            if not inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("idle")
            end
        elseif is_moving and not should_move then
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				if inst.components.locomotor then
					inst.components.locomotor:SetMoveDir(data.dir)
				else
					inst.Transform:SetRotation(data.dir)
				end
			end
            inst.sg:GoToState("run_start")
        end
    end),

    CommonHandlers.OnHop(),
}

local states =
{
	State{
		name = "init",
		onenter = function(inst)
			inst.sg:GoToState(inst:HasTag("sitting_on_chair") and "sitting" or "idle")
		end,
	},

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.entity:SetIsPredictingMovement(false)

			if pushanim == "cancel" or inst:HasTag("nopredict") or inst:HasTag("pausepredict") then
				--prediction interrupted by server state
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                return
            elseif pushanim == "noanim" then
				--server confirmed our preview action
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
				ClearCachedServerState(inst)
				--use timeout for clearing preview bufferedaction
                inst.sg:SetTimeout(TIMEOUT)
                return
            end

			--predicted idle state
			if inst.sg.lasttags and not inst.sg.lasttags["busy"] then
				inst.components.locomotor:StopMoving()
			else
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
			end
			inst:ClearBufferedAction()

            --V2C: Only predict looped anims. For idles with a pre, stick with
            --     "idle_loop" and wait for server to trigger the custom anims
            local anim
            if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
                anim = "idle_loop"
            elseif inst:HasTag("wereplayer") then
                --V2C: groggy moose and goose go straight back to idle_groggy (don't play idle_groggy_pre everytime like others do)
                if not inst:HasTag("groggy") or inst:HasTag("beaver") then
                    anim = "idle_loop"
                elseif inst:HasTag("weremoose") then
                    anim = (inst.AnimState:IsCurrentAnimation("idle_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("idle_walk") or
                            inst.AnimState:IsCurrentAnimation("idle_walk_pre")) and
                        "idle_groggy" or
                        "idle_loop"
                else--if inst:HasTag("weregoose") then
                    anim = (inst.AnimState:IsCurrentAnimation("idle_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("idle_walk") or
                            inst.AnimState:IsCurrentAnimation("idle_walk_pre")) and
                        "idle_groggy" or
                        "idle_loop"
                end
            elseif inst.player_classified ~= nil and inst.player_classified.inmightygym:value() > 0 then
				anim = "mighty_gym_active_loop"
			else
                anim =
                    (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and "heavy_idle") or
					(	IsChannelCasting(inst) and
						(IsChannelCastingItem(inst) and "channelcast_idle" or "channelcast_oh_idle")
					) or
					(   inst:IsInAnyStormOrCloud() and not inst.components.playervision:HasGoggleVision() and
                        (   inst.AnimState:IsCurrentAnimation("sand_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("sand_walk") or
                            inst.AnimState:IsCurrentAnimation("sand_walk_pre")
                        ) and
                        "sand_idle_loop"
                    ) or
                    "idle_loop"
            end

            if pushanim then
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end
        end,

        ontimeout = function(inst)
            if inst.bufferedaction ~= nil and inst.bufferedaction.ispreviewing then
                inst:ClearBufferedAction()
            end
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            ConfigureRunState(inst)
            if inst.sg.statemem.normalwonkey and inst.components.locomotor:GetTimeMoving() >= TUNING.WONKEY_TIME_TO_RUN then
                inst.sg:GoToState("run_monkey") --resuming after brief stop from changing directions
                return
            end
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pre")
            --goose footsteps should always be light
            inst.sg.mem.footsteps = (inst.sg.statemem.goose or inst.sg.statemem.goosegroggy) and 4 or 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            --mounted
            TimeEvent(0, function(inst)
                if inst.sg.statemem.riding then
                    DoMountedFoleySounds(inst)
                end
            end),

            --heavy lifting
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and not inst.sg.statemem.heavy_fast then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),

            --moose
            TimeEvent(2 * FRAMES, function(inst)
                if inst.sg.statemem.moose then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),

            --unmounted
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    PlayFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),

            --mounted
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    PlayFootstep(inst, nil, true)
                end
            end),

            --moose groggy
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.moosegroggy then
                    PlayMooseFootstep(inst, nil, true)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("run")
                end
            end),
        },
    },

    State{
        name = "run",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:RunForward()

            local anim = GetRunStateAnim(inst)
            if anim == "run" then
                anim = "run_loop"
            elseif anim == "run_woby" then
                anim = "run_woby_loop"
            end

            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            if inst.sg.statemem.normalwonkey and inst.components.locomotor:GetTimeMoving() >= TUNING.WONKEY_TIME_TO_RUN then
                inst.sg:GoToState("run_monkey_start")
                return
            end
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            --unmounted
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if inst.sg.statemem.normal then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --careful
            --Frame 11 shared with heavy lifting below
            --[[TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),]]
            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --sandstorm
            --Frame 12 shared with groggy below
            --[[TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.sandstorm then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),]]
            TimeEvent(23 * FRAMES, function(inst)
                if inst.sg.statemem.sandstorm then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --groggy
			--channelcast
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.groggy or
					inst.sg.statemem.channelcast or
					inst.sg.statemem.goose
				then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.groggy or
					inst.sg.statemem.channelcast or
					inst.sg.statemem.sandstorm
				then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --heavy lifting
            TimeEvent(0 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and inst.sg.statemem.heavy_fast then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and inst.sg.statemem.heavy_fast then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(11 * FRAMES, function(inst)
                if (inst.sg.statemem.heavy and not inst.sg.statemem.heavy_fast) or
                    inst.sg.statemem.sandstorm or
                    inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                elseif inst.sg.statemem.moose then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                if (inst.sg.statemem.heavy and not inst.sg.statemem.heavy_fast) or
                    inst.sg.statemem.sandstorm or
                    inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --mounted
            TimeEvent(0, function(inst)
                if inst.sg.statemem.riding then
                    DoMountedFoleySounds(inst)
                end
            end),
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    DoRunSounds(inst)
                end
            end),

            --moose
            --Frame 11 shared with heavy lifting above
            --[[TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.moose then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),]]
            TimeEvent(24 * FRAMES, function(inst)
                if inst.sg.statemem.moose then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --moose groggy
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.moosegroggy then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(30 * FRAMES, function(inst)
                if inst.sg.statemem.moosegroggy then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --goose
            --Frame 1 shared with groggy above
            --[[TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.goose then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),]]
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.goose then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),

            --goose groggy
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.goosegroggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.goosegroggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("gogglevision", function(inst, data)
                if data.enabled then
                    if inst.sg.statemem.sandstorm then
                        inst.sg:GoToState("run")
                    end
                elseif not (inst.sg.statemem.riding or
                            inst.sg.statemem.heavy or
                            inst.sg.statemem.iswere or
							inst.sg.statemem.sandstorm)
					and inst:IsInAnyStormOrCloud() then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("stormlevel", function(inst, data)
                if data.level < TUNING.SANDSTORM_FULL_LEVEL then
                    if inst.sg.statemem.sandstorm then
                        inst.sg:GoToState("run")
                    end
                elseif not (inst.sg.statemem.riding or
                            inst.sg.statemem.heavy or
                            inst.sg.statemem.iswere or
                            inst.sg.statemem.sandstorm or
                            inst.components.playervision:HasGoggleVision()) then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("miasmalevel", function(inst, data)
				if data.level < 1 then
					if inst.sg.statemem.sandstorm then
						inst.sg:GoToState("run")
					end
				elseif not (inst.sg.statemem.riding or
							inst.sg.statemem.heavy or
							inst.sg.statemem.iswere or
							inst.sg.statemem.sandstorm or
							inst.components.playervision:HasGoggleVision()) then
					inst.sg:GoToState("run")
				end
			end),
            EventHandler("carefulwalking", function(inst, data)
                if not data.careful then
                    if inst.sg.statemem.careful then
                        inst.sg:GoToState("run")
                    end
                elseif not (inst.sg.statemem.riding or
                            inst.sg.statemem.heavy or
                            inst.sg.statemem.sandstorm or
                            inst.sg.statemem.groggy or
                            inst.sg.statemem.careful or
                            inst.sg.statemem.iswere) then
                    inst.sg:GoToState("run")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("run")
        end,
    },

    State{
        name = "run_stop",
        tags = { "canrotate", "idle" },

        onenter = function(inst)
            ConfigureRunState(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")

            if inst.sg.statemem.moose or inst.sg.statemem.moosegroggy then
                PlayMooseFootstep(inst, .6, true)
                DoFoleySounds(inst)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                if inst.sg.statemem.goose or inst.sg.statemem.goosegroggy then
                    PlayFootstep(inst, .5, true)
                    DoFoleySounds(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },


    State{
        name = "run_monkey_start",
        tags = {"moving", "running", "canrotate", "monkey"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normalwonkey then
                inst.sg:GoToState("run")
                return
            end
            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_monkey_pre")
        end,

        onupdate = function(inst)
            if inst.components.locomotor:GetTimeMoving() < TUNING.WONKEY_TIME_TO_RUN then
                inst.sg:GoToState("run")
            end
        end,

        events =
        {
            EventHandler("gogglevision", function(inst, data)
				if not data.enabled and inst:IsInAnyStormOrCloud() then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("stormlevel", function(inst, data)
                if data.level >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("miasmalevel", function(inst, data)
				if data.level >= 1 and not inst.components.playervision:HasGoggleVision() then
					inst.sg:GoToState("run")
				end
			end),
            EventHandler("carefulwalking", function(inst, data)
                if data.careful then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("animover", function(inst)
                inst.sg.statemem.monkeyrunning = true
                inst.sg:GoToState("run_monkey")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.monkeyrunning then
                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "run_monkey",
        tags = {"moving", "running", "canrotate", "monkey"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normalwonkey then
                inst.sg:GoToState("run")
                return
            end
            inst.components.locomotor.predictrunspeed = TUNING.WILSON_RUN_SPEED + TUNING.WONKEY_SPEED_BONUS
            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation("run_monkey_loop") then
                inst.AnimState:PlayAnimation("run_monkey_loop", true)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst) PlayFootstep(inst, 0.5) end),
            TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst, 0.5) DoFoleySounds(inst) end),
            TimeEvent(10*FRAMES, function(inst) PlayFootstep(inst, 0.5) end),
            TimeEvent(11*FRAMES, function(inst) PlayFootstep(inst, 0.5) end),
        },

        onupdate = function(inst)
            if inst.components.locomotor:GetTimeMoving() < TUNING.WONKEY_TIME_TO_RUN then
                inst.sg:GoToState("run")
                return
            end
            inst.components.locomotor:RunForward()
        end,

        events =
        {
            EventHandler("gogglevision", function(inst, data)
				if not data.enabled and inst:IsInAnyStormOrCloud() then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("stormlevel", function(inst, data)
                if data.level >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
                    inst.sg:GoToState("run")
                end
            end),
			EventHandler("miasmalevel", function(inst, data)
				if data.level >= 1 and not inst.components.playervision:HasGoggleVision() then
					inst.sg:GoToState("run")
				end
			end),
            EventHandler("carefulwalking", function(inst, data)
                if data.careful then
                    inst.sg:GoToState("run")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.monkeyrunning = true
            inst.sg:GoToState("run_monkey")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.monkeyrunning then
                inst.components.locomotor.predictrunspeed = nil
                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "previewaction",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                inst.AnimState:PlayAnimation("idle_loop", true)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst.bufferedaction == nil then
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "chop_start",
        tags = { "prechop", "working" },
		server_states = { "chop_start", "chop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                if inst:HasTag("woodcutter") then
                    inst.AnimState:PlayAnimation("woodie_chop_pre")
                    inst.AnimState:PushAnimation("woodie_chop_lag", false)
                else
                    inst.AnimState:PlayAnimation("chop_pre")
                    inst.AnimState:PushAnimation("chop_lag", false)
                end
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },
		server_states = { "mine_start", "mine" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("pickaxe_pre")
                inst.AnimState:PushAnimation("pickaxe_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickaxe_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "hammer_start",
        tags = { "prehammer", "working" },
		server_states = { "hammer_start", "hammer" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("pickaxe_pre")
                inst.AnimState:PushAnimation("pickaxe_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickaxe_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "gnaw",
        tags = { "gnawing", "working" },
		server_states = { "gnaw" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "parry_pre",
        tags = { "preparrying", "busy" },
		server_states = { "parry_pre", "parry_idle" },

        onenter = function(inst)
            inst.sg.statemem.isshield = inst.bufferedaction ~= nil and inst.bufferedaction.invobject ~= nil and inst.bufferedaction.invobject:HasTag("shield")
 
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pre"  or "parry_pre")
            inst.AnimState:PushAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_pre", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "terraform",
        tags = { "busy" },
		server_states = { "terraform" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
            inst.AnimState:PushAnimation("shovel_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("shovel_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("shovel_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "dig_start",
        tags = { "predig", "working" },
		server_states = { "dig_start", "dig" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("shovel_pre")
                inst.AnimState:PushAnimation("shovel_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("shovel_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("shovel_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "bugnet_start",
        tags = { "prenet", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bugnet_pre")

            inst:PerformPreviewBufferedAction()
            inst:ClearBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("bugnet")
                end
            end),
        },
    },

    State{
        name = "bugnet",
        tags = { "prenet", "netting", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bugnet")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bugnet", nil, nil, true)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prenet")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "fishing_pre",
        tags = { "prefish", "fishing" },
		server_states = { "fishing_pre", "fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre")
            inst.AnimState:PushAnimation("fishing_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("fishing")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "fishing",
        tags = { "fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:PerformPreviewBufferedAction()
            inst.entity:FlattenMovementPrediction()
            inst.entity:SetIsPredictingMovement(false)
			ClearCachedServerState(inst)
        end,

        onupdate = function(inst)
            if not inst:HasTag("fishing") then
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", "noanim")
            end
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },

    State{
        name = "oceanfishing_cast",
        tags = { "prefish", "fishing" },
		server_states = { "oceanfishing_cast", "oceanfishing_idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pre")
            inst.AnimState:PushAnimation("fishing_ocean_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "oceanfishing_sethook",
		tags = { "fishing", "doing", "busy" },
		server_states = { "oceanfishing_sethook" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("fishing_ocean_bite_heavy_pre")
                inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_lag", false)
            end
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "oceanfishing_reel",
		tags = { "fishing", "doing", "reeling", "canrotate" },
		server_states = { "oceanfishing_reel" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local rod = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.replica.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.replica.oceanfishingrod:GetTarget() or nil
            if target == nil or target.components.oceanfishinghook ~= nil or rod.replica.oceanfishingrod:IsLineTensionLow() then
                if not inst.AnimState:IsCurrentAnimation("hooked_loose_reeling") then
                    inst.AnimState:PlayAnimation("hooked_loose_reeling", true)
                end
            elseif rod.replica.oceanfishingrod:IsLineTensionGood() then
                if not inst.AnimState:IsCurrentAnimation("hooked_good_reeling") then
                    inst.AnimState:PlayAnimation("hooked_good_reeling", true)
                end
            elseif not inst.AnimState:IsCurrentAnimation("hooked_tight_reeling") then
                inst.AnimState:PlayAnimation("hooked_tight_reeling", true)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "give",
        tags = { "giving" },
		server_states = { "give" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("give")
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("give_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("give_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "catchonfire",
        tags = { "igniting" },
		server_states = { "catchonfire" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("light_fire")
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("light_fire_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("light_fire_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "spray_wax",
        tags = { "waxing" },
		server_states = { "spray_wax" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if not inst.sg:ServerStateMatches() then
                inst.AnimState:PlayAnimation("light_fire")
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("light_fire_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("light_fire_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "use_dumbbell_pre",
		tags = { "doing", "lifting_dumbbell" },
		server_states = { "use_dumbbell_pre", "use_dumbbell_loop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			inst.sg.statemem.state =
				inst.GetCurrentMightinessState ~= nil and
				inst:GetCurrentMightinessState() or
				"normal"

			if inst.sg.statemem.state == "wimpy" then
				inst.AnimState:PlayAnimation("dumbbell_skinny_pre")
				inst.AnimState:PushAnimation("dumbbell_skinny_lag", false)
			elseif inst.sg.statemem.state == "mighty" then
				inst.AnimState:PlayAnimation("dumbbell_mighty_pre")
				inst.AnimState:PushAnimation("dumbbell_mighty_lag", false)
			else
				inst.AnimState:PlayAnimation("dumbbell_normal_pre")
				inst.AnimState:PushAnimation("dumbbell_normal_lag", false)
			end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation(inst.sg.statemem.state == "mighty" and  "dumbbell_mighty_pst" or "dumbbell_normal_pst")
				inst.AnimState:SetFrame(2)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.sg.statemem.state == "mighty" and  "dumbbell_mighty_pst" or "dumbbell_normal_pst")
			inst.AnimState:SetFrame(2)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "use_dumbbell_pst",
		tags = { "doing", "lifting_dumbbell" },
		server_states = { "use_dumbbell_pst" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            if inst.GetCurrentMightinessState then
                local state = inst:GetCurrentMightinessState()
                if state == "wimpy" then
                    inst.AnimState:PlayAnimation("dumbbell_skinny_pst")
                elseif state == "normal" then
                    inst.AnimState:PlayAnimation("dumbbell_normal_pst")
                else
                    inst.AnimState:PlayAnimation("dumbbell_mighty_pst")
                end
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
        end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:ClearBufferedAction()
					inst.sg:GoToState("idle")
				end
			end),
		},
    },

    State{
        name = "tent",
        tags = { "tent", "busy" },
		server_states = { "tent" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "wakeup",
        tags = { "busy", "waking" },
		server_states = { "wakeup" },

        onenter = function(inst)
            inst.entity:SetIsPredictingMovement(false)
            inst.entity:FlattenMovementPrediction()
            SendRPCToServer(RPC.WakeUp)
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() and
                inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "noanim")
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },

    State{
        name = "eat",
        tags = { "busy" },
		server_states = { "eat" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "quickeat",
        tags = { "busy" },
		server_states = { "quickeat" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("quick_eat_pre")
            inst.AnimState:PushAnimation("quick_eat_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "usewardrobe",
		tags = { "doing", "busy" },
		server_states = { "usewardrobe" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("give")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("give_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("give_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "unsaddle",
        tags = { "doing", "busy" },
		server_states = { "unsaddle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("unsaddle_pre")
            inst.AnimState:PushAnimation("unsaddle_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("unsaddle")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("unsaddle")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "heavylifting_drop",
        tags = { "doing", "busy" },
		server_states = { "heavylifting_drop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("heavy_item_hat_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("heavy_item_hat_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "dostandingaction",
        tags = { "doing", "busy" },
		server_states = { "dostandingaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("give_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("give_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "doequippedaction",
        tags = { "doing", "busy" },
		server_states = { "doequippedaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give_equipped")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("give_equipped_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("give_equipped_pst")
            inst.sg:GoToState("idle", true)
        end,
    },


    State{
        name = "doshortaction",
        tags = { "doing", "busy" },
		server_states = { "doshortaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst:HasTag("beaver") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            else
                inst.AnimState:PlayAnimation("pickup")
                inst.AnimState:PushAnimation("pickup_lag", false)
            end
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "dohungrybuild",
		onenter = function(inst) inst.sg:GoToState("dolongaction") end,
    },

    State{
        name = "domediumaction",
        onenter = function(inst) inst.sg:GoToState("dolongaction") end,
    },

    State{
        name = "dowoodiefastpick",
        onenter = function(inst) inst.sg:GoToState("dolongaction") end,
    },

    State{
        name = "dolongestaction",
        onenter = function(inst) inst.sg:GoToState("dolongaction") end,
    },

	State{
		--from crafting
		name = "makeballoon",
		onenter = function(inst) inst.sg:GoToState("dolongaction") end,
	},

    State{
        name = "dolongaction",
        tags = { "doing", "busy" },
		server_states = { "dolongaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			--V2C: always use "dontstarve/wilson/make_trap" for preview
			--     (even for things like makeballoon or shave)
			--     switch to server sound when action actually executes on server
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make_preview")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("build_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make_preview")
        end,
    },

	State{ name = "carvewood_boards", onenter = function(inst) inst.sg:GoToState("carvewood") end },
    State{
        name = "carvewood",
        tags = { "doing", "busy" },
		server_states = { "carvewood" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("useitem_pre")
			inst.AnimState:PushAnimation("useitem_lag", false)

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("useitem_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		timeline =
		{
			FrameEvent(7, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("useitem_pst")
			inst.sg:GoToState("idle", true)
		end,
    },

    State{
        name = "dojostleaction",
        tags = { "doing", "busy" },
		server_states = { "dojostleaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local rider = inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip_lag", false)
                inst.sg.statemem.iswhip = true
			elseif equip ~= nil and equip:HasTag("pocketwatch") then
				inst.AnimState:PlayAnimation("pocketwatch_atk_pre" )
				inst.AnimState:PushAnimation("pocketwatch_atk_lag", false)
				inst.sg.statemem.ispocketwatch = true
            elseif equip ~= nil and equip:HasTag("jab") then
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("spearjab_lag", false)
            elseif equip ~= nil and
                equip.replica.inventoryitem ~= nil and
                equip.replica.inventoryitem:IsWeapon() and
                not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            elseif equip ~= nil and
                (equip:HasTag("light") or
                equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            else
                inst.AnimState:PlayAnimation("punch")
            end

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "doswipeaction",
        tags = { "doing", "busy" },
		server_states = { "doswipeaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")
            inst.AnimState:PushAnimation("atk_prop_lag", false)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "dochannelaction",
        tags = { "doing", "busy" },
		server_states = { "dochannelaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("channel_pre")
            inst.AnimState:PushAnimation("channel_loop", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("channel_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("channel_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "dodismountaction",
        tags = { "doing", "busy" },
		server_states = { "dodismountaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dismount")
            inst.AnimState:PushAnimation("dismount_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("heavy_mount")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("heavy_mount")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "dostorytelling",
        tags = { "doing", "busy" },
		server_states = { "dostorytelling", "dostorytelling_loop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if inst:HasTag("mime") then
				inst.sg.statemem.mime = true
				inst.AnimState:PlayAnimation("mime13")
			else
				inst.AnimState:PlayAnimation("idle_walter_storytelling_pre")
				inst.AnimState:PushAnimation("idle_walter_storytelling")
			end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				if inst.sg.statemem.mime then
					inst.sg:GoToState("idle")
				else
					inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
					inst.sg:GoToState("idle", true)
				end
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			if inst.sg.statemem.mime then
				inst.sg:GoToState("idle")
			else
				inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
				inst.sg:GoToState("idle", true)
			end
        end,
    },

    State{
        name = "steer_boat_idle_pre",
        tags = { "is_using_steering_wheel", "doing" },
		server_states = { "steer_boat_idle_pre", "steer_boat_idle_loop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.Transform:SetPredictedNoFaced()
            inst.AnimState:PlayAnimation("steer_idle_pre")
            inst.AnimState:PushAnimation("steer_lag", false)
            inst:PerformPreviewBufferedAction()

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.Transform:ClearPredictedFacingModel()
        end,
    },

    State{
        name = "aim_cannon_pre",
        tags = { "is_using_cannon", "doing" },
		server_states = { "aim_cannon_pre", "aim_cannon_idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.Transform:SetPredictedEightFaced()
            inst.AnimState:PlayAnimation("aim_cannon_pre")
            inst.AnimState:PushAnimation("aim_cannon_loop", true)
            inst:PerformPreviewBufferedAction()

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.Transform:ClearPredictedFacingModel()
        end,
    },

    State{
        name = "mount_plank",
        tags = { "idle" },
		server_states = { "mount_plank" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_idle_pre")
            inst.AnimState:PushAnimation("plank_idle_loop", true)
            inst:PerformPreviewBufferedAction()

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "abandon_ship_pre",
		tags = { "doing", "busy", "drowning" },
		server_states = { "abandon_ship_pre", "abandon_ship" },

		onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("plank_hop_pre")

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "channel_longaction",
		tags = { "doing", "canrotate", "channeling" },
		server_states = { "channel_longaction" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("give")

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
        end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("give_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("give_pst")
			inst.sg:GoToState("idle", true)
		end,
    },

    State{
        name = "use_pocket_scale",
        tags = { "doing" },
		server_states = { "use_pocket_scale" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("action_uniqueitem_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("pocket_scale_weigh")
				inst.AnimState:SetFrame(63)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("pocket_scale_weigh")
			inst.AnimState:SetFrame(63)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "use_fan",
        tags = { "doing" },
		server_states = { "use_fan" },

        onenter = function(inst)
            local invobject = nil
            if inst.bufferedaction ~= nil and
                inst.bufferedaction.invobject ~= nil and
                inst.bufferedaction.invobject:HasTag("channelingfan") then
                inst.sg:AddStateTag("busy")
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("action_uniqueitem_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("fan")
				inst.AnimState:SetFrame(91)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("fan")
			inst.AnimState:SetFrame(91)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "book",
		tags = { "doing", "busy" },
		server_states = { "book", "book2" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			if inst:HasTag("canrepeatcast") and inst.entity:FlattenMovementPrediction() then
				inst:PerformPreviewBufferedAction()
				inst.sg:GoToState("idle", "noanim")
				return
			end

            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("action_uniqueitem_lag", false)

			--[[local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if book ~= nil and (book.components.spellbook ~= nil or book.components.aoetargeting ~= nil) then
				inst.sg:AddStateTag("busy")
			end]]

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("book")
				inst.AnimState:SetFrame(72)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("book")
			inst.AnimState:SetFrame(72)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "book_peruse",
        tags = { "doing" },
		server_states = { "book_peruse" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("action_uniqueitem_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("book") --better exit than peruse
				inst.AnimState:SetFrame(72)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("book") --better exit than peruse
			inst.AnimState:SetFrame(72)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
		name = "jumpin_pre",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "jumpin_pre", "jumpin" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local heavy = inst.replica.inventory:IsHeavyLifting()
            inst.AnimState:PlayAnimation(heavy and "heavy_jump_pre" or "jump_pre")
            inst.AnimState:PushAnimation(heavy and "heavy_jump_lag" or "jump_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "castspell",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "castspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "quickcastspell",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "quickcastspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk_lag", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "veryquickcastspell",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "veryquickcastspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk_lag", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "mermbuffcastspell",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "mermbuffcastspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cointoss_pre")
            inst.AnimState:PushAnimation("cointoss_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "cointosscastspell",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "cointosscastspell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cointoss_pre")
            inst.AnimState:PushAnimation("cointoss_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },
    
    State{
        name = "castspellmind",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "castspellmind" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			if inst:HasTag("canrepeatcast") and inst.entity:FlattenMovementPrediction() then
				inst:PerformPreviewBufferedAction()
				inst.sg:GoToState("idle", "noanim")
				return
			end

            inst.AnimState:PlayAnimation("pyrocast_pre")
			inst.AnimState:PushAnimation("pyrocast_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

	State{
		name = "remotecast",
		tags = { "doing", "busy" },
		server_states = { "remotecast_pre", "remotecast_trigger" },

		onenter = function(inst)
			inst.components.locomotor:Stop()

			if inst:HasTag("canrepeatcast") and inst.entity:FlattenMovementPrediction() then
				inst:PerformPreviewBufferedAction()
				inst.sg:GoToState("idle", "noanim")
				return
			end

			inst.AnimState:PlayAnimation("useitem_dir_pre")
			inst.AnimState:PushAnimation("useitem_dir_lag", false)

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("useitem_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("useitem_pst")
			inst.sg:GoToState("idle", true)
		end,
	},

    State{
        name = "play_gnarwail_horn",
		tags = { "doing", "busy", "playing", "canrotate" },
		server_states = { "play_gnarwail_horn" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hornblow_pre")
            inst.AnimState:PushAnimation("hornblow_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "play_strum",
		tags = { "doing", "busy", "playing", "canrotate" },
		server_states = { "play_strum" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("strum_pre")
            inst.AnimState:PushAnimation("strum_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "summon_abigail",
		tags = { "doing", "busy", "canrotate" },
		server_states = { "summon_abigail" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_channel")

			inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
            	inst.AnimState:PlayAnimation("wendy_channel_pst")
				inst.AnimState:SetFrame(45)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:SetFrame(45)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "unsummon_abigail",
        tags = { "doing", "busy" },
		server_states = { "unsummon_abigail" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_recall")
            inst.AnimState:PushAnimation("wendy_recall_lag", false)

			if inst.bufferedaction ~= nil then
				local flower = inst.bufferedaction.invobject
                if flower ~= nil and flower:IsValid() then
                    if flower.skin_id ~= 0 then
                        inst.AnimState:OverrideItemSkinSymbol( "flower", flower.AnimState:GetBuild(), "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end
				inst:PerformPreviewBufferedAction()
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("wendy_recall_pst")
				inst.AnimState:SetFrame(17)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("wendy_recall_pst")
			inst.AnimState:SetFrame(17)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "commune_with_abigail",
        tags = { "doing", "busy" },
        server_states = { "commune_with_abigail" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_commune_pre")
            inst.AnimState:PushAnimation("wendy_commune_lag", false)

			if inst.bufferedaction ~= nil then
                local flower = inst.bufferedaction.invobject
                if flower ~= nil and flower:IsValid() then
                    if flower.skin_id ~= 0 then
                        inst.AnimState:OverrideItemSkinSymbol( "flower", flower.AnimState:GetBuild(), "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end
				inst:PerformPreviewBufferedAction()
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("wendy_commune_pst")
				inst.AnimState:SetFrame(33)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("wendy_commune_pst")
			inst.AnimState:SetFrame(33)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "quicktele",
        tags = { "doing", "busy", "canrotate" },
		server_states = { "quicktele" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.replica.rider ~= nil and inst.replica.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk_lag", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "combat_lunge_start",
        tags = { "doing", "busy", "nointerrupt" },
		server_states = { "combat_lunge_start", "combat_lunge" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("lunge_pre")
            inst.AnimState:PushAnimation("lunge_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg.statemem.twirled = true
                inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil, true)
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    if not inst.sg.statemem.twirled then
                        inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil, true)
                    end
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "combat_leap_start",
        tags = { "doing", "busy", "nointerrupt" },
		server_states = { "combat_leap_start", "combat_leap" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.AnimState:PlayAnimation("atk_leap_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "combat_superjump_start",
        tags = { "doing", "busy", "nointerrupt" },
		server_states = { "combat_superjump_start", "combat_superjump" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")
            inst.AnimState:PushAnimation("superjump_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "blowdart_special",
        tags = { "doing", "busy", "nointerrupt" },
		server_states = { "blowdart_special" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dart_pre")
            inst.AnimState:PushAnimation("dart_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "slingshot_shoot",
        tags = { "attack" },
		server_states = { "slingshot_shoot" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("slingshot_pre")
            inst.AnimState:PushAnimation("slingshot_lag", true)

            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(3)
            end

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
				if buffaction.target ~= nil and buffaction.target:IsValid() then
					inst:ForceFacePoint(buffaction.target:GetPosition())
	                inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
				end

                inst:PerformPreviewBufferedAction()
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:HasStateTag("idle") then
				if inst.sg:HasStateTag("attack") and not inst:HasTag("attack") then
					local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equip == nil or not equip:HasTag("ammoloaded") then
						inst.sg:GoToState("idle", "noanim")
					else
						inst.sg:RemoveStateTag("attack")
					end
				end
			elseif inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:AddStateTag("idle")
					inst.sg:AddStateTag("canrotate")
					inst.entity:SetIsPredictingMovement(false) -- so the animation will come across
					ClearCachedServerState(inst)
				end
			elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle")
			end
        end,

        ontimeout = function(inst)
			if inst.sg:HasStateTag("idle") then
				inst.sg:GoToState("idle", "noanim")
			else
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle")
			end
        end,

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
		end,
    },

    State{
        name = "throw_line",
        tags = { "doing", "busy", "nointerrupt" },
		server_states = { "throw_line" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "catch_pre",
		tags = { "doing", "notalking", "readytocatch" },
		server_states = { "catch_pre", "catch" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("catch_pre")

            inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "attack",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
			local combat = inst.replica.combat
			if combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end

			local cooldown = combat:MinAttackPeriod()
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
            end
			combat:StartAttack()
            inst.components.locomotor:Stop()
            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local rider = inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                if equip ~= nil and (equip:HasTag("rangedweapon") or equip:HasTag("projectile")) then
                    inst.AnimState:PlayAnimation("player_atk_pre")
                    inst.AnimState:PushAnimation("player_atk", false)
                    if (equip.projectiledelay or 0) > 0 then
                        --V2C: Projectiles don't show in the initial delayed frames so that
                        --     when they do appear, they're already in front of the player.
                        --     Start the attack early to keep animation in sync.
                        inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                        if inst.sg.statemem.projectiledelay > FRAMES then
                            inst.sg.statemem.projectilesound =
                                (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                                (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                                (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                                "dontstarve/wilson/attack_weapon"
                        elseif inst.sg.statemem.projectiledelay <= 0 then
                            inst.sg.statemem.projectiledelay = nil
                        end
                    end
                    if inst.sg.statemem.projectilesound == nil then
                        inst.SoundEmitter:PlaySound(
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                            "dontstarve/wilson/attack_weapon",
                            nil, nil, true
                        )
                    end
                    if cooldown > 0 then
                        cooldown = math.max(cooldown, 13 * FRAMES)
                    end
                else
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                    DoMountSound(inst, rider:GetMount(), "angry")
                    if cooldown > 0 then
                        cooldown = math.max(cooldown, 16 * FRAMES)
                    end
                end
            elseif equip ~= nil and equip:HasTag("toolpunch") then
                inst.AnimState:PlayAnimation("toolpunch")
                inst.sg.statemem.istoolpunch = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 17 * FRAMES)
                end
			elseif equip ~= nil and equip:HasTag("pocketwatch") then
				inst.AnimState:PlayAnimation(inst.sg.statemem.chained and "pocketwatch_atk_pre_2" or "pocketwatch_atk_pre" )
				inst.AnimState:PushAnimation("pocketwatch_atk", false)
				inst.sg.statemem.ispocketwatch = true
				cooldown = math.max(cooldown, 15 * FRAMES)
                if equip:HasTag("shadow_item") then
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
					inst.AnimState:Show("pocketwatch_weapon_fx")
					inst.sg.statemem.ispocketwatch_fueled = true
                else
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
					inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
            elseif equip ~= nil and equip:HasTag("book") then
                inst.AnimState:PlayAnimation("attack_book")
                inst.sg.statemem.isbook = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 19 * FRAMES)
                end
            elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
				inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
                inst.AnimState:PushAnimation("woodie_chop_loop", false)
                inst.sg.statemem.ischop = true
                cooldown = math.max(cooldown, 11 * FRAMES)
            elseif equip ~= nil and equip:HasTag("jab") then
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("spearjab", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 21 * FRAMES)
                end
            elseif equip ~= nil and
                equip.replica.inventoryitem ~= nil and
                equip.replica.inventoryitem:IsWeapon() and
                not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                if (equip.projectiledelay or 0) > 0 then
                    --V2C: Projectiles don't show in the initial delayed frames so that
                    --     when they do appear, they're already in front of the player.
                    --     Start the attack early to keep animation in sync.
                    inst.sg.statemem.projectiledelay = 8 * FRAMES - equip.projectiledelay
                    if inst.sg.statemem.projectiledelay > FRAMES then
                        inst.sg.statemem.projectilesound =
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                            (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                            "dontstarve/wilson/attack_weapon"
                    elseif inst.sg.statemem.projectiledelay <= 0 then
                        inst.sg.statemem.projectiledelay = nil
                    end
                end
                if inst.sg.statemem.projectilesound == nil then
                    inst.SoundEmitter:PlaySound(
                        (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                        (equip:HasTag("shadow") and "dontstarve/wilson/attack_nightsword") or
                        (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
                        (equip:HasTag("firepen") and "wickerbottom_rework/firepen/launch") or
                        "dontstarve/wilson/attack_weapon",
                        nil, nil, true
                    )
                end
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            elseif equip ~= nil and
                (equip:HasTag("light") or
                equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 13 * FRAMES)
                end
            elseif inst:HasTag("weremoose") then
                inst.sg.statemem.ismoose = true
				if inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c") then
					inst.AnimState:PlayAnimation("punch_b")
				elseif inst.AnimState:IsCurrentAnimation("punch_b") then
					if inst:HasTag("weremoosecombo") then
						inst.sg.statemem.ismoosesmash = true
						inst.AnimState:PlayAnimation("moose_slam")
						inst.SoundEmitter:PlaySound("meta2/woodie/weremoose_groundpound", nil, nil, true)
					else
						inst.AnimState:PlayAnimation("punch_c")
					end
				else
					inst.AnimState:PlayAnimation("punch_a")
				end
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 15 * FRAMES)
                end
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                if cooldown > 0 then
                    cooldown = math.max(cooldown, 24 * FRAMES)
                end
            end

			local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if cooldown > 0 then
                inst.sg:SetTimeout(cooldown)
            end
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= FRAMES then
                    if inst.sg.statemem.projectilesound ~= nil then
                        inst.SoundEmitter:PlaySound(inst.sg.statemem.projectilesound, nil, nil, true)
                        inst.sg.statemem.projectilesound = nil
                    end
                    if inst.sg.statemem.projectiledelay <= 0 then
                        inst:ClearBufferedAction()
                        inst.sg:RemoveStateTag("abouttoattack")
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.ismoose and not inst.sg.statemem.ismoosesmash then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/punch", nil, nil, true)
                end
            end),
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.isbeaver then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                elseif inst.sg.statemem.ischop then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                end
            end),
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.ismoose then
					if inst.sg.statemem.ismoosesmash then
						inst:PushMooseSmashShake()

						--V2C: first frame is blank, so no need to worry about forcing instant facing update
						local x, y, z = inst.Transform:GetWorldPosition()
						local fx = SpawnPrefab("weremoose_smash_fx")
						fx.Transform:SetPosition(x, 0, z)
						fx.Transform:SetRotation(inst.Transform:GetRotation())
					end
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if not (inst.sg.statemem.isbeaver or
                        inst.sg.statemem.ismoose or
                        inst.sg.statemem.iswhip or
						inst.sg.statemem.ispocketwatch or
                        inst.sg.statemem.isbook) and
                    inst.sg.statemem.projectiledelay == nil then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(17*FRAMES, function(inst)
				if inst.sg.statemem.ispocketwatch then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
                inst.replica.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "attack_pillow_pre",
		tags = { "doing", "busy" },
		server_states = { "attack_pillow_pre", "attack_pillow" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pillow_pre")
            inst.AnimState:PushAnimation("atk_pillow_hold", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "attack_prop_pre",
        tags = { "propattack", "doing", "busy" },
		server_states = { "attack_prop_pre", "attack_prop" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")
            inst.AnimState:PushAnimation("atk_prop_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

	State{
		name = "throw_keep_equip",
		tags = { "busy" },
		server_states = { "throw_keep_equip" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw_lag", false)

			local buffaction = inst:GetBufferedAction()
			if buffaction ~= nil then
				inst:PerformPreviewBufferedAction()

				if buffaction.pos ~= nil then
					inst:ForceFacePoint(buffaction:GetActionPoint():Get())
				end
			end

			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle")
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
		end,
	},

    State{
        name = "throw",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
			local combat = inst.replica.combat
			if combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end

			combat:StartAttack()
			inst.sg:SetTimeout(math.max(11 * FRAMES, combat:MinAttackPeriod()))
            inst.components.locomotor:Stop()

			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw", false)

			local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:ClearBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
                inst.replica.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "blowdart",
        tags = { "attack", "notalking", "abouttoattack" },

        onenter = function(inst)
			local combat = inst.replica.combat
			if combat:InCooldown() then
				inst.sg:RemoveStateTag("abouttoattack")
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle", true)
				return
			end

			combat:StartAttack()
			inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, combat:MinAttackPeriod()))

            local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("dart_pre")
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(5)
            end
            inst.AnimState:PushAnimation("dart", false)

			local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:FacePoint(buffaction.target:GetPosition())
                    inst.sg.statemem.attacktarget = buffaction.target
                    inst.sg.statemem.retarget = buffaction.target
                end
            end

            if (equip.projectiledelay or 0) > 0 then
                --V2C: Projectiles don't show in the initial delayed frames so that
                --     when they do appear, they're already in front of the player.
                --     Start the attack early to keep animation in sync.
                inst.sg.statemem.projectiledelay = (inst.sg.statemem.chained and 9 or 14) * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.chained then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                if not inst.sg.statemem.chained then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, nil, true)
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if not inst.sg.statemem.chained and inst.sg.statemem.projectiledelay == nil then
                    inst:ClearBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg:HasStateTag("abouttoattack") then
                inst.replica.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "migrate",
        tags = { "doing", "busy" },
		server_states = { "migrate" },

        onenter = function(inst)
            inst.sg.statemem.heavy = inst.replica.inventory:IsHeavyLifting()
            inst.components.locomotor:Stop()
            if inst.sg.statemem.heavy then
                inst.AnimState:PlayAnimation("heavy_item_hat")
                inst.AnimState:PushAnimation("heavy_item_hat_lag", false)
            else
                inst.AnimState:PlayAnimation("pickup")
                inst.AnimState:PushAnimation("pickup_lag", false)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_item_hat_pst" or "pickup_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_item_hat_pst" or "pickup_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "bundle",
        tags = { "doing", "busy" },
		server_states = { "bundle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make_preview")
            inst.AnimState:PlayAnimation("wrap_pre")
            inst.AnimState:PushAnimation("wrap_loop", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("wrap_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("wrap_pst")
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make_preview")
        end,
    },

    State{
        name = "startconstruct",

        onenter = function(inst)
            inst.sg:GoToState("construct", true)
        end,
    },

    State{
        name = "construct",
        tags = { "doing", "busy" },
		server_states = { "construct", "constructing" },

        onenter = function(inst, start)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make_preview")
            if start then
                inst.sg.statemem.start = true
                inst.AnimState:PlayAnimation("build_pre")
                inst.AnimState:PushAnimation("build_loop", true)
            else
                inst.AnimState:PlayAnimation("construct_pre")
                inst.AnimState:PushAnimation("construct_loop", true)
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.start then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.start then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation(inst.sg.statemem.start and "build_pst" or "construct_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation(inst.sg.statemem.start and "build_pst" or "construct_pst")
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make_preview")
        end,
    },

    State{
        name = "startchanneling",
        tags = { "doing", "busy", "prechanneling" },
		server_states = { "startchanneling", "channeling" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("channel_pre")
            inst.AnimState:PushAnimation("channel_loop", true)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("channel_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("channel_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

	--Basically an "instant" action but with animation if you were idle
	State{
		name = "start_channelcast",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			if inst.bufferedaction then
				inst:PerformPreviewBufferedAction()
				StartPreviewChannelCast(inst, inst.bufferedaction)
			end
			if IsChannelCastingItem(inst) then
				inst.sg.statemem.channelcastitem = true
				inst.AnimState:PlayAnimation("channelcast_idle_pre")
				inst.AnimState:PushAnimation("channelcast_idle")
			else
				inst.AnimState:PlayAnimation("channelcast_oh_idle_pre")
				inst.AnimState:PushAnimation("channelcast_oh_idle")
			end
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst:IsChannelCasting() then
				if inst.entity:FlattenMovementPrediction() then
					StopPreviewChannelCast(inst)
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation(inst.sg.statemem.channelcastitem and "channelcast_idle_pst" or "channelcast_oh_idle_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.sg.statemem.channelcastitem and "channelcast_idle_pst" or "channelcast_oh_idle_pst")
			inst.sg:GoToState("idle", true)
		end,
	},

	--Basically an "instant" action but with animation if you were idle
	State{
		name = "stop_channelcast",
		tags = { "idle", "canrotate" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			if inst.bufferedaction then
				inst:PerformPreviewBufferedAction()
				StartPreviewChannelCast(inst, inst.bufferedaction)
			end
			if IsChannelCastingItem(inst) then
				inst.sg.statemem.channelcastitem = true
				inst.AnimState:PlayAnimation("channelcast_idle_pst")
			else
				inst.AnimState:PlayAnimation("channelcast_oh_idle_pst")
			end
			inst.AnimState:PushAnimation("idle_loop")
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if not inst:IsChannelCasting() then
				if inst.entity:FlattenMovementPrediction() then
					StopPreviewChannelCast(inst)
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation(inst.sg.statemem.channelcastitem and "channelcast_idle_pre" or "channelcast_oh_idle_pre")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.sg.statemem.channelcastitem and "channelcast_idle_pre" or "channelcast_oh_idle_pre")
			inst.sg:GoToState("idle", true)
		end,
	},

    State{
        name = "till_start",
        tags = { "doing", "busy" },
		server_states = { "till_start", "till" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

			local equippedTool = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equippedTool ~= nil and equippedTool:HasTag("DIG_tool") then
				inst.sg.statemem.fliptool = true
				inst.AnimState:PlayAnimation("till2_pre")
				inst.AnimState:PushAnimation("till2_lag", false)
			else
				inst.AnimState:PlayAnimation("till_pre")
				inst.AnimState:PushAnimation("till_lag", false)
			end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation(inst.sg.statemem.fliptool and "till2_pst" or "till_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.sg.statemem.fliptool and "till2_pst" or "till_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "pour",
        tags = { "doing", "busy" },
		server_states = { "pour" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("water_pre")
            inst.AnimState:PushAnimation("water_lag", false)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "portal_jumpin_pre",
        tags = { "busy" },
		server_states = { "portal_jumpin_pre", "portal_jumpin" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")
            inst.AnimState:PushAnimation("wortox_portal_jumpin_lag", false)

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                inst:PerformPreviewBufferedAction()

                if buffaction.pos ~= nil then
                    inst:ForceFacePoint(buffaction:GetActionPoint():Get())
                end
            end

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    --------------------------------------------------------------------------
    --Wormwood

	State{ name = "form_bush",		onenter = function(inst) inst.sg:GoToState("form_log") end },
	State{ name = "form_bush2",		onenter = function(inst) inst.sg:GoToState("form_log") end },
	State{ name = "form_juicy",		onenter = function(inst) inst.sg:GoToState("form_log") end },
	State{ name = "form_bulb",		onenter = function(inst) inst.sg:GoToState("form_log") end },
	State{ name = "form_moon",		onenter = function(inst) inst.sg:GoToState("form_log") end },
	State{ name = "form_monkey",	onenter = function(inst) inst.sg:GoToState("form_log") end },

	State{
		name = "form_log",
		tags = { "doing", "busy" },
		server_states = { "form_log" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("form_log_pre")
			inst.AnimState:PushAnimation("form_log_lag", false)

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle")
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
		end,
	},

    State{
        name = "fertilize",
        tags = { "doing", "busy" },
		server_states = { "fertilize" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fertilize_pre")
            inst.AnimState:PushAnimation("fertilize_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("item_hat")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("item_hat")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "fertilize_short",
        tags = { "doing", "busy" },
		server_states = { "fertilize_short" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("short_fertilize_pre")
            inst.AnimState:PushAnimation("short_fertilize_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "spawn_mutated_creature",
        tags = { "doing", "busy" },
		server_states = { "spawn_mutated_creature" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
			inst.AnimState:PlayAnimation("wormwood_cast_spawn_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("wormwood_cast_spawn")
				inst.AnimState:SetFrame(37)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("wormwood_cast_spawn")
			inst.AnimState:SetFrame(37)
			inst.sg:GoToState("idle", true)
        end,
    },

    --------------------------------------------------------------------------
    -- Wigfrid

    State{
        name = "sing_pre",
        tags = {"busy", "nointerrupt"},
		server_states = { "sing_pre", "sing", "cantsing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("sing_pre", false)
            inst.AnimState:PushAnimation("sing_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },


    State{
        name = "sing_fail",
        tags = { "busy" },

        onenter = function(inst)
            inst:PerformPreviewBufferedAction()

            inst.sg:GoToState("idle")
            inst.sg:SetTimeout(TIMEOUT)
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    --------------------------------------------------------------------------
	-- Wolfgang Might Gym

	State{
		name = "mighty_gym_success_perfect",
		server_states = { "mighty_gym_success_perfect" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("mighty_gym_lift") end,
	},

	State{
		name = "mighty_gym_success",
		server_states = { "mighty_gym_success" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("mighty_gym_lift") end,
	},

	State{
		name = "mighty_gym_workout_fail",
		server_states = { "mighty_gym_workout_fail" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("mighty_gym_lift") end,
	},

	State{
        name = "mighty_gym_lift",
        tags = { "busy" },

        onenter = function(inst)
			local anim = "lift" --(inst.player_classified ~= nil and inst.player_classified.currentmightiness:value() >= 100) and "lift_full" or "lift"

            inst.AnimState:PlayAnimation(anim.."_pre")
            inst.AnimState:PushAnimation(anim.."_lag", false)
            inst:PerformPreviewBufferedAction()

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },


    State{
        name = "mighty_gym_exit",
        tags = {"exiting_gym"}, --,"busy"
		server_states = { "jumpout" },

        onenter = function(inst)
            inst.entity:SetIsPredictingMovement(false)
            inst.entity:FlattenMovementPrediction()
            SendRPCToServer(RPC.exitgym)
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() and
                inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", "noanim")
        end,

        onexit = function(inst)
            inst.entity:SetIsPredictingMovement(true)
        end,
    },
    --------------------------------------------------------------------------

    State{
        name = "furl_boost",
        tags = { "doing" },
		server_states = { "furl_boost", "furl" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("pull_big_pre")
            inst.AnimState:PushAnimation("pull_big_lag", false)

            inst:PerformPreviewBufferedAction()

            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("pull_big_pst")
				inst.AnimState:SetFrame(10)
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("pull_big_pst")
			inst.AnimState:SetFrame(10)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "furl_fail",
        tags = { "busy", "furl_fail" },
		server_states = { "furl_fail" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("pull_fail_lag")
            inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
		end,
    },

    State{
        name = "tackle_pre",
        tags = { "busy" },
		server_states = { "tackle_pre", "tackle_start", "tackle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_lag_pre")
            inst.AnimState:PushAnimation("charge_lag", false)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "beaver_tailslap_pre",
        tags = { "busy" },
		server_states = { "beaver_tailslap_pre", "beaver_tailslap" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("tail_slap_pre")
            inst.AnimState:PushAnimation("tail_slap_lag", false)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("tail_slap")
				inst.AnimState:SetFrame(21)
				inst.sg:GoToState("idle", true)
            end
        end,

		timeline =
		{
			FrameEvent(10, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("tail_slap")
			inst.AnimState:SetFrame(21)
			inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "weregoose_takeoff_pre",
        tags = { "busy" },
		server_states = { "weregoose_takeoff_pre", "weregoose_takeoff" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("takeoff_pre")
            inst.AnimState:PushAnimation("takeoff_lag", false)
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

		timeline =
		{
			FrameEvent(10, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "winters_feast_eat",
        tags = { "doing", "feasting" }, -- feasting tag is for music
		server_states = { "winters_feast_eat" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("feast_eat_pre_pre")
            inst.AnimState:PushAnimation("feast_eat_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.AnimState:PlayAnimation("feast_eat_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("feast_eat_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

	State{
		name = "pocketwatch_openportal",
		server_states = { "pocketwatch_openportal" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_busy") end,
	},

	State{
		name = "pocketwatch_cast",
		server_states = { "pocketwatch_cast" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_busy") end,
	},

	State{
		name = "herd_followers",
		server_states = { "herd_followers" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_busy") end,
	},

	State{
		name = "repel_followers",
		server_states = { "repel_followers" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_busy") end,
	},

	State{
		name = "removeupgrademodules",
		server_states = { "removeupgrademodules" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_busy") end,
	},

    State{
        name = "use_inventory_item_busy",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("useitem_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("useitem_pst")
				inst.sg:GoToState("idle", true)
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("useitem_pst")
			inst.sg:GoToState("idle", true)
        end,
    },

	State{
		name = "throw_deploy",
		server_states = { "throw_deploy" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("use_inventory_item_dir_busy") end,
	},

	State{
		name = "use_inventory_item_dir_busy", --directional version with facings
		tags = { "doing", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("useitem_dir_pre")
			inst.AnimState:PushAnimation("useitem_dir_lag", false)

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("useitem_dir_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("useitem_pst")
			inst.sg:GoToState("idle", true)
		end,
	},

	State{
		name = "bedroll",
		server_states = { "bedroll" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "cookbook_open",
		server_states = { "cookbook_open" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "use_beef_bell",
		server_states = { "use_beef_bell" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "play_flute",
		server_states = { "play_flute" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "play_horn",
		server_states = { "play_horn" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "play_bell",
		server_states = { "play_bell" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "play_whistle",
		server_states = { "play_whistle" },
		forward_server_states = true,
		onenter = function(inst) inst.sg:GoToState("action_uniqueitem_busy") end,
	},

	State{
		name = "action_uniqueitem_busy",
		tags = { "doing", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("action_uniqueitem_pre")
			inst.AnimState:PushAnimation("action_uniqueitem_lag", false)

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("flute")
				inst.AnimState:SetFrame(103)
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("flute")
			inst.AnimState:SetFrame(103)
			inst.sg:GoToState("idle", true)
		end,
	},

    State{
        name = "pocketwatch_warpback_pre",
		tags = { "busy" },
		server_states = { "pocketwatch_warpback_pre", "pocketwatch_warpback" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp_pre")
            inst.AnimState:PushAnimation("pocketwatch_warp_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    --------------------------------------------------------------------------
    -- WX78 Rework
    State {
        name = "applyupgrademodule",
		tags = { "busy", "doing" },
		server_states = { "applyupgrademodule" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("upgrade_pre")
			inst.AnimState:PushAnimation("upgrade_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

	--------------------------------------------------------------------------
	-- Maxwell rework

	State{
		name = "start_using_tophat",
		tags = { "doing", "busy" },
		server_states = { "start_using_tophat", "using_tophat" },

		onenter = function(inst)
			inst.components.locomotor:Stop()

			local buffaction = inst:GetBufferedAction()
			local hat = buffaction ~= nil and buffaction.invobject or nil
			if hat ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == hat then
				inst.AnimState:PlayAnimation("tophat_equipped_pre")
				inst.AnimState:PushAnimation("tophat_equipped_lag", false)
				inst.sg.statemem.equipped = true
			else
				inst.AnimState:PlayAnimation("tophat_empty_pre")
				inst.AnimState:PushAnimation("tophat_empty_lag", false)
			end

			if buffaction ~= nil then
				inst:PerformPreviewBufferedAction()
			end
			inst.sg:SetTimeout(TIMEOUT)
		end,

		timeline =
		{
			TimeEvent(8 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("using_tophat")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation(inst.sg.statemem.equipped and "tophat_equipped_pst" or "tophat_empty_pst")
				inst.AnimState:SetFrame(9)
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation(inst.sg.statemem.equipped and "tophat_equipped_pst" or "tophat_empty_pst")
			inst.AnimState:SetFrame(9)
			inst.sg:GoToState("idle", true)
		end,
	},

	State{
		name = "using_tophat",
		tags = { "doing", "overridelocomote" },

		onenter = function(inst)
			inst.entity:SetIsPredictingMovement(false)
			ClearCachedServerState(inst)
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.bufferedaction == nil and not inst:HasTag("usingmagiciantool") then
				inst.sg:GoToState("idle", "noanim")
			end
		end,

		ontimeout = function(inst)
			if inst.bufferedaction ~= nil and inst.bufferedaction.ispreviewing then
				inst:ClearBufferedAction()
				inst.sg:GoToState("idle")
			end
		end,

		events =
		{
			EventHandler("locomote", function(inst)
				inst.sg:GoToState("stop_using_tophat", true)
				return true
			end),
		},

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
		end,
	},

	State{
		name = "stop_using_tophat",
		tags = { "idle", "overridelocomote" },

		onenter = function(inst, locomoting)
			inst.AnimState:PlayAnimation(
				inst:HasTag("usingmagiciantool_wasequipped") and
				inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == nil and
				"tophat_equipped_pst" or
				"tophat_empty_pst"
			)
			if locomoting then
				inst.sg.statemem.overridelocomote = true
				inst.components.playercontroller:RemotePredictOverrideLocomote()
			else
				inst:PerformPreviewBufferedAction()
			end
		end,

		onupdate = function(inst)
			if inst.sg:HasStateTag("overridelocomote") then
				if inst.sg.statemem.overridelocomote then
					inst.components.playercontroller:RemotePredictOverrideLocomote()
				end
			elseif not inst.components.locomotor:HasDestination() then
				inst.sg:GoToState("idle", "noanim")
				return
			end
			if inst.sg.statemem.stopped then
				if not (inst.AnimState:IsCurrentAnimation("tophat_equipped_pst") or
						inst.AnimState:IsCurrentAnimation("tophat_empty_pst")) then
					inst.sg:GoToState("idle", "noanim")
					return
				end
			elseif not inst:HasTag("usingmagiciantool") then
				inst.sg.statemem.stopped = true
				inst.entity:SetIsPredictingMovement(false)
			end
		end,

		timeline =
		{
			TimeEvent(7 * FRAMES, function(inst)
				inst.sg:AddStateTag("canrotate")
			end),
			TimeEvent(8 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("overridelocomote")
			end),
		},

		events =
		{
			EventHandler("locomote", function(inst)
				return inst.sg:HasStateTag("overridelocomote")
			end),
		},

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
		end,
	},

	State{
        name = "scythe",
		tags = { "busy" },
        server_states = { "scythe" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("scythe_pre")
			inst.AnimState:PushAnimation("scythe_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst.sg:ServerStateMatches() then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

	--------------------------------------------------------------------------
	--Sitting states

	State{
		name = "start_sitting",
		tags = { "busy" },
		server_states = { "start_sitting", "sit_jumpon", "sitting" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			local buffaction = inst:GetBufferedAction()
			local chair = buffaction ~= nil and buffaction.target or nil
			local ltd
			if chair ~= nil and chair:IsValid() then
				inst.Transform:SetRotation(chair.Transform:GetRotation())
				ltd = chair:HasTag("limited_chair")
				inst.sg.statemem.chair = chair
			end
			if ltd then
				inst.Transform:SetPredictedNoFaced()
				inst.AnimState:PlayAnimation("sit_pre_nofaced")
				inst.AnimState:PushAnimation("sit_lag_nofaced", false)
			else
				inst.AnimState:PlayAnimation("sit_pre")
				inst.AnimState:PushAnimation("sit_lag", false)
			end
			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("sitting", inst.sg.statemem.chair)
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("sit_off_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		events =
		{
			EventHandler("sg_cancelmovementprediction", function(inst)
				if inst.sg:ServerStateMatches() then
					inst.sg:GoToState("sitting", inst.sg.statemem.chair)
					return true
				end
			end),
		},

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("sit_off_pst")
			inst.sg:GoToState("idle", true)
		end,

		onexit = function(inst)
			inst.Transform:ClearPredictedFacingModel()
		end,
	},

	State{
		name = "sitting",
		tags = { "overridelocomote", "canrotate" },
		server_states = { "start_sitting", "sit_jumpon", "sitting" }, --for sg_cancelmovementprediction

		onenter = function(inst, chair)
			inst.entity:SetIsPredictingMovement(false)
			inst.sg:SetTimeout(TIMEOUT)
			inst.sg.statemem.chair = chair --can be nil, coming from "init"
			inst.sg.statemem.rot = inst.Transform:GetRotation()
		end,

		onupdate = function(inst)
			if inst.bufferedaction == nil and not inst:HasTag("sitting_on_chair") then
				inst.sg.statemem.not_interrupted = true
				inst.sg:GoToState("idle", "noanim")
			end
		end,

		ontimeout = function(inst)
			if inst.bufferedaction ~= nil and inst.bufferedaction.ispreviewing then
				inst:ClearBufferedAction()
				inst.sg.statemem.not_interrupted = true
				inst.sg:GoToState("idle")
			end
		end,

		events =
		{
			EventHandler("sg_cancelmovementprediction", function(inst)
				if inst.sg:ServerStateMatches() then
					return true
				end
				inst.sg.statemem.not_interrupted = true
			end),
			EventHandler("locomote", function(inst)
				if inst.components.locomotor:WantsToMoveForward() then
					inst.sg.statemem.not_interrupted = true
					inst.sg:GoToState("stop_sitting", inst.sg.statemem.rot)
				end
				return true
			end),
		},

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
			if not inst.sg.statemem.not_interrupted then
				--V2C: -Assume we got here by predicting an instant action that pops
				--      you off the chair.
				--     -SetBank on clients is BAD!!!! But....
				--     -This one is to remove flicker without refactoring how all
				--      non-sitting actions work from sitting.
				--     -The drawback is that if that action fails, then the
				--      player becomes invisible (we've popped off the chair to
				--      predict the animation while server still has us sitting).
				--     -In that case, it "should" recover if the client moves around
				--      enough to force themselves off the chair on the server as well.
				inst.AnimState:SetBank("wilson")
				local chair = inst.sg.statemem.chair
				local radius = inst:GetPhysicsRadius(0) + (chair and chair:IsValid() and chair:GetPhysicsRadius(0) or 0.25)
				if radius > 0 then
					local x, y, z = inst.Transform:GetWorldPosition()
					local x1, y1, z1 = chair.Transform:GetWorldPosition()
					if x == x1 and z == z1 then
						local rot = inst.Transform:GetRotation() * DEGREES
						x = x1 + radius * math.cos(rot)
						z = z1 - radius * math.sin(rot)
						if TheWorld.Map:IsPassableAtPoint(x, 0, z, true) then
							inst.Physics:Teleport(x, 0, z)
						end
					end
				end
			end
		end,
	},

	State{
		name = "stop_sitting",
		tags = { "busy" },
		server_states = { "stop_sitting", "sit_jumpoff" },

		onenter = function(inst, rot)
			inst.components.playercontroller:RemotePredictOverrideLocomote()
			if rot ~= nil then
				inst.Transform:SetRotation(rot)
			end
			local buffaction = inst:GetBufferedAction()
			if buffaction == nil or buffaction.action == ACTIONS.WALKTO then
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
				inst:ClearBufferedAction()
			end
			inst.AnimState:PlayAnimation("sit_off")
			inst.AnimState:PushAnimation("sit_off_lag", false)
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("sit_jumpoff")
				end
			end
		end,

		ontimeout = function(inst)
			inst.components.locomotor:Clear()
			if inst:HasTag("sitting_on_chair") then
				inst.AnimState:PlayAnimation("sit"..tostring(math.random(2)).."_loop", true)
				inst.sg:GoToState("sitting")
			else
				inst.AnimState:PlayAnimation("sit_off_pst")
				inst.sg:GoToState("idle", true)
			end
		end,
	},

	State{
		name = "sit_jumpoff",
		tags = { "busy" },
		server_states = { "stop_sitting", "sit_jumpoff" },

		onenter = function(inst)
			inst.entity:SetIsPredictingMovement(false)
			inst.components.locomotor:StopMoving()
		end,

		onupdate = function(inst)
			if not inst.sg:ServerStateMatches() then
				inst.sg:GoToState(inst:HasTag("idle") and "stop_sitting_pst" or "idle")
			end
		end,

		events =
		{
			EventHandler("sg_cancelmovementprediction", function(inst)
				if inst.sg:ServerStateMatches() then
					return true
				elseif inst:HasTag("idle") then
					inst.sg:GoToState("stop_sitting_pst")
					return true
				end
			end),
		},

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
		end,
	},

	State{
		name = "stop_sitting_pst",
		tags = { "idle", "overridelocomote" },
		server_states = { "stop_sitting_pst" },

		onenter = function(inst)
			if not inst.AnimState:IsCurrentAnimation("sit_off_pst") or inst.AnimState:GetCurrentAnimationFrame() >= 3 then
				inst.sg:GoToState("idle")
				return
			end
			inst.entity:SetIsPredictingMovement(false)
			inst.components.locomotor:StopMoving()
		end,

		onupdate = function(inst)
			if not inst.AnimState:IsCurrentAnimation("sit_off_pst") or inst.AnimState:GetCurrentAnimationFrame() >= 3 then
				inst.sg:GoToState("idle")
			end
		end,

		events =
		{
			EventHandler("locomote", function(inst)
				return true
			end),
		},

		onexit = function(inst)
			inst.entity:SetIsPredictingMovement(true)
		end,
	},

	--------------------------------------------------------------------------

	State{
		name = "start_pocket_rummage",
		tags = { "doing", "busy" },
		server_states = { "start_pocket_rummage" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make_preview")
			inst.AnimState:PlayAnimation("build_pre")
			inst.AnimState:PushAnimation("build_loop")

			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("build_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("build_pst")
			inst.sg:GoToState("idle", true)
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("make_preview")
		end,
	},

	State{
		name = "stop_pocket_rummage",
		tags = { "doing" },
		server_states = { "stop_pocket_rummage" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("build_pst")
			inst.AnimState:PushAnimation("idle_loop")
			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("build_pre")
				inst.AnimState:PushAnimation("build_loop")
				inst.sg:GoToState("idle", "noanim")
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("build_pre")
			inst.AnimState:PushAnimation("build_loop")
			inst.sg:GoToState("idle", "noanim")
		end,
	},

	State{
		name = "remote_teleport_pre",
		tags = { "busy" },
		server_states = { "remote_teleport_pre", "remote_teleport_out" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("remote_teleport_pre")
			inst.AnimState:PushAnimation("remote_teleport_lag", false)
			inst:PerformPreviewBufferedAction()
			inst.sg:SetTimeout(TIMEOUT)
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.sg:GoToState("idle")
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.sg:GoToState("idle")
		end,
	},

	State{
		name = "closeinspect",
		tags = { "idle", "canrotate" },
		server_states = { "run_stop", "closeinspect" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:PerformPreviewBufferedAction()

			local rider = inst.replica.rider
			if rider and rider:IsRiding() or inst.replica.inventory:IsHeavyLifting() or IsChannelCasting(inst) then
				if inst.sg.lasttags and inst.sg.lasttags["moving"] then
					ConfigureRunState(inst)
					inst.AnimState:PlayAnimation(GetRunStateAnim(inst).."_pst")
					inst.sg:GoToState("idle", true)
				else
					inst.sg:GoToState("idle")
				end
				return
			end

			inst.AnimState:PlayAnimation("closeinspect_pre")
			inst.AnimState:PushAnimation("closeinspect_loop")
			inst.sg:SetTimeout(TIMEOUT)

			inst.sg.statemem.run_stop_hash = hash("run_stop")
		end,

		onupdate = function(inst)
			if inst.sg:ServerStateMatches() then
				if inst.entity:FlattenMovementPrediction() then
					if inst.player_classified.currentstate:value() == inst.sg.statemem.run_stop_hash then
						return
					end
					inst.sg:GoToState("idle", "noanim")
				end
			elseif inst.bufferedaction == nil then
				inst.AnimState:PlayAnimation("closeinspect_pst")
				inst.sg:GoToState("idle", true)
			end
		end,

		ontimeout = function(inst)
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("closeinspect_pst")
			inst.sg:GoToState("idle", true)
		end,
	},
}

local hop_timelines =
{
    hop_pre =
    {
        TimeEvent(0, function(inst)
            inst.components.embarker.embark_speed = math.clamp(inst.components.locomotor:RunSpeed() * inst.components.locomotor:GetSpeedMultiplier() + TUNING.WILSON_EMBARK_SPEED_BOOST, TUNING.WILSON_EMBARK_SPEED_MIN, TUNING.WILSON_EMBARK_SPEED_MAX)
        end),
    },
}

local hop_anims =
{
    pre = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_pre" or "boat_jump_pre" end,
    loop = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_loop" or "boat_jump_loop" end,
    pst = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_pst" or "boat_jump_pst" end,
}

CommonStates.AddHopStates(states, true, hop_anims, hop_timelines, "turnoftides/common/together/boat/jump_on", nil, {start_embarking_pre_frame = 4*FRAMES})
CommonStates.AddRowStates(states, true)

return StateGraph("wilson_client", states, events, "init", actionhandlers)
