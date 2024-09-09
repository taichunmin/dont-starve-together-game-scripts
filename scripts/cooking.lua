require "tuning"

local official_foods = {}

local cookerrecipes = {}

local cookbook_recipes = {}
local MOD_COOKBOOK_CATEGORY = "mod"
function AddCookerRecipe(cooker, recipe, is_mod_food)
	if is_mod_food then
		recipe.cookbook_category = MOD_COOKBOOK_CATEGORY
	else
		official_foods[recipe.name] = true
		recipe.cookbook_atlas = "images/cookbook_"..recipe.name..".xml" -- use the high res images
	end

	if not cookerrecipes[cooker] then
		cookerrecipes[cooker] = {}
	end
	cookerrecipes[cooker][recipe.name] = recipe

	if cooker ~= "portablespicer" and not recipe.no_cookbook then
		if not cookbook_recipes[recipe.cookbook_category] then
			cookbook_recipes[recipe.cookbook_category] = {}
		end
		if not cookbook_recipes[recipe.cookbook_category][recipe.name] then
			cookbook_recipes[recipe.cookbook_category][recipe.name] = recipe
		end
	end
end

local recipe_cards = {}
function AddRecipeCard(cooker, recipe)
	table.insert(recipe_cards, {recipe_name = recipe.name, cooker_name = cooker})
end

local function IsModCookerFood(prefab)
	return not official_foods[prefab] -- note: we cannot test against cookbook_recipes[MOD_COOKBOOK_CATEGORY] because if the mod is unloaded, it would return true
end

local function HasModCookerFood()
	return cookbook_recipes[MOD_COOKBOOK_CATEGORY] ~= nil
end

local ingredients = {}
function AddIngredientValues(names, tags, cancook, candry)
	for _,name in pairs(names) do
		ingredients[name] = { tags= {}}

		if cancook then
			ingredients[name.."_cooked"] = {tags={}}
		end

		if candry then
			ingredients[name.."_dried"] = {tags={}}
		end

		for tagname,tagval in pairs(tags) do
			ingredients[name].tags[tagname] = tagval
			--print(name,tagname,tagval,ingtable[name].tags[tagname])

			if cancook then
				ingredients[name.."_cooked"].tags.precook = 1
				ingredients[name.."_cooked"].tags[tagname] = tagval
			end
			if candry then
				ingredients[name.."_dried"].tags.dried = 1
				ingredients[name.."_dried"].tags[tagname] = tagval
			end
		end
	end
end

function IsModCookingProduct(cooker, name)
	local enabledmods = ModManager:GetEnabledModNames()
    for i,v in ipairs(enabledmods) do
        local mod = ModManager:GetMod(v)
        if mod.cookerrecipes and mod.cookerrecipes[cooker] and table.contains(mod.cookerrecipes[cooker], name) then
            return true
        end
    end
    return false
end

-- All Tags: fruit, monster, sweetener, veggie, meat, fish, egg, decoration, fat, dairy, inedible, seed, magic
local fruits = {"pomegranate", "dragonfruit", "cave_banana"}
AddIngredientValues(fruits, {fruit=1}, true)

AddIngredientValues({"wormlight"}, {fruit=1})
AddIngredientValues({"wormlight_lesser"}, {fruit=.5})

AddIngredientValues({"berries"}, {fruit=.5}, true)
AddIngredientValues({"berries_juicy"}, {fruit=.5}, true)
AddIngredientValues({"fig"}, {fruit=.5}, true)
AddIngredientValues({"durian"}, {fruit=1, monster=1}, true)

AddIngredientValues({"honey", "honeycomb"}, {sweetener=1}, true)
AddIngredientValues({"royal_jelly"}, {sweetener=3}, true)

local veggies = {"carrot", "corn", "pumpkin", "eggplant", "cutlichen", "asparagus", "onion", "garlic", "tomato", "potato", "pepper"}
AddIngredientValues(veggies, {veggie=1}, true)

local mushrooms = {"red_cap", "green_cap", "blue_cap", "moon_cap"}
AddIngredientValues(mushrooms, {veggie=.5}, true)

AddIngredientValues({"meat"}, {meat=1}, true, true)
AddIngredientValues({"monstermeat"}, {meat=1, monster=1}, true, true)
AddIngredientValues({"froglegs", "drumstick", "batwing"}, {meat=.5}, true)
AddIngredientValues({"smallmeat", "batnose"}, {meat=.5}, true, true)

AddIngredientValues({"eel"}, {meat=.5,fish=1}, true)
AddIngredientValues({"fish"}, {meat=1,fish=1}, true)

AddIngredientValues({"pondeel"}, {meat=.5,fish=1}, true)
AddIngredientValues({"pondfish"}, {meat=.5,fish=.5}, false)
AddIngredientValues({"fishmeat_small"}, {meat=.5,fish=.5}, true)
AddIngredientValues({"fishmeat"}, {meat=1,fish=1}, true)
local oceanfishdefs = require("prefabs/oceanfishdef")
for _, fish_def in pairs(oceanfishdefs.fish) do
	if fish_def.cooker_ingredient_value ~= nil then
		AddIngredientValues({fish_def.prefab.."_inv"}, fish_def.cooker_ingredient_value, false)
	end
end

AddIngredientValues({"kelp"}, {veggie=.5}, true, true)

AddIngredientValues({"mandrake"}, {veggie=1, magic=1}, true)
AddIngredientValues({"egg"}, {egg=1}, true)
AddIngredientValues({"tallbirdegg"}, {egg=4}, true)
AddIngredientValues({"bird_egg"}, {egg=1}, true)
AddIngredientValues({"butterflywings"}, {decoration=2})
AddIngredientValues({"moonbutterflywings"}, {decoration=2})
AddIngredientValues({"butter"}, {fat=1, dairy=1})
AddIngredientValues({"twigs"}, {inedible=1})
AddIngredientValues({"lightninggoathorn"}, {inedible=1})

AddIngredientValues({"ice"}, {frozen=1})
AddIngredientValues({"mole"}, {meat=.5})
AddIngredientValues({"cactus_meat"}, {veggie=1}, true)
AddIngredientValues({"rock_avocado_fruit_ripe"}, {veggie=1}, true)
AddIngredientValues({"watermelon"}, {fruit=1}, true)
AddIngredientValues({"cactus_flower"}, {veggie=.5})
AddIngredientValues({"acorn"}, {seed=1})
AddIngredientValues({"acorn_cooked"}, {seed=1})
AddIngredientValues({"goatmilk"}, {dairy=1})
-- AddIngredientValues({"seeds"}, {seed=1}, true)

AddIngredientValues({"milkywhites"}, {dairy=1})

AddIngredientValues({"nightmarefuel"}, {inedible=1, magic=1})
AddIngredientValues({"boneshard"}, {inedible=1})

AddIngredientValues({"wobster_sheller_land"}, {meat=1.0, fish=1.0})

AddIngredientValues({"barnacle","barnacle_cooked"}, {meat=0.25, fish=0.25})

AddIngredientValues({"plantmeat","plantmeat_cooked"}, {meat=1})

AddIngredientValues({"refined_dust"}, {decoration=2})

AddIngredientValues({"forgetmelots"}, {decoration=1})

AddIngredientValues({"trunk_summer","trunk_winter","trunk_cooked"}, {meat=1})

AddIngredientValues({"ancientfruit_nightvision"}, {fruit=1}, true)

--our naming conventions aren't completely consistent, sadly
local aliases =
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked",
}

local function IsCookingIngredient(prefabname)
    return ingredients[aliases[prefabname] or prefabname] ~= nil
end

local foods = require("preparedfoods")
for k,recipe in pairs (foods) do
	AddCookerRecipe("cookpot", recipe)
	AddCookerRecipe("portablecookpot", recipe)
	AddCookerRecipe("archive_cookpot", recipe)

	if recipe.card_def then
		AddRecipeCard("cookpot", recipe)
	end
end

local portable_foods = require("preparedfoods_warly")
for k,recipe in pairs (portable_foods) do
	AddCookerRecipe("portablecookpot", recipe)
end

local spicedfoods = require("spicedfoods")
for k, recipe in pairs(spicedfoods) do
    AddCookerRecipe("portablespicer", recipe)
end

local nonfoods = require("preparednonfoods")
for k, recipe in pairs(nonfoods) do
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
end

local function GetIngredientValues(prefablist)
    local prefabs = {}
    local tags = {}
    for k,v in pairs(prefablist) do
        local name = aliases[v] or v
        prefabs[name] = (prefabs[name] or 0) + 1
        local data = ingredients[name]
        if data ~= nil then
            for kk, vv in pairs(data.tags) do
                tags[kk] = (tags[kk] or 0) + vv
            end
        end
    end
    return { tags = tags, names = prefabs }
end

local function GetRecipe(cooker, product)
	local recipes = cookerrecipes[cooker] or {}
	return recipes[product]
end

function GetCandidateRecipes(cooker, ingdata)
	local recipes = cookerrecipes[cooker] or {}
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		if v.test(cooker, ingdata.names, ingdata.tags) then
			table.insert(candidates, v)
		end
	end

	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then
		--find the set of highest priority recipes
		local top_candidates = {}
		local idx = 1
		local val = candidates[1].priority or 0

		for k,v in ipairs(candidates) do
			if k > 1 and (v.priority or 0) < val then
				break
			end
			table.insert(top_candidates, v)
		end
		return top_candidates
	end

	return candidates
end

local function CalculateRecipe(cooker, names)
	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(cooker, ingdata)

	table.sort( candidates, function(a,b) return (a.weight or 1) > (b.weight or 1) end )
	local total = 0
	for k,v in pairs(candidates) do
		total = total + (v.weight or 1)
	end

	local val = math.random()*total
	local idx = 1
	while idx <= #candidates do
		val = val - candidates[idx].weight
		if val <= 0 then
			return candidates[idx].name, candidates[idx].cooktime or 1
		end

		idx = idx+1
	end
end

--[[local function TestRecipes(cooker, prefablist)
	local ingdata = GetIngredientValues(prefablist)

	print ("Ingredients:")
	for k,v in pairs(prefablist) do
		if not IsCookingIngredient(v) then
			print ("NOT INGREDIENT:", v)
		end
	end

	for k,v in pairs(ingdata.names) do
		print (v,k)
	end

	print ("\nIngredient tags:")
	for k,v in pairs(ingdata.tags) do
		print (tostring(v), k)
	end

	print ("\nPossible recipes:")
	local candidates = GetCandidateRecipes(cooker, ingdata)
	for k,v in pairs(candidates) do
		print("\t"..v.name, v.weight or 1)
	end

	local recipe = CalculateRecipe(cooker, prefablist)
	print ("Make:", recipe)

	print ("total health:", foods[recipe].health)
	print ("total hunger:", foods[recipe].hunger)
end

TestRecipes("cookpot", {"tallbirdegg","meat","carrot","meat"})]]

return { CalculateRecipe = CalculateRecipe, IsCookingIngredient = IsCookingIngredient, recipes = cookerrecipes, ingredients = ingredients, GetRecipe = GetRecipe, cookbook_recipes = cookbook_recipes, recipe_cards = recipe_cards, HasModCookerFood = HasModCookerFood, IsModCookerFood = IsModCookerFood}
