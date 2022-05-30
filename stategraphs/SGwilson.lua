require("stategraphs/commonstates")

local ATTACK_PROP_MUST_TAGS = { "_combat" }
local ATTACK_PROP_CANT_TAGS = { "flying", "shadow", "ghost", "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }

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

local function UpdateActionMeter(inst, starttime)
    inst.player_classified.actionmeter:set_local(math.min(255, math.floor((GetTime() - starttime) * 10 + 2.5)))
end

local function StartActionMeter(inst, duration)
    if inst.HUD ~= nil then
        inst.HUD:ShowRingMeter(inst:GetPosition(), duration)
    end
    inst.player_classified.actionmetertime:set(math.min(255, math.floor(duration * 10 + .5)))
    inst.player_classified.actionmeter:set(2)
    if inst.sg.mem.actionmetertask == nil then
        inst.sg.mem.actionmetertask = inst:DoPeriodicTask(.1, UpdateActionMeter, nil, GetTime())
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

        local mount = inst.components.rider:GetMount()
        inst.sg.statemem.ridingwoby = mount and mount:HasTag("woby")

    elseif inst.components.inventory:IsHeavyLifting() then
        inst.sg.statemem.heavy = true
		inst.sg.statemem.heavy_fast = inst.components.mightiness ~= nil and inst.components.mightiness:IsMighty()
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
    elseif inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
        inst.sg.statemem.sandstorm = true
    elseif inst:HasTag("groggy") then
        inst.sg.statemem.groggy = true
    elseif inst:IsCarefulWalking() then
        inst.sg.statemem.careful = true
    else
        inst.sg.statemem.normal = true
    end
end

local function GetRunStateAnim(inst)
    return ((inst.sg.statemem.heavy and inst.sg.statemem.heavy_fast) and "heavy_walk_fast")
        or (inst.sg.statemem.heavy and "heavy_walk")
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
        function(inst)
            return not inst.sg:HasStateTag("prenet")
                and (inst.sg:HasStateTag("netting") and
                    "bugnet" or
                    "bugnet_start")
                or nil
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
    ActionHandler(ACTIONS.LIGHT, "give"),
    ActionHandler(ACTIONS.UNLOCK, "give"),
    ActionHandler(ACTIONS.USEKLAUSSACKKEY,
        function(inst)
            return inst:HasTag("quagmire_fasthands") and "domediumaction" or "dolongaction"
        end),
    ActionHandler(ACTIONS.TURNOFF, "give"),
    ActionHandler(ACTIONS.TURNON, "give"),
    ActionHandler(ACTIONS.ADDFUEL, "doshortaction"),
    ActionHandler(ACTIONS.ADDWETFUEL, "doshortaction"),
    ActionHandler(ACTIONS.REPAIR, "dolongaction"),
    ActionHandler(ACTIONS.READ,
        function(inst, action)
            return	(action.invobject ~= nil and action.invobject.components.simplebook ~= nil) and "cookbook_open"
					or inst:HasTag("aspiring_bookworm") and "book_peruse"
					or "book"
        end),
    ActionHandler(ACTIONS.MAKEBALLOON, "makeballoon"),
    ActionHandler(ACTIONS.DEPLOY, "doshortaction"),
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
            local obj = action.target or action.invobject
            return action.target.components.activatable ~= nil
                and (   (action.target.components.activatable.standingaction and "dostandingaction") or
                        (action.target.components.activatable.quickaction and "doshortaction") or
                        "dolongaction"
                    )
                or nil
        end),
    ActionHandler(ACTIONS.OPEN_CRAFTING, "dostandingaction"),
    ActionHandler(ACTIONS.PICK,
        function(inst, action)
            return (inst.components.rider ~= nil and inst.components.rider:IsRiding() and "dolongaction")
                or (action.target ~= nil
                and action.target.components.pickable ~= nil
                and (   (action.target.components.pickable.jostlepick and "dojostleaction") or
                        (action.target.components.pickable.quickpick and "doshortaction") or
                        (inst:HasTag("fastpicker") and "doshortaction") or
                        (inst:HasTag("quagmire_fasthands") and "domediumaction") or
                        "dolongaction"  ))
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
            return (action.target ~= nil and action.target:HasTag("minigameitem") and "dosilentshortaction")
                or (inst.components.rider ~= nil and inst.components.rider:IsRiding()
                    and (action.target ~= nil and action.target:HasTag("heavy") and "dodismountaction"
                        or "domediumaction")
                    )
                or "doshortaction"
        end),
    ActionHandler(ACTIONS.CHECKTRAP,
        function(inst, action)
            return (inst.components.rider ~= nil and inst.components.rider:IsRiding() and "domediumaction")
                or "doshortaction"
        end),
    ActionHandler(ACTIONS.RUMMAGE, "doshortaction"),
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
    ActionHandler(ACTIONS.JUMPIN, "jumpin_pre"),
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
                    )
                or "castspell"
        end),
    ActionHandler(ACTIONS.CASTAOE,
        function(inst, action)
            return action.invobject ~= nil
                and (   (action.invobject:HasTag("aoeweapon_lunge") and "combat_lunge_start") or
                        (action.invobject:HasTag("aoeweapon_leap") and (action.invobject:HasTag("superjump") and "combat_superjump_start" or "combat_leap_start")) or
                        (action.invobject:HasTag("blowdart") and "blowdart_special") or
                        (action.invobject:HasTag("throw_line") and "throw_line") or
                        (action.invobject:HasTag("book") and "book") or
                        (action.invobject:HasTag("parryweapon") and "parry_pre")
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
            if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
                local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
                return (weapon == nil and "attack")
                    or (weapon:HasTag("blowdart") and "blowdart")
					or (weapon:HasTag("slingshot") and "slingshot_shoot")
                    or (weapon:HasTag("thrown") and "throw")
                    or (weapon:HasTag("propweapon") and "attack_prop_pre")
                    or (weapon:HasTag("multithruster") and "multithrust_pre")
                    or (weapon:HasTag("helmsplitter") and "helmsplitter_pre")
                    or "attack"
            end
        end),
    ActionHandler(ACTIONS.TOSS, "throw"),
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
    ActionHandler(ACTIONS.STOP_STEERING_BOAT, "stop_steering"),
    ActionHandler(ACTIONS.SET_HEADING, "steer_boat_turning"),
    ActionHandler(ACTIONS.ROW_FAIL, "row_fail"),
    ActionHandler(ACTIONS.ROW, "row"),
    ActionHandler(ACTIONS.ROW_CONTROLLER, "row"),
    ActionHandler(ACTIONS.EXTEND_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.RETRACT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.ABANDON_SHIP, "abandon_ship_pre"),
    ActionHandler(ACTIONS.MOUNT_PLANK, "mount_plank"),
    ActionHandler(ACTIONS.DISMOUNT_PLANK, "doshortaction"),
    ActionHandler(ACTIONS.CAST_NET, "cast_net"),
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
    ActionHandler(ACTIONS.REVIVE_CORPSE, "revivecorpse"),
    ActionHandler(ACTIONS.DISMANTLE, "dolongaction"),
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
    ActionHandler(ACTIONS.WAX, "dolongaction"),

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
    ActionHandler(ACTIONS.APPLYMODULE_FAIL, "applyupgrademodule_fail"),
    ActionHandler(ACTIONS.REMOVEMODULES, "removeupgrademodules"),
    ActionHandler(ACTIONS.REMOVEMODULES_FAIL, "removeupgrademodules_fail"),
    ActionHandler(ACTIONS.CHARGE_FROM, "doshortaction"),
}

local events =
{
    EventHandler("locomote", function(inst, data)
        if inst.sg:HasStateTag("busy") then
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
            inst.sg:GoToState("run_stop")
        elseif not is_moving and should_move then
            inst.sg:GoToState("run_start")
        elseif data.force_idle_state and not (is_moving or should_move or inst.sg:HasStateTag("idle") or inst:HasTag("is_furling"))  then
            inst.sg:GoToState("idle")
        end
    end),

    EventHandler("blocked", function(inst, data)
        if not inst.components.health:IsDead() and inst.sg:HasStateTag("shell") then
            inst.sg:GoToState("shell_hit")
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
                    })
                end
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
        if not (inst.components.health:IsDead() or inst:HasTag("wereplayer")) then
            if inst.sg:HasStateTag("parrying") then
                inst.sg.statemem.parrying = true
                inst.sg:GoToState("parry_knockback", {
                    timeleft =
                        (inst.sg.statemem.task ~= nil and GetTaskRemaining(inst.sg.statemem.task)) or
                        (inst.sg.statemem.timeleft ~= nil and math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime())) or
                        inst.sg.statemem.parrytime,
                    knockbackdata = data,
                })
            else
                inst.sg:GoToState((data.forcelanded or inst.components.inventory:ArmorHasTag("heavyarmor") or inst:HasTag("heavybody")) and "knockbacklanded" or "knockback", data)
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

    EventHandler("set_heading",
        function(inst)
            if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead() or inst.sg:HasStateTag("is_turning_wheel")) then
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
        if data.eslot == EQUIPSLOTS.BODY and data.item ~= nil and data.item:HasTag("heavy") then
            inst.sg:GoToState("heavylifting_start")
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
		if inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("notalking") then
			if not inst:HasTag("mime") then
				inst.sg:GoToState("talk", data.noanim)
			elseif not inst.components.inventory:IsHeavyLifting() then
				--Don't do it even if mounted!
				inst.sg:GoToState("mime")
			end
		elseif data.duration ~= nil and not data.noanim then
			inst.sg.mem.queuetalk_timeout = data.duration + GetTime()
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
            inst.sg:GoToState("toolbroke", data.tool)
        end),

    EventHandler("armorbroke",
        function(inst)
            inst.sg:GoToState("armorbroke")
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

        onenter = function(inst)
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
            end

            if inst.components.rider:IsRiding() then
                inst.sg.statemem.data = data
                ForceStopHeavyLifting(inst)
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

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
            end
            inst.AnimState:PlayAnimation("rebirth")

            for k,v in pairs(statue_symbols) do
                inst.AnimState:OverrideSymbol(v, "wilsonstatue", v)
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
                inst.AnimState:PlayAnimation("fall_off")
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

                if HUMAN_MEAT_ENABLED then
                    inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
                end
                if inst.components.revivablecorpse ~= nil then
                    inst.AnimState:PlayAnimation("death2")
                else
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
        },

        onexit = function(inst)
            --You should never leave this state once you enter it!
            if inst.components.revivablecorpse == nil then
                assert(false, "Left death state.")
            end
        end,

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

                        if HUMAN_MEAT_ENABLED then
                            inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
                        end
                        if inst.components.revivablecorpse ~= nil then
                            inst.AnimState:PlayAnimation("death2")
                        else
                            inst.components.inventory:DropEverything(true)
                            inst.AnimState:PlayAnimation(inst.deathanimoverride or "death")
                        end

                        inst.AnimState:Hide("swap_arm_carry")
                    elseif inst.components.revivablecorpse ~= nil then
                        inst.sg:GoToState("corpse")
                    else
                        inst:PushEvent(inst.ghostenabled and "makeplayerghost" or "playerdied", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
                    end
                end
            end),
        },
    },

    State{
        name = "idle",
        tags = { "idle", "canrotate" },

        onenter = function(inst, pushanim)
            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

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
				local raminging_talk_time = inst.sg.mem.queuetalk_timeout - GetTime()
				inst.sg.mem.queuetalk_timeout = nil
				if not inst:HasTag("ignoretalking") and not pushanim then
					if raminging_talk_time > 1 then
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
            else
                inst.sg.statemem.ignoresandstorm = false
                if inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL
                    and not inst.components.playervision:HasGoggleVision() then
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
                    table.insert(anims, "idle_groggy_pre")
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
                local len = inst.AnimState:GetCurrentAnimationLength()
                local t = inst.AnimState:GetCurrentAnimationTime()
                t = math.floor((t - math.floor(t / len) * len) / FRAMES + .5)
                if (t == 5 or t == 14) and t ~= inst.sg.statemem.gooseframe then
                    PlayFootstep(inst, .5, false)
                    DoGooseStepFX(inst)
                end
                inst.sg.statemem.gooseframe = t
            end
        end,

        events =
        {
            EventHandler("sandstormlevel", function(inst, data)
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
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
            if not inst.sg.statemem.bowing and inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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

            if inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
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
            EventHandler("sandstormlevel", function(inst, data)
                if data.level < TUNING.SANDSTORM_FULL_LEVEL then
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
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("chop")
                end
            end),
        },
    },

    State{
        name = "chop",
        tags = { "prechop", "chopping", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.sg.statemem.iswoodcutter = inst:HasTag("woodcutter")
            inst.AnimState:PlayAnimation(inst.sg.statemem.iswoodcutter and "woodie_chop_loop" or "chop_loop")
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
    },

    State{
        name = "mine_start",
        tags = { "premine", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("mine")
                end
            end),
        },
    },

    State{
        name = "mine",
        tags = { "premine", "mining", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    local target = inst.sg.statemem.action.target
                    if target ~= nil and target:IsValid() then
                        local frozen = target:HasTag("frozen")
                        local moonglass = target:HasTag("moonglass")
                        if target.Transform ~= nil then
                            local mine_fx = (frozen and "mining_ice_fx") or (moonglass and "mining_moonglass_fx") or "mining_fx"
                            SpawnPrefab(mine_fx).Transform:SetPosition(target.Transform:GetWorldPosition())
                        end
                        inst.SoundEmitter:PlaySound((frozen and "dontstarve_DLC001/common/iceboulder_hit") or (moonglass and "turnoftides/common/together/moon_glass/mine") or "dontstarve/wilson/use_pick_rock")
                    end
                end
                inst:PerformBufferedAction()
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("premine")
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
    },

    State{
        name = "hammer_start",
        tags = { "prehammer", "working" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hammer")
                end
            end),
        },
    },

    State{
        name = "hammer",
        tags = { "prehammer", "hammering", "working" },

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("prehammer")
                local hit_skin_sound = inst.sg.statemem.action ~= nil and inst.sg.statemem.action.invobject ~= nil and inst.sg.statemem.action.invobject.hit_skin_sound or nil
                inst.SoundEmitter:PlaySound(hit_skin_sound or "dontstarve/wilson/hit")
            end),

            TimeEvent(9 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehammer")
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
        end,

        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.action ~= nil then
                    local target = inst.sg.statemem.action.target
                    if target ~= nil and target:IsValid() then
                        if inst.sg.statemem.action.action == ACTIONS.MINE then
                            SpawnPrefab("mining_fx").Transform:SetPosition(target.Transform:GetWorldPosition())
                            inst.SoundEmitter:PlaySound(target:HasTag("frozen") and "dontstarve_DLC001/common/iceboulder_hit" or "dontstarve/wilson/use_pick_rock")
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

                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
            EventHandler("unequip", function(inst, data)
                -- We need to handle this during the initial "busy" frames
                if not inst.sg:HasStateTag("idle") then
                    inst.sg:GoToState(GetUnequipState(inst, data))
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
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

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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

                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("parry_pre")
            inst.AnimState:PushAnimation("parry_loop", true)
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
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
                inst.sg:GoToState("parry_idle", { duration = inst.sg.statemem.parrytime, pauseframes = 30, talktask = talktask })
            else
                inst.AnimState:PlayAnimation("parry_pst")
                inst.sg:GoToState("idle", true)
            end
        end,

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "parry_idle",
        tags = { "notalking", "parrying", "nomorph" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            if data ~= nil and data.duration ~= nil then
                if data.duration > 0 then
                    inst.sg.statemem.task = inst:DoTaskInTime(data.duration, function(inst)
                        inst.sg.statemem.task = nil
                        inst.AnimState:PlayAnimation("parry_pst")
                        inst.sg:GoToState("idle", true)
                    end)
                else
                    inst.AnimState:PlayAnimation("parry_pst")
                    inst.sg:GoToState("idle", true)
                    return
                end
            end

            if not inst.AnimState:IsCurrentAnimation("parry_loop") then
                inst.AnimState:PushAnimation("parry_loop", true)
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
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
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
            if not inst.sg.statemem.parrying then
                inst.components.combat.redirectdamagefn = nil
            end
        end,
    },

    State{
        name = "parry_hit",
        tags = { "parrying", "parryhit", "nomorph", "busy", "nopredict" },

        onenter = function(inst, data)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("parryblock")
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
                inst.sg:GoToState("parry_idle", inst.sg.statemem.timeleft ~= nil and { duration = math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime()) } or nil)
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
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("parryblock")
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
                inst.sg:GoToState("parry_idle", inst.sg.statemem.timeleft ~= nil and { duration = math.max(0, inst.sg.statemem.timeleft + inst.sg.statemem.timeleft0 - GetTime()) } or nil)
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
        end,

        events =
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("dig")
                end
            end),
        },
    },

    State{
        name = "dig",
        tags = { "predig", "digging", "working" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shovel_loop")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("predig")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
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
        tags = { "busy", "nodangle" },

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
            end),

            TimeEvent(30 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),

            TimeEvent(70 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("eating")
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
        end,
    },

    State{
        name = "quickeat",
        tags = { "busy" },

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
            inst.SoundEmitter:KillSound("eating")
            if not GetGameModeProperty("no_hunger") then
                inst.components.hunger:Resume()
            end
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
        end,
    },

    State{
        name = "refuseeat",
        tags = { "busy", "pausepredict" },

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
        },

        ontimeout = function(inst)
			StopTalkSound(inst)
        end,

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
        tags = { "doing" },

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
        tags = { "doing" },

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
        name = "talk",
        tags = { "idle", "talking" },

        onenter = function(inst, noanim)
            if not noanim then
                inst.AnimState:PlayAnimation(
                    inst.components.inventory:IsHeavyLifting() and
                    not inst.components.rider:IsRiding() and
                    "heavy_dial_loop" or
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
            inst.AnimState:PlayAnimation("mime"..tostring(math.random(13)))
            for k = 1, math.random(2) do
                inst.AnimState:PushAnimation("mime"..tostring(math.random(13)), false)
            end
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
			if not inst.sg.statemem.not_interupted then
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
            TimeEvent(13 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(15 * FRAMES, function(inst)
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

            local mount = inst.components.rider:GetMount()
            inst.AnimState:PlayAnimation(mount ~= nil and "heavy_mount" or "heavy_pickup_pst")

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
            TimeEvent(8 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(10 * FRAMES, function(inst)
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
            TimeEvent(6 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(12 * FRAMES, function(inst)
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
            TimeEvent(6 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(12 * FRAMES, function(inst)
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
        tags = { "doing", "busy" },

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
            TimeEvent(4 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(6 * FRAMES, function(inst)
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
                    else
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
        tags = { "doing", "busy", "nodangle" },

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
                    inst.bufferedaction.target:PushEvent("startlongaction")
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
            inst:PerformBufferedAction()
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
            if inst.sg.statemem.actionmeter then
                StopActionMeter(inst, false)
            end
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
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
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre_shadow", nil, nil, true)
					inst.AnimState:Show("pocketwatch_weapon_fx")
					inst.sg.statemem.ispocketwatch_fueled = true
                else
	                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/pre", nil, nil, true)
					inst.AnimState:Hide("pocketwatch_weapon_fx")
                end
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
            --beaver: frame 4 remove busy, frame 6 action
            --whip: frame 8 remove busy, frame 10 action
            --other: frame 6 remove busy, frame 8 action
            TimeEvent(4 * FRAMES, function(inst)
                if inst.sg.statemem.isbeaver then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(6 * FRAMES, function(inst)
                if inst.sg.statemem.isbeaver then
                    inst:PerformBufferedAction()
                elseif not (inst.sg.statemem.iswhip or inst.sg.statemem.ispocketwatch) then
                    inst.sg:RemoveStateTag("busy")
                end
            end),
            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.ispocketwatch then
                    inst.sg:RemoveStateTag("busy")
                elseif not inst.sg.statemem.isbeaver then
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(10 * FRAMES, function(inst)
                if inst.sg.statemem.iswhip or inst.sg.statemem.ispocketwatch then
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
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if not inst.AnimState:IsCurrentAnimation("channel_loop") then
                    inst.AnimState:PlayAnimation("channel_loop", true)
                end
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
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
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
    },

    State{
        name = "dodismountaction",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("dismount")
            if inst.bufferedaction ~= nil then
                inst.sg.statemem.action = inst.bufferedaction
                if inst.bufferedaction.action.actionmeter then
                    inst.sg.statemem.actionmeter = true
                    StartActionMeter(inst, 43*FRAMES)
                end
                if inst.bufferedaction.target ~= nil and inst.bufferedaction.target:IsValid() then
                    inst.bufferedaction.target:PushEvent("startlongaction")
                end
            end
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.actionmeter then
                    inst.sg.statemem.actionmeter = nil
                    StopActionMeter(inst, true)
                end
                inst:PerformBufferedAction()
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.actionmeter then
                StopActionMeter(inst, false)
            end
            if inst.bufferedaction == inst.sg.statemem.action then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "makeballoon",
        tags = { "doing", "busy", "nodangle" },

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
            inst:PerformBufferedAction()
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
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "dostorytelling",
        tags = { "doing", "busy", "nodangle" },

        onenter = function(inst)
            inst.sg.statemem.action = inst.bufferedaction
            inst.components.locomotor:Stop()
	        if not inst:PerformBufferedAction() then
				inst.sg.statemem.not_interupted = true
				inst.sg:GoToState("idle")
			else
	            inst.AnimState:PlayAnimation("idle_walter_storytelling_pre")
			end
        end,

        timeline =
        {
            TimeEvent(7 * FRAMES, function(inst)
                DoTalkSound(inst)
            end),
        },

        events =
        {
            EventHandler("ontalk", function(inst)
				inst.sg.statemem.started = true -- to prevent the delayed "donetalking" event from a previous talk from cancelling the story
			end),
            EventHandler("donetalking", function(inst)
				if inst.sg.statemem.started then
					inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
					inst.sg:GoToState("idle", true)
				end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interupted = true
                    inst.sg:GoToState("dostorytelling_loop")
                end
            end),
        },

        onexit = function(inst)
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
			if not inst.sg.statemem.not_interupted then
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

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PushAnimation(math.random() < 0.75 and "idle_walter_storytelling" or "idle_walter_storytelling_2")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
					inst.sg.statemem.not_interupted = true
                    inst.sg:GoToState("dostorytelling_loop")
                end
            end),
            EventHandler("donetalking", function(inst)
				inst.sg.statemem.not_interupted = true
				StopTalkSound(inst)
		        inst.AnimState:PlayAnimation("idle_walter_storytelling_pst")
				inst.sg:GoToState("idle", true)
            end),
        },

        onexit = function(inst)
			if not inst.sg.statemem.not_interupted then
				StopTalkSound(inst, true)
				if inst.components.talker ~= nil then
					inst.components.talker:ShutUp()
				end
			end
        end,
    },

    State{
        name = "shave",
        tags = { "doing", "shaving", "nodangle" },

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

        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
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
        tags = { "doing", "playing" },

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
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            inst.components.inventory:ReturnActiveActionItem(inv_obj)
        end,

        timeline =
        {
            TimeEvent(30 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/flute_LP", "flute")
                else
                    inst.AnimState:SetTime(94 * FRAMES)
                end
            end),
            TimeEvent(85 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("flute")
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
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "play_horn",
        tags = { "doing", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("horn", false)
            inst.AnimState:OverrideSymbol("horn01", "horn", "horn01")
            --inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil)
        end,

        timeline =
        {
            TimeEvent(21 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
                else
                    inst.AnimState:SetTime(48 * FRAMES)
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
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "play_bell",
        tags = { "doing", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bell")
            inst.AnimState:OverrideSymbol("bell01", "bell", "bell01")
            --inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
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
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "play_whistle",
        tags = { "doing", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("whistle", false)
            inst.AnimState:OverrideSymbol("hound_whistle01", "houndwhistle", "hound_whistle01")
            --inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil)
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.SoundEmitter:PlaySound("dontstarve/common/together/houndwhistle")
                else
                    inst.AnimState:SetTime(34 * FRAMES)
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
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "play_gnarwail_horn",
        tags = { "doing", "playing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("hornblow_pre")
            inst.AnimState:PushAnimation("hornblow", false)
        end,

        timeline =
        {
            TimeEvent(17 * FRAMES, function(inst)
                local horn = (inst.bufferedaction and inst.bufferedaction.invobject) or nil
                if inst:PerformBufferedAction() then
                    if horn and horn.playsound then
                        inst.SoundEmitter:PlaySound(horn.playsound)
                    end
                else
                    inst.AnimState:SetTime(49 * FRAMES)
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
        tags = { "doing", "playing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("cowbell", false)
            inst.AnimState:OverrideSymbol("cbell", "cowbell", "cbell")
            inst.AnimState:Show("ARM_normal")

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

        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
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
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/summon") end),

            TimeEvent(52 * FRAMES, function(inst)
                inst.sg.statemem.fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailsummonfx_mount" or "abigailsummonfx")
                inst.sg.statemem.fx.entity:SetParent(inst.entity)
                inst.sg.statemem.fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

                if inst.bufferedaction ~= nil then
                    local flower = inst.bufferedaction.invobject
                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            inst.sg.statemem.fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                        end
                    end
                end

                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end
            end),
            TimeEvent(62 * FRAMES, function(inst)
                if inst:PerformBufferedAction() then
                    inst.sg.statemem.fx = nil
                else
                    inst.sg:GoToState("idle")
                end
            end),
            TimeEvent(74 * FRAMES, function(inst) inst.sg:RemoveStateTag("busy") end),
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
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wendy/recall") end),
            TimeEvent(26 * FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")

                if inst.components.talker ~= nil then
                    inst.components.talker:ShutUp()
                end

                local flower = nil
                if inst.bufferedaction ~= nil then
                    flower = inst.bufferedaction.invobject
                end

                if inst:PerformBufferedAction() then
                    local fx = SpawnPrefab(inst.components.rider:IsRiding() and "abigailunsummonfx_mount" or "abigailunsummonfx")
                    fx.entity:SetParent(inst.entity)
                    fx.AnimState:SetTime(0) -- hack to force update the initial facing direction

                    if flower ~= nil then
                        local skin_build = flower:GetSkinBuild()
                        if skin_build ~= nil then
                            fx.AnimState:OverrideItemSkinSymbol("flower", skin_build, "flower", flower.GUID, flower.AnimState:GetBuild() )
                        end
                    end
                else
                    inst.sg:GoToState("idle")
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
                inst:PerformBufferedAction()
            end),

            TimeEvent(35 * FRAMES, function(inst)
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
            inst.AnimState:ClearOverrideSymbol("flower")
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "play_strum",
        tags = { "doing", "playing", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("strum_pre")
            inst.AnimState:PushAnimation("strum", false)

            inst.AnimState:OverrideSymbol("swap_trident", "swap_trident", "swap_trident")
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("hookline_2/characters/trident_attack") end),
            TimeEvent(28 * FRAMES, function(inst)
                local instrument = (inst.bufferedaction and inst.bufferedaction.invobject) or nil
                if inst:PerformBufferedAction() then
                    if instrument and instrument.playsound then
                        inst.SoundEmitter:PlaySound(instrument.playsound)
                    end
                else
                    inst.AnimState:SetTime(51 * FRAMES)
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
        tags = { "doing", "canrotate", "channeling"},

        onenter = function(inst)

            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give",false)
            inst.AnimState:PushAnimation("give_pst",false)

            if inst:GetBufferedAction() then
                local act = inst:GetBufferedAction()
                inst.channelitem = act.target
                inst:PerformBufferedAction()
            end
        end,

        onexit = function(inst)
            if not inst.sg.noexit then
                if inst.channelitem then
                    inst.channelitem:PushEvent("channel_finished")
                    inst.channelitem = nil
                end
            else
                inst.sg.noexit = nil
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg.noexit = true
                inst.sg:GoToState("channel_longaction")
            end),
            EventHandler("cancel_channel_longaction", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

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

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

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
                    inst.AnimState:SetTime(51 * FRAMES)
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
            inst.AnimState:ClearOverrideBuild(inst.sg.statemem.target_build)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "book",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("book", false)
            --V2C: NOTE that these are now used in onexit to clear skinned symbols
            --Moved to player_common because these symbols are never cleared
            --inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
            --inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")
            --inst.AnimState:OverrideSymbol("book_open_pages", "player_actions_uniqueitem", "book_open_pages")
            --inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")

            local book = inst.bufferedaction ~= nil and (inst.bufferedaction.target or inst.bufferedaction.invobject) or nil
            if book ~= nil then
                inst.components.inventory:ReturnActiveActionItem(book)
                local skin_build = book:GetSkinBuild()
                if skin_build ~= nil then
                    inst.sg.statemem.skinned = true
                    inst.AnimState:OverrideItemSkinSymbol("book_open", skin_build, "book_open", book.GUID, "player_actions_uniqueitem")
                    inst.AnimState:OverrideItemSkinSymbol("book_closed", skin_build, "book_closed", book.GUID, "player_actions_uniqueitem")
                    inst.AnimState:OverrideItemSkinSymbol("book_open_pages", skin_build, "book_open_pages", book.GUID, "player_actions_uniqueitem")
                end

                --should be same as the buffered action item
                if book.components.aoetargeting ~= nil and book == inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                    inst.sg.statemem.isaoe = true
                    inst.sg:AddStateTag("busy")
                    if book.components.aoetargeting.targetprefab ~= nil then
                        local buffaction = inst:GetBufferedAction()
                        if buffaction ~= nil and buffaction.pos ~= nil then
                            inst.sg.statemem.targetfx = SpawnPrefab(book.components.aoetargeting.targetprefab)
                            if inst.sg.statemem.targetfx ~= nil then
                                inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
                                inst.sg.statemem.targetfx:ListenForEvent("onremove", OnRemoveCleanupTargetFX, inst)
                            end
                        end
                    end
                end
            end

            inst.sg.statemem.castsound = book ~= nil and book.castsound or "dontstarve/common/book_spell"
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                inst.sg.statemem.book_fx = SpawnPrefab(inst.components.rider:IsRiding() and "book_fx_mount" or "book_fx")
                inst.sg.statemem.book_fx.entity:SetParent(inst.entity)
                inst.sg.statemem.book_fx.Transform:SetPosition(0, .2, 0)
            end),
            TimeEvent(25 * FRAMES, function(inst)
                if inst.sg.statemem.isaoe then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(28 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_light")
            end),
            TimeEvent(54 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/use_book_close")
            end),
            TimeEvent(58 * FRAMES, function(inst)
                if inst.sg.statemem.targetfx ~= nil then
                    if inst.sg.statemem.targetfx:IsValid() then
                        OnRemoveCleanupTargetFX(inst)
                    end
                    inst.sg.statemem.targetfx = nil
                end
                inst.sg.statemem.book_fx = nil --Don't cancel anymore
                if not inst.sg.statemem.isaoe then
                    inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
                    inst:PerformBufferedAction()
                end
            end),
            TimeEvent(65 * FRAMES, function(inst)
                if inst.sg.statemem.isaoe then
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
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if item ~= nil and not item:HasTag("book") then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
            if inst.sg.statemem.skinned then
                inst.AnimState:OverrideSymbol("book_open", "player_actions_uniqueitem", "book_open")
                inst.AnimState:OverrideSymbol("book_closed", "player_actions_uniqueitem", "book_closed")
                inst.AnimState:OverrideSymbol("book_open_pages", "player_actions_uniqueitem", "book_open_pages")
            end
            if inst.sg.statemem.book_fx ~= nil and inst.sg.statemem.book_fx:IsValid() then
                inst.sg.statemem.book_fx:Remove()
            end
            if inst.sg.statemem.targetfx ~= nil and inst.sg.statemem.targetfx:IsValid() then
                OnRemoveCleanupTargetFX(inst)
            end
        end,
    },

    State{
        name = "book_peruse",
        tags = { "doing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("action_uniqueitem_pre")
            inst.AnimState:PushAnimation("peruse", false)
			inst.AnimState:Show("ARM_normal")
            inst.components.inventory:ReturnActiveActionItem(inst.bufferedaction ~= nil and inst.bufferedaction.invobject or nil)
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
                    inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Hide("ARM_normal")
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
                inst.AnimState:SetTime(5 * FRAMES)
            end
            inst.AnimState:PushAnimation("dart", false)

            inst.sg:SetTimeout(math.max((inst.sg.statemem.chained and 14 or 18) * FRAMES, inst.components.combat.min_attack_period + .5 * FRAMES))

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
            local cooldown = math.max(inst.components.combat.min_attack_period + .5 * FRAMES, 11 * FRAMES)

            inst.AnimState:PlayAnimation("throw")

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
                inst.sg.statemem.thrown = true
                inst:PerformBufferedAction()
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
                if data.eslot ~= EQUIPSLOTS.HANDS or not inst.sg.statemem.thrown then
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
            inst.components.combat:SetTarget(nil)
            if inst.sg:HasStateTag("abouttoattack") then
                inst.components.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "catch_pre",
        tags = { "notalking", "readytocatch" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            if not inst.AnimState:IsCurrentAnimation("catch_pre") then
                inst.AnimState:PlayAnimation("catch_pre")
            end

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
            local cooldown = inst.components.combat.min_attack_period + .5 * FRAMES
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
                                "dontstarve/wilson/attack_weapon"
                        elseif inst.sg.statemem.projectiledelay <= 0 then
                            inst.sg.statemem.projectiledelay = nil
                        end
                    end
                    if inst.sg.statemem.projectilesound == nil then
                        inst.SoundEmitter:PlaySound(
                            (equip:HasTag("icestaff") and "dontstarve/wilson/attack_icestaff") or
                            (equip:HasTag("firestaff") and "dontstarve/wilson/attack_firestaff") or
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
                inst.AnimState:PlayAnimation(inst.AnimState:IsCurrentAnimation("woodie_chop_loop") and inst.AnimState:GetCurrentAnimationTime() < 7.1 * FRAMES and "woodie_chop_atk_pre" or "woodie_chop_pre")
                inst.AnimState:PushAnimation("woodie_chop_loop", false)
                inst.sg.statemem.ischop = true
                cooldown = math.max(cooldown, 11 * FRAMES)
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
                inst.AnimState:PlayAnimation(
                    ((inst.AnimState:IsCurrentAnimation("punch_a") or inst.AnimState:IsCurrentAnimation("punch_c")) and "punch_b") or
                    (inst.AnimState:IsCurrentAnimation("punch_b") and "punch_c") or
                    "punch_a"
                )
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
                if inst.sg.statemem.ismoose then
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
                    inst:PerformBufferedAction()
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

            --V2C: adding half a frame time so it rounds up
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES)
        end,

        onupdate = function(inst)
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
            TimeEvent(1 * FRAMES, function(inst)
                if inst.sg.statemem.groggy then
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
                    inst.sg.statemem.sandstorm then
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
                            inst.sg.statemem.sandstorm or
                            inst:GetStormLevel() < TUNING.SANDSTORM_FULL_LEVEL) then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("sandstormlevel", function(inst, data)
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
        name = "item_hat",
        tags = { "idle" },

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
        tags = { "idle", "nodangle" },

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
        tags = { "idle", "nodangle" },

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
        tags = { "busy", "pausepredict" },

        onenter = function(inst, frozen)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("hit")

            if frozen == "noimpactsound" then
                frozen = nil
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end
            DoHurtSound(inst)

            --V2C: some of the woodie's were-transforms have shorter hit anims
            local stun_frames = math.min(math.floor(inst.AnimState:GetCurrentAnimationLength() / FRAMES + .5), frozen and 10 or 6)
            if inst.components.playercontroller ~= nil then
                --Specify min frames of pause since "busy" tag may be
                --removed too fast for our network update interval.
                inst.components.playercontroller:RemotePausePrediction(stun_frames <= 7 and stun_frames or nil)
            end
            inst.sg:SetTimeout(stun_frames * FRAMES)
        end,

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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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

            if spike ~= nil then
                inst:ForceFacePoint(spike.Transform:GetWorldPosition())
            end
            inst.AnimState:PlayAnimation("hit_spike_"..(spike ~= nil and spike.spikesize or "short"))

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
        tags = { "doing", "nodangle" },

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
                    inst.bufferedaction.target:PushEvent("startlongaction")
                end
            end
			if inst.components.mightiness then
				inst.components.mightiness:Pause()
			end
            if not inst:PerformBufferedAction() then
                inst.sg:GoToState("idle")
            end
        end,

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
            EventHandler("animqueueover", function(inst)
                if inst:PerformBufferedAction() then
                    inst.sg:GoToState("steer_boat_idle_loop", true)
                else
                    inst.sg:GoToState("idle")
                end
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
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
            inst.Transform:SetFourFaced()
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
                inst.sg:GoToState("steer_boat_turning_pst")
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.Transform:SetFourFaced()
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
            inst.Transform:SetFourFaced()
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("steer_boat_idle_loop")
            end),
            EventHandler("stop_steering_boat", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

   State{
        name = "stop_steering",
        tags = { },

        onenter = function(inst)
            inst.Transform:SetNoFaced()
            inst.AnimState:PlayAnimation("steer_idle_pst")
        end,

        onexit = function(inst)
            inst.Transform:SetFourFaced()
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle", true)
            end),
        }
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
            inst.AnimState:SetTime(60 * FRAMES)
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

            if inst.components.rider:IsRiding() or inst:HasTag("wereplayer") then
                inst.AnimState:PlayAnimation("hit")
            else
                inst.AnimState:PlayAnimation("distress_pre")
                inst.AnimState:PushAnimation("distress_pst", false)
            end

            DoHurtSound(inst)

            if data ~= nil and data.radius ~= nil and data.repeller ~= nil and data.repeller:IsValid() then
                local x, y, z = data.repeller.Transform:GetWorldPosition()
                local distsq = inst:GetDistanceSqToPoint(x, y, z)
                local rangesq = data.radius * data.radius
                if distsq < rangesq then
                    if distsq > 0 then
                        inst:ForceFacePoint(x, y, z)
                    end
                    local k = .5 * distsq / rangesq - 1
                    inst.sg.statemem.speed = 25 * k
                    inst.sg.statemem.dspeed = 2
                    inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
                end
            end

            inst.sg:SetTimeout(9 * FRAMES)
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
        tags = { "busy", "nopredict", "nomorph", "nodangle" },

        onenter = function(inst, data)
            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.rider:ActualDismount()
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            inst.AnimState:PlayAnimation("bucked")

            if data ~= nil then
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
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
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
        tags = { "knockback", "busy", "nopredict", "nomorph" },

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
        end,

        timeline =
        {
            TimeEvent(9 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
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
                    return item.prefab == inst.sg.statemem.toolname
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
            EventHandler("ontalk", function(inst)
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
        end,
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

            if data.teleporter ~= nil and data.teleporter.components.teleporter ~= nil then
                data.teleporter.components.teleporter:RegisterTeleportee(inst)
            end

            inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_jump" or "jump")

            local pos = data ~= nil and data.teleporter and data.teleporter:GetPosition() or nil

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
                    if inst.sg.statemem.target ~= nil and
                        inst.sg.statemem.target:IsValid() and
                        inst.sg.statemem.target.components.teleporter ~= nil then
                        --Unregister first before actually teleporting
                        inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
                        if inst.sg.statemem.target.components.teleporter:Activate(inst) then
                            inst.sg.statemem.isteleporting = true
                            inst.components.health:SetInvincible(true)
                            if inst.components.playercontroller ~= nil then
                                inst.components.playercontroller:Enable(false)
                            end
                            inst:Hide()
                            inst.DynamicShadow:Enable(false)
                            return
                        end
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

            if staff ~= nil and staff.components.aoetargeting ~= nil and staff.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(staff.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
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
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
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
        name = "veryquickcastspell",
        tags = { "doing", "canrotate", "busy" },

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

            local coin = inst.bufferedaction ~= nil and inst.bufferedaction.invobject
            inst.sg.statemem.fxcolour = coin ~= nil and coin.fxcolour or { 1, 1, 1 }
            inst.sg.statemem.castsound = coin ~= nil and coin.castsound
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
                if pos.x ~= data.targetpos.x or pos.z ~= data.targetpos.z then
                    inst:ForceFacePoint(data.targetpos:Get())
                end
                if data.weapon.components.aoeweapon_lunge:DoLunge(inst, pos, data.targetpos) then
                    inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
                    inst.Physics:Teleport(data.targetpos.x, 0, data.targetpos.z)
                    inst.components.bloomer:PushBloom("lunge", "shaders/anim.ksh", -2)
                    inst.components.colouradder:PushColour("lunge", 1, 1, 0, 0)
                    inst.sg.statemem.flash = 1
                    return
                end
            end
            --Failed
            inst.sg:GoToState("idle", true)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                inst.components.colouradder:PushColour("lunge", inst.sg.statemem.flash, inst.sg.statemem.flash, 0, 0)
            end
        end,

        timeline =
        {
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
            if weapon ~= nil and weapon.components.aoetargeting ~= nil and weapon.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(weapon.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
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
                    inst.sg.statemem.flash = 0
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
            if inst.sg.statemem.flash > 0 then
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
                inst.components.colouradder:PushColour("leap", .1, .1, 0, 0)
            end),
            TimeEvent(11 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("leap", .2, .2, 0, 0)
            end),
            TimeEvent(12 * FRAMES, function(inst)
                inst.components.colouradder:PushColour("leap", .4, .4, 0, 0)
                ToggleOnPhysics(inst)
                inst.Physics:Stop()
                inst.Physics:SetMotorVel(0, 0, 0)
                inst.Physics:Teleport(inst.sg.statemem.targetpos.x, 0, inst.sg.statemem.targetpos.z)
            end),
            TimeEvent(13 * FRAMES, function(inst)
                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.components.bloomer:PushBloom("leap", "shaders/anim.ksh", -2)
                inst.components.colouradder:PushColour("leap", 1, 1, 0, 0)
                inst.sg.statemem.flash = 1.3
                inst.sg:RemoveStateTag("nointerrupt")
                if inst.sg.statemem.weapon:IsValid() then
                    inst.sg.statemem.weapon.components.aoeweapon_leap:DoLeap(inst, inst.sg.statemem.startingpos, inst.sg.statemem.targetpos)
                end
            end),
            TimeEvent(25 * FRAMES, function(inst)
                inst.components.bloomer:PopBloom("leap")
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
            inst.components.bloomer:PopBloom("leap")
            inst.components.colouradder:PopColour("leap")
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
            if weapon ~= nil and weapon.components.aoetargeting ~= nil and weapon.components.aoetargeting.targetprefab ~= nil then
                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil and buffaction.pos ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(weapon.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
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
                    inst.AnimState:SetMultColour(.4, .4, .4, .4)
                    inst.sg.statemem.targetpos = data.targetpos
                    inst.sg.statemem.flash = 0
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
            if inst.sg.statemem.flash > 0 then
                inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)
                local c = math.min(1, inst.sg.statemem.flash)
                inst.components.colouradder:PushColour("superjump", c, c, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                inst.AnimState:SetMultColour(.7, .7, .7, .7)
                inst.components.colouradder:PushColour("superjump", .1, .1, 0, 0)
            end),
            TimeEvent(2 * FRAMES, function(inst)
                inst.AnimState:SetMultColour(.9, .9, .9, .9)
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
                inst.sg.statemem.flash = 1.3
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
        tags = { "attack" },

        onenter = function(inst)
            if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            if target ~= nil and target:IsValid() then
	            inst:ForceFacePoint(target.Transform:GetWorldPosition())
	            inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
			end

			inst.sg.statemem.abouttoattack = true

            inst.AnimState:PlayAnimation("slingshot_pre")
            inst.AnimState:PushAnimation("slingshot", false)

            if inst.sg.laststate == inst.sg.currentstate then
                inst.sg.statemem.chained = true
                inst.AnimState:SetTime(3 * FRAMES)
            end

            inst.components.combat:StartAttack()
            inst.components.combat:SetTarget(target)
            inst.components.locomotor:Stop()

            inst.sg:SetTimeout((inst.sg.statemem.chained and 25 or 28) * FRAMES)
        end,

        timeline =
        {
            TimeEvent(15 * FRAMES, function(inst)
				if inst.sg.statemem.chained then
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
					local buffaction = inst:GetBufferedAction()
					local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
						local target = buffaction ~= nil and buffaction.target or nil
						if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
							inst.sg.statemem.abouttoattack = false
							inst:PerformBufferedAction()
							inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
						else
							inst:ClearBufferedAction()
							inst.sg:GoToState("idle")
						end
					else -- out of ammo
						inst:ClearBufferedAction()
						inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
						inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
					end
				end
            end),

            TimeEvent(18 * FRAMES, function(inst)
				if not inst.sg.statemem.chained then
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
					local buffaction = inst:GetBufferedAction()
					local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
					if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
						local target = buffaction ~= nil and buffaction.target or nil
						if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
							inst.sg.statemem.abouttoattack = false
							inst:PerformBufferedAction()
							inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
						else
							inst:ClearBufferedAction()
							inst.sg:GoToState("idle")
						end
					else -- out of ammo
						inst:ClearBufferedAction()
						inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
						inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
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
            if inst.sg.statemem.abouttoattack and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
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
            inst.AnimState:PlayAnimation("atk_pre")

            if buffaction ~= nil and buffaction.pos ~= nil then
                inst:ForceFacePoint(buffaction:GetActionPoint():Get())

                if equip ~= nil and equip.components.aoetargeting ~= nil and equip.components.aoetargeting.targetprefab ~= nil then
                    inst.sg.statemem.targetfx = SpawnPrefab(equip.components.aoetargeting.targetprefab)
                    if inst.sg.statemem.targetfx ~= nil then
                        inst.sg.statemem.targetfx.Transform:SetPosition(buffaction:GetActionPoint():Get())
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
            TimeEvent(18 * FRAMES, function(inst)
                if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
                    inst.sg:GoToState("item_out")
                else
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.AnimState:IsCurrentAnimation("atk_pre") then
                        inst.AnimState:PlayAnimation("throw")
                        inst.AnimState:SetTime(6 * FRAMES)
                    else
                        inst.sg:GoToState(inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil and "item_out" or "idle")
                    end
                end
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

            if data.tags ~= nil then
                for i, v in ipairs(data.tags) do
                    inst.sg:AddStateTag(v)
                    if v == "dancing" then
                        TheWorld:PushEvent("dancingplayer",inst)
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
            elseif animtype == "table" then
                inst.AnimState:PlayAnimation(anim[1])
                for i = 2, #anim - 1 do
                    inst.AnimState:PushAnimation(anim[i])
                end
                inst.AnimState:PushAnimation(anim[#anim], data.loop == true)
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
            inst.AnimState:Show("ARM_normal")
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

        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
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
            TimeEvent(35 * FRAMES, function(inst)
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
                if inst.sg.statemem.talktask ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst, true)
                end
                if DoTalkSound(inst) then
                    inst.sg.statemem.talktask =
                        inst:DoTaskInTime(1.5 + math.random() * .5,
                            function()
                                inst.sg.statemem.talktask = nil
                                StopTalkSound(inst)
                            end)
                end
            end),
            EventHandler("donetalking", function(inst)
                if not inst.AnimState:IsCurrentAnimation("channel_loop") then
                    inst.AnimState:PlayAnimation("channel_loop", true)
                end
                if inst.sg.statemem.talktalk ~= nil then
                    inst.sg.statemem.talktask:Cancel()
                    inst.sg.statemem.talktask = nil
                    StopTalkSound(inst)
                end
            end),
        },

        onexit = function(inst)
            inst:RemoveTag("channeling")
            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                StopTalkSound(inst)
            end
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

    State{
        name = "till_start",
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("till_pre")
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
        tags = { "doing", "busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("till_loop")
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
                    inst.AnimState:PlayAnimation("till_pst")
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
				inst.AnimState:Show("ARM_normal")

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
					inst.sg:GoToState("idle")
				end
            end),
            TimeEvent(40 * FRAMES, function(inst)
				inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(48 * FRAMES, function(inst)
				if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
					inst.AnimState:Show("ARM_carry")
					inst.AnimState:Hide("ARM_normal")
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
			if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
				inst.sg.statemem.stafffx:Remove()
			end
			if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
				inst.sg.statemem.stafflight:Remove()
			end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
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
						inst.sg:GoToState("pocketwatch_warpback", inst.sg.statemem) -- 'warpback' is set by the action function
					else
	                    inst.sg:GoToState("idle")
					end
                end
            end),
        },
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

					inst.sg.statemem.portaljumping = true
					local warpback_data = inst.sg.statemem.warpback_data
					local dest_worldid = warpback_data.dest_worldid
					if dest_worldid ~= nil and dest_worldid ~= TheShard:GetShardId() then
						if Shard_IsWorldAvailable(dest_worldid) then
							TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = inst, portalid = nil, worldid = dest_worldid, x = warpback_data.dest_x, y = warpback_data.dest_y, z = warpback_data.dest_z })
						else
							warpback_data.dest_x, warpback_data.dest_y, warpback_data.dest_z = inst.Transform:GetWorldPosition()
							inst.sg:GoToState("pocketwatch_warpback_pst", inst.sg.statemem)
						end
					else
						inst.sg:GoToState("pocketwatch_warpback_pst", inst.sg.statemem)
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
            inst.sg:SetTimeout(8 * FRAMES)

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
                inst.sg:RemoveStateTag("noattack")
                inst.SoundEmitter:PlaySound("dontstarve/movement/bodyfall_dirt")
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
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
            TimeEvent(8 * FRAMES, function(inst)
				inst.AnimState:Show("ARM_normal")
			end),
            TimeEvent(18 * FRAMES, function(inst)
				if not inst:PerformBufferedAction() then
					inst.sg.statemem.action_failed = true
					inst.AnimState:Hide("gemshard")
	                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
				else
	                inst.SoundEmitter:PlaySound("turnoftides/common/together/moon_glass/mine")
                end
            end),
            TimeEvent(14 * FRAMES, function(inst)
                if inst.sg.statemem.castsound then
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
		            inst.AnimState:PlayAnimation("useitem_pst", false)
					if not inst.sg.statemem.action_failed then
						local line = inst.sg.statemem.same_shard and "ANNOUNCE_POCKETWATCH_OPEN_PORTAL" or "ANNOUNCE_POCKETWATCH_OPEN_PORTAL_DIFFERENTSHARD"
						inst:DoTaskInTime(6 * FRAMES, function() inst.components.talker:Say(GetString(inst, line)) end)
					end
					inst.sg:GoToState("idle", true)
                end
            end),
        },

        onexit = function(inst)
			if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
				inst.AnimState:Show("ARM_carry")
				inst.AnimState:Hide("ARM_normal")
			end
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

        onenter = function(inst, dest)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpin")
            local x, y, z = inst.Transform:GetWorldPosition()
            SpawnPrefab("wortox_portal_jumpin_fx").Transform:SetPosition(x, y, z)
            inst.sg:SetTimeout(11 * FRAMES)
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
            inst.sg:GoToState("portal_jumpout", inst.sg.statemem.dest)
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

        onenter = function(inst, dest)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wortox_portal_jumpout")
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

    State{
        name = "form_log",
        tags = { "doing", "busy", "nocraftinginterrupt", "nomorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("form_log_pre")
            inst.AnimState:PushAnimation("form_log", false)
            inst.sg.statemem.action = inst.bufferedaction
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/living_log_craft") end),
            TimeEvent(50 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(58 * FRAMES, function(inst)
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
            if inst.bufferedaction == inst.sg.statemem.action and
            (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
                inst:ClearBufferedAction()
            end
        end,
    },

    State{
        name = "fertilize",
        tags = { "doing", "busy", "nomorph", "self_fertilizing" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fertilize_pre")
            inst.AnimState:PushAnimation("fertilize", false)
        end,

        timeline =
        {
            TimeEvent(27 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/characters/wormwood/fertalize_LP", "rub")
                inst.SoundEmitter:SetParameter("rub", "start", math.random())
            end),
            TimeEvent(82 * FRAMES, function(inst)
                inst.SoundEmitter:KillSound("rub")
            end),
            TimeEvent(88 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(90 * FRAMES, function(inst)
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
            inst.SoundEmitter:KillSound("rub")
        end,
    },

    State{
        name = "fertilize_short",
        tags = { "doing", "busy", "nomorph", "self_fertilizing" },

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
        end,
    },

    --------------------------------------------------------------------------
    -- Wigfrid

    State{
        name = "sing_pre",
        tags = { "busy", "nointerrupt" },

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
                            inst.sg:GoToState("idle")
                        elseif singinginspiration:CanAddSong(songdata) then
                            inst.sg:GoToState("sing")
                        else
                            inst.sg:GoToState("cantsing")
                        end
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    },

    State{
        name = "sing_fail",
        tags = { "busy" },

        onenter = function(inst)
            inst:PerformBufferedAction()

            inst.sg:GoToState("idle")
            inst.components.talker:Say(GetActionFailString(inst, "SING_FAIL", "SAMESONG"))
        end,
    },

    State{
        name = "sing",
        tags = { "busy", "nointerrupt" },

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
        name = "cantsing",
        tags = {},

        onenter = function(inst)
            inst:ClearBufferedAction()

            inst.components.talker:Say(GetString(inst, "ANNOUNCE_NOINSPIRATION"), nil, true)

            inst.AnimState:PlayAnimation("sing_fail", false)

            inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/fail")
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
                inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_down", nil, nil, true)
                inst:PerformBufferedAction()
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.sg.statemem.stopfurling then
                    inst.sg:GoToState("idle")
                else
                    inst.sg.statemem.not_interrupted = true
                    inst.sg:GoToState("furl", inst.sg.mem.furl_target)          -- _repeat_delay
                end
            end),

            EventHandler("stopfurling", function(inst)
                inst.sg.statemem.stopfurling = true
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
                inst:RemoveTag("switchtoho")
				if inst.sg.mem.furl_target:IsValid() then
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
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
            end),
            TimeEvent((15+17) * FRAMES, function(inst)
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
            end),
            TimeEvent((15+(2*17)) * FRAMES, function(inst)
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
            end),
            TimeEvent((15+(3*17)) * FRAMES, function(inst)
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
            end),
            TimeEvent((15+(4*17)) * FRAMES, function(inst)
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
            end),
            TimeEvent((15+(5*17)) * FRAMES, function(inst)
                 inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/mast/sail_up", nil, nil, true)
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
                if inst.sg.mem.furl_target:IsValid() and inst.sg.mem.furl_target.components.mast then
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
			if inst.sg.mem.furl_target:IsValid() then
	            inst.sg.mem.furl_target.components.mast:AddSailFurler(inst, 0)
			end

            local fail_str = GetActionFailString(inst, "LOWER_SAIL_FAIL")
            inst.components.talker:Say(fail_str)

            inst:RemoveTag("is_heaving")

            inst.AnimState:PlayAnimation("pull_fail")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.not_interrupted then
				if inst.sg.mem.furl_target:IsValid() then
	                inst.sg.mem.furl_target.components.mast:RemoveSailFurler(inst)
				end
                inst:RemoveTag("is_furling")
                inst:RemoveTag("is_heaving")
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg.statemem.not_interrupted = true
                inst.sg:GoToState("furl", inst.sg.mem.furl_target)
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
        tags = { "busy", "nopredict", "nomorph", "nointerrupt" },

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
                inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES or
                inst.AnimState:GetCurrentAnimationLength() * math.random()
            )
        end,

        timeline =
        {
            TimeEvent(1 * FRAMES, PlayMooseFootstep),
            TimeEvent(4 * FRAMES, PlayMooseFootstep),
            TimeEvent(10 * FRAMES, PlayMooseFootstep),
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

        ontimeout = function(inst)
            if inst.sg.statemem.loop > 0 then
                inst.sg.statemem.tackling = true
                inst.sg:GoToState("tackle", {
                    targets = inst.sg.statemem.targets,
                    edgecount = inst.sg.statemem.edgecount,
                    trail = inst.sg.statemem.trailtask,
                    loop = inst.sg.statemem.loop - 1,
                })
            else
                inst.sg.statemem.stopping = true
                inst.sg:GoToState("tackle_stop")
            end
        end,

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
        tags = { "busy", "doing", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("upgrade")
            inst.SoundEmitter:PlaySound("WX_rework/module/insert")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        timeline =
        {
            TimeEvent(33*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(45*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
        },
    },

    State{
        name = "applyupgrademodule_fail",
        tags = { "busy" },

        onenter = function(inst)
            inst:PerformBufferedAction()

            inst.sg:GoToState("idle")
            inst.components.talker:Say(GetActionFailString(inst, "APPLYMODULE", "NOTENOUGHSLOTS"))
        end,
    },

    State {
        name = "removeupgrademodules",
        tags = { "busy", "doing", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("useitem_pre")
            inst.AnimState:PushAnimation("downgrade", false)
            inst.AnimState:PushAnimation("useitem_pst", false)
            inst.SoundEmitter:PlaySound("WX_rework/module/remove")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle", true)
                end
            end),
        },

        timeline =
        {
            TimeEvent(8*FRAMES, function(inst) -- length of "useitem_pre"
				inst.AnimState:Show("ARM_normal")
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
            TimeEvent(38*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("nointerrupt")
            end),
            TimeEvent(48*FRAMES, function(inst) -- length of "downgrade" + length of "useitem_pre"
                if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                    inst.AnimState:Show("ARM_carry")
                    inst.AnimState:Hide("ARM_normal")
                end
            end),
        },

        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,
    },

    State{
        name = "removeupgrademodules_fail",
        tags = { "busy" },

        onenter = function(inst)
            inst:PerformBufferedAction()

            inst.sg:GoToState("idle")
            inst.components.talker:Say(GetActionFailString(inst, "REMOVEMODULES", "NO_MODULES"))
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
