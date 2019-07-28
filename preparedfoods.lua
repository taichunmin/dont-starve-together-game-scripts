local foods =
{
	butterflymuffin =
	{
		test = function(cooker, names, tags) return names.butterflywings and not tags.meat and tags.veggie end,
		priority = 1,
		weight = 1,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	frogglebunwich =
	{
		test = function(cooker, names, tags) return (names.froglegs or names.froglegs_cooked) and tags.veggie end,
		priority = 1,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
        potlevel = "high",
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
		tags = {"honeyed"}
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
		tags = {"honeyed"}
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
		tags = {"catfood"}
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
		tags = {"honeyed"}
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
		tags = {"honeyed"}
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
	},
	perogies =
	{
		test = function(cooker, names, tags) return tags.egg and tags.meat and tags.veggie and not tags.inedible end,
		priority = 5,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
        potlevel = "high",
	},
	turkeydinner =
	{
		test = function(cooker, names, tags) return names.drumstick and names.drumstick > 1 and tags.meat and tags.meat > 1 and (tags.veggie or tags.fruit) end,
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
	},
	ratatouille =
	{
		test = function(cooker, names, tags) return not tags.meat and tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
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
	},
	fishtacos =
	{
		test = function(cooker, names, tags) return tags.fish and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
        potlevel = "high",
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
	},	
	
	monsterlasagna =
	{
		test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and not tags.inedible end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = -TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = -TUNING.SANITY_MEDLARGE,
		cooktime = .5,
		tags = {"monstermeat"},
	},

	powcake =
	{
		test = function(cooker, names, tags) return names.twigs and names.honey and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = -TUNING.HEALING_SMALL,
		hunger = 0,
		perishtime = 9000000,
		sanity = 0,
		cooktime = 0.5,
        potlevel = "low",
		tags = {"honeyed"}
	},

	unagi =
	{
		test = function(cooker, names, tags) return names.cutlichen and (names.eel or names.eel_cooked) end,
		priority = 20,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
	},
	
	wetgoop =
	{
		test = function(cooker, names, tags) return true end,
		priority = -2,
		health=0,
		hunger=0,
		perishtime = TUNING.PERISH_FAST,
		sanity = 0,
		cooktime = .25,
		wet_prefix = STRINGS.WET_PREFIX.WETGOOP,
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
	},	

	icecream =
	{
		test = function(cooker, names, tags) return tags.frozen and tags.dairy and tags.sweetener and not tags.meat and not tags.veggie and not tags.inedible and not tags.egg end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = 0,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_HUGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .5,
        potlevel = "low",
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
	},	

	trailmix =
	{
		test = function(cooker, names, tags) return names.acorn_cooked and tags.seed and tags.seed >= 1 and (names.berries or names.berries_cooked or names.berries_juicy or names.berries_juicy_cooked) and tags.fruit and tags.fruit >= 1 and not tags.meat and not tags.veggie and not tags.egg and not tags.dairy end,
		priority = 10,
		foodtype = FOODTYPE.VEGGIE,
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
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
	},	

	guacamole = 
	{
		test = function(cooker, names, tags) return names.mole and names.cactus_meat and not tags.fruit end,
		priority = 10,
		foodtype = FOODTYPE.MEAT,
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = 0,
		cooktime = .5,
        potlevel = "low",
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
        oneatenfn = function(inst, eater)
            if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
                not (eater.components.health ~= nil and eater.components.health:IsDead()) and
                not eater:HasTag("playerghost") then
                eater.components.debuffable:AddDebuff("healthregenbuff", "healthregenbuff")
            end
        end,
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
	},

	bananapop = 
	{
		test = function(cooker, names, tags) return (names.cave_banana or names.cave_banana_cooked) and tags.frozen and names.twigs and not tags.meat and not tags.fish and (tags.inedible and tags.inedible <= 2) end,
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
	}
}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0
end

return foods
