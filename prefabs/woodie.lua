local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/woodie.fsb"),

    Asset("ANIM", "anim/werebeaver_build.zip"),
    Asset("ANIM", "anim/werebeaver_basic.zip"),
    Asset("ANIM", "anim/werebeaver_groggy.zip"),
    Asset("ANIM", "anim/werebeaver_dance.zip"),
    Asset("ANIM", "anim/player_revive_to_werebeaver.zip"),
    Asset("ANIM", "anim/player_amulet_resurrect_werebeaver.zip"),
    Asset("ANIM", "anim/player_rebirth_werebeaver.zip"),
    Asset("ANIM", "anim/player_woodie.zip"),
    Asset("ATLAS", "images/woodie.xml"),
    Asset("IMAGE", "images/woodie.tex"),
    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),

    Asset("ANIM", "anim/ghost_werebeaver_build.zip"),
}

local prefabs =
{
    "shovel_dirt",
    "werebeaver_transform_fx",
}

local start_inv =
{
    default =
    {
        "lucy",
    },
}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WOODIE
end

prefabs = FlattenTree({ prefabs, start_inv }, true)

local BEAVERVISION_COLOURCUBES =
{
    day = "images/colour_cubes/beaver_vision_cc.tex",
    dusk = "images/colour_cubes/beaver_vision_cc.tex",
    night = "images/colour_cubes/beaver_vision_cc.tex",
    full_moon = "images/colour_cubes/beaver_vision_cc.tex",
}

--------------------------------------------------------------------------

local function BeaverGetStatus(inst, viewer)
    return inst:HasTag("playerghost") and "BEAVERGHOST" or "BEAVER"
end

--------------------------------------------------------------------------

local BEAVER_DIET =
{
    FOODTYPE.WOOD,
    FOODTYPE.ROUGHAGE,
}

local BEAVER_LMB_ACTIONS =
{
    "CHOP",
    "MINE",
    "DIG",
}

local BEAVER_ACTION_TAGS = {}

for i, v in ipairs(BEAVER_LMB_ACTIONS) do
    table.insert(BEAVER_ACTION_TAGS, v.."_workable")
end

local BEAVER_TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "catchable", "sign" }

local function CannotExamine(inst)
    return false
end

local function BeaverActionString(inst, action)
    return (action.action == ACTIONS.EAT and STRINGS.ACTIONS.EAT)
        or STRINGS.ACTIONS.GNAW
end

local function GetBeaverAction(target)
    for i, v in ipairs(BEAVER_LMB_ACTIONS) do
        if target:HasTag(v.."_workable") then
            return not target:HasTag("sign") and ACTIONS[v] or nil
        end
    end
end

local function BeaverActionButton(inst, force_target)
    if not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, inst.components.playercontroller.directwalking and 3 or 6, nil, BEAVER_TARGET_EXCLUDE_TAGS, BEAVER_ACTION_TAGS)
            for i, v in ipairs(ents) do
                if v ~= inst and v.entity:IsVisible() and CanEntitySeeTarget(inst, v) then
                    local action = GetBeaverAction(v)
                    if action ~= nil then
                        return BufferedAction(inst, v, action)
                    end
                end
            end
        elseif inst:GetDistanceSqToInst(force_target) <= (inst.components.playercontroller.directwalking and 9 or 36) then
            local action = GetBeaverAction(force_target)
            if action ~= nil then
                return BufferedAction(inst, force_target, action)
            end
        end
    end
end

local function LeftClickPicker(inst, target)
    if target ~= nil and target ~= inst then
        if inst.replica.combat:CanTarget(target) then
            return (not target:HasTag("player") or inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK))
                and inst.components.playeractionpicker:SortActionList({ ACTIONS.ATTACK }, target, nil)
                or nil
        end
        for i, v in ipairs(BEAVER_LMB_ACTIONS) do
            if target:HasTag(v.."_workable") then
                return not target:HasTag("sign")
                    and inst.components.playeractionpicker:SortActionList({ ACTIONS[v] }, target, nil)
                    or nil
            end
        end
    end
end

local function RightClickPicker(inst, target)
    if target ~= nil and target ~= inst then
        for i, v in ipairs(BEAVER_DIET) do
            if target:HasTag("edible_"..v) then
                return inst.components.playeractionpicker:SortActionList({ ACTIONS.EAT }, target, nil)
            end
        end
        return (target:HasTag("HAMMER_workable") and
                inst.components.playeractionpicker:SortActionList({ ACTIONS.HAMMER }, target, nil))
            or (target:HasTag("DIG_workable") and
                target:HasTag("sign") and
                inst.components.playeractionpicker:SortActionList({ ACTIONS.DIG }, target, nil))
            or nil
    end
end

local function SetBeaverActions(inst, enable)
    if enable then
        inst.ActionStringOverride = BeaverActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = BeaverActionButton
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
            inst.components.playeractionpicker.rightclickoverride = RightClickPicker
        end
    else
        inst.ActionStringOverride = nil
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = nil
            inst.components.playeractionpicker.rightclickoverride = nil
        end
    end
end

local function SetBeaverVision(inst, enable)
    if enable then
        inst.components.playervision:ForceNightVision(true)
        inst.components.playervision:SetCustomCCTable(BEAVERVISION_COLOURCUBES)
    else
        inst.components.playervision:ForceNightVision(false)
        inst.components.playervision:SetCustomCCTable(nil)
    end
end

local function SetBeaverMode(inst, isbeaver)
    if isbeaver then
        TheWorld:PushEvent("enabledynamicmusic", false)
        if not TheFocalPoint.SoundEmitter:PlayingSound("beavermusic") then
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/music/music_hoedown", "beavermusic")
        end

        inst.HUD.controls.status:SetBeaverMode(true)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Show()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = CannotExamine
            SetBeaverActions(inst, true)
            SetBeaverVision(inst, true)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.1
            end
        end
    else
        TheWorld:PushEvent("enabledynamicmusic", true)
        TheFocalPoint.SoundEmitter:KillSound("beavermusic")

        inst.HUD.controls.status:SetBeaverMode(false)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Hide()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = inst.isbeavermode:value() and CannotExamine or nil
            SetBeaverActions(inst, false)
            SetBeaverVision(inst, false)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
            end
        end
    end
end

local function SetGhostMode(inst, isghost)
    if isghost then
        SetBeaverMode(inst, false)
        inst._SetGhostMode(inst, true)
    else
        inst._SetGhostMode(inst, false)
        SetBeaverMode(inst, inst.isbeavermode:value())
    end
end

local function OnBeaverModeDirty(inst)
    if inst.HUD ~= nil and not inst:HasTag("playerghost") then
        SetBeaverMode(inst, inst.isbeavermode:value())
    end
end

local function OnPlayerDeactivated(inst)
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    if not TheWorld.ismastersim then
        inst:RemoveEventCallback("isbeavermodedirty", OnBeaverModeDirty)
    end
    TheFocalPoint.SoundEmitter:KillSound("beavermusic")
end

local function OnPlayerActivated(inst)
    if inst.HUD.beaverOL == nil then
        inst.HUD.beaverOL = inst.HUD.overlayroot:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
        inst.HUD.beaverOL:SetVRegPoint(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetHRegPoint(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetVAnchor(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetHAnchor(ANCHOR_MIDDLE)
        inst.HUD.beaverOL:SetScaleMode(SCALEMODE_FILLSCREEN)
        inst.HUD.beaverOL:SetClickable(false)
    end
    inst:ListenForEvent("onremove", OnPlayerDeactivated)
    if not TheWorld.ismastersim then
        inst:ListenForEvent("isbeavermodedirty", OnBeaverModeDirty)
    end
    OnBeaverModeDirty(inst)
end

--------------------------------------------------------------------------

local function GetBeaverness(inst)
    if inst.components.beaverness ~= nil then
        return inst.components.beaverness:GetPercent()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentbeaverness:value() * .01
    else
        return 1
    end
end

local function IsBeaverStarving(inst)
    if inst.components.beaverness ~= nil then
        return inst.components.beaverness:IsStarving()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentbeaverness:value() <= 0
    else
        return false
    end
end

local function CanShaveTest(inst)
    return false, "REFUSE"
end

local function OnResetBeard(inst)
    inst.components.beard.bits = inst.isbeavermode:value() and 0 or 3
end

local function beaversanityfn()--inst, dt)
    return TUNING.BEAVER_SANITY_PENALTY
end

local function beaverbonusdamagefn(inst, target, damage, weapon)
    return (target:HasTag("tree") or target:HasTag("beaverchewable")) and TUNING.BEAVER_WOOD_DAMAGE or 0
end

--------------------------------------------------------------------------

local function IsLucy(item)
    return item.prefab == "lucy"
end

local function onworked(inst, data)
    if data.target ~= nil and data.target.components.workable ~= nil then
        if inst.isbeavermode:value() then
            inst.components.beaverness:DoDelta(TUNING.BEAVER_GNAW_GAIN, true)
        elseif data.target.components.workable.action == ACTIONS.CHOP then
            inst.components.beaverness:DoDelta(TUNING.WOODIE_CHOP_DRAIN, true)

            local equipitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipitem ~= nil and (equipitem.prefab == "axe" or equipitem.prefab == "goldenaxe") then
                local itemuses = equipitem.components.finiteuses ~= nil and equipitem.components.finiteuses:GetUses() or nil
                if itemuses == nil or itemuses > 0 then
                    --Don't make Lucy if we already have one
                    if inst.components.inventory:FindItem(IsLucy) == nil then
                        local lucy = SpawnPrefab("lucy")
                        lucy.components.possessedaxe.revert_prefab = equipitem.prefab
                        lucy.components.possessedaxe.revert_uses = itemuses
                        equipitem:Remove()
                        inst.components.inventory:Equip(lucy)
                        if lucy.components.possessedaxe.transform_fx ~= nil then
                            local fx = SpawnPrefab(lucy.components.possessedaxe.transform_fx)
                            if fx ~= nil then
                                fx.entity:AddFollower()
                                fx.Follower:FollowSymbol(inst.GUID, "swap_object", 50, -25, 0)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function ondeployitem(inst, data)
    if data.prefab == "pinecone" or data.prefab == "acorn" or data.prefab == "twiggy_nut" then
        --inst.components.beaverness:DoDelta(TUNING.WOODIE_PLANT_TREE_GAIN)
        inst.components.sanity:DoDelta(TUNING.SANITY_TINY)
    end
end

local function OnIsFullmoon(inst, isfullmoon)
    if isfullmoon then
        if inst.components.beaverness:GetPercent() > .25 then
            inst.components.beaverness:SetPercent(.25)
        end
        inst.components.beaverness:SetTimeEffectMultiplier(TUNING.BEAVER_FULLMOON_DRAIN_MULTIPLIER)
    else
        inst.components.beaverness:SetTimeEffectMultiplier(1)
    end
end

local function onbeavernesschange(inst)
    if inst.sg:HasStateTag("nomorph") or
        inst.sg:HasStateTag("silentmorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead() or
        not inst.entity:IsVisible() then
        return
    end

    if inst.isbeavermode:value() then
        if inst.components.beaverness:GetPercent() > TUNING.WOODIE_TRANSFORM_TO_HUMAN then
            inst:PushEvent("transform_person")
        end
    elseif inst.components.beaverness:GetPercent() <= TUNING.WOODIE_TRANSFORM_TO_BEAVER then
        inst:PushEvent("transform_werebeaver")
    end
end

local function onnewstate(inst)
    if inst._wasnomorph ~= (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")) then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onbeavernesschange(inst)
        end
    end
end

--------------------------------------------------------------------------

local function SetBeaverWorker(inst, enable)
    if enable then
        if inst.components.worker == nil then
            inst:AddComponent("worker")
            inst.components.worker:SetAction(ACTIONS.CHOP, 4)
            inst.components.worker:SetAction(ACTIONS.MINE, .334)
            inst.components.worker:SetAction(ACTIONS.DIG, .334)
            inst.components.worker:SetAction(ACTIONS.HAMMER, .25)
        end
    elseif inst.components.worker ~= nil then
        inst:RemoveComponent("worker")
    end
end

local function SetBeaverSounds(inst, enable)
    if enable then
        inst.hurtsoundoverride = "dontstarve/characters/woodie/hurt_beaver"
    else
        inst.hurtsoundoverride = nil
    end
end

--------------------------------------------------------------------------

local function onbecamehuman(inst)
    if inst.prefab ~= nil and not inst.sg:HasStateTag("ghostbuild") then
        inst.AnimState:SetBank("wilson")
        inst.components.skinner:SetSkinMode("normal_skin")
    end

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat.bonusdamagefn = nil
    inst.components.health:SetAbsorptionAmount(0)
    inst.components.sanity.custom_rate_fn = nil
    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet({ FOODGROUP.WOODIE }, { FOODGROUP.WOODIE })
        inst.components.eater:SetAbsorptionModifiers(1,1,1)
    end
    inst.components.pinnable.canbepinned = true
    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:Resume()
    end
    inst.components.temperature.inherentinsulation = 0
    inst.components.temperature.inherentsummerinsulation = 0
    inst.components.moisture:SetInherentWaterproofness(0)
    inst.components.talker:StopIgnoringAll("becamebeaver")
    inst.components.catcher:SetEnabled(true)
    inst.components.debuffable:SetFollowSymbol("headbase", 0, -200, 0)
    inst.components.stormwatcher:SetSandstormSpeedMultiplier(TUNING.SANDSTORM_SPEED_MOD)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(TUNING.CAREFUL_SPEED_MOD)

    if inst.components.inspectable.getstatus == BeaverGetStatus then
        inst.components.inspectable.getstatus = inst._getstatus
        inst._getstatus = nil
    end

    inst.CanExamine = nil

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(true)
    end

    SetBeaverWorker(inst, false)
    SetBeaverActions(inst, false)
    SetBeaverSounds(inst, false)
    SetBeaverVision(inst, false)

    if inst.isbeavermode:value() then
        inst:RemoveTag("beaver")
        inst.Network:RemoveUserFlag(USERFLAGS.CHARACTER_STATE_1)
        inst.isbeavermode:set(false)
        inst.overrideskinmode = nil
        inst.overrideghostskinmode = nil
        inst:PushEvent("stopbeaver")
        OnBeaverModeDirty(inst)
    end

    OnResetBeard(inst)
end

local function onbecamebeaver(inst)
    if not inst.sg:HasStateTag("ghostbuild") then
        inst.components.skinner:HideAllClothing(inst.AnimState)
        inst.AnimState:SetBank("werebeaver")
        inst.components.skinner:SetSkinMode("werebeaver_skin")
    end

    inst.hurtsoundoverride = "dontstarve/characters/woodie/hurt_beaver"

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED * 1.1
    inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)
    inst.components.combat.bonusdamagefn = beaverbonusdamagefn
    inst.components.health:SetAbsorptionAmount(TUNING.BEAVER_ABSORPTION)
    inst.components.sanity.custom_rate_fn = beaversanityfn
    if inst.components.eater ~= nil then
        inst.components.eater:SetDiet(BEAVER_DIET, BEAVER_DIET)
        inst.components.eater:SetAbsorptionModifiers(0,0,0)
    end
    inst.components.pinnable.canbepinned = false
    inst.components.hunger:Pause()
    inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
    inst.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_LARGE)
    inst.components.talker:IgnoreAll("becamebeaver")
    inst.components.catcher:SetEnabled(false)
    inst.components.debuffable:SetFollowSymbol("torso", 0, -280, 0)
    inst.components.stormwatcher:SetSandstormSpeedMultiplier(1)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(1)

    if inst.components.inspectable.getstatus ~= BeaverGetStatus then
        inst._getstatus = inst.components.inspectable.getstatus
        inst.components.inspectable.getstatus = BeaverGetStatus
    end

    inst.CanExamine = CannotExamine

    if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(false)
    end

    SetBeaverWorker(inst, true)
    SetBeaverActions(inst, true)
    SetBeaverSounds(inst, true)
    SetBeaverVision(inst, true)

    if not inst.isbeavermode:value() then
        inst:AddTag("beaver")
        inst.Network:AddUserFlag(USERFLAGS.CHARACTER_STATE_1)
        inst.isbeavermode:set(true)
        inst.overrideskinmode = "werebeaver_skin"
        inst.overrideghostskinmode = "ghost_werebeaver_skin"
        inst:PushEvent("startbeaver")
        OnBeaverModeDirty(inst)
    end

    OnResetBeard(inst)
end

local function onrespawnedfromghost(inst)
    inst.components.beaverness:StartTimeEffect(1, -.75 * inst.components.beaverness.max / TUNING.BEAVER_DRAIN_TIME)

    if inst._wasnomorph == nil then
        inst._wasnomorph = inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")
        inst:ListenForEvent("working", onworked)
        inst:ListenForEvent("deployitem", ondeployitem)
        inst:ListenForEvent("beavernessdelta", onbeavernesschange)
        inst:ListenForEvent("newstate", onnewstate)
        inst:WatchWorldState("isfullmoon", OnIsFullmoon)
    end

    if inst.isbeavermode:value() then
        inst.components.inventory:Close()
        onbecamebeaver(inst)
    else
        onbecamehuman(inst)
    end

    OnIsFullmoon(inst, TheWorld.state.isfullmoon)
end

local function onbecameghost(inst, data)
    if inst.isbeavermode:value() and not (data ~= nil and data.corpse) then
        inst.components.skinner:SetSkinMode("ghost_werebeaver_skin")
    end

    inst.components.beaverness:StopTimeEffect()
    if inst.components.beaverness:GetPercent() < TUNING.WOODIE_TRANSFORM_TO_BEAVER then
        inst.components.beaverness:SetPercent(TUNING.WOODIE_TRANSFORM_TO_BEAVER)
    end

    if inst._wasnomorph ~= nil then
        inst._wasnomorph = nil
        inst:RemoveEventCallback("working", onworked)
        inst:RemoveEventCallback("deployitem", ondeployitem)
        inst:RemoveEventCallback("beavernessdelta", onbeavernesschange)
        inst:RemoveEventCallback("newstate", onnewstate)
        inst:StopWatchingWorldState("isfullmoon", OnIsFullmoon)
    end

    SetBeaverWorker(inst, false)
    SetBeaverActions(inst, false)
    SetBeaverSounds(inst, false)
    SetBeaverVision(inst, false)
end

local function TransformBeaver(inst, isbeaver)
    if isbeaver then
        onbecamebeaver(inst)
    else
        onbecamehuman(inst)
    end
end

--------------------------------------------------------------------------

--Re-enter idle state right after loading because
--idle animations are determined by beaver state.
local function onentityreplicated(inst)
    if inst.sg ~= nil and inst:HasTag("beaver") then
        inst.sg:GoToState("idle")
    end
end

local function onpreload(inst, data)
    if data ~= nil and data.isbeaver then
        onbecamebeaver(inst)
        inst.sg:GoToState("idle")
    end
end

local function onload(inst)
    if inst.isbeavermode:value() and not inst:HasTag("playerghost") then
        inst.components.inventory:Close()
    end
end

local function onsave(inst, data)
    data.isbeaver = inst.isbeavermode:value() or nil
end

--------------------------------------------------------------------------

local TALLER_FROSTYBREATHER_OFFSET = Vector3(.3, 3.75, 0)
local BEAVER_FROSTYBREATHER_OFFSET = Vector3(1.2, 2.15, 0)
local DEFAULT_FROSTYBREATHER_OFFSET = Vector3(.3, 1.15, 0)
local function GetFrostyBreatherOffset(inst)
    local rider = inst.replica.rider
    return (rider ~= nil and rider:IsRiding() and TALLER_FROSTYBREATHER_OFFSET)
        or (inst.isbeavermode:value() and BEAVER_FROSTYBREATHER_OFFSET)
        or DEFAULT_FROSTYBREATHER_OFFSET
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("woodcutter")
    inst:AddTag("polite")

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")

    if TheNet:GetServerGameMode() == "lavaarena" then
        --do nothing
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    else
        --beaverness (from beaverness component) added to pristine state for optimization
        inst:AddTag("beaverness")

        inst.GetBeaverness = GetBeaverness -- Didn't want to make beaverness a networked component
        inst.IsBeaverStarving = IsBeaverStarving -- Didn't want to make beaverness a networked component

        inst.isbeavermode = net_bool(inst.GUID, "woodie.isbeavermode", "isbeavermodedirty")
        inst:ListenForEvent("playeractivated", OnPlayerActivated)
        inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

        if inst.ghostenabled then
            inst._SetGhostMode = inst.SetGhostMode
            inst.SetGhostMode = SetGhostMode
        end
    end

    inst.components.frostybreather:SetOffsetFn(GetFrostyBreatherOffset)

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = onentityreplicated
    end
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/woodie").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
		-- nothing to see here (dont go into the else case, or else!)
    else
        -- Give Woodie a beard so he gets some insulation from winter cold
        -- (Value is Wilson's level 2 beard.)
        inst:AddComponent("beard")
        inst.components.beard.canshavetest = CanShaveTest
        inst.components.beard.onreset = OnResetBeard
        inst.components.beard:EnableGrowth(false)

        OnResetBeard(inst)

        inst:AddComponent("beaverness")

        inst._getstatus = nil
        inst._wasnomorph = nil
        inst.TransformBeaver = TransformBeaver

        inst:ListenForEvent("ms_respawnedfromghost", onrespawnedfromghost)
        inst:ListenForEvent("ms_becameghost", onbecameghost)

        onrespawnedfromghost(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnPreLoad = onpreload
    end
end

return MakePlayerCharacter("woodie", prefabs, assets, common_postinit, master_postinit)
