local MakePlayerCharacter = require("prefabs/player_common")
local easing = require("easing")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/woodie.fsb"),

    --Asset("ANIM", "anim/werebeaver_basic.zip"), --Moved to global.lua for use in Item Collection
    Asset("ANIM", "anim/werebeaver_groggy.zip"),
    Asset("ANIM", "anim/werebeaver_dance.zip"),
    Asset("ANIM", "anim/werebeaver_boat_jump.zip"),
    Asset("ANIM", "anim/werebeaver_boat_plank.zip"),
    Asset("ANIM", "anim/werebeaver_boat_sink.zip"),
    --Asset("ANIM", "anim/weremoose_basic.zip"), --Moved to global.lua for use in Item Collection
    Asset("ANIM", "anim/weremoose_attacks.zip"),
    Asset("ANIM", "anim/weremoose_transform.zip"),
    Asset("ANIM", "anim/weremoose_groggy.zip"),
    Asset("ANIM", "anim/weremoose_dance.zip"),
    Asset("ANIM", "anim/weremoose_boat_jump.zip"),
    Asset("ANIM", "anim/weremoose_boat_plank.zip"),
    Asset("ANIM", "anim/weremoose_boat_sink.zip"),
    --Asset("ANIM", "anim/weregoose_basic.zip"), --Moved to global.lua for use in Item Collection
    Asset("ANIM", "anim/weregoose_groggy.zip"),
    Asset("ANIM", "anim/weregoose_dance.zip"),
    Asset("ANIM", "anim/weregoose_boat_jump.zip"),
    Asset("ANIM", "anim/weregoose_boat_plank.zip"),
    Asset("ANIM", "anim/weregoose_boat_sink.zip"),
    Asset("ANIM", "anim/weregoose_fx.zip"), --the fx uses werebeaver_build, so doesn't auto-generate dependency (needs this build for override symbol)
    Asset("ANIM", "anim/splash_weregoose_fx.zip"), --the fx uses splash_water_drop build, so doesn't auto-generate dependency (needs this bank)
    Asset("ANIM", "anim/player_revive_to_werebeaver.zip"),
    Asset("ANIM", "anim/player_revive_to_weremoose.zip"),
    Asset("ANIM", "anim/player_revive_to_weregoose.zip"),
    Asset("ANIM", "anim/player_amulet_resurrect_werebeaver.zip"),
    Asset("ANIM", "anim/player_amulet_resurrect_weremoose.zip"),
    Asset("ANIM", "anim/player_amulet_resurrect_weregoose.zip"),
    Asset("ANIM", "anim/player_rebirth_werebeaver.zip"),
    Asset("ANIM", "anim/player_rebirth_weremoose.zip"),
    Asset("ANIM", "anim/player_rebirth_weregoose.zip"),
    Asset("ANIM", "anim/player_woodie.zip"),
    Asset("ANIM", "anim/round_puff_fx.zip"),
    Asset("ANIM", "anim/player_idles_woodie.zip"),
    Asset("ANIM", "anim/player_actions_woodcarving.zip"),
    Asset("ANIM", "anim/player_mount_woodcarving.zip"),
    Asset("ATLAS", "images/woodie.xml"),
    Asset("IMAGE", "images/woodie.tex"),
    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),
    Asset("MINIMAP_IMAGE", "woodie_1"), --beaver
    Asset("MINIMAP_IMAGE", "woodie_2"), --moose
    Asset("MINIMAP_IMAGE", "woodie_3"), --goose
    Asset("SCRIPT", "scripts/prefabs/skilltree_woodie.lua"),
}

local prefabs =
{
    "shovel_dirt",
    "plant_dug_small_fx",
    "round_puff_fx_sm",
    "round_puff_fx_lg",
    "round_puff_fx_hi",
    --
    "werebeaver_transform_fx",
    "werebeaver_shock_fx",
    "werebeaver_groundpound_fx",
    --
    "weremoose_transform_fx",
    "weremoose_transform2_fx",
    "weremoose_revert_fx",
    "weremoose_shock_fx",
    "weremoose_smash_fx",
    --
    "weregoose_transform_fx",
    "weregoose_shock_fx",
    "weregoose_feathers1",
    "weregoose_feathers2",
    "weregoose_feathers3",
    "weregoose_splash",
    "weregoose_splash_med1",
    "weregoose_splash_med2",
    "weregoose_splash_less1",
    "weregoose_splash_less2",
    "weregoose_ripple1",
    "weregoose_ripple2",
    --
    "reticuleline2",
}

local start_inv = {}
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

local WEREMODE_NAMES =
{
    "beaver",
    "moose",
    "goose",
}

local WEREMODES = { NONE = 0 }
for i, v in ipairs(WEREMODE_NAMES) do
    WEREMODES[string.upper(v)] = i
end

local function IsWereMode(mode)
    return WEREMODE_NAMES[mode] ~= nil
end

--------------------------------------------------------------------------

local function GetWereStatus(inst)--, viewer)
    return inst:HasTag("playerghost")
        and (string.upper(WEREMODE_NAMES[inst.weremode:value()]).."GHOST")
        or string.upper(WEREMODE_NAMES[inst.weremode:value()])
end

--------------------------------------------------------------------------

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
    return (action.action == ACTIONS.MOUNT_PLANK and STRINGS.ACTIONS.MOUNT_PLANK)
        or (action.action == ACTIONS.ABANDON_SHIP and STRINGS.ACTIONS.ABANDON_SHIP)
        or (action.action == ACTIONS.USE_WEREFORM_SKILL and STRINGS.ACTIONS.USE_WEREFORM_SKILL.BEAVER)
        or STRINGS.ACTIONS.GNAW
        ,
        (action.action == ACTIONS.ABANDON_SHIP)
        or (action.action == ACTIONS.USE_WEREFORM_SKILL)
        or nil
end

local function GetBeaverAction(inst, target)
    for i, v in ipairs(BEAVER_LMB_ACTIONS) do
        if target:HasTag(v.."_workable") then
            return not target:HasTag("sign") and ACTIONS[v] or nil
        end
    end

    if target:HasTag("walkingplank") and target:HasTag("interactable") then
        return (inst:HasTag("on_walkable_plank") and ACTIONS.ABANDON_SHIP) or
                (target:HasTag("plank_extended") and ACTIONS.MOUNT_PLANK) or
                ACTIONS.EXTEND_PLANK
    end
end

local function BeaverActionButton(inst, force_target)
    if not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, inst.components.playercontroller.directwalking and 3 or 6, nil, BEAVER_TARGET_EXCLUDE_TAGS, BEAVER_ACTION_TAGS)
            for i, v in ipairs(ents) do
                if v ~= inst and v.entity:IsVisible() and CanEntitySeeTarget(inst, v) then
                    local action = GetBeaverAction(inst, v)
                    if action ~= nil then
                        return BufferedAction(inst, v, action)
                    end
                end
            end
        elseif inst:GetDistanceSqToInst(force_target) <= (inst.components.playercontroller.directwalking and 9 or 36) then
            local action = GetBeaverAction(inst, force_target)
            if action ~= nil then
                return BufferedAction(inst, force_target, action)
            end
        end
    end
end

local function BeaverLeftClickPicker(inst, target)
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

        if target:HasTag("walkingplank") and target:HasTag("interactable") and target:HasTag("plank_extended") then
            return inst.components.playeractionpicker:SortActionList({ ACTIONS.MOUNT_PLANK }, target, nil)
        end
    end
end

local function BeaverRightClickPicker(inst, target, pos)
    return target ~= nil
        and target ~= inst
        and (   (   inst:HasTag("on_walkable_plank") and
                    target:HasTag("walkingplank") and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.ABANDON_SHIP }, target, nil)
                ) or
                (   target:HasTag("HAMMER_workable") and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.HAMMER }, target, nil)
                ) or
                (   target:HasTag("DIG_workable") and
                    target:HasTag("sign") and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.DIG }, target, nil)
                )
            )
        or
        (   not inst.components.playercontroller.isclientcontrollerattached and
            inst.components.skilltreeupdater:HasSkillTag("beaver_epic") and
            inst.components.playeractionpicker:SortActionList({ ACTIONS.USE_WEREFORM_SKILL },target or pos, nil)
        )
end

local function BeaverAndGoosePointSpecialActions(inst, pos, useitem, right)
    return
        right and
        inst.components.playercontroller:IsEnabled() and
        (
            (inst:HasTag("beaver") and inst.components.skilltreeupdater:HasSkillTag("beaver_epic"))
            or
            (inst:HasTag("weregoose") and inst.components.skilltreeupdater:HasSkillTag("goose_epic"))
        )
        and { ACTIONS.USE_WEREFORM_SKILL } or {}
end

local function MooseLeftClickPicker(inst, target)
    return target ~= nil
        and target ~= inst
        and (   (   inst.replica.combat:CanTarget(target) and
                    (not target:HasTag("player") or inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK)) and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.ATTACK }, target, nil)
                )
                or
                (   target:HasTag("walkingplank") and
                    target:HasTag("interactable") and
                    target:HasTag("plank_extended") and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.MOUNT_PLANK }, target, nil)
                )
            )
        or nil
end

local function MooseRightClickPicker(inst, target, pos)
    return target ~= inst
        and (	(	target ~= nil and
                    target:HasTag("walkingplank") and
                    inst:HasTag("on_walkable_plank") and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.ABANDON_SHIP }, target, nil)
                )
                or
                (	not inst.components.playercontroller.isclientcontrollerattached and
                    inst.components.playeractionpicker:SortActionList({ ACTIONS.TACKLE }, target or pos, nil)
                )
            )
        or nil
end

local function MoosePointSpecialActions(inst, pos, useitem, right)
    return right and inst.components.playercontroller:IsEnabled() and { ACTIONS.TACKLE } or {}
end

local function GooseActionString(inst, action)
    return STRINGS.ACTIONS.USE_WEREFORM_SKILL.GOOSE, true
end

local function GooseRightClickPicker(inst, target, pos)
    return
        not inst.components.playercontroller.isclientcontrollerattached and
        inst.components.skilltreeupdater:HasSkillTag("goose_epic") and
        inst.components.playeractionpicker:SortActionList({ ACTIONS.USE_WEREFORM_SKILL }, target or pos, nil)
end

local function Empty()
end

local function ReticuleTargetFn(inst)
    return Vector3(inst.entity:LocalToWorldSpace(1.5, 0, 0))
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)

	if inst.components.reticule ~= nil then
		inst.components.reticule.ease = reticule.entity:IsVisible()
	end
end

local function EnableReticule(inst, enable)
    if enable then
        if inst.components.reticule == nil then
            inst:AddComponent("reticule")
            inst.components.reticule.reticuleprefab = "reticuleline2"
            inst.components.reticule.targetfn = ReticuleTargetFn
            inst.components.reticule.updatepositionfn = ReticuleUpdatePositionFn
            inst.components.reticule.ease = true
            if inst.components.playercontroller ~= nil and inst == ThePlayer then
                inst.components.playercontroller:RefreshReticule()
            end
        end
    elseif inst.components.reticule ~= nil then
        inst:RemoveComponent("reticule")
        if inst.components.playercontroller ~= nil and inst == ThePlayer then
            inst.components.playercontroller:RefreshReticule()
        end
    end
end

local function SetWereActions(inst, mode)
    if not IsWereMode(mode) then
        inst.ActionStringOverride = nil
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = nil
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = nil
            inst.components.playeractionpicker.rightclickoverride = nil
            inst.components.playeractionpicker.pointspecialactionsfn = nil
        end
        EnableReticule(inst, false)
    elseif mode == WEREMODES.BEAVER then
        inst.ActionStringOverride = BeaverActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = BeaverActionButton
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = BeaverLeftClickPicker
            inst.components.playeractionpicker.rightclickoverride = BeaverRightClickPicker
            inst.components.playeractionpicker.pointspecialactionsfn = BeaverAndGoosePointSpecialActions
        end
        EnableReticule(inst, false)
    elseif mode == WEREMODES.MOOSE then
        inst.ActionStringOverride = nil
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = Empty
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = MooseLeftClickPicker
            inst.components.playeractionpicker.rightclickoverride = MooseRightClickPicker
            inst.components.playeractionpicker.pointspecialactionsfn = MoosePointSpecialActions
        end
        EnableReticule(inst, true)
    else--if mode == WEREMODES.GOOSE then
        inst.ActionStringOverride = GooseActionString
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller.actionbuttonoverride = Empty
        end
        if inst.components.playeractionpicker ~= nil then
            inst.components.playeractionpicker.leftclickoverride = Empty
            inst.components.playeractionpicker.rightclickoverride = GooseRightClickPicker
            inst.components.playeractionpicker.pointspecialactionsfn = BeaverAndGoosePointSpecialActions
        end
        EnableReticule(inst, false)
    end
end

local function SetWereVision(inst, mode)
    if IsWereMode(mode) then
        inst.components.playervision:PushForcedNightVision(inst, 2, BEAVERVISION_COLOURCUBES, false)
    else
        inst.components.playervision:PopForcedNightVision(inst)
    end
end

local function SetWereMode(inst, mode, skiphudfx)
    if IsWereMode(mode) then
        TheWorld:PushEvent("enabledynamicmusic", false)
        if not TheFocalPoint.SoundEmitter:PlayingSound("beavermusic") then
            TheFocalPoint.SoundEmitter:PlaySound(
                (mode == WEREMODES.BEAVER and "dontstarve/music/music_hoedown") or
                (mode == WEREMODES.MOOSE and "dontstarve/music/music_hoedown_moose") or
                (--[[mode == WEREMODES.GOOSE and]] "dontstarve/music/music_hoedown_goose"),
                "beavermusic"
            )
        end

        inst.HUD.controls.status:SetWereMode(true, skiphudfx)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Show()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = CannotExamine
            SetWereActions(inst, mode)
            SetWereVision(inst, mode)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed =
                    (mode == WEREMODES.BEAVER and TUNING.BEAVER_RUN_SPEED) or
                    (mode == WEREMODES.MOOSE and TUNING.WEREMOOSE_RUN_SPEED) or
                    (--[[mode == WEREMODES.GOOSE and]] TUNING.WEREGOOSE_RUN_SPEED)
            end
        end
    else
        TheWorld:PushEvent("enabledynamicmusic", true)
        TheFocalPoint.SoundEmitter:KillSound("beavermusic")

        inst.HUD.controls.status:SetWereMode(false, skiphudfx)
        if inst.HUD.beaverOL ~= nil then
            inst.HUD.beaverOL:Hide()
        end

        if not TheWorld.ismastersim then
            inst.CanExamine = nil
            SetWereActions(inst, mode)
            SetWereVision(inst, mode)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
            end
        end
    end
end

local function SetGhostMode(inst, isghost)
    if isghost then
        SetWereMode(inst, WEREMODES.NONE, true)
        inst._SetGhostMode(inst, true)
    else
        inst._SetGhostMode(inst, false)
        SetWereMode(inst, inst.weremode:value(), true)
    end
end

local function OnWereModeDirty(inst)
    if inst.HUD ~= nil and not inst:HasTag("playerghost") then
        SetWereMode(inst, inst.weremode:value())
    end
end

local GOOSEFLYCAM_SETTINGS =
{
	UpdateFn = function(dt, params, parent, best_dist_sq)
		if parent.gooseflycamvec ~= nil then
			local x, y, z = parent.AnimState:GetSymbolPosition("torso")
			parent.gooseflycamvec.y = y + 1.5
			TheCamera:SetOffset(parent.gooseflycamvec)
		end
	end,
}

local function OnGooseFlyingDirty(inst)
    if not (ThePlayer ~= nil and inst == ThePlayer) then
        return
    end

    if inst._weregooseflying:value() and inst:HasTag("weregoose") then
        TheMixer:PushMix("flying")
		inst.gooseflycamvec = Vector3(0, 0, 0)
		TheFocalPoint.components.focalpoint:StartFocusSource(inst, "gooseflycam", nil, math.huge, math.huge, 99, GOOSEFLYCAM_SETTINGS)
    else
        TheMixer:PopMix("flying")
		TheFocalPoint.components.focalpoint:StopFocusSource(inst, "gooseflycam")
		inst.gooseflycamvec = nil
    end
end

local function SetGooseFlying(inst, bool)
    inst._weregooseflying:set(bool)
    OnGooseFlyingDirty(inst)
end

local function PushMooseSmashShake_CLIENT(inst)
	if ThePlayer ~= nil then
		local duration = .5
		local speed = .02
		local scale = .1
		local maxDist = 12

		local distSq = ThePlayer:GetDistanceSqToInst(inst)
		local k = math.max(0, math.min(1, distSq / (maxDist * maxDist)))
		scale = easing.outQuad(k, scale, -scale, 1)

		if scale > 0 then
			TheCamera:Shake(CAMERASHAKE.VERTICAL, duration, speed, scale)
		end
	end
end

local function OnWereMooseSmashShake(inst)
	--Ignore if we're predicting our own shakes
	if inst.sg == nil then
		PushMooseSmashShake_CLIENT(inst)
	end
end

local function PushMooseSmashShake_SERVER(inst)
	inst._weremoosesmashshake:push()
	PushMooseSmashShake_CLIENT(inst)
end

local function OnPlayerDeactivated(inst)
    inst:RemoveEventCallback("onremove", OnPlayerDeactivated)
    if not TheWorld.ismastersim then
        inst:RemoveEventCallback("weremodedirty", OnWereModeDirty)
        inst:RemoveEventCallback("weregooseflyingdirty", OnGooseFlyingDirty)
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
        inst:ListenForEvent("weremodedirty", OnWereModeDirty)
        inst:ListenForEvent("weregooseflyingdirty", OnGooseFlyingDirty)
    end
    OnGooseFlyingDirty(inst)
    OnWereModeDirty(inst)
end

--------------------------------------------------------------------------

--Deprecated
local function GetBeaverness(inst) return 1 end
local function IsBeaverStarving(inst) return false end
--

local function GetWereness(inst)
    if inst.components.wereness ~= nil then
        return inst.components.wereness:GetPercent()
    elseif inst.player_classified ~= nil then
        return inst.player_classified.currentwereness:value() * .01
    else
        return 0
    end
end

local function GetWerenessDrainRate(inst)
    if inst.components.wereness ~= nil then
        return inst.components.wereness.rate
    elseif inst.player_classified ~= nil then
        return inst.player_classified.werenessdrainrate:value() / -6.3
    else
        return 0
    end
end

local function CanShaveTest(inst)
    return false, "REFUSE"
end

local function OnResetBeard(inst)
    inst.components.beard.bits = IsWereMode(inst.weremode:value()) and 0 or 3
end

local function WereSanityFn()
    return TUNING.WERE_SANITY_PENALTY
end

local function beaverbonusdamagefn(inst, target, damage, weapon)
    return (target:HasTag("tree") or target:HasTag("beaverchewable")) and TUNING.BEAVER_WOOD_DAMAGE or 0
end

local function OnGooseRunningOver(inst, CalculateWerenessDrainRate)
    if inst._gooserunninglevel > 1 then
        inst._gooserunninglevel = inst._gooserunninglevel - 1
        inst._gooserunning = inst:DoTaskInTime(TUNING.WEREGOOSE_RUN_DRAIN_TIME_DURATION, OnGooseRunningOver, CalculateWerenessDrainRate)
    else
        inst._gooserunning = nil
        inst._gooserunninglevel = nil
    end
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.GOOSE, TheWorld.state.isfullmoon))
end

local function CalculateWerenessDrainRate(inst, mode, isfullmoon)
    local skill_level = inst.components.skilltreeupdater:CountSkillTag("weremeter")
    local skill_mod = skill_level > 0 and TUNING.SKILLS.WOODIE.WEREMETER[skill_level] or nil

    local isfastdecaying = nil

    local t = isfullmoon and TUNING.WERE_FULLMOON_DRAIN_TIME_MULTIPLIER or 1

    if mode == WEREMODES.BEAVER then
        t = t * TUNING.BEAVER_DRAIN_TIME
        if inst._beaverworkinglevel ~= nil then
            t = t * (inst._beaverworkinglevel > 1 and TUNING.BEAVER_WORKING_DRAIN_TIME_MULTIPLIER2 or TUNING.BEAVER_WORKING_DRAIN_TIME_MULTIPLIER1)
            isfastdecaying = inst._beaverworkinglevel <= 1
        end
    elseif mode == WEREMODES.MOOSE then
        t = t * TUNING.WEREMOOSE_DRAIN_TIME
        if inst._moosefightinglevel ~= nil then
            t = t * (inst._moosefightinglevel > 1 and TUNING.WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER2 or TUNING.WEREMOOSE_FIGHTING_DRAIN_TIME_MULTIPLIER1)
            isfastdecaying = inst._moosefightinglevel <= 1
        end
    else--if mode == WEREMODES.GOOSE then
        t = t * TUNING.WEREGOOSE_DRAIN_TIME
        if inst.sg:HasStateTag("moving") or inst.sg:HasStateTag("flying") then
            if inst._gooserunning ~= nil then
                inst._gooserunning:Cancel()
            end
            inst._gooserunning = inst:DoTaskInTime(TUNING.WEREGOOSE_RUN_DRAIN_TIME_DURATION, OnGooseRunningOver, CalculateWerenessDrainRate)
            inst._gooserunninglevel = 2
        end
        if inst._gooserunninglevel ~= nil then
            t = t * (inst._gooserunninglevel > 1 and TUNING.WEREGOOSE_RUN_DRAIN_TIME_MULTIPLIER2 or TUNING.WEREGOOSE_RUN_DRAIN_TIME_MULTIPLIER1)
            isfastdecaying = inst._gooserunninglevel <= 1
        end
    end

    if skill_mod ~= nil and (inst.sg:HasStateTag("moving") or isfastdecaying == false) then
        t = t * skill_mod
    end

    return -100 / t
end

--------------------------------------------------------------------------

local function IsLucy(item)
    return item.prefab == "lucy"
end

local function onworked(inst, data)
    if data.target ~= nil and
        data.target.components.workable ~= nil and
        data.target.components.workable.action == ACTIONS.CHOP then
        local equipitem = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipitem ~= nil and equipitem:HasTag("possessable_axe") then
            local itemuses = equipitem.components.finiteuses ~= nil and equipitem.components.finiteuses:GetUses() or nil
            if (itemuses == nil or itemuses > 0) and inst.components.inventory:FindItem(IsLucy) == nil then
                --Don't make Lucy if we already have one
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

local function OnIsFullmoon(inst, isfullmoon)
    local islunnaraligned = inst:HasTag("player_lunar_aligned")

    if not isfullmoon then
        inst.fullmoontriggered = nil
        if inst.components.wereness:GetWereMode() == "fullmoon" then
            inst.components.wereness:SetWereMode(nil)
            if not IsWereMode(inst.weremode:value()) then
                inst.components.wereness:SetPercent(0, true)
            end
        end
    elseif not inst.fullmoontriggered then
        local pct = inst.components.wereness:GetPercent()
        if pct > 0 then
            inst.components.wereness:SetPercent(1)
            
        elseif not islunnaraligned then
            inst.fullmoontriggered = true
            inst.components.wereness:SetWereMode("fullmoon")
            inst.components.wereness:SetPercent(1, true)
            inst.components.wereness:StartDraining()
        end
    end
    if IsWereMode(inst.weremode:value()) then
        inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, inst.weremode:value(), isfullmoon))
    end
end

--------------------------------------------------------------------------

local function SetWereDrowning(inst, mode)
    --V2C: drownable HACKS, using "false" to override "nil" load behaviour
    --     Please refactor drownable to use POST LOAD timing.
    if inst.components.drownable ~= nil then
        if mode == WEREMODES.GOOSE then
            if inst.components.drownable.enabled ~= false then
                inst.components.drownable.enabled = false
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.GROUND)
                inst.Physics:CollidesWith(COLLISION.OBSTACLES)
                inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        elseif inst.components.drownable.enabled == false then
            inst.components.drownable.enabled = true
            if not inst:HasTag("playerghost") then
                inst.Physics:ClearCollisionMask()
                inst.Physics:CollidesWith(COLLISION.WORLD)
                inst.Physics:CollidesWith(COLLISION.OBSTACLES)
                inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
                inst.Physics:CollidesWith(COLLISION.CHARACTERS)
                inst.Physics:CollidesWith(COLLISION.GIANTS)
                inst.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        end
    end
end

local function SetWereRunner(inst, mode)
    if mode == WEREMODES.GOOSE then
        if inst._gooserunning ~= nil then
            inst._gooserunning:Cancel()
        end
        inst._gooserunning = inst:DoTaskInTime(TUNING.WEREGOOSE_RUN_DRAIN_TIME_DURATION, OnGooseRunningOver, CalculateWerenessDrainRate)
        inst._gooserunninglevel = 2
        inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.GOOSE, TheWorld.state.isfullmoon))
    elseif inst._gooserunning ~= nil then
        inst._gooserunning:Cancel()
        inst._gooserunning = nil
        inst._gooserunninglevel = nil
    end
end

--------------------------------------------------------------------------

local function OnBeaverWorkingOver(inst)
    if inst._beaverworkinglevel > 1 then
        inst._beaverworkinglevel = inst._beaverworkinglevel - 1
        inst._beaverworking = inst:DoTaskInTime(TUNING.BEAVER_WORKING_DRAIN_TIME_DURATION, OnBeaverWorkingOver)
    else
        inst._beaverworking = nil
        inst._beaverworkinglevel = nil
    end
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.BEAVER, TheWorld.state.isfullmoon))
end

local function OnBeaverWorking(inst)
    if inst._beaverworking ~= nil then
        inst._beaverworking:Cancel()
    end
    inst._beaverworking = inst:DoTaskInTime(TUNING.BEAVER_WORKING_DRAIN_TIME_DURATION, OnBeaverWorkingOver)
    inst._beaverworkinglevel = 2
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.BEAVER, TheWorld.state.isfullmoon))
end

local function OnBeaverFighting(inst, data)
    if data ~= nil and data.target ~= nil then
        OnBeaverWorking(inst)
    end
end

local function OnBeaverOnMissOther(inst, data)
    if not inst.sg:HasStateTag("tailslapping") then
        OnBeaverFighting(inst, data)
    end
end

local function SetUpGroundPounder(inst)
    local num_rings = 3
	inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.numRings = num_rings
    inst.components.groundpounder.radiusStepDistance = 2.75
	inst.components.groundpounder.ringWidth = 1.5
    inst.components.groundpounder.damageRings = 1
    inst.components.groundpounder.destructionRings = num_rings
    inst.components.groundpounder.platformPushingRings = num_rings - 1
    inst.components.groundpounder.inventoryPushingRings = num_rings - 2
    inst.components.groundpounder.workefficiency = 7

    inst.components.groundpounder.groundpoundfx = "werebeaver_groundpound_fx"
end

local function SetWereWorker(inst, mode)
    inst:RemoveEventCallback("working", onworked)

    if mode == WEREMODES.BEAVER then
        if inst.components.skilltreeupdater:HasSkillTag("recoilimmune") then
            inst:AddTag("toughworker")
        end

        if inst.components.worker == nil then
            local modifiers = TUNING.SKILLS.WOODIE.BEAVER_WORK_MULTIPLIER

            local mine_buff = inst.components.skilltreeupdater:IsActivated("woodie_curse_beaver_1")
            local chop_buff = inst.components.skilltreeupdater:IsActivated("woodie_curse_beaver_2")

            inst:AddComponent("worker")
            inst.components.worker:SetAction(ACTIONS.CHOP,  4    * (chop_buff and modifiers.CHOP or 1))
            inst.components.worker:SetAction(ACTIONS.MINE,   .5  * (mine_buff and modifiers.MINE or 1))
            inst.components.worker:SetAction(ACTIONS.DIG,    .5)
            inst.components.worker:SetAction(ACTIONS.HAMMER, .25)
            inst:ListenForEvent("working", OnBeaverWorking)
            inst:ListenForEvent("onattackother", OnBeaverFighting)
            inst:ListenForEvent("onmissother", OnBeaverOnMissOther)
            OnBeaverWorking(inst)

            inst:AddComponent("groundpounder")
            inst:SetUpGroundPounder()
        end
    else
        if inst.components.worker ~= nil then
            inst:RemoveComponent("worker")
            inst:RemoveEventCallback("working", OnBeaverWorking)
            inst:RemoveEventCallback("onattackother", OnBeaverFighting)
            inst:RemoveEventCallback("onmissother", OnBeaverFighting)
            if inst._beaverworking ~= nil then
                inst._beaverworking:Cancel()
                inst._beaverworking = nil
                inst._beaverworkinglevel = nil
            end
        end

        inst:RemoveComponent("groundpounder")
        inst:RemoveTag("toughworker")

        if mode == WEREMODES.NONE and not inst:HasTag("playerghost") then
            inst:ListenForEvent("working", onworked)
        end
    end
end

--------------------------------------------------------------------------

local function OnMooseFightingOver(inst)
    if inst._moosefightinglevel > 1 then
        inst._moosefightinglevel = inst._moosefightinglevel - 1
        inst._moosefighting = inst:DoTaskInTime(TUNING.WEREMOOSE_FIGHTING_DRAIN_TIME_DURATION, OnMooseFightingOver)
    else
        inst._moosefighting = nil
        inst._moosefightinglevel = nil
    end
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.MOOSE, TheWorld.state.isfullmoon))
end

local function ResetMooseFightingLevel(inst)
    if inst._moosefighting ~= nil then
        inst._moosefighting:Cancel()
    end
    inst._moosefighting = inst:DoTaskInTime(TUNING.WEREMOOSE_FIGHTING_DRAIN_TIME_DURATION, OnMooseFightingOver)
    inst._moosefightinglevel = 2
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.MOOSE, TheWorld.state.isfullmoon))
end

local function OnMooseFighting(inst, data)
    if data ~= nil and (data.target ~= nil or data.attacker ~= nil) then
        ResetMooseFightingLevel(inst)
    end
end

local function OnDodgeAttack(inst)
    local fx = SpawnPrefab("weregoose_transform_fx")

    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx.Transform:SetScale(1.3, 1.3, 1.3)
end

local function SetWereFighter(inst, mode)
    inst:RemoveEventCallback("onattackother", OnMooseFighting)
    inst:RemoveEventCallback("onmissother", OnMooseFighting)
    inst:RemoveEventCallback("attacked", OnMooseFighting)
    inst:RemoveEventCallback("blocked", OnMooseFighting)

    if inst.components.attackdodger then
        inst:RemoveComponent("attackdodger")
    end

    local skilltreeupdater = inst.components.skilltreeupdater
    if mode == WEREMODES.MOOSE then
        inst:ListenForEvent("onattackother", OnMooseFighting)
        inst:ListenForEvent("onmissother", OnMooseFighting)
        inst:ListenForEvent("attacked", OnMooseFighting)
        inst:ListenForEvent("blocked", OnMooseFighting)
        ResetMooseFightingLevel(inst)

        local healthregen_skill = skilltreeupdater:IsActivated("woodie_curse_moose_2")
        local planardefense_skill = skilltreeupdater:IsActivated("woodie_curse_epic_moose")

        if healthregen_skill then
            local regendata = TUNING.SKILLS.WOODIE.MOOSE_HEALTH_REGEN
            inst.components.health:AddRegenSource(inst, regendata.amount, regendata.period, "weremoose_skill")
        end

        if planardefense_skill then
            inst.components.planardefense:AddBonus(inst, TUNING.SKILLS.WOODIE.MOOSE_PLANAR_DEF, "weremoose_skill")
        end

    elseif mode == WEREMODES.GOOSE then
        if skilltreeupdater:IsActivated("woodie_curse_goose_3") then
            inst:AddComponent("attackdodger")
            inst.components.attackdodger:SetCooldownTime(TUNING.SKILLS.WOODIE.GOOSE_DODGE_COOLDOWN_TIME)
            inst.components.attackdodger:SetOnDodgeFn(inst.OnDodgeAttack)
        end
    end

    if mode ~= WEREMODES.MOOSE then
        if inst._moosefighting ~= nil then
            inst._moosefighting:Cancel()
            inst._moosefighting = nil
            inst._moosefightinglevel = nil
        end

        inst.components.planardefense:RemoveBonus(inst, "weremoose_skill")
        inst.components.health:RemoveRegenSource(inst, "weremoose_skill")
    end
end

--------------------------------------------------------------------------

local GOOSE_FLAP_STATES =
{
    ["idle"] = true,
    ["run_start"] = true,
    ["run"] = true,
    ["weregoose_takeoff"] = true,
    --["run_stop"] = true,
}
local GOOSE_HONK_STATES =
{
    ["idle"] = true,
    ["run_start"] = true,
    ["run"] = true,
    ["run_stop"] = true,
    ["weregoose_takeoff"] = true,
}

local function DoRipple(inst)
    if inst.components.drownable ~= nil and inst.components.drownable:IsOverWater() then
        SpawnPrefab("weregoose_ripple"..tostring(math.random(2))).entity:SetParent(inst.entity)
    end
end

local function OnNewGooseState(inst, data)
    if not GOOSE_FLAP_STATES[data.statename] or (inst.components.grogginess ~= nil and inst.components.grogginess.isgroggy) then
        inst.SoundEmitter:KillSound("flap")
        if inst.gooserippletask == nil then
            inst.gooserippletask = inst:DoPeriodicTask(.7, DoRipple, FRAMES)
        end
    else
        if not inst.SoundEmitter:PlayingSound("flap") then
            inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/goose/flap", "flap")
        end
        if inst.gooserippletask ~= nil then
            inst.gooserippletask:Cancel()
            inst.gooserippletask = nil
        end
    end

    if not GOOSE_HONK_STATES[data.statename] then
        inst.SoundEmitter:KillSound("honk")
    elseif not inst.SoundEmitter:PlayingSound("honk") then
        inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/goose/honk_LP", "honk")
    end
end

local function GetGooseWaterproofness(inst)
    local waterproof_skill = inst.components.skilltreeupdater:IsActivated("woodie_curse_goose_2")

    return waterproof_skill and TUNING.WATERPROOFNESS_ABSOLUTE or TUNING.WATERPROOFNESS_LARGE
end

local function SetWereSounds(inst, mode)
    inst:RemoveEventCallback("newstate", OnNewGooseState)
    if mode == WEREMODES.GOOSE then
        inst:ListenForEvent("newstate", OnNewGooseState)
        OnNewGooseState(inst, { statename = inst.sg.currentstate.name })
        inst.hurtsoundoverride = "dontstarve/characters/woodie/goose/hurt"
        inst.deathsoundoverride = "dontstarve/characters/woodie/goose/death_voice"
    else
        inst.SoundEmitter:KillSound("flap")
        inst.SoundEmitter:KillSound("honk")
        if inst.gooserippletask ~= nil then
            inst.gooserippletask:Cancel()
            inst.gooserippletask = nil
        end
        inst.hurtsoundoverride =
            (mode == WEREMODES.BEAVER and "dontstarve/characters/woodie/hurt_beaver") or
            (mode == WEREMODES.MOOSE and "dontstarve/characters/woodie/moose/hurt") or
            nil
        inst.deathsoundoverride =
            (mode == WEREMODES.MOOSE and "dontstarve/characters/woodie/moose/death_voice") or
            nil
    end
end

--------------------------------------------------------------------------

local function ChangeWereModeValue(inst, newmode)
    if inst.weremode:value() ~= newmode then
        if IsWereMode(inst.weremode:value()) then
            if not IsWereMode(newmode) then
                inst:RemoveTag("wereplayer")
            end
            inst:RemoveTag(inst.weremode:value() == WEREMODES.BEAVER and "beaver" or ("were"..WEREMODE_NAMES[inst.weremode:value()]))
            inst.Network:RemoveUserFlag(USERFLAGS["CHARACTER_STATE_"..tostring(inst.weremode:value())])
        else
            inst:AddTag("wereplayer")
        end

        inst.weremode:set(newmode)

        if IsWereMode(newmode) then
            inst:AddTag(newmode == WEREMODES.BEAVER and "beaver" or ("were"..WEREMODE_NAMES[newmode]))
            inst.Network:AddUserFlag(USERFLAGS["CHARACTER_STATE_"..tostring(newmode)])
            inst.overrideskinmode = "were"..WEREMODE_NAMES[newmode].."_skin"
            inst.overrideghostskinmode = "ghost_"..inst.overrideskinmode
            inst:PushEvent("startwereplayer") --event for sentientaxe
        else
            inst.overrideskinmode = nil
            inst.overrideghostskinmode = nil
            inst:PushEvent("stopwereplayer") --event for sentientaxe
        end

        OnWereModeDirty(inst)
    end
end

--V2C: if the debuff symbol offsets change, then make sure you update the offsets
--     baked into the symbols inside headbase_comp for weremoose_transform anims.
local SKIN_MODE_DATA =
{
    ["normal_skin"] = {
        bank = "wilson",
        shadow = { 1.3, .6 },
        debuffsymbol = { "headbase", 0, -200, 0 },
    },
    ["werebeaver_skin"] = {
        bank = "werebeaver",
        hideclothing = true,
        shadow = { 1.3, .6 },
        debuffsymbol = { "torso", 0, -280, 0 },
    },
    ["weremoose_skin"] = {
        bank = "weremoose",
        hideclothing = true,
        shadow = { 2, 1 },
        debuffsymbol = { "weremoose_headbase", 0, -120, 0 },
    },
    ["weregoose_skin"] = {
        bank = "weregoose",
        hideclothing = true,
        shadow = { 1.2, .6 },
        debuffsymbol = { "head", 0, 0, 0 },
        freezelevel = 3,
    },
    ["ghost_skin"] = {
        bank = "ghost",
        shadow = { 1.3, .6 },
    },
}
for i, v in ipairs(WEREMODE_NAMES) do
    SKIN_MODE_DATA["ghost_were"..v.."_skin"] = SKIN_MODE_DATA["ghost_skin"]
end

local function CustomSetShadowForSkinMode(inst, skinmode)
    inst.DynamicShadow:SetSize(unpack(SKIN_MODE_DATA[skinmode].shadow))
end

local function CustomSetDebuffSymbolForSkinMode(inst, skinmode)
    inst.components.debuffable:SetFollowSymbol(unpack(SKIN_MODE_DATA[skinmode].debuffsymbol))
end

local function CustomSetSkinMode(inst, skinmode)
    local data = SKIN_MODE_DATA[skinmode]
    if data.hideclothing then
        inst.components.skinner:HideAllClothing(inst.AnimState)
    end
    inst.AnimState:SetBank(data.bank)
    inst.components.skinner:SetSkinMode(skinmode)
    inst.DynamicShadow:SetSize(unpack(data.shadow))
    if data.debuffsymbol ~= nil then
        inst.components.debuffable:SetFollowSymbol(unpack(data.debuffsymbol))
    end
    if inst.components.freezable ~= nil then
        inst.components.freezable:SetShatterFXLevel(data.freezelevel or 4)
    end
    if skinmode == "weregoose_skin" then
        inst.Transform:SetEightFaced()
    else
        inst.Transform:SetFourFaced()
    end
end

local function UpdateShadowDominanceState(inst)
    local wereform = inst:HasTag("wereplayer")

    if wereform and inst:HasTag("player_shadow_aligned") then
        inst:AddTag("inherentshadowdominance")
        inst:AddTag("shadowdominance")

    elseif inst:HasTag("inherentshadowdominance") then
        inst:RemoveTag("inherentshadowdominance")

        if inst.components.inventory ~= nil then
            for k, v in pairs(inst.components.inventory.equipslots) do
                if v.components.shadowdominance ~= nil then
                    --A item with shadowdominance is equipped, don't remove the shadowdominance tag.
                    return
                end
            end
        end
        
        inst:RemoveTag("shadowdominance")
    end
end

local function RecalculateWereformSpeed(inst)
    local skilltreeupdater = inst.components.skilltreeupdater

    if not skilltreeupdater then return end

    if inst:IsWeremoose() then
        if skilltreeupdater:IsActivated("woodie_curse_moose_1") then
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wereform_speed_bonus", TUNING.SKILLS.WOODIE.MOOSE_RUN_SPEED_BONUS_MULT)
        end

    elseif inst:IsWeregoose() then
        if skilltreeupdater:IsActivated("woodie_curse_goose_1") then
            inst.components.locomotor:SetExternalSpeedMultiplier(inst, "wereform_speed_bonus", TUNING.SKILLS.WOODIE.GOOSE_RUN_SPEED_BONUS_MULT)
        end
    else
        inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "wereform_speed_bonus")
    end
end

local function onbecamehuman(inst)
    if inst.prefab == nil then
        --when entity is being spawned
        CustomSetDebuffSymbolForSkinMode(inst, "normal_skin")
        --CustomSetShadowForSkinMode(inst, "normal_skin") --should be same as default already
    elseif not inst.sg:HasStateTag("ghostbuild") then
        CustomSetSkinMode(inst, "normal_skin")
    end

    inst.MiniMapEntity:SetIcon("woodie.png")

    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.combat.bonusdamagefn = nil
    inst.components.health:SetAbsorptionAmount(0)
    inst.components.sanity.custom_rate_fn = nil
    inst.components.pinnable.canbepinned = true
    if not GetGameModeProperty("no_hunger") then
        inst.components.hunger:Resume()
        if IsWereMode(inst.weremode:value()) then
            local hungerpercent = inst:HasTag("cursemaster") and TUNING.SKILLS.WOODIE.CURSE_MASTER_MIN_HUNGER or 0
            inst.components.hunger:SetPercent(hungerpercent, true)
        end
    end
    inst.components.temperature.inherentinsulation = 0
    inst.components.temperature.inherentsummerinsulation = 0
    inst.components.moisture:SetInherentWaterproofness(0)
    inst.components.talker:StopIgnoringAll("becamewere")
    inst.components.catcher:SetEnabled(true)
    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(TUNING.SANDSTORM_SPEED_MOD)
    inst.components.moonstormwatcher:SetMoonstormSpeedMultiplier(TUNING.MOONSTORM_SPEED_MOD)
    inst.components.miasmawatcher:SetMiasmaSpeedMultiplier(TUNING.MIASMA_SPEED_MOD)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(TUNING.CAREFUL_SPEED_MOD)
    inst.components.wereeater:ResetFoodMemory()
    inst.components.wereness:StopDraining()

    if inst.components.inspectable.getstatus == GetWereStatus then
        inst.components.inspectable.getstatus = inst._getstatus
        inst._getstatus = nil
    end

    inst.CanExamine = nil

    --[[if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(true)
    end]]

    SetWereDrowning(inst, WEREMODES.NONE)
    SetWereRunner(inst, WEREMODES.NONE)
    SetWereWorker(inst, WEREMODES.NONE)
    SetWereFighter(inst, WEREMODES.NONE)
    SetWereActions(inst, WEREMODES.NONE)
    SetWereSounds(inst, WEREMODES.NONE)
    SetWereVision(inst, WEREMODES.NONE)
    ChangeWereModeValue(inst, WEREMODES.NONE)
    OnResetBeard(inst)

    inst:UpdateShadowDominanceState()
    inst:RecalculateWereformSpeed()
end

local function onbecamebeaver(inst)
    if not inst.sg:HasStateTag("ghostbuild") then
        CustomSetSkinMode(inst, "werebeaver_skin")
    end

    inst.MiniMapEntity:SetIcon("woodie_1.png")

    inst.components.locomotor.runspeed = TUNING.BEAVER_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.BEAVER_DAMAGE)
    inst.components.combat.bonusdamagefn = beaverbonusdamagefn
    inst.components.health:SetAbsorptionAmount(TUNING.BEAVER_ABSORPTION)
    inst.components.sanity.custom_rate_fn = WereSanityFn
    inst.components.pinnable.canbepinned = false
    if not GetGameModeProperty("no_hunger") then
        if inst.components.hunger:IsStarving() then
            inst.components.hunger:SetPercent(.001, true)
        end
        inst.components.hunger:Pause()
    end
    inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
    inst.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_LARGE)
    inst.components.talker:IgnoreAll("becamewere")
    inst.components.catcher:SetEnabled(false)
    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)
    inst.components.moonstormwatcher:SetMoonstormSpeedMultiplier(1)
    inst.components.miasmawatcher:SetMiasmaSpeedMultiplier(1)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(1)
    inst.components.wereeater:ResetFoodMemory()
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.BEAVER, TheWorld.state.isfullmoon))
    inst.components.wereness:StartDraining()
    inst.components.wereness:SetWereMode(nil)

    if inst.components.inspectable.getstatus ~= GetWereStatus then
        inst._getstatus = inst.components.inspectable.getstatus
        inst.components.inspectable.getstatus = GetWereStatus
    end

    inst.CanExamine = CannotExamine

    --[[if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(false)
    end]]

    SetWereDrowning(inst, WEREMODES.BEAVER)
    SetWereRunner(inst, WEREMODES.BEAVER)
    SetWereWorker(inst, WEREMODES.BEAVER)
    SetWereFighter(inst, WEREMODES.BEAVER)
    SetWereActions(inst, WEREMODES.BEAVER)
    SetWereSounds(inst, WEREMODES.BEAVER)
    SetWereVision(inst, WEREMODES.BEAVER)
    ChangeWereModeValue(inst, WEREMODES.BEAVER)
    OnResetBeard(inst)

    inst:UpdateShadowDominanceState()
    inst:RecalculateWereformSpeed()
end

local function onbecamemoose(inst)
    if not (inst.sg:HasStateTag("ghostbuild") or inst.sg:HasStateTag("transform")) then
        CustomSetSkinMode(inst, "weremoose_skin")
    end

    inst.MiniMapEntity:SetIcon("woodie_2.png")

    inst.components.locomotor.runspeed = TUNING.WEREMOOSE_RUN_SPEED
    inst.components.combat:SetDefaultDamage(TUNING.WEREMOOSE_DAMAGE)
    inst.components.combat.bonusdamagefn = nil
    inst.components.health:SetAbsorptionAmount(TUNING.WEREMOOSE_ABSORPTION)
    inst.components.sanity.custom_rate_fn = WereSanityFn
    inst.components.pinnable.canbepinned = false
    if not GetGameModeProperty("no_hunger") then
        if inst.components.hunger:IsStarving() then
            inst.components.hunger:SetPercent(.001, true)
        end
        inst.components.hunger:Pause()
    end
    inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
    inst.components.moisture:SetInherentWaterproofness(TUNING.WATERPROOFNESS_LARGE)
    inst.components.talker:IgnoreAll("becamewere")
    inst.components.catcher:SetEnabled(false)
    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)
    inst.components.moonstormwatcher:SetMoonstormSpeedMultiplier(1)
    inst.components.miasmawatcher:SetMiasmaSpeedMultiplier(1)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(1)
    inst.components.wereeater:ResetFoodMemory()
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.MOOSE, TheWorld.state.isfullmoon))
    inst.components.wereness:StartDraining()
    inst.components.wereness:SetWereMode(nil)

    if inst.components.inspectable.getstatus ~= GetWereStatus then
        inst._getstatus = inst.components.inspectable.getstatus
        inst.components.inspectable.getstatus = GetWereStatus
    end

    inst.CanExamine = CannotExamine

    --[[if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(false)
    end]]

    SetWereDrowning(inst, WEREMODES.MOOSE)
    SetWereRunner(inst, WEREMODES.MOOSE)
    SetWereWorker(inst, WEREMODES.MOOSE)
    SetWereFighter(inst, WEREMODES.MOOSE)
    SetWereActions(inst, WEREMODES.MOOSE)
    SetWereSounds(inst, WEREMODES.MOOSE)
    SetWereVision(inst, WEREMODES.MOOSE)
    ChangeWereModeValue(inst, WEREMODES.MOOSE)
    OnResetBeard(inst)

    inst:UpdateShadowDominanceState()
    inst:RecalculateWereformSpeed()
end

local function onbecamegoose(inst)
    if not inst.sg:HasStateTag("ghostbuild") then
        CustomSetSkinMode(inst, "weregoose_skin")
    end

    inst.MiniMapEntity:SetIcon("woodie_3.png")

    inst.components.locomotor.runspeed = TUNING.WEREGOOSE_RUN_SPEED
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat.bonusdamagefn = nil
    inst.components.health:SetAbsorptionAmount(0)
    inst.components.sanity.custom_rate_fn = WereSanityFn
    inst.components.pinnable.canbepinned = false
    if not GetGameModeProperty("no_hunger") then
        if inst.components.hunger:IsStarving() then
            inst.components.hunger:SetPercent(.001, true)
        end
        inst.components.hunger:Pause()
    end
    inst.components.temperature.inherentinsulation = TUNING.INSULATION_LARGE
    inst.components.temperature.inherentsummerinsulation = TUNING.INSULATION_LARGE
    inst.components.moisture:SetInherentWaterproofness(GetGooseWaterproofness(inst))
    inst.components.talker:IgnoreAll("becamewere")
    inst.components.catcher:SetEnabled(false)
    inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)
    inst.components.moonstormwatcher:SetMoonstormSpeedMultiplier(1)
    inst.components.miasmawatcher:SetMiasmaSpeedMultiplier(1)
    inst.components.carefulwalker:SetCarefulWalkingSpeedMultiplier(1)
    inst.components.wereeater:ResetFoodMemory()
    inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, WEREMODES.GOOSE, TheWorld.state.isfullmoon))
    inst.components.wereness:StartDraining()
    inst.components.wereness:SetWereMode(nil)

    if inst.components.inspectable.getstatus ~= GetWereStatus then
        inst._getstatus = inst.components.inspectable.getstatus
        inst.components.inspectable.getstatus = GetWereStatus
    end

    inst.CanExamine = CannotExamine

    --[[if inst.components.playercontroller ~= nil then
        inst.components.playercontroller:SetCanUseMap(false)
    end]]

    SetWereDrowning(inst, WEREMODES.GOOSE)
    SetWereRunner(inst, WEREMODES.GOOSE)
    SetWereWorker(inst, WEREMODES.GOOSE)
    SetWereFighter(inst, WEREMODES.GOOSE)
    SetWereActions(inst, WEREMODES.GOOSE)
    SetWereSounds(inst, WEREMODES.GOOSE)
    SetWereVision(inst, WEREMODES.GOOSE)
    ChangeWereModeValue(inst, WEREMODES.GOOSE)
    OnResetBeard(inst)

    inst:UpdateShadowDominanceState()
    inst:RecalculateWereformSpeed()
end

local function onwerenesschange(inst)
    if inst.sg:HasStateTag("nomorph") or
        inst.sg:HasStateTag("silentmorph") or
        inst:HasTag("playerghost") or
        inst.components.health:IsDead() then
        return
    elseif IsWereMode(inst.weremode:value()) then
        if inst.components.wereness:GetPercent() <= 0 then
            inst:PushEvent("transform_person", { mode = WEREMODE_NAMES[inst.weremode:value()], cb = onbecamehuman })
        end
    elseif inst.components.wereness:GetPercent() > 0 then
        local weremode = inst.components.wereness:GetWereMode()
        if weremode ~= nil then
            if weremode ~= "fullmoon" then
                weremode = WEREMODES[string.upper(weremode)]
            elseif TheWorld.state.isfullmoon then
                weremode = math.random(#WEREMODE_NAMES)
            else
                weremode = WEREMODES.NONE
                inst.components.wereness:SetWereMode(nil)
                if not IsWereMode(inst.weremode:value()) then
                    inst.components.wereness:SetPercent(0, true)
                end
            end
            if IsWereMode(weremode) then
                inst:PushEvent("transform_wereplayer", {
                    mode = WEREMODE_NAMES[weremode],
                    cb = (weremode == WEREMODES.BEAVER and onbecamebeaver) or
                        (weremode == WEREMODES.MOOSE and onbecamemoose) or
                        (--[[weremode == WEREMODES.GOOSE and]] onbecamegoose) or
                        nil
                })
            end
        end
    end
end

local function onnewstate(inst)
    if inst._wasnomorph ~= (inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")) then
        inst._wasnomorph = not inst._wasnomorph
        if not inst._wasnomorph then
            onwerenesschange(inst)
        end
    end

    if IsWereMode(inst.weremode:value()) then
        inst.components.wereness:SetDrainRate(CalculateWerenessDrainRate(inst, inst.weremode:value(), TheWorld.state.isfullmoon))
    end
end

local function onrespawnedfromghost(inst, data, nofullmoontest)
    if inst._wasnomorph == nil then
        inst._wasnomorph = inst.sg:HasStateTag("nomorph") or inst.sg:HasStateTag("silentmorph")
        inst:ListenForEvent("werenessdelta", onwerenesschange)
        inst:ListenForEvent("newstate", onnewstate)
        inst:WatchWorldState("isfullmoon", OnIsFullmoon)
    end

    if IsWereMode(inst.weremode:value()) then
        inst.components.inventory:Close()
        if inst.weremode:value() == WEREMODES.BEAVER then
            onbecamebeaver(inst)
        elseif inst.weremode:value() == WEREMODES.MOOSE then
            onbecamemoose(inst)
        else--if inst.weremode:value() == WEREMODES.GOOSE then
            onbecamegoose(inst)
        end
    else
        onbecamehuman(inst)
    end

    -- nofullmoontest is an argument passed manually only!
    if not nofullmoontest then
        OnIsFullmoon(inst, TheWorld.state.isfullmoon)
    end
end

local function onbecameghost(inst, data)
    if not IsWereMode(inst.weremode:value()) then
        --clear any queued transformations
        inst.components.wereness:SetPercent(0, true)
    elseif data == nil or not data.corpse then
        CustomSetSkinMode(inst, "ghost_were"..WEREMODE_NAMES[inst.weremode:value()].."_skin")
    end

    inst.components.wereeater:ResetFoodMemory()
    inst.components.wereness:StopDraining()
    inst.components.wereness:SetWereMode(nil)

    if inst._wasnomorph ~= nil then
        inst._wasnomorph = nil
        inst:RemoveEventCallback("werenessdelta", onwerenesschange)
        inst:RemoveEventCallback("newstate", onnewstate)
        inst:StopWatchingWorldState("isfullmoon", OnIsFullmoon)
    end

    SetWereDrowning(inst, WEREMODES.NONE)
    SetWereRunner(inst, WEREMODES.NONE)
    SetWereWorker(inst, WEREMODES.NONE)
    SetWereFighter(inst, WEREMODES.NONE)
    SetWereActions(inst, WEREMODES.NONE)
    SetWereSounds(inst, WEREMODES.NONE)
    SetWereVision(inst, WEREMODES.NONE)
end

local function OnForceTransform(inst, weremode)
    weremode = weremode ~= nil and WEREMODES[string.upper(weremode)] or nil
    if weremode == nil or not IsWereMode(weremode) then
        weremode = math.random(#WEREMODE_NAMES)
    end

    inst.components.wereness:SetWereMode(WEREMODE_NAMES[weremode])
    inst.components.wereness:SetPercent(1, true)
    -- NOTES(JBK): Do not call StartDraining here it is handled by the stategraph callback.
end

--------------------------------------------------------------------------

local function OnTackleStart(inst)
    if inst.sg.currentstate.name == "tackle_pre" then
        inst.sg.statemem.tackling = true
        inst.sg:GoToState("tackle_start")
        return true
    end
end

local function OnTackleCollide(inst, other)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = other.Transform:GetWorldPosition()
    local r = other:GetPhysicsRadius(.5)
    r = r / (r + 1)
    SpawnPrefab("round_puff_fx_hi").Transform:SetPosition(x1 + (x - x1) * r, 0, z1 + (z - z1) * r)
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/bounce")
    ShakeAllCameras(CAMERASHAKE.FULL, .6, .025, .4, other, 20)

    if inst.components.grogginess ~= nil then
        local grogginess_skill = inst.components.skilltreeupdater:IsActivated("woodie_curse_moose_1")

        inst.components.grogginess:SetPercent(grogginess_skill and TUNING.SKILLS.WOODIE.MOOSE_REDUCED_GROGGINESS or 0.99)
    end
end

local function OnTackleTrample(inst, other)
    SpawnPrefab((other:HasTag("largecreature") or other:HasTag("epic")) and "round_puff_fx_lg" or "round_puff_fx_sm").Transform:SetPosition(other.Transform:GetWorldPosition())
end

local function OnTakeDrowningDamage(inst, tuning)
    if tuning.WERENESS ~= nil then
        inst.components.wereness:DoDelta(-tuning.WERENESS)
    end
end

local function GetDrowningDamageTunings(inst)
    return TUNING.DROWNING_DAMAGE[IsWereMode(inst.weremode:value()) and "WEREWOODIE" or "WOODIE"]
end

--------------------------------------------------------------------------

--Re-enter idle state right after loading because
--idle animations are determined by were state.
local function onentityreplicated(inst)
    if inst.sg ~= nil and inst:HasTag("wereplayer") then
        inst.sg:GoToState("idle")
    end
end

local function onpreload(inst, data)
    if data ~= nil and data.fullmoontriggered then
        if inst.fullmoontriggered then
            inst.components.wereness:SetWereMode(nil)
            inst.components.wereness:SetPercent(0, true)
        else
            inst.fullmoontriggered = true
        end
    end

    if data ~= nil and data.islunnaraligned then
        inst:AddTag("player_lunar_aligned")
    end

    if data ~= nil then
        if data.isbeaver then
            onbecamebeaver(inst)
        elseif data.ismoose then
            onbecamemoose(inst)
        elseif data.isgoose then
            onbecamegoose(inst)
        else
            return
        end
        inst.sg:GoToState("idle")
    end
end

local function onload(inst)
    if IsWereMode(inst.weremode:value()) and not inst:HasTag("playerghost") then
        inst.components.inventory:Close()
        if inst.components.wereness:GetPercent() <= 0 then
            --under these conditions, we won't get a "werenessdelta" event on load
            --but we do want to trigger a transformation back to human right away.
            onwerenesschange(inst)
        end
    end

    OnIsFullmoon(inst, TheWorld.state.isfullmoon)
end

local function onsave(inst, data)
    if IsWereMode(inst.weremode:value()) then
        data["is"..WEREMODE_NAMES[inst.weremode:value()]] = true
    end
    data.fullmoontriggered = inst.fullmoontriggered

    -- Skills activation occurs after onload functions, that's why this is needed.
    data.islunnaraligned = inst:HasTag("player_lunar_aligned")
end

--------------------------------------------------------------------------

local TALLER_FROSTYBREATHER_OFFSET = Vector3(.3, 3.75, 0)
local WEREMODE_FROSTYBREATHER_OFFSET =
{
    [WEREMODES.BEAVER] = Vector3(1.2, 2.15, 0),
    [WEREMODES.MOOSE] = Vector3(1.35, 2.5, 0),
    [WEREMODES.GOOSE] = Vector3(.5, 2.5, 0),
}
local DEFAULT_FROSTYBREATHER_OFFSET = Vector3(.3, 1.15, 0)
local function GetFrostyBreatherOffset(inst)
    local rider = inst.replica.rider
    return (rider ~= nil and rider:IsRiding() and TALLER_FROSTYBREATHER_OFFSET)
        or WEREMODE_FROSTYBREATHER_OFFSET[inst.weremode:value()]
        or DEFAULT_FROSTYBREATHER_OFFSET
end

local function customidleanimfn(inst)
    local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    return item ~= nil and item.prefab == "lucy" and "idle_woodie" or nil
end

--------------------------------------------------------------------------

local function IsNotArchives(map, x, y, z)
    -- Don't land inside the archives, but you can fly from inside the archives.
    return map:IsLandTileAtPoint(x, y, z) and not map:NodeAtPointHasTag(x, y, z, "nocavein")
end

local function UseWereFormSkill(inst, act)
    local weremode = WEREMODE_NAMES[inst.weremode:value()]
    local delta = weremode ~= nil and TUNING.SKILLS.WOODIE.WERESKILL_WERENESS_CONSUMPTION[string.upper(weremode)] or nil

    if delta ~= nil and inst.components.wereness ~= nil then
        inst.components.wereness:DoDelta(delta)
    end

    if inst:HasTag("beaver") then
        if inst.components.groundpounder ~= nil then
            inst.components.groundpounder:GroundPound()
        end

    elseif inst:HasTag("weregoose") and TheWorld ~= nil then
        local pos = TheWorld.Map:FindRandomPointWithFilter(50, IsNotArchives)

        if pos ~= nil then
            inst.Physics:Teleport(pos.x, 0, pos.z)
            inst:ResetMinimapOffset()
            inst:SnapCamera()
        end
    end
end

local function IsWerebeaver(inst)
    return inst.weremode:value() == WEREMODES.BEAVER
end

local function IsWeremoose(inst)
    return inst.weremode:value() == WEREMODES.MOOSE
end

local function IsWeregoose(inst)
    return inst.weremode:value() == WEREMODES.GOOSE
end

--------------------------------------------------------------------------

local function common_postinit(inst)
    inst:AddTag("woodcutter")
    inst:AddTag("polite")
    inst:AddTag("werehuman")

    --bearded (from beard component) added to pristine state for optimization
    inst:AddTag("bearded")

    inst.AnimState:AddOverrideBuild("player_actions_woodcarving")

    inst.AnimState:OverrideSymbol("round_puff01", "round_puff_fx", "round_puff01")

    if TheNet:GetServerGameMode() == "lavaarena" then
        --do nothing
    elseif TheNet:GetServerGameMode() == "quagmire" then
        inst:AddTag("quagmire_shopper")
    else
        --wereness (from wereness component) added to pristine state for optimization
        inst:AddTag("wereness")

        --Deprecated
        inst.GetBeaverness = GetBeaverness
        inst.IsBeaverStarving = IsBeaverStarving
        --
        inst.GetWereness = GetWereness -- Didn't want to make wereness a networked component
        inst.GetWerenessDrainRate = GetWerenessDrainRate

        inst.weremode = net_tinybyte(inst.GUID, "woodie.weremode", "weremodedirty")
        inst._weregooseflying = net_bool(inst.GUID, "woodie._weregooseflying", "weregooseflyingdirty")
		inst._weremoosesmashshake = net_event(inst.GUID, "woodie._weremoosesmashshake")

		if not TheWorld.ismastersim then
			inst:ListenForEvent("woodie._weremoosesmashshake", OnWereMooseSmashShake)
			inst.PushMooseSmashShake = PushMooseSmashShake_CLIENT
		end

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

    inst.customidleanim = customidleanimfn

    if TheNet:GetServerGameMode() == "lavaarena" then
        event_server_data("lavaarena", "prefabs/woodie").master_postinit(inst)
    elseif TheNet:GetServerGameMode() == "quagmire" then
        -- nothing to see here (dont go into the else case, or else!)
    else
        inst.components.health:SetMaxHealth(TUNING.WOODIE_HEALTH)
        inst.components.hunger:SetMax(TUNING.WOODIE_HUNGER)
        inst.components.sanity:SetMax(TUNING.WOODIE_SANITY)

        -- Give Woodie a beard so he gets some insulation from winter cold
        -- (Value is Wilson's level 2 beard.)
        inst:AddComponent("beard")
        inst.components.beard.canshavetest = CanShaveTest
        inst.components.beard.onreset = OnResetBeard
        inst.components.beard:EnableGrowth(false)

        OnResetBeard(inst)

        inst.components.foodaffinity:AddPrefabAffinity("honeynuggets", TUNING.AFFINITY_15_CALORIES_LARGE)

        inst:AddComponent("wereness")

        inst:AddComponent("wereeater")
        inst.components.wereeater:SetForceTransformFn(OnForceTransform)

        inst:AddComponent("tackler")
        inst.components.tackler:SetOnStartTackleFn(OnTackleStart)
        inst.components.tackler:SetDistance(.5)
        inst.components.tackler:SetRadius(.75)
        inst.components.tackler:SetStructureDamageMultiplier(2)
        inst.components.tackler:AddWorkAction(ACTIONS.CHOP, 8)
        inst.components.tackler:AddWorkAction(ACTIONS.MINE, 4)
        inst.components.tackler:AddWorkAction(ACTIONS.HAMMER, 2)
        inst.components.tackler:SetOnCollideFn(OnTackleCollide)
        inst.components.tackler:SetOnTrampleFn(OnTackleTrample)
        inst.components.tackler:SetEdgeDistance(5)

        inst._getstatus = nil
        inst._wasnomorph = nil

        inst.CustomSetSkinMode = CustomSetSkinMode
        inst.CustomSetShadowForSkinMode = CustomSetShadowForSkinMode
        inst.CustomSetDebuffSymbolForSkinMode = CustomSetDebuffSymbolForSkinMode

        inst.UseWereFormSkill = UseWereFormSkill
        inst.SetGooseFlying = SetGooseFlying
		inst.PushMooseSmashShake = PushMooseSmashShake_SERVER

        if inst.components.drownable ~= nil then
            inst.components.drownable:SetOnTakeDrowningDamageFn(OnTakeDrowningDamage)
            inst.components.drownable:SetCustomTuningsFn(GetDrowningDamageTunings)
        end

        inst.IsWerebeaver = IsWerebeaver
        inst.IsWeremoose  = IsWeremoose
        inst.IsWeregoose  = IsWeregoose

        inst.RecalculateWereformSpeed  = RecalculateWereformSpeed
        inst.UpdateShadowDominanceState = UpdateShadowDominanceState
        inst.OnDodgeAttack  = OnDodgeAttack
        inst.SetUpGroundPounder = SetUpGroundPounder

        inst:ListenForEvent("ms_respawnedfromghost", onrespawnedfromghost)
        inst:ListenForEvent("ms_becameghost", onbecameghost)

        onrespawnedfromghost(inst, nil, true)

        inst.OnSave = onsave
        inst.OnLoad = onload
        inst.OnPreLoad = onpreload
    end
end

return MakePlayerCharacter("woodie", prefabs, assets, common_postinit, master_postinit)
