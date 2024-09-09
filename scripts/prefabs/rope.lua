local assets =
{
    Asset("ANIM", "anim/rope.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("rope")
    inst.AnimState:SetBuild("rope")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "cloth"

    inst:AddTag("cattoy")

    MakeInventoryFloatable(inst, "small", 0.05)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("tradable")

    return inst
end

return Prefab("rope", fn, assets)
