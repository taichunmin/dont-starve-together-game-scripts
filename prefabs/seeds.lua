require "prefabs/veggies"

local assets =
{
    Asset("ANIM", "anim/seeds.zip"),
}

local prefabs =
{
    "seeds_cooked",
    "spoiled_food",
}

for k,v in pairs(VEGGIES) do
    table.insert(prefabs, k)
end

local function pickproduct(inst)
    local total_w = 0
    for k,v in pairs(VEGGIES) do
        total_w = total_w + (v.seed_weight or 1)
    end

    local rnd = math.random()*total_w
    for k,v in pairs(VEGGIES) do
        rnd = rnd - (v.seed_weight or 1)
        if rnd <= 0 then
            return k
        end
    end

    return "carrot"
end

local function common(anim, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("seeds")
    inst.AnimState:SetBuild("seeds")
    inst.AnimState:PlayAnimation(anim)
    inst.AnimState:SetRayTestOnBB(true)

    if cookable then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.SEEDS

    if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "seeds_cooked"
    end

    inst:AddComponent("tradable")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)

    inst:AddComponent("perishable")

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst
end

local function raw()
    local inst = common("idle", true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2

    inst:AddComponent("bait")
    inst:AddComponent("plantable")
    inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.plantable.product = pickproduct

    return inst
end

local function cooked()
    local inst = common("cooked")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab("seeds", raw, assets, prefabs),
    Prefab("seeds_cooked", cooked, assets)
