local assets =
{
    Asset("ANIM", "anim/razor.zip"),
    Asset("ANIM", "anim/swap_razor.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("razor")
    inst.AnimState:SetBuild("swap_razor")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "small", 0.08, {0.9, 0.7, 0.9}, true, -2, {sym_build = "swap_razor"})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("shaver")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("razor", fn, assets)