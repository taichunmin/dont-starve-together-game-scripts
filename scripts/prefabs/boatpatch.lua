local assets_wood =
{
    Asset("ANIM", "anim/boat_repair_build.zip"),
    Asset("ANIM", "anim/boat_repair.zip"),
}

local assets_kelp =
{
    Asset("ANIM", "anim/boat_repair_kelp.zip"),
}

local prefabs_wood =
{
    "fishingnetvisualizer",
}

local prefabs_kelp =
{
    "repaired_kelp_timeout_fx",
}


local CACHED_KELP_RECIPE_COST = nil

local function CacheKelpRecipeCost(default)
    local boatpatchrecipe = AllRecipes.boatpatch_kelp

    if boatpatchrecipe == nil or boatpatchrecipe.ingredients == nil then
        return default
    end

    local neededkelp = 0
    for _, ingredient in ipairs(boatpatchrecipe.ingredients) do
        if ingredient.type ~= "kelp" then
            return default
        end
        neededkelp = neededkelp + ingredient.amount
    end

    return neededkelp
end

local function fn_wood()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("boat_patch")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boat_repair")
    inst.AnimState:SetBuild("boat_repair_build")
    inst.AnimState:PlayAnimation("item")

    MakeInventoryFloatable(inst, "med", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("boatpatch")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LOGS_HEALTH * 2
    inst.components.repairer.boatrepairsound = "turnoftides/common/together/boat/repair_with_wood"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL * 2 -- 2x logs

    MakeHauntableLaunch(inst)

    return inst
end

local function fn_kelp()
    local inst = fn_wood()

    inst:AddTag("show_spoilage")

    inst.AnimState:SetBank("boat_repair_kelp")
    inst.AnimState:SetBuild("boat_repair_kelp")

    if not TheWorld.ismastersim then
        return inst
    end
    
    if CACHED_KELP_RECIPE_COST == nil then
        CACHED_KELP_RECIPE_COST = CacheKelpRecipeCost(3)
    end

    inst.components.boatpatch.patch_type = "kelp"

    inst.components.repairer.repairmaterial = MATERIALS.KELP
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_KELP_HEALTH * CACHED_KELP_RECIPE_COST
    inst.components.repairer.boatrepairsound = "meta4/boat_patch/kelp_place"

    inst.components.burnable:SetBurnTime(TUNING.SMALL_BURNTIME)

    inst:AddComponent("bait")
    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY * CACHED_KELP_RECIPE_COST
    inst.components.edible.healthvalue = -TUNING.HEALING_TINY * CACHED_KELP_RECIPE_COST
    inst.components.edible.sanityvalue = (-TUNING.SANITY_SMALL * CACHED_KELP_RECIPE_COST) - TUNING.SANITY_MED -- Disgusting!
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    return inst
end

return
    Prefab("boatpatch",      fn_wood, assets_wood, prefabs_wood),
    Prefab("boatpatch_kelp", fn_kelp, assets_kelp, prefabs_kelp)
