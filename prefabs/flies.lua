local assets =
{
    Asset("ANIM", "anim/flies.zip"),
}

local function onnear(inst)
    inst.SoundEmitter:KillSound("flies")
    inst.AnimState:PlayAnimation("swarm_pst")
end

local function onfar(inst)
    if not inst:IsAsleep() then
        inst.SoundEmitter:PlaySound("dontstarve/common/flies", "flies")
    end
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
end

local function OnWake(inst)
    if not inst.components.playerprox:IsPlayerClose() then
        inst.SoundEmitter:PlaySound("dontstarve/common/flies", "flies")
    end
end

local function OnSleep(inst)
    inst.SoundEmitter:KillSound("flies")
end

local function oninit(inst)
    inst.components.playerprox:ForceUpdate()
    if not inst:IsAsleep() then
        OnWake(inst)
    end
    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("flies")
    inst.AnimState:SetBuild("flies")

    inst.AnimState:PlayAnimation("swarm_pre")

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:PushAnimation("swarm_loop", true)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(2,3)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:DoTaskInTime(0, oninit)

    return inst
end

return Prefab("flies", fn, assets)
