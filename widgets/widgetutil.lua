
function ShouldHintRecipe(recipetree, buildertree)
	if Profile:GetCraftingHintAllRecipesEnabled() then
		return true;
	end

    for k, v in pairs(recipetree) do
        local v1 = buildertree[tostring(k)]
        if v ~= nil and v1 ~= nil and v > v1 + 1 then
            return false
        end
    end
    return true
end

function CanPrototypeRecipe(recipetree, buildertree)
    for k, v in pairs(recipetree) do
        local v1 = buildertree[tostring(k)]
        if v ~= nil and v1 ~= nil and v > v1 then
            return false
        end
    end
    return true
end

local lastsoundtime = nil
-- return values: "keep_crafting_menu_open", "error message"
function DoRecipeClick(owner, recipe, skin)
    if recipe ~= nil and owner ~= nil and owner.replica.builder ~= nil then
        if skin == recipe.name then
            skin = nil
        end
        if owner:HasTag("busy") or owner.replica.builder:IsBusy() then
            return true
        end
        if owner.components.playercontroller ~= nil then
            local iscontrolsenabled, ishudblocking = owner.components.playercontroller:IsEnabled()
            if not (iscontrolsenabled or ishudblocking) then
                --Ignore button click when controls are disabled
                --but not just because of the HUD blocking input
                return true
            end
        end

        local buffered = owner.replica.builder:IsBuildBuffered(recipe.name)
        local knows = buffered or owner.replica.builder:KnowsRecipe(recipe)
        local has_ingredients = buffered or owner.replica.builder:HasIngredients(recipe)

        if not has_ingredients and TheWorld.ismastersim then
            owner:PushEvent("cantbuild", { owner = owner, recipe = recipe })
            --You might have the materials now. Check again.
            has_ingredients = owner.replica.builder:HasIngredients(recipe)
        end

		if buffered then
			SetCraftingAutopaused(false)
			Profile:SetLastUsedSkinForItem(recipe.name, skin)

            if recipe.placer == nil then
                owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
            elseif owner.components.playercontroller ~= nil then
                owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
            end
			return false -- close the crafting menu
		elseif knows then
			if has_ingredients then
                --TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				SetCraftingAutopaused(false)
				Profile:SetLastUsedSkinForItem(recipe.name, skin)

                if recipe.placer == nil then
                    owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
                    return true
                elseif owner.components.playercontroller ~= nil then
                    --owner.HUD.controls.craftingmenu.tabs:DeselectAll()
                    owner.replica.builder:BufferBuild(recipe.name)
                    if not owner.replica.builder:IsBuildBuffered(recipe.name) then
                        return true
                    end
                    owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
                end
			else
				local tech_level = owner.replica.builder:GetTechTrees()
				for i, ing in ipairs(recipe.ingredients) do
					local ing_recipe = GetValidRecipe(ing.type)
					if ing_recipe ~= nil
						and not owner.replica.inventory:Has(ing.type, math.max(1, RoundBiasedUp(ing.amount * owner.replica.builder:IngredientMod())), true)
						and (owner.replica.builder:KnowsRecipe(ing_recipe) or CanPrototypeRecipe(ing_recipe.level, tech_level)) and owner.replica.builder:HasIngredients(ing_recipe) then
						owner.replica.builder:MakeRecipeFromMenu(recipe, skin) -- tell the server to build the current recipe, not the ingredient
						return true
					end
				end
			
				return true, "NO_INGREDIENTS"
			end
		else
            local tech_level = owner.replica.builder:GetTechTrees()
            if CanPrototypeRecipe(recipe.level, tech_level) then
				if has_ingredients then
					SetCraftingAutopaused(false)
					Profile:SetLastUsedSkinForItem(recipe.name, skin)

					if recipe.placer == nil then
						owner.replica.builder:MakeRecipeFromMenu(recipe, skin)
						if recipe.nounlock then
							return true
						end
					elseif owner.components.playercontroller ~= nil then
						owner.replica.builder:BufferBuild(recipe.name)
						if not owner.replica.builder:IsBuildBuffered(recipe.name) then
							return true
						end
						owner.components.playercontroller:StartBuildPlacementMode(recipe, skin)
						if owner.components.builder ~= nil then
							owner.components.builder:ActivateCurrentResearchMachine(recipe)
							owner.components.builder:UnlockRecipe(recipe.name)
						end
					end
					if not recipe.nounlock then
						if lastsoundtime == nil or GetStaticTime() - lastsoundtime >= 1 then
							lastsoundtime = GetStaticTime()
							TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/research_unlock")
						end
					end

					return recipe.placer == nil -- close the crafting menu if there is a placer
				else
					-- check if we can craft sub ingredients
					for i, ing in ipairs(recipe.ingredients) do
						local ing_recipe = GetValidRecipe(ing.type)
						if ing_recipe ~= nil
							and not owner.replica.inventory:Has(ing.type, math.max(1, RoundBiasedUp(ing.amount * owner.replica.builder:IngredientMod())), true)
							and (owner.replica.builder:KnowsRecipe(ing_recipe) or CanPrototypeRecipe(ing_recipe.level, tech_level)) and owner.replica.builder:HasIngredients(ing_recipe) then
							owner.replica.builder:MakeRecipeFromMenu(recipe, skin) -- tell the server to build the current recipe, not the ingredient
							return true
						end
					end

					return true, "NO_INGREDIENTS"
				end
            else
                return true, recipe.nounlock and "NO_STATION" or "NO_TECH"
            end
        end
    end
end