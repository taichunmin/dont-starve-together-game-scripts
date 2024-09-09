-- This Is a list of crockpot recipes, similar to preparedfoods
-- However, keys in this list must reference prefabs that are defined elsewhere,
-- as these entries are not implicitly turned into prefabs.

local items =
{
    batnosehat =
    {
        test = function(cooker, names, tags)
            return names.batnose and names.kelp
                    and (tags.dairy and tags.dairy >= 1)
        end,
        priority = 55,
        cooktime = 2,
        perishtime = TUNING.PERISH_SLOW,
        cookpot_perishtime = 0,
        floater = {"med", 0.05, 0.7},
        overridebuild = "hat_batnose",
        overridesymbolname = "swap_cookpot",
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_HUNGER_REGEN,

        noprefab = true,
        -- Unused stats, for cookbook. See hats.lua for behaviour.
        health = 0,
        hunger = TUNING.HUNGERREGEN_TICK_VALUE,
        sanity = 0,
    },

	dustmeringue =
	{
		test = function(cooker, names, tags) return (names.refined_dust) end,
		priority = 100,
		foodtype = FOODTYPE.ELEMENTAL,
		perishtime = nil,
		cooktime = 2,
		overridebuild = "cook_pot_food6",
		floater = {"small", 0.05, 1},
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_DUST_MOTH_FOOD,

		health = 0,
		hunger = TUNING.CALORIES_SMALL,
		sanity = 0,
	},
}

for k, v in pairs(items) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

    v.cookbook_category = "cookpot"
end

return items
