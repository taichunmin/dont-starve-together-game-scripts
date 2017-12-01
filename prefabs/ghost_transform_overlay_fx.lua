local assets =
{
    Asset("ANIM", "anim/player_revive_fx.zip"),
}

local function Flash(inst, intensity, radius)
    inst._kintensity = intensity or inst._kintensity
    inst._kradius = radius or inst._kradius
end

local function OnUpdate(inst)
    if inst._kradius <= 0 then
        local intk = .2 * inst._kintensity
        inst.Light:SetIntensity(.6 + intk)
        inst.Light:SetFalloff(.6 - intk)
    elseif inst._kradius > 0 then
        inst._kradius = inst._kradius - .067
        if inst._kradius <= 0 then
            inst.Light:Enable(false)
        else
            local intk = .2 * inst._kintensity
            local k = 1 - inst._kradius
            k = 1 - k * k
            inst.Light:SetRadius(.5 * k)
            inst.Light:SetIntensity(.6 * k + intk)
            inst.Light:SetFalloff(.6 * k - intk)
        end
    end
    inst._kintensity = inst._kintensity * .75
end

local function RemoveMe(inst)
    inst:DoTaskInTime(1, inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.AnimState:SetBank("player_revive_fx")
    inst.AnimState:SetBuild("player_revive_fx")
    inst.AnimState:PlayAnimation("shudder")

    --Copy ghost light values from player_common
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.6)
    inst.Light:SetColour(180 / 255, 195 / 255, 225 / 255)
    inst.Light:EnableClientModulation(true)

    inst._kintensity = 0
    inst._kradius = 0
    inst:DoPeriodicTask(FRAMES, OnUpdate)
    inst:DoTaskInTime(6 * FRAMES, Flash, .75)
    inst:DoTaskInTime(15 * FRAMES, Flash, 1)
    inst:DoTaskInTime(30 * FRAMES, Flash, 1.1)
    inst:DoTaskInTime(40 * FRAMES, Flash, 1)
    inst:DoTaskInTime(47 * FRAMES, Flash, .8)
    inst:DoTaskInTime(64 * FRAMES, Flash, 1.2)
    inst:DoTaskInTime(74 * FRAMES, Flash, .8, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.AnimState:PushAnimation("brace", false)
    inst.AnimState:PushAnimation("transform", false)
    inst:ListenForEvent("animqueueover", RemoveMe)

    return inst
end

return Prefab("ghost_transform_overlay_fx", fn, assets)
