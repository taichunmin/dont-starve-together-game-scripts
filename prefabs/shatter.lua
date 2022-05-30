local assets =
{
    Asset("ANIM", "anim/frozen_shatter.zip"),
}

local shatterlevels =
{
    { anim = "tiny" },
    { anim = "small" },
    { anim = "medium" },
    { anim = "large" },
    { anim = "huge" },
}

local function PlayShatterAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("frozen_shatter")
    inst.AnimState:SetBuild("frozen_shatter")
    inst.AnimState:SetFinalOffset(3)

    inst.SoundEmitter:PlaySound("dontstarve/common/break_iceblock")

    inst:AddComponent("shatterfx")
    inst.components.shatterfx.levels = shatterlevels
    inst.components.shatterfx:SetLevel(proxy._level:value())

    inst:ListenForEvent("animover", inst.Remove)
end

local function OnLevelDirty(inst)
    if inst._complete or inst._level:value() <= 0 then
        return
    end

    --Delay one frame in case we are about to be removed
    inst:DoTaskInTime(0, PlayShatterAnim)
    inst._complete = true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.Transform:SetTwoFaced()

    inst:AddTag("FX")

    inst._level = net_tinybyte(inst.GUID, "_level", "leveldirty")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        inst._complete = false
        inst:ListenForEvent("leveldirty", OnLevelDirty)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("shatterfx")
    --Override proxy SetLevel function
    function inst.components.shatterfx:SetLevel(level)
        inst._level:set(level)
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("shatter", fn, assets)
