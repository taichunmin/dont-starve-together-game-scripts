local assets =
{
    Asset("ANIM", "anim/ice_puddle.zip"),
}

local function fn()
    local inst = CreateEntity()

    --Use FX, not DECOR, otherwise won't inspect properly when parented
    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("ice_puddle")
    inst.AnimState:SetBuild("ice_puddle")
    inst.AnimState:PlayAnimation("full")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    return inst
end

return Prefab("ice_puddle", fn, assets)
