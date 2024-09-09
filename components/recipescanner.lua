local RecipeScanner = Class(function(self, inst)
	self.inst = inst
	self.onscanned = nil

	--V2C: Recommended to explicitly add tag to prefab pristine state
	inst:AddTag("recipescanner")
end)

function RecipeScanner:OnRemoveFromEntity()
	self.inst:RemoveTag("recipescanner")
end

function RecipeScanner:SetOnScannedFn(fn)
	self.onscanned = fn
end

function RecipeScanner:Scan(target, doer)
	if doer.components.builder == nil or target:HasTag("NOCLICK") then
		return false
	end
	local recipe
	if target.SCANNABLE_RECIPENAME then
		recipe = GetValidRecipe(target.SCANNABLE_RECIPENAME)
	else
		recipe = AllRecipes[target.prefab]
		if recipe and recipe.source_recipename then --in case of deconstruction recipe for a deployed item
			recipe = GetValidRecipe(recipe.source_recipename)
		end
	end
	if recipe == nil then
		return false, "CANTLEARN"
	elseif doer.components.builder:KnowsRecipe(recipe, true) then
		return false, "KNOWN"
	elseif recipe.nounlock or FunctionOrValue(recipe.no_deconstruction, target) then
		return false, "CANTLEARN"
	elseif not doer.components.builder:CanLearn(recipe.name) then
		return false, "CANTLEARN"
	end
	doer.components.builder:UnlockRecipe(recipe.name)
	target:PushEvent("onrecipescanned", { scanner = self.inst, doer = doer, recipe = recipe.name })
	if self.onscanned then
		self.onscanned(self.inst, target, doer, recipe.name)
	end
	return true
end

return RecipeScanner
