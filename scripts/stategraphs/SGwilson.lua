require("stategraphs/commonstates")
local PlayerCommonExtensions = require("prefabs/player_common_extensions")

local ATTACK_PROP_MUST_TAGS = { "_combat" }
local ATTACK_PROP_CANT_TAGS = { "flying", "shadow", "ghost", "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }

local MOOSE_AOE_MUST_TAGS = { "_combat" }
local MOOSE_AOE_CANT_TAGS = { "INLIMBO", "wall", "companion", "flight", "invisible", "notarget", "noattack" }

local FLOWERS_MUST_TAGS = {"flower"}
local FLOWERS_CANT_TAGS = {"INLIMBO"}

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
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
    local saddle = inst.components.rider:GetSaddle()
    if saddle ~= nil and saddle.mounted_foleysound ~= nil then
        inst.SoundEmitter:PlaySound(saddle.mounted_foleysound, nil, nil, true)
    end
end

local DoRunSounds = function(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

if TheNet:GetServerGameMode() == "lavaarena" or TheNet:GetServerGameMode() == "quagmire" then
    DoRunSounds = event_server_data("common", "stategraphs/SGwilson").OverrideRunSounds(DoRunSounds)
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

local function DoGooseStepFX(inst)
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
        SpawnPrefab("weregoose_splash_med"..tostring(math.random(2))).entity:SetParent(inst.entity)
    end
end

local function DoGooseWalkFX(inst)
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
        SpawnPrefab("weregoose_splash_less"..tostring(math.random(2))).entity:SetParent(inst.entity)
    end
end

local function DoGooseRunFX(inst)
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
        SpawnPrefab("weregoose_splash").entity:SetParent(inst.entity)
    else
        SpawnPrefab("weregoose_feathers"..tostring(math.random(3))).entity:SetParent(inst.entity)
    end
end

local function DoHurtSound(inst)
    if inst.hurtsoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.hurtsoundoverride, nil, inst.hurtsoundvolume)
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/hurt", nil, inst.hurtsoundvolume)
    end
end

local function DoYawnSound(inst)
    if inst.yawnsoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.yawnsoundoverride)
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/yawn")
    end
end

local function DoTalkSound(inst)
    if inst.talksoundoverride ~= nil then
        inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
        return true
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/talk_LP", "talk")
        return true
    end
end

local function StopTalkSound(inst, instant)
    if not instant and inst.endtalksound ~= nil and inst.SoundEmitter:PlayingSound("talk") then
        inst.SoundEmitter:PlaySound(inst.endtalksound)
    end
    inst.SoundEmitter:KillSound("talk")
end

local function CancelTalk_Override(inst, instant)
	if inst.sg.statemem.talktask ~= nil then
		inst.sg.statemem.talktask:Cancel()
		inst.sg.statemem.talktask = nil
		StopTalkSound(inst, instant)
	end
end

local function OnTalk_Override(inst)
	CancelTalk_Override(inst, true)
	if DoTalkSound(inst) then
		inst.sg.statemem.talktask = inst:DoTaskInTime(1.5 + math.random() * .5, CancelTalk_Override)
	end
	return true
end

local function OnDoneTalking_Override(inst)
	CancelTalk_Override(inst)
	return true
end

local function DoMountSound(inst, mount, sound, ispredicted)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, ispredicted)
    end
end

--[[
local DANGER_ONEOF_TAGS = { "monster", "pig", "_combat" }
local DANGER_NOPIG_ONEOF_TAGS = { "monster", "_combat" }
local function IsNearDanger(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = inst.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    -- See entityreplica.lua (for _combat tag usage)
    local nospiderdanger = inst:HasTag("spiderwhisperer") or inst:HasTag("spiderdisguise")
    local nopigdanger = not inst:HasTag("monster")
    --Danger if:
    -- being targetted
    -- OR near monster that is not player
    -- ignore shadow monsters when not insane
    return FindEntity(inst, 10,
        function(target)
            return (target.components.combat ~= nil and target.components.combat.target == inst)
                or ((target:HasTag("monster") or (not nopigdanger and target:HasTag("pig"))) and
                    not target:HasTag("player") and
                    not (nospiderdanger and target:HasTag("spider")) and
                    not (inst.components.sanity:IsSane() and target:HasTag("shadowcreature")))
        end,
        nil, nil, nopigdanger and DANGER_NOPIG_ONEOF_TAGS or DANGER_ONEOF_TAGS) ~= nil
end
]]

--V2C: This is for cleaning up interrupted states with legacy stuff, like
--     freeze and pinnable, that aren't consistently controlled by either
--     the stategraph or the component.
local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

local function SetSleeperSleepState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:AddImmunity("sleeping")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:IgnoreAll("sleeping")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Disable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(false)
        inst.components.playercontroller:Enable(false)
    end
    inst:OnSleepIn()
    inst.components.inventory:Hide()
    inst:PushEvent("ms_closepopups")
    inst:ShowActions(false)
end

local function SetSleeperAwakeState(inst)
    if inst.components.grue ~= nil then
        inst.components.grue:RemoveImmunity("sleeping")
    end
    if inst.components.talker ~= nil then
        inst.components.talker:StopIgnoringAll("sleeping")
    end
    if inst.components.firebug ~= nil then
        inst.components.firebug:Enable()
    end
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:EnableMapControls(true)
        inst.components.playercontroller:Enable(true)
    end
    inst:OnWakeUp()
    inst.components.inventory:Show()
    inst:ShowActions(true)
end


local function DoEmoteFX(inst, prefab)
    local fx = SpawnPrefab(prefab)
    if fx ~= nil then
        if inst.components.rider:IsRiding() then
            fx.Transform:SetSixFaced()
        end
        fx.entity:SetParent(inst.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(inst.GUID, "emotefx", 0, 0, 0)
    end
end

local function DoForcedEmoteSound(inst, soundpath)
    inst.SoundEmitter:PlaySound(soundpath)
end

local function DoEmoteSound(inst, soundoverride, loop)
    --NOTE: loop only applies to soundoverride
    loop = loop and soundoverride ~= nil and "emotesoundloop" or nil
    local soundname = soundoverride or "emote"
    local emotesoundoverride = soundname.."soundoverride"
    if inst[emotesoundoverride] ~= nil then
        inst.SoundEmitter:PlaySound(inst[emotesoundoverride], loop)
    elseif not inst:HasTag("mime") then
        inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/"..soundname, loop)
    end
end

local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function StartTeleporting(inst)
    inst.sg.statemem.isteleporting = true

    inst.components.health:SetInvincible(true)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(false)
    end
    inst:Hide()
    inst.DynamicShadow:Enable(false)
end

local function DoneTeleporting(inst)
    inst.sg.statemem.isteleporting = false

    inst.components.health:SetInvincible(false)
    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:Enable(true)
    end
    inst:Show()
    inst.DynamicShadow:Enable(true)
end

local function UpdateActionMeter(inst)
	inst.player_classified.actionmeter:set_local(math.min(255, math.floor(inst.sg.timeinstate * 10 + 2.5)))
end

local function StartActionMeter(inst, duration)
    if inst.HUD ~= nil then
        inst.HUD:ShowRingMeter(inst:GetPosition(), duration)
    end
    inst.player_classified.actionmetertime:set(math.min(255, math.floor(duration * 10 + .5)))
    inst.player_classified.actionmeter:set(2)
    if inst.sg.mem.actionmetertask == nil then
		inst.sg.mem.actionmetertask = inst:DoPeriodicTask(.1, UpdateActionMeter)
    end
end

local function StopActionMeter(inst, flash)
    if inst.HUD ~= nil then
        inst.HUD:HideRingMeter(flash)
    end
    if inst.sg.mem.actionmetertask ~= nil then
        inst.sg.mem.actionmetertask:Cancel()
        inst.sg.mem.actionmetertask = nil
        inst.player_classified.actionmeter:set(flash and 1 or 0)
    end
end

local function GetUnequipState(inst, data)
    return (inst:HasTag("wereplayer") and "item_in")
        or (data.eslot ~= EQUIPSLOTS.HANDS and "item_hat")
        or (not data.slip and "item_in")
        or (data.item ~= nil and data.item:IsValid() and "tool_slip")
        or "toolbroke"
        , data.item
end

local function ConfigureRunState(inst)
    if inst.components.rider:IsRiding() then
        inst.sg.statemem.riding = true
        inst.sg.statemem.groggy = inst:HasTag("groggy")
        inst.sg:AddStateTag("nodangle")
		inst.sg:AddStateTag("noslip")

        local mount = inst.components.rider:GetMount()
        inst.sg.statemem.ridingwoby = mount and mount:HasTag("woby")

    elseif inst.components.inventory:IsHeavyLifting() then
        inst.sg.statemem.heavy = true
		inst.sg.statemem.heavy_fast = inst.components.mightiness ~= nil and inst.components.mightiness:IsMighty()
		inst.sg:AddStateTag("noslip")
	elseif inst:IsChannelCasting() then
		inst.sg.statemem.channelcast = true
		inst.sg.statemem.channelcastitem = inst:IsChannelCastingItem()
    elseif inst:HasTag("wereplayer") then
        inst.sg.statemem.iswere = true
		inst.sg:AddStateTag("noslip")

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
		inst.sg:AddStateTag("noslip")
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

local function OnRemoveCleanupTargetFX(inst)
    if inst.sg.statemem.targetfx.KillFX ~= nil then
        inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
        inst.sg.statemem.targetfx:KillFX()
    else
        inst.sg.statemem.targetfx:Remove()
    end
end

local function IsWeaponEquipped(inst, weapon)
    return weapon ~= nil
        and weapon.components.equippable ~= nil
        and weapon.components.equippable:IsEquipped()
        and weapon.components.inventoryitem ~= nil
        and weapon.components.inventoryitem:IsHeldBy(inst)
end

local function ValidateMultiThruster(inst)
    return IsWeaponEquipped(inst, inst.sg.statemem.weapon) and inst.sg.statemem.weapon.components.multithruster ~= nil
end

local function ValidateHelmSplitter(inst)
    return IsWeaponEquipped(inst, inst.sg.statemem.weapon) and inst.sg.statemem.weapon.components.helmsplitter ~= nil
end

local function DoThrust(inst, nosound)
    if ValidateMultiThruster(inst) then
        inst.sg.statemem.weapon.components.multithruster:DoThrust(inst, inst.sg.statemem.target)
        if not nosound then
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end
    end
end

local function DoHelmSplit(inst)
    if ValidateHelmSplitter(inst) then
        inst.sg.statemem.weapon.components.helmsplitter:DoHelmSplit(inst, inst.sg.statemem.target)
    end
end

local function IsMinigameItem(inst)
    return inst:HasTag("minigameitem")
end

local function DoWortoxPortalTint(inst, val)
    if val > 0 then
        inst.components.colouradder:PushColour("portaltint", 154 / 255 * val, 23 / 255 * val, 19 / 255 * val, 0)
        val = 1 - val
        inst.AnimState:SetMultColour(val, val, val, 1)
    else
        inst.components.colouradder:PopColour("portaltint")
        inst.AnimState:SetMultColour(1, 1, 1, 1)
    end
end

local function DoMimeAnimations(inst)
    inst.AnimState:PlayAnimation("mime"..tostring(math.random(13)))
    for k = 1, math.random(2) do
        inst.AnimState:PushAnimation("mime"..tostring(math.random(13)), false)
    end
end

local function SetPocketRummageMem(inst, item)
	inst.sg.mem.pocket_rummage_item = item
end

local function ClosePocketRummageMem(inst, item)
	if item == nil then
		item = inst.sg.mem.pocket_rummage_item
	elseif item ~= inst.sg.mem.pocket_rummage_item then
		return
	end
	if item then
		inst.sg.mem.pocket_rummage_item = nil

		if item.components.inventoryitem and
			item.components.inventoryitem:GetGrandOwner() == inst and
			item.components.container
		then
			item.components.container:Close(inst)
		end
	end
end

--Call this when exiting a "keep_pocket_rummage" state
local function CheckPocketRummageMem(inst)
	local item = inst.sg.mem.pocket_rummage_item
	if item then
		if not (item.components.container and
				item.components.container:IsOpenedBy(inst) and
				item.components.inventoryitem and
				item.components.inventoryitem:GetGrandOwner() == inst)
		then
			SetPocketRummageMem(inst, nil)
		else
			local stayopen = inst.sg.statemem.keep_pocket_rummage_mem_onexit
			if not stayopen and inst.sg.statemem.is_going_to_action_state then
				local buffaction = inst:GetBufferedAction()
				if buffaction and
					(	buffaction.action == ACTIONS.BUILD or
						(	buffaction.invobject and
							buffaction.invobject.components.inventoryitem and
							buffaction.invobject.components.inventoryitem:IsHeldBy(item)
						)
					)
				then
					stayopen = true
				end
			end
			if not stayopen then
				ClosePocketRummageMem(inst)
			end
		end
	end
end

local function TryResumePocketRummage(inst)
	local item = inst.sg.mem.pocket_rummage_item
	if item then
		if item.components.container and
			item.components.container:IsOpenedBy(inst) and
			item.components.inventoryitem and
			item.components.inventoryitem:GetGrandOwner() == inst
		then
			inst.sg.statemem.keep_pocket_rummage_mem_onexit = true
			inst.sg:GoToState("start_pocket_rummage", item)
			return true
		end
		inst.sg.mem.pocket_rummage_item = nil
	end
	return false
end

local actionhandlers =
{
    ActionHandler(ACTIONS.CHOP,
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("prechop")
                and (inst.sg:HasStateTag("chopping") and
                    "chop" or
                    "chop_start")
                or nil
        end),
    ActionHandler(ACTIONS.MINE,
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("premine")
                and (inst.sg:HasStateTag("mining") and
                    "mine" or
                    "mine_start")
                or nil
        end),
    ActionHandler(ACTIONS.HAMMER,
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("prehammer")
                and (inst.sg:HasStateTag("hammering") and
                    "hammer" or
                    "hammer_start")
                or nil
        end),
    ActionHandler(ACTIONS.TERRAFORM, "terraform"),
    ActionHandler(ACTIONS.DIG,
        function(inst)
            if inst:HasTag("beaver") then
                return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
            end
            return not inst.sg:HasStateTag("predig")
                and (inst.sg:HasStateTag("digging") and
                    "dig" or
                    "dig_start")
                or nil
        end),
    ActionHandler(ACTIONS.NET,
        function(inst, action)
            if action.invobject == nil or not action.invobject:HasTag(ACTIONS.NET.id.."_tool") then
                return "doshortaction"
            end

            return not inst.sg:HasStateTag("prenet") and (inst.sg:HasStateTag("netting") and "bugnet" or "bugnet_start") or nil
        end),

    ActionHandler(ACTIONS.FISH, "fishing_pre"),
    ActionHandler(ACTIONS.FISH_OCEAN, "fishing_ocean_pre"),
    ActionHandler(ACTIONS.OCEAN_FISHING_POND, "fishing_ocean_pre"),
    ActionHandler(ACTIONS.OCEAN_FISHING_CAST, "oceanfishing_cast"),
    ActionHandler(ACTIONS.OCEAN_FISHING_REEL,
        function(inst, action)
            local fishable = action.invobject ~= nil and action.invobject.components.oceanfishingrod.target or nil
            if fishable ~= nil and fishable.components.oceanfishable ~= nil and fishable:HasTag("partiallyhooked") then
                return "oceanfishing_sethook"
            elseif inst:HasTag("fishing_idle") and not (inst.sg:HasStateTag("reeling") and not inst.sg.statemem.allow_repeat) then
                return "oceanfishing_reel"
            end
            return nil
        end),
    ActionHandler(ACTIONS.FERTILIZE,
        function(inst, action)
            return (((action.target ~= nil and action.target ~= inst) or action:GetActionPoint() ~= nil) and "doshortaction")
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
    ActionHandler(ACTIONS.ADDFUEL, "doshortaction"),
    ActionHandler(ACTIONS.ADDWETFUEL, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR, function(inst, action)
        return action.target:HasTag("repairshortaction") and "doshortaction" or "dolongaction"
    end),
    ActionHandler(ACTIONS.READ,
        function(inst, action)
            return (action.invobject ~= nil and action.invobject.components.simplebook ~= nil and "cookbook_open")
				or (inst.components.reader ~= nil and inst.components.reader:IsAspiringBookworm() and "book_peruse")
				or "book"
        end),
    ActionHandler(ACTIONS.MAKEBALLOON, "makeballoon"),
	ActionHandler(ACTIONS.DEPLOY, function(inst, action) return action.invobject and action.invobject.components.complexprojectile and "throw_deploy" or "doshortaction" end),
    ActionHandler(ACTIONS.DEPLOY_TILEARRIVE, "doshortaction"),
    ActionHandler(ACTIONS.STORE, "doshortaction"),
    ActionHandler(ACTIONS.DROP,
        function(inst)
            return inst.components.inventory:IsHeavyLifting()
                and not inst.components.rider:IsRiding()
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
            return action.target.components.activatable ~= nil
				and (	(	action.target:HasTag("engineering") and (
								(inst:HasTag("scientist") and "dolongaction") or
								(not inst:HasTag("handyperson") and "dolongestaction")
							)
						) or
						(action.target.components.activatable.standingaction and "dostandingaction") or
                        (action.target.components.activatable.quickaction and "doshortaction") or
                        "dolongaction"
                    )
                or nil
        end),
    ActionHandler(ACTIONS.OPEN_CRAFTING, "dostandingaction"),
    ActionHandler(ACTIONS.PICK,
        function(inst, action)
            return
				(action.target and action.target:HasTag("noquickpick") and "dolongaction") or
                (inst:HasTag("farmplantfastpicker") and action.target ~= nil and action.target:HasTag("farm_plant") and "domediumaction") or
				(inst.components.rider ~= nil and inst.components.rider:IsRiding() and (
					(inst:HasTag("woodiequickpicker") and "dowoodiefastpick") or
					"dolongaction"
				)) or
                (
                    action.target ~= nil and
                    (action.target.components.pickable ~= nil and
                    (
                        (action.target.components.pickable.jostlepick and "dojostleaction") or
                        (action.target.components.pickable.quickpick and "doshortaction") or
                        (inst:HasTag("fastpicker") and "doshortaction") or
						(inst:HasTag("woodiequickpicker") and "dowoodiefastpick") or
                        (inst:HasTag("quagmire_fasthands") and "domediumaction") or
                        "dolongaction"
                    )) or
                    (action.target.components.searchable ~= nil and
                    (
                        (action.target.components.searchable.jostlesearch and "dojostleaction") or
                        (action.target.components.searchable.quicksearch and "doshortaction") or
                        "dolongaction"
                    ))
                )
                or nil
        end),
    ActionHandler(ACTIONS.CARNIVALGAME_FEED,
        function(inst, action)
            return (inst.components.rider ~= nil and inst.components.rider:IsRiding() and "dolongaction")
				or "doequippedaction"
        end),
    ActionHandler(ACTIONS.SLEEPIN,
        function(inst, action)
            if action.invobject ~= nil then
                if action.invobject.onuse ~= nil then
                    action.invobject:onuse(inst)
                end
                return "bedroll"
            else
                return "tent"
            end
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
    ActionHandler(ACTIONS.SHAVE, "shave"),
    ActionHandler(ACTIONS.COOK,
        function(inst, action)
            return inst:HasTag("expertchef") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.FILL, "dolongaction"),
    ActionHandler(ACTIONS.FILL_OCEAN, "dolongaction"),
    ActionHandler(ACTIONS.PICKUP,
        function(inst, action)
			return (inst.components.rider ~= nil and inst.components.rider:IsRiding()
                    and (action.target ~= nil and action.target:HasTag("heavy") and "dodismountaction"
                        or "domediumaction")
                    )
				or (action.target ~= nil and action.target:HasTag("minigameitem") and "dosilentshortaction")
                or "doshortaction"
        end),
    ActionHandler(ACTIONS.CHECKTRAP,
        function(inst, action)
            return (inst.components.rider ~= nil and inst.components.rider:IsRiding() and "domediumaction")
                or "doshortaction"
        end),
	ActionHandler(ACTIONS.RUMMAGE,
		function(inst, action)
			return action.invobject
				and action.invobject:HasTag("portablestorage")
				and action.invobject.components.container
				and (	action.invobject.components.container:IsOpenedBy(inst) and
						"stop_pocket_rummage" or
						"start_pocket_rummage"
					)
				or "doshortaction"
		end),
    ActionHandler(ACTIONS.BAIT, "doshortaction"),
    ActionHandler(ACTIONS.HEAL, "dolongaction"),
    ActionHandler(ACTIONS.SEW, "dolongaction"),
    ActionHandler(ACTIONS.TEACH, "dolongaction"),
    ActionHandler(ACTIONS.RESETMINE, "dolongaction"),
    ActionHandler(ACTIONS.EAT,
        function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return
            end
            local obj = action.target or action.invobject
            if obj == nil then
                return
            elseif obj.components.edible ~= nil then
                if not inst.components.eater:PrefersToEat(obj) then
                    inst:PushEvent("wonteatfood", { food = obj })
                    return
                end
            elseif obj.components.soul ~= nil then
                if inst.components.souleater == nil then
                    inst:PushEvent("wonteatfood", { food = obj })
                    return
                end
            else
                return
            end
            return (obj.components.soul ~= nil and "eat")
                or (obj.components.edible.foodtype == FOODTYPE.MEAT and "eat")
                or "quickeat"
        end),
    ActionHandler(ACTIONS.GIVE,
        function(inst, action)
            return action.invobject ~= nil
                and action.target ~= nil
                and (   (action.target:HasTag("moonportal") and action.invobject:HasTag("moonportalkey") and "dochannelaction") or
                        (action.invobject.prefab == "quagmire_portal_key" and action.target:HasTag("quagmire_altar") and "quagmireportalkey") or
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
    ActionHandler(ACTIONS.FAN, "use_fan"),
    ActionHandler(ACTIONS.ERASE_PAPER, "dolongaction"),
    ActionHandler(ACTIONS.JUMPIN, "jumpin_pre"),
    ActionHandler(ACTIONS.JUMPIN_MAP, "jumpin_pre"),
    ActionHandler(ACTIONS.TELEPORT,
        function(inst, action)
            return action.invobject ~= nil and "dolongaction" or "give"
        end),
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
				and (	(action.invobject:HasTag("book") and (inst:HasTag("canrepeatcast") and "book_repeatcast" or "book")) or
						(action.invobject:HasTag("willow_ember") and (inst:HasTag("canrepeatcast") and "repeatcastspellmind" or "castspellmind")) or
						(action.invobject:HasTag("remotecontrol") and (inst:HasTag("canrepeatcast") and "remotecast_trigger" or "remotecast_pre")) or
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
            inst.sg.mem.localchainattack = not action.forced or nil
			local playercontroller = inst.components.playercontroller
			local attack_tag =
				playercontroller ~= nil and
				playercontroller.remote_authority and
				playercontroller.remote_predicting and
				"abouttoattack" or
				"attack"
			if not (inst.sg:HasStateTag(attack_tag) and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
                local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
                return (weapon == nil and "attack")
                    or (weapon:HasOneOfTags({"blowdart", "blowpipe"}) and "blowdart")
					or (weapon:HasTag("slingshot") and "slingshot_shoot")
                    or (weapon:HasTag("thrown") and "throw")
                    or (weapon:HasTag("pillow") and "attack_pillow_pre")
                    or (weapon:HasTag("propweapon") and "attack_prop_pre")
                    or (weapon:HasTag("multithruster") and "multithrust_pre")
                    or (weapon:HasTag("helmsplitter") and "helmsplitter_pre")
                    or "attack"
            end
        end),
	ActionHandler(ACTIONS.TOSS,
		function(inst, action)
			local projectile = action.invobject
			if projectile == nil then
				--for Special action TOSS, we can also use equipped item.
				projectile = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
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
                    projectile = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
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
    ActionHandler(ACTIONS.RAISE_SAIL, "dostandingaction" ),
    ActionHandler(ACTIONS.LOWER_SAIL_BOOST,
        function(inst, action)
            inst.sg.statemem.not_interrupted = true
            return "furl_boost"
        end),
    ActionHandler(ACTIONS.LOWER_SAIL_FAIL,
        function(inst, action)
            inst.sg.statemem.not_interrupted = true
            return "furl_fail"
        end),
    ActionHandler(ACTIONS.RAISE_ANCHOR, "raiseanchor"),
    ActionHandler(ACTIONS.LOWER_ANCHOR, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR_LEAK, "dolongaction"),
    ActionHandler(ACTIONS.STEER_BOAT, "steer_boat_idle_pre"),
    ActionHandler(ACTIONS.SET_HEADING, "steer_boat_turning"),
    ActionHandler(ACTIONS.ROTATE_BOAT_CLOCKWISE, "doshortaction"),
    ActionHandler(ACTIONS.ROTATE_BOAT_COUNTERCLOCKWISE, "doshortaction"),
    ActionHandler(ACTIONS.ROTATE_BOAT_STOP, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_ACTIVATE, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_DEACTIVATE, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_BEACON_TURN_ON, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_MAGNET_BEACON_TURN_OFF, "doshortaction"),
    ActionHandler(ACTIONS.ROW_FAIL, "row_fail"),
    ActionHandler(ACTIONS.ROW, "row"),
    ActionHandler(ACTIONS.ROW_CONTROLLER, "row"),
    ActionHandler(ACTIONS.EXTEND_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.RETRACT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.ABANDON_SHIP, "abandon_ship_pre"),
    ActionHandler(ACTIONS.MOUNT_PLANK, "mount_plank"),
    ActionHandler(ACTIONS.DISMOUNT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.CAST_NET, "cast_net"),
    ActionHandler(ACTIONS.BOAT_CANNON_LOAD_AMMO, "doshortaction"),
    ActionHandler(ACTIONS.BOAT_CANNON_START_AIMING, "aim_cannon_pre"),
    ActionHandler(ACTIONS.BOAT_CANNON_SHOOT,
        function(inst)
            inst.sg.statemem.aiming = true
            return "shoot_cannon"
        end),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_LOWER, "doshortaction"),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_RAISE, "doshortaction"),
    ActionHandler(ACTIONS.OCEAN_TRAWLER_FIX, "dolongaction"),

    ActionHandler(ACTIONS.UNWRAP,
        function(inst, action)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.BREAK, "dolongaction"),
    ActionHandler(ACTIONS.CONSTRUCT,
        function(inst, action)
            return (action.target == nil or action.target.components.constructionsite == nil) and "startconstruct" or "construct"
        end),
    ActionHandler(ACTIONS.STARTCHANNELING, function(inst,action)
        if action.target and action.target.components.channelable and action.target.components.channelable.use_channel_longaction then
                return "channel_longaction"
            else
                return "startchanneling"
            end
        end),
	ActionHandler(ACTIONS.START_CHANNELCAST, "start_channelcast"),
	ActionHandler(ACTIONS.STOP_CHANNELCAST, "stop_channelcast"),
    ActionHandler(ACTIONS.REVIVE_CORPSE, "revivecorpse"),
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

    ActionHandler(ACTIONS.WINTERSFEAST_FEAST,
        function(inst, action)
            if not inst.sg:HasStateTag("feasting") then
                TheWorld:PushEvent("feasterstarted",{player=inst,target=action.target})
            end
            return "winters_feast_eat"
        end),

    ActionHandler(ACTIONS.START_CARRAT_RACE, "give"),

    ActionHandler(ACTIONS.BEGIN_QUEST, "doshortaction"),
    ActionHandler(ACTIONS.ABANDON_QUEST, "dolongaction"),

	ActionHandler(ACTIONS.TELLSTORY, "dostorytelling"),
    ActionHandler(ACTIONS.PERFORM, function(inst, action)
            inst:PerformBufferedAction()
            return "acting_idle"
        end),

    ActionHandler(ACTIONS.POUR_WATER,
        function(inst, action)
            return action.invobject ~= nil
                and (action.invobject:HasTag("wateringcan") and "pour")
                or "dolongaction"
        end),
    ActionHandler(ACTIONS.POUR_WATER_GROUNDTILE,
        function(inst, action)
            return action.invobject ~= nil
                and (action.invobject:HasTag("wateringcan") and "pour")
                or "dolongaction"
        end),
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

    ActionHandler(ACTIONS.USEITEM, function(inst, action)        
        return "doaction"
    end),

    ActionHandler(ACTIONS.STOPUSINGITEM, "dolongaction"),
    ActionHandler(ACTIONS.YOTB_STARTCONTEST, "doshortaction"),
    ActionHandler(ACTIONS.YOTB_UNLOCKSKIN, "dolongaction"),
    ActionHandler(ACTIONS.YOTB_SEW, "dolongaction"),
    ActionHandler(ACTIONS.CARNIVAL_HOST_SUMMON, "give"),

    ActionHandler(ACTIONS.MUTATE_SPIDER, "give"),

    ActionHandler(ACTIONS.HERD_FOLLOWERS, "herd_followers"),
    ActionHandler(ACTIONS.BEDAZZLE, "dolongaction"),
    ActionHandler(ACTIONS.REPEL, "repel_followers"),
    ActionHandler(ACTIONS.UNLOAD_WINCH, "give"),
    ActionHandler(ACTIONS.USE_HEAVY_OBSTACLE, "dolongaction"),
    ActionHandler(ACTIONS.ADVANCE_TREE_GROWTH, "dolongaction"),

    ActionHandler(ACTIONS.HIDEANSEEK_FIND, "dolongaction"),
    ActionHandler(ACTIONS.RETURN_FOLLOWER, "dolongaction"),

    ActionHandler(ACTIONS.DISMANTLE_POCKETWATCH, "dolongaction"),

    ActionHandler(ACTIONS.UNLOAD_GYM, "doshortaction"),

    ActionHandler(ACTIONS.LIFT_DUMBBELL, function(inst, action)
        if inst.components.dumbbelllifter:IsLifting(action.invobject) then
            return "use_dumbbell_pst"
        else
            return "use_dumbbell_pre"
        end
    end),

    ActionHandler(ACTIONS.APPLYMODULE, "applyupgrademodule"),
    ActionHandler(ACTIONS.REMOVEMODULES, "removeupgrademodules"),
    ActionHandler(ACTIONS.CHARGE_FROM, "doshortaction"),

    ActionHandler(ACTIONS.ROTATE_FENCE, "doswipeaction"),

	ActionHandler(ACTIONS.USEMAGICTOOL, "start_using_tophat"),
	ActionHandler(ACTIONS.STOPUSINGMAGICTOOL, function(inst)
		inst.sg.statemem.stopusingmagiciantool = true
		return "stop_using_tophat"
	end),
	ActionHandler(ACTIONS.CAST_SPELLBOOK, "book"),
	ActionHandler(ACTIONS.SCYTHE, "scythe"),
	ActionHandler(ACTIONS.SITON, "start_sitting"),

	ActionHandler(ACTIONS.USE_WEREFORM_SKILL, function(inst)
		return (inst:HasTag("beaver") and "beaver_tailslap_pre")
			or (inst:HasTag("weregoose") and "weregoose_takeoff_pre")
			or nil
    end),

	ActionHandler(ACTIONS.REMOTE_TELEPORT, "remote_teleport_pre"),

    ActionHandler(ACTIONS.INCINERATE, "doshortaction"),
}

local events =
{
    EventHandler("locomote", function(inst, data)
		--V2C: - "overridelocomote" indidcates state has custom handler.
		--     - This check is not redundant, because events buffered from previous state
		--       won't use current state's handlers, and can still reach here unwantedly.
        if inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("overridelocomote") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        if inst:HasTag("ingym") then
            inst.sg.statemem.dontleavegym = true
            local gym = inst.components.strongman.gym
            if gym then
                gym.components.mightygym:CharacterExitGym(inst)
            end
        elseif inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or inst.sg:HasStateTag("waking") then -- wakeup on locomote
            if inst.sleepingbag ~= nil and inst.sg:HasStateTag("sleeping") then
                inst.sleepingbag.components.sleepingbag:DoWakeUp()
                inst.sleepingbag = nil
            end
        elseif is_moving and not should_move then
            if inst:HasTag("acting") then
                inst.sg:GoToState("acting_run_stop")
            else
                inst.sg:GoToState("run_stop")
            end
        elseif not is_moving and should_move then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				inst.components.locomotor:SetMoveDir(data.dir)
			end
            inst.sg:GoToState("run_start")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle") or inst:HasTag("is_furling")) then
			--V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
			if data and data.dir then
				inst.components.locomotor:SetMoveDir(data.dir)
			end
            inst.sg:GoToState("idle")
        end
    end),

    EventHandler("blocked", function(inst, data)
        if not inst.components.health:IsDead() and inst.sg:HasStateTag("shell") then
            inst.sg:GoToState("shell_hit")
        end
    end),

	EventHandler("coach", function(inst, data)
		if not inst.components.health:IsDead() then
			if inst.sg:HasStateTag("idle") then
				inst.sg:GoToState("coach")
			else
				inst.components.talker:Say(GetString(inst, "ANNOUNCE_COACH"))
			end
		end
	end),

    EventHandler("attacked", function(inst, data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") then
            if data.weapon ~= nil and data.weapon:HasTag("tranquilizer") and (inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("knockout")) then
                return --Do nothing
            elseif inst.sg:HasStateTag("transform") or inst.sg:HasStateTag("dismounting") then
                -- don't interrupt transform or when bucked in the air
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                DoHurtSound(inst)
            elseif inst.sg:HasStateTag("sleeping") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                DoHurtSound(inst)
                if inst.sleepingbag ~= nil then
                    inst.sleepingbag.components.sleepingbag:DoWakeUp()
                    inst.sleepingbag = nil
                else
                    inst.sg.statemem.iswaking = true
                    inst.sg:GoToState("wakeup")
                end
            elseif inst.sg:HasStateTag("parrying") and data.redirected then
                if not inst.sg:HasStateTag("parryhit") then
                    inst.sg.statemem.parrying = true
                    inst.sg:GoToState("parry_hit", {
                        timeleft = inst.sg.statemem.task ~= nil and GetTaskRemaining(inst.sg.statemem.task) or inst.sg.statemem.parrytime,
                        pushing = data.attacker ~= nil and data.attacker.sg ~= nil and data.attacker.sg:HasStateTag("pushing"),
                        isshield = inst.sg.statemem.isshield,
                    })
                end
			elseif inst.sg:HasStateTag("devoured") then
				return --Do nothing
            elseif data.attacker ~= nil
                and data.attacker:HasTag("groundspike")
                and not inst.components.rider:IsRiding()
                and not inst:HasTag("wereplayer") then
                inst.sg:GoToState("hit_spike", data.attacker)
            elseif data.attacker ~= nil
                and data.attacker.sg ~= nil
                and data.attacker.sg:HasStateTag("pushing") then
                inst.sg:GoToState("hit_push")
            elseif inst.sg:HasStateTag("shell") then
                inst.sg:GoToState("shell_hit")
            elseif inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("pinned_hit")
            elseif data.stimuli == "darkness" then
                inst.sg:GoToState("hit_darkness")
            elseif data.stimuli == "electric" and not inst.components.inventory:IsInsulated() then
                inst.sg:GoToState("electrocute")
            elseif inst.sg:HasStateTag("nointerrupt") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                DoHurtSound(inst)
            else
                local t = GetTime()
                local stunlock =
                    data.stimuli ~= "stun" and
                    data.attacker ~= nil and
                    --V2C: skip stunlock protection when idle
                    -- gjans: we transition to idle for 1 frame after being hit, hence the timeinstate check
                    not (inst.sg:HasStateTag("idle") and inst.sg.timeinstate > 0) and
                    data.attacker.components.combat ~= nil and
                    data.attacker.components.combat.playerstunlock or
                    nil
                if stunlock ~= nil and
                    t - (inst.sg.mem.laststuntime or 0) <
                    (   (stunlock == PLAYERSTUNLOCK.NEVER and math.huge) or
                        (stunlock == PLAYERSTUNLOCK.RARELY and TUNING.STUNLOCK_TIMES.RARELY) or
                        (stunlock == PLAYERSTUNLOCK.SOMETIMES and TUNING.STUNLOCK_TIMES.SOMETIMES) or
                        (stunlock == PLAYERSTUNLOCK.OFTEN and TUNING.STUNLOCK_TIMES.OFTEN) or
                        0 --unsupported case
                    ) then
                    -- don't go to full hit state, just play sounds
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                    DoHurtSound(inst)
                else
                    inst.sg.mem.laststuntime = t
                    inst.sg:GoToState("hit", data.noimpactsound and "noimpactsound" or nil)
                end
            end
        end
    end),

    EventHandler("snared", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("startle", true)
        end
    end),

    EventHandler("repelled", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("repelled", data)
        end
    end),

    EventHandler("knockback", function(inst, data)
		if not inst.components.health:IsDead() then
			if inst:HasTag("wereplayer") then
				inst.sg.mem.laststuntime = GetTime()
				if data ~= nil then
					data = shallowcopy(data)
					data.repeller = data.knocker
					inst.sg:GoToState("repelled", data)
				else
					inst.sg:GoToState("hit")
				end
			elseif inst.sg:HasStateTag("parrying") then
                inst.sg.statemem.parrying = true
                inst.sg:GoToState("parry_knockback", {
                    timeleft =
                        (inst.sg.statemem.task ~= nil and GetTaskRemaining(inst.sg.statemem.task)) or
                        (inst.sg.statemem.timeleft ~= nil and math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime())) or
                        inst.sg.statemem.parrytime,
                    knockbackdata = data,
                    isshield = inst.sg.statemem.isshield,
                })
            else
                inst.sg:GoToState((data.forcelanded or inst.components.inventory:EquipHasTag("heavyarmor") or inst:HasTag("heavybody")) and "knockbacklanded" or "knockback", data)
            end
        end
    end),

    EventHandler("souloverload",
        function(inst)
            if not (inst.components.health:IsDead() or inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("drowning")) then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_SOUL_OVERLOAD"))
                if inst.sg:HasStateTag("jumping") then
                    inst.sg.statemem.queued_post_land_state = "hit_souloverload"
                else
                    inst.sg:GoToState("hit_souloverload")
                end
            end
        end),

    EventHandler("mindcontrolled", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("mindcontrolled")
        end
    end),

	EventHandler("devoured", function(inst, data)
		if not inst.components.health:IsDead() and data ~= nil and data.attacker ~= nil and data.attacker:IsValid() then
			inst.sg:GoToState("devoured", data.attacker)
		end
	end),

	EventHandler("feetslipped", function(inst)
		if inst.sg:HasStateTag("running") and not inst.sg:HasStateTag("noslip") then
			inst.sg:GoToState("slip")
		end
	end),

    EventHandler("set_heading",
        function(inst)
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead() or inst.sg:HasStateTag("is_turning_wheel")) then
                inst.sg.statemem.steering = true
                inst.sg:GoToState("steer_boat_turning", true)
            end
        end),

    --For crafting, attunement cost, etc... Just go directly to hit.
    EventHandler("consumehealthcost", function(inst, data)
        if not (inst.sg:HasStateTag("nocraftinginterrupt") or inst.components.health:IsDead()) then
            inst.sg:GoToState("hit")
        end
    end),

    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if data.eslot == EQUIPSLOTS.BEARD then
            return nil
        elseif data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
			if inst.components.rider:IsRiding() then
				--V2C: See "dodismountaction"
				inst.sg.statemem.keepmount = true
				inst.sg:GoToState("heavylifting_mount_start")
			else
				inst.sg:GoToState("heavylifting_start")
			end
		elseif inst.components.inventory:IsHeavyLifting()
            and not inst.components.rider:IsRiding() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif (inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling")) and not inst:HasTag("wereplayer") then
            inst.sg:GoToState(
                (data.item ~= nil and data.item.projectileowner ~= nil and "catch_equip") or
                (data.eslot == EQUIPSLOTS.HANDS and "item_out") or
                "item_hat"
            )
        elseif data.item ~= nil and data.item.projectileowner ~= nil then
            SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
        end

    end),

    EventHandler("unequip", function(inst, data)
        if inst.sg:HasStateTag("acting") then
            return
        end
        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("heavylifting_stop")
            end
        elseif inst.components.inventory:IsHeavyLifting()
            and not inst.components.rider:IsRiding() then
            if inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("moving") then
                inst.sg:GoToState("heavylifting_item_hat")
            end
        elseif inst.sg:HasStateTag("idle") or inst.sg:HasStateTag("channeling") then
            inst.sg:GoToState(GetUnequipState(inst, data))
        end
    end),

    EventHandler("death", function(inst, data)
        if inst.sleepingbag ~= nil and (inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent")) then -- wakeup on death to "consume" sleeping bag first
            inst.sleepingbag.components.sleepingbag:DoWakeUp()
            inst.sleepingbag = nil
        end

        if data ~= nil and data.cause == "file_load" and inst.components.revivablecorpse ~= nil then
            inst.sg:GoToState("corpse", true)
        elseif not inst.sg:HasStateTag("dead") then
            inst.sg:GoToState("death")
        end
    end),

    EventHandler("ontalk", function(inst, data)
        if inst:IsActing() and not inst.sg:HasStateTag("talking") and (inst.components.rider == nil or not inst.components.rider:IsRiding()) then
            if inst:HasTag("mime") then
                inst.sg:GoToState("acting_mime")
            else
                inst.sg:GoToState("acting_talk")
            end
        elseif inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
			if data.sgparam and data.sgparam.closeinspect and
				not (	inst.components.rider:IsRiding() or
						inst.components.inventory:IsHeavyLifting() or
						inst:IsChannelCasting()
					)
			then
				inst.sg:GoToState("closeinspect")
			elseif not inst:HasTag("mime") then
				inst.sg:GoToState("talk", data.noanim)
			elseif not inst.components.inventory:IsHeavyLifting() then
				--Don't do it even if mounted!
				inst.sg:GoToState("mime")
			end
		elseif data.duration ~= nil and not data.noanim then
			inst.sg.mem.queuetalk_timeout = data.duration + GetTime()
		end
    end),

	EventHandler("silentcloseinspect", function(inst)
		if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") and
			not (	inst.components.rider:IsRiding() or
					inst.components.inventory:IsHeavyLifting() or
					inst:IsChannelCasting()
				)
		then
			inst.sg:GoToState("closeinspect", true)
		end
	end),

    EventHandler("powerup_wurt",
        function(inst)
            if not inst.sg:HasStateTag("dead") then
                inst.sg:GoToState("powerup_wurt")
            end
        end),

    EventHandler("powerdown_wurt",
        function(inst)
            if not inst.sg:HasStateTag("dead") then
                inst.sg:GoToState("powerdown_wurt")
            end
        end),

    EventHandler("powerup",
        function(inst)
            if not inst.sg:HasStateTag("dead") then
                if inst.sg:HasStateTag("lifting_dumbbell") then
                    inst.sg.mem.lifting_dumbbell = true
                    inst.components.dumbbelllifter:StopLifting()
                end

                inst.sg:GoToState("powerup")
            end
        end),

    EventHandler("powerdown",
        function(inst)
            if not inst.sg:HasStateTag("dead") then
                inst.sg:GoToState("powerdown")
            end
        end),

    EventHandler("becomeyounger_wanda",
        function(inst)
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("becomeyounger_wanda")
            end
        end),

    EventHandler("becomeolder_wanda",
        function(inst)
            if inst.sg:HasStateTag("idle") then
                inst.sg:GoToState("becomeolder_wanda")
            end
        end),

    EventHandler("onsink", function(inst, data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") and
                (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
            if data ~= nil and data.boat ~= nil then
                inst.sg:GoToState("sink", data.shore_pt)
            else
                inst.sg:GoToState("sink_fast")
            end
        end
    end),

    EventHandler("transform_wereplayer",
        function(inst, data)
            if not (inst.sg:HasStateTag("transform") or inst:HasTag("wereplayer")) and inst.components.wereness:GetPercent() > 0 then
                inst.sg:GoToState("transform_wereplayer", data)
            end
        end),

    EventHandler("transform_person",
        function(inst, data)
            if not inst.sg:HasStateTag("transform") and inst:HasTag("wereplayer") then
                inst.sg:GoToState("transform_"..data.mode.."_person", data.cb)
            end
        end),

    EventHandler("toolbroke",
        function(inst, data)
			if not inst.sg:HasStateTag("nointerrupt") then
				inst.sg:GoToState("toolbroke", data.tool)
			end
        end),

    EventHandler("armorbroke",
        function(inst)
			if not inst.sg:HasStateTag("nointerrupt") then
				inst.sg:GoToState("armorbroke")
			end
        end),

    EventHandler("fishingcancel",
        function(inst)
            if inst.sg:HasStateTag("fishing") and not inst:HasTag("busy") then
                inst.sg:GoToState("fishing_pst")
            end
        end),
    EventHandler("knockedout",
        function(inst)
            if inst.sg:HasStateTag("knockout") then
                inst.sg.statemem.cometo = nil
            elseif not (inst.sg:HasStateTag("sleeping") or inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or inst.sg:HasStateTag("waking") or inst.sg:HasStateTag("drowning")) then
                if inst.sg:HasStateTag("jumping") then
                    inst.sg.statemem.queued_post_land_state = "knockout"
                else
                    inst.sg:GoToState("knockout")
                end
            end
        end),
    EventHandler("yawn",
        function(inst, data)
            --NOTE: yawns DO knock you out of shell/bush hat
            --      yawns do NOT affect:
            --       sleeping
            --       frozen
            --       pinned
            if not (inst.components.health:IsDead() or
                    inst.sg:HasStateTag("sleeping") or
                    (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen()) or
                    (inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck())) then
                inst.sg:GoToState("yawn", data)
            end
        end),
    EventHandler("emote",
        function(inst, data)
            if not (inst.sg:HasStateTag("busy") or
                    inst.sg:HasStateTag("nopredict") or
                    inst.sg:HasStateTag("sleeping"))
                and not inst.components.inventory:IsHeavyLifting()
                and (data.mounted or not inst.components.rider:IsRiding())
                and (not data.mountonly or inst.components.rider:IsRiding())
                and (data.beaver or not inst:HasTag("beaver"))
                and (data.moose or not inst:HasTag("weremoose"))
                and (data.goose or not inst:HasTag("weregoose"))
                and (not data.requires_validation or TheInventory:CheckClientOwnership(inst.userid, data.item_type)) then
                inst.sg:GoToState("emote", data)
            end
        end),
    EventHandler("pinned",
        function(inst, data)
            if inst.components.health ~= nil and not inst.components.health:IsDead() and inst.components.pinnable ~= nil then
                if inst.components.pinnable.canbepinned then
                    inst.sg:GoToState("pinned_pre", data)
                elseif inst.components.pinnable:IsStuck() then
                    --V2C: Since sg events are queued, it's possible we're no longer pinnable
                    inst.components.pinnable:Unstick()
                end
            end
        end),
    EventHandler("freeze",
        function(inst)
            if inst.components.health ~= nil and not inst.components.health:IsDead() then
                inst.sg:GoToState("frozen")
            end
        end),
    EventHandler("wonteatfood",
        function(inst)
            if inst.components.health ~= nil and not inst.components.health:IsDead() then
                inst.sg:GoToState("refuseeat")
            end
        end),
    EventHandler("ms_opengift",
        function(inst)
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("opengift")
            end
        end),
    EventHandler("dismount",
        function(inst)
            if not inst.sg:HasStateTag("dismounting") and inst.components.rider:IsRiding() then
                inst.sg:GoToState("dismount")
            end
        end),
    EventHandler("bucked",
        function(inst, data)
            if not inst.sg:HasStateTag("dismounting") and inst.components.rider:IsRiding() then
                inst.sg:GoToState(data.gentle and "falloff" or "bucked")
            end
        end),
    EventHandler("oceanfishing_stoppedfishing",
        function(inst, data)
            if inst.sg:HasStateTag("fishing") and (inst.components.health == nil or not inst.components.health:IsDead()) then
                if data ~= nil and data.reason ~= nil then
                    if data.reason == "linesnapped" or data.reason == "toofaraway" then
                        inst.sg:GoToState("oceanfishing_linesnapped", {escaped_str = "ANNOUNCE_OCEANFISHING_LINESNAP"})
                    else
                        inst.sg:GoToState("oceanfishing_stop", {escaped_str = data.reason == "linetooloose" and "ANNOUNCE_OCEANFISHING_LINETOOLOOSE"
                                                                            or data.reason == "badcast" and "ANNOUNCE_OCEANFISHING_BADCAST"
                                                                            or (data.reason ~= "reeledin") and "ANNOUNCE_OCEANFISHING_GOTAWAY"
                                                                            or nil})
                    end
                else
                    inst.sg:GoToState("oceanfishing_stop")
                end
            end
        end),
    EventHandler("spooked", --Hallowed nights
        function(inst)
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead() or inst.components.rider:IsRiding()) then
                inst.sg:GoToState("spooked")
            end
        end),
    EventHandler("feastinterrupted", --Winter's Feast
        function(inst)
            if inst.sg:HasStateTag("feasting") then
                inst.sg:GoToState("idle")
            end
        end),

    EventHandler("singsong", function(inst, data)
        if (inst.components.health == nil or not inst.components.health:IsDead()) and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState("singsong", data)
        end
    end),

    EventHandler("yotb_learnblueprint", function(inst, data)
        if (inst.components.health == nil or not inst.components.health:IsDead()) then
            inst.sg:GoToState("research", data)
        end
    end),

    EventHandler("hideandseek_start", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or
                inst.sg:HasStateTag("sleeping"))
            and not inst.components.inventory:IsHeavyLifting()
            and not inst.components.rider:IsRiding()
			and (inst.components.health == nil or not inst.components.health:IsDead())
            and (data.beaver or not inst:HasTag("beaver"))
            and (data.moose or not inst:HasTag("weremoose"))
            and (data.goose or not inst:HasTag("weregoose"))
			then

            inst.sg:GoToState("hideandseek_counting", (data and data.timeout) or nil)
        end
    end),

    EventHandler("perform_do_next_line", function(inst, data)
        if inst:HasTag("mime") then
            inst.sg:GoToState("acting_mime")
        else
            if data.anim then
                inst.sg:GoToState("acting_action", data)
            else
                inst.sg:GoToState("acting_talk")
            end
        end
    end),

    EventHandler("acting", function(inst, data)
        if not inst.components.health:IsDead() then
            if data.act == "bow" then
                inst.sg:GoToState("acting_bow")
            elseif data.act == "curtsy" then
                inst.sg:GoToState("acting_curtsy")
            end
        end
    end),

    EventHandler("startstageacting", function(inst, data)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("acting_idle")
        end
    end),

    EventHandler("monkeycursehit", function(inst, data)
        if data == nil or not data.uncurse then
            --receiving curse
            if not (inst.sg:HasStateTag("nointerrupt") or
                    inst.sg:HasStateTag("nomorph") or
                    inst.sg:HasStateTag("silentmorph") or
                    inst.components.health:IsDead()) then
                local t = GetTime()
                if t > (inst.sg.mem.lastcursehittime or -math.huge) + 1 then
                    inst.sg.mem.lastcursehittime = t
                    inst.sg:GoToState("hit")
                end
            end
        else
            --removing curse
            if not (inst.sg:HasStateTag("nointerrupt") or
                    inst.components.health:IsDead()) then
                local t = GetTime()
                if t > (inst.sg.mem.lastcursehittime or -math.huge) + 1 or inst:HasTag("wonkey") then
                    inst.sg.mem.lastcursehittime = t
                    inst.sg:GoToState("hit_spike", "med")
                end
            end
        end
    end),

    EventHandler("pillowfight_ended", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or
                    inst.sg:HasStateTag("nopredict") or
                    inst.sg:HasStateTag("sleeping"))
                and not inst.components.inventory:IsHeavyLifting() then
            if data and data.won then
                inst.sg:GoToState("emote", { anim = "emoteXL_happycheer", mounted = true, mountsound = "yell" })
            else
                inst.sg:GoToState("emote", { anim = "emoteXL_angry", mounted = true, mountsound = "angry", mountsounddelay = 7 * FRAMES })
            end
        end
    end),

	EventHandler("ms_closeportablestorage", function(inst, data)
		if data and data.item then
			ClosePocketRummageMem(inst, data.item)
		end
	end),

    CommonHandlers.OnHop(),
}

local statue_symbols =
{
    "ww_head",
    "ww_limb",
    "ww_meathand",
    "ww_shadow",
    "ww_torso",
    "frame",
    "rope_joints",
    "swap_grown"
}

local weremoose_symbols =
{
    "weremoose_antlers01",
    "weremoose_arm_lower",
    "weremoose_arm_upper",
    "weremoose_arm_upper_skin",
    "weremoose_eyes",
    "weremoose_face",
    "weremoose_foot",
    "weremoose_hairpigtails",
    "weremoose_hand",
    "weremoose_headbase",
    "weremoose_leg",
    "weremoose_mouth",
    "weremoose_torso",
    "weremoose_torso_pelvis",
}

local states =
{
    State{
        name = "wakeup",
        tags = { "busy", "waking", "nomorph", "nodangle" },

        onenter = function(inst, data)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            if inst.AnimState:IsCurrentAnimation("bedroll") or
                inst.AnimState:IsCurrentAnimation("bedroll_sleep_loop") then
                inst.AnimState:PlayAnimation("bedroll_wakeup")
            elseif not (inst.AnimState:IsCurrentAnimation("bedroll_wakeup") or
                        inst.AnimState:IsCurrentAnimation("wakeup")) then
                inst.AnimState:PlayAnimation("wakeup")
            end
            if not inst:IsHUDVisible() then
                --Touch stone rez
                inst.sg.statemem.isresurrection = true
                inst.sg:AddStateTag("nopredict")
                inst.sg:AddStateTag("silentmorph")
                inst.sg:RemoveStateTag("nomorph")
                inst.components.health:SetInvincible(false)
                inst:ShowHUD(false)
                inst:SetCameraDistance(12)
            end

			if data ~= nil and data.goodsleep then
                inst.sg.statemem.goodsleep=true
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            SetSleeperAwakeState(inst)
            if inst.sg.statemem.isresurrection then
                --Touch stone rez
                inst:ShowHUD(true)
                inst:SetCameraDistance()
                SerializeUserSession(inst)
            end
            if inst.sg.statemem.goodsleep then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_COZY_SLEEP"))
            end
        end,
    },


    State{
        name = "powerup_wurt",
        tags = { "busy", "pausepredict", "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerup")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(29 * FRAMES, function(inst)
                inst.components.skinner:SetSkinMode("powerup", "wurt_stage2")
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
        name = "powerdown_wurt",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerdown")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(29 * FRAMES, function(inst)
                inst.components.skinner:SetSkinMode("normal_skin", "wurt")
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
        name = "powerup",
        tags = { "busy", "pausepredict", "nomorph", "powerup" },

        onenter = function(inst)
            local x,y,z = inst.Transform:GetWorldPosition()
            local fx = SpawnPrefab("wolfgang_mighty_fx").Transform:SetPosition(x,y,z)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerup")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(29 * FRAMES, function(inst)
                --Lava Arena adds nointerrupt state tag to prevent hit interruption
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then

                    if inst.sg.mem.lifting_dumbbell then
                        inst.sg.mem.lifting_dumbbell = nil

                        local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                        if equippedTool and equippedTool.components.mightydumbbell then
                            inst.components.dumbbelllifter:StartLifting(equippedTool)
                            inst.sg:GoToState("use_dumbbell_pre")
                            return
                        end
                    end
                    inst.sg:GoToState("idle")

                    -- if inst.components.mightiness and not using_dumbbell then
                    --     inst.components.mightiness:Resume()
                    -- end
                end
            end),
        },

        onexit = function(inst)
            -- If the lifting_dumbbell is not nil at this point we got interrupted
            if inst.sg.mem.lifting_dumbbell then
                inst.sg.mem.lifting_dumbbell = nil
            end
        end,
    },

    State{
        name = "powerdown",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerdown")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(29 * FRAMES, function(inst)
                --Lava Arena adds nointerrupt state tag to prevent hit interruption
                inst.sg:RemoveStateTag("nointerrupt")
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

    --------------------------------------------------------------------------

    State{
        name = "becomeyounger_wanda",
        tags = { "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("wanda_young")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/younger_transition") end),
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
        name = "becomeolder_wanda",
        tags = { "nomorph", "nodangle" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("wanda_old")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/older_transition") end),
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

    --------------------------------------------------------------------------
    State{
        name = "transform_wereplayer",
        tags = { "busy", "pausepredict", "dismounting", "transform", "nomorph" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.components.inventory:Close()
            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            if inst.components.rider:IsRiding() then
                inst.sg.statemem.data = data
                inst.AnimState:PlayAnimation("fall_off")
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            else
                inst.sg.statemem.transforming = true
                inst.sg:GoToState("transform_were"..data.mode, data.cb)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.rider:ActualDismount()
                    inst.sg.statemem.transforming = true
                    inst.sg:GoToState("transform_were"..inst.sg.statemem.data.mode, inst.sg.statemem.data.cb)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.transforming then
                inst.components.rider:ActualDismount()
                if not inst.components.health:IsDead() then
                    inst.components.inventory:Open()
                end
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,
    },

    State{
        --V2C: This state is only meant to be entered via "transform_wereplayer"
        name = "transform_werebeaver",
        tags = { "busy", "pausepredict", "transform", "nomorph" },

        onenter = function(inst, cb)
            inst.sg.statemem.cb = cb
            inst:SetCameraDistance(14)
            inst.AnimState:PlayAnimation("transform_pre")
            DoHurtSound(inst)
            inst.components.inventory:DropEquipped(true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, PlayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.cb == nil or inst:HasTag("wereplayer") then
                        inst.sg:GoToState("idle")
                    else
                        inst.sg.statemem.cb(inst)
                        inst.AnimState:PlayAnimation("transform_pst")
                        SpawnPrefab("werebeaver_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst:SetCameraDistance()
                        inst.sg:RemoveStateTag("transform")
                    end
                end
            end),
        },

        ontimeout = function(inst)
            if not inst.sg:HasStateTag("transform") then
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if not (inst.components.health:IsDead() or inst:HasTag("wereplayer")) then
                    --failed or interrupted
                    inst.components.inventory:Open()
                end
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "transform_beaver_person",
        tags = { "busy", "pausepredict", "transform", "nomorph" },

        onenter = function(inst, cb)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.sg.statemem.cb = cb
            inst.AnimState:PlayAnimation("transform_pre")
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_voice", nil, .5)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 23 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(37.5 * FRAMES, PlayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.cb ~= nil and inst:HasTag("wereplayer") then
                        inst.sg.statemem.cb(inst)
                        inst.AnimState:PlayAnimation("transform_pst")
                        SpawnPrefab("werebeaver_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst.components.inventory:Open()
                        inst:SetCameraDistance()
                        inst.sg:RemoveStateTag("transform")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        ontimeout = function(inst)
            if not inst.sg:HasStateTag("transform") then
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if not (inst.components.health:IsDead() or inst:HasTag("wereplayer")) then
                    inst.components.inventory:Open()
                end
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    --------------------------------------------------------------------------
    State{
        --V2C: This state is only meant to be entered via "transform_wereplayer"
        name = "transform_weremoose",
        tags = { "busy", "pausepredict", "transformpre", "transform", "nomorph" },

        onenter = function(inst, cb)
            inst.sg.statemem.cb = cb
            inst:SetCameraDistance(14)
            inst.AnimState:PlayAnimation("weremoose_transform")
            DoHurtSound(inst)
            inst.components.inventory:DropEquipped(true)
            for i, v in ipairs(weremoose_symbols) do
                inst.AnimState:OverrideSymbol(v, "weremoose_build", v)
            end
            inst:CustomSetDebuffSymbolForSkinMode("weremoose_skin")
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - 2 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("transformpre")
                inst:CustomSetShadowForSkinMode("weremoose_skin")
                SpawnPrefab("weremoose_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
            TimeEvent(24 * FRAMES, function(inst)
                if inst.sg.statemem.cb ~= nil and not inst:HasTag("wereplayer") then
                    inst.sg.statemem.cb(inst)
                    inst:SetCameraDistance()
                    inst.sg:RemoveStateTag("transform")
                else
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/roar")
            end),
            TimeEvent(27 * FRAMES, function(inst)
                SpawnPrefab("weremoose_transform2_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if inst:HasTag("wereplayer") then
                    inst:CustomSetSkinMode("weremoose_skin")
                elseif inst.sg:HasStateTag("transformpre") then
                    inst:CustomSetDebuffSymbolForSkinMode("normal_skin")
                    if not inst.components.health:IsDead() then
                        inst.components.inventory:Open()
                    end
                elseif inst.sg.statemem.cb ~= nil then
                    inst.sg:RemoveStateTag("transform")
                    inst.sg.statemem.cb(inst)
                    SpawnPrefab("weremoose_transform2_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                end
            elseif inst:HasTag("wereplayer") then
                inst:CustomSetSkinMode("weremoose_skin")
            end
            for i, v in ipairs(weremoose_symbols) do
                inst.AnimState:ClearOverrideSymbol(v)
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "transform_moose_person",
        tags = { "busy", "pausepredict", "transformpre", "transform", "nomorph" },

        onenter = function(inst, cb)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.sg.statemem.cb = cb
            inst:CustomSetSkinMode("normal_skin")
            inst:CustomSetShadowForSkinMode("weremoose_skin")
            inst:CustomSetDebuffSymbolForSkinMode("weremoose_skin")
            inst.AnimState:PlayAnimation("weremoose_revert")
            for i, v in ipairs(weremoose_symbols) do
                inst.AnimState:OverrideSymbol(v, "weremoose_build", v)
            end
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/death_voice", nil, .5)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("transformpre")
                inst:CustomSetShadowForSkinMode("normal_skin")
                SpawnPrefab("weremoose_revert_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.cb ~= nil and inst:HasTag("wereplayer") then
                    inst.sg.statemem.cb(inst)
                    inst:CustomSetDebuffSymbolForSkinMode("weremoose_skin")
                    inst.components.inventory:Open()
                    inst:SetCameraDistance()
                    inst.sg:RemoveStateTag("transform")
                else
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(28 * FRAMES, PlayFootstep),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if not inst:HasTag("wereplayer") then
                    inst:CustomSetShadowForSkinMode("normal_skin")
                    inst:CustomSetDebuffSymbolForSkinMode("normal_skin")
                    if not inst.components.health:IsDead() then
                        inst.components.inventory:Open()
                    end
                elseif inst.sg:HasStateTag("transformpre") then
                    inst:CustomSetSkinMode("weremoose_skin")
                elseif inst.sg.statemem.cb ~= nil then
                    inst.sg.statemem.cb(inst)
                    if not inst.components.health:IsDead() then
                        inst.components.inventory:Open()
                    end
                end
            else
                inst:CustomSetDebuffSymbolForSkinMode("normal_skin")
            end
            for i, v in ipairs(weremoose_symbols) do
                inst.AnimState:ClearOverrideSymbol(v)
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    --------------------------------------------------------------------------
    State{
        --V2C: This state is only meant to be entered via "transform_wereplayer"
        name = "transform_weregoose",
        tags = { "busy", "pausepredict", "transform", "nomorph" },

        onenter = function(inst, cb)
            inst.sg.statemem.cb = cb
            inst:SetCameraDistance(14)
            inst.AnimState:PlayAnimation("transform_weregoose_pre")
            DoHurtSound(inst)
            inst.components.inventory:DropEquipped(true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.cb == nil or inst:HasTag("wereplayer") then
                        inst.sg:GoToState("idle")
                    else
                        inst.sg.statemem.cb(inst)
                        inst.AnimState:PlayAnimation("transform_weregoose_pst")
                        inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/goose/death_voice")
                        SpawnPrefab("weregoose_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst:SetCameraDistance()
                        inst.sg:RemoveStateTag("transform")
                    end
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if not (inst.components.health:IsDead() or inst:HasTag("wereplayer")) then
                    inst.components.inventory:Open()
                end
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
                inst.components.playercontroller:EnableMapControls(true)
            end
        end,
    },

    State{
        name = "transform_goose_person",
        tags = { "busy", "pausepredict", "transform", "nomorph" },

        onenter = function(inst, cb)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.sg.statemem.cb = cb
            inst.AnimState:PlayAnimation("revert_weregoose_pre")
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/goose/death_voice")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 18 * FRAMES)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.cb ~= nil and inst:HasTag("wereplayer") then
                        inst.sg.statemem.cb(inst)
                        inst.AnimState:PlayAnimation("revert_weregoose_pst")
                        PlayFootstep(inst)
                        if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
                            SpawnPrefab("weregoose_splash").entity:SetParent(inst.entity)
                        end
                        SpawnPrefab("weregoose_transform_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
                        inst.components.inventory:Open()
                        inst:SetCameraDistance()
                        inst.sg:RemoveStateTag("transform")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        ontimeout = function(inst)
            if not inst.sg:HasStateTag("transform") then
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if inst.sg:HasStateTag("transform") then
                --interrupted
                inst:SetCameraDistance()
                if not (inst.components.health:IsDead() or inst:HasTag("wereplayer")) then
                    inst.components.inventory:Open()
                end
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
                inst.components.playercontroller:EnableMapControls(true)
            end
        end,
    },

    --------------------------------------------------------------------------

    State{
        name = "electrocute",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.fx = SpawnPrefab(
                (not inst:HasTag("wereplayer") and "shock_fx") or
                (inst:HasTag("beaver") and "werebeaver_shock_fx") or
                (inst:HasTag("weremoose") and "weremoose_shock_fx") or
                (--[[inst:HasTag("weregoose") and]] "weregoose_shock_fx")
            )
            if inst.components.rider:IsRiding() then
                inst.fx.Transform:SetSixFaced()
            end
            inst.fx.entity:SetParent(inst.entity)
            inst.fx.entity:AddFollower()
            inst.fx.Follower:FollowSymbol(inst.GUID, "swap_shock_fx", 0, 0, 0)

            if not inst:HasTag("electricdamageimmune") then
                inst.components.bloomer:PushBloom("electrocute", "shaders/anim.ksh", -2)
                inst.Light:Enable(true)
            end

            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:PushAnimation("shock_pst", false)

            DoHurtSound(inst)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(8 * FRAMES + inst.AnimState:GetCurrentAnimationLength())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.fx ~= nil then
                    if not inst:HasTag("electricdamageimmune") then
                        inst.Light:Enable(false)
                        inst.components.bloomer:PopBloom("electrocute")
                    end
                    inst.fx:Remove()
                    inst.fx = nil
                end
            end),

            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.fx ~= nil then
                if not inst:HasTag("electricdamageimmune") then
                    inst.Light:Enable(false)
                    inst.components.bloomer:PopBloom("electrocute")
                end
                inst.fx:Remove()
                inst.fx = nil
            end
        end,
    },

    State{
        name = "rebirth",
        tags = { "nopredict", "silentmorph" },

        onenter = function(inst, source)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("rebirth")

            local skin_build = source and source:GetSkinBuild() or nil
            if skin_build ~= nil then
                for k,v in pairs(statue_symbols) do
                    inst.AnimState:OverrideItemSkinSymbol(v, skin_build, v, inst.GUID, "wilsonstatue")
                end
            else
                for k,v in pairs(statue_symbols) do
                    inst.AnimState:OverrideSymbol(v, "wilsonstatue", v)
                end
            end

            inst.components.health:SetInvincible(true)
            inst:ShowHUD(false)
            inst:SetCameraDistance(12)
        end,

        timeline =
        {
            TimeEvent(16*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
            end),
            TimeEvent(45*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/dropwood")
            end),
            TimeEvent(92*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth")
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

        onexit = function(inst)
            for k, v in pairs(statue_symbols) do
                inst.AnimState:ClearOverrideSymbol(v)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end

            inst.components.health:SetInvincible(false)
            inst:ShowHUD(true)
            inst:SetCameraDistance()

            SerializeUserSession(inst)
        end,
    },

    State{
        name = "death",
        tags = { "busy", "dead", "pausepredict", "nomorph" },

        onenter = function(inst)
            assert(inst.deathcause ~= nil, "Entered death state without cause.")

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            if inst.components.rider:IsRiding() then
                DoMountSound(inst, inst.components.rider:GetMount(), "yell")
                inst.AnimState:PlayAnimation("fall_off") --22 frames
                inst.sg:AddStateTag("dismounting")
            else
                if not inst:HasTag("wereplayer") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/death")
                elseif inst:HasTag("beaver") then
                    inst.sg.statemem.beaver = true
                elseif inst:HasTag("weremoose") then
                    inst.sg.statemem.moose = true
                else--if inst:HasTag("weregoose") then
                    inst.sg.statemem.goose = true
                end

                if inst.deathsoundoverride ~= nil then
                    inst.SoundEmitter:PlaySound(inst.deathsoundoverride)
                elseif not inst:HasTag("mime") then
                    inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/death_voice")
                end

				if inst.charlie_vinesave then
					inst.AnimState:AddOverrideBuild("winona_death")
					inst.AnimState:PlayAnimation("death_vinesave")
					inst.SoundEmitter:PlaySound("meta4/charlie_residue/resurrect_grab")
					inst:SetCameraDistance(14)
					inst.sg.statemem.dovinesave = true
				elseif inst.components.revivablecorpse ~= nil then
                    inst.AnimState:PlayAnimation("death2")
                else
					if HUMAN_MEAT_ENABLED then
						inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
					end
                    inst.components.inventory:DropEverything(true)
                    inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
                end

                inst.AnimState:Hide("swap_arm_carry")
            end

            inst.components.burnable:Extinguish()

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            --Don't process other queued events if we died this frame
            inst.sg:ClearBufferedEvents()
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                if inst.sg.statemem.beaver then
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                elseif inst.sg.statemem.goose then
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                    DoGooseRunFX(inst)
                end
            end),
            TimeEvent(20 * FRAMES, function(inst)
                if inst.sg.statemem.moose then
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
			FrameEvent(41, function(inst)
				if inst.sg.statemem.dovinesave and not inst.sg.statemem.dismount_vinesave then
					PlayerCommonExtensions.OnDeathTriggerVineSave(inst)
				end
			end),
			FrameEvent(22 + 41, function(inst)
				if inst.sg.statemem.dismount_vinesave then
					PlayerCommonExtensions.OnDeathTriggerVineSave(inst)
				end
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg:HasStateTag("dismounting") then
                        inst.sg:RemoveStateTag("dismounting")
                        inst.components.rider:ActualDismount()

                        inst.SoundEmitter:PlaySound("dontstarve/wilson/death")

						if inst.deathsoundoverride ~= nil then
							inst.SoundEmitter:PlaySound(FunctionOrValue(inst.deathsoundoverride, inst))
						elseif not inst:HasTag("mime") then
                            inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/death_voice")
                        end

						if inst.charlie_vinesave then
							inst.AnimState:AddOverrideBuild("winona_death")
							inst.AnimState:PlayAnimation("death_vinesave")
							inst.SoundEmitter:PlaySound("meta4/charlie_residue/resurrect_grab")
							inst:SetCameraDistance(14)
							inst.sg.statemem.dovinesave = true
							inst.sg.statemem.dismount_vinesave = true
						elseif inst.components.revivablecorpse ~= nil then
                            inst.AnimState:PlayAnimation("death2")
                        else
							if HUMAN_MEAT_ENABLED then
								inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
							end
                            inst.components.inventory:DropEverything(true)
                            inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
                        end

                        inst.AnimState:Hide("swap_arm_carry")
					elseif inst.sg.statemem.dovinesave then
						inst.sg.statemem.vinesaving = true
						inst.sg:GoToState("death_vinesave_pst")
                    elseif inst.components.revivablecorpse ~= nil then
                        inst.sg:GoToState("corpse")
                    elseif inst.ghostenabled then
                        inst.components.cursable:Died()
                        if inst:HasTag("wonkey") then
                            inst:ChangeFromMonkey()
                        else
                            inst:PushEvent("makeplayerghost", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
                        end
                    else
                        inst:PushEvent("playerdied", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
                    end
                end
            end),
        },

		onexit = function(inst)
			if inst.sg.statemem.vinesaving then
				return
			elseif inst.components.revivablecorpse == nil then
				--You should never leave this state once you enter it!
				assert(false, "Left death state.")
				if inst.components.playercontroller then
					inst.components.playercontroller:Enable(true)
				end
			end
			inst.charlie_vinesave = nil
			if inst.sg.statemem.dovinesave then
				inst.AnimState:ClearOverrideBuild("winona_death")
			end
			inst:SetCameraDistance()
		end,
    },

    State{
        name = "seamlessplayerswap_death",
        tags = { "busy", "dead", "noattack", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst)
            if inst.components.revivablecorpse ~= nil then
                inst.sg:GoToState("corpse")
            elseif inst.ghostenabled then
                inst:PushEvent("makeplayerghost", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
            else
                inst.AnimState:SetPercent(inst.deathanimoverride or "death", 1)
                inst:PushEvent("playerdied", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
            end
        end,

        onexit = function(inst)
            --You should never leave this state once you enter it!
            if inst.components.revivablecorpse == nil then
                assert(false, "Left death state.")
            end
        end,
    },

	State{
		name = "death_vinesave_pst",
		tags = { "busy", "dead", "invisible", "noattack", "nopredict", "nomorph" },

		onenter = function(inst)
			ClearStatusAilments(inst)
			ForceStopHeavyLifting(inst)

			inst.components.locomotor:Stop()
			inst.components.locomotor:Clear()
			inst:ClearBufferedAction()

			inst.components.rider:ActualDismount()

			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
			end

			inst.AnimState:PlayAnimation("death_vinesave_pst")
			inst.DynamicShadow:Enable(false)
			inst:SetCameraDistance(14)

			local x, y, z = inst.Transform:GetWorldPosition()
            local flowers = TheSim:FindEntities(x, y, z, DEPLOYSPACING_RADIUS[DEPLOYSPACING.LESS], FLOWERS_MUST_TAGS, FLOWERS_CANT_TAGS)
            local _world = TheWorld
            for _, flower in ipairs(flowers) do
                if flower.components.pickable then
                    local success, loot = flower.components.pickable:Pick(_world)
                    if loot ~= nil then
                        for _, item in ipairs(loot) do
                            Launch(item, inst, 1.0)
                        end
                    end
                end
            end
			local rose = SpawnPrefab("flower_rose")
            rose.planted = true
			rose.Transform:SetPosition(x, 0, z)
			rose:DoRoseBounceAnim()
			rose:AddTag("NOCLICK")
			rose.persists = false
			inst.sg.statemem.rose = rose

			local fx = SpawnPrefab("rose_petals_fx")
			fx.Transform:SetPosition(x, 0, z)
			fx.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

			--death_vinesave_pst is quite short, about 10 frames
			--screen fade 2 seconds
			inst.sg:SetTimeout(3)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst:Hide()
					inst:ScreenFade(false, 2)
				end
			end),
		},

		ontimeout = function(inst)
            local x, y, z = FindCharlieRezSpotFor(inst)

			inst.Physics:Teleport(x, 0, z)
			inst:SnapCamera()
			inst:ScreenFade(true, 1)

			inst.sg.statemem.vinesaving = true
			inst.sg:GoToState("respawn_vinesave")
		end,

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
			inst:Show()

			local rose = inst.sg.statemem.rose
			if rose and rose:IsValid() then
				rose:RemoveTag("NOCLICK")
				rose.persists = true
			end

			if not inst.sg.statemem.vinesaving then
				assert(false, "Left death state.")
				inst.AnimState:ClearOverrideBuild("winona_death")
				inst.components.health:SetInvincible(false)
				if inst.components.playercontroller then
					inst.components.playercontroller:Enable(true)
				end
				inst:SetCameraDistance()
			end
		end,
	},

	State{
		name = "respawn_vinesave",
		tags = { "busy", "noattack", "nopredict", "silentmorph" },

		onenter = function(inst)
			PlayerCommonExtensions.OnRespawnFromVineSave(inst)
			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
			end
			inst.AnimState:PlayAnimation("rebirth_vinesave")
			inst.SoundEmitter:PlaySound("meta4/charlie_residue/resurrect_release")
			inst.components.health:SetInvincible(true)
			inst:ShowHUD(false)
			inst:SetCameraDistance(14)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst:ShowHUD(true)
			inst:SetCameraDistance()
			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(true)
			end
			inst.components.health:SetInvincible(false)
			inst.AnimState:ClearOverrideBuild("winona_death")

			SerializeUserSession(inst)
		end,
	},

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
			if inst.sg.lasttags and not inst.sg.lasttags["busy"] then
				inst.components.locomotor:StopMoving()
			else
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
			end
			inst:ClearBufferedAction()

            if inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() then
                inst.sg:GoToState("sink_fast")
                return
			end

            inst.sg.statemem.ignoresandstorm = true

            if inst.components.rider:IsRiding() then
                inst.sg:GoToState("mounted_idle", pushanim)
                return
            end

            local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                inst.sg:GoToState("enter_onemanband", pushanim)
                return
            end

			if inst.sg.mem.queuetalk_timeout ~= nil then
				local remaining_talk_time = inst.sg.mem.queuetalk_timeout - GetTime()
				inst.sg.mem.queuetalk_timeout = nil
				if not (pushanim or inst:HasTag("ignoretalking")) then
					if remaining_talk_time > 1 then
						if not inst:HasTag("mime") then
							inst.sg:GoToState("talk")
							return
						elseif not inst.components.inventory:IsHeavyLifting() then
							inst.sg:GoToState("mime")
							return
						end
					end
				end
			end

            local anims = {}
            local dofunny = true

            if inst:HasTag("wereplayer") then
                if inst:HasTag("groggy") then
                    --V2C: groggy moose and goose go straight back to idle_groggy (don't play idle_groggy_pre everytime like others do)
                    local skippre = false
                    if inst:HasTag("weremoose") then
                        skippre =
                            inst.AnimState:IsCurrentAnimation("idle_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("idle_walk") or
                            inst.AnimState:IsCurrentAnimation("idle_walk_pre")
                    elseif inst:HasTag("weregoose") then
                        skippre =
                            inst.AnimState:IsCurrentAnimation("idle_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("idle_walk") or
                            inst.AnimState:IsCurrentAnimation("idle_walk_pre")
                    end
                    if not skippre then
                        table.insert(anims, "idle_groggy_pre")
                    end
                    table.insert(anims, "idle_groggy")
                else
                    table.insert(anims, "idle_loop")
                    if inst:HasTag("weregoose") then
                        inst.sg.statemem.gooseframe = -1
                    end
                end
                dofunny = false
            elseif inst.components.inventory:IsHeavyLifting() then
                table.insert(anims, "heavy_idle")
                dofunny = false
			elseif inst:IsChannelCasting() then
				inst.sg.statemem.channelcast = true
				inst.sg.statemem.channelcastitem = inst:IsChannelCastingItem()
				if inst.sg.lasttags and inst.sg.lasttags["keepchannelcasting"] then
					--Came from a state that isn't channeling item specific
					--so it would've animated back to regular idle instead.
					table.insert(anims, inst.sg.statemem.channelcastitem and "channelcast_idle_pre" or "channelcast_oh_idle_pre")
				end
				table.insert(anims, inst.sg.statemem.channelcastitem and "channelcast_idle" or "channelcast_oh_idle")
				dofunny = false
            else
                inst.sg.statemem.ignoresandstorm = false
				if inst:IsInAnyStormOrCloud() and not inst.components.playervision:HasGoggleVision() then
                    if not (inst.AnimState:IsCurrentAnimation("sand_walk_pst") or
                            inst.AnimState:IsCurrentAnimation("sand_walk") or
                            inst.AnimState:IsCurrentAnimation("sand_walk_pre")) then
                        table.insert(anims, "sand_idle_pre")
                    end
                    table.insert(anims, "sand_idle_loop")
                    inst.sg.statemem.sandstorm = true
                    dofunny = false
                elseif inst.components.sanity:IsInsane() then
                    table.insert(anims, "idle_sanity_pre")
                    table.insert(anims, "idle_sanity_loop")
                elseif inst.components.sanity:IsEnlightened() then
                    table.insert(anims, "idle_lunacy_pre")
                    table.insert(anims, "idle_lunacy_loop")
                elseif inst.components.temperature:IsFreezing() then
                    table.insert(anims, "idle_shiver_pre")
                    table.insert(anims, "idle_shiver_loop")
                elseif inst.components.temperature:IsOverheating() then
                    table.insert(anims, "idle_hot_pre")
                    table.insert(anims, "idle_hot_loop")
                    dofunny = false
                elseif inst:HasTag("groggy") then
                    if not inst.AnimState:IsCurrentAnimation("yawn") then
                        table.insert(anims, "idle_groggy_pre")
                    end
                    table.insert(anims, "idle_groggy")
                else
                    table.insert(anims, "idle_loop")
                end
            end

            if pushanim then
                for k, v in pairs(anims) do
                    inst.AnimState:PushAnimation(v, k == #anims)
                end
            else
                inst.AnimState:PlayAnimation(anims[1], #anims == 1)
                for k, v in pairs(anims) do
                    if k > 1 then
                        inst.AnimState:PushAnimation(v, k == #anims)
                    end
                end
            end

            if dofunny then
                inst.sg:SetTimeout(math.random() * 4 + 2)
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.gooseframe ~= nil and inst.AnimState:IsCurrentAnimation("idle_loop") then
				local t = inst.AnimState:GetCurrentAnimationFrame()
                if (t == 5 or t == 14) and t ~= inst.sg.statemem.gooseframe then
                    PlayFootstep(inst, .5, false)
                    DoGooseStepFX(inst)
                end
                inst.sg.statemem.gooseframe = t
            end
        end,

        events =
        {
			EventHandler("stormlevel", function(inst, data)
                if not inst.sg.statemem.ignoresandstorm then
                    if data.level < TUNING.SANDSTORM_FULL_LEVEL then
                        if inst.sg.statemem.sandstorm then
                            inst.sg:GoToState("idle")
                        end
                    elseif not (inst.sg.statemem.sandstorm or inst.components.playervision:HasGoggleVision()) then
                        inst.sg:GoToState("idle")
                    end
                end
            end),
			EventHandler("miasmalevel", function(inst, data)
				if not inst.sg.statemem.ignoresandstorm then
					if data.level < 1 then
						if inst.sg.statemem.sandstorm then
							inst.sg:GoToState("idle")
						end
					elseif not (inst.sg.statemem.sandstorm or inst.components.playervision:HasGoggleVision()) then
						inst.sg:GoToState("idle")
					end
				end
			end),
			EventHandler("stopchannelcast", function(inst)
				if inst.sg.statemem.channelcast and not inst:IsChannelCasting() then
					inst.AnimState:PlayAnimation(inst.sg.statemem.channelcastitem and "channelcast_idle_pst" or "channelcast_oh_idle_pst")
					inst.sg:GoToState("idle", true)
				end
			end),
        },

        ontimeout = function(inst)
            local royalty = nil
            local mindistsq = 25
            for i, v in ipairs(AllPlayers) do
                if v ~= inst and
                    not v:HasTag("playerghost") and
                    v.entity:IsVisible() and
                    v.components.inventory:EquipHasTag("regal") then
                    local distsq = v:GetDistanceSqToInst(inst)
                    if distsq < mindistsq then
                        mindistsq = distsq
                        royalty = v
                    end
                end
            end
            if royalty ~= nil then
                inst.sg:GoToState("bow", royalty)
            else
                inst.sg:GoToState("funnyidle")
            end
        end,
    },

    State{
        name = "funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            if inst.components.temperature:GetCurrent() < 5 then
                inst.AnimState:PlayAnimation("idle_shiver_pre")
                inst.AnimState:PushAnimation("idle_shiver_loop")
                inst.AnimState:PushAnimation("idle_shiver_pst", false)
            elseif inst.components.temperature:GetCurrent() > TUNING.OVERHEAT_TEMP - 10 then
                inst.AnimState:PlayAnimation("idle_hot_pre")
                inst.AnimState:PushAnimation("idle_hot_loop")
                inst.AnimState:PushAnimation("idle_hot_pst", false)
            elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst.components.sanity:IsInsanityMode() and inst.components.sanity:GetPercent() < .5 then
                inst.AnimState:PlayAnimation("idle_inaction_sanity")
            elseif inst.components.sanity:IsLunacyMode() and inst.components.sanity:GetPercent() > .5 then
                inst.AnimState:PlayAnimation("idle_inaction_lunacy")
            elseif inst:HasTag("groggy") then
                inst.AnimState:PlayAnimation("idle_groggy01_pre")
                inst.AnimState:PushAnimation("idle_groggy01_loop")
                inst.AnimState:PushAnimation("idle_groggy01_pst", false)
            elseif inst.customidleanim == nil and inst.customidlestate == nil then
                inst.AnimState:PlayAnimation("idle_inaction")
			else
                local anim = inst.customidleanim ~= nil and (type(inst.customidleanim) == "string" and inst.customidleanim or inst:customidleanim()) or nil
				local state = anim == nil and (inst.customidlestate ~= nil and (type(inst.customidlestate) == "string" and inst.customidlestate or inst:customidlestate())) or nil
                if anim ~= nil or state ~= nil then
                    if inst.sg.mem.idlerepeats == nil then
                        inst.sg.mem.usecustomidle = math.random() < .5
                        inst.sg.mem.idlerepeats = 0
                    end
                    if inst.sg.mem.idlerepeats > 1 then
                        inst.sg.mem.idlerepeats = inst.sg.mem.idlerepeats - 1
                    else
                        inst.sg.mem.usecustomidle = not inst.sg.mem.usecustomidle
                        inst.sg.mem.idlerepeats = inst.sg.mem.usecustomidle and 1 or math.ceil(math.random(2, 5) * .5)
                    end
					if inst.sg.mem.usecustomidle then
						if anim ~= nil then
		                    inst.AnimState:PlayAnimation(anim)
						else
							inst.sg:GoToState(state)
						end
					else
	                    inst.AnimState:PlayAnimation("idle_inaction")
					end
                else
                    inst.AnimState:PlayAnimation("idle_inaction")
                end
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "wes_funnyidle",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_wes")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/breath_idle")
            end),
            TimeEvent(26 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/blow_idle")
            end),
            TimeEvent(42 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/breath_idle")
            end),
            TimeEvent(58 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/blow_idle")
            end),
            TimeEvent(73 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wes/characters/wes/pop_idle")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "wx78_funnyidle",
        tags = {"idle", "canrotate", "nodangle"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_wx")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

	State{
		name = "waxwell_funnyidle",
		tags = { "idle", "canrotate", "nodangle" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation(math.random() < .7 and "idle_waxwell" or "idle2_waxwell") -- Keep odds in sync with skinspuppet!
		end,

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
        name = "bow",
        tags = { "notalking", "busy", "nopredict", "forcedangle" },

        onenter = function(inst, target)
            if target ~= nil then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("bow_pre")
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds.grunt ~= nil then
                    inst.SoundEmitter:PlaySound(mount.sounds.grunt)
                end
            end),
            TimeEvent(24 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and
                    inst.sg.statemem.target:IsValid() and
                    inst.sg.statemem.target:IsNear(inst, 6) and
                    inst.sg.statemem.target.components.inventory:EquipHasTag("regal") and
                    inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_ROYALTY"))
                else
                    inst.sg.statemem.notalk = true
                end
            end),
        },

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.target == nil or
                        (   not inst.sg.statemem.notalk and
                            inst.sg.statemem.target:IsValid() and
                            inst.sg.statemem.target:IsNear(inst, 6) and
                            inst.sg.statemem.target.components.inventory:EquipHasTag("regal")
                        ) then
                        inst.sg.statemem.bowing = true
                        inst.sg:GoToState("bow_loop", { target = inst.sg.statemem.target, talktask = inst.sg.statemem.talktask })
                    else
                        inst.sg:GoToState("bow_pst")
                    end
                end
            end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.bowing then
				CancelTalk_Override(inst)
            end
        end,
    },

    State{
        name = "bow_loop",
        tags = { "notalking", "idle", "canrotate", "forcedangle" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.target = data.target
                inst.sg.statemem.talktask = data.talktask
            end
            inst.AnimState:PlayAnimation("bow_loop", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.target ~= nil and
                not (   inst.sg.statemem.target:IsValid() and
                        inst.sg.statemem.target:IsNear(inst, 6) and
                        inst.sg.statemem.target.components.inventory:EquipHasTag("regal")
                    ) then
                inst.sg:GoToState("bow_pst")
            end
        end,

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
        },

		onexit = CancelTalk_Override,
    },

    State{
        name = "bow_pst",
        tags = { "idle", "canrotate", "forcedangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bow_pst")
            inst.sg:SetTimeout(8 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("bow_pst2")
        end,

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
        name = "bow_pst2",
        tags = { "idle", "canrotate" },

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
        name = "mounted_idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            local equippedArmor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if equippedArmor ~= nil and equippedArmor:HasTag("band") then
                inst.sg:GoToState("enter_onemanband", pushanim)
                return
            end

			if inst:IsInAnyStormOrCloud() and not inst.components.playervision:HasGoggleVision() then
                if pushanim then
                    inst.AnimState:PushAnimation("sand_idle_pre")
                else
                    inst.AnimState:PlayAnimation("sand_idle_pre")
                end
                inst.AnimState:PushAnimation("sand_idle_loop", true)
                inst.sg.statemem.sandstorm = true
            else
                if pushanim then
                    inst.AnimState:PushAnimation("idle_loop", true)
                else
                    inst.AnimState:PlayAnimation("idle_loop", true)
                end
                inst.sg:SetTimeout(2 + math.random() * 8)
            end
        end,

        events =
        {
			EventHandler("stormlevel", function(inst, data)
                if data.level < TUNING.SANDSTORM_FULL_LEVEL then
                    if inst.sg.statemem.sandstorm then
                        inst.sg:GoToState("mounted_idle")
                    end
                elseif not (inst.sg.statemem.sandstorm or inst.components.playervision:HasGoggleVision()) then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
			EventHandler("miasmalevel", function(inst, data)
				if data.level < 1 then
					if inst.sg.statemem.sandstorm then
						inst.sg:GoToState("mounted_idle")
					end
				elseif not (inst.sg.statemem.sandstorm or inst.components.playervision:HasGoggleVision()) then
					inst.sg:GoToState("mounted_idle")
				end
			end),
        },

        ontimeout = function(inst)
            local mount = inst.components.rider:GetMount()
            if mount == nil then
                inst.sg:GoToState("idle")
                return
            end

            local royalty = nil
            local mindistsq = 25
            for i, v in ipairs(AllPlayers) do
                if v ~= inst and
                    not v:HasTag("playerghost") and
                    v.entity:IsVisible() and
                    v.components.inventory:EquipHasTag("regal") then
                    local distsq = v:GetDistanceSqToInst(inst)
                    if distsq < mindistsq then
                        mindistsq = distsq
                        royalty = v
                    end
                end
            end
            if royalty ~= nil then
                inst.sg:GoToState("bow", royalty)
            elseif mount.components.hunger == nil then
                inst.sg:GoToState(math.random() < 0.5 and "shake" or "bellow")
            elseif mount:HasTag("woby") then
                local woby_idles = {"shake_woby", "alert_woby", "bark_woby"}
                inst.sg:GoToState(woby_idles[math.random(1, #woby_idles)])
            else
                local rand = math.random()
                inst.sg:GoToState(
                    (rand < .25 and "shake") or
                    (rand < .5 and "bellow") or
                    (inst.components.hunger:IsStarving() and "graze_empty" or "graze")
                )
            end
        end,
    },

    State{
        name = "graze",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("graze_loop", true)
            inst.sg:SetTimeout(1 + math.random() * 5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("mounted_idle")
        end,
    },

    State{
        name = "graze_empty",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("graze2_pre")
            inst.AnimState:PushAnimation("graze2_loop")
            inst.sg:SetTimeout(1 + math.random() * 5)
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("graze2_pst")
            inst.sg:GoToState("mounted_idle", true)
        end,
    },

    State{
        name = "bellow",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bellow")
            DoMountSound(inst, inst.components.rider:GetMount(), "grunt")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },
    },

    State{
        name = "shake",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shake")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },
    },

    State{
        name = "shake_woby",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local mount = inst.components.rider:GetMount()
            if mount and mount:HasTag("woby") then
                inst.AnimState:PlayAnimation("shake_woby")
            else
                inst.sg:GoToState("mounted_idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
        },
    },

    State{
        name = "alert_woby",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local mount = inst.components.rider:GetMount()
            if mount and mount:HasTag("woby") then
                inst.AnimState:PlayAnimation("alert_woby_pre",  false)
                inst.AnimState:PushAnimation("alert_woby_loop", false)
                inst.AnimState:PushAnimation("alert_woby_pst",  false)
            else
                inst.sg:GoToState("mounted_idle")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/foley") end),
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/chuff") end),
        },
    },

    State{
        name = "bark_woby",
        tags = { "idle", "canrotate" },

        onenter = function(inst)
            local mount = inst.components.rider:GetMount()
            if mount and mount:HasTag("woby") then
                if math.random() < 0.5 then
                    inst.AnimState:PlayAnimation("bark1_woby",  false)
                end
            else
                inst.sg:GoToState("mounted_idle")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },

        timeline=
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark") end),
        },
    },

    State{
        name = "chop_start",
        tags = { "prechop", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst:HasTag("woodcutter") and "woodie_chop_pre" or "chop_pre")
			inst:AddTag("prechop")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.chopping = true
                    inst.sg:GoToState("chop")
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.chopping then
				inst:RemoveTag("prechop")
			end
		end,
    },

    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.sg.statemem.iswoodcutter = inst:HasTag("woodcutter")
            inst.AnimState:PlayAnimation(inst.sg.statemem.iswoodcutter and "woodie_chop_loop" or "chop_loop")
			inst:AddTag("prechop")
        end,

        timeline =
        {
            ----------------------------------------------
            --Woodcutter chop

            TimeEvent(2 * FRAMES, function(inst)
                if inst.sg.statemem.iswoodcutter then
                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.iswoodcutter then
                    inst.sg:RemoveStateTag("prechop")
					inst:RemoveTag("prechop")
                end
            end),

            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswoodcutter and
                    inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.iswoodcutter then
                    inst.sg:RemoveStateTag("chopping")
                end
            end),

            ----------------------------------------------
            --Normal chop

            TimeEvent(2 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter then
                    inst:PerformBufferedAction()
                end
            end),

            TimeEvent(9 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter then
                    inst.sg:RemoveStateTag("prechop")
					inst:RemoveTag("prechop")
                end
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter and
                    inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16 * FRAMES, function(inst)
                if not inst.sg.statemem.iswoodcutter then
                    inst.sg:RemoveStateTag("chopping")
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    --We don't have a chop_pst animation
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("prechop")
		end,
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
			inst:AddTag("premine")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.mining = true
                    inst.sg:GoToState("mine")
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.mining then
				inst:RemoveTag("premine")
			end
		end,
    },

    State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
			inst:AddTag("premine")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    PlayMiningFX(inst, inst.sg.statemem.action.target)
                end
				inst.sg.statemem.recoilstate = "mine_recoil"
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
				inst:RemoveTag("premine")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_PRIMARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("premine")
		end,
    },

	State{
		name = "mine_recoil",
		tags = { "busy", "nopredict", "nomorph" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("pickaxe_recoil")
			if data ~= nil and data.target ~= nil and data.target:IsValid() then
				SpawnPrefab("impact").Transform:SetPosition(data.target.Transform:GetWorldPosition())
			end
			inst:ShakeCamera(CAMERASHAKE.FULL, .4, .02, .15)
			inst.Physics:SetMotorVel(-6, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.75
			end
		end,

		timeline =
		{
			FrameEvent(4, function(inst)
				inst.sg.statemem.speed = -3
			end),
			FrameEvent(17, function(inst)
				inst.sg.statemem.speed = nil
				inst.Physics:Stop()
			end),
			FrameEvent(23, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nopredict")
				inst.sg:RemoveStateTag("nomorph")
			end),
			FrameEvent(30, function(inst)
				inst.sg:GoToState("idle", true)
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

		onexit = function(inst)
			inst.Physics:Stop()
		end,
	},

    State{
        name = "hammer_start",
        tags = { "prehammer", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
			inst:AddTag("prehammer")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.hammering = true
                    inst.sg:GoToState("hammer")
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.hammering then
				inst:RemoveTag("prehammer")
			end
		end,
    },

    State{
        name = "hammer",
        tags = { "prehammer", "hammering", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
			inst:AddTag("prehammer")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sg.statemem.action ~= nil and inst.sg.statemem.action.invobject ~= nil and inst.sg.statemem.action.invobject.hit_skin_sound or "dontstarve/wilson/hit")
				inst.sg.statemem.recoilstate = "mine_recoil"
				inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehammer")
				inst:RemoveTag("prehammer")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_SECONDARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ALTACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("pickaxe_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("prehammer")
		end,
    },

    State{
        name = "gnaw",
        tags = { "gnawing", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
			inst:AddTag("gnawing")
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    local target = inst.sg.statemem.action.target
                    if target ~= nil and target:IsValid() then
                        if inst.sg.statemem.action.action == ACTIONS.MINE then
							inst.sg.statemem.recoilstate = "gnaw_recoil"
                            PlayMiningFX(inst, target)
                        elseif inst.sg.statemem.action.action == ACTIONS.HAMMER then
                            inst.sg.statemem.rmb = true
                            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
                        elseif inst.sg.statemem.action.action == ACTIONS.DIG then
                            inst.sg.statemem.rmb = target:HasTag("sign")
                            SpawnPrefab("shovel_dirt").Transform:SetPosition(target.Transform:GetWorldPosition())
                        end
                    end
                end
                inst:PerformBufferedAction()
            end),

            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("gnawing")
				inst:RemoveTag("gnawing")
            end),

            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.action == nil or
                    inst.sg.statemem.action.action == nil or
                    inst.components.playercontroller == nil then
                    return
                end
                if inst.sg.statemem.rmb then
                    if not inst.components.playercontroller:IsAnyOfControlsPressed(
                            CONTROL_SECONDARY,
                            CONTROL_CONTROLLER_ALTACTION) then
                        return
                    end
                elseif not inst.components.playercontroller:IsAnyOfControlsPressed(
                            CONTROL_PRIMARY,
                            CONTROL_ACTION,
                            CONTROL_CONTROLLER_ACTION) then
                    return
                end
                if inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target.components.workable:GetWorkAction() == inst.sg.statemem.action.action and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
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

		onexit = function(inst)
			inst:RemoveTag("gnawing")
		end,
    },

	State{
		name = "gnaw_recoil",
		tags = { "busy", "nopredict", "nomorph" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("hit")
			inst:ShakeCamera(CAMERASHAKE.FULL, .4, .02, .15)
			inst.Physics:SetMotorVel(-6, 0, 0)
		end,

		onupdate = function(inst)
			if inst.sg.statemem.speed ~= nil then
				inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
				inst.sg.statemem.speed = inst.sg.statemem.speed * 0.6
			end
		end,

		timeline =
		{
			FrameEvent(1, function(inst)
				inst.sg.statemem.speed = -2
			end),
			FrameEvent(5, function(inst)
				inst.sg.statemem.speed = nil
				inst.Physics:Stop()
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

		onexit = function(inst)
			inst.Physics:Stop()
		end,
	},

    State{
        name = "hide",
        tags = { "hiding", "notalking", "nomorph", "busy", "nopredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hide")
            inst.AnimState:PushAnimation("hide_idle", false)
            inst.SoundEmitter:PlaySound("dontstarve/movement/foley/hidebush")
        end,

        timeline =
        {
            TimeEvent(24 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
                inst.sg:AddStateTag("idle")
            end),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
                inst.AnimState:PushAnimation("hide_idle", false)
				return OnTalk_Override(inst)
            end),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                -- We need to handle this during the initial "busy" frames
                if not inst.sg:HasStateTag("idle") then
                    inst.sg:GoToState(GetUnequipState(inst, data))
                end
            end),
        },

		onexit = CancelTalk_Override,
    },

    State{
        name = "shell_enter",
        tags = { "hiding", "notalking", "shell", "nomorph", "busy", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hideshell")

            inst.sg:SetTimeout(23 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/foley/hideshell")
            end),
        },

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
                inst.sg:GoToState(GetUnequipState(inst, data))
            end),
        },

        ontimeout = function(inst)
            --Transfer talk task to shell_idle state
            local talktask = inst.sg.statemem.talktask
            inst.sg.statemem.talktask = nil
            inst.sg:GoToState("shell_idle", talktask)
        end,

		onexit = CancelTalk_Override,
    },

    State{
        name = "shell_idle",
        tags = { "hiding", "notalking", "shell", "nomorph", "idle" },

        onenter = function(inst, talktask)
            inst.components.locomotor:Stop()
            inst.AnimState:PushAnimation("hideshell_idle", false)

            --Transferred over from shell_idle so it doesn't cut off abrubtly
            inst.sg.statemem.talktask = talktask
        end,

        events =
        {
            EventHandler("ontalk", function(inst)
                inst.AnimState:PushAnimation("hitshell")
                inst.AnimState:PushAnimation("hideshell_idle", false)
				return OnTalk_Override(inst)
            end),
			EventHandler("donetalking", OnDoneTalking_Override),
        },

		onexit = CancelTalk_Override,
    },

    State{
        name = "shell_hit",
        tags = { "hiding", "shell", "nomorph", "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hitshell")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")

            local stun_frames = 3
            if inst.components.playercontroller ~= nil then
                --Specify min frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(stun_frames)
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        events =
        {
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
                inst.sg.statemem.unequipped = true
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState(inst.sg.statemem.unequipped and "idle" or "shell_idle")
        end,
    },

    State{
        name = "parry_pre",
        tags = { "preparrying", "busy", "nomorph" },

        onenter = function(inst)
            inst.sg.statemem.isshield = inst.bufferedaction ~= nil and inst.bufferedaction.invobject ~= nil and inst.bufferedaction.invobject:HasTag("shield")

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pre"  or "parry_pre")
            inst.AnimState:PushAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_loop", true)
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
            --V2C: using animover results in a slight hang on last frame of parry_pre

            local function oncombatparry(inst, data)
                inst.sg:AddStateTag("parrying")
                if data ~= nil then
                    if data.direction ~= nil then
                        inst.Transform:SetRotation(data.direction)
                    end
                    inst.sg.statemem.parrytime = data.duration
                    inst.sg.statemem.item = data.weapon
                    if data.weapon ~= nil then
                        inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli)
                            return IsWeaponEquipped(inst, data.weapon)
                                and data.weapon.components.parryweapon ~= nil
                                and data.weapon.components.parryweapon:TryParry(inst, attacker, damage, weapon, stimuli)
                                and data.weapon
                                or nil
                        end
                    end
                end
            end
            --V2C: using EventHandler will result in a frame delay, but we want this to trigger
            --     immediately during PerformBufferedAction()
            inst:ListenForEvent("combat_parry", oncombatparry)
            inst:PerformBufferedAction()
            inst:RemoveEventCallback("combat_parry", oncombatparry)
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item.components.parryweapon ~= nil and
                    inst.sg.statemem.item:IsValid() then
                    --This is purely for stategraph animation sfx, can actually be bypassed!
                    inst.sg.statemem.item.components.parryweapon:OnPreParry(inst)
                end
            end),
        },

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
                inst.sg:GoToState(GetUnequipState(inst, data))
            end),
        },

        ontimeout = function(inst)
            if inst.sg:HasStateTag("parrying") then
                inst.sg.statemem.parrying = true
                --Transfer talk task to parry_idle state
                local talktask = inst.sg.statemem.talktask
                inst.sg.statemem.talktask = nil
                inst.sg:GoToState("parry_idle", { duration = inst.sg.statemem.parrytime, pauseframes = 30, talktask = talktask, isshield = inst.sg.statemem.isshield })
            else
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
			CancelTalk_Override(inst)
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "parry_idle",
        tags = { "notalking", "parrying", "nomorph" },

        onenter = function(inst, data)
            inst.sg.statemem.isshield = data ~= nil and data.isshield

            inst.components.locomotor:Stop()

            if data ~= nil and data.duration ~= nil then
                if data.duration > 0 then
                    inst.sg.statemem.task = inst:DoTaskInTime(data.duration, function(inst)
                        inst.sg.statemem.task = nil
                        inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
                        inst.sg:GoToState("idle", true)
                    end)
                else
                    inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_pst"  or "parry_pst")
                    inst.sg:GoToState("idle", true)
                    return
                end
            end

            if not inst.AnimState:IsCurrentAnimation("parry_loop") then
                inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparry_loop" or "parry_loop", true)
            end

            --Transferred over from parry_pre so it doesn't cut off abrubtly
            inst.sg.statemem.talktask = data ~= nil and data.talktask or nil

            if data ~= nil and (data.pauseframes or 0) > 0 then
                inst.sg:AddStateTag("busy")
                inst.sg:AddStateTag("pausepredict")

                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction(data.pauseframes <= 7 and data.pauseframes or nil)
                end
                inst.sg:SetTimeout(data.pauseframes * FRAMES)
            else
                inst.sg:AddStateTag("idle")
            end
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.sg:RemoveStateTag("pausepredict")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("unequip", function(inst, data)
                if not inst.sg:HasStateTag("idle") then
                    -- We need to handle this because the default unequip
                    -- handler is ignored while we are in a "busy" state.
                    inst.sg:GoToState(GetUnequipState(inst, data))
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.task ~= nil then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil
            end
			CancelTalk_Override(inst)
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "parry_hit",
        tags = { "parrying", "parryhit", "nomorph", "busy", "nopredict" },

        onenter = function(inst, data)
            inst.sg.statemem.isshield = data ~= nil and data.isshield

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparryblock" or "parryblock")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")

            local stun_frames = data ~= nil and data.pushing and 6 or 4
            if data ~= nil and data.timeleft ~= nil then
                inst.sg.statemem.timeleft0 = GetTime()
                inst.sg.statemem.timeleft = data.timeleft
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        events =
        {
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
                inst.sg.statemem.unequipped = true
            end),
        },

        ontimeout = function(inst)
            if inst.sg.statemem.unequipped then
                inst.sg:GoToState("idle")
            else
                inst.sg.statemem.parrying = true
                inst.sg:GoToState("parry_idle",
                    inst.sg.statemem.timeleft ~= nil and { duration = math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime()), isshield = inst.sg.statemem.isshield }
                    or inst.sg.statemem.isshield and { isshield = inst.sg.statemem.isshield }
                    or nil
                )
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "parry_knockback",
        tags = { "parrying", "parryhit", "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            inst.sg.statemem.isshield = data ~= nil and data.isshield

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation(inst.sg.statemem.isshield and "shieldparryblock" or "parryblock")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")

            if data ~= nil then
                if data.timeleft ~= nil then
                    inst.sg.statemem.timeleft0 = GetTime()
                    inst.sg.statemem.timeleft = data.timeleft
                end
                data = data.knockbackdata
                if data ~= nil and data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 12 * k
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end

            inst.sg:SetTimeout(6 * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = .75 * inst.sg.statemem.speed
                inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
            end
        end,

        events =
        {
            EventHandler("unequip", function(inst, data)
                -- We need to handle this because the default unequip
                -- handler is ignored while we are in a "busy" state.
                inst.sg.statemem.unequipped = true
            end),
        },

        ontimeout = function(inst)
            if inst.sg.statemem.unequipped then
                inst.sg:GoToState("idle")
            else
                inst.sg.statemem.parrying = true
                inst.sg:GoToState("parry_idle",
                    inst.sg.statemem.timeleft ~= nil and { duration = math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime()), isshield = inst.sg.statemem.isshield }
                    or inst.sg.statemem.isshield and { isshield = inst.sg.statemem.isshield }
                    or nil
                )
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "terraform",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
            inst.AnimState:PushAnimation("shovel_loop", false)
        end,

        timeline =
        {
            TimeEvent(25 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("busy")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "dig_start",
        tags = { "predig", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("shovel_pre")
			inst:AddTag("predig")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.digging = true
                    inst.sg:GoToState("dig")
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.digging then
				inst:RemoveTag("predig")
			end
		end,
    },

    State{
        name = "dig",
        tags = { "predig", "digging", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
            inst.sg.statemem.action = inst:GetBufferedAction()
			inst:AddTag("predig")
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("predig")
				inst:RemoveTag("predig")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
				inst:PerformBufferedAction()
            end),

            TimeEvent(35 * FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                    inst.components.playercontroller:IsAnyOfControlsPressed(
                        CONTROL_SECONDARY,
                        CONTROL_ACTION,
                        CONTROL_CONTROLLER_ACTION) and
                    inst.sg.statemem.action ~= nil and
                    inst.sg.statemem.action:IsValid() and
                    inst.sg.statemem.action.target ~= nil and
                    inst.sg.statemem.action.target.components.workable ~= nil and
                    inst.sg.statemem.action.target.components.workable:CanBeWorked() and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and
                    CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
					--No fast-forward when repeat initiated on server
					inst.sg.statemem.action.options.no_predict_fastforward = true
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.AnimState:PlayAnimation("shovel_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

		onexit = function(inst)
			inst:RemoveTag("predig")
		end,
    },

    State{
        name = "bugnet_start",
        tags = { "prenet", "working", "autopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bugnet_pre")
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
        tags = { "prenet", "netting", "working", "autopredict" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bugnet")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bugnet", nil, nil, true)
        end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                local buffaction = inst:GetBufferedAction()
                local tool = buffaction ~= nil and buffaction.invobject or nil
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("prenet")
                inst.SoundEmitter:PlaySound(tool ~= nil and tool.overridebugnetsound or "dontstarve/wilson/dig")
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
        name = "fishing_ocean_pre",
        onenter = function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "fishing_pre",
        tags = { "prefish", "fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre")
            inst.AnimState:PushAnimation("fishing_cast", false)
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast") end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")
                    inst.sg:GoToState("fishing")
                end
            end),
        },
    },

    State{
        name = "fishing",
        tags = { "fishing" },

        onenter = function(inst, pushanim)
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("fishing_idle", true)
            else
                inst.AnimState:PlayAnimation("fishing_idle", true)
            end
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:WaitForFish()
            end
        end,

        events =
        {
            EventHandler("fishingnibble", function(inst) inst.sg:GoToState("fishing_nibble") end),
        },
    },

    State{
        name = "fishing_pst",

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pst")
        end,

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
        name = "fishing_nibble",
        tags = { "fishing", "nibble" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bite_light_pre")
            inst.AnimState:PushAnimation("bite_light_loop", true)
            inst.sg:SetTimeout(1 + math.random())
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("fishing", "bite_light_pst")
        end,

        events =
        {
            EventHandler("fishingstrain", function(inst) inst.sg:GoToState("fishing_strain") end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
        end,
    },

    State{
        name = "fishing_strain",
        tags = { "fishing" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bite_heavy_pre")
            inst.AnimState:PushAnimation("bite_heavy_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_strain", "strain")
        end,

        events =
        {
            EventHandler("fishingcatch", function(inst, data)
                inst.sg:GoToState("catchfish", data.build)
            end),
            EventHandler("fishingloserod", function(inst)
                inst.sg:GoToState("loserod")
            end),

        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
            inst.SoundEmitter:KillSound("strain")
        end,
    },

    State{
        name = "catchfish",
        tags = { "fishing", "catchfish", "busy" },

        onenter = function(inst, build)
            inst.AnimState:PlayAnimation("fish_catch")
            --print("Using ", build, " to swap out fish01")
            inst.AnimState:OverrideSymbol("fish01", build, "fish01")

            -- inst.AnimState:OverrideSymbol("fish_body", build, "fish_body")
            -- inst.AnimState:OverrideSymbol("fish_eye", build, "fish_eye")
            -- inst.AnimState:OverrideSymbol("fish_fin", build, "fish_fin")
            -- inst.AnimState:OverrideSymbol("fish_head", build, "fish_head")
            -- inst.AnimState:OverrideSymbol("fish_mouth", build, "fish_mouth")
            -- inst.AnimState:OverrideSymbol("fish_tail", build, "fish_tail")
        end,

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught") end),
            TimeEvent(10*FRAMES, function(inst) inst.sg:RemoveStateTag("fishing") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland") end),
            TimeEvent(24*FRAMES, function(inst)
                local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equippedTool and equippedTool.components.fishingrod then
                    equippedTool.components.fishingrod:Collect()
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

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
            -- inst.AnimState:ClearOverrideSymbol("fish_body")
            -- inst.AnimState:ClearOverrideSymbol("fish_eye")
            -- inst.AnimState:ClearOverrideSymbol("fish_fin")
            -- inst.AnimState:ClearOverrideSymbol("fish_head")
            -- inst.AnimState:ClearOverrideSymbol("fish_mouth")
            -- inst.AnimState:ClearOverrideSymbol("fish_tail")
        end,
    },

    State{
        name = "loserod",
        tags = { "busy", "nopredict" },

        onenter = function(inst)
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:Release()
                equippedTool:Remove()
            end
            inst.AnimState:PlayAnimation("fish_nocatch")
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_lostrod") end),
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
        name = "eat",
		tags = { "busy", "nodangle", "keep_pocket_rummage" },

        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()

            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction()
                end
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end

            if feed == nil or
                feed.components.edible == nil or
                feed.components.edible.foodtype ~= FOODTYPE.GEARS then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            end

            if feed ~= nil and feed.components.soul ~= nil then
                inst.sg.statemem.soulfx = SpawnPrefab("wortox_eat_soul_fx")
                inst.sg.statemem.soulfx.entity:SetParent(inst.entity)
                if inst.components.rider:IsRiding() then
                    inst.sg.statemem.soulfx:MakeMounted()
                end
            end

            if inst.components.inventory:IsHeavyLifting() and
                not inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("heavy_eat")
            else
                inst.AnimState:PlayAnimation("eat_pre")
                inst.AnimState:PushAnimation("eat", false)
            end

            inst.components.hunger:Pause()
        end,

        timeline =
        {
            TimeEvent(28 * FRAMES, function(inst)
                if inst.sg.statemem.feed == nil then
                    inst:PerformBufferedAction()
                elseif inst.sg.statemem.feed.components.soul == nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                elseif inst.components.souleater ~= nil then
                    inst.components.souleater:EatSoul(inst.sg.statemem.feed)
                end
				--NOTE: "queue_post_eat_state" can be triggered immediately from the eat action
            end),

            TimeEvent(30 * FRAMES, function(inst)
				if inst.sg.statemem.queued_post_eat_state == nil then
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("pausepredict")
				end
            end),
			FrameEvent(52, function(inst)
				if inst.sg.statemem.queued_post_eat_state ~= nil then
					inst.sg:GoToState(inst.sg.statemem.queued_post_eat_state)
				end
			end),
            TimeEvent(70 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eating")
            end),
			FrameEvent(94, TryResumePocketRummage),
        },

        events =
        {
			EventHandler("queue_post_eat_state", function(inst, data)
				--NOTE: this event can trigger instantly instead of buffered
				if data ~= nil then
					inst.sg.statemem.queued_post_eat_state = data.post_eat_state
					if data.nointerrupt then
						inst.sg:AddStateTag("nointerrupt")
					end
				end
			end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.queued_post_eat_state or "idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            if not GetGameModeProperty("no_hunger") then
                inst.components.hunger:Resume()
            end
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
            if inst.sg.statemem.soulfx ~= nil then
                inst.sg.statemem.soulfx:Remove()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        name = "quickeat",
		tags = { "busy", "keep_pocket_rummage" },

        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()

            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction()
                end
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end

            if feed == nil or
                feed.components.edible == nil or
                feed.components.edible.foodtype ~= FOODTYPE.GEARS then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
            end

            if inst.components.inventory:IsHeavyLifting() and
                not inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("heavy_quick_eat")
            else
                inst.AnimState:PlayAnimation("quick_eat_pre")
                inst.AnimState:PushAnimation("quick_eat", false)
            end

            inst.components.hunger:Pause()
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.feed ~= nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                else
                    inst:PerformBufferedAction()
                end
				--NOTE: "queue_post_eat_state" can be triggered immediately from the eat action
				if inst.sg.statemem.queued_post_eat_state == nil then
					inst.sg:RemoveStateTag("busy")
					inst.sg:RemoveStateTag("pausepredict")
				end
            end),
			FrameEvent(21, function(inst)
				if inst.sg.statemem.queued_post_eat_state ~= nil then
					inst.sg:GoToState(inst.sg.statemem.queued_post_eat_state)
				else
					TryResumePocketRummage(inst)
				end
			end),
        },

        events =
        {
			EventHandler("queue_post_eat_state", function(inst, data)
				--NOTE: this event can trigger instantly instead of buffered
				if data ~= nil then
					inst.sg.statemem.queued_post_eat_state = data.post_eat_state
					if data.nointerrupt then
						inst.sg:AddStateTag("nointerrupt")
					end
				end
			end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.sg.statemem.queued_post_eat_state or "idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("eating")
            if not GetGameModeProperty("no_hunger") then
                inst.components.hunger:Resume()
            end
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        name = "refuseeat",
		tags = { "busy", "pausepredict", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            if inst.components.rider:IsRiding() then
                DoTalkSound(inst)
                inst.AnimState:PlayAnimation("dial_loop")
            else
                DoTalkSound(inst)
                inst.AnimState:PlayAnimation(inst.components.inventory:IsHeavyLifting() and "heavy_refuseeat" or "refuseeat")
				inst.sg:SetTimeout(60 * FRAMES)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
			FrameEvent(74, TryResumePocketRummage),
        },

		ontimeout = StopTalkSound,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			StopTalkSound(inst)
			CheckPocketRummageMem(inst)
		end,
    },

    State{
        name = "opengift",
        tags = { "busy", "pausepredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            local failstr =
                (inst.IsNearDanger(inst) and "ANNOUNCE_NODANGERGIFT") or
                (inst.components.rider:IsRiding() and "ANNOUNCE_NOMOUNTEDGIFT") or
                nil

            if failstr ~= nil then
                inst.sg.statemem.isfailed = true
                inst.sg:GoToState("idle")
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, failstr))
                end
                return
            end

            ForceStopHeavyLifting(inst)

            inst.SoundEmitter:PlaySound("dontstarve/common/player_receives_gift")
            inst.AnimState:PlayAnimation("gift_pre")
            inst.AnimState:PushAnimation("giift_loop", true)
            -- NOTE: the previously used ripping paper anim is called "giift_loop"

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            inst:ShowActions(false)
            inst:ShowPopUp(POPUPS.GIFTITEM, true)

            if inst.components.giftreceiver ~= nil then
                inst.components.giftreceiver:OnStartOpenGift()
            end
        end,

        timeline =
        {
            -- Timing of the gift box opening animation on giftitempopup.lua
            TimeEvent(155 * FRAMES, function(inst)
                inst.AnimState:PlayAnimation("gift_open_pre")
                inst.AnimState:PushAnimation("gift_open_loop", true)
            end),
        },

        events =
        {
            EventHandler("firedamage", function(inst)
                inst.AnimState:PlayAnimation("gift_open_pst")
                inst.sg:GoToState("idle", true)
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_NODANGERGIFT"))
                end
            end),
            EventHandler("ms_doneopengift", function(inst, data)
                if data.wardrobe == nil or
                    data.wardrobe.components.wardrobe == nil or
                    not (data.wardrobe.components.wardrobe:CanBeginChanging(inst) and
                        CanEntitySeeTarget(inst, data.wardrobe) and
                        data.wardrobe.components.wardrobe:BeginChanging(inst)) then
                    inst.AnimState:PlayAnimation("gift_open_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isfailed then
                return
            elseif not inst.sg.statemem.isopeningwardrobe then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
                inst:ShowActions(true)
            end
            inst:ShowPopUp(POPUPS.GIFTITEM, false)
        end,
    },

    State{
        name = "usewardrobe",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "openwardrobe",
        tags = { "inwardrobe", "busy", "pausepredict" },

        onenter = function(inst, data)
            inst.sg.statemem.isopeninggift = data.openinggift
            if not inst.sg.statemem.isopeninggift then
                inst.components.locomotor:Stop()
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()

                inst.AnimState:PlayAnimation("idle_wardrobe1_pre")
                inst.AnimState:PushAnimation("idle_wardrobe1_loop", true)

                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction()
                    inst.components.playercontroller:EnableMapControls(false)
                    inst.components.playercontroller:Enable(false)
                end
                inst.components.inventory:Hide()
                inst:PushEvent("ms_closepopups")
                inst:ShowActions(false)
            elseif inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            if data.target and data.target.components.groomer then
                assert(data.target.components.groomer.occupant,"Grooming station had not occupant")
                inst:ShowPopUp(POPUPS.GROOMER, true, data.target.components.groomer.occupant, inst)
            else
                inst:ShowPopUp(POPUPS.WARDROBE, true, data.target)
            end
        end,

        events =
        {
            EventHandler("firedamage", function(inst)
                if inst.sg.statemem.isopeninggift then
                    inst.AnimState:PlayAnimation("gift_open_pst")
                    inst.sg:GoToState("idle", true)
                else
                    inst.sg:GoToState("idle")
                end
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_NOWARDROBEONFIRE"))
                end
            end),
        },

        onexit = function(inst)
            inst:ShowPopUp(POPUPS.GROOMER, false)
            inst:ShowPopUp(POPUPS.WARDROBE, false)
            if not inst.sg.statemem.ischanging then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
                inst:ShowActions(true)
                if not inst.sg.statemem.isclosingwardrobe then
                    inst.sg.statemem.isclosingwardrobe = true
                    POPUPS.WARDROBE:Close(inst)
                end
            end
        end,
    },

    State{
        name = "changeinwardrobe",
        tags = { "inwardrobe", "busy", "nopredict", "silentmorph" },

        onenter = function(inst, delay)
            --This state is only valid as a substate of openwardrobe
            inst:Hide()
            inst.DynamicShadow:Enable(false)
            inst.sg.statemem.isplayerhidden = true

            inst.sg:SetTimeout(delay)
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("jumpout_wardrobe")
            inst:Show()
            inst.DynamicShadow:Enable(true)
            inst.sg.statemem.isplayerhidden = nil
            inst.sg.statemem.task = inst:DoTaskInTime(4.5 * FRAMES, function()
                inst.sg.statemem.task = nil
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.isplayerhidden and inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.task ~= nil then
                inst.sg.statemem.task:Cancel()
                inst.sg.statemem.task = nil
            end
            if inst.sg.statemem.isplayerhidden then
                inst:Show()
                inst.DynamicShadow:Enable(true)
                inst.sg.statemem.isplayerhidden = nil
            end
            --Cleanup from openwardobe state
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.components.inventory:Show()
            inst:ShowActions(true)
            if not inst.sg.statemem.isclosingwardrobe then
                inst.sg.statemem.isclosingwardrobe = true
                POPUPS.WARDROBE:Close(inst)
            end
        end,
    },

    State{
        name = "changeoutsidewardrobe",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst, cb)
            inst.sg.statemem.cb = cb

            --This state is only valid as a substate of openwardrobe
            inst.AnimState:OverrideSymbol("shadow_hands", "shadow_skinchangefx", "shadow_hands")
            inst.AnimState:OverrideSymbol("shadow_ball", "shadow_skinchangefx", "shadow_ball")
            inst.AnimState:OverrideSymbol("splode", "shadow_skinchangefx", "splode")

            inst.AnimState:PlayAnimation("gift_pst", false)
            inst.AnimState:PushAnimation("skin_change", false)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            -- gift_pst plays first and it is 20 frames long
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/skin_change")
            end),
            -- frame 42 of skin_change is where the character is completely hidden
            TimeEvent(62 * FRAMES, function(inst)
                if inst.sg.statemem.cb ~= nil then
                    inst.sg.statemem.cb()
                    inst.sg.statemem.cb = nil
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.cb ~= nil then
                -- in case of interruption
                inst.sg.statemem.cb()
                inst.sg.statemem.cb = nil
            end
            inst.AnimState:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")
            --Cleanup from openwardobe state
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.components.inventory:Show()
            inst:ShowActions(true)
            if not inst.sg.statemem.isclosingwardrobe then
                inst.sg.statemem.isclosingwardrobe = true
                POPUPS.WARDROBE:Close(inst)
            end
        end,
    },

    State{
        name = "dressupwardrobe",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst, cb)
            inst.sg.statemem.cb = cb
            inst.sg:SetTimeout(1)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
            if inst.sg.statemem.cb ~= nil then
                inst.sg.statemem.cb()
                inst.sg.statemem.cb = nil
            end
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
			inst.SoundEmitter:KillSound("make")
            if inst.sg.statemem.cb ~= nil then
                -- in case of interruption
                inst.sg.statemem.cb()
                inst.sg.statemem.cb = nil
            end
            --Cleanup from openwardobe state
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.components.inventory:Show()
            inst:ShowActions(true)
            if not inst.sg.statemem.isclosingwardrobe then
                inst.sg.statemem.isclosingwardrobe = true
                POPUPS.WARDROBE:Close(inst)
            end
        end,
    },

    State{
        name = "cookbook_open",
		tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:OverrideSymbol("book_cook", "cookbook", "book_cook")
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("reading_in", false)
            inst.AnimState:PushAnimation("reading_loop", true)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

		onupdate = function(inst)
			if not CanEntitySeeTarget(inst, inst) then
                inst.sg:GoToState("cookbook_close")
			end
		end,

        events =
        {
            EventHandler("ms_closepopup", function(inst, data)
                if data.popup == POPUPS.COOKBOOK then
                    inst.sg:GoToState("cookbook_close")
                end
            end),
        },

        onexit = function(inst)
		    inst:ShowPopUp(POPUPS.COOKBOOK, false)
        end,
    },

    State{
        name = "cookbook_close",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("reading_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                end
            end),
        },
    },

    State{
        name = "plantregistry_open",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

		onupdate = function(inst)
			if not CanEntitySeeTarget(inst, inst) then
                inst.sg:GoToState("plantregistry_close")
			end
		end,

        events =
        {
            EventHandler("ms_closepopup", function(inst, data)
                if data.popup == POPUPS.PLANTREGISTRY then
                    inst.sg:GoToState("plantregistry_close")
                end
            end),
        },

        onexit = function(inst)
		    inst:ShowPopUp(POPUPS.PLANTREGISTRY, false)
        end,
    },

    State{
        name = "plantregistry_close",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
        end,
    },

    State{
        name = "inspectacles_open",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.sg:GoToState("inspectacles_close")
            end
        end,

        events =
        {
            EventHandler("ms_closepopup", function(inst, data)
                if data.popup == POPUPS.INSPECTACLES then
                    inst.sg:GoToState("inspectacles_close")
                end
            end),
            EventHandler("unequip", function(inst, data)
                if data and data.item ~= nil and data.item.prefab == "inspectacleshat" then
                    inst.sg:GoToState("inspectacles_close")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst:ShowPopUp(POPUPS.INSPECTACLES, false)
        end,
    },

    State{
        name = "inspectacles_close",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("build_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                end
            end),
        },
    },

    State{
        name = "charlieresidue_open",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.sg:GoToState("charlieresidue_close")
            end
        end,

        events =
        {
            EventHandler("ms_closepopup", function(inst, data)
                if data.popup == POPUPS.INSPECTACLES then
                    inst.sg:GoToState("charlieresidue_close")
                end
            end),
            EventHandler("unequip", function(inst, data)
                if data and data.item ~= nil and data.item.prefab == "roseglasseshat" then
                    inst.sg:GoToState("charlieresidue_close")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            --inst:ShowPopUp(POPUPS.INSPECTACLES, false)
        end,
    },

    State{
        name = "charlieresidue_close",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("build_pst")

            --inst.components.activatable.inactive = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                end
            end),
        },
    },

    State{
        name = "talk",
        tags = { "idle", "talking" },

        onenter = function(inst, noanim)
            if not noanim then
                inst.AnimState:PlayAnimation(
					(inst.components.inventory:IsHeavyLifting() and not inst.components.rider:IsRiding() and "heavy_dial_loop") or
					(inst:IsChannelCasting() and (
						inst:IsChannelCastingItem() and "channelcast_idle_dial_loop" or "channelcast_oh_idle_dial_loop"
					)) or
                    "dial_loop",
                    true)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "mime",
        tags = { "idle", "talking" },

		onenter = function(inst)
            DoMimeAnimations(inst)
            DoTalkSound(inst)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = StopTalkSound,
    },

	State{
		name = "closeinspect",
		tags = { "idle", "talking" },

		onenter = function(inst, silent)
			inst.AnimState:PlayAnimation("closeinspect_pre")
			inst.AnimState:PushAnimation("closeinspect_loop")
			if not silent then
				DoTalkSound(inst)
			end
			inst.sg:SetTimeout(2)
		end,

		ontimeout = function(inst)
			inst.AnimState:PlayAnimation("closeinspect_pst")
			inst.sg:GoToState("idle", true)
		end,

		events =
		{
			EventHandler("donetalking", StopTalkSound),
		},

		onexit = StopTalkSound,
	},

    -- Same as above, but intended for use during stageplays, so it eschews the "idle" tag,
    -- and goes to "acting_idle" when it finishes instead.
    State{
        name = "acting_mime",
        tags = {"forcedangle", "acting", "talking", "mime"},
        onenter = function(inst)
            DoMimeAnimations(inst)
            DoTalkSound(inst)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("acting_idle")
                end
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "singsong",
        tags = { "idle", "notalking" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation(
                inst.components.inventory:IsHeavyLifting() and
                not inst.components.rider:IsRiding() and
                "heavy_dial_loop" or
                "dial_loop",
                true)

			inst.SoundEmitter:PlaySound(data.sound, "singsong")
			inst.components.talker:Say(data.lines, nil, true, true)
        end,

        events =
        {
            EventHandler("ontalk", function(inst)
				inst.sg.statemem.started = true -- to prevent the delayed "donetalking" event from a previous talk from cancelling the story
			end),
            EventHandler("donetalking", function(inst)
				if inst.sg.statemem.started then
					inst.sg:GoToState("idle", true)
				end
            end),
        },

        onexit = function(inst)
			inst.SoundEmitter:KillSound("singsong")
			if not inst.sg.statemem.not_interrupted then
				StopTalkSound(inst, true)
				if inst.components.talker ~= nil then
					inst.components.talker:ShutUp()
				end
			end
        end,
    },

    State{
        name = "unsaddle",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("unsaddle_pre")
            inst.AnimState:PushAnimation("unsaddle", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(21 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "heavylifting_start",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("heavy_pickup_pst")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

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
		name = "heavylifting_mount_start",
		tags = { "busy", "nomorph", "pausepredict" },

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst:ClearBufferedAction()

			local mount = inst.components.rider:GetMount()
			inst.sg.statemem.ridingwoby = mount ~= nil and mount:HasTag("woby")

			inst.AnimState:PlayAnimation("heavy_mount")

			if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:RemotePausePrediction()
			end
		end,

		timeline =
		{
			TimeEvent(12 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
			end),
			TimeEvent(14 * FRAMES, function(inst)
				if inst.sg.statemem.ridingwoby then
					inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark")
				end
			end),
			TimeEvent(38 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
			end),
			TimeEvent(39 * FRAMES, function(inst)
				inst.sg:GoToState("mounted_idle", true)
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("mounted_idle")
				end
			end),
		},
	},

    State{
        name = "heavylifting_stop",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("pickup")
            inst.AnimState:PushAnimation("pickup_pst", false)

            local stun_frames = 6
            if inst.components.playercontroller ~= nil then
                --Specify min frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(stun_frames)
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "heavylifting_item_hat",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)

            if inst.components.playercontroller ~= nil then
                --12 frames is too long for specifying min frames
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(12 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "heavylifting_drop",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("heavy_item_hat")
            inst.AnimState:PushAnimation("heavy_item_hat_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(12 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dostandingaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --give_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doequippedaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give_equipped")
            inst.AnimState:PushAnimation("give_equipped_pst", false)

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(14 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            --give_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doshortaction",
		tags = { "doing", "busy", "keepchannelcasting" },

        onenter = function(inst, silent)
            inst.components.locomotor:Stop()
            if inst:HasTag("beaver") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            else
                inst.AnimState:PlayAnimation("pickup")
                inst.AnimState:PushAnimation("pickup_pst", false)
            end

            inst.sg.statemem.action = inst.bufferedaction
            inst.sg.statemem.silent = silent
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                if inst.sg.statemem.silent then
                    inst.components.talker:IgnoreAll("silentpickup")
                    inst:PerformBufferedAction()
                    inst.components.talker:StopIgnoringAll("silentpickup")
                else
                    inst:PerformBufferedAction()
                end
            end),
        },

        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dosilentshortaction",
		tags = { "keepchannelcasting" },

        onenter = function(inst)
            inst.sg:GoToState("doshortaction", true)
        end,
    },

    State{
        name = "dohungrybuild",

        onenter = function(inst)
            local slow = inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH
            if not (slow or inst:HasTag("fastbuilder")) then
                inst.sg.mem.lasthungrybuildtalk = nil
                inst.sg:GoToState("dolongaction")
            else
                if inst.components.talker ~= nil then
                    local t = GetTime()
                    if slow then
                        inst.sg.mem.hungryfastbuildtalktime = nil
                        if (inst.sg.mem.hungryslowbuildtalktime or 0) < t then
                            inst.sg.mem.hungryslowbuildtalktime = t + GetRandomMinMax(4, 8)
                            inst.components.talker:Say(GetString(inst, "ANNOUNCE_HUNGRY_SLOWBUILD"))
                        end
                    elseif inst.sg.mem.dohungryfastbuildtalk then
                        inst.sg.mem.hungryslowbuildtalktime = nil
                        if inst.sg.mem.hungryfastbuildtalktime == nil or inst.sg.mem.hungryfastbuildtalktime + 10 < t then
                            inst.sg.mem.hungryfastbuildtalktime = t + GetRandomMinMax(4, 6)
                        elseif inst.sg.mem.hungryfastbuildtalktime < t then
                            inst.sg.mem.hungryfastbuildtalktime = nil
                            inst.components.talker:Say(GetString(inst, "ANNOUNCE_HUNGRY_FASTBUILD"))
                        end
                    end
                end
                inst.sg:GoToState("dolongaction", slow and 2 or .5)
            end
        end,
    },

    State{
        name = "domediumaction",

        onenter = function(inst)
            inst.sg:GoToState("dolongaction", .5)
        end,
    },

    State{
        name = "dowoodiefastpick",

        onenter = function(inst)
            local skill_level = inst.components.skilltreeupdater:CountSkillTag("quickpicker")
            local timeout = skill_level > 0 and TUNING.SKILLS.WOODIE.QUICKPICK_TIMEOUT[skill_level] or 1

            inst.sg:GoToState("dolongaction", timeout)
        end,
    },

    State{
        name = "revivecorpse",

        onenter = function(inst)
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_REVIVING_CORPSE"))
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            inst.sg:GoToState("dolongaction",
                TUNING.REVIVE_CORPSE_ACTION_TIME *
                (inst.components.corpsereviver ~= nil and inst.components.corpsereviver:GetReviverSpeedMult(target) or 1) *
                (target ~= nil and target.components.revivablecorpse ~= nil and target.components.revivablecorpse:GetReviveSpeedMult(inst) or 1)
            )
        end,
    },

    State{
        name = "dolongestaction",
        onenter = function(inst)
            inst.sg:GoToState("dolongaction", TUNING.LONGEST_ACTION_TIMEOUT)
        end,
    },

    State{
        name = "use_dumbbell_pre",
        tags = { "doing", "nodangle", "lifting_dumbbell" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:PerformBufferedAction()

            local dumbbell = inst.components.dumbbelllifter.dumbbell
            inst.AnimState:OverrideSymbol("swap_dumbbell", dumbbell.swap_dumbbell, dumbbell.swap_dumbbell)

            if inst.components.mightiness then
                local state = inst.components.mightiness:GetState()
                local pre_anim = "dumbbell_skinny_pre"

                if state == "normal" then
                    pre_anim = "dumbbell_normal_pre"
                elseif state == "mighty" then
                    pre_anim = "dumbbell_mighty_pre"
                end

                inst.AnimState:PlayAnimation(pre_anim)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.dumbbell_anim_done then
                inst.components.mightiness:Resume()
                inst.components.dumbbelllifter:StopLifting()
            end
        end,

        timeline = {
            TimeEvent(FRAMES * 10, function(inst)
                if inst.components.mightiness then
                    local state = inst.components.mightiness:GetState()
                    if state == "wimpy" or state == "normal" then
                        inst.SoundEmitter:PlaySound("wolfgang2/characters/wolfgang/grunt")
                    end
                end
            end),
        },

        events =
        {
            EventHandler("stopliftingdumbbell", function(inst)
                inst.sg.statemem.queue_stop = true
            end),

            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.dumbbell_anim_done = true

                    if inst.sg.statemem.queue_stop then
                        inst.sg:GoToState("use_dumbbell_pst")
                    else
                        inst.sg:GoToState("use_dumbbell_loop")
                    end
                end
            end),
        },
    },

    State{
        name = "use_dumbbell_loop",
        tags = { "doing", "nodangle", "lifting_dumbbell" },

        onenter = function(inst)
            if inst.components.mightiness then
                local state = inst.components.mightiness:GetState()
                local loop_anim = "dumbbell_skinny_loop"

                if state == "normal" then
                    loop_anim = "dumbbell_normal_loop"
                elseif state == "mighty" then
                    loop_anim = "dumbbell_mighty_loop"
                end

                inst.AnimState:PlayAnimation(loop_anim)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.dumbbell_anim_done then
                inst.components.dumbbelllifter:StopLifting()
            end
        end,

        timeline = {

            TimeEvent(FRAMES * 7, function(inst)
                if inst.components.mightiness then
                    local state = inst.components.mightiness:GetState()

                    if state == "mighty" then
                        inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/twirl")
                    end
                end
            end),


            TimeEvent(FRAMES * 3, function(inst)
                if inst.components.mightiness then
                    local state = inst.components.mightiness:GetState()

                    if state == "mighty" then
                        inst.SoundEmitter:PlaySound("wolfgang2/characters/wolfgang/grunt")
                    end
                end
            end),

            TimeEvent(FRAMES * 12, function(inst)
                if inst.components.mightiness then
                    local state = inst.components.mightiness:GetState()
                    if state == "wimpy" or state == "normal" then
                        inst.SoundEmitter:PlaySound("wolfgang2/characters/wolfgang/grunt")
                    end
                end
            end),
        },

        events =
        {
            EventHandler("stopliftingdumbbell", function(inst, data)
                if data and data.instant then
                    inst.sg:GoToState("idle")
                else
                    inst.sg.statemem.queue_stop = true
                end
            end),

            EventHandler("animover", function(inst)
                inst.sg.statemem.dumbbell_anim_done = true

                if inst.sg.statemem.queue_stop or
                   inst.components.dumbbelllifter.dumbbell == nil then
                    inst.sg:GoToState("use_dumbbell_pst")
                elseif inst.components.dumbbelllifter:Lift() and inst.components.mightiness:GetPercent() < 1 then
                    inst.sg:GoToState("use_dumbbell_loop")
                else
                    inst.sg:GoToState("use_dumbbell_pst")
                end
            end),
        },
    },

    State{
        name = "use_dumbbell_pst",
        tags = { "doing", "nodangle", "lifting_dumbbell" },

        onenter = function(inst)
            if inst.components.mightiness then
                inst.sg.statemem.mightiness = inst.components.mightiness:GetState()
                local pst_anim = "dumbbell_skinny_pst"

                if inst.sg.statemem.mightiness == "normal" then
                    pst_anim = "dumbbell_normal_pst"
                elseif inst.sg.statemem.mightiness == "mighty" then
                    pst_anim = "dumbbell_mighty_pst"
                end

                inst.AnimState:PlayAnimation(pst_anim)
            end
        end,

        timeline = {
            TimeEvent(FRAMES * 1, function(inst)
                if inst.components.mightiness then
                    if inst.sg.statemem.mightiness == "wimpy" then
                        inst.SoundEmitter:PlaySound("wolfgang2/characters/wolfgang/grunt")
                    end
                end
            end),

            TimeEvent(FRAMES * 10, function(inst)
                if inst.components.mightiness then
                    if inst.sg.statemem.mightiness == "wimpy" then
                        inst.SoundEmitter:PlaySound("wolfgang2/common/dumbel_drop")
                    end
                end
            end),
        },


        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.components.dumbbelllifter:StopLifting()
            inst.components.mightiness:Resume()
            inst.AnimState:ClearOverrideSymbol("swap_dumbbell")
        end,
    },

    State{
        name = "dolongaction",
		tags = { "doing", "busy", "nodangle", "keep_pocket_rummage" },

        onenter = function(inst, timeout)
            if timeout == nil then
                timeout = 1
            elseif timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.action.actionmeter then
                    inst.sg.statemem.actionmeter = true
                    StartActionMeter(inst, timeout)
                end
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                    inst.bufferedaction.target:PushEvent("startlongaction", inst)
                end
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
            if inst.sg.statemem.actionmeter then
                inst.sg.statemem.actionmeter = nil
                StopActionMeter(inst, true)
            end
			inst.sg:RemoveStateTag("busy")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					if not TryResumePocketRummage(inst) then
						inst.sg:GoToState("idle")
					end
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if inst.sg.statemem.actionmeter then
                StopActionMeter(inst, false)
            end
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    State{name = "carvewood_boards", onenter = function(inst) inst.sg:GoToState("carvewood", 1) end},
    State{
        name = "carvewood",
		tags = { "doing", "busy", "nodangle", "keep_pocket_rummage" },

        onenter = function(inst, timeout)
            local timeout = timeout or 1.5
            if timeout > 1 then
                inst.sg:AddStateTag("slowaction")
            end
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("useitem_pre")
			inst.AnimState:PushAnimation("carving_pre")
			inst.AnimState:PushAnimation("carving_loop")
			inst.AnimState:OverrideSymbol("swap_lucy_axe", "swap_lucy_axe", "swap_lucy_axe")
			inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
			FrameEvent(7, function(inst)
				inst.sg:RemoveStateTag("busy")
            end),
			FrameEvent(8, function(inst)
				inst.SoundEmitter:PlaySound("meta2/woodie/carving_lp", "carve")
			end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("carve")
			--inst.AnimState:PlayAnimation("carving_pst")
			--inst.AnimState:PushAnimation("useitem_pst", false)
			inst.AnimState:PlayAnimation("useitem_pst")
			inst.sg:RemoveStateTag("busy")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					if not TryResumePocketRummage(inst) then
						inst.sg:GoToState("idle")
					end
                end
            end),
        },

        onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("swap_lucy_axe")
            inst.SoundEmitter:KillSound("carve")
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        --Alternative to doshortaction but animated with your held tool
        --Animation mirrors attack action, but are not "auto" predicted
        --by clients (also no sound prediction)
        name = "dojostleaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()
            local cooldown
            if inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                DoMountSound(inst, inst.components.rider:GetMount(), "angry")
                cooldown = 16 * FRAMES
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_large")
                cooldown = 17 * FRAMES
			elseif equip ~= nil and equip:HasTag("pocketwatch") then
				inst.AnimState:PlayAnimation("pocketwatch_atk_pre" )
				inst.AnimState:PushAnimation("pocketwatch_atk", false)
				inst.sg.statemem.ispocketwatch = true
				cooldown = 19 * FRAMES
                if equip:HasTag("shadow_item") then
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow")
					inst.AnimState:Show("pocketwatch_weapon_fx")
					inst.sg.statemem.ispocketwatch_fueled = true
                else
                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre")
					inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
            elseif equip ~= nil and equip:HasTag("jab") then
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("spearjab", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                cooldown = 21 * FRAMES
            elseif equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                cooldown = 13 * FRAMES
            elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                cooldown = 13 * FRAMES
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                cooldown = 13 * FRAMES
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
                cooldown = 24 * FRAMES
            end

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target:GetPosition())
            end

            inst.sg.statemem.action = buffaction
            inst.sg:SetTimeout(cooldown)
        end,

        timeline =
        {
			--beaver: frame 6 action
			--whip: frame 10 action
			--other: frame 8 action
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.isbeaver then
					inst.sg:RemoveStateTag("busy")
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
				if not (inst.sg.statemem.iswhip or
						inst.sg.statemem.ispocketwatch or
						inst.sg.statemem.isbeaver) then
					inst.sg:RemoveStateTag("busy")
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.ispocketwatch then
					inst.sg:RemoveStateTag("busy")
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(17*FRAMES, function(inst)
				if inst.sg.statemem.ispocketwatch then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.ispocketwatch_fueled and "wanda2/characters/wanda/watch/weapon/pst_shadow" or "wanda2/characters/wanda/watch/weapon/pst")
                end
            end),
        },

        ontimeout = function(inst)
            --anim pst should still be playing
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "doswipeaction",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")
            inst.AnimState:PushAnimation("atk_prop", false)

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
            inst.sg.statemem.action = buffaction
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            TimeEvent(7 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
                inst:PerformBufferedAction()
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dochannelaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("channel_pre")
            inst.AnimState:PushAnimation("channel_loop", true)
            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(3)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(.7, function(inst)
                if inst.bufferedaction ~= nil and
                    inst.components.talker ~= nil and
                    inst.bufferedaction.target ~= nil and
                    inst.bufferedaction.target:HasTag("moonportal") then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_DESPAWN"))
                end
            end),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
                if not (inst.AnimState:IsCurrentAnimation("channel_dial_loop") or inst:HasTag("mime")) then
                    inst.AnimState:PlayAnimation("channel_dial_loop", true)
                end
				return OnTalk_Override(inst)
            end),
            EventHandler("donetalking", function(inst)
                if not inst.AnimState:IsCurrentAnimation("channel_loop") then
                    inst.AnimState:PlayAnimation("channel_loop", true)
                end
				return OnDoneTalking_Override(inst)
            end),
        },

        ontimeout = function(inst)
            if not inst:PerformBufferedAction() then
                inst.AnimState:PlayAnimation("channel_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			CancelTalk_Override(inst)
        end,
    },

    State{
		--V2C: This is currently used ONLY for heavy pickup while mounted.
        name = "dodismountaction",
		tags = { "doing", "busy", "nomorph", "dismounting" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dismount")
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            end),
			TimeEvent(25 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg:GoToState("idle")
				end
			end),
        },

        onexit = function(inst)
			--V2C: Exepcted to trigger PICKUP action => heavylifting_mount_start
			if not inst.sg.statemem.keepmount then
				inst.components.rider:ActualDismount()
			end
        end,
    },

    State{
        name = "makeballoon",
		tags = { "doing", "busy", "nodangle", "keep_pocket_rummage" },

        onenter = function(inst, timeout)
            inst.sg.statemem.action = inst.bufferedaction
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/common/balloon_make", "make")
            inst.SoundEmitter:PlaySound("dontstarve/common/balloon_blowup")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("build_pst")
			inst.sg:RemoveStateTag("busy")
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					if not TryResumePocketRummage(inst) then
						inst.sg:GoToState("idle")
					end
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        name = "dostorytelling",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.sg.statemem.action = inst.bufferedaction
            inst.components.locomotor:Stop()
	        if not inst:PerformBufferedAction() then
				inst.sg.statemem.not_interrupted = true
				inst.sg:GoToState("idle")
			elseif inst:HasTag("mime") then
				inst.sg.statemem.mime = true
				inst.AnimState:PlayAnimation("mime13")
			else
	            inst.AnimState:PlayAnimation("idle_walter_storytelling_pre")
			end
        end,

        timeline =
        {
			TimeEvent(7 * FRAMES, DoTalkSound),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
				inst.sg.statemem.started = true -- to prevent the delayed "donetalking" event from a previous talk from cancelling the story
			end),
            EventHandler("donetalking", function(inst)
				if inst.sg.statemem.started then
					if inst.sg.statemem.mime then
						inst.sg:GoToState("idle")
					else
						inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
						inst.sg:GoToState("idle", true)
					end
				end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interrupted = true
					inst.sg:GoToState("dostorytelling_loop", inst.sg.statemem.mime)
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			if not inst.sg.statemem.not_interrupted then
				StopTalkSound(inst, true)
				if inst.components.talker ~= nil then
					inst.components.talker:ShutUp()
				end
			end
        end,
    },

    State{
        name = "dostorytelling_loop",
        tags = { "doing", "nodangle" },

		onenter = function(inst, mime)
            inst.components.locomotor:Stop()
			if mime then
				inst.sg.statemem.mime = mime
				DoMimeAnimations(inst)
			else
				inst.AnimState:PushAnimation(math.random() < 0.75 and "idle_walter_storytelling" or "idle_walter_storytelling_2")
			end
        end,

        events =
        {
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interrupted = true
					inst.sg:GoToState("dostorytelling_loop", inst.sg.statemem.mime)
                end
            end),
            EventHandler("donetalking", function(inst)
				inst.sg.statemem.not_interrupted = true
				StopTalkSound(inst)
				if inst.sg.statemem.mime then
					inst.sg:GoToState("idle")
				else
					inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
					inst.sg:GoToState("idle", true)
				end
            end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.not_interrupted then
				StopTalkSound(inst, true)
				if inst.components.talker ~= nil then
					inst.components.talker:ShutUp()
				end
			end
        end,
    },

    State{
        name = "shave",
		tags = { "doing", "busy", "shaving", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local pass = false
            local reason = nil

            if inst.bufferedaction ~= nil and
                inst.bufferedaction.invobject ~= nil and
                inst.bufferedaction.invobject.components.shaver ~= nil then
                local shavee = inst.bufferedaction.target or inst.bufferedaction.doer
                if shavee ~= nil then
                    if shavee.components.beard ~= nil then
                        pass, reason = shavee.components.beard:ShouldTryToShave(inst.bufferedaction.doer, inst.bufferedaction.invobject)
                    elseif shavee.components.shaveable ~= nil then
                        pass, reason = shavee.components.shaveable:CanShave(inst.bufferedaction.doer, inst.bufferedaction.invobject)
                    end
                end
            end

            if not pass then
                inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = reason })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end

            inst.SoundEmitter:PlaySound("dontstarve/wilson/shave_LP", "shave")

            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)

            inst.sg:SetTimeout(1)
        end,

		timeline =
		{
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
			inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("shave")
        end,
    },

    State{
        name = "enter_onemanband",
        tags = { "playing", "idle" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:Stop()

            if pushanim then
                inst.AnimState:PushAnimation("idle_onemanband1_pre", false)
            else
                inst.AnimState:PlayAnimation("idle_onemanband1_pre")
            end

            if inst.AnimState:IsCurrentAnimation("idle_onemanband1_pre") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
                inst.sg.statemem.soundplayed = true
            end
        end,

        onupdate = function(inst)
            if not inst.sg.statemem.soundplayed and inst.AnimState:IsCurrentAnimation("idle_onemanband1_pre") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
                inst.sg.statemem.soundplayed = true
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("idle_onemanband1_pre") then
                    inst.sg:GoToState("play_onemanband")
                end
            end),
        },
    },

    State{
        name = "play_onemanband",
        tags = { "playing", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("idle_onemanband1_pre")
            inst.AnimState:PlayAnimation("idle_onemanband1_loop")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(math.random() <= 0.15 and "play_onemanband_stomp" or "play_onemanband")
                end
            end),
        },
    },

    State{
        name = "play_onemanband_stomp",
        tags = { "playing", "idle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_onemanband1_pst")
            inst.AnimState:PushAnimation("idle_onemanband2_pre")
            inst.AnimState:PushAnimation("idle_onemanband2_loop")
            inst.AnimState:PushAnimation("idle_onemanband2_pst", false)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
            end),
            TimeEvent(25*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
            end),
            TimeEvent(30*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
            end),
            TimeEvent(35*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "play_flute",
		tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("flute", false)

            local inv_obj = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
            local skin_build = inv_obj:GetSkinBuild()
            if skin_build ~= nil then
                inst.AnimState:OverrideItemSkinSymbol("pan_flute01", skin_build, "pan_flute01", inv_obj.GUID, "pan_flute" )
            else
                inst.AnimState:OverrideSymbol("pan_flute01", "pan_flute", "pan_flute01")
            end
            inst.components.inventory:ReturnActiveActionItem(inv_obj)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/flute_LP", "flute")
                else
					inst.sg.statemem.action_failed = true
					inst.AnimState:SetFrame(94)
                end
            end),
			TimeEvent(36 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(52 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
            TimeEvent(85 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.SoundEmitter:KillSound("flute")
				end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("flute")
			inst.AnimState:ClearOverrideSymbol("pan_flute01")
        end,
    },

    State{
        name = "play_horn",
		tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("horn", false)
            inst.AnimState:OverrideSymbol("horn01", "horn", "horn01")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil)
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
                else
					inst.sg.statemem.action_failed = true
                end
            end),
			TimeEvent(29 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(50)
				end
			end),
			TimeEvent(34 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(43 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("horn01")
		end,
    },

    State{
        name = "play_bell",
		tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("bell", false)
            inst.AnimState:OverrideSymbol("bell01", "bell", "bell01")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/glommer_bell")
            end),
            TimeEvent(60 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(62 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("bell01")
		end,
    },

    State{
        name = "play_whistle",
		tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("whistle", false)
			local item = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
			local build, symbol
			if item ~= nil then
				build = item.whistle_build
				symbol = item.whistle_symbol
				inst.sg.statemem.sound = item.whistle_sound
			end
			inst.AnimState:OverrideSymbol("hound_whistle01", build or "houndwhistle", symbol or "hound_whistle01")
			inst.components.inventory:ReturnActiveActionItem(item)
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
					inst.SoundEmitter:PlaySound(inst.sg.statemem.sound or "dontstarve/common/together/houndwhistle")
                else
					inst.sg.statemem.action_failed = true
					inst.AnimState:SetFrame(35)
                end
            end),
			TimeEvent(27 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(30 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("hound_whistle01")
		end,
    },

    State{
        name = "coach",
		tags = { "idle", "canrotate", "notalking" },

        onenter = function(inst)
            inst.components.talker:Say(GetString(inst, "ANNOUNCE_COACH"))
            inst.AnimState:PlayAnimation("coach")
            DoTalkSound(inst)
			--V2C: hack since we are idle, but also notalking
			inst.sg.mem.queuetalk_timeout = nil
        end,

		timeline =
		{
			FrameEvent(43, function(inst) inst.SoundEmitter:PlaySound("meta2/wolfgang/clap") end),
			FrameEvent(51, function(inst) inst.SoundEmitter:PlaySound("meta2/wolfgang/clap") end),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = StopTalkSound,
    },

    State{
        name = "play_gnarwail_horn",
		tags = { "doing", "busy", "playing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hornblow_pre")
            inst.AnimState:PushAnimation("hornblow", false)
        end,

        timeline =
        {
            TimeEvent(17 * FRAMES, function(inst)
				local horn = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
				if horn ~= nil and horn.playsound ~= nil then
					inst.SoundEmitter:PlaySound(horn.playsound)
				end
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
				end
            end),
			TimeEvent(22 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(39)
				end
			end),
			TimeEvent(27 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(30 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "use_beef_bell",
		tags = { "doing", "busy", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("cowbell", false)
            inst.AnimState:OverrideSymbol("cbell", "cowbell", "cbell")

            local invitem = (inst.bufferedaction ~= nil and inst.bufferedaction.invobject) or nil
            inst.components.inventory:ReturnActiveActionItem(invitem)
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(30 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),

            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(56*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
            TimeEvent(67*FRAMES, function(inst) inst.SoundEmitter:PlaySound("yotb_2021/common/cow_bell") end),
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
        name = "summon_abigail",
        tags = { "doing", "busy", "nodangle", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_channel")
            inst.AnimState:PushAnimation("wendy_channel_pst", false)

            if inst.bufferedaction ~= nil then
                local flower = inst.bufferedaction.invobject
                if flower ~= nil then
                    local skin_build = flower:GetSkinBuild()
                    if skin_build ~= nil then
                        inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end

                inst.sg.statemem.action = inst.bufferedaction
            end
        end,

        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                if inst.components.talker ~= nil and inst.components.ghostlybond ~= nil then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_SUMMON", "LEVEL"..tostring(math.max(inst.components.ghostlybond.bondlevel, 1))), nil, nil, true)
                end
            end),

            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre") end),

			TimeEvent(51 * FRAMES, function(inst)
                inst.sg.statemem.fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailsummonfx_mount" or "abigailsummonfx")
                inst.sg.statemem.fx.entity:SetParent(inst.entity)

                if inst.bufferedaction ~= nil then
                    local flower = inst.bufferedaction.invobject
                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.sg.statemem.fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                        end
                    end
                end
			end),
			TimeEvent(52 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end
            end),
			TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon") end),
            TimeEvent(62 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.sg.statemem.fx = nil
				else
					inst.sg.statemem.action_failed = true
                end
            end),
			TimeEvent(69 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(45)
					if inst.sg.statemem.fx ~= nil then
						inst.sg.statemem.fx:Remove()
						inst.sg.statemem.fx = nil
					end
				end
			end),
			TimeEvent(73 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(74 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("flower")
            if inst.sg.statemem.fx ~= nil then
                inst.sg.statemem.fx:Remove()
            end
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "unsummon_abigail",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_recall")
            inst.AnimState:PushAnimation("wendy_recall_pst", false)

            if inst.bufferedaction ~= nil then
                local flower = inst.bufferedaction.invobject
                if flower ~= nil then
                    local skin_build = flower:GetSkinBuild()
                    if skin_build ~= nil then
                        inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end

                inst.sg.statemem.action = inst.bufferedaction

                inst.components.talker:Say(GetString(inst, "ANNOUNCE_ABIGAIL_RETRIEVE"), nil, nil, true)
            end
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon_pre") end),
			TimeEvent(25 * FRAMES, function(inst)
				inst.sg.statemem.fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailunsummonfx_mount" or "abigailunsummonfx")
				inst.sg.statemem.fx.entity:SetParent(inst.entity)

				local flower = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
				if flower ~= nil then
					local skin_build = flower:GetSkinBuild()
					if skin_build ~= nil then
						inst.sg.statemem.fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild())
					end
				end
			end),
            TimeEvent(26 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end

                if inst:PerformBufferedAction() then
					inst.sg.statemem.fx = nil
                else
					inst.sg.statemem.action_failed = true
                end
            end),
			TimeEvent(28 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(17)
				end
			end),
			TimeEvent(30 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall")
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(32 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
					if inst.sg.statemem.fx ~= nil then
						inst.sg.statemem.fx:Remove()
						inst.sg.statemem.fx = nil
					end
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg.statemem.fx ~= nil then
				inst.sg.statemem.fx:Remove()
			end
            inst.AnimState:ClearOverrideSymbol("flower")
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "commune_with_abigail",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wendy_commune_pre")
            inst.AnimState:PushAnimation("wendy_commune_pst", false)

            if inst.bufferedaction ~= nil then
                local flower = inst.bufferedaction.invobject
                if flower ~= nil then
                    local skin_build = flower:GetSkinBuild()
                    if skin_build ~= nil then
                        inst.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                    else
                        inst.AnimState:OverrideSymbol("flower", flower.AnimState:GetBuild(), "flower")
                    end
                end

                inst.sg.statemem.action = inst.bufferedaction
            end
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
				end
            end),
			TimeEvent(18 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(24)
				end
			end),
			TimeEvent(29 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
            TimeEvent(35 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("flower")
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "play_strum",
        tags = { "doing", "busy", "playing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("strum_pre")
            inst.AnimState:PushAnimation("strum", false)

            inst.AnimState:OverrideSymbol("swap_trident", "swap_trident", "swap_trident")
        end,

        timeline =
        {
			TimeEvent(23 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/trident_attack") end),
            TimeEvent(28 * FRAMES, function(inst)
				local instrument = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
				if instrument ~= nil and instrument.playsound ~= nil then
					inst.SoundEmitter:PlaySound(instrument.playsound)
				end
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
				end
            end),
			TimeEvent(30 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(41)
				end
			end),
			TimeEvent(32 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
			TimeEvent(41 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "channel_longaction",
		tags = { "doing", "canrotate", "channeling" },

		onenter = function(inst, channelitem)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("give")
			inst.AnimState:PushAnimation("give_pst", false)

			if channelitem ~= nil then
				inst.sg.statemem.channelitem = channelitem
			else
				local bufferedaction = inst:GetBufferedAction()
				if bufferedaction ~= nil then
					inst.sg.statemem.channelitem = bufferedaction.target
					inst:PerformBufferedAction()
				end
			end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
				local channelitem = inst.sg.statemem.channelitem
				if channelitem ~= nil and channelitem:IsValid() then
					inst.sg.statemem.channeling = true
					inst.sg:GoToState("channel_longaction", channelitem)
				else
					inst.sg:GoToState("idle")
				end
            end),
            EventHandler("cancel_channel_longaction", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.channeling then
				local channelitem = inst.sg.statemem.channelitem
				if channelitem ~= nil and channelitem:IsValid() then
					channelitem:PushEvent("channel_finished")
				end
			end
		end,
    },

    State{
        name = "use_pocket_scale",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("pocket_scale_weigh", false)
            inst.SoundEmitter:PlaySound("hookline/common/trophyscale_fish/pocket")

            inst.AnimState:OverrideSymbol("swap_pocket_scale_body", "pocket_scale", "pocket_scale_body")

            local act = inst:GetBufferedAction()
            if act ~= nil and act.target and act.invobject then
                inst.sg.statemem.target = act.target.components.weighable and act.target
                                        or act.invobject.components.weighable and act.invobject
                                        or nil

                if inst.sg.statemem.target then
                    inst.sg.statemem.target_build = inst.sg.statemem.target.AnimState:GetBuild()
                    inst.AnimState:AddOverrideBuild(inst.sg.statemem.target_build)
                end
            end
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                local weight = inst.sg.statemem.target ~= nil and inst.sg.statemem.target.components.weighable:GetWeight() or nil
                if weight ~= nil and inst:PerformBufferedAction() then
                    local announce_str = inst.sg.statemem.target.components.weighable:GetWeightPercent() >= TUNING.WEIGHABLE_HEAVY_WEIGHT_PERCENT and "ANNOUNCE_WEIGHT_HEAVY" or "ANNOUNCE_WEIGHT"
                    local str = subfmt(GetString(inst, announce_str), {weight = string.format("%0.2f", weight)})
                    inst.components.talker:Say(str)
                else
                    inst.AnimState:ClearOverrideBuild(inst.sg.statemem.target_build)
                    inst:ClearBufferedAction()
					inst.AnimState:SetFrame(53)
					inst.sg.statemem.action_failed = true
                end
            end),
			TimeEvent(48 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.SoundEmitter:PlaySound("hookline/common/trophyscale_fish/pocket_pop")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("swap_pocket_scale_body")
            inst.AnimState:ClearOverrideBuild(inst.sg.statemem.target_build)
        end,
    },

	State{
		name = "book_repeatcast",
		onenter = function(inst)
			inst.sg:GoToState("book", true)
		end,
	},

	State{
		name = "book",
		tags = { "doing", "busy" },

		onenter = function(inst, repeatcast)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("action_uniqueitem_pre")

			local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if book ~= nil then
				inst.components.inventory:ReturnActiveActionItem(book)

				if book.components.spellbook ~= nil and book.components.spellbook:HasSpellFn() then
					--inst.sg:AddStateTag("busy")
				elseif book.components.aoetargeting ~= nil then
					--inst.sg:AddStateTag("busy")
					inst.sg.statemem.targetfx = book.components.aoetargeting:SpawnTargetFXAt(inst.bufferedaction:GetDynamicActionPoint())
					if inst.sg.statemem.targetfx ~= nil then
						inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
					end
				end
			end

			local fxname = book ~= nil and book:HasTag("shadowmagic") and "waxwell_book_fx" or "book_fx"
			if inst.components.rider:IsRiding() then
				fxname = fxname.."_mount"
			end
			inst.sg.statemem.book_fx = SpawnPrefab(fxname)
			inst.sg.statemem.book_fx.entity:SetParent(inst.entity)

			if repeatcast then
				local t = inst.AnimState:GetCurrentAnimationNumFrames()
				inst.sg.statemem.book_fx.AnimState:SetFrame(t + 6)
				inst.sg.statemem.not_interrupted = true
				inst.sg:GoToState("book2", {
					book_fx = inst.sg.statemem.book_fx,
					targetfx = inst.sg.statemem.targetfx,
					repeatcast = true,
				})
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interrupted = true
					inst.sg:GoToState("book2", {
						book_fx = inst.sg.statemem.book_fx,
						targetfx = inst.sg.statemem.targetfx,
					})
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.not_interrupted then
				if inst.sg.statemem.book_fx ~= nil and inst.sg.statemem.book_fx:IsValid() then
					inst.sg.statemem.book_fx:Remove()
				end
				if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
					OnRemoveCleanupTargetFX(inst)
				end
			end
		end,
	},

	State{
		name = "book2",
		tags = { "doing", "busy" },

		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("book")

			--V2C: NOTE that these are now used in onexit to clear skinned symbols
			--Moved to player_common because these symbols are never cleared
			--inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
			--inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")

			local frameskip = 0
			if data ~= nil then
				inst.sg.statemem.book_fx = data.book_fx
				inst.sg.statemem.targetfx = data.targetfx
				if data.repeatcast then
					inst.sg.statemem.repeatcast = true
					frameskip = 6
					inst.AnimState:SetFrame(frameskip)
				end
			end

			local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if book ~= nil then
				local suffix = inst.components.rider:IsRiding() and "_mount" or ""

				if book.def ~= nil then
					if book.def.fx_over_prefab ~= nil then
						inst.sg.statemem.fx_over = SpawnPrefab(book.def.fx_over_prefab..suffix)
						inst.sg.statemem.fx_over.entity:SetParent(inst.entity)
						inst.sg.statemem.fx_over.Follower:FollowSymbol(inst.GUID, "swap_book_fx_over", 0, 0, 0, true)
						inst.sg.statemem.fx_over.AnimState:SetFrame(frameskip)
					end
					if book.def.fx_under_prefab ~= nil then
						inst.sg.statemem.fx_under = SpawnPrefab(book.def.fx_under_prefab..suffix)
						inst.sg.statemem.fx_under.entity:SetParent(inst.entity)
						inst.sg.statemem.fx_under.Follower:FollowSymbol(inst.GUID, "swap_book_fx_under", 0, 0, 0, true)
						inst.sg.statemem.fx_under.AnimState:SetFrame(frameskip)
					end

					if book.def.layer_sound ~= nil then
						--track and manage via soundtask and sound name (even though it is not a loop)
						--so we can handle interruptions to this state
						local frame = book.def.layer_sound.frame or 0
						if frame > 0 then
							inst.sg.statemem.soundtask = inst:DoTaskInTime((frame - frameskip) * FRAMES, function(inst)
								inst.sg.statemem.soundtask = nil
								inst.SoundEmitter:KillSound("book_layer_sound")
								inst.SoundEmitter:PlaySound(book.def.layer_sound.sound, "book_layer_sound")
							end)
						else
							inst.SoundEmitter:KillSound("book_layer_sound")
							inst.SoundEmitter:PlaySound(book.def.layer_sound.sound, "book_layer_sound")
						end
					end
				end

				if book:HasTag("shadowmagic") then
					inst.sg.statemem.fx_shadow = SpawnPrefab("waxwell_shadow_book_fx"..suffix)
					inst.sg.statemem.fx_shadow.entity:SetParent(inst.entity)
					inst.sg.statemem.fx_shadow.AnimState:SetFrame(frameskip)
				end

				local swap_build = book.swap_build
				local swap_prefix = book.swap_prefix or "book"
				local skin_build = book:GetSkinBuild()
				if skin_build ~= nil then
					inst.AnimState:OverrideItemSkinSymbol("book_open", skin_build, "book_open", book.GUID, swap_build or "player_actions_uniqueitem", swap_prefix.."_open")
					inst.AnimState:OverrideItemSkinSymbol("book_closed", skin_build, "book_closed", book.GUID, swap_build or "player_actions_uniqueitem", swap_prefix.."_closed")
					inst.sg.statemem.symbolsoverridden = true
				elseif swap_build ~= nil then
					inst.AnimState:OverrideSymbol("book_open", swap_build, swap_prefix.."_open")
					inst.AnimState:OverrideSymbol("book_closed", swap_build, swap_prefix.."_closed")
					inst.sg.statemem.symbolsoverridden = true
				end

				if book.components.spellbook ~= nil and book.components.spellbook:HasSpellFn() then
					--inst.sg:AddStateTag("busy")
				elseif book.components.aoetargeting ~= nil then
					inst.sg.statemem.earlycast = true
					inst.sg.statemem.canrepeatcast = book.components.aoetargeting:CanRepeatCast()
					--inst.sg:AddStateTag("busy")
				end
			end

			inst.sg.statemem.castsound = book ~= nil and book.castsound or "dontstarve/common/book_spell"
		end,

		timeline =
		{
			--
			TimeEvent(13 * FRAMES, function(inst)
				local function fn19()
					inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")

					if inst.sg.statemem.earlycast then
						if inst.sg.statemem.fx_shadow ~= nil then
							if inst.sg.statemem.fx_shadow:IsValid() then
								local x, y, z = inst.sg.statemem.fx_shadow.Transform:GetWorldPosition()
								inst.sg.statemem.fx_shadow.entity:SetParent(nil)
								inst.sg.statemem.fx_shadow.Transform:SetPosition(x, y, z)
								inst.sg.statemem.fx_shadow.Transform:SetRotation(inst.Transform:GetRotation())
							end
							inst.sg.statemem.fx_shadow = nil --Don't cancel anymore
						end
						inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
						if not inst:PerformBufferedAction() then
                            inst.sg.statemem.canrepeatcast = false
                            inst:RemoveTag("canrepeatcast")
                        end
					end
				end
				if inst.sg.statemem.repeatcast then
					fn19()
				else
					inst.sg.statemem.fn19 = fn19
				end
			end),
			TimeEvent(19 * FRAMES, function(inst)
				if inst.sg.statemem.fn19 ~= nil then
					inst.sg.statemem.fn19()
					inst.sg.statemem.fn19 = nil
				end
			end),
			--
			TimeEvent(18 * FRAMES, function(inst)
				if inst.sg.statemem.repeatcast and inst.sg.statemem.canrepeatcast then
					inst:AddTag("canrepeatcast")
				end
			end),
			TimeEvent(24 * FRAMES, function(inst)
				if not inst.sg.statemem.repeatcast and inst.sg.statemem.canrepeatcast then
					inst:AddTag("canrepeatcast")
				end
			end),
			--
			TimeEvent(24 * FRAMES, function(inst)
				local function fn30()
					if inst.sg.statemem.fx_shadow ~= nil then
						if inst.sg.statemem.fx_shadow:IsValid() then
							local x, y, z = inst.sg.statemem.fx_shadow.Transform:GetWorldPosition()
							inst.sg.statemem.fx_shadow.entity:SetParent(nil)
							inst.sg.statemem.fx_shadow.Transform:SetPosition(x, y, z)
							inst.sg.statemem.fx_shadow.Transform:SetRotation(inst.Transform:GetRotation())
						end
						inst.sg.statemem.fx_shadow = nil --Don't cancel anymore
					end
				end
				if inst.sg.statemem.repeatcast then
					fn30()
				else
					inst.sg.statemem.fn30 = fn30
				end
			end),
			TimeEvent(30 * FRAMES, function(inst)
				if inst.sg.statemem.fn30 ~= nil then
					inst.sg.statemem.fn30()
					inst.sg.statemem.fn30 = nil
				end
			end),
			--
			TimeEvent(44 * FRAMES, function(inst)
				local function fn50()
					if inst.sg.statemem.targetfx ~= nil then
						if inst.sg.statemem.targetfx:IsValid() then
							OnRemoveCleanupTargetFX(inst)
						end
						inst.sg.statemem.targetfx = nil
					end

					local book_fx = inst.sg.statemem.book_fx
					if book_fx ~= nil then
						if book_fx:IsValid() then
							local x, y, z = book_fx.Transform:GetWorldPosition()
							book_fx.entity:SetParent(nil)
							book_fx.Transform:SetPosition(x, y, z)
							book_fx.Transform:SetRotation(inst.Transform:GetRotation())
						else
							book_fx = nil
						end
						inst.sg.statemem.book_fx = nil --Don't cancel anymore
					end

					if not inst.sg.statemem.earlycast then
						inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
						inst.sg:RemoveStateTag("busy")
						if not inst:PerformBufferedAction() then
							if book_fx ~= nil then
								book_fx:PushEvent("fail_fx", inst)
							end
                            inst.sg.statemem.canrepeatcast = false
                            inst:RemoveTag("canrepeatcast")
						end
					end
				end
				if inst.sg.statemem.repeatcast then
					fn50()
				else
					inst.sg.statemem.fn50 = fn50
				end
			end),
			TimeEvent(50 * FRAMES, function(inst)
				if inst.sg.statemem.fn50 ~= nil then
					inst.sg.statemem.fn50()
					inst.sg.statemem.fn50 = nil
				end
			end),
			--
			TimeEvent(45 * FRAMES, function(inst)
				if inst.sg.statemem.repeatcast then
					inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
				end
			end),
			TimeEvent(51 * FRAMES, function(inst)
				if not inst.sg.statemem.repeatcast then
					inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
				end
			end),
			--
			TimeEvent(46 * FRAMES, function(inst)
				if inst.sg.statemem.repeatcast then
					inst.sg:RemoveStateTag("busy")
					inst:RemoveTag("canrepeatcast")
				end
			end),
			TimeEvent(52 * FRAMES, function(inst)
				if not inst.sg.statemem.repeatcast then
					inst.sg:RemoveStateTag("busy")
					inst:RemoveTag("canrepeatcast")
				end
			end),
			--
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.statemem.symbolsoverridden then
				inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
				inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")
			end
			if inst.sg.statemem.book_fx ~= nil and inst.sg.statemem.book_fx:IsValid() then
				inst.sg.statemem.book_fx:Remove()
			end
			if inst.sg.statemem.fx_shadow ~= nil and inst.sg.statemem.fx_shadow:IsValid() then
				inst.sg.statemem.fx_shadow:Remove()
			end
			if inst.sg.statemem.fx_over ~= nil and inst.sg.statemem.fx_over:IsValid() then
				inst.sg.statemem.fx_over:Remove()
			end
			if inst.sg.statemem.fx_under ~= nil and inst.sg.statemem.fx_under:IsValid() then
				inst.sg.statemem.fx_under:Remove()
			end
			if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
				OnRemoveCleanupTargetFX(inst)
			end
			if inst.sg.statemem.soundtask ~= nil then
				inst.sg.statemem.soundtask:Cancel()
			elseif inst.SoundEmitter:PlayingSound("book_layer_sound") then
				inst.SoundEmitter:SetVolume("book_layer_sound", .5)
			end
			inst:RemoveTag("canrepeatcast")
		end,
	},

    State{
        name = "book_peruse",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("peruse", false)
            --V2C: NOTE that these are now used in onexit to clear skinned symbols
            --Moved to player_common because these symbols are never cleared
            --inst.AnimState:OverrideSymbol("book_peruse", "wurt_peruse", "book_peruse")

            local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
            if book ~= nil then
                inst.components.inventory:ReturnActiveActionItem(book)

                local swap_build = book.swap_build
                local swap_prefix = book.swap_prefix or "book"
                local skin_build = book:GetSkinBuild()
                if skin_build ~= nil then
                    inst.AnimState:OverrideItemSkinSymbol("book_peruse", skin_build, "book_peruse", book.GUID, swap_build or "wurt_peruse", swap_prefix.."_peruse")
                    inst.sg.statemem.symbolsoverridden = true
                elseif swap_build ~= nil then
                    inst.AnimState:OverrideSymbol("book_peruse", swap_build, swap_prefix.."_peruse")
                    inst.sg.statemem.symbolsoverridden = true
                end
            end
        end,

        timeline =
        {
            TimeEvent(25 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book")
            end),
            TimeEvent(68 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/actions/page_turn")
            end),
            TimeEvent(98 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },
        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.symbolsoverridden then
                inst.AnimState:OverrideSymbol("book_peruse", "wurt_peruse", "book_peruse")
            end
        end,
    },

    State{
        name = "blowdart",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dart_pre")
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(5)
            end
            inst.AnimState:PushAnimation("dart", false)

            inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, inst.components.combat.min_attack_period))

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end

            if (equip ~= nil and equip.projectiledelay or 0) > 0 then
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
                    inst:PerformBufferedAction()
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
                    inst:PerformBufferedAction()
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
                    inst:PerformBufferedAction()
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
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

	State{
		name = "throw_deploy",
		tags = { "doing", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("useitem_dir_pre") --8 frames
			inst.AnimState:PushAnimation("deploytoss_pre")
			inst.AnimState:PushAnimation("deploytoss", false)

			local buffaction = inst:GetBufferedAction()
			if buffaction then
				if buffaction.pos then
					inst:ForceFacePoint(buffaction:GetActionPoint():Get())
				end
				local deployable = buffaction.invobject and buffaction.invobject.components.deployable or nil
				local override = deployable and deployable.deploytoss_symbol_override or nil
				if override then
					inst.AnimState:OverrideSymbol("swap_deploytoss_object", override.build, override.symbol)
				end
			end
		end,

		timeline =
		{
			FrameEvent(15, function(inst)
				inst:PerformBufferedAction()
			end),
			FrameEvent(22, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

		events =
		{
			EventHandler("equip", function(inst, data)
				inst.sg:GoToState("idle")
			end),
			EventHandler("unequip", function(inst, data)
				inst.sg:GoToState("idle")
			end),
		},

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("swap_deploytoss_object")
		end,
	},

	State{
		name = "throw_keep_equip",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw", false)

			local buffaction = inst:GetBufferedAction()
			if buffaction ~= nil then
				if buffaction.pos ~= nil then
					inst:ForceFacePoint(buffaction:GetActionPoint():Get())
				end

				if buffaction.invobject ~= nil then
					local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if buffaction.invobject ~= equipped and
						buffaction.invobject.components.equippable ~= nil and
						buffaction.invobject.components.equippable.equipslot == EQUIPSLOTS.HANDS and
						not buffaction.invobject.components.equippable:IsRestricted(inst)
						then
						inst.sg.statemem.actionunequip = equipped
						inst.sg.statemem.actionequip = buffaction.invobject
						inst.components.inventory:Equip(buffaction.invobject)
					end
				end
			end
		end,

		timeline =
		{
			TimeEvent(7 * FRAMES, function(inst)
				if inst:PerformBufferedAction() then
					inst.sg.statemem.thrown = true
				end
				local prevequip = inst.sg.statemem.prevequip
				if prevequip ~= nil and
					prevequip:IsValid() and
					prevequip.components.inventoryitem ~= nil and
					prevequip.components.inventoryitem:GetGrandOwner() == inst
					then
					local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equipped == nil or not inst.sg.statemem.thrown then
						inst.sg.statemem.actionunequip = equipped
						inst.sg.statemem.actionequip = prevequip
						inst.components.inventory:Equip(prevequip)
					end
				end
			end),
			TimeEvent(14 * FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

		events =
		{
			EventHandler("equip", function(inst, data)
				if data.item == inst.sg.statemem.actionequip then
					inst.sg.statemem.actionequip = nil
				else
					inst.sg:GoToState("idle")
				end
			end),
			EventHandler("unequip", function(inst, data)
				if data.item == inst.sg.statemem.actionunequip then
					inst.sg.statemem.prevequip = inst.sg.statemem.actionunequip
					inst.sg.statemem.actionunequip = nil
				elseif inst.sg.statemem.thrown and data.eslot == EQUIPSLOTS.HANDS then
					inst.sg.statemem.thrown = nil
				else
					inst.sg:GoToState("idle")
				end
			end),
		},
	},

    State{
        name = "throw",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = math.max(inst.components.combat.min_attack_period, 11 * FRAMES)

			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw", false)

            inst.sg:SetTimeout(cooldown)

            if target ~= nil and target:IsValid() then
                inst:FacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
				if inst:PerformBufferedAction() then
					inst.sg.statemem.thrown = true
				end
                inst.sg:RemoveStateTag("abouttoattack")
            end),
        },

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("attack")
            inst.sg:AddStateTag("idle")
        end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst, data)
				if inst.sg.statemem.thrown and data.eslot == EQUIPSLOTS.HANDS then
					inst.sg.statemem.thrown = nil
				else
                    inst.sg:GoToState("idle")
                end
            end),
			EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "catch_pre",
		tags = { "doing", "notalking", "readytocatch" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("catch_pre")

            inst.sg:SetTimeout(3)
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,

        events =
        {
            EventHandler("catch", function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("catch")
            end),
            EventHandler("cancelcatch", function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "catch",
        tags = { "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("catch")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

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
        name = "attack",
        tags = { "attack", "notalking", "abouttoattack", "autopredict" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.combat:SetTarget(target)
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            local cooldown = inst.components.combat.min_attack_period
            if inst.components.rider:IsRiding() then
                if equip ~= nil and (equip.components.projectile ~= nil or equip:HasTag("rangedweapon")) then
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
                    cooldown = math.max(cooldown, 13 * FRAMES)
                else
                    inst.AnimState:PlayAnimation("atk_pre")
                    inst.AnimState:PushAnimation("atk", false)
                    DoMountSound(inst, inst.components.rider:GetMount(), "angry", true)
                    cooldown = math.max(cooldown, 16 * FRAMES)
                end
            elseif equip ~= nil and equip:HasTag("toolpunch") then

                -- **** ANIMATION WARNING ****
                -- **** ANIMATION WARNING ****
                -- **** ANIMATION WARNING ****

                --  THIS ANIMATION LAYERS THE LANTERN GLOW UNDER THE ARM IN THE UP POSITION SO CANNOT BE USED IN STANDARD LANTERN GLOW ANIMATIONS.

                inst.AnimState:PlayAnimation("toolpunch")
                inst.sg.statemem.istoolpunch = true
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, inst.sg.statemem.attackvol, true)
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif equip ~= nil and equip:HasTag("whip") then
                inst.AnimState:PlayAnimation("whip_pre")
                inst.AnimState:PushAnimation("whip", false)
                inst.sg.statemem.iswhip = true
                inst.SoundEmitter:PlaySound("dontstarve/common/whip_pre", nil, nil, true)
                cooldown = math.max(cooldown, 17 * FRAMES)
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
                cooldown = math.max(cooldown, 19 * FRAMES)
            elseif equip ~= nil and equip:HasTag("chop_attack") and inst:HasTag("woodcutter") then
				inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationFrame() <= 7 and "woodie_chop_atk_pre" or "woodie_chop_pre")
                inst.AnimState:PushAnimation("woodie_chop_loop", false)
                inst.sg.statemem.ischop = true
                cooldown = math.max(cooldown, 11 * FRAMES)
            elseif equip ~= nil and equip:HasTag("jab") then
                inst.AnimState:PlayAnimation("spearjab_pre")
                inst.AnimState:PushAnimation("spearjab", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 21 * FRAMES)
            elseif equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
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
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif equip ~= nil and (equip:HasTag("light") or equip:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif inst:HasTag("beaver") then
                inst.sg.statemem.isbeaver = true
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 13 * FRAMES)
            elseif inst:HasTag("weremoose") then
                inst.sg.statemem.ismoose = true
				if inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c") then
					inst.AnimState:PlayAnimation("punch_b")
					if inst:HasTag("weremoosecombo") then
						inst.sg:AddStateTag("nointerrupt")
					end
				elseif inst.AnimState:IsCurrentAnimation("punch_b") then
					if inst:HasTag("weremoosecombo") then
						inst.sg.statemem.ismoosesmash = true
						inst.sg:AddStateTag("nointerrupt")
						inst.AnimState:PlayAnimation("moose_slam")
						inst.SoundEmitter:PlaySound("meta2/woodie/weremoose_groundpound", nil, nil, true)
					else
						inst.AnimState:PlayAnimation("punch_c")
					end
				else
					inst.AnimState:PlayAnimation("punch_a")
				end
                cooldown = math.max(cooldown, 15 * FRAMES)
            else
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh", nil, nil, true)
                cooldown = math.max(cooldown, 24 * FRAMES)
            end

            inst.sg:SetTimeout(cooldown)

            if target ~= nil then
                inst.components.combat:BattleCry()
                if target:IsValid() then
                    inst:FacePoint(target:GetPosition())
                    inst.sg.statemem.attacktarget = target
                    inst.sg.statemem.retarget = target
                end
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
                        inst:PerformBufferedAction()
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
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                elseif inst.sg.statemem.ischop then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
                end
            end),
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.ismoose then
					if inst.sg.statemem.ismoosesmash then
						inst:PushMooseSmashShake()
						inst.sg:RemoveStateTag("nointerrupt")

						local x, y, z = inst.Transform:GetWorldPosition()
						local rot = inst.Transform:GetRotation()

						--V2C: first frame is blank, so no need to worry about forcing instant facing update
						local fx = SpawnPrefab("weremoose_smash_fx")
						fx.Transform:SetPosition(x, 0, z)
						fx.Transform:SetRotation(rot)
						fx._owner:set(inst)

						inst:ClearBufferedAction()
						inst.components.combat.ignorehitrange = true
						inst.components.combat:SetDefaultDamage(TUNING.SKILLS.WOODIE.MOOSE_SMASH_DAMAGE)
						local dist = 1
						local radius = 2
						rot = rot * DEGREES
						x = x + dist * math.cos(rot)
						z = z - dist * math.sin(rot)
						for i, v in ipairs(TheSim:FindEntities(x, y, z, radius + 3, MOOSE_AOE_MUST_TAGS, MOOSE_AOE_CANT_TAGS)) do
							if v ~= inst and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
								local range = radius + v:GetPhysicsRadius(0)
								local dsq = v:GetDistanceSqToPoint(x, y, z)
								if dsq < range * range and
									(	v == inst.sg.statemem.attacktarget or --would mean we force attacked if needed
										not inst:TargetForceAttackOnly(v)
									) and
									inst.components.combat:CanTarget(v) and
									not inst.components.combat:IsAlly(v)
								then
									if v.components.planarentity ~= nil then
										inst.components.planardamage:AddBonus(inst, TUNING.SKILLS.WOODIE.MOOSE_SMASH_PLANAR_DAMAGE, "weremoose_smash")
									end
									inst.components.combat:DoAttack(v)
									inst.components.planardamage:RemoveBonus(inst, "weremoose_smash")
								end
							end
						end
						inst.components.combat:SetDefaultDamage(TUNING.WEREMOOSE_DAMAGE)
						inst.components.combat.ignorehitrange = false
					else
						inst:PerformBufferedAction()
					end
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
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.isbook or inst.sg.statemem.ispocketwatch then
                    inst:PerformBufferedAction()
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
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "attack_pillow_pre",
        tags = { "doing", "busy", "notalking" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pillow_pre")
            inst.AnimState:PushAnimation("atk_pillow_hold", true)

            local buffaction = inst:GetBufferedAction()
            if buffaction and buffaction.target and buffaction.target:IsValid() then
                inst:ForceFacePoint(buffaction.target.Transform:GetWorldPosition())
            end

            local pillow = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.sg:SetTimeout((pillow and pillow._laglength) or 1.0)
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("attack_pillow")
        end,
    },

    State{
        name = "attack_pillow",
        tags = { "doing", "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_pillow")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "attack_prop_pre",
        tags = { "propattack", "doing", "busy", "notalking" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop_pre")

            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            if target ~= nil and target:IsValid() then
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end
        end,

        events =
        {
            EventHandler("unequip", function(inst)
                inst.sg:GoToState("idle")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("attack_prop")
                end
            end),
        },
    },

    State{
        name = "attack_prop",
        tags = { "propattack", "doing", "busy", "notalking", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_prop")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,
        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst:PerformBufferedAction()
                local dist = .8
                local radius = 1.7
                inst.components.combat.ignorehitrange = true
                local x0, y0, z0 = inst.Transform:GetWorldPosition()
                local angle = (inst.Transform:GetRotation() + 90) * DEGREES
                local sinangle = math.sin(angle)
                local cosangle = math.cos(angle)
                local x = x0 + dist * sinangle
                local z = z0 + dist * cosangle
                for i, v in ipairs(TheSim:FindEntities(x, y0, z, radius + 3, ATTACK_PROP_MUST_TAGS, ATTACK_PROP_CANT_TAGS)) do
                    if v:IsValid() and not v:IsInLimbo() and
                        not (v.components.health ~= nil and v.components.health:IsDead()) then
                        local range = radius + v:GetPhysicsRadius(.5)
                        if v:GetDistanceSqToPoint(x, y0, z) < range * range and inst.components.combat:CanTarget(v) then
                            --dummy redirected so that players don't get red blood flash
                            v:PushEvent("attacked", { attacker = inst, damage = 0, redirected = v })
                            v:PushEvent("knockback", { knocker = inst, radius = radius + dist, propsmashed = true })
                            inst.sg.statemem.smashed = true
                        end
                    end
                end
                inst.components.combat.ignorehitrange = false
                if inst.sg.statemem.smashed then
                    local prop = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if prop ~= nil then
                        dist = dist + radius - .5
                        inst.sg.statemem.smashed = { prop = prop, pos = Vector3(x0 + dist * sinangle, y0, z0 + dist * cosangle) }
                    else
                        inst.sg.statemem.smashed = nil
                    end
                end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                if inst.sg.statemem.smashed ~= nil then
                    local smashed = inst.sg.statemem.smashed
                    inst.sg.statemem.smashed = false
                    smashed.prop:PushEvent("propsmashed", smashed.pos)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst)
                if inst.sg.statemem.smashed == nil then
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.smashed then --could be false, so don't nil check
                inst.sg.statemem.smashed.prop:PushEvent("propsmashed", inst.sg.statemem.smashed.pos)
            end
        end,
    },

    State{
        name = "run_start",
        tags = { "moving", "running", "canrotate", "autopredict" },

        onenter = function(inst)
            ConfigureRunState(inst)
            if inst.sg.statemem.normalwonkey and inst.components.locomotor:GetTimeMoving() >= TUNING.WONKEY_TIME_TO_RUN then
                inst.sg:GoToState("run_monkey") --resuming after brief stop from changing directions, or resuming prediction after running into obstacle
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
                    PlayMooseFootstep(inst, nil, true)
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
        tags = { "moving", "running", "canrotate", "autopredict" },

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
			if inst.sg.statemem.normalwonkey and not inst.sg.statemem.channelcast and inst.components.locomotor:GetTimeMoving() >= TUNING.WONKEY_TIME_TO_RUN then
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
					inst.sg.statemem.channelcast
				then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                elseif inst.sg.statemem.goose then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    DoGooseRunFX(inst)
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
                    if inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and inst.sg.statemem.heavy_fast then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                end
            end),
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and not inst.sg.statemem.heavy_fast then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                elseif inst.sg.statemem.moose then
                    DoMooseRunSounds(inst)
                    DoFoleySounds(inst)
                elseif inst.sg.statemem.sandstorm
                    or inst.sg.statemem.careful then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                end
            end),
            TimeEvent(36 * FRAMES, function(inst)
                if inst.sg.statemem.heavy and not inst.sg.statemem.heavy_fast then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    if inst.sg.mem.footsteps > 12 then
                        inst.sg.mem.footsteps = math.random(4, 6)
                        inst:PushEvent("encumberedwalking")
                    elseif inst.sg.mem.footsteps > 3 then
                        --normally stops at > 3, but heavy needs to keep count
                        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
                    end
                end
            end),

            --mounted
            TimeEvent(0 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    DoMountedFoleySounds(inst)
                end
            end),
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    DoRunSounds(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/walk",nil,.5)
                    if inst.sg.statemem.ridingwoby then
                        inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1})
                    end
                end
            end),
            TimeEvent(3 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    if inst.sg.statemem.ridingwoby then
                        inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1})
                    end
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    DoRunSounds(inst)
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/walk",nil,.5)
                    if inst.sg.statemem.ridingwoby then
                        inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1})
                    end
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.riding then
                    if inst.sg.statemem.ridingwoby then
                        inst.SoundEmitter:PlaySoundWithParams("dontstarve/characters/walter/woby/big/footstep", {intensity= 1})
                    end
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
                    DoGooseRunFX(inst)
                end
            end),]]
            TimeEvent(9 * FRAMES, function(inst)
                if inst.sg.statemem.goose then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    DoGooseRunFX(inst)
                end
            end),

            --goose groggy
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.goosegroggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    DoGooseWalkFX(inst)
                end
            end),
            TimeEvent(17 * FRAMES, function(inst)
                if inst.sg.statemem.goosegroggy then
                    DoRunSounds(inst)
                    DoFoleySounds(inst)
                    DoGooseWalkFX(inst)
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
        tags = { "canrotate", "idle", "autopredict" },

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
                    if inst.sg.statemem.goosegroggy then
                        DoGooseWalkFX(inst)
                    else
                        DoGooseStepFX(inst)
                    end
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
        tags = {"moving", "running", "canrotate", "monkey", "autopredict"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normalwonkey then
                inst.sg:GoToState("run")
                return
            end
            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_monkey_pre")
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/wilbur/walktorun", "walktorun") TODO SOUND
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
        tags = {"moving", "running", "canrotate", "monkey", "autopredict"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normalwonkey then
                inst.sg:GoToState("run")
                return
            end
            inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WONKEY_SPEED_BONUS
            inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * TUNING.WONKEY_RUN_HUNGER_RATE_MULT)
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
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WONKEY_WALK_SPEED_PENALTY
                inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "item_hat",
		tags = { "idle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,

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
        name = "item_in",
		tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.followfx ~= nil then
                for i, v in ipairs(inst.sg.statemem.followfx) do
                    v:Remove()
                end
            end
        end,
    },

    State{
        name = "item_out",
		tags = { "idle", "nodangle", "keepchannelcasting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,

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
        name = "give",
        tags = { "giving" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.AnimState:PushAnimation("give_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "catchonfire",
        tags = { "igniting" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("light_fire")
            inst.AnimState:PushAnimation("light_fire_pst", false)
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "spray_wax",
        tags = { "waxing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("light_fire")
            inst.AnimState:PushAnimation("light_fire_pst", false)
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("qol1/wax_spray/spritz")
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "bedroll",
        tags = { "bedroll", "busy", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local failreason =
                (TheWorld.state.isday and
                    (TheWorld:HasTag("cave") and "ANNOUNCE_NODAYSLEEP_CAVE" or "ANNOUNCE_NODAYSLEEP")
                )
                or (inst.IsNearDanger(inst) and "ANNOUNCE_NODANGERSLEEP")
                -- you can still sleep if your hunger will bottom out, but not absolutely
                or (inst.components.hunger.current < TUNING.CALORIES_MED and "ANNOUNCE_NOHUNGERSLEEP")
                or nil

            if failreason == nil and inst.components.sleepingbaguser ~= nil then
                local _, sleepingbagfailreason = inst.components.sleepingbaguser:ShouldSleep()
                failreason = sleepingbagfailreason
            end

            if failreason ~= nil then
                inst:PushEvent("performaction", { action = inst.bufferedaction })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, failreason))
                end
                return
            end

            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("bedroll", false)
            SetSleeperSleepState(inst)

            --Hack since we've already temp unequipped hand items at this point
            --but we want to show the correct arms for action_uniqueitem_pre
            if inst._sleepinghandsitem ~= nil then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bedroll")
            end),
        },

        events =
        {
            EventHandler("firedamage", function(inst)
                if inst.sg:HasStateTag("sleeping") then
                    inst.sg.statemem.iswaking = true
                    inst.sg:GoToState("wakeup")
                end
            end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    if TheWorld.state.isday or
                        (inst.components.health ~= nil and inst.components.health.takingfiredamage) or
                        (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
                        inst:PushEvent("performaction", { action = inst.bufferedaction })
                        inst:ClearBufferedAction()
                        inst.sg.statemem.iswaking = true
                        inst.sg:GoToState("wakeup")
                    elseif inst:GetBufferedAction() then
                        inst:PerformBufferedAction()
                        if inst.components.playercontroller ~= nil then
                            inst.components.playercontroller:Enable(true)
                        end
                        inst.sg:AddStateTag("sleeping")
                        inst.sg:AddStateTag("silentmorph")
                        inst.sg:RemoveStateTag("nomorph")
                        inst.sg:RemoveStateTag("busy")
                        inst.AnimState:PlayAnimation("bedroll_sleep_loop", true)
                    else
                        inst.sg.statemem.iswaking = true
                        inst.sg:GoToState("wakeup")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Hide("ARM_carry")
                inst.AnimState:Show("ARM_normal")
            end
            if inst.sleepingbag ~= nil then
                --Interrupted while we are "sleeping"
                inst.sleepingbag.components.sleepingbag:DoWakeUp(true)
                inst.sleepingbag = nil
                SetSleeperAwakeState(inst)
            elseif not inst.sg.statemem.iswaking then
                --Interrupted before we are "sleeping"
                SetSleeperAwakeState(inst)
            end
        end,
    },

    State{
        name = "tent",
        tags = { "tent", "busy", "silentmorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local target = inst:GetBufferedAction().target
            local siesta = target:HasTag("siestahut")
            local failreason =
                (siesta ~= TheWorld.state.isday and
                    (siesta
                    and (TheWorld:HasTag("cave") and "ANNOUNCE_NONIGHTSIESTA_CAVE" or "ANNOUNCE_NONIGHTSIESTA")
                    or (TheWorld:HasTag("cave") and "ANNOUNCE_NODAYSLEEP_CAVE" or "ANNOUNCE_NODAYSLEEP"))
                )
                or (target.components.burnable ~= nil and
                    target.components.burnable:IsBurning() and
                    "ANNOUNCE_NOSLEEPONFIRE")
                or (inst.IsNearDanger(inst) and "ANNOUNCE_NODANGERSLEEP")
                -- you can still sleep if your hunger will bottom out, but not absolutely
                or (inst.components.hunger.current < TUNING.CALORIES_MED and "ANNOUNCE_NOHUNGERSLEEP")
                or nil

            if failreason ~= nil then
                inst:PushEvent("performaction", { action = inst.bufferedaction })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, failreason))
                end
                return
            end

            inst.AnimState:PlayAnimation("pickup")
            inst.sg:SetTimeout(6 * FRAMES)

            SetSleeperSleepState(inst)
        end,

        ontimeout = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            if bufferedaction == nil then
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
                return
            end
            local tent = bufferedaction.target
            if tent == nil or
                not tent.components.sleepingbag or
                not tent:HasTag("tent") or
                tent:HasTag("hassleeper") or
                tent:HasTag("siestahut") ~= TheWorld.state.isday or
                (tent.components.burnable ~= nil and tent.components.burnable:IsBurning()) then
                --Edge cases, don't bother with fail dialogue
                --Also, think I will let smolderig pass this one
                inst:PushEvent("performaction", { action = inst.bufferedaction })
                inst:ClearBufferedAction()
                inst.AnimState:PlayAnimation("pickup_pst")
                inst.sg:GoToState("idle", true)
            else
                inst:PerformBufferedAction()
                inst.components.health:SetInvincible(true)
                inst:Hide()
                if inst.Physics ~= nil then
                    inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                end
                if inst.DynamicShadow ~= nil then
                    inst.DynamicShadow:Enable(false)
                end
                inst.sg:AddStateTag("sleeping")
                inst.sg:RemoveStateTag("busy")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst:Show()
            if inst.DynamicShadow ~= nil then
                inst.DynamicShadow:Enable(true)
            end
            if inst.sleepingbag ~= nil then
                --Interrupted while we are "sleeping"
                inst.sleepingbag.components.sleepingbag:DoWakeUp(true)
                inst.sleepingbag = nil
                SetSleeperAwakeState(inst)
            elseif not inst.sg.statemem.iswaking then
                --Interrupted before we are "sleeping"
                SetSleeperAwakeState(inst)
            end
        end,
    },

    State{
        name = "knockout",
        tags = { "busy", "knockout", "nopredict", "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.sg.statemem.isinsomniac = inst:HasTag("insomniac")

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
                inst.AnimState:PlayAnimation("fall_off")
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            else
                inst.AnimState:PlayAnimation(inst.sg.statemem.isinsomniac and "insomniac_dozy" or "dozy")
            end

            SetSleeperSleepState(inst)

            inst.sg:SetTimeout(TUNING.KNOCKOUT_SLEEP_TIME)
        end,

        ontimeout = function(inst)
            if inst.components.grogginess == nil then
                inst.sg.statemem.iswaking = true
                inst.sg:GoToState("wakeup")
            end
        end,

        events =
        {
            EventHandler("firedamage", function(inst)
                if inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("drowning") then
                    inst.sg.statemem.iswaking = true
                    inst.sg:GoToState("wakeup")
                else
                    inst.sg.statemem.cometo = true
                end
            end),
            EventHandler("cometo", function(inst)
                if inst.sg:HasStateTag("sleeping") and not inst.sg:HasStateTag("drowning") then
                    inst.sg.statemem.iswaking = true
                    inst.sg:GoToState("wakeup")
                else
                    inst.sg.statemem.cometo = true
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg:HasStateTag("dismounting") then
                        inst.sg:RemoveStateTag("dismounting")
                        inst.components.rider:ActualDismount()
                        inst.AnimState:PlayAnimation(inst.sg.statemem.isinsomniac and "insomniac_dozy" or "dozy")
                    elseif inst.sg.statemem.cometo then
                        inst.sg.statemem.iswaking = true
                        inst.sg:GoToState("wakeup")
                    else
                        inst.AnimState:PlayAnimation(inst.sg.statemem.isinsomniac and "insomniac_sleep_loop" or "sleep_loop", true)
                        inst.sg:AddStateTag("sleeping")
                    end
                end
            end),
        },

        onexit = function(inst)
            if inst.components.grogginess then
                inst.components.grogginess.knockedout = false
				inst.components.grogginess:CapToResistance()
            end
            if inst.sg:HasStateTag("dismounting") then
                --Interrupted
                inst.components.rider:ActualDismount()
            end
            if not inst.sg.statemem.iswaking then
                --Interrupted
                SetSleeperAwakeState(inst)
            end
        end,
    },

    State{
        name = "hit",
		tags = { "busy", "pausepredict", "keepchannelcasting" },

        onenter = function(inst, frozen)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation(
				inst:IsChannelCasting() and (
					inst:IsChannelCastingItem() and "channelcast_hit" or "channelcast_oh_hit"
				) or "hit"
			)

            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
            DoHurtSound(inst)

            --V2C: some of the woodie's were-transforms have shorter hit anims
			local stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), frozen and 10 or 6)
            if inst.components.playercontroller ~= nil then
                --Specify min frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(stun_frames <= 7 and stun_frames or nil)
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
			--V2C: -removing the tag now, since this is actually a supported "channeling_item"
			--      state (i.e. has custom anim)
			--     -the state enters with the tag though, to cheat having to create a separate
			--      hit state for channeling items
			inst.sg:RemoveStateTag("keepchannelcasting")
            inst.sg:GoToState("idle", true)
        end,

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
        name = "hit_souloverload",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(13 * FRAMES)
        end,

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

		onexit = CancelTalk_Override,
    },

    State{
        name = "hit_darkness",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            --V2C: Moved to pristine state in player_common
            --     since we never clear these extra symbols
            --inst.AnimState:AddOverrideBuild("player_hit_darkness")
            inst.AnimState:PlayAnimation("hit_darkness")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

            inst.sg:SetTimeout(24 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "hit_spike",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, spike)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            local anim = "short"

            if spike ~= nil and type(spike) == "table" then
                inst:ForceFacePoint(spike.Transform:GetWorldPosition())
                if spike.spikesize then
                    anim = spike.spikesize
                end
            else
                anim = spike
            end
            inst.AnimState:PlayAnimation("hit_spike_"..anim)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            inst.sg:SetTimeout(15 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "hit_push",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "startle",
        tags = { "busy" },

        onenter = function(inst, snap)
            local usehit = inst.components.rider:IsRiding() or inst:HasTag("wereplayer")
            local stun_frames = usehit and 6 or 9

            if snap then
                inst.sg:AddStateTag("nopredict")
            else
                inst.sg:AddStateTag("pausepredict")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction(stun_frames <= 7 and stun_frames or nil)
                end
            end

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if usehit then
                inst.AnimState:PlayAnimation("hit")
            else
                inst.AnimState:PlayAnimation("distress_pre")
                inst.AnimState:PushAnimation("distress_pst", false)
            end

            DoHurtSound(inst)

            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

   State{
        name = "mount_plank",
        tags = { "idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("plank_idle_pre")
            inst.AnimState:PushAnimation("plank_idle_loop", true)
            inst:AddTag("on_walkable_plank")
            inst:PerformBufferedAction()

            inst.sg:SetTimeout(180 * FRAMES)
        end,

        onexit = function(inst)
            if inst.bufferedaction == nil or inst.bufferedaction.action ~= ACTIONS.ABANDON_SHIP then
                inst.components.walkingplankuser:Dismount()
            end
            inst:RemoveTag("on_walkable_plank")
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("plank_idle_pst")
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "raiseanchor",
		tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
	            inst.sg.statemem.anchor = inst.bufferedaction.target
                if inst.bufferedaction.action.actionmeter then
                    inst.sg.statemem.actionmeter = true
                    StartActionMeter(inst, timeout)
                end
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
					inst.bufferedaction.target:PushEvent("startlongaction", inst)
                end
            end
			if inst.components.mightiness then
				inst.components.mightiness:Pause()
			end
            if not inst:PerformBufferedAction() then
                inst.sg:GoToState("idle")
            end
        end,

		timeline =
		{
			TimeEvent(4 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
		},

        events =
        {
            EventHandler("stopraisinganchor", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
			if inst.components.mightiness then
				inst.components.mightiness:Resume()
			end
            if inst.sg.statemem.actionmeter then
                StopActionMeter(inst, false)
            end
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			if inst.sg.statemem.anchor ~= nil and inst.sg.statemem.anchor:IsValid() then
	            inst.sg.statemem.anchor.components.anchor:RemoveAnchorRaiser(inst)
			end
        end,
    },

    State{
        name = "steer_boat_idle_pre",
        tags = { "is_using_steering_wheel", "doing" },

        onenter = function(inst, skip_pre)
            inst.Transform:SetNoFaced()
            inst.AnimState:PlayAnimation("steer_idle_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst:PerformBufferedAction() then
                        inst.sg.statemem.steering = true
                        inst.sg:GoToState("steer_boat_idle_loop", true)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.steering then
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "steer_boat_idle_loop",
        tags = { "is_using_steering_wheel", "doing" },

        onenter = function(inst, play_pre)
            inst.Transform:SetNoFaced()
            if play_pre then
                inst.AnimState:PlayAnimation("steer_idle_pre2")
            end
            inst.AnimState:PushAnimation("steer_idle_loop", true)
        end,

        onexit = function(inst)
            if not inst.sg.statemem.steering then
                inst.Transform:SetFourFaced()
            end
        end,

        events =
        {
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "steer_boat_turning",
        tags = { "is_using_steering_wheel", "doing", "is_turning_wheel" },

        onenter = function(inst, skip_action)
            if not skip_action then
                inst:PerformBufferedAction()
            end

            inst.Transform:SetNoFaced()
            if inst.components.steeringwheeluser.should_play_left_turn_anim then
                inst.AnimState:PlayAnimation("steer_left_pre", false)
                inst.AnimState:PushAnimation("steer_left_loop", true)
            else
                inst.AnimState:PlayAnimation("steer_right_pre", false)
                inst.AnimState:PushAnimation("steer_right_loop", true)
            end

            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/steering_wheel/LP", "turn")
        end,

        events =
        {
            EventHandler("playerstopturning", function(inst)
                inst.sg.statemem.steering = true
                inst.sg:GoToState("steer_boat_turning_pst")
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.steering then
                inst.Transform:SetFourFaced()
            end
            inst.SoundEmitter:KillSound("turn")
        end,
    },

    State{
        name = "steer_boat_turning_pst",
        tags = { "is_using_steering_wheel", "doing", "is_turning_wheel" },

        onenter = function(inst, skip_action)
            inst.Transform:SetNoFaced()
            if inst.components.steeringwheeluser.should_play_left_turn_anim then
                inst.AnimState:PlayAnimation("steer_left_pst", false)
            else
                inst.AnimState:PlayAnimation("steer_right_pst", false)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.steering then
                inst.Transform:SetFourFaced()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.steering = true
                    inst.sg:GoToState("steer_boat_idle_loop")
                end
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

   State{
        name = "stop_steering",
        tags = { "busy" },

        onenter = function(inst)
            inst.Transform:SetNoFaced()
            inst.AnimState:PlayAnimation("steer_idle_pst")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.Transform:SetFourFaced()
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        }
    },

    State{
        name = "aim_cannon_pre",
        tags = { "is_using_cannon", "doing" },

        onenter = function(inst)
            inst.Transform:SetEightFaced()
            inst.AnimState:PlayAnimation("aim_cannon_pre")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.boatcannonuser ~= nil and inst.components.boatcannonuser:GetCannon() ~= nil then
                        inst.sg.statemem.aiming = true
                        inst.sg:GoToState("aim_cannon_idle")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.aiming then
                inst.components.boatcannonuser:SetCannon(nil)
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "aim_cannon_idle",
        tags = { "is_using_cannon", "doing" },

        onenter = function(inst)
            inst.Transform:SetEightFaced()
            inst.AnimState:PlayAnimation("aim_cannon_loop", true)
        end,

        onexit = function(inst)
            if not inst.sg.statemem.aiming then
                inst.components.boatcannonuser:SetCannon(nil)
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "shoot_cannon",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.Transform:SetEightFaced()
            inst.AnimState:PlayAnimation("shoot_cannon")
            inst:PerformBufferedAction()
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.Transform:SetFourFaced()
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
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

        onexit = function(inst)
            if not inst.sg.statemem.aiming then
                inst.components.boatcannonuser:SetCannon(nil)
                inst.Transform:SetFourFaced()
            end
        end,
    },

    State{
        name = "aim_cannon_pst",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("aim_cannon_pst")
        end,

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
        name = "sink",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst, shore_pt)
            ForceStopHeavyLifting(inst)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:PlayAnimation("sink")
            inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/sinking")
            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
            end

            if shore_pt ~= nil then
                inst.components.drownable:OnFallInOcean(shore_pt:Get())
            else
                inst.components.drownable:OnFallInOcean()
            end
            inst.DynamicShadow:Enable(false)

            inst:ShowHUD(false)
        end,

        timeline =
        {
            TimeEvent(75 * FRAMES, function(inst)
                inst.components.drownable:DropInventory()
                inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    StartTeleporting(inst)

                    if inst.sg:HasStateTag("dismounting") then
                        inst.sg:RemoveStateTag("dismounting")

                        local mount = inst.components.rider:GetMount()
                        inst.components.rider:ActualDismount()
                        if mount ~= nil then
							if mount.components.drownable ~= nil then
								mount:Hide()
								mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
							elseif mount.components.health ~= nil then
								mount:Hide()
								mount.components.health:Kill()
							end
                        end
                    end

                    inst.components.drownable:WashAshore() -- TODO: try moving this into the timeline
                end
            end),

            EventHandler("on_washed_ashore", function(inst)
                inst.sg:GoToState("washed_ashore")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,
    },

    State{
        name = "sink_fast",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst, data)
            ForceStopHeavyLifting(inst)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:PlayAnimation("sink")
			inst.AnimState:SetFrame(60)
            inst.AnimState:Hide("plank")
            inst.AnimState:Hide("float_front")
            inst.AnimState:Hide("float_back")

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
            end

            inst.components.drownable:OnFallInOcean()
            inst.DynamicShadow:Enable(false)
            inst:ShowHUD(false)
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.AnimState:Show("float_front")
                inst.AnimState:Show("float_back")
            end),

            TimeEvent(16 * FRAMES, function(inst)
                inst.components.drownable:DropInventory()
            end),
        },


        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    StartTeleporting(inst)

                    if inst.components.rider ~= nil and inst.components.rider:IsRiding() then
                        local mount = inst.components.rider:GetMount()
                        inst.components.rider:ActualDismount()
                        if mount ~= nil then
							if mount.components.drownable ~= nil then
								mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
							elseif mount.components.health ~= nil then
								mount:Hide()
								mount.components.health:Kill()
							end
                        end
                    end

                    inst.components.drownable:WashAshore() -- TODO: try moving this into the timeline
                end
            end),

            EventHandler("on_washed_ashore", function(inst)
                inst.sg:GoToState("washed_ashore")
            end),
        },

        onexit = function(inst)
            inst.AnimState:Show("plank")
            inst.AnimState:Show("float_front")
            inst.AnimState:Show("float_back")
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,
    },


    State{
        name = "abandon_ship_pre",
        tags = { "doing", "busy", "drowning" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("plank_hop_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                        inst.sg:GoToState("abandon_ship")
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

   State{
        name = "abandon_ship",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph", "jumping", "drowning" },

        onenter = function(inst)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("plank_hop")

            inst:ShowHUD(false)
            if inst.components.drownable ~= nil then
                inst.components.drownable:OnFallInOcean()
            end

            inst.sg.statemem.speed = 6
            inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)
        end,

        timeline =
        {
            TimeEvent(.5 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.75, 0, 0)
            end),
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end),

            TimeEvent(12 * FRAMES, function(inst)
                -- TODO: Start camera fade here
            end),

            TimeEvent(15 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst.Physics:Stop()

                if TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) or inst.components.drownable == nil then
                    inst.sg:GoToState("idle")
                else
                    inst.components.drownable:DropInventory()
                end
            end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/medium") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.components.drownable ~= nil then
                        inst.components.drownable:WashAshore()
                        StartTeleporting(inst)
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),

            EventHandler("on_washed_ashore", function(inst)
                inst.sg:GoToState("washed_ashore")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,

    },

    State{
        name = "washed_ashore",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wakeup")
            if inst.components.drownable ~= nil then
                inst.components.drownable:TakeDrowningDamage()
            end

            local puddle = SpawnPrefab("washashore_puddle_fx")
            puddle.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_WASHED_ASHORE"))

                    inst.sg:GoToState("idle")
                end
            end),
        },


    },

    State{
        name = "cast_net",
        tags = { "doing", "busy" },

        onenter = function(inst, silent)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cast_pre")
            inst.AnimState:PushAnimation("cast_loop", true)
            --inst.sg.statemem.action = inst.bufferedaction
            --inst.sg.statemem.silent = silent
            --inst.sg:SetTimeout(10 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)

                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("begin_retrieving", function(inst)
                inst.sg:GoToState("cast_net_retrieving")
            end),
            },

        --[[
        ontimeout = function(inst)
            --pickup_pst should still be playing
            inst.sg:GoToState("idle", true)
        end,
        ]]--

        --[[
        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
        ]]--
    },

    State{
        name = "cast_net_retrieving",
        tags = { "doing", "busy" },

        onenter = function(inst, silent)
            inst.AnimState:PlayAnimation("cast_pst")
            inst.AnimState:PushAnimation("return_pre")
            inst.AnimState:PushAnimation("return_loop", true)
        end,

        events =
        {
            EventHandler("begin_final_pickup", function(inst)
                inst.sg:GoToState("cast_net_release")
            end),
        },
    },

    State{
        name = "cast_net_release",
        tags = { "doing", "busy" },

        onenter = function(inst, silent)
            inst.AnimState:PlayAnimation("release_loop", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("cast_net_release_pst")
            end),
        }
    },

    State{
        name = "cast_net_release_pst",
        tags = { "doing" },

        onenter = function(inst, silent)
            inst.sg:RemoveStateTag("busy")
            inst.AnimState:PlayAnimation("release_pst", false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "oceanfishing_cast",
        tags = { "prefish", "fishing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pre")
            inst.AnimState:PushAnimation("fishing_ocean_cast", false)
            inst.AnimState:PushAnimation("fishing_ocean_cast_loop", true)
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast")
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast_ocean")
                inst.sg:RemoveStateTag("prefish")
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("newfishingtarget", function(inst, data)
                if data ~= nil and data.target ~= nil and not data.target:HasTag("projectile") then
                    inst.sg.statemem.hooklanded = true
                    inst.AnimState:PushAnimation("fishing_ocean_cast_pst", false)
                end
            end),

            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.hooklanded and inst.AnimState:AnimDone() then
                    inst.sg:GoToState("oceanfishing_idle")
                end
            end),
        },
    },

    State{
        name = "oceanfishing_idle",
        tags = { "fishing", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local target = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod.components.oceanfishingrod.target or nil
            if target ~= nil and target.components.oceanfishinghook ~= nil and TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN > 0 then
                inst.sg:SetTimeout(TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN + math.random() * TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_VAR)
            end
        end,

        onupdate = function(inst)
            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
            if target ~= nil then
                if target.components.oceanfishinghook ~= nil then
					inst.SoundEmitter:KillSound("unreel_loop")
					if not inst.AnimState:IsCurrentAnimation("hooked_loose_idle") then
						inst.AnimState:PlayAnimation("hooked_loose_idle", true)
					end
				else
					if rod.components.oceanfishingrod:IsLineTensionLow() then
						inst.SoundEmitter:KillSound("unreel_loop")
						if not inst.AnimState:IsCurrentAnimation("hooked_loose_idle") then
							inst.AnimState:PlayAnimation("hooked_loose_idle", true)
						end
					elseif rod.components.oceanfishingrod:IsLineTensionGood() then
						if target.components.oceanfishable ~= nil and target.components.oceanfishable:IsStruggling() then
							if not inst.SoundEmitter:PlayingSound("unreel_loop") then
								inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_strain", "unreel_loop")
							end
			                inst.SoundEmitter:SetParameter("unreel_loop", "tension", 0.0)
						else
							inst.SoundEmitter:KillSound("unreel_loop")
						end
						if not inst.AnimState:IsCurrentAnimation("hooked_good_idle") then
							inst.AnimState:PlayAnimation("hooked_good_idle", true)
						end
					else
						if not inst.SoundEmitter:PlayingSound("unreel_loop") then
							inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_strain", "unreel_loop")
						end
		                inst.SoundEmitter:SetParameter("unreel_loop", "tension", 1.0)
						if not inst.AnimState:IsCurrentAnimation("hooked_tight_idle") then
							inst.AnimState:PlayAnimation("hooked_tight_idle", true)
						end
					end
				end
			end
        end,

        ontimeout = function(inst)
            if inst.components.talker ~= nil then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_OCEANFISHING_IDLE_QUOTE"), nil, nil, true)

                inst.sg:SetTimeout(inst.sg.timeinstate + TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_MIN + math.random() * TUNING.OCEAN_FISHING.IDLE_QUOTE_TIME_VAR)
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("unreel_loop")
            inst:RemoveTag("fishing_idle")
        end,
    },

    State{
        name = "oceanfishing_reel",
        tags = { "fishing", "doing", "reeling", "canrotate" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.components.locomotor:Stop()

            local rod = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            rod = (rod ~= nil and rod.components.oceanfishingrod ~= nil) and rod or nil
            local target = rod ~= nil and rod.components.oceanfishingrod.target or nil
            if target == nil then
                inst:ClearBufferedAction()
            else
                if inst:PerformBufferedAction() then
                    if target.components.oceanfishinghook ~= nil or rod.components.oceanfishingrod:IsLineTensionLow() then
                        inst.SoundEmitter:KillSound("reel_loop")
						inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in1_LP", "reel_loop")
                        if not inst.AnimState:IsCurrentAnimation("hooked_loose_reeling") then
                            inst.AnimState:PlayAnimation("hooked_loose_reeling", true)
                        end
                    elseif rod.components.oceanfishingrod:IsLineTensionGood() then
                        inst.SoundEmitter:KillSound("reel_loop")
						inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in2_LP", "reel_loop")
                        if not inst.AnimState:IsCurrentAnimation("hooked_good_reeling") then
                            inst.AnimState:PlayAnimation("hooked_good_reeling", true)
                        end
                    else
                        inst.SoundEmitter:KillSound("reel_loop")
						inst.SoundEmitter:PlaySound("dontstarve/common/fishpole_reel_in3_LP", "reel_loop")
						if not inst.AnimState:IsCurrentAnimation("hooked_tight_reeling") then
                            inst.AnimState:PlayAnimation("hooked_tight_reeling", true)
                        end
					end

                    inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
                end

            end
        end,

        timeline =
        {
            TimeEvent(TUNING.OCEAN_FISHING.REEL_ACTION_REPEAT_DELAY, function(inst) inst.sg.statemem.allow_repeat = true end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("oceanfishing_idle")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("reel_loop")
            inst:RemoveTag("fishing_idle")
        end,
    },


    State{
        name = "oceanfishing_sethook",
        tags = { "fishing", "doing", "busy" },

        onenter = function(inst)
            inst:AddTag("fishing_idle")
            inst.components.locomotor:Stop()

            --inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught_ocean")
            inst.AnimState:PlayAnimation("fishing_ocean_bite_heavy_pre")
            inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_loop", false)

            inst:PerformBufferedAction()
        end,

        timeline =
        {
--            TimeEvent(2*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("oceanfishing_idle") end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("sethook_loop")
            inst:RemoveTag("fishing_idle")
        end,
    },

    State{
        name = "oceanfishing_catch",
        tags = { "fishing", "catchfish", "busy" },

        onenter = function(inst, build)
            inst.AnimState:PlayAnimation("fishing_ocean_catch")
        end,

        timeline =
        {
--            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
        end,
    },

    State{
        name = "oceanfishing_stop",
        tags = { "fishing" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_ocean_pst")

            if data ~= nil and data.escaped_str and inst.components.talker ~= nil then
                inst.components.talker:Say(GetString(inst, data.escaped_str), nil, nil, true)
            end
        end,

        timeline =
        {
--            TimeEvent(18*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "oceanfishing_linesnapped",
        tags = { "busy", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("line_snap")
            inst.sg.statemem.escaped_str = data ~= nil and data.escaped_str or nil
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_linebreak")
            end),
            TimeEvent(29*FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, inst.sg.statemem.escaped_str or "ANNOUNCE_OCEANFISHING_LINESNAP"), nil, nil, true)
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "repelled",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

			--V2C: in case mount or woodie's were-transforms have shorter hit anims
			local stun_frames = 9
            if inst.components.rider:IsRiding() or inst:HasTag("wereplayer") then
                inst.AnimState:PlayAnimation("hit")
				stun_frames = math.min(inst.AnimState:GetCurrentAnimationNumFrames(), stun_frames)
            else
                inst.AnimState:PlayAnimation("distress_pre")
                inst.AnimState:PushAnimation("distress_pst", false)
            end

            DoHurtSound(inst)

			if data ~= nil then
				if data.knocker ~= nil then
					inst.sg:AddStateTag("nointerrupt")
				end
				if data.radius ~= nil and data.repeller ~= nil and data.repeller:IsValid() then
					local x, y, z = data.repeller.Transform:GetWorldPosition()
					local distsq = inst:GetDistanceSqToPoint(x, y, z)
					local rangesq = data.radius * data.radius
					if distsq < rangesq then
						if distsq > 0 then
							inst:ForceFacePoint(x, y, z)
						end
						local k = .5 * distsq / rangesq - 1
						inst.sg.statemem.speed = (data.strengthmult or 1) * 25 * k
						inst.sg.statemem.dspeed = 2
						inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
					end
				end
			end

			inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .25
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
        end,

		timeline =
		{
			FrameEvent(4, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
			end),
		},

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "knockback",
		tags = { "busy", "nopredict", "nomorph", "nodangle", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.rider:ActualDismount()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

			inst.AnimState:PlayAnimation("knockback_high")

            if data ~= nil then
                if data.disablecollision then
                    ToggleOffPhysics(inst)
                    inst.Physics:CollidesWith(COLLISION.WORLD)
                end
                if data.propsmashed then
                    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local pos
                    if item ~= nil then
                        pos = inst:GetPosition()
                        pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_HIGH
                        local dropped = inst.components.inventory:DropItem(item, true, true, pos)
                        if dropped ~= nil then
                            dropped:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_HIGH, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_HIGH })
                        end
                    end
                    if item == nil or not item:HasTag("propweapon") then
                        item = inst.components.inventory:FindItem(IsMinigameItem)
                        if item ~= nil then
                            pos = pos or inst:GetPosition()
                            pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_LOW
                            item = inst.components.inventory:DropItem(item, false, true, pos)
                            if item ~= nil then
                                item:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_LOW, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_LOW })
                            end
                        end
                    end
                end
                if data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 12 * k
                    inst.sg.statemem.dspeed = 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end
			if not inst.sg.statemem.isphysicstoggle then
				if inst:IsOnPassablePoint(true) then
					inst.sg.statemem.safepos = inst:GetPosition()
				elseif data ~= nil and data.knocker ~= nil and data.knocker:IsValid() and data.knocker:IsOnPassablePoint(true) then
					local x1, y1, z1 = data.knocker.Transform:GetWorldPosition()
					local radius = data.knocker:GetPhysicsRadius(0) - inst:GetPhysicsRadius(0)
					if radius > 0 then
						local x, y, z = inst.Transform:GetWorldPosition()
						local dx = x - x1
						local dz = z - z1
						local dist = radius / math.sqrt(dx * dx + dz * dz)
						x = x1 + dx * dist
						z = z1 + dz * dist
						if TheWorld.Map:IsPassableAtPoint(x, 0, z, true) then
							x1, z1 = x, z
						end
					end
					inst.sg.statemem.safepos = Vector3(x1, 0, z1)
				end
			end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .075
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
			local safepos = inst.sg.statemem.safepos
			if safepos ~= nil then
				if inst:IsOnPassablePoint(true) then
					safepos.x, safepos.y, safepos.z = inst.Transform:GetWorldPosition()
				elseif inst.sg.statemem.landed then
					local mass = inst.Physics:GetMass()
					if mass > 0 then
						inst.sg.statemem.restoremass = mass
						inst.Physics:SetMass(99999)
					end
					inst.Physics:Teleport(safepos.x, 0, safepos.z)
					inst.sg.statemem.safepos = nil
				end
			end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
			FrameEvent(10, function(inst)
				inst.sg.statemem.landed = true
				inst.sg:RemoveStateTag("nointerrupt")
				inst.sg:RemoveStateTag("jumping")
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("knockback_pst")
                end
            end),
        },

        onexit = function(inst)
			if inst.sg.statemem.restoremass ~= nil then
				inst.Physics:SetMass(inst.sg.statemem.restoremass)
			end
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "knockback_pst",
        tags = { "knockback", "busy", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("buck_pst")
        end,

        timeline =
        {
            TimeEvent(27 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("knockback")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nomorph")
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
        name = "knockbacklanded",
		tags = { "knockback", "busy", "nopredict", "nomorph", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.rider:ActualDismount()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit_spike_heavy")

            if data ~= nil then
                if data.propsmashed then
                    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    local pos
                    if item ~= nil then
                        pos = inst:GetPosition()
                        pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_LOW
                        local dropped = inst.components.inventory:DropItem(item, true, true, pos)
                        if dropped ~= nil then
                            dropped:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_LOW, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_LOW })
                        end
                    end
                    if item == nil or not item:HasTag("propweapon") then
                        item = inst.components.inventory:FindItem(IsMinigameItem)
                        if item ~= nil then
                            if pos == nil then
                                pos = inst:GetPosition()
                                pos.y = TUNING.KNOCKBACK_DROP_ITEM_HEIGHT_LOW
                            end
                            item = inst.components.inventory:DropItem(item, false, true, pos)
                            if item ~= nil then
                                item:PushEvent("knockbackdropped", { owner = inst, knocker = data.knocker, delayinteraction = TUNING.KNOCKBACK_DELAY_INTERACTION_LOW, delayplayerinteraction = TUNING.KNOCKBACK_DELAY_PLAYER_INTERACTION_LOW })
                            end
                        end
                    end
                end
                if data.radius ~= nil and data.knocker ~= nil and data.knocker:IsValid() then
                    local x, y, z = data.knocker.Transform:GetWorldPosition()
                    local distsq = inst:GetDistanceSqToPoint(x, y, z)
                    local rangesq = data.radius * data.radius
                    local rot = inst.Transform:GetRotation()
                    local rot1 = distsq > 0 and inst:GetAngleToPoint(x, y, z) or data.knocker.Transform:GetRotation() + 180
                    local drot = math.abs(rot - rot1)
                    while drot > 180 do
                        drot = math.abs(drot - 360)
                    end
                    local k = distsq < rangesq and .3 * distsq / rangesq - 1 or -.7
                    inst.sg.statemem.speed = (data.strengthmult or 1) * 8 * k
                    inst.sg.statemem.dspeed = 0
                    if drot > 90 then
                        inst.sg.statemem.reverse = true
                        inst.Transform:SetRotation(rot1 + 180)
                        inst.Physics:SetMotorVel(-inst.sg.statemem.speed, 0, 0)
                    else
                        inst.Transform:SetRotation(rot1)
                        inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                    end
                end
            end

			if inst:IsOnPassablePoint(true) then
				inst.sg.statemem.safepos = inst:GetPosition()
			elseif data ~= nil and data.knocker ~= nil and data.knocker:IsValid() and data.knocker:IsOnPassablePoint(true) then
				local x1, y1, z1 = data.knocker.Transform:GetWorldPosition()
				local radius = data.knocker:GetPhysicsRadius(0) - inst:GetPhysicsRadius(0)
				if radius > 0 then
					local x, y, z = inst.Transform:GetWorldPosition()
					local dx = x - x1
					local dz = z - z1
					local dist = radius / math.sqrt(dx * dx + dz * dz)
					x = x1 + dx * dist
					z = z1 + dz * dist
					if TheWorld.Map:IsPassableAtPoint(x, 0, z, true) then
						x1, z1 = x, z
					end
				end
				inst.sg.statemem.safepos = Vector3(x1, 0, z1)
			end

            inst.sg:SetTimeout(11 * FRAMES)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed ~= nil then
                inst.sg.statemem.speed = inst.sg.statemem.speed + inst.sg.statemem.dspeed
                if inst.sg.statemem.speed < 0 then
                    inst.sg.statemem.dspeed = inst.sg.statemem.dspeed + .075
                    inst.Physics:SetMotorVel(inst.sg.statemem.reverse and -inst.sg.statemem.speed or inst.sg.statemem.speed, 0, 0)
                else
                    inst.sg.statemem.speed = nil
                    inst.sg.statemem.dspeed = nil
                    inst.Physics:Stop()
                end
            end
			local safepos = inst.sg.statemem.safepos
			if safepos ~= nil then
				if inst:IsOnPassablePoint(true) then
					safepos.x, safepos.y, safepos.z = inst.Transform:GetWorldPosition()
				elseif inst.sg.statemem.landed then
					local mass = inst.Physics:GetMass()
					if mass > 0 then
						inst.sg.statemem.restoremass = mass
						inst.Physics:SetMass(99999)
					end
					inst.Physics:Teleport(safepos.x, 0, safepos.z)
					inst.sg.statemem.safepos = nil
				end
			end
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
			FrameEvent(10, function(inst)
				inst.sg.statemem.landed = true
				inst.sg:RemoveStateTag("nointerrupt")
				inst.sg:RemoveStateTag("jumping")
			end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
			if inst.sg.statemem.restoremass ~= nil then
				inst.Physics:SetMass(inst.sg.statemem.restoremass)
			end
            if inst.sg.statemem.speed ~= nil then
                inst.Physics:Stop()
            end
        end,
    },

    State{
        name = "mindcontrolled",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
                inst.AnimState:PlayAnimation("fall_off")
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            else
                inst.AnimState:PlayAnimation("mindcontrol_pre")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg:HasStateTag("dismounting") then
                        inst.sg:RemoveStateTag("dismounting")
                        inst.components.rider:ActualDismount()
                        inst.AnimState:PlayAnimation("mindcontrol_pre")
                    else
                        inst.sg.statemem.mindcontrolled = true
                        inst.sg:GoToState("mindcontrolled_loop")
                    end
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("dismounting") then
                --interrupted
                inst.components.rider:ActualDismount()
            end
            if not inst.sg.statemem.mindcontrolled then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
            end
        end,
    },

    State{
        name = "mindcontrolled_loop",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("mindcontrol_loop") then
                inst.AnimState:PlayAnimation("mindcontrol_loop", true)
            end
            inst.sg:SetTimeout(3 * FRAMES)
        end,

        events =
        {
            EventHandler("mindcontrolled", function(inst)
                inst.sg.statemem.mindcontrolled = true
                inst.sg:GoToState("mindcontrolled_loop")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("mindcontrolled_pst")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.mindcontrolled then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
            end
        end,
    },

    State{
        name = "mindcontrolled_pst",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("mindcontrol_pst")

            --Should be coming from "mindcontrolled" state
            --[[
            local stun_frames = 6
            if inst.components.playercontroller ~= nil then
                --Specify min frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(stun_frames)
            end]]
            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

	State{
		name = "devoured",
		tags = { "devoured", "invisible", "noattack", "notalking", "nointerrupt", "busy", "nopredict", "silentmorph" },

		onenter = function(inst, attacker)
			ClearStatusAilments(inst)
			ForceStopHeavyLifting(inst)
			local mount = inst.components.rider:ActualDismount()
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("empty")
			inst:ShowHUD(false)
			inst:SetCameraDistance(14)
			inst:Hide()
			inst.DynamicShadow:Enable(false)
			ToggleOffPhysics(inst)
			if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:Enable(false)
			end
			StopTalkSound(inst, true)
			if inst.components.talker ~= nil then
				inst.components.talker:ShutUp()
				inst.components.talker:IgnoreAll("devoured")
			end
			if attacker ~= nil and attacker:IsValid() then
				inst.sg.statemem.attacker = attacker
				if mount ~= nil then
					--use true physics radius if available
					local radius = attacker.Physics ~= nil and attacker.Physics:GetRadius() or attacker:GetPhysicsRadius(0)
					if radius > 0 then
						local dir = attacker:GetAngleToPoint(inst.Transform:GetWorldPosition()) * DEGREES
						local x, y, z = attacker.Transform:GetWorldPosition()
						x = x + radius * math.cos(dir)
						z = z - radius * math.sin(dir)
						if TheWorld.Map:IsPassableAtPoint(x, 0, z) then
							if mount.Physics ~= nil then
								mount.Physics:Teleport(x, 0, z)
							else
								mount.Transform:SetPosition(x, 0, z)
							end
						end
					end
				end
				inst.Transform:SetRotation(attacker.Transform:GetRotation() + 180)
			end
		end,

		onupdate = function(inst)
			local attacker = inst.sg.statemem.attacker
			if attacker:IsValid() then
				inst.Transform:SetPosition(attacker.Transform:GetWorldPosition())
				inst.Transform:SetRotation(attacker.Transform:GetRotation() + 180)
			else
				inst.sg:GoToState("idle")
			end
		end,

		events =
		{
			EventHandler("spitout", function(inst, data)
				local attacker = data ~= nil and data.spitter or inst.sg.statemem.attacker
				if attacker ~= nil and attacker:IsValid() then
					local rot = attacker.Transform:GetRotation()
					inst.Transform:SetRotation(rot + 180)
					local physradius = attacker:GetPhysicsRadius(0)
					if physradius > 0 then
						local x, y, z = inst.Transform:GetWorldPosition()
						rot = rot * DEGREES
						x = x + math.cos(rot) * physradius
						z = z - math.sin(rot) * physradius
						inst.Physics:Teleport(x, 0, z)
					end
					DoHurtSound(inst)
					inst.sg:HandleEvent("knockback", {
						knocker = attacker,
						radius = data ~= nil and data.radius or physradius + 1,
						strengthmult = data ~= nil and data.strengthmult or nil,
					})
				else
					inst.sg:HandleEvent("knockback")
				end
				--NOTE: ignores heavy armor/body
			end),
		},

		onexit = function(inst)
			if inst.components.health:IsDead() then
				local attacker = inst.sg.statemem.attacker
				if attacker ~= nil and attacker:IsValid() then
					local rot = attacker.Transform:GetRotation()
					inst.Transform:SetRotation(rot + 180)
					--use true physics radius if available
					local radius = attacker.Physics ~= nil and attacker.Physics:GetRadius() or attacker:GetPhysicsRadius(0)
					if radius > 0 then
						local x, y, z = inst.Transform:GetWorldPosition()
						rot = rot * DEGREES
						x = x + math.cos(rot) * radius
						z = z - math.sin(rot) * radius
						if TheWorld.Map:IsPassableAtPoint(x, 0, z, true) then
							inst.Physics:Teleport(x, 0, z)
						end
					end
				end
			end
			inst:ShowHUD(true)
			inst:SetCameraDistance()
			inst:Show()
			inst.DynamicShadow:Enable(true)
			if inst.sg.statemem.isphysicstoggle then
				ToggleOnPhysics(inst)
			end
			inst.entity:SetParent(nil)
			if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:Enable(true)
			end
			if inst.components.talker ~= nil then
				inst.components.talker:StopIgnoringAll("devoured")
			end
		end,
	},

    State{
        name = "toolbroke",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, tool)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            if tool == nil or not tool.nobrokentoolfx then
                SpawnPrefab("brokentool").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end

            inst.sg.statemem.toolname = tool ~= nil and tool.prefab or nil

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.toolname ~= nil then
                local sameTool = inst.components.inventory:FindItem(function(item)
					return item.prefab == inst.sg.statemem.toolname and item.components.equippable ~= nil
                end)
                if sameTool ~= nil then
                    inst.components.inventory:Equip(sameTool)
                end
            end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "tool_slip",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/common/tool_slip")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            local splash = SpawnPrefab("splash")
            splash.entity:SetParent(inst.entity)
            splash.entity:AddFollower()
            splash.Follower:FollowSymbol(inst.GUID, "swap_object", 0, 0, 0)

            if inst.components.talker ~= nil then
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_TOOL_SLIP"))
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "armorbroke",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)

            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_armour_break")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.sg:SetTimeout(10 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    },

    State{
        name = "spooked",
        tags = { "busy", "pausepredict" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("spooked")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                if inst.components.talker ~= nil then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_SPOOKED"))
                end
            end),
            TimeEvent(49 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
            end),
        },

        events =
        {
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = CancelTalk_Override,
    },

    State{
        name = "teleportato_teleport",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("teleport")
            inst:ShowHUD(false)
            inst:SetCameraDistance(20)
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_pulled")
            end),
            TimeEvent(82*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/teleportato/teleportato_under")
            end),
        },

        onexit = function(inst)
            inst:ShowHUD(true)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.components.health:SetInvincible(false)
        end,
    },

    State{
        name = "amulet_rebirth",
        tags = { "busy", "nopredict", "silentmorph" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("amulet_rebirth")
            inst.AnimState:OverrideSymbol("FX", "player_amulet_resurrect", "FX")
            inst.components.health:SetInvincible(true)
            inst:ShowHUD(false)
            inst:SetCameraDistance(14)

            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if item ~= nil and item.prefab == "amulet" then
                item = inst.components.inventory:RemoveItem(item)
                if item ~= nil then
                    item:Remove()
                    inst.sg.statemem.usedamulet = true
                end
            end
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                local stafflight = SpawnPrefab("staff_castinglight")
                stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                stafflight:SetUp({ 150 / 255, 46 / 255, 46 / 255 }, 1.7, 1)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_raise")
            end),
            TimeEvent(60 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_poof")
            end),
            TimeEvent(80 * FRAMES, function(inst)
                local x, y, z = inst.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, 10)
                for k, v in pairs(ents) do
                    if v ~= inst and v.components.sleeper ~= nil then
                        v.components.sleeper:GoToSleep(20)
                    end
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

        onexit = function(inst)
            if inst.sg.statemem.usedamulet and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY) == nil then
                inst.AnimState:ClearOverrideSymbol("swap_body")
            end
            inst:ShowHUD(true)
            inst:SetCameraDistance()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.components.health:SetInvincible(false)
            inst.AnimState:ClearOverrideSymbol("FX")

            SerializeUserSession(inst)
        end,
    },

    State{
        name = "portal_rez",
        tags = { "busy", "nopredict", "silentmorph" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst:ShowHUD(false)
            inst:SetCameraDistance(14)
            inst.AnimState:SetMultColour(0, 0, 0, 1)
            inst:Hide()
            inst.DynamicShadow:Enable(false)
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst:Show()
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(72 * FRAMES, function(inst)
                inst.components.colourtweener:StartTween(
                    { 1, 1, 1, 1 },
                    14 * FRAMES,
                    function(inst)
                        if inst.sg.currentstate.name == "portal_rez" then
                            inst.sg.statemem.istweencomplete = true
                            inst.sg:GoToState("idle")
                        end
                    end)
            end),
        },

        onexit = function(inst)
            --In case of interruptions
            inst:Show()
            inst.DynamicShadow:Enable(true)
            --
            inst:ShowHUD(true)
            inst:SetCameraDistance()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.components.health:SetInvincible(false)

            SerializeUserSession(inst)

            --In case of interruptions
            if not inst.sg.statemem.istweencomplete then
                if inst.components.colourtweener:IsTweening() then
                    inst.components.colourtweener:EndTween()
                else
                    inst.AnimState:SetMultColour(1, 1, 1, 1)
                end

            end
        end,
    },

    State{
        name = "reviver_rebirth",
        tags = { "busy", "reviver_rebirth", "pausepredict", "silentmorph", "ghostbuild" },

        onenter = function(inst)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            SpawnPrefab("ghost_transform_overlay_fx").entity:SetParent(inst.entity)

            inst.SoundEmitter:PlaySound("dontstarve/ghost/player_revive")
            if inst.CustomSetSkinMode ~= nil then
                inst:CustomSetSkinMode(inst.overrideghostskinmode or "ghost_skin")
            else
                inst.AnimState:SetBank("ghost")
                inst.components.skinner:SetSkinMode(inst.overrideghostskinmode or "ghost_skin")
            end
            inst.AnimState:PlayAnimation("shudder")
            inst.AnimState:PushAnimation("brace", false)
            inst.AnimState:PushAnimation("transform", false)
            inst.components.health:SetInvincible(true)
            inst:ShowHUD(false)
            inst:SetCameraDistance(14)

            inst:PushEvent("startghostbuildinstate")
        end,

        timeline =
        {
            TimeEvent(88 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                inst:ApplySkinOverrides()
                inst.AnimState:PlayAnimation("transform_end")
                -- inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_use_bloodpump")
                inst.sg:RemoveStateTag("ghostbuild")
                inst:PushEvent("stopghostbuildinstate")
            end),
            TimeEvent(89 * FRAMES, function(inst)
                if inst:HasTag("weregoose") then
                    DoGooseRunFX(inst)
                end
            end),
            TimeEvent(96 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("playerghostbloom")
                inst.AnimState:SetLightOverride(0)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            --In case of interruptions
            inst.DynamicShadow:Enable(true)
            inst:ApplySkinOverrides()
            inst.components.bloomer:PopBloom("playerghostbloom")
            inst.AnimState:SetLightOverride(0)
            if inst.sg:HasStateTag("ghostbuild") then
                inst.sg:RemoveStateTag("ghostbuild")
                inst:PushEvent("stopghostbuildinstate")
            end
            --
            inst.components.health:SetInvincible(false)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end

            inst:ShowHUD(true)
            inst:SetCameraDistance()

            SerializeUserSession(inst)
        end,
    },

    State{
        name = "rewindtime_rebirth",
        tags = { "busy", "busy", "nopredict", "silentmorph" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("death_reverse")

            inst.sg:AddStateTag("nopredict")
            inst.sg:AddStateTag("silentmorph")
            inst.sg:RemoveStateTag("nomorph")
            inst.components.health:SetInvincible(false)
            inst:ShowHUD(false)
            inst:SetCameraDistance(12)
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("wanda1/wanda/rewindtime_rebirth")
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

        onexit = function(inst)
            SetSleeperAwakeState(inst)
            inst:ShowHUD(true)
            inst:SetCameraDistance()
            SerializeUserSession(inst)
        end,
    },

    State{
        name = "corpse",
        tags = { "busy", "dead", "noattack", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst, fromload)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end

            inst:PushEvent("playerdied", { loading = fromload, skeleton = false })

            inst:ShowActions(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("death2_idle")
        end,

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst:ShowActions(true)
            inst.components.health:SetInvincible(false)
        end,
    },

    State{
        name = "corpse_rebirth",
        tags = { "busy", "noattack", "nopredict", "nomorph" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            inst.AnimState:PlayAnimation("death2_idle")

            inst.components.health:SetInvincible(true)
            inst:ShowActions(false)
            inst:SetCameraDistance(14)
        end,

        timeline =
        {
            TimeEvent(53 * FRAMES, function(inst)
                inst.components.bloomer:PushBloom("corpse_rebirth", "shaders/anim.ksh", -2)
                inst.sg.statemem.fadeintime = (86 - 53) * FRAMES
                inst.sg.statemem.fadetime = 0
            end),
            TimeEvent(86 * FRAMES, function(inst)
                inst.sg.statemem.physicsrestored = true
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.WORLD)
                inst.Physics:CollidesWith(COLLISION.OBSTACLES)
                inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)

                inst.AnimState:PlayAnimation("corpse_revive")
                if inst.sg.statemem.fade ~= nil then
                    inst.sg.statemem.fadeouttime = 20 * FRAMES
                    inst.sg.statemem.fadetotal = inst.sg.statemem.fade
                end
                inst.sg.statemem.fadeintime = nil
            end),
            TimeEvent((86 + 20) * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("corpse_rebirth")
            end),
        },

        onupdate = function(inst, dt)
            if inst.sg.statemem.fadeouttime ~= nil then
                inst.sg.statemem.fade = math.max(0, inst.sg.statemem.fade - inst.sg.statemem.fadetotal * dt / inst.sg.statemem.fadeouttime)
                if inst.sg.statemem.fade > 0 then
                    inst.components.colouradder:PushColour("corpse_rebirth", inst.sg.statemem.fade, inst.sg.statemem.fade, inst.sg.statemem.fade, 0)
                else
                    inst.components.colouradder:PopColour("corpse_rebirth")
                    inst.sg.statemem.fadeouttime = nil
                end
            elseif inst.sg.statemem.fadeintime ~= nil then
                local k = 1 - inst.sg.statemem.fadetime / inst.sg.statemem.fadeintime
                inst.sg.statemem.fade = .8 * (1 - k * k)
                inst.components.colouradder:PushColour("corpse_rebirth", inst.sg.statemem.fade, inst.sg.statemem.fade, inst.sg.statemem.fade, 0)
                inst.sg.statemem.fadetime = inst.sg.statemem.fadetime + dt
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and inst.AnimState:IsCurrentAnimation("corpse_revive") then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_REVIVED_FROM_CORPSE"))
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst:ShowActions(true)
            inst:SetCameraDistance()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.components.health:SetInvincible(false)

            inst.components.bloomer:PopBloom("corpse_rebirth")
            inst.components.colouradder:PopColour("corpse_rebirth")

            if not inst.sg.statemem.physicsrestored then
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.WORLD)
                inst.Physics:CollidesWith(COLLISION.OBSTACLES)
                inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)
            end

            SerializeUserSession(inst)
        end,
    },

    State{
        name = "jumpin_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.components.inventory:IsHeavyLifting() and "heavy_jump_pre" or "jump_pre", false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "jumpin",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.teleporter
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

            local pos = nil
            if data.teleporter ~= nil and data.teleporter.components.teleporter ~= nil then
                data.teleporter.components.teleporter:RegisterTeleportee(inst)
                pos = data.teleporter:GetPosition()
            end
            inst.sg.statemem.teleporterexit = data.teleporterexit -- Can be nil.

            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_jump" or "jump")

            local MAX_JUMPIN_DIST = 3
            local MAX_JUMPIN_DIST_SQ = MAX_JUMPIN_DIST * MAX_JUMPIN_DIST
            local MAX_JUMPIN_SPEED = 6

            local dist
            if pos ~= nil then
                inst:ForceFacePoint(pos:Get())
                local distsq = inst:GetDistanceSqToPoint(pos:Get())
                if distsq <= .25 * .25 then
                    dist = 0
                    inst.sg.statemem.speed = 0
                elseif distsq >= MAX_JUMPIN_DIST_SQ then
                    dist = MAX_JUMPIN_DIST
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED
                else
                    dist = math.sqrt(distsq)
                    inst.sg.statemem.speed = MAX_JUMPIN_SPEED * dist / MAX_JUMPIN_DIST
                end
            else
                inst.sg.statemem.speed = 0
                dist = 0
            end

            inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)

            inst.sg.statemem.teleportarrivestate = "jumpout" -- this can be overriden in the teleporter component
        end,

        timeline =
        {
            TimeEvent(.5 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.speed * (inst.sg.statemem.heavy and .55 or .75), 0, 0)
            end),
            TimeEvent(1 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.heavy and inst.sg.statemem.speed * .6 or inst.sg.statemem.speed, 0, 0)
            end),

            -- NORMAL WHOOSH SOUND GOES HERE
            TimeEvent(1 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    --print ("START NORMAL JUMPING SOUND")
                    inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
                end
            end),

            -- HEAVY WHOOSH SOUND GOES HERE
            TimeEvent(5 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    --print ("START HEAVY JUMPING SOUND")
                    inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
                end
            end),

            --Heavy lifting
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)
                end
            end),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed * .4, 0, 0)
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed * .3, 0, 0)
                end
            end),

            --Normal
            TimeEvent(15 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:Stop()
                end

                -- this is just hacked in here to make the sound play BEFORE the player hits the wormhole
                if inst.sg.statemem.target ~= nil then
                    if inst.sg.statemem.target:IsValid() then
                        inst.sg.statemem.target:PushEvent("starttravelsound", inst)
                    else
                        inst.sg.statemem.target = nil
                    end
                end
            end),

            --Heavy lifting
            TimeEvent(20 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:Stop()
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local should_teleport = false
                    if inst.sg.statemem.target ~= nil and
                        inst.sg.statemem.target:IsValid() and
                        inst.sg.statemem.target.components.teleporter ~= nil then
                        --Unregister first before actually teleporting
                        inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
                        local teleporterexit = inst.sg.statemem.teleporterexit
                        if teleporterexit then
                            if not teleporterexit:IsValid() then
								teleporterexit = teleporterexit.overtakenhole
								--this is just for an overtaken tentacle_pillar, otherwise nil
                            end
                            if inst.sg.statemem.target.components.teleporter:UseTemporaryExit(inst, teleporterexit) then
                                should_teleport = true
                            end
                        else
                            if inst.sg.statemem.target.components.teleporter:Activate(inst) then
                                should_teleport = true
                            end
                        end
                    end
                    if should_teleport then
                        inst.sg.statemem.isteleporting = true
                        inst.components.health:SetInvincible(true)
                        if inst.components.playercontroller ~= nil then
                            inst.components.playercontroller:Enable(false)
                        end
                        inst:Hide()
                        inst.DynamicShadow:Enable(false)
                        return
                    end
                    inst.sg:GoToState("jumpout")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.Physics:Stop()

            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            elseif inst.sg.statemem.target ~= nil
                and inst.sg.statemem.target:IsValid()
                and inst.sg.statemem.target.components.teleporter ~= nil then
                inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
            end
        end,
    },

    State{
        name = "jumpout",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

        onenter = function(inst)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_jumpout" or "jumpout")

            inst.Physics:SetMotorVel(4, 0, 0)
        end,

        timeline =
        {
            --Heavy lifting
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
            end),
            TimeEvent(12.2 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    if inst.sg.statemem.isphysicstoggle then
                        ToggleOnPhysics(inst)
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
            TimeEvent(16 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(1, 0, 0)
                end
            end),

            --Normal
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(3, 0, 0)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:SetMotorVel(2, 0, 0)
                end
            end),
            TimeEvent(15.2 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    if inst.sg.statemem.isphysicstoggle then
                        ToggleOnPhysics(inst)
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.Physics:SetMotorVel(inst.sg.statemem.heavy and .5 or 1, 0, 0)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.Physics:Stop()
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

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "entertownportal",
        tags = { "doing", "busy", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.teleporter
            inst.sg.statemem.teleportarrivestate = "exittownportal_pre"

            inst.AnimState:PlayAnimation("townportal_enter_pre")

            inst.sg.statemem.fx = SpawnPrefab("townportalsandcoffin_fx")
            inst.sg.statemem.fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg.statemem.isteleporting = true
                inst.components.health:SetInvincible(true)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(false)
                end
                inst.DynamicShadow:Enable(false)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst:Hide()
            end),
            TimeEvent(26 * FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil and
                    inst.sg.statemem.target.components.teleporter ~= nil and
                    inst.sg.statemem.target.components.teleporter:Activate(inst) then
                    inst:Hide()
                    inst.sg.statemem.fx:KillFX()
                else
                    inst.sg:GoToState("exittownportal")
                end
            end),
        },

        onexit = function(inst)
            inst.sg.statemem.fx:KillFX()

            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            end
        end,
    },

    State{
        name = "exittownportal_pre",
        tags = { "doing", "busy", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.fx = SpawnPrefab("townportalsandcoffin_fx")
            inst.sg.statemem.fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

            inst:Hide()
            inst.components.health:SetInvincible(true)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.DynamicShadow:Enable(false)

            inst.sg:SetTimeout(32 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("exittownportal")
        end,

        onexit = function(inst)
            inst.sg.statemem.fx:KillFX()

            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            inst:Show()
            inst.components.health:SetInvincible(false)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.DynamicShadow:Enable(true)
        end,
    },

    State{
        name = "exittownportal",
        tags = { "doing", "busy", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("townportal_exit_pst")
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
                if inst.sg.statemem.isphysicstoggle then
                    ToggleOnPhysics(inst)
                end
            end),
            TimeEvent(26 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nopredict")
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

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "castspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("staff_pre")
            inst.AnimState:PushAnimation("staff", false)
            inst.components.locomotor:Stop()

            --Spawn an effect on the player's location
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local colour = staff ~= nil and staff.fxcolour or { 1, 1, 1 }

            inst.sg.statemem.stafffx = SpawnPrefab(inst.components.rider:IsRiding() and "staffcastfx_mount" or "staffcastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(colour)

            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)

			if staff ~= nil and staff.components.aoetargeting ~= nil then
                local buffaction = inst:GetBufferedAction()
				if buffaction ~= nil then
					inst.sg.statemem.targetfx = staff.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            if staff ~= nil then
                inst.sg.statemem.castsound = staff.skin_castsound or staff.castsound or "dontstarve/wilson/use_gemstaff"
            else
                inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
            end
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end),
            TimeEvent(53 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
                inst.sg.statemem.stafffx = nil --Can't be cancelled anymore
                inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
                --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
                inst:PerformBufferedAction()
            end),
			TimeEvent(69 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				if inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "quickcastspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end

            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.SoundEmitter:PlaySound((staff ~= nil and staff.castsound) or "dontstarve/wilson/attack_weapon")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(16 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "veryquickcastspell",
		tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end

            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.SoundEmitter:PlaySound((staff ~= nil and staff.castsound) or "dontstarve/wilson/attack_weapon")
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "cointosscastspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("cointoss_pre")
            inst.AnimState:PushAnimation("cointoss", false)
            inst.components.locomotor:Stop()

            local coin = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil
            inst.sg.statemem.fxcolour = coin ~= nil and coin.fxcolour or { 1, 1, 1 }
            inst.sg.statemem.castsound = coin ~= nil and coin.castsound or nil
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg.statemem.stafffx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding()) and "cointosscastfx_mount" or "cointosscastfx")
                inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
                inst.sg.statemem.stafffx:SetUp(inst.sg.statemem.fxcolour)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.stafflight:SetUp(inst.sg.statemem.fxcolour, 1.2, .33)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                if inst.sg.statemem.castsound then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
                end
            end),
            TimeEvent(53 * FRAMES, function(inst)
                inst.sg.statemem.stafffx = nil --Can't be cancelled anymore
                inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
                inst:PerformBufferedAction()
            end),
			TimeEvent(70 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				if inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
                inst.sg.statemem.stafffx:Remove()
            end
            if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
                inst.sg.statemem.stafflight:Remove()
            end
        end,
    },

    State{
        name = "mermbuffcastspell",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end

            inst.AnimState:PlayAnimation("cointoss_pre")
            inst.AnimState:PushAnimation("cointoss", false)
            inst.components.locomotor:Stop()

            local item = inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil

            inst.sg.statemem.fxprefab    = item ~= nil and item.fxprefab    or "purebrilliance_castfx"
            inst.sg.statemem.lightcolour = item ~= nil and item.lightcolour or { 1, 1, 1 }

            if item ~= nil and item.castsound then
                inst.SoundEmitter:KillSound("mermcastspellsound")
                inst.SoundEmitter:PlaySound(item ~= nil and item.castsound, "mermcastspellsound")
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                local mounted = inst.components.rider ~= nil and inst.components.rider:IsRiding()
                local prefab = inst.sg.statemem.fxprefab..(mounted and "_mount" or "")

                inst.sg.statemem.spellfx = SpawnPrefab(prefab)
                inst.sg.statemem.spellfx.entity:SetParent(inst.entity)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.sg.statemem.spelllight = SpawnPrefab("staff_castinglight")
                inst.sg.statemem.spelllight.Transform:SetPosition(inst.Transform:GetWorldPosition())
                inst.sg.statemem.spelllight:SetUp(inst.sg.statemem.lightcolour, 1.2, .33)
            end),
            TimeEvent(51 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(70 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				if inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            if inst.sg.statemem.spellfx ~= nil and inst.sg.statemem.spellfx:IsValid() then
                inst.sg.statemem.spellfx:Remove()
            end
            if inst.sg.statemem.spelllight ~= nil and inst.sg.statemem.spelllight:IsValid() then
                inst.sg.statemem.spelllight:Remove()
            end

            if inst.sg:HasStateTag("busy") then
                inst.SoundEmitter:KillSound("mermcastspellsound")
            end
        end,
    },

	State{
		name = "repeatcastspellmind",
		onenter = function(inst)
			inst.sg:GoToState("castspellmind", true)
		end,
	},

    State{
        name = "castspellmind",
		tags = { "doing", "busy", "canrotate" },

		onenter = function(inst, repeatcast)
            inst.SoundEmitter:PlaySound("meta3/willow/pyrokinetic_activate")

			if repeatcast then
				inst.AnimState:PlayAnimation("pyrocast")
				inst.sg.statemem.repeatcast = true
			else
				inst.AnimState:PlayAnimation("pyrocast_pre") --4 frames
				inst.AnimState:PushAnimation("pyrocast", false)
			end
            inst.components.locomotor:Stop()

			local item = inst.bufferedaction and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if item then
				inst.components.inventory:ReturnActiveActionItem(item)

				if item.components.aoetargeting and not (item.components.spellbook and item.components.spellbook:HasSpellFn()) then
					inst.sg.statemem.canrepeatcast = item.components.aoetargeting:CanRepeatCast()
					inst.sg.statemem.targetfx = item.components.aoetargeting:SpawnTargetFXAt(inst.bufferedaction:GetDynamicActionPoint())
					if inst.sg.statemem.targetfx then
						inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
					end
				elseif inst.components.playercontroller then
					inst.components.playercontroller:Enable(false)
				end
			elseif inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
			end
        end,

        timeline =
		{
			FrameEvent(11, function(inst)
				if inst.sg.statemem.repeatcast then
					--V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
					if not inst:PerformBufferedAction() then
						inst.sg.statemem.canrepeatcast = false
						inst:RemoveTag("canrepeatcast")
					elseif inst:IsChannelCasting() then
						--V2C: didn't add this on enter state since we DO want to
						--     cancel previous channelcasting
						inst.sg:AddStateTag("keepchannelcasting")
						inst.sg:GoToState("idle")
					end
				end
			end),
			FrameEvent(16, function(inst)
				if inst.sg.statemem.repeatcast then
					inst.sg:RemoveStateTag("busy")
					if inst.sg.statemem.canrepeatcast then
						inst:AddTag("canrepeatcast")
					end
				end
			end),
			--
			FrameEvent(15, function(inst)
				if not inst.sg.statemem.repeatcast then
					--V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
					if not inst:PerformBufferedAction() then
						inst.sg.statemem.canrepeatcast = false
						inst:RemoveTag("canrepeatcast")
					elseif inst:IsChannelCasting() then
						--V2C: didn't add this on enter state since we DO want to
						--     cancel previous channelcasting
						inst.sg:AddStateTag("keepchannelcasting")
						inst.sg:GoToState("idle")
					end
				end
            end),
			FrameEvent(20, function(inst)
				if not inst.sg.statemem.repeatcast then
					inst.sg:RemoveStateTag("busy")
					if inst.sg.statemem.canrepeatcast then
						inst:AddTag("canrepeatcast")
					end
				end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
			end
			inst:RemoveTag("canrepeatcast")
			if inst.sg.statemem.targetfx and inst.sg.statemem.targetfx:IsValid() then
				OnRemoveCleanupTargetFX(inst)
			end
        end,
    },

	State{
		name = "remotecast_pre",
		tags = { "doing", "busy" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("useitem_dir_pre")
			inst.AnimState:PushAnimation("remotecast_pre", false)
			inst.components.locomotor:Stop()

			local item = inst.bufferedaction and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if item then
				inst.components.inventory:ReturnActiveActionItem(item)

				if item.components.aoetargeting and not (item.components.spellbook and item.components.spellbook:HasSpellFn()) then
					inst.sg.statemem.targetfx = item.components.aoetargeting:SpawnTargetFXAt(inst.bufferedaction:GetDynamicActionPoint())
					if inst.sg.statemem.targetfx then
						inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
					end
				end

				local swap_build = item.swap_build or item.AnimState:GetBuild() or "winona_remote"
				local skin_build = item:GetSkinBuild()
				if skin_build then
					inst.AnimState:OverrideItemSkinSymbol("swap_remote", skin_build, "swap_remote", item.GUID, swap_build)
				else
					inst.AnimState:OverrideSymbol("swap_remote", swap_build, "swap_remote")
				end
			else
				inst.AnimState:OverrideSymbol("swap_remote", "winona_remote", "swap_remote")
			end
		end,

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.remotecasting = true
					inst.sg:GoToState("remotecast_trigger", inst.sg.statemem.targetfx)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.remotecasting then
				if inst.sg.statemem.targetfx and inst.sg.statemem.targetfx:IsValid() then
					OnRemoveCleanupTargetFX(inst)
				end
				inst.AnimState:ClearOverrideSymbol("swap_remote")
			end
		end,
	},

	State{
		name = "remotecast_trigger",
		tags = { "doing", "busy" },

		onenter = function(inst, targetfx)
			inst.components.locomotor:Stop()

			inst.sg.statemem.targetfx = targetfx

			local item = inst.bufferedaction and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
			if item then
				inst.components.inventory:ReturnActiveActionItem(item)

				if item.components.aoetargeting and not (item.components.spellbook and item.components.spellbook:HasSpellFn()) then
					inst.sg.statemem.canrepeatcast = item.components.aoetargeting:CanRepeatCast()
					if targetfx == nil then
						inst.sg.statemem.targetfx = item.components.aoetargeting:SpawnTargetFXAt(inst.bufferedaction:GetDynamicActionPoint())
						if inst.sg.statemem.targetfx then
							inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
						end
					end
				end

				local swap_build = item.swap_build or item.AnimState:GetBuild() or "winona_remote"
				local skin_build = item:GetSkinBuild()
				if skin_build then
					inst.AnimState:OverrideItemSkinSymbol("swap_remote", skin_build, "swap_remote", item.GUID, swap_build)
					inst.AnimState:OverrideItemSkinSymbol("remote_overlay", skin_build, "remote_overlay", item.GUID, swap_build)
				else
					inst.AnimState:OverrideSymbol("swap_remote", swap_build, "swap_remote")
					inst.AnimState:OverrideSymbol("remote_overlay", swap_build, "remote_overlay")
				end

				inst.AnimState:SetSymbolLightOverride("remote_overlay", 0.5)
				inst.AnimState:SetSymbolBloom("remote_overlay")
				inst.AnimState:PlayAnimation("remotecast_trigger") --12 frames
				inst.SoundEmitter:PlaySound("meta4/winona_remote/click")
			else
				--fail!!!
				inst:ClearBufferedAction()
				inst.sg.statemem.remotecasting = true
				inst.sg:GoToState("remotecast_pst")
			end
		end,

        timeline =
		{
			FrameEvent(2, function(inst)
				inst.AnimState:SetSymbolLightOverride("swap_remote", 0.15)
				--V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
				if not inst:PerformBufferedAction() then
					if inst.sg.statemem.targetfx then
						if inst.sg.statemem.targetfx:IsValid() then
							OnRemoveCleanupTargetFX(inst)
						end
						inst.sg.statemem.targetfx = nil
					end
				end
				if inst.sg.statemem.canrepeatcast then
					inst.AnimState:PushAnimation("remotecast_loop", false) --28 frames
				end
			end),
			FrameEvent(4, function(inst)
				inst.AnimState:SetSymbolLightOverride("swap_remote", 0)
			end),
			FrameEvent(6, function(inst)
				inst.AnimState:SetSymbolLightOverride("swap_remote", 0.15)
			end),
			FrameEvent(8, function(inst)
				inst.AnimState:SetSymbolLightOverride("swap_remote", 0)
			end),
			FrameEvent(10, function(inst)
				inst.sg:RemoveStateTag("busy")
				if inst.sg.statemem.canrepeatcast then
					inst:AddTag("canrepeatcast")
				end
			end),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.remotecasting = true
					inst.sg:GoToState("remotecast_pst")
				end
			end),
		},

		onexit = function(inst)
			inst:RemoveTag("canrepeatcast")
			if inst.sg.statemem.targetfx and inst.sg.statemem.targetfx:IsValid() then
				OnRemoveCleanupTargetFX(inst)
			end
			if not inst.sg.statemem.remotecasting then
				inst.AnimState:ClearOverrideSymbol("swap_remote")
			end
			inst.AnimState:ClearOverrideSymbol("remote_overlay")
			inst.AnimState:ClearSymbolBloom("remote_overlay")
			inst.AnimState:SetSymbolLightOverride("remote_overlay", 0)
			inst.AnimState:SetSymbolLightOverride("swap_remote", 0)
		end,
	},

	State{
		name = "remotecast_pst",
		tags = { "doing" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("remotecast_pst") --7 frames
			inst.AnimState:PushAnimation("useitem_dir_pst", false)
		end,

		timeline =
		{
			FrameEvent(12, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("swap_remote")
		end,
	},

    State{
        name = "quicktele",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("player_atk_pre")
                inst.AnimState:PushAnimation("player_atk", false)
            else
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")

            --called by blinkstaff component
            inst.sg.statemem.onstartblinking = function()
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
                inst:Hide()
            end
            inst.sg.statemem.onstopblinking = function()
                inst.sg:RemoveStateTag("noattack")
				if inst.sg.statemem.endbusy then
					inst.sg:RemoveStateTag("busy")
				end
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                inst:Show()
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(18 * FRAMES, function(inst)
				if inst.sg:HasStateTag("noattack") then
					inst.sg.statemem.endbusy = true
				else
					inst.sg:RemoveStateTag("busy")
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("noattack") then
                --interrupted
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                inst:Show()
            end
        end,
    },

    State{
        name = "forcetele",
        tags = { "busy", "nopredict", "nomorph" },

        onenter = function(inst)
            ClearStatusAilments(inst)

            inst.components.rider:ActualDismount()

            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(true)
            inst.DynamicShadow:Enable(false)
            inst:Hide()
            inst:ScreenFade(false, 2)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            inst:Show()

            if inst.sg.statemem.teleport_task ~= nil then
                -- Still have a running teleport_task
                -- Interrupt!
                inst.sg.statemem.teleport_task:Cancel()
                inst.sg.statemem.teleport_task = nil
                inst:ScreenFade(true, .5)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "combat_lunge_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("lunge_pre")
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/twirl", nil, nil, true)
            end),
        },

        events =
        {
            EventHandler("combat_lunge", function(inst, data)
                inst.sg:GoToState("combat_lunge", data)
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("lunge_pre") then
                        inst.AnimState:PlayAnimation("lunge_lag")
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "combat_lunge",
        tags = { "aoe", "doing", "busy", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil and
                data.targetpos ~= nil and
                data.weapon ~= nil and
                data.weapon.components.aoeweapon_lunge ~= nil and
                inst.AnimState:IsCurrentAnimation("lunge_lag") then
                inst.AnimState:PlayAnimation("lunge_pst")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                local pos = inst:GetPosition()
				local dir
                if pos.x ~= data.targetpos.x or pos.z ~= data.targetpos.z then
					dir = inst:GetAngleToPoint(data.targetpos)
					inst.Transform:SetRotation(dir)
                end
                if data.weapon.components.aoeweapon_lunge:DoLunge(inst, pos, data.targetpos) then
                    inst.SoundEmitter:PlaySound(data.weapon.components.aoeweapon_lunge.sound or "dontstarve/common/lava_arena/fireball")

					--Make sure we don't land directly on world boundary, where
					--physics may end up popping in the wrong direction to void
					local x, z = data.targetpos.x, data.targetpos.z
					if dir then
						local theta = dir * DEGREES
						local cos_theta = math.cos(theta)
						local sin_theta = math.sin(theta)
						local x1, z1
						local map = TheWorld.Map
						if not map:IsPassableAtPoint(x, 0, z) then
							--scan for nearby land in case we were slightly off
							--adjust position slightly toward valid ground
							if map:IsPassableAtPoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
								x1 = x + 0.5 * cos_theta
								z1 = z - 0.5 * sin_theta
							elseif map:IsPassableAtPoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
								x1 = x - 0.5 * cos_theta
								z1 = z + 0.5 * sin_theta
							end
						else
							--scan to make sure we're not just on the edge of land, could result in popping to the wrong side
							--adjust position slightly away from invalid ground
							if not map:IsPassableAtPoint(x + 0.1 * cos_theta, 0, z - 0.1 * sin_theta) then
								x1 = x - 0.4 * cos_theta
								z1 = z + 0.4 * sin_theta
							elseif not map:IsPassableAtPoint(x - 0.1 * cos_theta, 0, z + 0.1 * sin_theta) then
								x1 = x + 0.4 * cos_theta
								z1 = z - 0.4 * sin_theta
							end
						end

						if x1 and map:IsPassableAtPoint(x1, 0, z1) then
							x, z = x1, z1
						end
					end

					--V2C: -physics doesn't resolve correctly if we teleport from
					--      one point colliding with world to another point still
					--      colliding with world.
					--     -#HACK use mass change to force physics refresh.
					local mass = inst.Physics:GetMass()
					if mass > 0 then
						inst.sg.statemem.restoremass = mass
						inst.Physics:SetMass(mass + 1)
					end
					inst.Physics:Teleport(x, 0, z)

                    -- aoeweapon_lunge:DoLunge can get us out of the state!
                    -- And then, if onexit is run before this: bugs!
                    if not data.skipflash and inst.sg.currentstate == "combat_lunge" then
                        inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
                        inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
                        inst.sg.statemem.flash = 1
                    end
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                inst.components.colouradder:PushColour("lunge", inst.sg.statemem.flash, inst.sg.statemem.flash, 0, 0)
            end
        end,

        timeline =
        {
			FrameEvent(8, function(inst)
				if inst.sg.statemem.restoremass ~= nil then
					inst.Physics:SetMass(inst.sg.statemem.restoremass)
					inst.sg.statemem.restoremass = nil
				end
			end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("lunge")
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

        onexit = function(inst)
			if inst.sg.statemem.restoremass ~= nil then
				inst.Physics:SetMass(inst.sg.statemem.restoremass)
			end
            inst.components.bloomer:PopBloom("lunge")
            inst.components.colouradder:PopColour("lunge")
        end,
    },

    State{
        name = "combat_leap_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_leap_pre")

            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if weapon ~= nil and weapon.components.aoetargeting ~= nil then
                local buffaction = inst:GetBufferedAction()
				if buffaction ~= nil then
					inst.sg.statemem.targetfx = weapon.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end
        end,

        events =
        {
            EventHandler("combat_leap", function(inst, data)
                inst.sg.statemem.leap = true
                inst.sg:GoToState("combat_leap", {
                    targetfx = inst.sg.statemem.targetfx,
                    data = data,
                })
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("atk_leap_pre") then
                        inst.AnimState:PlayAnimation("atk_leap_lag")
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.leap and inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "combat_leap",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.targetfx = data.targetfx
                data = data.data
                if data ~= nil and
                        data.targetpos ~= nil and
                        data.weapon ~= nil and
                        data.weapon.components.aoeweapon_leap ~= nil and
                        inst.AnimState:IsCurrentAnimation("atk_leap_lag") then
                    ToggleOffPhysics(inst)
                    inst.Transform:SetEightFaced()
                    inst.AnimState:PlayAnimation("atk_leap")
                    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                    inst.sg.statemem.startingpos = inst:GetPosition()
                    inst.sg.statemem.weapon = data.weapon
                    inst.sg.statemem.targetpos = data.targetpos
                    if not data.skipflash then
                        inst.sg.statemem.flash = 0
                    end
                    if inst.sg.statemem.startingpos.x ~= data.targetpos.x or inst.sg.statemem.startingpos.z ~= data.targetpos.z then
                        inst:ForceFacePoint(data.targetpos:Get())
                        inst.Physics:SetMotorVel(math.sqrt(distsq(inst.sg.statemem.startingpos.x, inst.sg.statemem.startingpos.z, data.targetpos.x, data.targetpos.z)) / (12 * FRAMES), 0 ,0)
                    end
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("leap", c, c, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.flash then
                    inst.components.colouradder:PushColour("leap", .1, .1, 0, 0)
                end
            end),
            TimeEvent(11 * FRAMES, function(inst)
                if inst.sg.statemem.flash then
                    inst.components.colouradder:PushColour("leap", .2, .2, 0, 0)
                end
            end),
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.flash then
                    inst.components.colouradder:PushColour("leap", .4, .4, 0, 0)
                end
                ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.sg.statemem.flash then
                    inst.components.bloomer:PushBloom("leap", "shaders/anim.ksh", -2)
                    inst.components.colouradder:PushColour("leap", 1, 1, 0, 0)
                    inst.sg.statemem.flash = 1.3
                end
                inst.sg:RemoveStateTag("nointerrupt")
                if inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon.components.aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
                end
            end),
            TimeEvent(25 * FRAMES, function(inst)
                if inst.sg.statemem.flash then
                    inst.components.bloomer:PopBloom("leap")
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

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                local x, y, z = inst.Transform:GetWorldPosition()
                if TheWorld.Map:IsPassableAtPoint(x, 0, z) and not TheWorld.Map:IsGroundTargetBlocked(Vector3(x, 0, z)) then
                    inst.Physics:Teleport(x, 0, z)
                else
                    inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
                end
            end
            inst.Transform:SetFourFaced()
            if inst.sg.statemem.flash then
                inst.components.bloomer:PopBloom("leap")
                inst.components.colouradder:PopColour("leap")
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "combat_superjump_start",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("superjump_pre")

            local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if weapon ~= nil and weapon.components.aoetargeting ~= nil then
                local buffaction = inst:GetBufferedAction()
				if buffaction ~= nil then
					inst.sg.statemem.targetfx = weapon.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end
        end,

        events =
        {
            EventHandler("combat_superjump", function(inst, data)
                inst.sg.statemem.superjump = true
                inst.sg:GoToState("combat_superjump", {
                    targetfx = inst.sg.statemem.targetfx,
                    data = data,
                })
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("superjump_pre") then
                        inst.AnimState:PlayAnimation("superjump_lag")
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.superjump and inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "combat_superjump",
        tags = { "aoe", "doing", "busy", "nointerrupt", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil then
                inst.sg.statemem.targetfx = data.targetfx
                inst.sg.statemem.data = data
                data = data.data
                if data ~= nil and
                    data.targetpos ~= nil and
                    data.weapon ~= nil and
                    data.weapon.components.aoeweapon_leap ~= nil and
                    inst.AnimState:IsCurrentAnimation("superjump_lag") then
                    ToggleOffPhysics(inst)
                    inst.AnimState:PlayAnimation("superjump")
                    inst.AnimState:SetMultColour(.8, .8, .8, 1)
                    inst.components.colouradder:PushColour("superjump", .1, .1, .1, 0)
                    inst.sg.statemem.data.startingpos = inst:GetPosition()
                    inst.sg.statemem.weapon = data.weapon
                    if inst.sg.statemem.data.startingpos.x ~= data.targetpos.x or inst.sg.statemem.data.startingpos.z ~= data.targetpos.z then
                        inst:ForceFacePoint(data.targetpos:Get())
                    end
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, .4)
                    inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")
                    inst.sg:SetTimeout(1)
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.dalpha ~= nil and inst.sg.statemem.alpha > 0 then
                inst.sg.statemem.dalpha = math.max(.1, inst.sg.statemem.dalpha - .1)
                inst.sg.statemem.alpha = math.max(0, inst.sg.statemem.alpha - inst.sg.statemem.dalpha)
                inst.AnimState:SetMultColour(0, 0, 0, inst.sg.statemem.alpha)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.AnimState:SetMultColour(.5, .5, .5, 1)
                inst.components.colouradder:PushColour("superjump", .3, .3, .2, 0)
                inst:PushEvent("dropallaggro")
                if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon:PushEvent("superjumpstarted", inst)
                end
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(0, 0, 0, 1)
                inst.components.colouradder:PushColour("superjump", .6, .6, .4, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.sg.statemem.alpha = 1
                inst.sg.statemem.dalpha = .5
            end),
            TimeEvent(1 - 7 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Hide()
                    inst.Physics:Teleport(inst.sg.statemem.data.data.targetpos.x, 0, inst.sg.statemem.data.data.targetpos.z)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.superjump = true
            inst.sg.statemem.data.isphysicstoggle = inst.sg.statemem.data.isphysicstoggle
            inst.sg.statemem.data.targetfx = nil
            inst.sg:GoToState("combat_superjump_pst", inst.sg.statemem.data)
        end,

        onexit = function(inst)
            if not inst.sg.statemem.superjump then
                inst.components.health:SetInvincible(false)
                if inst.sg.statemem.isphysicstoggle then
                    ToggleOnPhysics(inst)
                end
                inst.components.colouradder:PopColour("superjump")
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.DynamicShadow:Enable(true)
                if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon:PushEvent("superjumpcancelled", inst)
                end
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
            inst:Show()
        end,
    },

    State{
        name = "combat_superjump_pst",
        tags = { "aoe", "doing", "busy", "noattack", "nopredict", "nomorph" },

        onenter = function(inst, data)
            if data ~= nil and data.data ~= nil then
                inst.sg.statemem.startingpos = data.startingpos
                inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
                data = data.data
                inst.sg.statemem.weapon = data.weapon
                if inst.sg.statemem.startingpos ~= nil and
                    data.targetpos ~= nil and
                    data.weapon ~= nil and
                    data.weapon.components.aoeweapon_leap ~= nil and
                    inst.AnimState:IsCurrentAnimation("superjump") then
                    inst.AnimState:PlayAnimation("superjump_land")
                    inst.AnimState:SetMultColour(1, 1, 1, .4)
                    inst.sg.statemem.targetpos = data.targetpos
                    if not data.skipflash then
                        inst.sg.statemem.flash = 0
                    end
                    if not inst.sg.statemem.isphysicstoggle then
                        ToggleOffPhysics(inst)
                    end
                    inst.Physics:Teleport(data.targetpos.x, 0, data.targetpos.z)
                    inst.components.health:SetInvincible(true)
                    inst.sg:SetTimeout(22 * FRAMES)
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(1, 1, 1, .7)
                inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, .9)
                inst.components.colouradder:PushColour("superjump", .2, .2, 0, 0)
            end),
            TimeEvent(3 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(1, 1, 1, 1)
                inst.components.colouradder:PushColour("superjump", .4, .4, 0, 0)
                inst.DynamicShadow:Enable(true)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("superjump", 1, 1, 0, 0)
                inst.components.bloomer:PushBloom("superjump", "shaders/anim.ksh", -2)
                ToggleOnPhysics(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                if inst.sg.statemem.flash then
                    inst.sg.statemem.flash = 1.3
                end
                inst.sg:RemoveStateTag("noattack")
                inst.components.health:SetInvincible(false)
                if inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon.components.aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
                    inst.sg.statemem.weapon = nil
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("superjump")
            end),
            TimeEvent(19 * FRAMES, PlayFootstep),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.AnimState:SetMultColour(1, 1, 1, 1)
            inst.DynamicShadow:Enable(true)
            inst.components.health:SetInvincible(false)
            inst.components.bloomer:PopBloom("superjump")
            inst.components.colouradder:PopColour("superjump")
            if inst.sg.statemem.weapon ~= nil and inst.sg.statemem.weapon:IsValid() then
                inst.sg.statemem.weapon:PushEvent("superjumpcancelled", inst)
            end
        end,
    },

    State{
        name = "multithrust_pre",
        tags = { "thrusting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("multithrust_yell")

            if inst.bufferedaction ~= nil and inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                inst.sg.statemem.target = inst.bufferedaction.target
                inst.components.combat:SetTarget(inst.sg.statemem.target)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.thrusting = true
                    inst.sg:GoToState("multithrust", inst.sg.statemem.target)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.thrusting then
                inst.components.combat:SetTarget(nil)
            end
        end,
    },

    State{
        name = "multithrust",
        tags = { "thrusting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("multithrust")
            inst.Transform:SetEightFaced()

            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end

            inst.sg:SetTimeout(30 * FRAMES)

            --[[if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end]]
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            end),
            TimeEvent(11 * FRAMES, function(inst)
                inst.sg.statemem.weapon = inst.components.combat:GetWeapon()
                inst:PerformBufferedAction()
                DoThrust(inst)
            end),
            TimeEvent(13 * FRAMES, DoThrust),
            TimeEvent(15 * FRAMES, DoThrust),
            TimeEvent(17 * FRAMES, function(inst)
                DoThrust(inst, true)
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
                DoThrust(inst, true)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            inst.Transform:SetFourFaced()
            if ValidateMultiThruster(inst) then
                inst.sg.statemem.weapon.components.multithruster:StopThrusting(inst)
            end
        end,
    },

    State{
        name = "helmsplitter_pre",
        tags = { "helmsplitting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("atk_leap_pre")

            if inst.bufferedaction ~= nil and inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                inst.sg.statemem.target = inst.bufferedaction.target
                inst.components.combat:SetTarget(inst.sg.statemem.target)
                inst:ForceFacePoint(inst.sg.statemem.target.Transform:GetWorldPosition())
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

            inst.sg:SetTimeout(8 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.helmsplitting = true
            inst.sg:GoToState("helmsplitter", inst.sg.statemem.target)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.helmsplitting = true
                    inst.sg:GoToState("helmsplitter", inst.sg.statemem.target)
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.helmsplitting then
                inst.components.combat:SetTarget(nil)
            end
        end,
    },

    State{
        name = "helmsplitter",
        tags = { "helmsplitting", "doing", "busy", "nointerrupt", "nomorph", "pausepredict" },

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.Transform:SetEightFaced()
            inst.AnimState:PlayAnimation("atk_leap")
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

            if target ~= nil and target:IsValid() then
                inst.sg.statemem.target = target
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
            end

            inst.sg:SetTimeout(30 * FRAMES)

            --[[if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end]]
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .1, .1, 0, 0)
            end),
            TimeEvent(11 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .2, .2, 0, 0)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .4, .4, 0, 0)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.components.bloomer:PushBloom("helmsplitter", "shaders/anim.ksh", -2)
                inst.components.colouradder:PushColour("helmsplitter", 1, 1, 0, 0)
                inst.sg:RemoveStateTag("nointerrupt")
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .015, .5, inst, 20)
                inst.sg.statemem.weapon = inst.components.combat:GetWeapon()
                inst:PerformBufferedAction()
                DoHelmSplit(inst)
            end),
            TimeEvent(14 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .8, .8, 0, 0)
            end),
            TimeEvent(15 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .6, .6, 0, 0)
            end),
            TimeEvent(16 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .4, .4, 0, 0)
            end),
            TimeEvent(17 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("helmsplitter", .2, .2, 0, 0)
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst.components.colouradder:PopColour("helmsplitter")
            end),
            TimeEvent(19 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("helmsplitter")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
            inst.Transform:SetFourFaced()
            inst.components.bloomer:PopBloom("helmsplitter")
            inst.components.colouradder:PopColour("helmsplitter")
            if ValidateHelmSplitter(inst) then
                inst.sg.statemem.weapon.components.helmsplitter:StopHelmSplitting(inst)
            end
        end,
    },

    State{
        name = "blowdart_special",
        tags = { "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dart_pre")
            if equip ~= nil and equip:HasTag("aoeblowdart_long") then
                inst.sg.statemem.long = true
                inst.AnimState:PushAnimation("dart_long", false)
                inst.sg:SetTimeout(29 * FRAMES)
            else
                inst.AnimState:PushAnimation("dart", false)
                inst.sg:SetTimeout(22 * FRAMES)
            end

            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end

            if (equip ~= nil and equip.projectiledelay or 0) > 0 then
                --V2C: Projectiles don't show in the initial delayed frames so that
                --     when they do appear, they're already in front of the player.
                --     Start the attack early to keep animation in sync.
                inst.sg.statemem.projectiledelay = 14 * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("nointerrupt")
                end
            end
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.projectiledelay == nil then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("nointerrupt")
                end
            end),
            TimeEvent(20 * FRAMES, function(inst)
                if inst.sg.statemem.long then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot", nil, .4)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "slingshot_shoot",
		tags = { "attack", "abouttoattack" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
			if target == nil then
				if buffaction ~= nil and inst.components.playercontroller ~= nil and inst.components.playercontroller.isclientcontrollerattached then
					inst.sg.statemem.air_attack = true
				end
			elseif target:IsValid() then
	            inst:ForceFacePoint(target.Transform:GetWorldPosition())
	            inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
			end

            inst.AnimState:PlayAnimation("slingshot_pre")
            inst.AnimState:PushAnimation("slingshot", false)

            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
				inst.AnimState:SetFrame(3)
            end

            inst.components.combat:StartAttack()
            inst.components.combat:SetTarget(target)
            inst.components.locomotor:Stop()

			local timeout = inst.sg.statemem.chained and 25 or 28
			local playercontroller = inst.components.playercontroller
			if playercontroller ~= nil and playercontroller.remote_authority and playercontroller.remote_predicting then
				timeout = timeout - 1
			end
			inst.sg:SetTimeout(timeout * FRAMES)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
				if inst.sg.statemem.chained and not inst.sg.statemem.air_attack then
					local buffaction = inst:GetBufferedAction()
					local target = buffaction ~= nil and buffaction.target or nil
					if not (target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target)) then
						inst:ClearBufferedAction()
						inst.sg:GoToState("idle")
					end
				end
            end),
            TimeEvent(16 * FRAMES, function(inst) -- start of slingshot
				if inst.sg.statemem.chained then
	                inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
				end
            end),
            TimeEvent(22 * FRAMES, function(inst)
				if inst.sg.statemem.chained then
					if inst.sg.statemem.air_attack then
						inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
						inst:ClearBufferedAction()
						inst.sg:GoToState("idle")
					else
						local buffaction = inst:GetBufferedAction()
						local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
						if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
							local target = buffaction ~= nil and buffaction.target or nil
							if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
								inst:PerformBufferedAction()
								inst.sg:RemoveStateTag("abouttoattack")
								inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
							else
								inst:ClearBufferedAction()
								inst.sg:GoToState("idle")
							end
						else -- out of ammo
							inst:ClearBufferedAction()
							inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
							inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
							inst.sg:GoToState("idle")
						end
					end
				end
            end),

            TimeEvent(18 * FRAMES, function(inst)
				if not inst.sg.statemem.chained and not inst.sg.statemem.air_attack then
					local buffaction = inst:GetBufferedAction()
					local target = buffaction ~= nil and buffaction.target or nil
					if not (target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target)) then
						inst:ClearBufferedAction()
						inst.sg:GoToState("idle")
					end
				end
            end),
            TimeEvent(19 * FRAMES, function(inst) -- start of slingshot
				if not inst.sg.statemem.chained then
	                inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
				end
            end),
            TimeEvent(25 * FRAMES, function(inst)
				if not inst.sg.statemem.chained then
					if inst.sg.statemem.air_attack then
						inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
						inst:ClearBufferedAction()
						inst.sg:GoToState("idle")
					else
						local buffaction = inst:GetBufferedAction()
						local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
						if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
							local target = buffaction ~= nil and buffaction.target or nil
							if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
								inst:PerformBufferedAction()
								inst.sg:RemoveStateTag("abouttoattack")
								inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
							else
								inst:ClearBufferedAction()
								inst.sg:GoToState("idle")
							end
						else -- out of ammo
							inst:ClearBufferedAction()
							inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
							inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
							inst.sg:GoToState("idle")
						end
					end
				end
            end),
        },

		ontimeout = function(inst)
			inst.sg:RemoveStateTag("attack")
			inst.sg:AddStateTag("idle")
		end,

        events =
        {
            EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.combat:SetTarget(nil)
			if inst.sg:HasStateTag("abouttoattack") then
				inst.components.combat:CancelAttack()
            end
        end,
	},

    State{
        name = "throw_line",
        tags = { "doing", "busy", "nointerrupt", "nomorph" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("throw_pre")
			inst.AnimState:PushAnimation("throw", false)

			local pos = buffaction ~= nil and buffaction:GetActionPoint() or nil
			if pos ~= nil then
				inst:ForceFacePoint(pos:Get())

				if equip ~= nil and equip.components.aoetargeting ~= nil then
					inst.sg.statemem.targetfx = equip.components.aoetargeting:SpawnTargetFXAt(buffaction:GetDynamicActionPoint())
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                    end
                end
            end

            if (equip ~= nil and equip.projectiledelay or 0) > 0 then
                --V2C: Projectiles don't show in the initial delayed frames so that
                --     when they do appear, they're already in front of the player.
                --     Start the attack early to keep animation in sync.
                inst.sg.statemem.projectiledelay = 7 * FRAMES - equip.projectiledelay
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg.statemem.projectiledelay = nil
                end
            end

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        onupdate = function(inst, dt)
            if (inst.sg.statemem.projectiledelay or 0) > 0 then
                inst.sg.statemem.projectiledelay = inst.sg.statemem.projectiledelay - dt
                if inst.sg.statemem.projectiledelay <= 0 then
                    inst.sg:RemoveStateTag("nointerrupt")
                    if inst:PerformBufferedAction() and inst.sg.statemem.targetfx ~= nil then
                        if inst.sg.statemem.targetfx:IsValid() then
                            inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
                            inst.sg.statemem.targetfx:DoTaskInTime(1.05, inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)
                        end
                        inst.sg.statemem.targetfx = nil
                    end
                end
            end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.projectiledelay == nil then
                    inst.sg:RemoveStateTag("nointerrupt")
                    if inst:PerformBufferedAction() and inst.sg.statemem.targetfx ~= nil then
                        if inst.sg.statemem.targetfx:IsValid() then
                            inst.sg.statemem.targetfx:RemoveEventCallback("onremove", OnRemoveCleanupTargetFX, inst)
                            inst.sg.statemem.targetfx:DoTaskInTime(1.05, inst.sg.statemem.targetfx.KillFX or inst.sg.statemem.targetfx.Remove)
                        end
                        inst.sg.statemem.targetfx = nil
                    end
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
				inst.sg:GoToState("idle", true)
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "catch_equip",
        tags = { "idle" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("catch_pre")
            inst.AnimState:PushAnimation("catch", false)
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.sg.statemem.playedfx = true
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.playedfx then
                SpawnPrefab("lucy_transform_fx").entity:AddFollower():FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
            end
        end,
    },

    State{
        name = "emote",
        tags = { "busy", "pausepredict" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            local dancedata = nil
            if data.tags ~= nil then
                for i, v in ipairs(data.tags) do
                    inst.sg:AddStateTag(v)
                    if v == "dancing" then
                        dancedata = dancedata or {}
                        TheWorld:PushEvent("dancingplayer", inst)
                        local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                        if hat ~= nil and hat.OnStartDancing ~= nil then
                            local newdata = hat:OnStartDancing(inst, data)
                            if newdata ~= nil then
                                inst.sg.statemem.dancinghat = hat
                                data = newdata
                            end
                        end
                    end
                end
                if inst.sg.statemem.dancinghat ~= nil and data.tags ~= nil then
                    for i, v in ipairs(data.tags) do
                        if not inst.sg:HasStateTag(v) then
                            inst.sg:AddStateTag(v)
                        end
                    end
                end
            end

            local anim = data.anim
            local animtype = type(anim)
            if data.randomanim and animtype == "table" then
                anim = anim[math.random(#anim)]
                animtype = type(anim)
            end
            if animtype == "table" and #anim <= 1 then
                anim = anim[1]
                animtype = type(anim)
            end

            if animtype == "string" then
                inst.AnimState:PlayAnimation(anim, data.loop)
                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim, loop = data.loop,})
                end
            elseif animtype == "table" then
                local maxanim = #anim
                -- NOTES(JBK): Keep these in sync with the data replication in `dancedata` below.
                inst.AnimState:PlayAnimation(anim[1])
                for i = 2, maxanim - 1 do
                    inst.AnimState:PushAnimation(anim[i])
                end
                inst.AnimState:PushAnimation(anim[maxanim], data.loop == true)

                if dancedata ~= nil then
                    table.insert(dancedata, {play = true, anim = anim[1]})
                    for i = 2, maxanim - 1 do
                        table.insert(dancedata, {anim = anim[i]})
                    end
                    table.insert(dancedata, {anim = anim[maxanim], loop = data.loop == true,})
                end
            end
            if dancedata ~= nil then
                TheWorld:PushEvent("dancingplayerdata", {inst = inst, dancedata = dancedata,})
            end

            if data.fx then --fx might be a boolean, so don't do ~= nil
                if data.fxdelay == nil or data.fxdelay == 0 then
                    DoEmoteFX(inst, data.fx)
                else
                    inst.sg.statemem.emotefxtask = inst:DoTaskInTime(data.fxdelay, DoEmoteFX, data.fx)
                end
            elseif data.fx ~= false then
                DoEmoteFX(inst, "emote_fx")
            end

            if data.sound then --sound might be a boolean, so don't do ~= nil
                if (data.sounddelay or 0) <= 0 then
                    inst.SoundEmitter:PlaySound(data.sound)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoForcedEmoteSound, data.sound)
                end
            elseif data.sound ~= false then
                if (data.sounddelay or 0) <= 0 then
                    DoEmoteSound(inst, data.soundoverride, data.soundlooped)
                else
                    inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoEmoteSound, data.soundoverride, data.soundlooped)
                end
            end

            if data.mountsound ~= nil then
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds[data.mountsound] ~= nil then
                    if (data.mountsoundperiod or 0) <= 0 then
                        if (data.mountsounddelay or 0) <= 0 then
                            inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound])
                        else
                            inst.sg.statemem.emotemountsoundtask = inst:DoTaskInTime(data.mountsounddelay, DoForcedEmoteSound, mount.sounds[data.mountsound])
                        end
                    elseif (data.mountsounddelay or 0) <= 0 then
                        inst.sg.statemem.emotemountsoundtask = inst:DoPeriodicTask(data.mountsoundperiod, DoForcedEmoteSound, nil, mount.sounds[data.mountsound])
                        inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound])
                    else
                        inst.sg.statemem.emotemountsoundtask = inst:DoPeriodicTask(data.mountsoundperiod, DoForcedEmoteSound, data.mountsounddelay, mount.sounds[data.mountsound])
                    end
                end
            end

            if data.mountsound2 ~= nil then
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds[data.mountsound2] ~= nil then
                    if (data.mountsound2period or 0) <= 0 then
                        if (data.mountsound2delay or 0) <= 0 then
                            inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound2])
                        else
                            inst.sg.statemem.emotemountsound2task = inst:DoTaskInTime(data.mountsound2delay, DoForcedEmoteSound, mount.sounds[data.mountsound2])
                        end
                    elseif (data.mountsound2delay or 0) <= 0 then
                        inst.sg.statemem.emotemountsound2task = inst:DoPeriodicTask(data.mountsound2period, DoForcedEmoteSound, nil, mount.sounds[data.mountsound2])
                        inst.SoundEmitter:PlaySound(mount.sounds[data.mountsound2])
                    else
                        inst.sg.statemem.emotemountsound2task = inst:DoPeriodicTask(data.mountsound2period, DoForcedEmoteSound, data.mountsound2delay, mount.sounds[data.mountsound2])
                    end
                end
            end

            if data.zoom ~= nil then
                inst.sg.statemem.iszoomed = true
                inst:SetCameraZoomed(true)
                inst:ShowHUD(false)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(.5, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.emotefxtask ~= nil then
                inst.sg.statemem.emotefxtask:Cancel()
                inst.sg.statemem.emotefxtask = nil
            end
            if inst.sg.statemem.emotesoundtask ~= nil then
                inst.sg.statemem.emotesoundtask:Cancel()
                inst.sg.statemem.emotesoundtask = nil
            end
            if inst.sg.statemem.emotemountsoundtask ~= nil then
                inst.sg.statemem.emotemountsoundtask:Cancel()
                inst.sg.statemem.emotemountsoundtask = nil
            end
            if inst.sg.statemem.emotemountsound2task ~= nil then
                inst.sg.statemem.emotemountsound2task:Cancel()
                inst.sg.statemem.emotemountsound2task = nil
            end
            if inst.SoundEmitter:PlayingSound("emotesoundloop") then
                inst.SoundEmitter:KillSound("emotesoundloop")
            end
            if inst.sg.statemem.iszoomed then
                inst:SetCameraZoomed(false)
                inst:ShowHUD(true)
            end
            if inst.sg.statemem.dancinghat ~= nil and
                inst.sg.statemem.dancinghat == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and
                inst.sg.statemem.dancinghat.OnStopDancing ~= nil then
                inst.sg.statemem.dancinghat:OnStopDancing(inst)
            end

        end,
    },

    State{
        name = "frozen",
        tags = { "busy", "frozen", "nopredict", "nodangle" },

        onenter = function(inst)
            if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
                inst.components.pinnable:Unstick()
            end

            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end

            --V2C: cuz... freezable component and SG need to match state,
            --     but messages to SG are queued, so it is not great when
            --     when freezable component tries to change state several
            --     times within one frame...
            if inst.components.freezable == nil then
                inst.sg:GoToState("hit", true)
            elseif inst.components.freezable:IsThawing() then
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            elseif not inst.components.freezable:IsFrozen() then
                inst.sg:GoToState("hit", true)
            end
        end,

        events =
        {
            EventHandler("onthaw", function(inst)
                inst.sg.statemem.isstillfrozen = true
                inst.sg:GoToState("thaw")
            end),
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.isstillfrozen then
                inst.components.inventory:Show()
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
            end
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "thaw",
        tags = { "busy", "thawing", "nopredict", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                inst.sg:GoToState("hit", true)
            end),
        },

        onexit = function(inst)
            inst.components.inventory:Show()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
    },

    State{
        name = "pinned_pre",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
                inst.components.freezable:Unfreeze()
            end

            ForceStopHeavyLifting(inst)

            if inst.components.pinnable == nil or not inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("breakfree")
                return
            end

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:OverrideSymbol("swap_goosplat", inst.components.pinnable.goo_build or "goo", "swap_goosplat")
            inst.AnimState:PlayAnimation("hit")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.isstillpinned = true
                    inst.sg:GoToState("pinned")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.isstillpinned then
                inst.components.inventory:Show()
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
            end
            inst.AnimState:ClearOverrideSymbol("swap_goosplat")
        end,
    },

    State{
        name = "pinned",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            if inst.components.pinnable == nil or not inst.components.pinnable:IsStuck() then
                inst.sg:GoToState("breakfree")
                return
            end

            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_loop", true)
             -- TODO: struggle sound
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerstruggle", "struggling")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
        },

        onexit = function(inst)
            inst.components.inventory:Show()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst.SoundEmitter:KillSound("struggling")
        end,
    },

    State{
        name = "pinned_hit",
        tags = { "busy", "pinned", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit_goo")

            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            DoHurtSound(inst)

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("onunpin", function(inst, data)
                inst.sg:GoToState("breakfree")
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.isstillpinned = true
                    inst.sg:GoToState("pinned")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.isstillpinned then
                inst.components.inventory:Show()
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,
    },

    State{
        name = "breakfree",
        tags = { "busy", "nopredict" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("distress_pst")
            inst.SoundEmitter:PlaySound("dontstarve/creatures/spat/spit_playerunstuck")

            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(false)
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.inventory:Show()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "use_fan",
        tags = { "doing" },

        onenter = function(inst)
            local invobject = nil
            if inst.bufferedaction ~= nil then
                invobject = inst.bufferedaction.invobject
                if invobject ~= nil and invobject.components.fan ~= nil and invobject.components.fan:IsChanneling() then
                    inst.sg.statemem.item = invobject
                    inst.sg.statemem.target = inst.bufferedaction.target or inst.bufferedaction.doer
                    inst.sg:AddStateTag("busy")
                end
            end
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("fan", false)
            local skin_build = invobject:GetSkinBuild()
            local src_symbol = invobject ~= nil and invobject.components.fan ~= nil and invobject.components.fan.overridesymbol or "swap_fan"
            if skin_build ~= nil then
                inst.AnimState:OverrideItemSkinSymbol( "fan01", skin_build, src_symbol, invobject.GUID, "fan" )
            else
                inst.AnimState:OverrideSymbol( "fan01", "fan", src_symbol )
            end
            inst.components.inventory:ReturnActiveActionItem(invobject)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item:IsValid() and
                    inst.sg.statemem.item.components.fan ~= nil then
                    inst.sg.statemem.item.components.fan:Channel(inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target or inst)
                end
            end),
            TimeEvent(50 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil and
                    inst.sg.statemem.item:IsValid() and
                    inst.sg.statemem.item.components.fan ~= nil then
                    inst.sg.statemem.item.components.fan:Channel(inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target or inst)
                end
            end),
            TimeEvent(70 * FRAMES, function(inst)
                if inst.sg.statemem.item ~= nil then
                    inst.sg:RemoveStateTag("busy")
                end
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "yawn",
        tags = { "busy", "yawn", "pausepredict" },

        onenter = function(inst, data)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

            if data ~= nil and
                data.grogginess ~= nil and
                data.grogginess > 0 and
                inst.components.grogginess ~= nil then
                --Because we have the yawn state tag, we will not get
                --knocked out no matter what our grogginess level is.
                inst.sg.statemem.groggy = true
                inst.sg.statemem.knockoutduration = data.knockoutduration
                inst.components.grogginess:AddGrogginess(data.grogginess, data.knockoutduration)
            end

            inst.AnimState:PlayAnimation("yawn")
        end,

        timeline =
        {
            TimeEvent(.1, function(inst)
                local mount = inst.components.rider:GetMount()
                if mount ~= nil and mount.sounds ~= nil and mount.sounds.yell ~= nil then
                    inst.SoundEmitter:PlaySound(mount.sounds.yell)
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if inst:HasTag("weregoose") then
                    DoYawnSound(inst)
                end
            end),
            TimeEvent(15 * FRAMES, function(inst)
                if not inst:HasTag("weregoose") then
                    DoYawnSound(inst)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:RemoveStateTag("yawn")
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.groggy and
                not inst.sg:HasStateTag("yawn") and
                inst.components.grogginess ~= nil then
                --Add a little grogginess to see if it triggers
                --knock out now that we don't have the yawn tag
                inst.components.grogginess:AddGrogginess(.01, inst.sg.statemem.knockoutduration)
            end
        end,
    },

    State{
        name = "migrate",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_item_hat" or "pickup")

            inst.sg.statemem.action = inst.bufferedaction
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and
                    not inst:PerformBufferedAction() then
                    inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_item_hat_pst" or "pickup_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "mount",
        tags = { "doing", "busy", "nomorph", "nopredict" },

        onenter = function(inst)
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
            inst.sg.statemem.ridingwoby = inst.components.rider.target_mount and inst.components.rider.target_mount:HasTag("woby")

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_mount" or "mount")

            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
        end,

        timeline =
        {
            --Heavy lifting
            TimeEvent(12 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.ridingwoby then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/woby/big/bark")
                elseif not inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/grunt")
                end

            end),
            TimeEvent(38 * FRAMES, function(inst)
                if inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),

            --Normal
            TimeEvent(20 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
                    inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mounted_idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "dismount",
        tags = { "doing", "busy", "pausepredict", "nomorph", "dismounting" },

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("dismount")


            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.rider:ActualDismount()
        end,
    },

    State{
        name = "falloff",
        tags = { "busy", "pausepredict", "nomorph", "dismounting" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("fall_off")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.components.rider:ActualDismount()
        end,
    },

    State{
        name = "bucked",
        tags = { "busy", "pausepredict", "nomorph", "dismounting" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("buck")

            DoMountSound(inst, inst.components.rider:GetMount(), "yell")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("bucked_post")
                end
            end),
        },

        onexit = function(inst)
            inst.components.rider:ActualDismount()
        end,
    },

    State{
        name = "bucked_post",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bucked")
            inst.AnimState:PushAnimation("buck_pst", false)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "bundle",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            inst.AnimState:PlayAnimation("wrap_pre")
            inst.AnimState:PushAnimation("wrap_loop", true)
            inst.sg:SetTimeout(.7)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("make")
            inst.AnimState:PlayAnimation("wrap_pst")
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
            if not inst.sg.statemem.bundling then
                inst.SoundEmitter:KillSound("make")
            end
        end,
    },

    State{
        name = "bundling",
        tags = { "doing", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("wrap_loop") then
                inst.AnimState:PlayAnimation("wrap_loop", true)
            end
        end,

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.AnimState:PlayAnimation("wrap_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.bundling then
                inst.SoundEmitter:KillSound("make")
                inst.components.bundler:StopBundling()
            end
        end,
    },

    State{
        name = "bundle_pst",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("wrap_loop") then
                inst.AnimState:PlayAnimation("wrap_loop", true)
            end
            inst.sg:SetTimeout(.7)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.AnimState:PlayAnimation("wrap_pst")
            inst.sg.statemem.finished = true
            inst.components.bundler:OnFinishBundling()
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
            inst.SoundEmitter:KillSound("make")
            if not inst.sg.statemem.finished then
                inst.components.bundler:StopBundling()
            end
        end,
    },

    State{
        name = "startconstruct",

        onenter = function(inst)
            inst.sg:GoToState("construct", inst:HasTag("fastbuilder") and .5 or 1)
        end,
    },

    State{
        name = "construct",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            if timeout ~= nil then
                inst.sg:SetTimeout(timeout)
                inst.sg.statemem.delayed = true
                inst.AnimState:PlayAnimation("build_pre")
                inst.AnimState:PushAnimation("build_loop", true)
            else
                inst.sg:SetTimeout(.7)
                inst.AnimState:PlayAnimation("construct_pre")
                inst.AnimState:PushAnimation("construct_loop", true)
            end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.delayed then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(9 * FRAMES, function(inst)
                if not (inst.sg.statemem.delayed or inst:PerformBufferedAction()) then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
        },

        ontimeout = function(inst)
            if not inst.sg.statemem.delayed then
                inst.SoundEmitter:KillSound("make")
                inst.AnimState:PlayAnimation("construct_pst")
            elseif not inst:PerformBufferedAction() then
                inst.SoundEmitter:KillSound("make")
                inst.AnimState:PlayAnimation("build_pst")
            end
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
            if not inst.sg.statemem.constructing then
                inst.SoundEmitter:KillSound("make")
            end
        end,
    },

    State{
        name = "constructing",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            if not inst.AnimState:IsCurrentAnimation("construct_loop") then
                if inst.AnimState:IsCurrentAnimation("build_loop") then
                    inst.AnimState:PlayAnimation("build_pst")
                    inst.AnimState:PushAnimation("construct_loop", true)
                else
                    inst.AnimState:PlayAnimation("construct_loop", true)
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst) then
                inst.AnimState:PlayAnimation("construct_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        events =
        {
            EventHandler("stopconstruction", function(inst)
                inst.AnimState:PlayAnimation("construct_pst")
                inst.sg:GoToState("idle", true)
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.constructing then
                inst.SoundEmitter:KillSound("make")
                inst.components.constructionbuilder:StopConstruction()
            end
        end,
    },

    State{
        name = "construct_pst",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.SoundEmitter:PlayingSound("make") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            end
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
            inst.sg:SetTimeout(inst:HasTag("fastbuilder") and .5 or 1)
        end,

        ontimeout = function(inst)
            inst.sg:RemoveStateTag("busy")
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg.statemem.finished = true
            inst.components.constructionbuilder:OnFinishConstruction()
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
            inst.SoundEmitter:KillSound("make")
            if not inst.sg.statemem.finished then
                inst.components.constructionbuilder:StopConstruction()
            end
        end,
    },

    State{
        name = "startchanneling",
        tags = { "doing", "busy", "prechanneling", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("channel_pre")
            inst.AnimState:PushAnimation("channel_loop", true)
            inst.sg:SetTimeout(.7)
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(9 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("channel_pst")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "channeling",
        tags = { "doing", "channeling", "nodangle" },

        onenter = function(inst, target)
            inst:AddTag("channeling")
            inst.components.locomotor:Stop()
            if not inst.AnimState:IsCurrentAnimation("channel_loop") then
                inst.AnimState:PlayAnimation("channel_loop", true)
            end
            inst.sg.statemem.target = target
        end,

        onupdate = function(inst)
            if not CanEntitySeeTarget(inst, inst.sg.statemem.target) then
                inst.sg:GoToState("stopchanneling")
            end
        end,

        events =
        {
            EventHandler("ontalk", function(inst)
                if not (inst.AnimState:IsCurrentAnimation("channel_dial_loop") or inst:HasTag("mime")) then
                    inst.AnimState:PlayAnimation("channel_dial_loop", true)
                end
				return OnTalk_Override(inst)
            end),
            EventHandler("donetalking", function(inst)
                if not inst.AnimState:IsCurrentAnimation("channel_loop") then
                    inst.AnimState:PlayAnimation("channel_loop", true)
                end
				return OnDoneTalking_Override(inst)
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("channeling")
			CancelTalk_Override(inst)
            if not inst.sg.statemem.stopchanneling and
                inst.sg.statemem.target ~= nil and
                inst.sg.statemem.target:IsValid() and
                inst.sg.statemem.target.components.channelable ~= nil then
                inst.sg.statemem.target.components.channelable:StopChanneling(true)
            end
        end,
    },

    State{
        name = "stopchanneling",
        tags = { "idle", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("channel_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

	--Basically an "instant" action but with animation if you were idle
	State{
		name = "start_channelcast",

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:PerformBufferedAction()
			inst.AnimState:PlayAnimation(inst:IsChannelCastingItem() and "channelcast_idle_pre" or "channelcast_oh_idle_pre")
			inst.sg:GoToState("idle", true)
		end,
	},

	--Basically an "instant" action but with animation if you were idle
	State{
		name = "stop_channelcast",

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation(inst:IsChannelCastingItem() and "channelcast_idle_pst" or "channelcast_oh_idle_pst")
			inst:PerformBufferedAction()
			inst.sg:GoToState("idle", true)
		end,
	},

    State{
        name = "till_start",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equippedTool ~= nil and equippedTool.components.tool ~= nil and equippedTool.components.tool:CanDoAction(ACTIONS.DIG) then
				--upside down tool build
				inst.AnimState:PlayAnimation("till2_pre")
			else
				inst.AnimState:PlayAnimation("till_pre")
			end
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("till")
                end
            end),
        },
    },

    State{
        name = "till",
        tags = { "doing", "busy", "tilling" },

        onenter = function(inst)
			local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equippedTool ~= nil and equippedTool.components.tool ~= nil and equippedTool.components.tool:CanDoAction(ACTIONS.DIG) then
				--upside down tool build
				inst.sg.statemem.fliptool = true
				inst.AnimState:PlayAnimation("till2_loop")
			else
				inst.AnimState:PlayAnimation("till_loop")
			end
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/dig") end),
            TimeEvent(11 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(12 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mole/emerge") end),
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.AnimState:PlayAnimation(inst.sg.statemem.fliptool and "till2_pst" or "till_pst")
                    inst.sg:GoToState("idle", true)
                end
            end),
        },
    },

    State{
        name = "pour",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("water_pre")
            inst.AnimState:PushAnimation("water", false)

            inst.AnimState:Show("water")

            inst.sg.statemem.action = inst:GetBufferedAction()

            if inst.sg.statemem.action ~= nil then
                local pt = inst.sg.statemem.action:GetActionPoint()
                if pt ~= nil then
                    local tx, ty, tz = TheWorld.Map:GetTileCenterPoint(pt.x, 0, pt.z)
                    inst.Transform:SetRotation(inst:GetAngleToPoint(tx, ty, tz))
                end

                local invobject = inst.sg.statemem.action.invobject
				if invobject.components.finiteuses ~= nil and invobject.components.finiteuses:GetUses() <= 0 then
                    inst.AnimState:Hide("water")
                    inst.sg.statemem.nosound = true
                end
            end

            inst.sg:SetTimeout(26 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(5 * FRAMES, function(inst)
                if not inst.sg.statemem.nosound then
                    inst.SoundEmitter:PlaySound("farming/common/watering_can/use")
				end
            end),
            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    --------------------------------------------------------------------------
    -- Wanda Pocket Watch


    State{
        name = "pocketwatch_cast",
        tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre") -- 8 frames
            inst.AnimState:PushAnimation("pocketwatch_cast", false)
            inst.AnimState:PushAnimation("useitem_pst", false)

			local buffaction = inst:GetBufferedAction()
			if buffaction ~= nil then
		        inst.AnimState:OverrideSymbol("watchprop", buffaction.invobject.AnimState:GetBuild(), "watchprop")
				inst.sg.statemem.castfxcolour = buffaction.invobject.castfxcolour
				inst.sg.statemem.pocketwatch = buffaction.invobject
				inst.sg.statemem.target = buffaction.target
			end
        end,

		timeline =
		{
            TimeEvent(8 * FRAMES, function(inst)
				local pocketwatch = inst.sg.statemem.pocketwatch
				if pocketwatch ~= nil and pocketwatch:IsValid() and pocketwatch.components.pocketwatch:CanCast(inst, inst.sg.statemem.target) then
					inst.sg.statemem.stafffx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding()) and "pocketwatch_cast_fx_mount" or "pocketwatch_cast_fx")
					inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
					inst.sg.statemem.stafffx:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 })

                    inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/heal")
				end
            end),
            TimeEvent(16 * FRAMES, function(inst)
				if inst.sg.statemem.stafffx ~= nil then
					inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight_small")
					inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
					inst.sg.statemem.stafflight:SetUp(inst.sg.statemem.castfxcolour or { 1, 1, 1 }, 0.75, 0)
				end
            end),
            TimeEvent(25 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
				end
            end),

			--success timeline
            TimeEvent(40 * FRAMES, function(inst)
				if not inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
            end),

			--failed timeline
			TimeEvent(28 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:SetFrame(34)
					if inst.sg.statemem.stafffx ~= nil then
						inst.sg.statemem.stafffx:Remove()
						inst.sg.statemem.stafffx = nil
					end
					if inst.sg.statemem.stafflight ~= nil then
						inst.sg.statemem.stafflight:Remove()
						inst.sg.statemem.stafflight = nil
					end
				end
			end),
			TimeEvent(41 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.sg:RemoveStateTag("busy")
				end
			end),
		},

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
	                inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("watchprop")
			if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
				inst.sg.statemem.stafffx:Remove()
			end
			if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
				inst.sg.statemem.stafflight:Remove()
			end
		end,
    },

    State{
        name = "pocketwatch_warpback_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp_pre")

			local buffaction = inst:GetBufferedAction()
			if buffaction ~= nil then
		        inst.AnimState:OverrideSymbol("watchprop", buffaction.invobject.AnimState:GetBuild(), "watchprop")

				inst.sg.statemem.castfxcolour = buffaction.invobject.castfxcolour
			end
        end,

        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/warp") end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst:PerformBufferedAction() then
						-- statemem.warpback is set by the action function
						local data = shallowcopy(inst.sg.statemem)
						inst.sg.statemem.portaljumping = true
						inst.sg:GoToState("pocketwatch_warpback", data)
					else
	                    inst.sg:GoToState("idle")
					end
                end
            end),
        },

		onexit = function(inst)
			if not inst.sg.statemem.portaljumping then
				inst.AnimState:ClearOverrideSymbol("watchprop")
			end
		end,
    },

    State{
        name = "pocketwatch_warpback",
        tags = { "busy", "pausepredict", "nodangle", "nomorph", "jumping" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pocketwatch_warp")

			inst.sg.statemem.warpback_data = data.warpback -- 'warpback' passed in through the previous state bug is set by the action function
			inst.sg.statemem.castfxcolour = data.castfxcolour

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end

			inst.sg.statemem.stafffx = SpawnPrefab("pocketwatch_warpback_fx")
			inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
			inst.sg.statemem.stafffx:SetUp(data.castfxcolour or { 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),

            TimeEvent(4 * FRAMES, function(inst)
				local warpback_data = inst.sg.statemem.warpback_data
				local x, y, z = inst.Transform:GetWorldPosition()
				if (warpback_data.dest_worldid == nil or warpback_data.dest_worldid == TheShard:GetShardId()) and VecUtil_DistSq(x, z, warpback_data.dest_x, warpback_data.dest_z) > 30*30 then
					inst.sg.statemem.snap_camera = true
					inst:ScreenFade(false, 0.5)
				end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					if inst.sg.statemem.stafffx ~= nil then
						-- detach fx
						inst.sg.statemem.stafffx.entity:SetParent(nil)
						inst.sg.statemem.stafffx.Transform:SetPosition(inst.Transform:GetWorldPosition())
						inst.sg.statemem.stafffx = nil
					end

					if inst.sg.statemem.snap_camera then
						inst.sg.statemem.snap_camera = nil
						inst.sg.statemem.queued_snap_camera = true
					end

					local data = shallowcopy(inst.sg.statemem)
					local warpback_data = data.warpback_data
					local dest_worldid = warpback_data.dest_worldid
					inst.sg.statemem.portaljumping = true
					if dest_worldid ~= nil and dest_worldid ~= TheShard:GetShardId() then
						if Shard_IsWorldAvailable(dest_worldid) then
							TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = inst, portalid = nil, worldid = dest_worldid, x = warpback_data.dest_x, y = warpback_data.dest_y, z = warpback_data.dest_z })
						else
							warpback_data.dest_x, warpback_data.dest_y, warpback_data.dest_z = inst.Transform:GetWorldPosition()
							inst.sg:GoToState("pocketwatch_warpback_pst", data)
						end
					else
						inst.sg:GoToState("pocketwatch_warpback_pst", data)
					end
                end
            end),
        },

        onexit = function(inst)
			if inst.sg.statemem.snap_camera then
				inst:SnapCamera()
				inst:ScreenFade(true, 0.5)
			end
			if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
				inst.sg.statemem.stafffx:Remove()
			end
            if not inst.sg.statemem.portaljumping then
				inst.AnimState:ClearOverrideSymbol("watchprop")
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
            end
        end,
    },

    State{
        name = "pocketwatch_warpback_pst",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt", "jumping" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.DynamicShadow:Enable(false)
            inst.components.health:SetInvincible(true)

            inst.AnimState:PlayAnimation("pocketwatch_warp_pst")

			if data.queued_snap_camera then
				inst:SnapCamera()
				inst:ScreenFade(true, 0.5)
			end

            if data.warpback_data ~= nil then
                inst.Physics:Teleport(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
            end
            inst:PushEvent("onwarpback", data.warpback_data)

			local fx = SpawnPrefab("pocketwatch_warpbackout_fx")
			fx.Transform:SetPosition(data.warpback_data.dest_x, data.warpback_data.dest_y, data.warpback_data.dest_z)
			fx:SetUp(data.castfxcolour or { 1, 1, 1 })
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/recall")
            end),

            TimeEvent(3 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
				inst.sg:RemoveStateTag("jumping")
				inst.sg:RemoveStateTag("nomorph")
				inst.sg:RemoveStateTag("nointerrupt")
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
			TimeEvent(9 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst.sg:RemoveStateTag("nopredict")
				inst.sg:AddStateTag("idle")
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

        onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("watchprop")
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    State{
        name = "pocketwatch_openportal",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("pocketwatch_portal", false)
			inst.AnimState:PushAnimation("useitem_pst", false)

            inst.components.locomotor:Stop()

            local watch = inst.bufferedaction ~= nil and inst.bufferedaction.invobject
			if watch ~= nil then
		        inst.AnimState:OverrideSymbol("watchprop", watch.AnimState:GetBuild(), "watchprop")
	            inst.sg.statemem.castsound = watch.castsound
				inst.sg.statemem.same_shard = watch.components.recallmark ~= nil and watch.components.recallmark:IsMarkedForSameShard()
			end
        end,

        timeline =
        {
            TimeEvent(18 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
					inst.AnimState:Hide("gemshard")
	                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				else
	                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                end
            end),
			TimeEvent(32 * FRAMES, function(inst)
				if inst.sg.statemem.action_failed then
					inst.AnimState:Show("gemshard")
				else
					local line = inst.sg.statemem.same_shard and "ANNOUNCE_POCKETWATCH_OPEN_PORTAL" or "ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD"
					inst:DoTaskInTime(6 * FRAMES, function() inst.components.talker:Say(GetString(inst, line)) end)
				end
			end),
			TimeEvent(37 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("watchprop")
			if inst.sg.statemem.action_failed then
				inst.AnimState:Show("gemshard")
			end
        end,
    },

    State{
        name = "pocketwatch_portal_land",
        tags = { "busy", "nopredict", "nomorph", "nodangle", "jumping", "noattack" },

        onenter = function(inst, data)
			if not inst:HasTag("pocketwatchcaster") then
				inst.sg:GoToState("pocketwatch_portal_fallout")
				return
			end

            inst.components.locomotor:Stop()
			ForceStopHeavyLifting(inst)
			StartTeleporting(inst)

			inst.AnimState:PlayAnimation("jumpportal_out")

			local x, y, z = inst.Transform:GetWorldPosition()
			local fx = SpawnPrefab("pocketwatch_portal_exit_fx")
			fx.Transform:SetPosition(x, 4, z)
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
				inst:Show() -- hidden by StartTeleporting
            end),

            TimeEvent(17 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
            end),

            TimeEvent(20 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),

            TimeEvent(22 * FRAMES, function(inst)
                PlayFootstep(inst)
            end),

            TimeEvent(28 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("jumping")
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nomorph")
				inst.sg:RemoveStateTag("noattack")

				DoneTeleporting(inst)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			if inst.sg.statemem.isteleporting then
				DoneTeleporting(inst)
			end
		end,
    },

    State{
        name = "pocketwatch_portal_fallout",
        tags = { "busy", "nopredict", "nomorph", "nodangle", "jumping", "noattack" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
			ForceStopHeavyLifting(inst)
			StartTeleporting(inst)

			inst.AnimState:PlayAnimation("jumpportal2_out")
			inst.AnimState:PushAnimation("jumpportal2_out_pst", false)

			local x, y, z = inst.Transform:GetWorldPosition()
			local fx = SpawnPrefab("pocketwatch_portal_exit_fx")
			fx.Transform:SetPosition(x, 4, z)
        end,

        timeline =
        {
            TimeEvent(16 * FRAMES, function(inst)
				inst:Show() -- hidden by StartTeleporting
            end),

            TimeEvent(19 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("wanda1/wanda/jump_whoosh")
            end),

            TimeEvent(23 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
            end),

            TimeEvent(27 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),

            TimeEvent(59 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("jumping")
                inst.sg:RemoveStateTag("busy")
				DoneTeleporting(inst)
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = function(inst)
			if inst.sg.statemem.isteleporting then
				DoneTeleporting(inst)
			end
		end,
    },

    --------------------------------------------------------------------------
    -- Wortox soul hop

    State{
        name = "portal_jumpin_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin_pre")

            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() and not inst:PerformBufferedAction() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "portal_jumpin",
        tags = { "busy", "pausepredict", "nodangle", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin")
            local x, y, z = inst.Transform:GetWorldPosition()
            SpawnPrefab("wortox_portal_jumpin_fx").Transform:SetPosition(x, y, z)
            inst.sg:SetTimeout(11 * FRAMES)
            inst.sg.statemem.from_map = data and data.from_map or nil
            local dest = data and data.dest or nil
            if dest ~= nil then
                inst.sg.statemem.dest = dest
                inst:ForceFacePoint(dest:Get())
            else
                inst.sg.statemem.dest = Vector3(x, y, z)
            end

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/creatures/together/toad_stool/infection_post", nil, .7)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/spawn", nil, .5)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 1, .6, .3, .1 }
                PlayFootstep(inst)
            end),
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:AddStateTag("noattack")
                inst.components.health:SetInvincible(true)
                inst.DynamicShadow:Enable(false)
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.portaljumping = true
            inst.sg:GoToState("portal_jumpout", {dest = inst.sg.statemem.dest, from_map = inst.sg.statemem.from_map})
        end,

        onexit = function(inst)
            if not inst.sg.statemem.portaljumping then
                inst.components.health:SetInvincible(false)
                inst.DynamicShadow:Enable(true)
                DoWortoxPortalTint(inst, 0)
            end
        end,
    },

    State{
        name = "portal_jumpout",
        tags = { "busy", "nopredict", "nomorph", "noattack", "nointerrupt" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpout")
            inst:ResetMinimapOffset()
            if data and data.from_map then
                inst:SnapCamera()
            end
            local dest = data and data.dest or nil
            if dest ~= nil then
                inst.Physics:Teleport(dest:Get())
            else
                dest = inst:GetPosition()
            end
            SpawnPrefab("wortox_portal_jumpout_fx").Transform:SetPosition(dest:Get())
            inst.DynamicShadow:Enable(false)
            inst.sg:SetTimeout(14 * FRAMES)
            DoWortoxPortalTint(inst, 1)
            inst.components.health:SetInvincible(true)
            inst:PushEvent("soulhop")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.tints ~= nil then
                DoWortoxPortalTint(inst, table.remove(inst.sg.statemem.tints))
                if #inst.sg.statemem.tints <= 0 then
                    inst.sg.statemem.tints = nil
                end
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wortox/soul/hop_out") end),
            TimeEvent(5 * FRAMES, function(inst)
                inst.sg.statemem.tints = { 0, .4, .7, .9 }
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.components.health:SetInvincible(false)
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(8 * FRAMES, function(inst)
                inst.DynamicShadow:Enable(true)
                ToggleOnPhysics(inst)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.DynamicShadow:Enable(true)
            DoWortoxPortalTint(inst, 0)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
        end,
    },

    --------------------------------------------------------------------------
    -- Wormwood

	State{ name = "form_bush",		onenter = function(inst) inst.sg:GoToState("form_log", "bush"  ) end },
	State{ name = "form_bush2",		onenter = function(inst) inst.sg:GoToState("form_log", "leafy" ) end },
	State{ name = "form_juicy",		onenter = function(inst) inst.sg:GoToState("form_log", "juicy" ) end },
	State{ name = "form_bulb",		onenter = function(inst) inst.sg:GoToState("form_log", "bulb"  ) end },
	State{ name = "form_moon",		onenter = function(inst) inst.sg:GoToState("form_log", "moon"  ) end },
	State{ name = "form_monkey",	onenter = function(inst) inst.sg:GoToState("form_log", "monkey") end },

	State{
		name = "form_log",
		tags = { "doing", "busy", "nocraftinginterrupt", "nomorph", "keep_pocket_rummage" },

		onenter = function(inst, product)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("form_log_pre")
			inst.AnimState:PushAnimation("form_log", false)
			if product == nil or product == "log" then
				inst.sg.statemem.islog = true
				inst.AnimState:OverrideSymbol("wood_splinter", "player_wormwood", "wood_splinter")
			else
				inst.AnimState:OverrideSymbol("wood_splinter", "wormwood_skills_fx", "wood_splinter_"..product)
			end
			inst.sg.statemem.action = inst.bufferedaction
		end,

		timeline =
		{
			FrameEvent(0, function(inst)
				if not inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("meta2/wormwood/armchop_f0")
				end
			end),
			FrameEvent(2, function(inst)
				if inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/living_log_craft")
				end
			end),
			FrameEvent(40, function(inst)
				if not inst.sg.statemem.islog then
					inst.SoundEmitter:PlaySound("meta2/wormwood/armchop_f40")
				end
			end),
			FrameEvent(50, function(inst)
				inst:PerformBufferedAction()
			end),
			FrameEvent(58, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(62, TryResumePocketRummage),
		},

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if inst.bufferedaction == inst.sg.statemem.action and
					(not inst.components.playercontroller or
					inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
				inst:ClearBufferedAction()
			end
			inst.AnimState:ClearOverrideSymbol("wood_splinter")
			CheckPocketRummageMem(inst)
		end,
	},

    State{
        name = "fertilize",
		tags = { "doing", "busy", "nomorph", "self_fertilizing", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.sg.statemem.fast = inst.components.skilltreeupdater:IsActivated("wormwood_quick_selffertilizer")

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fertilize_pre")
            inst.AnimState:PushAnimation(inst.sg.statemem.fast and "shortest_fertilize" or "fertilize", false)
        end,

        timeline =
        {
            FrameEvent(27, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/fertalize_LP", "rub")
                inst.SoundEmitter:SetParameter("rub", "start", math.random())
            end),

            FrameEvent(45, function(inst)
                if inst.sg.statemem.fast then
                    inst:PerformBufferedAction()
                end
            end),
            FrameEvent(50, function(inst)
                if inst.sg.statemem.fast then
                    inst.SoundEmitter:KillSound("rub")
                end
            end),
            FrameEvent(52, function(inst)
                if inst.sg.statemem.fast then
					if not TryResumePocketRummage(inst) then
						inst.sg:RemoveStateTag("busy")
					end
                end
            end),

            FrameEvent(82, function(inst)
                if not inst.sg.statemem.fast then
                    inst.SoundEmitter:KillSound("rub")
                end
            end),
            FrameEvent(88, function(inst)
                if not inst.sg.statemem.fast then
                    inst:PerformBufferedAction()
                end
            end),
            FrameEvent(90, function(inst)
                if not inst.sg.statemem.fast then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
			FrameEvent(92, function(inst)
				if not inst.sg.statemem.fast then
					TryResumePocketRummage(inst)
				end
			end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("rub")
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        name = "fertilize_short",
		tags = { "doing", "busy", "nomorph", "self_fertilizing", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("short_fertilize_pre")
            inst.AnimState:PushAnimation("short_fertilize", false)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/fertalize_LP", "rub")
                inst.SoundEmitter:SetParameter("rub", "start", math.random())
            end),
            TimeEvent(18 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(31 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("rub")
            end),
            TimeEvent(33 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
			FrameEvent(35, TryResumePocketRummage),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("rub")
			CheckPocketRummageMem(inst)
        end,
    },

    State{
        name = "spawn_mutated_creature",
		tags = { "doing", "busy", "nocraftinginterrupt", "nomorph", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("wormwood_cast_spawn_pre")
			inst.AnimState:PushAnimation("wormwood_cast_spawn", false)
            inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
            FrameEvent(0, function(inst)
                inst.SoundEmitter:PlaySound("meta2/wormwood/animation_sendup")
            end),
            FrameEvent(34, function(inst)
                inst:PerformBufferedAction()
            end),
			FrameEvent(38, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
			FrameEvent(42, TryResumePocketRummage),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
                    (not inst.components.playercontroller or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			CheckPocketRummageMem(inst)
        end,
    },

    --------------------------------------------------------------------------
    -- Wigfrid

    State{
        name = "sing_pre",
		tags = { "busy", "nointerrupt", "keep_pocket_rummage" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("sing_pre", false)
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then

                    local buffaction = inst:GetBufferedAction()
                    local songdata = buffaction and buffaction.invobject.songdata or nil
                    local singinginspiration = inst.components.singinginspiration

                    if singinginspiration and songdata then
                        if singinginspiration:IsSongActive(songdata) then
                            inst:ClearBufferedAction()
                            inst.components.talker:Say(GetActionFailString(inst, "SING_FAIL", "SAMESONG"))
							if not TryResumePocketRummage(inst) then
								inst.sg:GoToState("idle")
							end
						else
							inst.sg.statemem.keep_pocket_rummage_mem_onexit = true
							if singinginspiration:CanAddSong(songdata, buffaction.invobject) then
								inst.sg:GoToState("sing")
							else
								inst.sg:GoToState("cantsing")
							end
                        end
					elseif not TryResumePocketRummage(inst) then
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },

		onexit = CheckPocketRummageMem,
    },

    State{
        name = "sing_fail",
		tags = { "busy", "keep_pocket_rummage" },

        onenter = function(inst)
            inst:PerformBufferedAction()

			if not TryResumePocketRummage(inst) then
				inst.sg:GoToState("idle")
			end
			--V2C: BAD! (code AFTER leaving state)
			--     Probably because they wanted talk to happen with "idle" state tag.
			--     Will just leave this one since talking is not that dangerous.
			--     PLEASE DO NOT COPY
            inst.components.talker:Say(GetActionFailString(inst, "SING_FAIL", "SAMESONG"))
        end,

		onexit = CheckPocketRummageMem,
    },

    State{
        name = "sing",
		tags = { "busy", "nointerrupt", "keep_pocket_rummage" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local songdata = buffaction and buffaction.invobject.songdata or nil

            if songdata ~= nil then
                inst.AnimState:PushAnimation(songdata.INSTANT and "quote" or "sing", false)
                if songdata.INSTANT then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_" .. string.upper(songdata.NAME)), nil, true)
                end
            end
        end,

        timeline =
        {
            TimeEvent(3 * FRAMES, function(inst)
                local buffaction = inst:GetBufferedAction()
                local songdata = buffaction and buffaction.invobject.songdata or nil
                if songdata then
                    inst.SoundEmitter:PlaySound(songdata.SOUND or ("dontstarve_DLC001/characters/wathgrithr/"..(songdata.INSTANT and "quote" or "sing")))
                end
            end),

            TimeEvent(24 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(34 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
			FrameEvent(42, TryResumePocketRummage),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

		onexit = CheckPocketRummageMem,
    },

    State{
        name = "cantsing",
		tags = { "keep_pocket_rummage" },

        onenter = function(inst)
            local buffaction = inst:GetBufferedAction()
            local required_skill = buffaction and buffaction.invobject.songdata and buffaction.invobject.songdata.REQUIRE_SKILL or nil

            inst:ClearBufferedAction()

            local failstring =
                required_skill ~= nil and
                not inst.components.skilltreeupdater:IsActivated(required_skill) and
                "ANNOUNCE_NOTSKILLEDENOUGH" or
                "ANNOUNCE_NOINSPIRATION"

            inst.components.talker:Say(GetString(inst, failstring), nil, true)

            inst.AnimState:PlayAnimation("sing_fail", false)

            inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/fail")
        end,

		timeline =
		{
			FrameEvent(34, TryResumePocketRummage),
		},

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
		},

		onexit = CheckPocketRummageMem,
    },

    --------------------------------------------------------------------------
    -- sail anims

    State{
        name = "furl_boost",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("pull_big_pre")
            inst.AnimState:PushAnimation("pull_big_loop", false)

            if inst:HasTag("is_heaving") then
                inst:RemoveTag("is_heaving")
            else
                inst:AddTag("is_heaving")
            end

            inst:AddTag("is_furling")

            inst.sg.mem.furl_target = inst.bufferedaction.target or inst.sg.mem.furl_target

            local target_x, target_y, target_z = inst.sg.mem.furl_target.Transform:GetWorldPosition()
            inst:ForceFacePoint(target_x, 0, target_z)
        end,

        onupdate = function(inst)
            if not inst:HasTag("is_furling") then
                inst.sg:GoToState("idle")
            end
        end,

        timeline =
        {
            TimeEvent(17 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_down")
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.stopfurling then
                        inst.AnimState:PlayAnimation("pull_big_pst", false)
						inst.sg:GoToState("idle", true)
					else
						inst.sg.statemem.not_interrupted = true
						inst.sg:GoToState("furl", inst.sg.mem.furl_target) -- _repeat_delay
					end
				end
            end),

            EventHandler("stopfurling", function(inst)
                inst.sg.statemem.stopfurling = true
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
                inst:RemoveTag("switchtoho")
				if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast ~= nil then
	                inst.sg.mem.furl_target.components.mast:RemoveSailFurler(inst)
				end
                inst:RemoveTag("is_furling")
                inst:RemoveTag("is_heaving")
            end
        end,
    },

    State{
        name = "furl",
        tags = { "doing" },

        onenter = function(inst)
            inst:AddTag("switchtoho")
            inst.AnimState:PlayAnimation("pull_small_pre")
            inst.AnimState:PushAnimation("pull_small_loop", true)
            inst:PerformBufferedAction() -- this will clear the buffer if it's full, but you don't get here from an action anyway.
            if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast ~= nil then
                inst.sg.mem.furl_target.components.mast:AddSailFurler(inst, 1)
                inst.sg.statemem._onburnt = function()
                    inst.AnimState:PlayAnimation("pull_small_pst")
                    inst.sg:GoToState("idle",true)
                end
                inst:ListenForEvent("onburnt", inst.sg.statemem._onburnt, inst.sg.mem.furl_target)
            end
            if inst.components.mightiness then
                inst.components.mightiness:Pause()
            end
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
            TimeEvent((15+17) * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
            TimeEvent((15+(2*17)) * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
            TimeEvent((15+(3*17)) * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
            TimeEvent((15+(4*17)) * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
            TimeEvent((15+(5*17)) * FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up")
            end),
        },

        events =
        {
            EventHandler("stopfurling", function(inst)
                inst.AnimState:PlayAnimation("pull_small_pst")
                inst.sg:GoToState("idle",true)
            end),
        },

        onexit = function(inst)
            if inst.components.mightiness then
                inst.components.mightiness:Resume()
            end

            if not inst.sg.statemem.not_interrupted then
                inst:RemoveTag("switchtoho")
                if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast ~= nil then
                    inst.sg.mem.furl_target.components.mast:RemoveSailFurler(inst)
                end
                inst:RemoveTag("is_furling")
                inst:RemoveTag("is_heaving")
            end

			if inst.sg.statemem._onburnt ~= nil and inst.sg.mem.furl_target:IsValid() then
	            inst:RemoveEventCallback("onburnt", inst.sg.statemem._onburnt, inst.sg.mem.furl_target)
			end
        end,
    },

    State{
        name = "furl_fail",
        tags = { "busy", "furl_fail" },

        onenter = function(inst)

            inst:PerformBufferedAction()
			if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast ~= nil then
	            inst.sg.mem.furl_target.components.mast:AddSailFurler(inst, 0)
			end

            local fail_str = GetActionFailString(inst, "LOWER_SAIL_FAIL")
            inst.components.talker:Say(fail_str)

            inst:RemoveTag("is_heaving")

            inst.AnimState:PlayAnimation("pull_fail")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
				if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast ~= nil then
	                inst.sg.mem.furl_target.components.mast:RemoveSailFurler(inst)
				end
                inst:RemoveTag("is_furling")
                inst:RemoveTag("is_heaving")
            end
        end,

        events =
        {
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interrupted = true
					inst.sg:GoToState("furl", inst.sg.mem.furl_target)
				end
            end),
            EventHandler("stopfurling", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    --------------------------------------------------------------------------


    State{
        name = "tackle_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_lag_pre")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() - FRAMES)
        end,

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            if inst.sg.currentstate.name == "tackle_pre" then
                --action failed, do it anyway!
                --repro: action target entity is removed
                inst.sg.statemem.tackling = true
                inst.sg:GoToState("tackle_start")
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.tackling and inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "tackle_start",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_pre")
            inst.Physics:SetMotorVel(12, 0, 0)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.WORLD)
            inst.Physics:CollidesWith(COLLISION.OBSTACLES)
            inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
            inst.Physics:CollidesWith(COLLISION.GIANTS)
            inst.sg.statemem.targets = {}
            inst.sg.statemem.edgecount = 0
            inst.sg.statemem.trailtask = inst:DoPeriodicTask(0, function(inst, data)
                if data.delay > 0 then
                    data.delay = data.delay - 1
                else
                    data.delay = math.random(4, 6)
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local angle = inst.Transform:GetRotation() * DEGREES
                    local fx = SpawnPrefab("plant_dug_small_fx")
                    fx.Transform:SetPosition(x - math.cos(angle) * 1.6, 0, z + math.sin(angle) * 1.6)
                    if math.random() < .5 then
                        fx.AnimState:SetScale(-1, 1)
                    end
                    local scale = .8 + math.random() * .5
                    fx.Transform:SetScale(scale, scale, scale)
                end
            end,
            nil,
            { delay = 0 })
        end,

        timeline =
        {
            TimeEvent(4 * FRAMES, PlayMooseFootstep),
        },

        onupdate = function(inst)
            if inst.components.tackler ~= nil then
                if inst.components.tackler:CheckCollision(inst.sg.statemem.targets) then
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("tackle_collide")
                elseif not inst.components.tackler:CheckEdge() then
                    inst.sg.statemem.edgecount = 0
                elseif inst.sg.statemem.edgecount < 3 then
                    inst.sg.statemem.edgecount = inst.sg.statemem.edgecount + 1
                else
                    inst.sg.statemem.stopping = true
                    inst.sg:GoToState("tackle_stop")
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg.statemem.tackling = true
                    inst.sg:GoToState("tackle", {
                        targets = inst.sg.statemem.targets,
                        edgecount = inst.sg.statemem.edgecount,
                        trail = inst.sg.statemem.trailtask,
                        loop = 3,
                    })
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.tackling then
                if inst.sg.statemem.trailtask ~= nil then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
                if not inst.sg.statemem.stopping and inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,
    },

    State{
        name = "tackle",
		tags = { "busy", "nopredict", "nomorph", "nointerrupt", "overridelocomote" },

        onenter = function(inst, data)
            inst.sg.statemem.targets = data ~= nil and data.targets or nil
            inst.sg.statemem.edgecount = data ~= nil and data.edgecount or 0
            inst.sg.statemem.trailtask = data ~= nil and data.trail or nil
            inst.sg.statemem.loop = data ~= nil and data.loop or 0
            if not inst.AnimState:IsCurrentAnimation("charge_loop") then
                inst.AnimState:PlayAnimation("charge_loop", true)
            end
            inst.sg:SetTimeout(
                inst.sg.statemem.loop > 0 and
                inst.AnimState:GetCurrentAnimationLength() or
                inst.AnimState:GetCurrentAnimationLength() * math.random()
            )

			if data ~= nil and data.cancancel ~= nil then
				inst.sg.statemem.cancancel = data.cancancel
			elseif inst.components.skilltreeupdater:IsActivated("woodie_curse_moose_3") then
				inst.player_classified.busyremoteoverridelocomote:set(true)
				inst.sg.statemem.init_cancancel = true
			end
        end,

        events =
        {
            EventHandler("locomote", function(inst, data)
				if data ~= nil and data.remoteoverridelocomote and inst.sg.statemem.cancancel then
					inst.sg.statemem.stopping = true
					inst.sg:GoToState("tackle_stop")
				end
				return true
            end),
        },

        timeline =
        {
            TimeEvent(1 * FRAMES, PlayMooseFootstep),
            TimeEvent(4 * FRAMES, PlayMooseFootstep),
            TimeEvent(10 * FRAMES, PlayMooseFootstep),
            TimeEvent(TUNING.SKILLS.WOODIE.MOOSE_CANCEL_CHARGE_TIME, function(inst)
				if inst.sg.statemem.init_cancancel then
					inst.sg.statemem.cancancel = true
				end
            end),
        },

        onupdate = function(inst)
            if inst.components.tackler ~= nil then
                if inst.components.tackler:CheckCollision(inst.sg.statemem.targets) then
					inst.sg.statemem.stopping = true
                    inst.sg:GoToState("tackle_collide")
					return
                elseif not inst.components.tackler:CheckEdge() then
                    inst.sg.statemem.edgecount = 0
                elseif inst.sg.statemem.edgecount < 3 then
                    inst.sg.statemem.edgecount = inst.sg.statemem.edgecount + 1
                else
                    inst.sg.statemem.stopping = true
					inst.sg:GoToState("tackle_stop")
					return
                end
            end

			if inst.sg.statemem.cancancel and inst.HUD ~= nil then
				local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
				if math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)) >= deadzone or
					math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)) >= deadzone
				then
					inst.sg.statemem.stopping = true
					inst.sg:GoToState("tackle_stop")
				end
			end
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.loop > 0 then
                inst.sg.statemem.tackling = true
                inst.sg:GoToState("tackle", {
                    targets = inst.sg.statemem.targets,
                    edgecount = inst.sg.statemem.edgecount,
                    trail = inst.sg.statemem.trailtask,
                    loop = inst.sg.statemem.loop - 1,
					cancancel = inst.sg.statemem.cancancel == true,
                })
            else
                inst.sg.statemem.stopping = true
				inst.sg:GoToState("tackle_stop")
            end
        end,

        onexit = function(inst)
            if not inst.sg.statemem.tackling then
				inst.player_classified.busyremoteoverridelocomote:set(false)
                if inst.sg.statemem.trailtask ~= nil then
                    inst.sg.statemem.trailtask:Cancel()
                    inst.sg.statemem.trailtask = nil
                end
                inst.Physics:Stop()
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
				if not inst.sg.statemem.stopping and inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
                end
            end
        end,
    },

    State{
        name = "tackle_collide",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("charge_bash")
        end,

        timeline =
        {
            TimeEvent(8.5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
            TimeEvent(32 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(35 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
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

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "tackle_stop",
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

		onenter = function(inst)
            inst.AnimState:PlayAnimation("charge_pst")
            inst.sg.statemem.speed = 12
            inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            PlayMooseFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/slide")
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > .1 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                inst.sg.statemem.speed = inst.sg.statemem.speed * .75
            elseif inst.sg.statemem.speed > 0 then
                inst.Physics:Stop()
                inst.sg.statemem.speed = 0
            end
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(22 * FRAMES, function(inst)
                inst.sg:GoToState("idle", true)
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

        onexit = function(inst)
            inst.Physics:Stop()
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "beaver_tailslap_pre",
        tags = { "busy", "tailslapping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("tail_slap_pre")
            inst.components.locomotor:Stop()
        end,

        timeline =
        {
            FrameEvent(10, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("beaver_tailslap")
				end
			end),
		},
    },

    State{
        name = "beaver_tailslap",
		tags = { "busy", "tailslapping", "pausepredict", "nomorph" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("tail_slap")

            inst.components.locomotor:Stop()

            if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        timeline =
        {
			FrameEvent(4, function(inst)
				ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .025, .4, inst, 20)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("meta2/woodie/werebeaver_groundpound")
            end),
			FrameEvent(22, function(inst)
				inst.sg:GoToState("idle", true)
			end),
        },

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "weregoose_takeoff_pre",
        tags = { "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("takeoff_pre")
            inst.components.locomotor:Stop()
        end,

        timeline =
        {
            FrameEvent(10, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("weregoose_takeoff")
				end
			end),
		},
    },

    State{
        name = "weregoose_takeoff",
		tags = { "busy", "flying", "pausepredict", "nomorph", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.health:SetInvincible(true)

            if inst.components.playercontroller ~= nil then
				inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            inst:SetCameraDistance(14)

            inst.AnimState:PushAnimation("takeoff")

            inst.sg.statemem.feather_fx = 7*FRAMES
            inst.sg.statemem.pos = inst:GetPosition()
			inst.sg.statemem.pos.y = 0

            inst.SoundEmitter:PlaySound("meta2/woodie/weregoose_takeoff")

            inst:SetGooseFlying(true)
        end,

        onupdate = function(inst, dt)
            inst.sg.statemem.feather_fx = inst.sg.statemem.feather_fx - dt
            if inst.sg.statemem.feather_fx <= 0 then
                inst.sg.statemem.feather_fx = 7*FRAMES
				SpawnPrefab("weregoose_feathers"..tostring(math.random(3))).Transform:SetPosition(inst.sg.statemem.pos:Get())
            end

			inst.sg.statemem.pos.y = inst.sg.statemem.pos.y + (dt * 7)
        end,

        timeline =
        {
			FrameEvent(7, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
            FrameEvent(40, function(inst)
                inst:ScreenFade(false, 1)
            end),
            FrameEvent(60, function(inst)
                inst:Hide()
                inst:PerformBufferedAction()
            end),
            FrameEvent(100, function(inst)
				inst.sg.statemem.landing = true
				inst.sg:GoToState("weregoose_land")
            end),
        },

		onexit = function(inst)
			inst:Show()
			if not inst.sg.statemem.landing then
				--interrupted
				inst.DynamicShadow:Enable(true)
				inst:SetGooseFlying(false)
				inst:ScreenFade(true, 0)
				inst:SetCameraDistance()
				inst.components.health:SetInvincible(false)
				if inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
				end
			end
		end,
    },

    State{
        name = "weregoose_land",
        tags = { "busy", "flying", "nopredict", "nomorph", "noattack", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("land")
            inst:ScreenFade(true, 1)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.landing = true
                    inst.sg:GoToState("weregoose_land_pst")
                end
            end),
        },

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
			inst:SetGooseFlying(false)
			inst:SetCameraDistance()
			inst.components.health:SetInvincible(false)
			if not inst.sg.statemem.landing then
				--interrupted
				if inst.components.playercontroller ~= nil then
					inst.components.playercontroller:Enable(true)
				end
			end
		end,
    },

    State{
        name = "weregoose_land_pst",
        tags = { "busy", "flying", "nopredict", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("land_pst")
            inst.SoundEmitter:PlaySound("meta2/woodie/weregoose_land")
        end,

		timeline =
		{
			FrameEvent(2, function(inst)
				inst.sg:RemoveStateTag("flying")
			end),
			FrameEvent(12, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
			end),
			FrameEvent(14, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    --------------------------------------------------------------------------

    -- winter's feast anims

    State{
        name = "winters_feast_eat",
        tags = { "doing", "feasting" },

        onenter = function(inst, target)
            inst._winters_feast_music:push()

            inst.components.locomotor:Stop()

            if target == nil then
                target = inst:GetBufferedAction() ~= nil and inst:GetBufferedAction().target
            end
            inst.sg.statemem.target = target
            inst:PerformBufferedAction()

            if target ~= nil and target:IsValid() then
                target.components.wintersfeasttable.current_feasters[inst] = true

                inst.AnimState:PlayAnimation("feast_eat_pre_pre")
                inst.AnimState:PushAnimation("feast_eat_pre", false)
                inst.AnimState:PushAnimation("feast_eat_loop", false)
                inst.AnimState:PushAnimation("feast_eat_loop", false)
                inst.AnimState:PushAnimation("feast_eat_pst", false)
            else
                inst.sg:GoToState("idle")
            end
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst)
                local target = inst.sg.statemem.target
                if target ~= nil and target:IsValid() and target:HasTag("readyforfeast") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
                else
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(94 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eating")
            end),
        },

        onupdate = function(inst)
            if not inst:IsInLight() then
                inst.sg.statemem.is_in_dark = true
                inst.sg:GoToState("idle")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                local target = inst.sg.statemem.target
                if target ~= nil and target:IsValid() and target:HasTag("readyforfeast") then
                    inst.sg.statemem.keep_eating = true
                    inst.sg:GoToState("winters_feast_eat", target)
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            local target = inst.sg.statemem.target

            if target ~= nil and target.entity:IsValid() then
                target.components.wintersfeasttable.current_feasters[inst] = nil
            end

            inst.SoundEmitter:KillSound("eating")
            if not inst.sg.statemem.keep_eating then
                TheWorld:PushEvent("feasterfinished",{player=inst, target=target, is_in_dark=inst.sg.statemem.is_in_dark})
            end
        end,
    },

    State{
        name = "research",
        tags = { "busy", "pausepredict", "nomorph" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("research")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(14 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("yotb_2021/common/heel_click")
            end),

            TimeEvent(23 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("yotb_2021/common/heel_click")
            end),

            TimeEvent(33 * FRAMES, function(inst)
                --Lava Arena adds nointerrupt state tag to prevent hit interruption
                inst.sg:RemoveStateTag("nointerrupt")
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
        name = "herd_followers",
        tags = { "busy", "doing", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("webber_spider_whistle", false)
            inst.AnimState:PushAnimation("useitem_pst", false)
        end,

        timeline =
        {
            TimeEvent(26 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/goose/death_voice") end),
            TimeEvent(26 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("webber1/spiderwhistle/blow",nil,.8) end),
            TimeEvent(35 * FRAMES, function(inst) inst:PerformBufferedAction() end),
			TimeEvent(58 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
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
        name = "repel_followers",
        tags = { "busy", "doing", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("spider_repellent", false)
            inst.AnimState:PushAnimation("useitem_pst", false)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("webber2/common/spider_repellent") end),
            TimeEvent(17 * FRAMES, function(inst) inst:PerformBufferedAction() end),
			TimeEvent(43 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
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

    --------------------------------------------------------------------------
    -- Year of the Catcoon
    State {
        name = "hideandseek_counting",
        tags = { "idle", "canrotate", "notalking" },

        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("down_hideandseek_pre")
            inst.AnimState:PushAnimation("down_hideandseek_loop", true)

            inst.sg:SetTimeout((timeout or 1) - FRAMES * 12)
        end,

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("down_hideandseek_pst")
            inst.sg.statemem.done = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.done and inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", true)
                end
            end),
		}
    },

    --------------------------------------------------------------------------
    -- WX78 Rework
    State {
        name = "applyupgrademodule",
		tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("upgrade_pre")
			inst.AnimState:PushAnimation("upgrade", false)
            inst.SoundEmitter:PlaySound("WX_rework/module/insert")
        end,

        timeline =
        {
            TimeEvent(33*FRAMES, function(inst)
				inst.sg:AddStateTag("nointerrupt")
                inst:PerformBufferedAction()
            end),
			TimeEvent(47 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
    },

    State {
        name = "removeupgrademodules",
		tags = { "busy", "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("downgrade", false)
            inst.AnimState:PushAnimation("useitem_pst", false)
            inst.SoundEmitter:PlaySound("WX_rework/module/remove")
        end,

        timeline =
        {
			TimeEvent(26 * FRAMES, function(inst)
				inst.sg:AddStateTag("nointerrupt")
			end),
            TimeEvent(27*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
			TimeEvent(35 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("nointerrupt")
			end),
            TimeEvent(38*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },

		events =
		{
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},
    },

	--------------------------------------------------------------------------
	-- Maxwell rework

	State{
		name = "start_using_tophat",
		tags = { "doing", "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()

			local buffaction = inst:GetBufferedAction()
			local hat = buffaction ~= nil and buffaction.invobject or nil
			inst.AnimState:PlayAnimation(
				hat ~= nil and
				inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == hat and
				"tophat_equipped_pre" or
				"tophat_empty_pre"
			)
			inst.components.inventory:ReturnActiveActionItem(hat)
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("using_tophat")
				end
			end),
		},
	},

	State{
		name = "using_tophat",
		tags = { "doing", "overridelocomote" },

		onenter = function(inst)
			if inst:PerformBufferedAction() then
				local hat, equipped, build, skin_build
				if inst.components.magician ~= nil then
					hat = inst.components.magician.item
					equipped = inst.components.magician.equip
					if hat ~= nil then
						build = hat.AnimState:GetBuild()
						skin_build = hat:GetSkinBuild()
					end
				end

				inst.AnimState:PlayAnimation(equipped and "tophat_equipped_start" or "tophat_empty_start")
				inst.AnimState:PushAnimation("tophat_loop")
				if skin_build ~= nil then
					inst.AnimState:OverrideItemSkinSymbol("swap_hattop", skin_build, "swap_hat", hat.GUID, build)
				else
					inst.AnimState:OverrideSymbol("swap_hattop", build, "swap_hat")
				end

				--shadow particles
				inst.AnimState:OverrideSymbol("tophat_fx_float", "tophat_fx", "fx_float")
				inst.AnimState:SetSymbolMultColour("tophat_fx_float", 1, 1, 1, .5)
				inst.sg.statemem.fx_float = SpawnPrefab("tophat_using_shadow_fx")
				inst.sg.statemem.fx_float:AttachToTopHatUser(inst)

				--shadow swirl
				inst.sg.statemem.fx_front = SpawnPrefab("tophat_swirl_fx")
				inst.sg.statemem.fx_front:AttachToTopHatUser(inst, true)
				inst.sg.statemem.fx_back = SpawnPrefab("tophat_swirl_fx")
				inst.sg.statemem.fx_back:AttachToTopHatUser(inst, false)
			else
				inst.AnimState:PlayAnimation(
					inst.AnimState:IsCurrentAnimation("tophat_equipped_pre") and
					"tophat_equipped_pst" or
					"tophat_empty_pst"
				)
				inst.AnimState:SetFrame(9)
				inst.sg:RemoveStateTag("overridelocomote")
			end
		end,

		events =
		{
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
			EventHandler("equip", function(inst)
				if inst.AnimState:IsCurrentAnimation("tophat_loop") then
					inst.AnimState:PlayAnimation("tophat_item_in")
					inst.AnimState:PushAnimation("tophat_loop")
				end
			end),
			EventHandler("unequip", function(inst)
				if inst.AnimState:IsCurrentAnimation("tophat_loop") then
					inst.AnimState:PlayAnimation("tophat_item_in")
					inst.AnimState:PushAnimation("tophat_loop")
				end
			end),
			EventHandler("performaction", function(inst, data)
				if data ~= nil and data.action ~= nil and data.action.action == ACTIONS.DROP then
					if inst.AnimState:IsCurrentAnimation("tophat_loop") then
						inst.AnimState:PlayAnimation("tophat_item_in")
						inst.AnimState:PushAnimation("tophat_loop")
					end
				end
			end),
			EventHandler("magicianstopped", function(inst)
				--handle unexpected stops, e.g. the item got deleted
				inst.sg:GoToState("idle")
			end),
			EventHandler("locomote", function(inst)
				if inst.sg:HasStateTag("overridelocomote") then
					local data = { locomoting = true, talktask = inst.sg.statemem.talktask }
					inst.sg.statemem.talktask = nil
					inst.sg.statemem.stopusingmagiciantool = true
					inst.sg:GoToState("stop_using_tophat", data)
					return true
				end
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.stopusingmagiciantool then
				--interrupted
				inst.AnimState:ClearOverrideSymbol("swap_hattop")
				inst.AnimState:ClearOverrideSymbol("tophat_fx_float")
				inst.AnimState:SetSymbolMultColour("tophat_fx_float", 1, 1, 1, 1)
				if inst.components.magician ~= nil then
					if not inst.sg.statemem.is_going_to_action_state then
						inst.components.magician:DropToolOnStop()
					end
					inst.components.magician:StopUsing()
				end
			end
			if inst.sg.statemem.fx_float ~= nil then
				inst.sg.statemem.fx_float:Remove()
				inst.sg.statemem.fx_front:Remove()
				inst.sg.statemem.fx_back:Remove()
			end
			CancelTalk_Override(inst)
		end,
	},

	State{
		name = "stop_using_tophat",
		tags = { "idle", "overridelocomote" },

		onenter = function(inst, data)
			-- 'locomoting' means we got here via locomotion control rather than ACTIONS.STOPUSINGMAGICTOOL:
			-- - We must manually stop magician
			-- - Any buffered actions would be our NEXT action after we play some pst anim
			local locomoting
			if data ~= nil then
				locomoting = data.locomoting
				inst.sg.statemem.talktask = data.talktask
			end

			local held, equipped
			if inst.components.magician ~= nil then
				inst.sg.statemem.hat = inst.components.magician.item
				held = inst.components.magician.held
				equipped = inst.components.magician.equip and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == nil
				if locomoting then
					inst.components.magician:StopUsing()
				end
			end

			if not locomoting then
				if not inst:PerformBufferedAction() then
					inst.sg:GoToState("idle")
					return
				end
			end

			if equipped then
				--NOTE: anim is duplicated for both swap_hat and swap_hattop
				--      so that it'll be seamless for clients predicting the
				--      anim before the re-equip happens on the server.
				inst.AnimState:PlayAnimation("tophat_equipped_pst")
				inst.AnimState:ClearOverrideSymbol("swap_hattop")
			elseif held then
				inst.AnimState:PlayAnimation("tophat_empty_pst")
			else
				--dropped on ground
				inst.sg:GoToState("idle")
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
			EventHandler("ontalk", function(inst)
				if inst.sg:HasStateTag("overridelocomote") then
					OnTalk_Override(inst)
					return true
				end
				CancelTalk_Override(inst, true)
			end),
			EventHandler("donetalking", OnDoneTalking_Override),
			EventHandler("equip", function(inst, data)
				--suppress equip events for re-equipping our magiciantool hat
				return data ~= nil and data.item == inst.sg.statemem.hat
			end),
			EventHandler("locomote", function(inst)
				--don't handle locomotion states yet
				--we still allows buffering them, since we are not "busy"
				return inst.sg:HasStateTag("overridelocomote")
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.AnimState:ClearOverrideSymbol("swap_hattop")
			inst.AnimState:ClearOverrideSymbol("tophat_fx_float")
			inst.AnimState:SetSymbolMultColour("tophat_fx_float", 1, 1, 1, 1)
			CancelTalk_Override(inst)
		end,
	},

    ---------------------------------------------------------------------------
    -- monkey

    State{
        name = "monkeychanger_pre",
        tags = { "busy", "pausepredict", "dismounting", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst, tomonkey)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.Physics:Stop()
            inst.components.inventory:Close(true) --true to keep activeitem over seamless player swap
            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            if inst.components.rider:IsRiding() then
                inst.sg.statemem.tomonkey = tomonkey
                inst.AnimState:PlayAnimation("fall_off")
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            else
                inst.sg.statemem.transforming = true
                inst.sg:GoToState(tomonkey and "changetomonkey" or "changefrommonkey")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.components.rider:ActualDismount()
                    inst.sg.statemem.transforming = true
                    inst.sg:GoToState(inst.sg.statemem.tomonkey and "changetomonkey" or "changefrommonkey")
                end
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.transforming then
                inst.components.rider:ActualDismount()
                if not inst.components.health:IsDead() then
                    inst.components.inventory:Open()
                end
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:EnableMapControls(true)
                    inst.components.playercontroller:Enable(true)
                end
            end
        end,
    },

    State{
        name = "changetomonkey",
        tags = { "busy", "nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.components.inventory:Close(true) --true to keep activeitem over seamless player swap
            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.AnimState:AddOverrideBuild("player_monkey_change")
            inst.AnimState:PlayAnimation("cursed_pre")

            SpawnPrefab("monkey_cursed_pre_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:AddStateTag("noattack")
                    inst.components.health:SetInvincible(true)
                    inst:ChangeToMonkey()
                end
            end),
        },

        onexit = function(inst)
            assert(not inst.sg:HasStateTag("noattack"), "Left changetomonkey state.")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst:SetCameraDistance()
        end,
    },

    State{
        name = "changetomonkey_pst",
        tags = { "busy", "nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:AddOverrideBuild("player_monkey_change")
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cursed_pst")

            SpawnPrefab("monkey_cursed_pst_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {

            TimeEvent(15*FRAMES, function(inst)
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_MONKEY_CURSE_CHANGE"))
            end),

            TimeEvent(20*FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
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
        name = "changefrommonkey",
        tags = { "busy", "nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst:SetCameraDistance(14)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.components.inventory:Close(true) --true to keep activeitem over seamless player swap
            inst:PushEvent("ms_closepopups")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:EnableMapControls(false)
            end

            inst.AnimState:PlayAnimation("deform_pre")

            SpawnPrefab("monkey_deform_pre_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:AddStateTag("noattack")
                    inst.components.health:SetInvincible(true)
                    inst:ChangeFromMonkey()
                end
            end),
        },

        onexit = function(inst)
            assert(not inst.sg:HasStateTag("noattack"), "Left changetomonkey state.")
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:EnableMapControls(true)
                inst.components.playercontroller:Enable(true)
            end
            inst:SetCameraDistance()
        end,
    },

    State{
        name = "changefrommonkey_pst",
        tags = { "busy","nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.AnimState:ClearOverrideBuild("player_monkey_change")
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("deform_pst")

            SpawnPrefab("monkey_deform_pst_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                inst.components.talker:Say(GetString(inst, "ANNOUNCE_MONKEY_CURSE_CHANGEBACK"))
            end),

            TimeEvent(20*FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
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

    ----------------------------------------------------------------------------------------------------
    -- STAGE ACTING STATES

    State{
        name = "acting_idle",
        tags = { "idle", "forcedangle", "acting"},

        onenter = function(inst, pre)
            local function getidle()
                if math.random() < 0.5 then
                    return "acting_idle1"
                else
                    return "acting_idle2"
                end
            end

            if pre then
                inst.AnimState:PlayAnimation(pre, false)
                inst.AnimState:PushAnimation(getidle(),false)
            else
                inst.AnimState:PlayAnimation(getidle(),false)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("acting_idle")
            end),
        },
    },

    State{
        name = "acting_run_stop",
        tags = { "canrotate", "acting", "autopredict" },

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
                    if inst.sg.statemem.goosegroggy then
                        DoGooseWalkFX(inst)
                    else
                        DoGooseStepFX(inst)
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("acting_idle")
                end
            end),
        },
    },

    State{
        name = "acting_talk",
        tags = { "talking", "acting" },

        onenter = function(inst, noanim)
            local function gettalk()
                if math.random() < 0.5 then
                    return "acting_1"
                else
                    return "acting_2"
                end
            end

            if not noanim then
                inst.AnimState:PlayAnimation(gettalk(),false)
            end
            DoTalkSound(inst)
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst)
            inst.sg.statemem.talkdone = true
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.talkdone then
                    inst.sg:GoToState("acting_idle")
                else
                    local function gettalk()
                        if math.random() < 0.5 then
                            return "acting_1"
                        else
                            return "acting_2"
                        end
                    end
                    inst.AnimState:PlayAnimation(gettalk())
                end
            end),
            EventHandler("donetalking", function(inst)
                inst.sg.statemem.talkdone = true
            end),
        },

        onexit = function(inst)
            StopTalkSound(inst)
        end,
    },

    State{
        name = "acting_action",
        tags = { "talking", "acting" },

        onenter = function(inst, data)
            local loop = false
            if data.animtype == "loop" then
                loop = true
                inst.sg.statemem.loop = true
            end
            if data.animtype == "hold" then
                inst.sg.statemem.hold = true
            end

            if type(data.anim) == "table" then
                for i,animation in ipairs(data.anim)do
                    inst.sg.statemem.queue = true
                    if i == 1 then
                        if #data.anim == 1 and loop then
                            inst.AnimState:PlayAnimation(animation, true)
                        else
                            inst.AnimState:PlayAnimation(animation, false)
                        end
                    elseif i == #data.anim then
                        inst.AnimState:PushAnimation(animation, loop)
                    else 
                        inst.AnimState:PushAnimation(animation, false)
                    end
                end
            else
                inst.AnimState:PlayAnimation(data.anim, loop)
            end
            if data.line then
                DoTalkSound(inst)
            end
        end,

        events =
        {
            EventHandler("donetalking", function(inst)
                StopTalkSound(inst)
                if not inst.sg.statemem.loop and not inst.sg.statemem.hold then
                    inst.sg:GoToState("acting_idle")
                end
            end),
            EventHandler("animover", function(inst)
                if not inst.sg.statemem.loop and not inst.sg.statemem.hold then
                    if not inst.sg.statemem.queue then
                        inst.sg:GoToState("acting_idle")
                    end
                end
            end),  
            EventHandler("animqueueover", function(inst)
                if not inst.sg.statemem.loop and not inst.sg.statemem.hold then
                    if inst.sg.statemem.queue then
                        inst.sg:GoToState("acting_idle")
                    end
                end
            end),
        },

        onexit = function(inst)
            StopTalkSound(inst)
        end,
    },

    State{
        name = "acting_bow",
        tags = { "nopredict", "forcedangle", "acting"},

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("bow_pre",false)
            inst.AnimState:PushAnimation("bow_pst",false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("acting_idle")
            end),
        },
    },

    State{
        name = "acting_curtsy",
        tags = { "nopredict", "forcedangle", "acting"},

        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("idle_wathgrithr",false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("acting_idle")
            end),
        },
    },

    -- END STAGE ACTING

	State{
		name = "scythe",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("scythe_pre")
			inst.AnimState:PushAnimation("scythe_loop", false)
		end,

		timeline =
		{
			FrameEvent(14, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
			FrameEvent(15, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
				inst:PerformBufferedAction()
			end),
			FrameEvent(18, function(inst)
				inst.sg:RemoveStateTag("busy")
			end),
			FrameEvent(25, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

		events =
		{
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	--------------------------------------------------------------------------
	--Sitting states

	State{
		name = "start_sitting",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			local buffaction = inst:GetBufferedAction()
			local chair = buffaction ~= nil and buffaction.target or nil
			local nofaced
			if chair ~= nil and chair:IsValid() then
				inst.Transform:SetRotation(chair.Transform:GetRotation())
				if inst:PerformBufferedAction() and
					chair.components.sittable ~= nil and
					chair.components.sittable:IsOccupiedBy(inst) then
					--
					inst:AddTag("sitting_on_chair")
					if chair:HasTag("limited_chair") then
						inst:AddTag("limited_sitting")
						nofaced = true
					end
					inst.sg.statemem.chair = chair
				end
			else
				inst:ClearBufferedAction()
			end
			if nofaced then
				inst.Transform:SetPredictedNoFaced()
				inst.AnimState:PlayAnimation("sit_pre_nofaced")
			else
				inst.AnimState:PlayAnimation("sit_pre")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.sitting = true
					inst.sg:GoToState("sit_jumpon", inst.sg.statemem.chair)
				end
			end),
		},

		onexit = function(inst)
			inst.Transform:ClearPredictedFacingModel()
			if not inst.sg.statemem.sitting then
				inst:RemoveTag("sitting_on_chair")
				inst:RemoveTag("limited_sitting")
				local chair = inst.sg.statemem.chair
				if chair ~= nil and
					chair:IsValid() and
					chair.components.sittable ~= nil and
					chair.components.sittable:IsOccupiedBy(inst) then
					--
					chair.components.sittable:SetOccupier(nil)
				end
			end
		end,
	},

	State{
		name = "sit_jumpon",
		tags = { "busy", "nopredict" },

		onenter = function(inst, chair)
			if chair == nil or not chair:IsValid() or chair.components.sittable == nil then
				inst.sg:GoToState("idle")
				return
			elseif not chair.components.sittable:IsOccupied() then
				chair.components.sittable:SetOccupier(inst)
			elseif not chair.components.sittable:IsOccupiedBy(inst) then
				inst.sg:GoToState("idle")
				return
			end
			inst.components.locomotor:Stop()
			inst:AddTag("sitting_on_chair")
			if chair:HasTag("limited_chair") then
				inst:AddTag("limited_sitting")
				inst.Transform:SetNoFaced()
				inst.AnimState:SetBankAndPlayAnimation("wilson_sit_nofaced", "sit_jump")
			else
				inst.AnimState:SetBankAndPlayAnimation("wilson_sit", "sit_jump")
			end
			inst.sg.statemem.chair = chair
			inst.sg.statemem.onremovechair = function(chair)
				inst.sg.statemem.chair = nil
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
			end
			inst.sg.statemem.onbecomeunsittable = function(chair)
				inst.sg.statemem.sitting = true
				inst.sg.statemem.jumpoff = true
				inst.sg:GoToState("sit_jumpoff", {
					chair = inst.sg.statemem.chair,
					isphysicstoggle = inst.sg.statemem.isphysicstoggle,
				})
			end
			inst:ListenForEvent("onremove", inst.sg.statemem.onremovechair, chair)
			inst:ListenForEvent("becomeunsittable", inst.sg.statemem.onbecomeunsittable, chair)
			local rot = chair.Transform:GetRotation()
			inst.Transform:SetRotation(rot)
			local x, y, z = inst.Transform:GetWorldPosition()
			local x1, y1, z1 = chair.Transform:GetWorldPosition()
			local dx = x1 - x
			local dz = z1 - z
			if dx ~= 0 or dz ~= 0 then
				local dist = math.sqrt(dx * dx + dz * dz)
				local speed = dist * 30 / inst.AnimState:GetCurrentAnimationNumFrames()
				local dir = math.atan2(-dz, dx) - rot * DEGREES
				inst.Physics:SetMotorVel(speed * math.cos(dir), 0, -speed * math.sin(dir))
			end
			ToggleOffPhysics(inst)
		end,

		timeline =
		{
			FrameEvent(11, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt", nil, 0.5) end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.sitting = true
					inst.sg:GoToState("sitting", {
						landed = true,
						chair = inst.sg.statemem.chair,
						onremovechair = inst.sg.statemem.onremovechair,
						onbecomeunsittable = inst.sg.statemem.onbecomeunsittable,
						isphysicstoggle = inst.sg.statemem.isphysicstoggle,
					})
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:Stop()
			if not inst.sg.statemem.sitting or inst.sg.statemem.jumpoff then
				inst:RemoveTag("sitting_on_chair")
				inst:RemoveTag("limited_sitting")
				inst.Transform:SetFourFaced()
			end
			if not inst.sg.statemem.sitting then
				if not inst.sg.statemem.stop then
					inst.AnimState:SetBank("wilson")
				end
				if inst.sg.statemem.isphysicstoggle then
					ToggleOnPhysics(inst)
				end
				local chair = inst.sg.statemem.chair
				if chair ~= nil and chair:IsValid() then
					inst:RemoveEventCallback("onremove", inst.sg.statemem.onremovechair, chair)
					inst:RemoveEventCallback("becomeunsittable", inst.sg.statemem.onbecomeunsittable, chair)
					if chair.components.sittable ~= nil and chair.components.sittable:IsOccupiedBy(inst) then
						chair.components.sittable:SetOccupier(nil)
					end
				end
			end
		end,
	},

	State{
		name = "sitting",
		tags = { "overridelocomote", "canrotate" },

		onenter = function(inst, data)
			local chair, landed
			if EntityScript.is_instance(data) then
				chair = data
			elseif data ~= nil then
				landed = data.landed
				chair = data.chair
				inst.sg.statemem.onremovechair = data.onremovechair
				inst.sg.statemem.onbecomeunsittable = data.onbecomeunsittable
				inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
			end
			if chair == nil or not chair:IsValid() or chair.components.sittable == nil then
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
				return
			elseif not chair.components.sittable:IsOccupied() then
				chair.components.sittable:SetOccupier(inst)
			elseif not chair.components.sittable:IsOccupiedBy(inst) then
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
				return
			end
			if inst.sg.statemem.onremovechair == nil then
				inst.sg.statemem.onremovechair = function(chair)
					inst.sg.statemem.chair = nil
					inst.sg.statemem.stop = true
					inst.sg:GoToState("stop_sitting_pst")
				end
				inst:ListenForEvent("onremove", inst.sg.statemem.onremovechair, chair)
			end
			if inst.sg.statemem.onbecomeunsittable == nil then
				inst.sg.statemem.onbecomeunsittable = function(chair)
					inst.sg.statemem.sitting = true
					inst.sg.statemem.jumpoff = true
					inst.sg:GoToState("sit_jumpoff", {
						chair = inst.sg.statemem.chair,
						isphysicstoggle = inst.sg.statemem.isphysicstoggle,
					})
				end
				inst:ListenForEvent("becomeunsittable", inst.sg.statemem.onbecomeunsittable, chair)
			end
			if not inst.sg.statemem.isphysicstoggle then
				ToggleOffPhysics(inst)
			end
			inst.components.locomotor:StopMoving()
			inst.sg.statemem.chair = chair
			local bank = "wilson_sit"
			inst:AddTag("sitting_on_chair")
			if chair:HasTag("limited_chair") then
				inst:AddTag("limited_sitting")
				inst.Transform:SetNoFaced()
				inst.sg.statemem.noemotes = true
				bank = "wilson_sit_nofaced"
			end
			if landed then
				inst.AnimState:SetBankAndPlayAnimation(bank, "sit_loop_pre")
				inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop")
			else
				inst.AnimState:SetBankAndPlayAnimation(bank, "sit"..tostring(math.random(2)).."_loop", true)
			end
			inst.Physics:Teleport(chair.Transform:GetWorldPosition())

			inst.sg.statemem.interrupt_emote = function(inst)
				if inst.sg.statemem.emotefxtask ~= nil then
					inst.sg.statemem.emotefxtask:Cancel()
					inst.sg.statemem.emotefxtask = nil
				end
				if inst.sg.statemem.emotesoundtask ~= nil then
					inst.sg.statemem.emotesoundtask:Cancel()
					inst.sg.statemem.emotesoundtask = nil
				end
			end
		end,

		events =
		{
			EventHandler("ontalk", function(inst)
				inst.sg.statemem.interrupt_emote(inst)
				if inst.sg.statemem.sittalktask ~= nil then
					inst.sg.statemem.sittalktask:Cancel()
					inst.sg.statemem.sittalktask = nil
				end
				local duration = inst.sg.statemem.talktask ~= nil and GetTaskRemaining(inst.sg.statemem.talktask) or 1.5 + math.random() * .5
				if inst:HasTag("mime") then
					inst.AnimState:PlayAnimation("sit_mime1")
					for i = 2, math.floor(duration / inst.AnimState:GetCurrentAnimationLength() + 0.5) do
						inst.AnimState:PushAnimation("sit_mime1")
					end
					inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop")
				else
					inst.AnimState:PlayAnimation("sit_dial", true)
					inst.sg.statemem.sittalktask = inst:DoTaskInTime(duration, function(inst)
						inst.sg.statemem.sittalktask = nil
						if inst.AnimState:IsCurrentAnimation("sit_dial") then
							inst.AnimState:PlayAnimation("sit"..tostring(math.random(2)).."_loop", true)
						end
					end)
				end
				return OnTalk_Override(inst)
			end),
			EventHandler("donetalking", function(inst)
				if inst.sg.statemem.sittalktask ~= nil then
					inst.sg.statemem.sittalktask:Cancel()
					inst.sg.statemem.sittalktask = nil
					if inst.AnimState:IsCurrentAnimation("sit_dial") then
						inst.AnimState:PlayAnimation("sit"..tostring(math.random(2)).."_loop", true)
					end
				end
				return OnDoneTalking_Override(inst)
			end),
			EventHandler("equip", function(inst, data)
				inst.sg.statemem.interrupt_emote(inst)
				inst.AnimState:PlayAnimation(data.eslot == EQUIPSLOTS.HANDS and "sit_item_out" or "sit_item_hat")
				inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop")
			end),
			EventHandler("unequip", function(inst, data)
				inst.sg.statemem.interrupt_emote(inst)
				inst.AnimState:PlayAnimation(data.eslot == EQUIPSLOTS.HANDS and "sit_item_in" or "sit_item_hat")
				inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop")
			end),
			EventHandler("performaction", function(inst, data)
				if data ~= nil and data.action ~= nil and data.action.action == ACTIONS.DROP then
					inst.sg.statemem.interrupt_emote(inst)
					inst.AnimState:PlayAnimation("sit_item_hat")
					inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop")
				end
			end),
			EventHandler("locomote", function(inst, data)
				if data ~= nil and data.remoteoverridelocomote or inst.components.locomotor:WantsToMoveForward() then
					inst.sg.statemem.sitting = true
					inst.sg.statemem.stop = true
					inst.sg:GoToState("stop_sitting", {
						chair = inst.sg.statemem.chair,
						isphysicstoggle = inst.sg.statemem.isphysicstoggle,
					})
				end
				return true
			end),
			EventHandler("emote", function(inst, data)
				if data.sitting and
					not inst.sg.statemem.noemotes and
					(	not data.requires_validation or
						TheInventory:CheckClientOwnership(inst.userid, data.item_type)
					)
				then
					inst.sg.statemem.interrupt_emote(inst)

					--Not supported
					assert(data.tags == nil)

					local anim = data.anim
					local animtype = type(anim)
					if data.randomanim and animtype == "table" then
						anim = anim[math.random(#anim)]
						animtype = type(anim)
					end
					if animtype == "table" and #anim <= 1 then
						anim = anim[1]
						animtype = type(anim)
					end

					if animtype == "string" then
						inst.AnimState:PlayAnimation(anim, data.loop)
						if not data.loop then
							inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop", true)
						end
					elseif animtype == "table" then
						inst.AnimState:PlayAnimation(anim[1])
						for i = 2, #anim do
							inst.AnimState:PushAnimation(anim[i])
						end
						if not data.loop then
							inst.AnimState:PushAnimation("sit"..tostring(math.random(2)).."_loop", true)
						end
					end

					if data.fx then --fx might be a boolean, so don't do ~= nil
						if data.fxdelay == nil or data.fxdelay == 0 then
							DoEmoteFX(inst, data.fx)
						else
							inst.sg.statemem.emotefxtask = inst:DoTaskInTime(data.fxdelay, DoEmoteFX, data.fx)
						end
					elseif data.fx ~= false then
						DoEmoteFX(inst, "emote_fx")
					end

					if data.sound then --sound might be a boolean, so don't do ~= nil
						if (data.sounddelay or 0) <= 0 then
							inst.SoundEmitter:PlaySound(data.sound)
						else
							inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoForcedEmoteSound, data.sound)
						end
					elseif data.sound ~= false then
						if (data.sounddelay or 0) <= 0 then
							DoEmoteSound(inst, data.soundoverride, data.soundlooped)
						else
							inst.sg.statemem.emotesoundtask = inst:DoTaskInTime(data.sounddelay, DoEmoteSound, data.soundoverride, data.soundlooped)
						end
					end
				end
				return true
			end),
		},

		onexit = function(inst)
			local chair = inst.sg.statemem.chair
			if chair ~= nil then
				inst:RemoveEventCallback("onremove", inst.sg.statemem.onremovechair, chair)
				inst:RemoveEventCallback("becomeunsittable", inst.sg.statemem.onbecomeunsittable, chair)
			end
			if not inst.sg.statemem.sitting or inst.sg.statemem.jumpoff then
				inst:RemoveTag("sitting_on_chair")
				inst:RemoveTag("limited_sitting")
				inst.Transform:SetFourFaced()
			end
			if not inst.sg.statemem.sitting then
				if not inst.sg.statemem.stop then
					inst.AnimState:SetBank("wilson")
				end
				if inst.sg.statemem.isphysicstoggle then
					ToggleOnPhysics(inst)
				end
				if chair ~= nil and chair:IsValid() then
					if chair.components.sittable ~= nil and chair.components.sittable:IsOccupiedBy(inst) then
						chair.components.sittable:SetOccupier(nil)
					end
					local radius = inst:GetPhysicsRadius(0) + chair:GetPhysicsRadius(0)
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
			end
			if inst.sg.statemem.sittalktask ~= nil then
				inst.sg.statemem.sittalktask:Cancel()
			end
			CancelTalk_Override(inst)
			if inst.sg.statemem.interrupt_emote ~= nil then
				inst.sg.statemem.interrupt_emote(inst)
			end
		end,
	},

	State{
		name = "stop_sitting",
		tags = { "busy" },

		onenter = function(inst, data)
			local chair
			if EntityScript.is_instance(data) then
				chair = data
			elseif data ~= nil then
				chair = data.chair
				inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
			end
			if chair == nil or not chair:IsValid() or chair.components.sittable == nil then
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
				return
			elseif not chair.components.sittable:IsOccupied() then
				chair.components.sittable:SetOccupier(inst)
			elseif not chair.components.sittable:IsOccupiedBy(inst) then
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
				return
			end
			if not inst.sg.statemem.isphysicstoggle then
				ToggleOffPhysics(inst)
			end
			local buffaction = inst:GetBufferedAction()
			if buffaction == nil or buffaction.action == ACTIONS.WALKTO then
				inst.components.locomotor:Stop()
				inst.components.locomotor:Clear()
				inst:ClearBufferedAction()
			end
			inst.sg.statemem.chair = chair
			inst.sg.statemem.rot = inst.Transform:GetRotation()
			inst.Transform:SetRotation(chair.Transform:GetRotation())
			inst:AddTag("sitting_on_chair")
			if chair:HasTag("limited_chair") then
				inst:AddTag("limited_sitting")
				inst.Transform:SetNoFaced()
				inst.AnimState:SetBankAndPlayAnimation("wilson_sit_nofaced", "sit_off")
			else
				inst.AnimState:SetBankAndPlayAnimation("wilson_sit", "sit_off")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.Transform:SetRotation(inst.sg.statemem.rot)
					inst.sg.statemem.sitting = true
					--inst.sg.statemem.jumpoff = true
					inst.sg:GoToState("sit_jumpoff", {
						chair = inst.sg.statemem.chair,
						isphysicstoggle = inst.sg.statemem.isphysicstoggle,
					})
				end
			end),
		},

		onexit = function(inst)
			inst:RemoveTag("sitting_on_chair")
			inst:RemoveTag("limited_sitting")
			inst.Transform:SetFourFaced()
			if not inst.sg.statemem.sitting then
				if not inst.sg.statemem.stop then
					inst.AnimState:SetBank("wilson")
				end
				if inst.sg.statemem.isphysicstoggle then
					ToggleOnPhysics(inst)
				end
				local chair = inst.sg.statemem.chair
				if chair ~= nil and chair:IsValid() then
					if chair.components.sittable ~= nil and chair.components.sittable:IsOccupiedBy(inst) then
						chair.components.sittable:SetOccupier(nil)
					end
					local radius = inst:GetPhysicsRadius(0) + chair:GetPhysicsRadius(0)
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
			end
		end,
	},

	State{
		name = "sit_jumpoff",
		tags = { "busy", "nopredict" },

		onenter = function(inst, data)
			local chair
			if EntityScript.is_instance(data) then
				chair = data
			elseif data ~= nil then
				chair = data.chair
				inst.sg.statemem.isphysicstoggle = data.isphysicstoggle
			end
			if chair == nil or not chair:IsValid() then
				inst.sg.statemem.stop = true
				inst.sg:GoToState("stop_sitting_pst")
				return
			end
			if not inst.sg.statemem.isphysicstoggle then
				ToggleOffPhysics(inst)
			end
			inst.sg.statemem.chair = chair
			inst.components.locomotor:StopMoving()
			inst.AnimState:SetBankAndPlayAnimation("wilson", "sit_jump_off")
			local radius = inst:GetPhysicsRadius(0) + chair:GetPhysicsRadius(0)
			if radius > 0 then
				inst.Physics:SetMotorVel(radius * 30 / inst.AnimState:GetCurrentAnimationNumFrames(), 0, 0)
				if inst:IsOnPassablePoint() then
					inst.sg.statemem.safepos = inst:GetPosition()
				end
			end
		end,

		onupdate = function(inst)
			local safepos = inst.sg.statemem.safepos
			if safepos ~= nil and inst:IsOnPassablePoint() then
				safepos.x, safepos.y, safepos.z = inst.Transform:GetWorldPosition()
			end
		end,

		timeline =
		{
			FrameEvent(11, PlayFootstep),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					if inst.sg.statemem.safepos ~= nil and not inst:IsOnPassablePoint() then
						inst.Physics:Teleport(inst.sg.statemem.safepos.x, 0, inst.sg.statemem.safepos.z)
					end
					inst.sg.statemem.stop = true
					inst.sg:GoToState("stop_sitting_pst", true)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.stop then
				inst.AnimState:SetBank("wilson")
			end
			inst.Physics:Stop()
			if inst.sg.statemem.isphysicstoggle then
				ToggleOnPhysics(inst)
			end
			local chair = inst.sg.statemem.chair
			if chair ~= nil and
				chair:IsValid() and
				chair.components.sittable ~= nil and
				chair.components.sittable:IsOccupiedBy(inst) then
				--
				chair.components.sittable:SetOccupier(nil)
			end
		end,
	},

	State{
		name = "stop_sitting_pst",
		tags = { "idle", "overridelocomote" },

		onenter = function(inst, skipsound)
			inst.components.locomotor:StopMoving()
			inst.AnimState:SetBankAndPlayAnimation("wilson", "sit_off_pst")
			if not skipsound then
				PlayFootstep(inst)
			end
		end,

		timeline =
		{
			FrameEvent(3, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},

		events =
		{
			EventHandler("locomote", function(inst)
				return true
			end),
		},
	},

	--------------------------------------------------------------------------
	--Slipping states

	State{
		name = "slip",
		tags = { "busy", "nopredict", "nomorph", "jumping", "overridelocomote" },

		onenter = function(inst)
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			if inst.components.slipperyfeet then
				inst.components.slipperyfeet:SetCurrent(0)
			end

			inst.AnimState:PlayAnimation("slip_pre")
			inst.AnimState:PushAnimation("slip_loop", false)
			inst.SoundEmitter:PlaySound("dontstarve/movement/iceslab_slipping")

			inst.sg.statemem.speed = inst.components.locomotor:GetRunSpeed()
			inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.6, 0, 0)

			inst.player_classified.busyremoteoverridelocomote:set(true)
			inst.sg.statemem.trackcontrol = true
		end,

		onupdate = function(inst)
			if inst.sg.statemem.trackcontrol then
				if inst.HUD then
					local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
					if math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)) >= deadzone or
						math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)) >= deadzone
					then
						if inst.sg.statemem.checkfall then
							inst.sg.statemem.slipping = true
							inst.sg:GoToState("slip_fall", inst.sg.statemem.speed * 0.25)
							return
						end
						inst.sg.statemem.controltick = GetTick()
					end
				end

				if inst.sg.statemem.trystoptracking and GetTick() - inst.sg.statemem.controltick > 10 then
					inst.sg.statemem.trackcontrol = false
				end
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst) inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.3, 0, 0) end),
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/iceslab_slipping") end),
			FrameEvent(12, function(inst) inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.25, 0, 0) end),
			FrameEvent(18, function(inst) inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.2, 0, 0) end),

			FrameEvent(18, function(inst)
				inst.sg.statemem.checkfall = true
			end),
			FrameEvent(20, function(inst)
				if inst.sg.statemem.controltick then
					inst.sg.statemem.trystoptracking = true
				else
					inst.sg.statemem.trackcontrol = false
				end
				inst.SoundEmitter:PlaySound("dontstarve/movement/iceslab_slipping", nil, 0.5)
			end),
		},

		events =
		{
			EventHandler("locomote", function(inst, data)
				if inst.sg.statemem.trackcontrol and data and data.remoteoverridelocomote or inst.components.locomotor:WantsToMoveForward() then
					if inst.sg.statemem.checkfall then
						inst.sg.statemem.slipping = true
						inst.sg:GoToState("slip_fall", inst.sg.statemem.speed * 0.25)
						return
					end
					inst.sg.statemem.controltick = GetTick()
				end
				return true
			end),
			EventHandler("animqueueover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg.statemem.slipping = true
					inst.sg:GoToState("slip_pst", inst.sg.statemem.speed)
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.slipping then
				inst.Physics:SetMotorVel(0, 0, 0)
				inst.Physics:Stop()
			end
			inst.player_classified.busyremoteoverridelocomote:set(false)
		end,
	},

	State{
		name = "slip_pst",
		tags = { "busy", "nopredict", "nomorph", "jumping" },

		onenter = function(inst, speed)
			inst.AnimState:PlayAnimation("slip_pst")
			inst.sg.statemem.speed = speed or inst.components.locomotor:GetRunSpeed()
			inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.15, 0, 0)
		end,

		timeline =
		{
			FrameEvent(2, function(inst) inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.1, 0, 0) end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			inst.Physics:SetMotorVel(0, 0, 0)
			inst.Physics:Stop()
		end,
	},

	State{
		name = "slip_fall",
		tags = { "busy", "nopredict", "nomorph", "jumping" },

		onenter = function(inst, speed)
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			if inst.components.slipperyfeet then
				inst.components.slipperyfeet:SetCurrent(0)
			end

			inst.AnimState:PlayAnimation("slip_fall_pre")
			inst.SoundEmitter:PlaySound("dontstarve/movement/slip_fall_whoop")

			if speed then
				inst.sg.statemem.speed = speed
				inst.Physics:SetMotorVel(speed * 0.8, 0, 0)
			end
		end,

		timeline =
		{
			FrameEvent(10, function(inst) inst.SoundEmitter:PlaySound("dontstarve/movement/slip_fall_thud") end),
			FrameEvent(11, function(inst)
				DoHurtSound(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.64, 0, 0)
				end
			end),
			--held 2 frames on purpose =P
			FrameEvent(13, function(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.32, 0, 0)
				end
			end),
			FrameEvent(14, function(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.16, 0, 0)
				end
			end),
			FrameEvent(15, function(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.08, 0, 0)
				end
			end),
			FrameEvent(16, function(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(inst.sg.statemem.speed * 0.04, 0, 0)
				end
			end),
			FrameEvent(17, function(inst)
				if inst.sg.statemem.speed then
					inst.Physics:SetMotorVel(0, 0, 0)
					inst.Physics:Stop()
				end
			end),
		},

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("slip_fall_loop")
				end
			end),
		},

		onexit = function(inst)
			if inst.sg.statemem.speed then
				inst.Physics:SetMotorVel(0, 0, 0)
				inst.Physics:Stop()
			end
		end,
	},

	State{
		name = "slip_fall_loop",
		tags = { "busy", "nomorph", "overridelocomote" },

		onenter = function(inst)
			ForceStopHeavyLifting(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()

			if inst.components.slipperyfeet then
				inst.components.slipperyfeet:SetCurrent(0)
			end

			inst.AnimState:PlayAnimation("slip_fall_idle")

			inst.player_classified.busyremoteoverridelocomote:set(true)
		end,

		onupdate = function(inst)
			if inst.HUD then
				local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
				if math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)) >= deadzone or
					math.abs(TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)) >= deadzone
				then
					inst.sg:GoToState("slip_fall_pst")
				end
			end
		end,

		events =
		{
			EventHandler("locomote", function(inst, data)
				if data ~= nil and data.remoteoverridelocomote or inst.components.locomotor:WantsToMoveForward() then
					inst.sg:GoToState("slip_fall_pst")
				end
				return true
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("slip_fall_pst")
				end
			end),
		},

		onexit = function(inst)
			inst.player_classified.busyremoteoverridelocomote:set(false)
		end,
	},

	State{
		name = "slip_fall_pst",
		tags = { "busy", "nomorph" },

		onenter = function(inst)
			inst.AnimState:PlayAnimation("slip_fall_pst")
		end,

		timeline =
		{
			FrameEvent(6, function(inst) PlayFootstep(inst, 0.6) end),
			FrameEvent(12, function(inst)
				inst.sg:GoToState("idle", true)
			end),
		},
	},

	State{
		name = "start_pocket_rummage",
		tags = { "doing", "busy", "nodangle", "keep_pocket_rummage" },

		onenter = function(inst, resume_item)
			inst.components.locomotor:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
			inst.AnimState:PlayAnimation("build_pre")
			inst.AnimState:PushAnimation("build_loop")

			if resume_item then
				if resume_item ~= inst.sg.mem.pocket_rummage_item then
					ClosePocketRummageMem(inst)
				end
				inst.sg.statemem.item = resume_item
				inst.sg:RemoveStateTag("busy")
			else
				ClosePocketRummageMem(inst)
				inst.sg.statemem.action = inst:GetBufferedAction()
				inst.sg.statemem.item = inst.sg.statemem.action and inst.sg.statemem.action.invobject or nil
				inst.components.inventory:ReturnActiveActionItem(inst.sg.statemem.item)
			end
		end,

		onupdate = function(inst)
			local item = inst.sg.mem.pocket_rummage_item
			if item and
				not (item.components.container and
					item.components.container:IsOpenedBy(inst) and
					item.components.inventoryitem and
					item.components.inventoryitem:GetGrandOwner() == inst)
			then
				SetPocketRummageMem(inst, nil)
				inst.sg:GoToState("stop_pocket_rummage", true)
			end
		end,

		timeline =
		{
			FrameEvent(6, function(inst)
				inst.sg:RemoveStateTag("busy")
				inst:PerformBufferedAction()

				local item = inst.sg.statemem.item
				if item and
					item.components.container and
					item.components.container:IsOpenedBy(inst) and
					item.components.inventoryitem and
					item.components.inventoryitem:GetGrandOwner() == inst
				then
					SetPocketRummageMem(inst, item)
				else
					SetPocketRummageMem(inst, nil)
					inst.sg:GoToState("stop_pocket_rummage", true)
				end
			end),
		},

		events =
		{
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
			EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
		},

		onexit = function(inst)
			inst.SoundEmitter:KillSound("make")
			CancelTalk_Override(inst)

			CheckPocketRummageMem(inst)

			if inst.bufferedaction == inst.sg.statemem.action and
				not (inst.components.playercontroller and inst.components.playercontroller.lastheldaction == inst.bufferedaction)
			then
				inst:ClearBufferedAction()
			end
		end,
	},

	State{
		name = "stop_pocket_rummage",
		tags = { "doing", "nodangle" },

		onenter = function(inst, ignoreaction)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("build_pst")

			ClosePocketRummageMem(inst)

			if not ignoreaction then
				--V2C: Clear, don't perform. Make sure we only do closing here.
				--     The RUMMAGE action might reopen if it was closed already.
				inst:ClearBufferedAction()
			end
		end,

		events =
		{
			EventHandler("ontalk", OnTalk_Override),
			EventHandler("donetalking", OnDoneTalking_Override),
			EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = CancelTalk_Override,
	},

	State{
		name = "remote_teleport_pre",
		tags = { "busy" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:AddOverrideBuild("winona_teleport")
			inst.AnimState:PlayAnimation("remote_teleport_pre")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
					local success, reason
					local item = inst.bufferedaction and inst.bufferedaction.invobject or nil
					if item and item.components.remoteteleporter and
						item == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					then
						success, reason = item.components.remoteteleporter:CanActivate(inst)
						if success then
							inst.sg.statemem.teleporting = true
							inst.sg:GoToState("remote_teleport_out")
							return
						end
						inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = reason })
					end
					inst:ClearBufferedAction()
					inst.sg:GoToState("idle")
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.teleporting then
				inst.AnimState:ClearOverrideBuild("winona_teleport")
			end
		end,
	},

	State{
		name = "remote_teleport_out",
		tags = { "busy", "pausepredict", "nomorph" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("remote_teleport_out")
			inst.AnimState:SetSymbolLightOverride("beam01", 1)
			inst.AnimState:SetSymbolLightOverride("beam02", 1)
			inst.AnimState:SetSymbolLightOverride("flash01", 1)
			inst.AnimState:SetSymbolLightOverride("glow01", 1)
			inst.AnimState:SetSymbolLightOverride("lightning_parts", 1)
			inst.AnimState:SetSymbolBloom("beam01")
			inst.AnimState:SetSymbolBloom("beam02")
			inst.AnimState:SetSymbolBloom("flash01")
			inst.AnimState:SetSymbolBloom("glow01")
			inst.AnimState:SetSymbolBloom("lightning_parts")
			inst.SoundEmitter:PlaySound("meta4/winona_teleumbrella/beep")
			inst.SoundEmitter:PlaySound("meta4/winona_teleumbrella/telaumbrella_out")
			inst.components.inventory:Hide()
			inst:PushEvent("ms_closepopups")
			if inst.components.playercontroller then
				inst.components.playercontroller:RemotePausePrediction()
				inst.components.playercontroller:Enable(false)
				inst.components.playercontroller:EnableMapControls(false)
			end
			local item = inst.bufferedaction and inst.bufferedaction.invobject or nil
			if item and item.components.remoteteleporter then
				item.components.remoteteleporter:OnStartTeleport(inst)
				inst.sg.statemem.item = item
			end
		end,

		timeline =
		{
			FrameEvent(15, function(inst)
				inst.DynamicShadow:Enable(false)
				inst.components.health:SetInvincible(true)
				inst.sg:AddStateTag("noattack")
				inst.sg:AddStateTag("invisible")
				StopTalkSound(inst, true)
				if inst.components.talker then
					inst.components.talker:ShutUp()
					inst.components.talker:IgnoreAll("remote_teleporting")
				end
                local item = inst.sg.statemem.item
                if item and item:IsValid() then
                    local remoteteleporter = item.components.remoteteleporter
                    if remoteteleporter then
                        local nearbyitems = remoteteleporter:Teleport_GetNearbyItems(inst)
                        if nearbyitems then
                            inst.sg.statemem.nearbyitems = nearbyitems
                            for _, nearbyitem in ipairs(nearbyitems) do
                                nearbyitem:RemoveFromScene()
                            end
                        end
                    end
                end
			end),
		},

		events =
		{
			EventHandler("actionfailed", function(inst, data)
				inst.sg.statemem.teleporting = true
				inst.sg:GoToState("remote_teleport_in", {
                    nearbyitems = inst.sg.statemem.nearbyitems,
					item = inst.sg.statemem.item,
					faildata = data,
				})
			end),
			EventHandler("animover", function(inst)
				if inst.AnimState:AnimDone() then
                    local item = inst.sg.statemem.item
                    if inst.sg.statemem.nearbyitems then
                        if item and item:IsValid() then
                            local remoteteleporter = item.components.remoteteleporter
                            if remoteteleporter then
                                remoteteleporter:SetNearbyItems(inst.sg.statemem.nearbyitems)
                            end
                        end
                    end
					if inst:PerformBufferedAction() then
                        if item and item:IsValid() then
                            local remoteteleporter = item.components.remoteteleporter
                            if remoteteleporter then
                                remoteteleporter:SetNearbyItems(nil)
                            end
                        end
						inst.sg.statemem.teleporting = true
						inst.sg:GoToState("remote_teleport_in", {
                            nearbyitems = inst.sg.statemem.nearbyitems,
                            item = item,
                        })
					end
				end
			end),
		},

		onexit = function(inst)
			if not inst.sg.statemem.teleporting then
				inst.DynamicShadow:Enable(true)
				inst.components.health:SetInvincible(false)
				inst.components.inventory:Show()
				if inst.components.playercontroller then
					inst.components.playercontroller:Enable(true)
					inst.components.playercontroller:EnableMapControls(true)
				end
				if inst.components.talker then
					inst.components.talker:StopIgnoringAll("remote_teleporting")
				end
				inst.AnimState:SetSymbolLightOverride("beam01", 0)
				inst.AnimState:SetSymbolLightOverride("beam02", 0)
				inst.AnimState:SetSymbolLightOverride("flash01", 0)
				inst.AnimState:SetSymbolLightOverride("glow01", 0)
				inst.AnimState:SetSymbolLightOverride("lightning_parts", 0)
				inst.AnimState:ClearSymbolBloom("beam01")
				inst.AnimState:ClearSymbolBloom("beam02")
				inst.AnimState:ClearSymbolBloom("flash01")
				inst.AnimState:ClearSymbolBloom("glow01")
				inst.AnimState:ClearSymbolBloom("lightning_parts")
				inst.AnimState:ClearOverrideBuild("winona_teleport")
				local item = inst.sg.statemem.item
				if item and item:IsValid() and item.components.remoteteleporter then
					item.components.remoteteleporter:OnStopTeleport(inst, false)
				end
                if inst.sg.statemem.nearbyitems then
                    for _, nearbyitem in ipairs(inst.sg.statemem.nearbyitems) do
                        if nearbyitem:IsValid() then
                            nearbyitem:ReturnToScene()
                        end
                    end
                    inst.sg.statemem.nearbyitems = nil
                end
			end
		end,
	},

	State{
		name = "remote_teleport_in",
		tags = { "busy", "silentmorph", "nopredict", "noattack", "invisible" },

		onenter = function(inst, data)
			inst.components.locomotor:Stop()
			inst.AnimState:PlayAnimation("remote_teleport_in")
			inst.SoundEmitter:PlaySound("meta4/winona_teleumbrella/telaumbrella_in")
			inst.DynamicShadow:Enable(false)
			inst.components.health:SetInvincible(true)
			inst.components.inventory:Hide()
			inst:PushEvent("ms_closepopups")
			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(false)
				inst.components.playercontroller:EnableMapControls(false)
			end
			StopTalkSound(inst, true)
			if inst.components.talker then
				inst.components.talker:ShutUp()
				inst.components.talker:IgnoreAll("remote_teleporting")
			end
			if data then
                inst.sg.statemem.nearbyitems = data.nearbyitems
				inst.sg.statemem.item = data.item
				inst.sg.statemem.faildata = data.faildata
			end
		end,

		timeline =
		{
            FrameEvent(15, function(inst)
                if inst.sg.statemem.nearbyitems then
                    for _, item in ipairs(inst.sg.statemem.nearbyitems) do
                        if item:IsValid() then
                            item:ReturnToScene()
                        end
                    end
                    inst.sg.statemem.nearbyitems = nil
                end
            end),
			FrameEvent(18, function(inst)
				inst.DynamicShadow:Enable(true)
				inst.sg:RemoveStateTag("invisible")
				if inst.components.talker and inst.sg.statemem.faildata == nil then
					inst.components.talker:StopIgnoringAll("remote_teleporting")
				end
			end),
			FrameEvent(23, function(inst)
				inst.sg:RemoveStateTag("noattack")
				inst.components.health:SetInvincible(false)
			end),
			FrameEvent(25, function(inst)
				inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
				PlayFootstep(inst)
			end),
			FrameEvent(31, function(inst)
				if inst.sg.statemem.faildata then
					if inst.components.talker then
						inst.components.talker:StopIgnoringAll("remote_teleporting")
					end
					inst:PushEvent("actionfailed", inst.sg.statemem.faildata)
				end
				inst.sg:GoToState("idle", true)
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

		onexit = function(inst)
			inst.DynamicShadow:Enable(true)
			inst.components.health:SetInvincible(false)
			inst.components.inventory:Show()
			if inst.components.playercontroller then
				inst.components.playercontroller:Enable(true)
				inst.components.playercontroller:EnableMapControls(true)
			end
			if inst.components.talker then
				inst.components.talker:StopIgnoringAll("remote_teleporting")
			end
			inst.AnimState:SetSymbolLightOverride("beam01", 0)
			inst.AnimState:SetSymbolLightOverride("beam02", 0)
			inst.AnimState:SetSymbolLightOverride("flash01", 0)
			inst.AnimState:SetSymbolLightOverride("glow01", 0)
			inst.AnimState:SetSymbolLightOverride("lightning_parts", 0)
			inst.AnimState:ClearSymbolBloom("beam01")
			inst.AnimState:ClearSymbolBloom("beam02")
			inst.AnimState:ClearSymbolBloom("flash01")
			inst.AnimState:ClearSymbolBloom("glow01")
			inst.AnimState:ClearSymbolBloom("lightning_parts")
			inst.AnimState:ClearOverrideBuild("winona_teleport")
			local item = inst.sg.statemem.item
			if item and item:IsValid() and item.components.remoteteleporter then
				item.components.remoteteleporter:OnStopTeleport(inst, inst.sg.statemem.faildata == nil)
			end
            if inst.sg.statemem.nearbyitems then
                for _, item in ipairs(inst.sg.statemem.nearbyitems) do
                    if item:IsValid() then
                        item:ReturnToScene()
                    end
                end
                inst.sg.statemem.nearbyitems = nil
            end
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
    hop_loop =
    {
        TimeEvent(0, function(inst)
            inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/jump")
        end),
    },
}

local function landed_in_water_state(inst)
    return (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown() and "sink") or nil
end

local hop_anims =
{
    pre = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_pre" or "boat_jump_pre" end,
    loop = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_loop" or "boat_jump_loop" end,
    pst = function(inst) return (inst.replica.inventory ~= nil and inst.replica.inventory:IsHeavyLifting() and (inst.replica.rider == nil or not inst.replica.rider:IsRiding())) and "boat_jumpheavy_pst" or "boat_jump_pst" end,
}

CommonStates.AddRowStates(states, false)
CommonStates.AddHopStates(states, true, hop_anims, hop_timelines, "turnoftides/common/together/boat/jump_on", landed_in_water_state, {start_embarking_pre_frame = 4*FRAMES})

local GymStates = require("stategraphs/SGwilson_gymstates")
GymStates.AddGymStates(states, actionhandlers, events)

if TheNet:GetServerGameMode() == "quagmire" then
    event_server_data("quagmire", "stategraphs/SGwilson").AddQuagmireStates(states, DoTalkSound, StopTalkSound, ToggleOnPhysics, ToggleOffPhysics)
end

return StateGraph("wilson", states, events, "idle", actionhandlers)
