AddLevel(LEVELTYPE.QUAGMIRE, {
    id = "QUAGMIRE",
    name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.QUAGMIRE,
    desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.QUAGMIRE,
    location = "quagmire", -- this is actually the prefab name
    version = 4,
    overrides={
        boons = "never",
        touchstone = "never",
        traps = "never",
        poi = "never",
        protected = "never",
        disease_delay = "none",
        prefabswaps_start = "classic",
        petrification = "none",
        wildfires = "never",
    },
    background_node_range = {0,1},
})

-- older depreciated AddLevel up here --

AddWorldGenLevel(LEVELTYPE.QUAGMIRE, {
    id = "QUAGMIRE",
    name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.QUAGMIRE,
    desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.QUAGMIRE,
    location = "quagmire", -- this is actually the prefab name
    version = 4,
    overrides={
        boons = "never",
        touchstone = "never",
        traps = "never",
        poi = "never",
        protected = "never",
        prefabswaps_start = "classic",
    },
    background_node_range = {0,1},
})
AddSettingsPreset(LEVELTYPE.QUAGMIRE, {
    id = "QUAGMIRE",
    name = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS.QUAGMIRE,
    desc = STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC.QUAGMIRE,
    location = "quagmire", -- this is actually the prefab name
    version = 1,
    overrides={
        disease_delay = "none",
        petrification = "none",
        wildfires = "never",
    },
})