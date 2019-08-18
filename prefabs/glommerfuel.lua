local assets =
{
    Asset("ANIM", "anim/glommer_fuel.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("glommer_fuel")
    inst.AnimState:SetBuild("glommer_fuel")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.GLOMMERFUEL_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.GLOMMERFUEL_SOILCYCLES

    MakeHauntableLaunch(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_LARGE
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = -TUNING.SANITY_HUGE

    return inst
end

return Prefab("glommerfuel", fn, assets)
