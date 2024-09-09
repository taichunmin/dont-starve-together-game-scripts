local assets =
{
    Asset("ANIM", "anim/wortox_eat_soul_fx.zip"),
}

local function MakeMounted(inst)
    inst.Transform:SetSixFaced()
    inst.AnimState:PlayAnimation("mounted_eat")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("wortox_eat_soul_fx")
    inst.AnimState:SetBuild("wortox_eat_soul_fx")
    inst.AnimState:PlayAnimation("eat")
    inst.AnimState:SetFinalOffset(1)

    inst:AddTag("DECOR") --"FX" will catch mouseover
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst.MakeMounted = MakeMounted

    return inst
end

return Prefab("wortox_eat_soul_fx", fn, assets)
