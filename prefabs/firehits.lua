local assets =
{
    Asset("ANIM", "anim/lavaarena_hits_variety.zip"),
}

local function PlayFXAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("lavaarena_hits_variety")
    inst.AnimState:SetBuild("lavaarena_hits_variety")
    inst.AnimState:PlayAnimation("hit_"..tostring(math.floor(proxy.variation:value() / 2) + 1))
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    if proxy.variation:value() % 2 ~= 0 then
        inst.AnimState:SetScale(-1, 1)
    end

    inst:ListenForEvent("animover", inst.Remove)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame so that we are positioned properly before starting the effect
        --or in case we are about to be removed
        inst:DoTaskInTime(0, PlayFXAnim)
    end

    inst.variation = net_tinybyte(inst.GUID, "firehit.variation")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/firehits").master_postinit(inst)

    return inst
end

return Prefab("firehit", fn, assets)
