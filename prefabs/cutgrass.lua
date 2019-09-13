local assets =
{
    Asset("ANIM", "anim/cutgrass.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cutgrass")
    inst.AnimState:SetBuild("cutgrass")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("cattoy")
    inst:AddTag("renewable")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ROUGHAGE
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.HAY
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTGRASS_HEALTH

    return inst
end

return Prefab("cutgrass", fn, assets)
