local assets =
{
    Asset("ANIM", "anim/spoiled_food.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spoiled")
    inst.AnimState:SetBuild("spoiled_food")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("icebox_valid")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.SPOILEDFOOD_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.SPOILEDFOOD_SOILCYCLES

    inst.components.fertilizer.withered_cycles = TUNING.SPOILEDFOOD_WITHEREDCYCLES

    inst:AddComponent("smotherer")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("selfstacker")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("spoiled_food", fn, assets)
