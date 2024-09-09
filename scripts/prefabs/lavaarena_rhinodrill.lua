local assets =
{
    Asset("ANIM", "anim/lavaarena_rhinodrill_basic.zip"),
    Asset("ANIM", "anim/lavaarena_rhinodrill_damaged.zip"),
    Asset("ANIM", "anim/lavaarena_battlestandard.zip"),
    Asset("ANIM", "anim/wilson_fx.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local assets_alt =
{
    Asset("ANIM", "anim/lavaarena_rhinodrill_basic.zip"),
    Asset("ANIM", "anim/lavaarena_rhinodrill_clothed_b_build.zip"),
    Asset("ANIM", "anim/lavaarena_rhinodrill_damaged.zip"),
    Asset("ANIM", "anim/lavaarena_battlestandard.zip"),
    Asset("ANIM", "anim/wilson_fx.zip"),
    Asset("ANIM", "anim/fossilized.zip"),
}

local prefabs =
{
    "fossilizing_fx",
    "rhinodrill_fossilized_break_fx_right",
    "rhinodrill_fossilized_break_fx_left",
    "rhinodrill_fossilized_break_fx",
    "rhinobuff",
    "rhinobumpfx",
    "lavaarena_creature_teleport_small_fx",
}

--------------------------------------------------------------------------

local function DoPulse(inst)
    inst.task = nil
    if inst.level > 0 then
        inst:Show()
        inst.AnimState:PlayAnimation("attack_fx3")
    else
        inst:Remove()
    end
end

local function OnPulseAnimOver(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
    if inst.level >= 7 then
        inst.AnimState:PlayAnimation("attack_fx3")
    elseif inst.level > 0 then
        inst.task = inst:DoTaskInTime(3.5 - inst.level * .5, DoPulse)
        inst:Hide()
    else
        inst:Remove()
    end
end

local function CreatePulse()
    local inst = CreateEntity()

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("lavaarena_battlestandard")
    inst.AnimState:SetBuild("lavaarena_battlestandard")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:Hide()
    inst.level = 0
    inst.task = inst:DoTaskInTime(1, DoPulse)
    inst:ListenForEvent("animover", OnPulseAnimOver)

    return inst
end

local function OnBuffLevelDirty(inst)
    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        if inst.buff_fx ~= nil then
            inst.buff_fx.level = 0
            inst.buff_fx = nil
        end
        if inst._bufflevel:value() > 0 then
            inst.buff_fx = CreatePulse()
            inst.buff_fx.entity:SetParent(inst.entity)
            inst.buff_fx.level = inst._bufflevel:value()
        end
    end
end

local function SetBuffLevel(inst, level)
    level = math.clamp(level, 0, 7)
    if inst._bufflevel:value() ~= level then
        inst._bufflevel:set(level)
        OnBuffLevelDirty(inst)
    end
end

--------------------------------------------------------------------------

local function OnCameraFocusDirty(inst)
    if inst._camerafocus:value() then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, nil, nil, 60, 60, 2)
    else
        TheFocalPoint.components.focalpoint:StopFocusSource(inst)
    end
end

local function EnableCameraFocus(inst, enable)
    if enable ~= inst._camerafocus:value() then
        inst._camerafocus:set(enable)
        if not TheNet:IsDedicated() then
            OnCameraFocusDirty(inst)
        end
    end
end

--------------------------------------------------------------------------

local function MakeRhinoDrill(name, alt)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddDynamicShadow()
        inst.entity:AddNetwork()

        inst.DynamicShadow:SetSize(2.75, 1.25)
        inst.Transform:SetSixFaced()
        inst.Transform:SetScale(1.15, 1.15, 1.15)

        inst:SetPhysicsRadiusOverride(1)
        MakeCharacterPhysics(inst, 400, inst.physicsradiusoverride)

        inst.AnimState:SetBank("rhinodrill")
        inst.AnimState:SetBuild("lavaarena_rhinodrill_basic")
        inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
        if alt then
            inst.AnimState:AddOverrideBuild("lavaarena_rhinodrill_clothed_b_build")
        end
        inst.AnimState:PlayAnimation("idle_loop", true)

        inst.AnimState:AddOverrideBuild("fossilized")

        inst:AddTag("LA_mob")
        inst:AddTag("monster")
        inst:AddTag("hostile")
        inst:AddTag("largecreature")

        --fossilizable (from fossilizable component) added to pristine state for optimization
        inst:AddTag("fossilizable")

        inst._bufflevel = net_tinybyte(inst.GUID, "rhinodrill._bufflevel", "buffleveldirty")
        inst._camerafocus = net_bool(inst.GUID, "rhinodrill._camerafocus", "camerafocusdirty")

        ------------------------------------------

        if TheWorld.components.lavaarenamobtracker ~= nil then
            TheWorld.components.lavaarenamobtracker:StartTracking(inst)
        end

        ------------------------------------------

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("buffleveldirty", OnBuffLevelDirty)
            inst:ListenForEvent("camerafocusdirty", OnCameraFocusDirty)

            return inst
        end

        inst.SetBuffLevel = SetBuffLevel
        inst.EnableCameraFocus = EnableCameraFocus

        event_server_data("lavaarena", "prefabs/lavaarena_rhinodrill").master_postinit(inst, alt)

        return inst
    end

    return Prefab(name, fn, alt and assets_alt or assets, prefabs)
end

local function MakeFossilizedBreakFX(side)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        inst.Transform:SetSixFaced()

        --Leave this out of pristine state to force animstate to be dirty later
        --inst.AnimState:SetBank("rhinodrill")
        inst.AnimState:SetBuild("fossilized")
        inst.AnimState:PlayAnimation("fossilized_break_fx")

        if side:len() > 0 then
            inst.AnimState:Hide(side == "right" and "fx_lavarock_L" or "fx_lavarock_R")
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false
        inst:ListenForEvent("animover", ErodeAway)

        return inst
    end

    return Prefab(side:len() > 0 and ("rhinodrill_fossilized_break_fx_"..side) or "rhinodrill_fossilized_break_fx", fn, assets)
end

return MakeRhinoDrill("rhinodrill"),
    MakeRhinoDrill("rhinodrill2", true),
    MakeFossilizedBreakFX("right"),
    MakeFossilizedBreakFX("left"),
    MakeFossilizedBreakFX("")
