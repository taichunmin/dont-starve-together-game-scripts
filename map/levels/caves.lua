require("map/level")

----------------------------------
-- Cave levels
----------------------------------


AddLevel(LEVELTYPE.SURVIVAL, {
        id="DST_CAVE",
        name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE,
        desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE,
        location = "cave",
        version = 3,

        overrides={
        },
        background_node_range = {0,1},
    })

AddLevel(LEVELTYPE.SURVIVAL, {
        id="DST_CAVE_PLUS",
        name=STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.DST_CAVE_PLUS,
        desc= STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.DST_CAVE_PLUS,
        location = "cave",
        version = 3,

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
