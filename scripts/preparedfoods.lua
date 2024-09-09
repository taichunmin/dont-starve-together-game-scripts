local foods =
{
	butterflymuffin =
	{
		test = function(cooker, names, tags) return (names.butterflywings or names.moonbutterflywings) and not tags.meat and tags.veggie and tags.veggie >= 0.5 end,
		priority = 1,
		weight = 1,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        floater = {"small", 0.05, 0.7},
		card_def = {ingredients = {{"butterflywings", 1}, {"carrot", 2}, {"berries", 1}} },
	},

	frogglebunwich =
	{
		test = function(cooker, names, tags) return (names.froglegs or names.froglegs_cooked) and tags.veggie and tags.veggie >= 0.5 end,
		priority = 1,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", nil, 0.55},
		card_def = {ingredients = {{"froglegs", 1}, {"red_cap", 2}, {"carrot", 1}} },
	},

	taffy =
	{
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >= 3 and not tags.meat end,
		priority = 10,
		foodtype = FOODTYPE.GOODIES,
		health = -TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*2,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		tags = {"honeyed"},
        floater = {"med", nil, 0.6},
		card_def = {ingredients = {{"honey", 3}, {"berries", 1}} },
	},

	pumpkincookie =
	{
		test = function(cooker, names, tags) return (names.pumpkin or names.pumpkin_cooked) and tags.sweetener and tags.sweetener >= 2 end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = 0,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		tags = {"honeyed"},
        floater = {"med", nil, 0.65},
		card_def = {ingredients = {{"pumpkin", 1}, {"honey", 2}, {"berries", 1}} },
	},

	stuffedeggplant =
	{
		test = function(cooker, names, tags) return (names.eggplant or names.eggplant_cooked) and tags.veggie and tags.veggie > 1 end,
		priority = 1,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_BRIEF,
		cooktime = 2,
        floater = {"small", nil, 0.8},
		card_def = {ingredients = {{"eggplant", 1}, {"potato", 1}, {"onion", 1}, {"garlic", 1}} },
	},

	fishsticks =
	{
		test = function(cooker, names, tags) return tags.fish and names.twigs and (tags.inedible and tags.inedible <= 1) end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        potlevel =  "high",
		tags = {"catfood"},
        floater = {"small", nil, nil},
		card_def = {ingredients = {{"fishmeat_small", 3}, {"twigs", 1}} },
	},

	honeynuggets =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat <= 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        potlevel = "high",
		tags = {"honeyed"},
        floater = {"med", nil, 0.7},
		card_def = {ingredients = {{"honey", 2}, {"smallmeat", 2}} },
	},

	honeyham =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat > 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 2,
		tags = {"honeyed"},
        floater = {"small", nil, nil},
		card_def = {ingredients = {{"honey", 2}, {"meat", 2}} },
	},

	dragonpie =
	{
		test = function(cooker, names, tags)  return (names.dragonfruit or names.dragonfruit_cooked) and not tags.meat end,
		priority = 1,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 2,
        floater = {"med", nil, 0.8},
		card_def = {ingredients = {{"dragonfruit", 2}, {"potato", 1},  {"pepper", 1}} },
	},
	kabobs =
	{
		test = function(cooker, names, tags) return tags.meat and names.twigs and (not tags.monster or tags.monster <= 1) and (tags.inedible and tags.inedible <= 1) end,
		priority = 5,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", nil, 0.55},
		card_def = {ingredients = {{"meat", 1}, {"onion", 1}, {"eggplant", 1},  {"twigs", 1}} },
	},
	mandrakesoup =
	{
		test = function(cooker, names, tags) return names.mandrake end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SUPERHUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = 3,
        potlevel = "low",
        floater = {"small", nil, nil},
	},
	baconeggs =
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg > 1 and tags.meat and tags.meat > 1 and not tags.veggie end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", nil, 0.6},
	},
	meatballs =
	{
		test = function(cooker, names, tags) return tags.meat and not tags.inedible end,
		priority = -1,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*5,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
        potlevel = "high",
        floater = {"small", nil, nil},
	},
	bonestew =
	{
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 3 and not tags.inedible end,
		priority = 0,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_SMALL*4,
		hunger = TUNING.CALORIES_LARGE*4,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
        potlevel = "low",
        floater = {"small", 0.1, 0.8},
	},
	perogies =
	{
		test = function(cooker, names, tags) return tags.egg and tags.meat and tags.veggie and tags.veggie >= 0.5 and not tags.inedible end,
		priority = 5,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
        potlevel = "high",
        floater = {"med", nil, 0.65},
	},
	turkeydinner =
	{
		test = function(cooker, names, tags) return names.drumstick and names.drumstick > 1 and tags.meat and tags.meat > 1 and ((tags.veggie and tags.veggie >= 0.5) or tags.fruit) end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 3,
        potlevel = "high",
        floater = {"med", nil, 0.75},
		card_def = {ingredients = {{"drumstick", 2}, {"meat", 1}, {"berries", 1}} },
	},
	ratatouille =
	{
		test = function(cooker, names, tags) return not tags.meat and tags.veggie and tags.veggie >= 0.5 and not tags.inedible end,
		priority = 0,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
        floater = {"med", nil, 0.68},
	},
	jammypreserves =
	{
		test = function(cooker, names, tags) return tags.fruit and not tags.meat and not tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*3,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        floater = {"small", nil, nil},
	},

	fruitmedley =
	{
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 3 and not tags.meat and not tags.veggie end,
		priority = 0,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_BRIEF,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", nil, 0.6},
	},
	fishtacos =
	{
		test = function(cooker, names, tags) return tags.fish and (names.corn or names.corn_cooked or names.oceanfish_small_5_inv or names.oceanfish_medium_5_inv) end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        potlevel = "high",
        floater = {"small", nil, nil},
		card_def = {ingredients = {{"fishmeat_small", 2}, {"corn", 1}, {"onion", 1}} },
	},
	waffles =
	{
		test = function(cooker, names, tags) return names.butter and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked) and tags.egg end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        potlevel = "high",
        floater = {"med", nil, 0.75},
	},

	monsterlasagna =
	{
		test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and not tags.inedible end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		secondaryfoodtype = FOODTYPE.MONSTER,
		health = -TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = -TUNING.SANITY_MEDLARGE,
		cooktime = .5,
		tags = {"monstermeat"},
        floater = {"med", nil, 0.58},
	},

	powcake =
	{
		test = function(cooker, names, tags) return names.twigs and names.honey and (names.corn or names.corn_cooked or names.oceanfish_small_5_inv or names.oceanfish_medium_5_inv) end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = -TUNING.HEALING_SMALL,
		hunger = 0,
		perishtime = 9000000,
		sanity = 0,
		cooktime = 0.5,
        potlevel = "low",
		tags = {"honeyed", "donotautopick"},
        floater = {"med", nil, 0.65},
		card_def = {ingredients = {{"honey", 1}, {"corn", 1}, {"twigs", 2}} },
	},

	unagi =
	{
		test = function(cooker, names, tags) return (names.cutlichen or names.kelp or names.kelp_cooked or names.kelp_dried) and (names.eel or names.eel_cooked or names.pondeel) end,
		priority = 20,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
        floater = {"med", nil, 0.67},
	},

	wetgoop =
	{
		test = function(cooker, names, tags) return true end,
		priority = -10,
		health=0,
		hunger=0,
		perishtime = TUNING.PERISH_FAST,
		sanity = 0,
		cooktime = .25,
		wet_prefix = STRINGS.WET_PREFIX.WETGOOP,
        floater = {"small", nil, nil},
	},

	flowersalad =
	{
		test = function(cooker, names, tags) return names.cactus_flower and tags.veggie and tags.veggie >= 2 and not tags.meat and not tags.inedible and not tags.egg and not tags.sweetener and not tags.fruit end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", nil, nil},
	},

	icecream =
	{
		test = function(cooker, names, tags) return tags.frozen and tags.dairy and tags.sweetener and not tags.meat and not tags.veggie and not tags.inedible and not tags.egg end,
		priority = 10,
		foodtype = FOODTYPE.GOODIES,
		health = 0,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_HUGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", nil, nil},
	},

	watermelonicle =
	{
		test = function(cooker, names, tags) return names.watermelon and tags.frozen and names.twigs and not tags.meat and not tags.veggie and not tags.egg end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_MEDLARGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", 0.1, 0.82},
	},

	trailmix =
	{
		test = function(cooker, names, tags) return (names.acorn or names.acorn_cooked) and tags.seed and tags.seed >= 1 and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked) and tags.fruit and tags.fruit >= 1 and not tags.meat and not tags.veggie and not tags.egg and not tags.dairy end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        floater = {"small", 0.05, nil},
		card_def = {ingredients = {{"acorn_cooked", 2}, {"berries", 2}} },
	},

	hotchili =
	{
		test = function(cooker, names, tags) return tags.meat and tags.veggie and tags.meat >= 1.5 and tags.veggie >= 1.5 end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = 0,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", nil, nil},
		card_def = {ingredients = {{"meat", 2}, {"tomato", 1}, {"pepper", 1}} },
	},

	guacamole =
	{
		test = function(cooker, names, tags) return names.mole and (names.rock_avocado_fruit_ripe or names.cactus_meat) and not tags.fruit end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = 0,
		cooktime = .5,
        potlevel = "low",
        floater = {"small", nil, 0.85},
		card_def = {ingredients = {{"mole", 1}, {"rock_avocado_fruit_ripe", 2}, {"corn", 1}} },
	},

	jellybean =
	{
		test = function(cooker, names, tags) return names.royal_jelly and not tags.inedible and not tags.monster end,
		priority = 12,
		foodtype = FOODTYPE.GOODIES,
		health = TUNING.JELLYBEAN_TICK_VALUE,
		hunger = 0,
		perishtime = nil, -- not perishable
		sanity = TUNING.SANITY_TINY,
		cooktime = 2.5,
        potlevel = "low",
		tags = {"honeyed"},
		stacksize = 3,
        prefabs = { "healthregenbuff" },
		oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_HEALTH_REGEN,
        oneatenfn = function(inst, eater)
			eater:AddDebuff("healthregenbuff", "healthregenbuff")
        end,
        floater = {"small", nil, 0.85},
		scrapbook_healthvalue = 122, -- First tick + total ticks
	},

    --new!
    potatotornado =
    {
        test = function(cooker, names, tags) return (names.potato or names.potato_cooked) and names.twigs and (not tags.monster or tags.monster <= 1) and not tags.meat and (tags.inedible and tags.inedible <= 2) end,
        priority = 10,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_SMALL,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = .75,
        floater = {nil, 0.05},
    },

    mashedpotatoes =
    {
        test = function(cooker, names, tags) return ((names.potato and names.potato > 1) or (names.potato_cooked and names.potato_cooked > 1) or (names.potato and names.potato_cooked)) and (names.garlic or names.garlic_cooked) and not tags.meat and not tags.inedible end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_LARGE,
        cooktime = 1,
        potlevel = "low",
        floater = {nil, 0.1, {0.7, 0.6, 0.7}},
    },

    asparagussoup =
	{
		test = function(cooker, names, tags) return (names.asparagus or names.asparagus_cooked) and tags.veggie and tags.veggie > 2 and not tags.meat and not tags.inedible end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
        potlevel = "low",
        floater = {nil, 0.05, {0.75, 0.65, 0.75}},
		card_def = {ingredients = {{"asparagus", 2}, {"potato", 1}, {"onion", 1}} },
	},

	vegstinger =
	{
		test = function(cooker, names, tags) return (names.asparagus or names.asparagus_cooked or names.tomato or names.tomato_cooked) and tags.veggie and tags.veggie > 2 and tags.frozen and not tags.meat and not tags.inedible and not tags.egg end,
		priority = 15,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_LARGE,
		cooktime = 0.5,
        potlevel = "low",
        floater = {nil, 0.1, 0.6},
	},

	bananapop =
	{
		test = function(cooker, names, tags) return (names.cave_banana or names.cave_banana_cooked) and tags.frozen and names.twigs and not tags.meat and not tags.fish end,
		priority = 20,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_LARGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 0.5,
        potlevel = "low",
        floater = {nil, 0.05, 0.95},
		card_def = {ingredients = {{"cave_banana", 1}, {"ice", 2}, {"twigs", 1}} },
	},

    frozenbananadaiquiri =
    {
        test = function(cooker, names, tags) return (names.cave_banana or names.cave_banana_cooked) and (tags.frozen and tags.frozen >= 1) and not tags.meat and not tags.fish end,
        priority = 2,
        overridebuild = "cook_pot_food9",
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MEDLARGE,
        hunger = TUNING.CALORIES_MEDSMALL,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_MED,
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.FOOD_TEMP_LONG,
        cooktime = 1,
        floater = {"small", 0.05, 0.7},
    },

    bananajuice =
    {
        test = function(cooker, names, tags) return ((names.cave_banana or 0) + (names.cave_banana_cooked or 0) >= 2) and not tags.meat and not tags.fish and not tags.monster end,
        priority = 1,
        overridebuild = "cook_pot_food10",
        foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MEDSMALL,
		hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_SLOW, 
		sanity = TUNING.SANITY_LARGE,
        cooktime = 0.5,
        floater = {"med", 0.05, 0.55},
    },

	ceviche =
	{
		test = function(cooker, names, tags) return tags.fish and tags.fish >= 2 and tags.frozen and not tags.inedible and not tags.egg end,
		priority = 20,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 0.5,
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
	},

	salsa =
	{
		test = function(cooker, names, tags) return (names.tomato or names.tomato_cooked) and (names.onion or names.onion_cooked) and not tags.meat and not tags.inedible and not tags.egg end,
		priority = 20,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_LARGE,
		cooktime = 0.5,
        potlevel = "low",
        floater = {nil, 0.1, {0.7, 0.6, 0.7}},
	},

	pepperpopper =
	{
		test = function(cooker, names, tags) return (names.pepper or names.pepper_cooked) and tags.meat and tags.meat <= 1.5 and not tags.inedible end,
		priority = 20,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = -TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = 2,
        --floater = nil,
		card_def = {ingredients = {{"pepper", 1}, {"smallmeat", 2}, {"potato", 1}} },
	},

	californiaroll =
	{
		test = function(cooker, names, tags) return ((names.kelp or 0) + (names.kelp_cooked or 0) + (names.kelp_dried or 0)) == 2 and (tags.fish and tags.fish >= 1) end,
		priority = 20,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = .5,
		overridebuild = "cook_pot_food2",
		potlevel = "high",
		floater = {"med", 0.05, {0.65, 0.6, 0.65}},
		card_def = {ingredients = {{"kelp", 2}, {"fishmeat_small", 2}} },
	},

	seafoodgumbo =
	{
		test = function(cooker, names, tags) return tags.fish and tags.fish > 2 end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MEDLARGE,
		cooktime = 1,
		overridebuild = "cook_pot_food2",
		floater = {"med", 0.05, {0.65, 0.6, 0.65}},
	},

	surfnturf =
	{
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 2.5 and tags.fish and tags.fish >= 1.5 and not tags.frozen end,
		priority = 30,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_LARGE,
		cooktime = 1,
		overridebuild = "cook_pot_food2",
		potlevel = "high",
		floater = {"med", 0.05, {0.65, 0.6, 0.65}},
	},

    lobsterbisque =
    {
        test = function(cooker, names, tags) return names.wobster_sheller_land and tags.frozen end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_MED,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_SMALL,
        cooktime = 0.5,
        overridebuild = "cook_pot_food3",
        potlevel = "high",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    lobsterdinner =
    {
        test = function(cooker, names, tags)
            return names.wobster_sheller_land and names.butter
                    and (tags.meat and tags.meat >= 1.0) and (tags.fish and tags.fish >= 1.0) and not tags.frozen
        end,
        priority = 25,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_HUGE,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_HUGE,
        cooktime = 1,
        overridebuild = "cook_pot_food3",
        potlevel = "high",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    barnaclepita =
    {
        test = function(cooker, names, tags)
            return (names.barnacle or names.barnacle_cooked)
                    and tags.veggie and tags.veggie >= 0.5
        end,
        priority = 25,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_SLOW,
        sanity = TUNING.SANITY_TINY,
        cooktime = 2,
        overridebuild = "cook_pot_food5",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    barnaclesushi =
    {
        test = function(cooker, names, tags)
            return (names.barnacle or names.barnacle_cooked)
            		and (names.kelp or names.kelp_cooked)
                    and tags.egg and tags.egg >= 1
        end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_LARGE,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED,
        sanity = TUNING.SANITY_MED,
        cooktime = 0.5,
        overridebuild = "cook_pot_food5",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
		card_def = {ingredients = {{"barnacle", 1}, {"kelp", 2}, {"bird_egg", 1}} },
    },

    barnaclinguine =
    {
        test = function(cooker, names, tags)
            return ((names.barnacle or 0) + (names.barnacle_cooked or 0) >= 2 )
                    and tags.veggie and tags.veggie >= 2
        end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDLARGE,
        hunger = TUNING.CALORIES_HUGE,
        perishtime = TUNING.PERISH_FAST,
        sanity = TUNING.HEALING_MED,
        cooktime = 2,
        overridebuild = "cook_pot_food5",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    barnaclestuffedfishhead =
    {
        test = function(cooker, names, tags)
            return (names.barnacle or names.barnacle_cooked)
                    and tags.fish and tags.fish >= 1.25
        end,
        priority = 26,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_LARGE*2,
        perishtime = TUNING.PERISH_SUPERFAST,
        sanity = 0,
        cooktime = 2,
        overridebuild = "cook_pot_food5",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
		card_def = {ingredients = {{"barnacle", 1}, {"fishmeat_small", 2}, {"potato", 1}} },
    },


    leafloaf =
    {
        test = function(cooker, names, tags)
            return ((names.plantmeat or 0) + (names.plantmeat_cooked or 0) >= 2 )
        end,
        priority = 25,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDSMALL,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_PRESERVED,
        sanity = TUNING.SANITY_TINY,
        cooktime = 2,
        overridebuild = "cook_pot_food4",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    leafymeatburger =
    {
        test = function(cooker, names, tags)
            return (names.plantmeat or names.plantmeat_cooked)
            		and (names.onion or names.onion_cooked)
                    and tags.veggie and tags.veggie >= 2
        end,
        priority = 26,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_MEDLARGE,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_FAST,
        sanity = TUNING.SANITY_LARGE,
        cooktime = 2,
        overridebuild = "cook_pot_food4",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    leafymeatsouffle =
    {
        test = function(cooker, names, tags)
            return ((names.plantmeat or 0) + (names.plantmeat_cooked or 0) >= 2 )
                    and tags.sweetener and tags.sweetener >= 2
        end,
        priority = 50,
        foodtype = FOODTYPE.MEAT,
        health = 0,
        hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_FAST,
        sanity = TUNING.SANITY_HUGE,
        cooktime = 2,
        overridebuild = "cook_pot_food4",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
    },

    meatysalad =
    {
        test = function(cooker, names, tags)
            return (names.plantmeat or names.plantmeat_cooked)
                    and tags.veggie and tags.veggie >= 3
        end,
        priority = 25,
        foodtype = FOODTYPE.MEAT,
        health = TUNING.HEALING_LARGE,
        hunger = TUNING.CALORIES_LARGE*2,
        perishtime = TUNING.PERISH_FAST,
        sanity = TUNING.SANITY_TINY,
        cooktime = 2,
        overridebuild = "cook_pot_food4",
        floater = {"med", 0.05, {0.65, 0.6, 0.65}},
		card_def = {ingredients = {{"plantmeat", 1}, {"tomato", 2}, {"carrot", 1}} },
	},

    shroomcake =
    {
        test = function(cooker, names, tags)
            return names.moon_cap and names.red_cap and names.blue_cap and names.green_cap
        end,
        priority = 30,
        foodtype = FOODTYPE.GOODIES,
        health = 0,
        hunger = TUNING.CALORIES_MED,
        sanity = TUNING.SANITY_SMALL,
        perishtime = TUNING.PERISH_SLOW,
        cooktime = 1,
        overridebuild = "cook_pot_food6",
        floater = {"med", 0.05, 1.0},

        prefabs = { "buff_sleepresistance" },
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_SLEEP_RESISTANCE,
        oneatenfn = function(inst, eater)
            if eater.components.grogginess ~= nil and
			not (eater.components.health ~= nil and eater.components.health:IsDead()) and
			not eater:HasTag("playerghost") then
				eater.components.grogginess:ResetGrogginess()
            end

			eater:AddDebuff("shroomsleepresist", "buff_sleepresistance")
        end,
    },

	sweettea =
	{
		test = function(cooker, names, tags) return names.forgetmelots and tags.sweetener and tags.frozen and not tags.monster and not tags.veggie and not tags.meat and not tags.fish and not tags.egg and not tags.fat and not tags.dairy and not tags.inedible end,
		priority = 1,
		overridebuild = "cook_pot_food7",
		--foodtype = FOODTYPE.GOODIES,
		health = TUNING.HEALING_SMALL,
		hunger = 0,
		sanity = TUNING.SANITY_MED,
		perishtime = TUNING.PERISH_SUPERFAST,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_BRIEF,
		cooktime = 1,
        potlevel = "low",
        floater = {"med", 0.05, 0.65},
        prefabs = { "sweettea_buff" },
		tags = {"honeyed"},
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_HOT_SANITY_REGEN,
        oneatenfn = function(inst, eater)
			eater:AddDebuff("sweettea_buff", "sweettea_buff")
        end,
		card_def = {ingredients = {{"forgetmelots", 1}, {"honey", 1}, {"ice", 2}} },
		scrapbook_sanityvalue = 45 -- first tick + total ticks
	},

	koalefig_trunk =
	{
		test = function(cooker, names, tags) return (names.trunk_summer or names.trunk_cooked or names.trunk_winter) and (names.fig or names.fig_cooked) end,
		priority = 40,
		overridebuild = "cook_pot_food8",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		sanity = TUNING.SANITY_MED,
		perishtime = TUNING.PERISH_SLOW,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", 0.05, 0.65},
	},

	figatoni =
	{
		test = function(cooker, names, tags) return (names.fig or names.fig_cooked) and tags.veggie and tags.veggie >= 2  and not tags.meat end,
		priority = 30,
		overridebuild = "cook_pot_food8",
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MEDLARGE,
        hunger = TUNING.CALORIES_LARGE + TUNING.CALORIES_MEDSMALL,
        sanity = TUNING.SANITY_MED,
        perishtime = TUNING.PERISH_FAST,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", 0.05, 0.65},
	},

	figkabab =
	{
		test = function(cooker, names, tags) return (names.fig or names.fig_cooked) and names.twigs and tags.meat and tags.meat >= 1 and (not tags.monster or tags.monster <= 1) end,
		priority = 30,
		overridebuild = "cook_pot_food8",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		sanity = TUNING.SANITY_SMALL,
		perishtime = TUNING.PERISH_SLOW,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = 1,
        potlevel = "high",
        floater = {"med", nil, 0.55},
		card_def = {ingredients = {{"fig", 1}, {"twigs", 1}, {"smallmeat", 2}} },
	},

	frognewton =
	{
		test = function(cooker, names, tags) return (names.fig or names.fig_cooked) and (names.froglegs or names.froglegs_cooked) end,
		priority = 1,
		overridebuild = "cook_pot_food8",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = 1,
        potlevel = "high",
        floater = {"med", nil, 0.55},
	},

    bunnystew =
    {
        test = function(cooker, names, tags)
            return (tags.meat and tags.meat < 1)
                and (tags.frozen and tags.frozen >= 2)
                and (not tags.inedible)
        end,
        priority = 1,
        overridebuild = "cook_pot_food9",
        foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
        perishtime = TUNING.PERISH_MED, 
		sanity = TUNING.SANITY_TINY,
        temperature = TUNING.HOT_FOOD_BONUS_TEMP,
        temperatureduration = TUNING.FOOD_TEMP_BRIEF,
        cooktime = 0.5,
        floater = {"med", 0.05, 0.55},
		card_def = {ingredients = {{"smallmeat", 1}, {"ice", 2}, {"tomato", 1}} },
    },

	justeggs = 
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg >= 3 end,
		priority = 0,
		overridebuild = "cook_pot_food11",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*4,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
        potlevel = "high",
        floater = {"med", nil, 0.85},
	},

	veggieomlet = 
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg >= 1 and tags.veggie and tags.veggie >= 1 and not tags.meat and not tags.dairy end,
		priority = 1,
		overridebuild = "cook_pot_food11",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
        potlevel = "high",
        floater = {"med", nil, 0.7},
	},

	talleggs = 
	{
		test = function(cooker, names, tags) return names.tallbirdegg and tags.veggie and tags.veggie >= 1 end,
		priority = 10,
		overridebuild = "cook_pot_food11",
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        floater = {"med", nil, 0.65},
	},

	beefalofeed = 
	{
		-- basic beefalo food
		test = function(cooker, names, tags) return tags.inedible and not tags.monster and not tags.meat and not tags.fish and not tags.egg and not tags.fat and not tags.dairy and not tags.magic end,
		priority = -5,
		overridebuild = "cook_pot_food11",
		foodtype = FOODTYPE.ROUGHAGE,
		secondaryfoodtype = FOODTYPE.WOOD,
		health = TUNING.HEALING_MEDLARGE/2,
		hunger = TUNING.CALORIES_MOREHUGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = 0,
		cooktime = 0.5,
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_BEEFALO,
		OnPutInInventory = function(inst, owner) if owner ~= nil and owner:IsValid() then owner:PushEvent("learncookbookstats", inst.food_basename or inst.prefab) end end,
		card_def = {ingredients = {{"twigs", 3}, {"acorn", 1}} },
	},

	beefalotreat = 
	{
		-- good beefalo food
		test = function(cooker, names, tags) return tags.inedible and tags.seed and names.forgetmelots and not tags.monster and not tags.meat and not tags.fish and not tags.egg and not tags.fat and not tags.dairy and not tags.magic end,
		priority = -4,
		foodtype = FOODTYPE.ROUGHAGE,
		overridebuild = "cook_pot_food11",
		health = TUNING.HEALING_MOREHUGE,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = 0,
		cooktime = 2,
        potlevel = "high",
        floater = {"med", nil, 0.85},
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_BEEFALO,
		OnPutInInventory = function(inst, owner) if owner ~= nil and owner:IsValid() then owner:PushEvent("learncookbookstats", inst.food_basename or inst.prefab) end end,
	},

    shroombait =
    {
        test = function(cooker, names, tags)
            return ((names.moon_cap or 0) >= 2 ) and names.monstermeat  --names.moon_cap
        end,
        priority = 30,
        foodtype = FOODTYPE.MEAT,
        health = -TUNING.HEALING_MED,
        hunger = TUNING.CALORIES_MEDSMALL,
        sanity = -TUNING.SANITY_MED,
        perishtime = TUNING.PERISH_SLOW,
        cooktime = 1,
        overridebuild = "cook_pot_food11",
        floater = {"med", 0.05, 1.0},
        oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_SLEEP,
        oneatenfn = function(inst, eater)
			if eater.components.sleeper ~= nil then
	            eater.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
	        elseif eater.components.grogginess ~= nil then
	            eater.components.grogginess:AddGrogginess(10, TUNING.PANFLUTE_SLEEPTIME)
	        else
	            eater:PushEvent("knockedout")
	        end
        end,
    },	

}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0

	v.cookbook_category = "cookpot"
end

return foods
