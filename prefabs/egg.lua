local assets =
{
    Asset("ANIM", "anim/bird_eggs.zip"),
}

local prefabs =
{
    "bird_egg_cooked",
    "rottenegg",
}

local cooked_prefabs =
{
    "spoiled_food",
}

local function commonfn(anim, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("birdegg")
    inst.AnimState:SetBuild("bird_eggs")
    inst.AnimState:PlayAnimation(anim)

    inst:AddTag("catfood")

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "bird_egg_cooked"
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "rottenegg"

    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1

    return inst
end

local function defaultfn()
    local inst = commonfn("idle", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

	inst.components.tradable.rocktribute = 1

    return inst
end

local function cookedfn()
    local inst = commonfn("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable.onperishreplacement = "spoiled_food"    

    return inst
end

local function rottenfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("birdegg")
    inst.AnimState:SetBuild("bird_eggs")
    inst.AnimState:PlayAnimation("rotten")

    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.SPOILEDFOOD_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.SPOILEDFOOD_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.SPOILEDFOOD_WITHEREDCYCLES

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER

    return inst
end

return Prefab("bird_egg", defaultfn, assets, prefabs),
    Prefab("bird_egg_cooked", cookedfn, assets, cooked_prefabs),
    Prefab("rottenegg", rottenfn, assets)
