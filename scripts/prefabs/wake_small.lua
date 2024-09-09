local assets =
{
    Asset("ANIM", "anim/water_squid_wake.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("water_squid_wake")
    inst.AnimState:SetBuild("water_squid_wake")
    inst.AnimState:PlayAnimation("wake"..math.random(1,3))
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("fx")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("wake_small", fn, assets)