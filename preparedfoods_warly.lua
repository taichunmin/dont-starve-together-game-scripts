local foods =
{
    -- Swaps sanity and health
    nightmarepie =
    {
        test = function(cooker, names, tags) return names.nightmarefuel and names.nightmarefuel == 2 and (names.potato or names.potato_cooked) and (names.onion or names.onion_cooked) end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_TINY,
        hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = 2,
		oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_SWAP_HEALTH_AND_SANITY,
        oneatenfn = function(inst, eater)
            if eater.components.sanity ~= nil and eater.components.health ~= nil and eater.components.oldager == nil then
                local sanity_percent = eater.components.sanity:GetPercent()
                local health_percent = eater.components.health:GetPercent()
                --Use DoDelta so that we don't bypass invincibility
                --and to make sure we get the correct HUD triggers.
                eater.components.sanity:DoDelta(health_percent * eater.components.sanity.max - eater.components.sanity.current)
                eater.components.health:DoDelta(sanity_percent * eater.components.health.maxhealth - eater.components.health.currenthealth, nil, "nightmarepie")
            end
        end,
        tags = { "masterfood", "unsafefood" },
        floater = {nil, 0.1, 0.9},
    },

	-- Lightning attack
	voltgoatjelly =
	{
		test = function(cooker, names, tags) return (names.lightninggoathorn) and (tags.sweetener and tags.sweetener >= 2) and not tags.meat end,
		priority = 30,
		foodtype = FOODTYPE.GOODIES,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = 2,
        potlevel = "high",
		tags = {"masterfood"},
		prefabs = { "buff_electricattack" },
		oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_ELECTRIC_ATTACK,
        oneatenfn = function(inst, eater)
            eater:AddDebuff("buff_electricattack", "buff_electricattack")
       	end,
        floater = {"med", nil, 0.65},
	},

    -- Produces light
    glowberrymousse =
    {
        test = function(cooker, names, tags) return (names.wormlight or (names.wormlight_lesser and names.wormlight_lesser >= 2)) and (tags.fruit and tags.fruit >= 2) and not tags.meat and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_FASTISH,
        sanity = TUNING.SANITY_SMALL,
        cooktime = 1,
        potlevel = "low",
        prefabs = { "wormlight_light_greater" },
		oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_GLOW,
        oneatenfn = function(inst, eater)
            --see wormlight.lua for original code
            if eater.wormlight ~= nil then
                if eater.wormlight.prefab == "wormlight_light_greater" then
                    eater.wormlight.components.spell.lifetime = 0
                    eater.wormlight.components.spell:ResumeSpell()
                    return
                else
                    eater.wormlight.components.spell:OnFinish()
                end
            end

            local light = SpawnPrefab("wormlight_light_greater")
            light.components.spell:SetTarget(eater)
            if light:IsValid() then
                if light.components.spell.target == nil then
                    light:Remove()
                else
                    light.components.spell:StartSpell()
                end
            end
        end,
        tags = { "masterfood" },
        floater = {nil, 0.1, 0.75},
    },

    frogfishbowl =
    {
        test = function(cooker, names, tags) return ((names.froglegs and names.froglegs >= 2) or (names.froglegs_cooked and names.froglegs_cooked >= 2 ) or (names.froglegs and names.froglegs_cooked)) and tags.fish and tags.fish >= 1 and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        sanity = -TUNING.SANITY_SMALL,
        perishtime = TUNING.PERISH_FASTISH,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        prefabs = { "buff_moistureimmunity" },
		oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_DRY,
        oneatenfn = function(inst, eater)
            eater:AddDebuff("buff_moistureimmunity", "buff_moistureimmunity")
       	end,
        floater = {nil, 0.1},
    },

    dragonchilisalad =
    {
        test = function(cooker, names, tags) return (names.dragonfruit or names.dragonfruit_cooked) and (names.pepper or names.pepper_cooked) and not tags.meat and not tags.inedible and not tags.egg end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = -TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_MED,
        sanity = TUNING.SANITY_SMALL,
        temperature = TUNING.HOT_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        nochill = true,
        perishtime = TUNING.PERISH_SLOW,
        cooktime = 0.75,
        potlevel = "low",
        tags = { "masterfood" },
        floater = {nil, 0.1, 0.7},
    },

    gazpacho =
    {
        test = function(cooker, names, tags) return ((names.asparagus and names.asparagus >= 2) or (names.asparagus_cooked and names.asparagus_cooked >= 2) or (names.asparagus and names.asparagus_cooked)) and (tags.frozen and tags.frozen >= 2) end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_MED,
        sanity = TUNING.SANITY_SMALL,
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.BUFF_FOOD_TEMP_DURATION,
        perishtime = TUNING.PERISH_SLOW,
        cooktime = 0.5,
        potlevel = "low",
        tags = { "masterfood" },
        floater = {nil, 0.1, 0.7},
    },


    -- Neutral foods
    potatosouffle =
    {
        test = function(cooker, names, tags) return ((names.potato and names.potato >= 2) or (names.potato_cooked and names.potato_cooked >= 2) or (names.potato and names.potato_cooked)) and tags.egg and not tags.meat and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        floater = {nil, 0.1, 0.65},
    },

    -- Slightly better version of monster lasagna
    monstertartare =
    {
        test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        secondaryfoodtype = FOODTYPE.MONSTER,
        health = -TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_SMALL * 5,
        perishtime = TUNING.PERISH_MED,
        sanity = -TUNING.SANITY_MEDLARGE,
        cooktime = 0.5,
        tags = { "masterfood", "monstermeat" },
        floater = {"med", nil, {0.65, 0.5, 0.65}},
    },


    freshfruitcrepes =
    {
        test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 1.5 and names.butter and names.honey end,
        priority = 30,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_SUPERHUGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 2,
        potlevel = "high",
        tags = { "masterfood" },
        --floater = nil,
    },

    bonesoup =
    {
        test = function(cooker, names, tags) return names.boneshard and names.boneshard == 2 and (names.onion or names.onion_cooked) and (tags.inedible and tags.inedible < 3) end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDSMALL * 4,
        hunger = TUNING.CALORIES_LARGE * 4,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_TINY,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        floater = {nil, 0.05},
    },

    moqueca =
    {
        test = function(cooker, names, tags) return tags.fish and (names.onion or names.onion_cooked) and (names.tomato or names.tomato_cooked) and not tags.inedible end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED * 3,
        hunger = TUNING.CALORIES_LARGE * 3,
        perishtime = TUNING.PERISH_FASTISH,
        sanity = TUNING.SANITY_LARGE,
        cooktime = 2,
        potlevel = "low",
        tags = { "masterfood" },
        floater = {nil, 0.1},
    },

}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

	v.cookbook_category = "portablecookpot"
end

return foods
