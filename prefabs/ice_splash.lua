local assets =
{
    Asset("ANIM", "anim/ice_splash.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("ice_splash")
    inst.AnimState:SetBuild("ice_splash")
    inst.AnimState:PlayAnimation("full")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("ice_splash", fn, assets)
