local assets =
{
    Asset("ANIM", "anim/goosemoose_nest_fx.zip"),
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

    inst.AnimState:SetBank("goosemoose_nest_fx")
    inst.AnimState:SetBuild("goosemoose_nest_fx")
    inst.AnimState:PlayAnimation(proxy.anim)
    inst.AnimState:SetFinalOffset(3)

    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/moose/egg_electric")

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:ListenForEvent("animover", inst.Remove)
end

local function Make(anim)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            --Delay one frame so that we are positioned properly before starting the effect
            --or in case we are about to be removed

            inst.anim = anim
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
    return fn
end

return Prefab("moose_nest_fx_idle", Make("idle"), assets),
    Prefab("moose_nest_fx_hit", Make("hit"), assets)