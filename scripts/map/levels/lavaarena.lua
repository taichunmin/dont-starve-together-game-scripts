AddLevel(LEVELTYPE.LAVAARENA, {
        id = "LAVAARENA",
        name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.LAVAARENA,
        desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.LAVAARENA,
        location = "lavaarena", -- this is actually the prefab name
        version = 4,
        overrides={
			boons = "never",
			touchstone = "never",
            traps = "never",
            poi = "never",
            protected = "never",
        },
        background_node_range = {0,1},
    })

-- older depreciated AddLevel up here --

AddWorldGenLevel(LEVELTYPE.LAVAARENA, {
    id = "LAVAARENA",
    name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.LAVAARENA,
    desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.LAVAARENA,
    location = "lavaarena", -- this is actually the prefab name
    version = 4,
    overrides={
        boons = "never",
        touchstone = "never",
        traps = "never",
        poi = "never",
        protected = "never",
    },
    background_node_range = {0,1},
})
AddSettingsPreset(LEVELTYPE.LAVAARENA, {
    id = "LAVAARENA",
    name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.LAVAARENA,
    desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.LAVAARENA,
    location = "lavaarena", -- this is actually the prefab name
    version = 1,
    overrides={},
})