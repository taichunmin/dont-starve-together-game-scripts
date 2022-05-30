require "recipes"

local assets =
{
    Asset("ANIM", "anim/blueprint.zip"),
    Asset("ANIM", "anim/blueprint_rare.zip"),
    Asset("INV_IMAGE", "blueprint"),
    Asset("INV_IMAGE", "blueprint_rare"),
}

local function onload(inst, data)
    if data ~= nil and data.recipetouse ~= nil then
        inst.recipetouse = data.recipetouse
        inst.components.teacher:SetRecipe(inst.recipetouse)

        if data.is_rare then
            inst.is_rare = data.is_rare
            inst.components.named:SetName(subfmt(STRINGS.NAMES.BLUEPRINT_RARE, { item = STRINGS.NAMES[string.upper(inst.recipetouse)] or STRINGS.NAMES.UNKNOWN }))
            inst.AnimState:SetBank("blueprint_rare")
            inst.AnimState:SetBuild("blueprint_rare")
            inst.components.inventoryitem:ChangeImageName("blueprint_rare")
            inst:RemoveComponent("burnable")
            inst:RemoveComponent("propagator")
        else
            inst.components.named:SetName((STRINGS.NAMES[string.upper(inst.recipetouse)] or STRINGS.NAMES.UNKNOWN).." "..STRINGS.NAMES.BLUEPRINT)
        end
    end
end

local function onsave(inst, data)
    data.recipetouse = inst.recipetouse
    data.is_rare = inst.is_rare or nil
end

local function getstatus(inst)
    return (inst.is_rare and "RARE")
           or "COMMON"
end

local function OnTeach(inst, learner)
    learner:PushEvent("learnrecipe", { teacher = inst, recipe = inst.components.teacher.recipe })
end

local function CanBlueprintRandomRecipe(recipe)
    if recipe.nounlock or recipe.builder_tag ~= nil then
        --Exclude crafting station and character specific
        return false
    end
    local hastech = false
    for k, v in pairs(recipe.level) do
        if v >= 10 then
            --Exclude TECH.LOST
            return false
        elseif v > 0 then
            hastech = true
        end
    end
    --Exclude TECH.NONE
    return hastech
end

local function CanBlueprintSpecificRecipe(recipe)
    --Exclude crafting station and character specific
    if recipe.nounlock or recipe.builder_tag ~= nil then
        return false
    end
    for k, v in pairs(recipe.level) do
        if v > 0 then
            return true
        end
    end
    --Exclude TECH.NONE
    return false
end

local function OnHaunt(inst, haunter)
    if not inst.is_rare and math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local recipes = {}
        local old = inst.recipetouse ~= nil and GetValidRecipe(inst.recipetouse) or nil
        for k, v in pairs(AllRecipes) do
            if IsRecipeValid(v.name) and
                old ~= v and
                (old == nil or old.tab == v.tab) and
                CanBlueprintRandomRecipe(v) and
                not haunter.components.builder:KnowsRecipe(v) and
                haunter.components.builder:CanLearn(v.name) then
                table.insert(recipes, v)
            end
        end
        if #recipes > 0 then
            inst.recipetouse = recipes[math.random(#recipes)].name or "unknown"
            inst.components.teacher:SetRecipe(inst.recipetouse)
            inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
            return true
        end
    end
    return false
end

local function fn(is_rare)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint")
    inst.AnimState:SetBuild("blueprint")
    inst.AnimState:PlayAnimation("idle")

    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst:SetPrefabName("blueprint")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.is_rare = is_rare

    --Remove these tags so that they can be added properly when replicating components below
    inst:RemoveTag("_named")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("blueprint")

    inst:AddComponent("named")
    inst:AddComponent("teacher")
    inst.components.teacher.onteach = OnTeach

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    if not is_rare then
        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
    else
        inst.AnimState:SetBank("blueprint_rare")
        inst.AnimState:SetBuild("blueprint_rare")
        inst.components.inventoryitem:ChangeImageName("blueprint_rare")
    end

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, OnHaunt, true, false, true)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

local function MakeAnyBlueprint()
    local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

    local unknownrecipes = {}
    local knownrecipes = {}
    local allplayers = AllPlayers
    for k, v in pairs(AllRecipes) do
        if IsRecipeValid(v.name) and CanBlueprintRandomRecipe(v) then
            local known = false
            for i, player in ipairs(allplayers) do
                if player.components.builder:KnowsRecipe(v) or
                    not player.components.builder:CanLearn(v.name) then
                    known = true
                    break
                end
            end
            table.insert(known and knownrecipes or unknownrecipes, v)
        end
    end
    inst.recipetouse =
        (#unknownrecipes > 0 and unknownrecipes[math.random(#unknownrecipes)].name) or
        (#knownrecipes > 0 and knownrecipes[math.random(#knownrecipes)].name) or
        "unknown"
    inst.components.teacher:SetRecipe(inst.recipetouse)
    inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
    return inst
end

local function MakeSpecificBlueprint(specific_item)
    return function()
        local is_rare = false

        local r = GetValidRecipe(specific_item)
        if r ~= nil then
            for k, v in pairs(r.level) do
                if v >= 10 then
                    is_rare = true
                    break
                end
            end
        end

        local inst = fn(is_rare)

        if not TheWorld.ismastersim then
            return inst
        end

        local r = GetValidRecipe(specific_item)
        inst.recipetouse = r ~= nil and not r.nounlock and r.name or "unknown"
        inst.components.teacher:SetRecipe(inst.recipetouse)
        if is_rare then
            inst.components.named:SetName(subfmt(STRINGS.NAMES.BLUEPRINT_RARE, { item = STRINGS.NAMES[string.upper(inst.recipetouse)] }))
        else
            inst.components.named:SetName(STRINGS.NAMES[string.upper(inst.recipetouse)].." "..STRINGS.NAMES.BLUEPRINT)
        end
        return inst
    end
end

local prefabs = {}

table.insert(prefabs, Prefab("blueprint", MakeAnyBlueprint, assets))
for k, v in pairs(AllRecipes) do
    if CanBlueprintSpecificRecipe(v) then
        table.insert(prefabs, Prefab(string.lower(k or "NONAME").."_blueprint", MakeSpecificBlueprint(k), assets))
    end
end

-- tab based blueprints are deprecated and will now generate MakeAnyBlueprint
for k, v in pairs(RECIPETABS) do
    if not v.crafting_station then
		-- Renamed WAR_blueprint because another prefab of the same name was added and this, for many reasons, was the easier one to fix.
        table.insert(prefabs, Prefab(string.lower(v.str == "WAR" and "WARTAB" or v.str or "NONAME").."_blueprint", MakeAnyBlueprint, assets))
    end
end

CanBlueprintSpecificRecipe = nil --don't need this anymore
return unpack(prefabs)
