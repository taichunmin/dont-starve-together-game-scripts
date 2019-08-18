local assets =
{
    Asset("ANIM", "anim/koalephant_trunk.zip"),
}

local prefabs =
{
    "trunk_cooked",
    "spoiled_food",
}

local function create_common(anim, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("trunk")
    inst.AnimState:SetBuild("koalephant_trunk")
    inst.AnimState:PlayAnimation(anim)

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "trunk_cooked"
    end

    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function create_summer()
    local inst = create_common("idle_summer", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst.components.edible.healthvalue = TUNING.HEALING_MEDLARGE
    inst.components.edible.hungervalue = TUNING.CALORIES_LARGE

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_winter()
    local inst = create_common("idle_winter", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst.components.edible.healthvalue = TUNING.HEALING_MEDLARGE
    inst.components.edible.hungervalue = TUNING.CALORIES_LARGE

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_cooked()
    local inst = create_common("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst.components.edible.healthvalue = TUNING.HEALING_LARGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
    inst.components.perishable:StartPerishing()

    return inst
end

return Prefab("trunk_summer", create_summer, assets, prefabs),
    Prefab("trunk_winter", create_winter, assets, prefabs),
    Prefab("trunk_cooked", create_cooked, assets)
