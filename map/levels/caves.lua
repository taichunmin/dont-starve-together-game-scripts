local dst_cave = {
	id="DST_CAVE",
	name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE,
	desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE,
	location = "cave",
	version = 4,
	overrides={
	},
	background_node_range = {0,1},
}
if IsConsole() then
	dst_cave.name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PS4
end
AddLevel(LEVELTYPE.SURVIVAL, dst_cave)

AddLevel(LEVELTYPE.SURVIVAL, {
    id="DST_CAVE_PLUS",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PLUS,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE_PLUS,
    location = "cave",
    version = 4,

    overrides={
        boons = "often",

        cave_spiders = "often",

        rabbits = "rare",

        berrybush = "rare",
        carrot = "rare",

        flower_cave = "rare",
        wormlights = "rare",
    },
    background_node_range = {0,1},
})

-- older depreciated AddLevel up here --

AddWorldGenLevel(LEVELTYPE.SURVIVAL, {id="DST_CAVE",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE,
    location = "cave",
    version = 4,
    overrides={},
    background_node_range = {0,1},
})
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="DST_CAVE",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE,
    location = "cave",
    version = 4,
    overrides={},
})

AddWorldGenLevel(LEVELTYPE.SURVIVAL, {id="DST_CAVE_PLUS",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PLUS,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE_PLUS,
    location = "cave",
    version = 4,
    overrides={
        boons = "often",

        cave_spiders = "often",

        rabbits = "rare",

        berrybush = "rare",
        carrot = "rare",

        flower_cave = "rare",
        wormlights = "rare",
    },
    background_node_range = {0,1},
})
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="DST_CAVE_PLUS",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PLUS,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE_PLUS,
    location = "cave",
    version = 4,
    overrides={
        flower_cave_regrowth = "rare",
    },
})

AddWorldGenLevel(LEVELTYPE.SURVIVAL, {id="TERRARIA_CAVE",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.TERRARIA_CAVE,
    desc=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.TERRARIA_CAVE,
    location = "cave",
    version = 4, --??
    overrides={
        boons = "often",
    },
    background_node_range = {0,1},
})
-- Maybe non-console world_size = "huge"
AddSettingsPreset(LEVELTYPE.SURVIVAL, {id="TERRARIA_CAVE",
    name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.TERRARIA_CAVE,
    desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.TERRARIA_CAVE,
    location = "cave",
    version = 4,
    overrides={
        -- world
        weather = "often",
        wormattacks = "often",

        -- resources
        flower_cave_regrowth = "fast",
        mushtree_regrowth = "fast",
        mushtree_moon_regrowth = "fast",

        -- hostile creatures
        bats_setting = "often",
        spider_dropper = "often",
    },
})
