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
	playstyle = "survival",
    version = 4,
	overrides = {},
}
AddSettingsPreset(LEVELTYPE.SURVIVAL, settings_survival_together)

-------------------------------------------------------------------------------
local nosweat_worldgen = deepcopy(survival_together)
nosweat_worldgen.id = "RELAXED"
nosweat_worldgen.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.RELAXED
nosweat_worldgen.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.RELAXED

local nosweat_settings = {}
nosweat_settings.id = "RELAXED"
nosweat_settings.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.RELAXED
nosweat_settings.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.RELAXED
nosweat_settings.location = "forest"
nosweat_settings.playstyle = "relaxed"
nosweat_settings.version = 4
nosweat_settings.overrides = {
	ghostsanitydrain = "none",
	portalresurection = "always",
	temperaturedamage = "nonlethal",
	hunger = "nonlethal",
	darkness = "nonlethal",
	lessdamagetaken = "always",
	healthpenalty = "none",
	wildfires = "never",
	hounds = "rare",

	resettime = "none",
	shadowcreatures = "rare",
	brightmarecreatures = "rare",
}

AddWorldGenLevel(LEVELTYPE.SURVIVAL, nosweat_worldgen)
AddSettingsPreset(LEVELTYPE.SURVIVAL, nosweat_settings)

AddPlaystyleDef({
	id = "relaxed",
	default_preset = "RELAXED",
	location = "forest",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.RELAXED,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.RELAXED,
	image = {atlas = "images/serverplaystyles.xml", icon = "relaxed.tex"},
	smallimage = {atlas = "images/serverplaystyles.xml", icon = "relaxed_small.tex"},
	priority = 8,
	overrides = {
		ghostsanitydrain = "none",
		portalresurection = "always",
		temperaturedamage = "nonlethal",
		hunger = "nonlethal",
		darkness = "nonlethal",
		lessdamagetaken = "always",
		healthpenalty = "none",
		wildfires = "never",
	},
})

-------------------------------------------------------------------------------
local endless_worldgen = deepcopy(survival_together)
endless_worldgen.id = "ENDLESS"
endless_worldgen.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.ENDLESS
endless_worldgen.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.ENDLESS

local endless_settings = {}
endless_settings.id = "ENDLESS"
endless_settings.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.ENDLESS
endless_settings.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.ENDLESS
endless_settings.location = "forest"
endless_settings.playstyle = "endless"
endless_settings.version = 4
endless_settings.overrides = {
	portalresurection = "always",
	basicresource_regrowth = "always",
	resettime = "none",

	ghostsanitydrain = "none",
}

AddWorldGenLevel(LEVELTYPE.SURVIVAL, endless_worldgen)
AddSettingsPreset(LEVELTYPE.SURVIVAL, endless_settings)

AddPlaystyleDef({
	id = "endless",
	default_preset = "ENDLESS",
	location = "forest",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.ENDLESS,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.ENDLESS,
	image = {atlas = "images/serverplaystyles.xml", icon = "endless.tex"},
	smallimage = {atlas = "images/serverplaystyles.xml", icon = "endless_small.tex"},
	priority = 2,
	overrides = {
		portalresurection = "always",
		resettime = "none",
	},
})

-------------------------------------------------------------------------------

AddPlaystyleDef({
	id = "survival",
	default_preset = "SURVIVAL_TOGETHER",
	location = "forest",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER,
	image = {atlas = "images/serverplaystyles.xml", icon = "survival.tex"},
	smallimage = {atlas = "images/serverplaystyles.xml", icon = "survival_small.tex"},
	is_default = true,
	priority = 0,
	overrides = {},
})

-------------------------------------------------------------------------------
local wilderness_worldgen = deepcopy(survival_together)
wilderness_worldgen.id = "WILDERNESS"
wilderness_worldgen.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.WILDERNESS
wilderness_worldgen.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.WILDERNESS

local wilderness_settings = {}
wilderness_settings.id = "WILDERNESS"
wilderness_settings.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.WILDERNESS
wilderness_settings.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.WILDERNESS
wilderness_settings.location = "forest"
wilderness_settings.playstyle = "wilderness"
wilderness_settings.version = 4
wilderness_settings.overrides = {
    spawnmode = "scatter",
    basicresource_regrowth = "always",
    ghostenabled = "none",

    ghostsanitydrain = "none",
    resettime = "none",
}

AddWorldGenLevel(LEVELTYPE.SURVIVAL, wilderness_worldgen)
AddSettingsPreset(LEVELTYPE.SURVIVAL, wilderness_settings)

AddPlaystyleDef({
	id = "wilderness",
	default_preset = "WILDERNESS",
	location = "forest",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.WILDERNESS,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.WILDERNESS,
	image = {atlas = "images/serverplaystyles.xml", icon = "wilderness.tex"},
	smallimage = {atlas = "images/serverplaystyles.xml", icon = "wilderness_small.tex"},
	priority = 5,
	overrides = {
		spawnmode = "scatter",
		ghostenabled = "none",
	},
})

-------------------------------------------------------------------------------
local lightsout_worldgen = deepcopy(worldgen_survival_together)
lightsout_worldgen.id = "LIGHTS_OUT"
lightsout_worldgen.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.LIGHTS_OUT
lightsout_worldgen.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.LIGHTS_OUT
lightsout_worldgen.overrides={
	start_location = "darkness",
}
AddWorldGenLevel(LEVELTYPE.SURVIVAL, lightsout_worldgen)

local lightsout_settings = {}
lightsout_settings.id = "LIGHTS_OUT"
lightsout_settings.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.LIGHTS_OUT
lightsout_settings.desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.LIGHTS_OUT
lightsout_settings.location = "forest"
lightsout_settings.playstyle = "lightsout"
lightsout_settings.version = 4
lightsout_settings.overrides = {
	day = "onlynight",
}
AddSettingsPreset(LEVELTYPE.SURVIVAL, lightsout_settings)

-- the old COMPLETE_DARKNESS is now basically an alias on LIGHTS_OUT that is left in for old saves
local complete_darkness_worldgen = deepcopy(lightsout_worldgen)
complete_darkness_worldgen.id = "COMPLETE_DARKNESS"
complete_darkness_worldgen.hideinfrontend = true
AddWorldGenLevel(LEVELTYPE.SURVIVAL, complete_darkness_worldgen)

local complete_darkness_settings = deepcopy(lightsout_settings)
complete_darkness_settings.id = "COMPLETE_DARKNESS"
complete_darkness_settings.hideinfrontend = true
AddSettingsPreset(LEVELTYPE.SURVIVAL, complete_darkness_settings)
AddPlaystyleDef({
	id = "lightsout",
	default_preset = "LIGHTS_OUT",
	location = "forest",
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.COMPLETE_DARKNESS,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.COMPLETE_DARKNESS,
	image = {atlas = "images/serverplaystyles.xml", icon = "lightsout.tex"},
	smallimage = {atlas = "images/serverplaystyles.xml", icon = "lightsout_small.tex"},
	priority = 10,
	overrides = deepcopy(complete_darkness_settings.overrides),
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
	playstyle = PLAYSTYLE_DEFAULT,
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

-------------------------------------------------------------------------------

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
	hideinfrontend = true,
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
	hideinfrontend = true,
	name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.SURVIVAL_TOGETHER_CLASSIC,
	desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.SURVIVAL_TOGETHER_CLASSIC,
	location = "forest",
	playstyle = PLAYSTYLE_DEFAULT,
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
	playstyle = PLAYSTYLE_DEFAULT,
    version = 4,
	overrides={},
})


-------------------------------------------------------------------------------
