local costumes =
{
	WAR =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_1"] and ingredients["yotb_pattern_fragment_1"] > 1 and
				   ingredients["yotb_pattern_fragment_2"]
		end,

		priority = 1,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_war",
			"beefalo_body_war",
			"beefalo_horn_war",
			"beefalo_tail_war",
			"beefalo_feet_war",
		},
	},

	DOLL =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_2"] and ingredients["yotb_pattern_fragment_2"] > 1 and
				   ingredients["yotb_pattern_fragment_3"]
		end,
		priority = 2,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_doll",
			"beefalo_body_doll",
			"beefalo_horn_doll",
			"beefalo_tail_doll",
			"beefalo_feet_doll",
		},
	},

	ROBOT =
	{
		test = function(ingredients)
			-- Add more tech related fillers
			return ingredients["yotb_pattern_fragment_1"] and ingredients["yotb_pattern_fragment_1"] > 2
		end,

		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_robot",
			"beefalo_body_robot",
			"beefalo_horn_robot",
			"beefalo_tail_robot",
			"beefalo_feet_robot",
		},
	},

	NATURE =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_3"] and ingredients["yotb_pattern_fragment_3"] > 1 and
				   ingredients["yotb_pattern_fragment_2"]
		end,

		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_nature",
			"beefalo_body_nature",
			"beefalo_horn_nature",
			"beefalo_tail_nature",
			"beefalo_feet_nature",
		},
	},

	FORMAL =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_2"] and ingredients["yotb_pattern_fragment_2"] > 2
		end,
		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_formal",
			"beefalo_body_formal",
			"beefalo_horn_formal",
			"beefalo_tail_formal",
			"beefalo_feet_formal",
		},
	},

	VICTORIAN =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_1"] and ingredients["yotb_pattern_fragment_2"] and
				   ingredients["yotb_pattern_fragment_3"]
		end,

		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_victorian",
			"beefalo_body_victorian",
			"beefalo_horn_victorian",
			"beefalo_tail_victorian",
			"beefalo_feet_victorian",
		},
	},

	ICE =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_1"] and ingredients["yotb_pattern_fragment_1"] > 1 and
				   ingredients["yotb_pattern_fragment_3"]
		end,
		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_ice",
			"beefalo_body_ice",
			"beefalo_horn_ice",
			"beefalo_tail_ice",
			"beefalo_feet_ice",
		},
	},

	FESTIVE =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_3"] and ingredients["yotb_pattern_fragment_3"] > 2
		end,
		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_festive",
			"beefalo_body_festive",
			"beefalo_horn_festive",
			"beefalo_tail_festive",
			"beefalo_feet_festive",
		},
	},

	BEAST =
	{
		test = function(ingredients)
			return ingredients["yotb_pattern_fragment_3"] and ingredients["yotb_pattern_fragment_3"] > 1 and
				   ingredients["yotb_pattern_fragment_1"]
		end,
		priority = 3,
		time = TUNING.BASE_SEWING_TIME,
		skins = {
			"beefalo_head_beast",
			"beefalo_body_beast",
			"beefalo_horn_beast",
			"beefalo_tail_beast",
			"beefalo_feet_beast",
		},
	},
}

for k, v in pairs(costumes) do
	v.skin_name = k
    v.prefab_name = string.lower(k) .. "_blueprint"
    v.priority = v.priority or 0
end

local WAR = {
	FEARSOME = 2,
	FESTIVE = 0,
	FORMAL = 1,
}

local DOLL = {
	FEARSOME = 0,
	FESTIVE = 1,
	FORMAL = 2,
}

local FESTIVE = {
	FEARSOME = 0,
	FESTIVE = 3,
	FORMAL = 0,
}

local ROBOT = {
	FEARSOME = 3,
	FESTIVE = 0,
	FORMAL = 1,
}

local NATURE = {
	FEARSOME = 0,
	FESTIVE = 2,
	FORMAL = 1,
}

local VICTORIAN = {
	FEARSOME = 1,
	FESTIVE = 1,
	FORMAL = 1,
}

local FORMAL = {
	FEARSOME = 0,
	FESTIVE = 0,
	FORMAL = 3,
}

local ICE = {
	FEARSOME = 2,
	FESTIVE = 1,
	FORMAL = 0,
}

local DEFAULT = {
	FEARSOME = 1.5,
	FESTIVE = 1.5,
	FORMAL = 1.5,
}

local BEAST = {
	FEARSOME = 1,
	FESTIVE = 2,
	FORMAL = 0,
}

local categories = {
	WAR = WAR,
	DOLL = DOLL,
	FESTIVE = FESTIVE,
	ROBOT = ROBOT,
	NATURE = NATURE,
	VICTORIAN = VICTORIAN,
	FORMAL = FORMAL,
	ICE = ICE,
	DEFAULT = DEFAULT,
	BEAST = BEAST,
}

local parts =
{
	beefalo_head_war = WAR,
	beefalo_body_war = WAR,
	beefalo_horn_war = WAR,
	beefalo_tail_war = WAR,
	beefalo_feet_war = WAR,

	beefalo_head_doll = DOLL,
	beefalo_body_doll = DOLL,
	beefalo_horn_doll = DOLL,
	beefalo_tail_doll = DOLL,
	beefalo_feet_doll = DOLL,

	beefalo_head_festive = FESTIVE,
	beefalo_body_festive = FESTIVE,
	beefalo_horn_festive = FESTIVE,
	beefalo_tail_festive = FESTIVE,
	beefalo_feet_festive = FESTIVE,

	beefalo_head_nature = NATURE,
	beefalo_body_nature = NATURE,
	beefalo_horn_nature = NATURE,
	beefalo_tail_nature = NATURE,
	beefalo_feet_nature = NATURE,

	beefalo_head_robot = ROBOT,
	beefalo_body_robot = ROBOT,
	beefalo_horn_robot = ROBOT,
	beefalo_tail_robot = ROBOT,
	beefalo_feet_robot = ROBOT,

	beefalo_head_ice = ICE,
	beefalo_body_ice = ICE,
	beefalo_horn_ice = ICE,
	beefalo_tail_ice = ICE,
	beefalo_feet_ice = ICE,

	beefalo_head_formal = FORMAL,
	beefalo_body_formal = FORMAL,
	beefalo_horn_formal = FORMAL,
	beefalo_tail_formal = FORMAL,
	beefalo_feet_formal = FORMAL,

	beefalo_head_victorian = VICTORIAN,
	beefalo_body_victorian = VICTORIAN,
	beefalo_horn_victorian = VICTORIAN,
	beefalo_tail_victorian = VICTORIAN,
	beefalo_feet_victorian = VICTORIAN,

	beefalo_head_beast = BEAST,
	beefalo_body_beast = BEAST,
	beefalo_horn_beast = BEAST,
	beefalo_tail_beast = BEAST,
	beefalo_feet_beast = BEAST,

	default = DEFAULT,
}

return {
    costumes = costumes,
    parts = parts,
    categories = categories,
}
