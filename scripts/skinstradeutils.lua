require("skinsutils")
require("trade_recipes")

function GetNumberSelectedItems(selections)
	local count = 0
	for k,v in pairs(selections) do
		count = count + 1
	end

	return count
end


--Returns the recipe name from the basic recipe list in trade_recipes.lua
function GetBasicRecipeMatch(selections)
	local rarity = nil
	for _,item in pairs(selections) do
		rarity = GetRarityForItem(item.item)
		break
	end

	if rarity ~= nil then
		for rule_name, rule_contents in pairs(TRADE_RECIPES) do
			if rule_contents.inputs.rarity == rarity then
				return rule_name
			end
		end
	end

	return nil
end


--currently only returns a single filter
function GetBasicFilters(recipe_name)
	if recipe_name ~= nil then
		return { {TRADE_RECIPES[recipe_name].inputs.rarity} }
	else
		return { {"Common"}, {"Classy"}, {"Spiffy"} }
	end
end

function GetSpecialFilters(recipe_data, selected_items)
	local filters = {}

	if recipe_data ~= nil then
		local satisfied_restrictions = GetSatisfiedRestrictions(recipe_data, selected_items)

		for k,restriction in pairs(recipe_data.Restrictions) do

			if not satisfied_restrictions[k] then

				local filters_list = {}

				local type_tag = nil
				for _, tag in pairs(restriction.Tags) do
					type_tag = GetTypeFromTag(tag)
					if type_tag ~= nil then
						break
					end
				end

				if restriction.ItemType
					and IsItemId(restriction.ItemType)
					and not table.contains(filters, type_tag)
				then -- ItemType is the item id
					table.insert(filters_list, restriction.ItemType)
				end

				if type_tag ~= nil and not table.contains(filters, type_tag) then
					table.insert(filters_list, type_tag)
				end

				-- TODO: add colour
				if not table.contains(filters, restriction.Rarity) then
					table.insert(filters_list, restriction.Rarity)
				end

				table.insert(filters, filters_list)
			end
		end
	end

	return filters

end

--[[function GetSatisfiedRestrictions(recipe_data, selected_items)
	local used_items = {}
	local satisfied_restrictions = {}
	for res_id,restriction in pairs(recipe_data.Restrictions) do
		if not satisfied_restrictions[res_id] then
			for index, data in pairs(selected_items) do
				if not used_items[index] then
					local matches = does_item_match_restriction( restriction, data )
					if matches then
						used_items[index] = true
						satisfied_restrictions[res_id] = true
						break
					end
				end
			end
		end
	end
	return satisfied_restrictions
end]]

-- Moved this out of tradescreen since recipelist also needs to access it now.
--[[function does_item_match_restriction( restriction, item )
	local matched_item = true
	if restriction.ItemType ~= "" then
		--print( "looking for item", restriction.ItemType )
		if item.item ~= restriction.ItemType then
			matched_item = false
		end
	elseif next(restriction.Tags) ~= nil then
		--print( "looking for tags" )
		for _,tag in pairs(restriction.Tags) do
			local type = GetTypeForItem( item.item )
			if tag ~= GetTagFromType(type) then
				matched_item = false
			end
			--CURRENTLY THIS ONLY SUPPORTS THE TYPE TAG FOR CLOTHING, DO COLOUR NEXT
		end
	else
		--print( "looking for rarity" )
		--restriction.Rarity
		--Assume the rarity is correct from the filtering
	end
	return matched_item
end]]