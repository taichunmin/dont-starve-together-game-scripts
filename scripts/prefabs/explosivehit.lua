local assets =
{
    Asset("ANIM", "anim/explode.zip"),
}

local function PlayFXAnim(proxy)
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFromProxy(proxy.GUID)

    inst.AnimState:SetBank("explode")
    inst.AnimState:SetBuild("explode")
    inst.AnimState:PlayAnimation("small_firecrackers")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(1)

    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

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

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    event_server_data("lavaarena", "prefabs/explosivehit").master_postinit(inst)

    return inst
end

return Prefab("explosivehit", fn, assets)
