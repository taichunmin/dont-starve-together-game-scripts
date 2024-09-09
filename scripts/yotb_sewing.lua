require "tuning"

local set_data = require("yotb_costumes")
local recipes = {}
for k, recipe in pairs (set_data.costumes) do
	table.insert(recipes, recipe)
end


local function GetIngredientValues(prefablist)
    local prefabs = {}
    local tags = {}

    for k,v in pairs(prefablist) do
        local name = v
        prefabs[name] = (prefabs[name] or 0) + 1
    end

    return prefabs
end

local function GetCandidateRecipes(ingdata)
	local candidates = {}

	--find all potentially valid recipes
	for k,v in pairs(recipes) do
		if v.test and v.test(ingdata) then
			table.insert(candidates, v)
		end
	end

	table.sort( candidates, function(a,b) return (a.priority or 0) > (b.priority or 0) end )
	if #candidates > 0 then

		--find the set of highest priority recipes
		local top_candidates = {}
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

local function IsRecipeValid(names)
	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(ingdata)

	return #candidates > 0
end

local function CalculateRecipe(names)
	local ingdata = GetIngredientValues(names)
	local candidates = GetCandidateRecipes(ingdata)

	return candidates[1].prefab_name, candidates[1].time or 1
end

return { CalculateRecipe = CalculateRecipe, IsRecipeValid = IsRecipeValid, recipes = recipes}
