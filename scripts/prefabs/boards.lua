local assets =
{
    Asset("ANIM", "anim/boards.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boards")
    inst.AnimState:SetBuild("boards")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "wood"

    MakeInventoryFloatable(inst, "med", .15, {1.15, .8, 1.15})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_BOARDS_HEALTH
    inst.components.repairer.boatrepairsound = "turnoftides/common/together/boat/repair_with_wood"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("boards", fn, assets)
