local assets =
{
    Asset("ANIM", "anim/mossling_spin_fx.zip")
}

local function PlayFX(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("mossling_spin_fx")
    inst.AnimState:SetBuild("mossling_spin_fx")
    inst.AnimState:PlayAnimation("spin_loop")

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
    inst:DoTaskInTime(24*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
        inst:DoTaskInTime(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/mossling/spin_electric")
        end)
    end)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

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
        inst:DoTaskInTime(0, PlayFX)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("mossling_spin_fx", fn, assets)