local survival_together = {
	id = "SURVIVAL_TOGETHER",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER,
	location = "forest",
	version = 4,
	overrides = {
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
}
if IsConsole() then
	survival_together.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER_PS4
end
AddLevel(LEVELTYPE.SURVIVAL, survival_together)

-- if a mod preset vanishes (i.e. the mod isn't running), just use the default preset instead.
local mod_missing = deepcopy(survival_together)
mod_missing.id = "MOD_MISSING"
mod_missing.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.MOD_MISSING
mod_missing.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.MOD_MISSING
mod_missing.hideinfrontend = true
AddLevel(LEVELTYPE.SURVIVAL, mod_missing)

AddLevel(LEVELTYPE.SURVIVAL, {
	id = "SURVIVAL_TOGETHER_CLASSIC",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER_CLASSIC,
	location = "forest",
	version = 4,
	overrides = {
		task_set = "classic",
		spring = "noseason",
		summer = "noseason",
		frograin = "never",
		wildfires = "never",

		bearger = "never",
		goosemoose = "never",
		dragonfly = "never",
		deciduousmonster = "never",
		houndmound = "never",

		buzzard = "never",
		catcoon = "never",
		moles = "never",
		lightninggoat = "never",

		rock_ice = "never",

		cactus = "never",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
})

if IsConsole() then   -- boons and spiders at default values rather than "often"
	AddLevel(LEVELTYPE.SURVIVAL, {
		id="SURVIVAL_DEFAULT_PLUS",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_DEFAULT_PLUS,
		desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_DEFAULT_PLUS,
		location = "forest",
		version = 4,
		overrides={
			start_location = "plus",

			berrybush = "rare",
			carrot = "rare",

			rabbits = "rare",
		},
		required_setpieces = {
			"Sculptures_1",
			"Maxwell5",
		},
		numrandom_set_pieces = 4,
		random_set_pieces =
		{
			"Sculptures_2",
			"Sculptures_3",
			"Sculptures_3",
			"Sculptures_3",
			"Sculptures_4",
			"Chessy_1",
			"Chessy_2",
			"Chessy_3",
			"Chessy_4",
			"Chessy_5",
			"Chessy_6",
			--"ChessSpot1",
			--"ChessSpot2",
			--"ChessSpot3",
			"Maxwell1",
			"Maxwell2",
			"Maxwell3",
			"Maxwell4",
			"Maxwell6",
			"Maxwell7",
			"Warzone_1",
			"Warzone_2",
			"Warzone_3",
		},
	})
else
	AddLevel(LEVELTYPE.SURVIVAL, {
		id="SURVIVAL_DEFAULT_PLUS",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_DEFAULT_PLUS,
		desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_DEFAULT_PLUS,
		location = "forest",
		version = 4,
		overrides={
			start_location = "plus",
			boons = "often",

			spiders = "often",

			berrybush = "rare",
			carrot = "rare",

			rabbits = "rare",
		},
		required_setpieces = {
			"Sculptures_1",
			"Maxwell5",
		},
		numrandom_set_pieces = 4,
		random_set_pieces =
		{
			"Sculptures_2",
			"Sculptures_3",
			"Sculptures_4",
			"Sculptures_5",
			"Chessy_1",
			"Chessy_2",
			"Chessy_3",
			"Chessy_4",
			"Chessy_5",
			"Chessy_6",
			--"ChessSpot1",
			--"ChessSpot2",
			--"ChessSpot3",
			"Maxwell1",
			"Maxwell2",
			"Maxwell3",
			"Maxwell4",
			"Maxwell6",
			"Maxwell7",
			"Warzone_1",
			"Warzone_2",
			"Warzone_3",
		},
	})
end

AddLevel(LEVELTYPE.SURVIVAL, {
	id="COMPLETE_DARKNESS",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.COMPLETE_DARKNESS,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.COMPLETE_DARKNESS,
	location = "forest",
	version = 4,
	overrides={
		start_location = "darkness",
		day = "onlynight",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
})

-- older depreciated AddLevel up here --

local worldgen_survival_together = {id = "SURVIVAL_TOGETHER",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER,
	location = "forest",
	version = 4,
	overrides = {},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
}
AddWorldGenLevel(LEVELTYPE.SURVIVAL, worldgen_survival_together)
local settings_survival_together = {id = "SURVIVAL_TOGETHER",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER,
	location = "forest",
    version = 4,
	overrides = {},
}
AddSettingsPreset(LEVELTYPE.SURVIVAL, settings_survival_together)

--if a mod preset vanishes (i.e. the mod isn't running), just use the default preset instead.
local worldgen_mod_missing = deepcopy(worldgen_survival_together)
worldgen_mod_missing.id = "MOD_MISSING"
worldgen_mod_missing.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.MOD_MISSING
worldgen_mod_missing.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.MOD_MISSING
worldgen_mod_missing.hideinfrontend = true
AddWorldGenLevel(LEVELTYPE.SURVIVAL, worldgen_mod_missing)
local settings_mod_missing = deepcopy(settings_survival_together)
settings_mod_missing.id = "MOD_MISSING"
settings_mod_missing.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.MOD_MISSING
settings_mod_missing.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.MOD_MISSING
settings_mod_missing.hideinfrontend = true
AddSettingsPreset(LEVELTYPE.SURVIVAL, settings_mod_missing)

AddWorldGenLevel(LEVELTYPE.SURVIVAL, {id = "SURVIVAL_TOGETHER_CLASSIC",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER_CLASSIC,
	location = "forest",
	version = 4,
	overrides = {
		task_set = "classic",
		spring = "noseason",
		summer = "noseason",

		houndmound = "never",

		buzzard = "never",
		catcoon = "never",
		moles = "never",
		lightninggoat = "never",

		rock_ice = "never",

		cactus = "never",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
})
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id = "SURVIVAL_TOGETHER_CLASSIC",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER_CLASSIC,
	location = "forest",
    version = 4,
	overrides = {
		frograin = "never",
		wildfires = "never",

		bearger = "never",
		goosemoose = "never",
		dragonfly = "never",
		deciduousmonster = "never",
	},
})

local worldgen_survival_plus = {id="SURVIVAL_DEFAULT_PLUS",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_DEFAULT_PLUS,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_DEFAULT_PLUS,
	location = "forest",
	version = 4,
	overrides={
		start_location = "plus",

		berrybush = "rare",
		carrot = "rare",

		rabbits = "rare",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_3",
		"Sculptures_3",
		"Sculptures_4",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
}
if not IsConsole() then
	worldgen_survival_plus.overrides.boons = "often"
	worldgen_survival_plus.overrides.spiders = "often"
end
AddWorldGenLevel(LEVELTYPE.SURVIVAL, worldgen_survival_plus)
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="SURVIVAL_DEFAULT_PLUS",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_DEFAULT_PLUS,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_DEFAULT_PLUS,
	location = "forest",
    version = 4,
	overrides={},
})

AddWorldGenLevel(LEVELTYPE.SURVIVAL, {id="COMPLETE_DARKNESS",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.COMPLETE_DARKNESS,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.COMPLETE_DARKNESS,
	location = "forest",
	version = 4,
	overrides={
		start_location = "darkness",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_4",
		"Sculptures_5",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		--"ChessSpot1",
		--"ChessSpot2",
		--"ChessSpot3",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
})
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="COMPLETE_DARKNESS",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.COMPLETE_DARKNESS,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.COMPLETE_DARKNESS,
	location = "forest",
    version = 4,
	overrides={
		day = "onlynight",
	},
})

---------------------------------------------------------------------------------
local worldgen_survival_plus = {id="TERRARIA",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.TERRARIA,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.TERRARIA,
	location = "forest",
	version = 4,
	overrides={
        -- global
        season_start = "spring",

        -- world
        boons = "never",

        -- resources
        rock_ice = "rare",

        -- creatures/spawners
        bees = "never",
        angrybees = "always",
	},
	required_setpieces = {
		"Sculptures_1",
		"Maxwell5",
	},
	numrandom_set_pieces = 4,
	random_set_pieces =
	{
		"Sculptures_2",
		"Sculptures_3",
		"Sculptures_3",
		"Sculptures_3",
		"Sculptures_4",
		"Chessy_1",
		"Chessy_2",
		"Chessy_3",
		"Chessy_4",
		"Chessy_5",
		"Chessy_6",
		"Maxwell1",
		"Maxwell2",
		"Maxwell3",
		"Maxwell4",
		"Maxwell6",
		"Maxwell7",
		"Warzone_1",
		"Warzone_2",
		"Warzone_3",
	},
}
if not IsConsole() then
	--worldgen_survival_plus.overrides.boons = "often"
	--worldgen_survival_plus.overrides.spiders = "often"
end
AddWorldGenLevel(LEVELTYPE.SURVIVAL, worldgen_survival_plus)
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="TERRARIA",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.TERRARIA,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.TERRARIA,
	location = "forest",
    version = 4,
	overrides={
        -- global
        day = "longnight",
        --beefaloheat = "rare" or "never"?

        -- survivors
        shadowcreatures = "never",

        -- world
        lightning = "never", -- or "rare"
        weather = "often",
        wildfires = "never",

        -- resource
        regrowth = "fast",
        carrots_regrowth = "never",
        flowers_regrowth = "fast",

        -- creatures
        bees_setting = "never",
        birds = "often",
        rabbits_setting = "often",

        -- monsters
        bats_setting = "never",
        wasps = "always",
        sharks = "many",
        lureplants = "often",
    },
})