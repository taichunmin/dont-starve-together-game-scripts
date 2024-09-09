local assets =
{
    Asset("ANIM", "anim/cookingrecipecard.zip"),
}

local cooking = require("cooking")

local function SetRecipe(inst, recipe_name, cooker_name)
    inst.recipe_name = recipe_name
    inst.cooker_name = cooker_name

    inst.components.named:SetName(subfmt(STRINGS.NAMES.COOKINGRECIPECARD, { item = STRINGS.NAMES[string.upper(recipe_name)] or recipe_name }))
end

local function PickRandomRecipe(inst)
	local card = cooking.recipe_cards[math.random(#cooking.recipe_cards)]
	SetRecipe(inst, card.recipe_name, card.cooker_name)
end

local function getdesc(inst, viewer)
	local cooker_recipes = cooking.recipes[inst.cooker_name]
	if cooker_recipes then
		local card = cooker_recipes[inst.recipe_name] and cooker_recipes[inst.recipe_name].card_def
		if card then
			local ing_str = subfmt(STRINGS.COOKINGRECIPECARD_DESC.INGREDIENTS_FIRST, {num = card.ingredients[1][2], ing = STRINGS.NAMES[string.upper(card.ingredients[1][1])]})
			for i = 2, #card.ingredients do
				ing_str = ing_str .. subfmt(STRINGS.COOKINGRECIPECARD_DESC.INGREDIENTS_MORE, {num = card.ingredients[i][2], ing = STRINGS.NAMES[string.upper(card.ingredients[i][1])]})
			end

			return subfmt(STRINGS.COOKINGRECIPECARD_DESC.BASE, {name = STRINGS.NAMES[string.upper(inst.recipe_name)], ingredients = ing_str})
		end
	end

	return nil
end

local function OnSave(inst, data)
    data.r = inst.recipe_name
    data.c = inst.cooker_name
end

local function OnLoad(inst, data)
	if data ~= nil then
		SetRecipe(inst, data.r, data.c)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cookingrecipecard")
    inst.AnimState:SetBuild("cookingrecipecard")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", nil, 0.75)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst.components.inspectable.getspecialdescription = getdesc

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")

	inst:AddComponent("erasablepaper")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	PickRandomRecipe(inst)

    return inst
end

return Prefab("cookingrecipecard", fn, assets)
