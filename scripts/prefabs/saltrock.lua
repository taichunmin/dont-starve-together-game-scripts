local assets =
{
    Asset("ANIM", "anim/salt.zip"),
}

local CACHED_SALT_LICK_IMPROVED_RECIPE_COST = nil

local function CacheSaltLickImprovedRecipeCost(default)
    local saltlickrecipe = AllRecipes.saltlick_improved

    if saltlickrecipe == nil or saltlickrecipe.ingredients == nil then
        return default
    end

    local neededsalt = 0

    for _, ingredient in ipairs(saltlickrecipe.ingredients) do
        if ingredient.type == "saltrock" then
            neededsalt = neededsalt + ingredient.amount
        end
    end

    return neededsalt > 0 and neededsalt or default
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("salt")
    inst.AnimState:SetBuild("salt")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "rock"

    inst:AddTag("molebait")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    if CACHED_SALT_LICK_IMPROVED_RECIPE_COST == nil then
        CACHED_SALT_LICK_IMPROVED_RECIPE_COST = CacheSaltLickImprovedRecipeCost(6)
    end

    inst:AddComponent("bait")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("tradable")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("preservative")
    inst.components.preservative.percent_increase = TUNING.SALTROCK_PRESERVE_PERCENT_ADD

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.SALT
    inst.components.repairer.finiteusesrepairvalue = TUNING.SALTLICK_IMPROVED_MAX_LICKS / CACHED_SALT_LICK_IMPROVED_RECIPE_COST

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("saltrock", fn, assets)
