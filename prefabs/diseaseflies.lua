local assets =
{
    Asset("ANIM", "anim/flies.zip"),
}

local function PlayFlies(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    local parent = proxy.entity:GetParent()
    if parent ~= nil then
        inst.entity:SetParent(parent.entity)
    else
        inst.Transform:SetFromProxy(proxy.GUID)
    end

    inst.AnimState:SetBank("flies")
    inst.AnimState:SetBuild("flies")
    inst.AnimState:PlayAnimation("swarm_pre")
    for i = 1, proxy._loops:value() do
        inst.AnimState:PushAnimation("swarm_loop")
    end
    inst.AnimState:PushAnimation("swarm_pst", false)
    inst.AnimState:SetFinalOffset(1)

    inst.SoundEmitter:PlaySound("dontstarve/common/flies", "flies", .5)

    inst:ListenForEvent("animqueueover", inst.Remove)
end

local function SetLoops(inst, loops)
    inst._loops:set(loops)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    --Dedicated server does not need to spawn the local fx
    if not TheNet:IsDedicated() then
        --Delay one frame so that we are positioned properly before starting the effect
        --or in case we are about to be removed
        inst:DoTaskInTime(0, PlayFlies)
    end

    inst._loops = net_tinybyte(inst.GUID, "diseaseflies._loops")
    inst._loops:set(5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(2, inst.Remove)

    inst.SetLoops = SetLoops

    return inst
end

return Prefab("diseaseflies", fn, assets)
