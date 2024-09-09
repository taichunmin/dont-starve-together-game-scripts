
AddLocation({
    location = "forest",
    version = 2,
    overrides={
        start_location = "default",
        season_start = "default",
        world_size = "default",
        task_set = "default",
        layout_mode = "LinkNodesByKeys",
        wormhole_prefab = "wormhole",
        roads = "default",
		keep_disconnected_tiles = true,
		no_wormholes_to_disconnected_tiles = true,
		no_joining_islands = true,
		has_ocean = true,
    },
    required_prefabs = {
        "multiplayer_portal",
    },
})

AddLocation({
    location = "cave",
    version = 2,
    overrides={
        task_set = "cave_default",
        start_location = "caves",
        season_start = "default",
        world_size = "default",
        layout_mode = "RestrictNodesByKey",
        wormhole_prefab = "tentacle_pillar",
        roads = "never",
    },
    required_prefabs = {
        "multiplayer_portal",
    },
})

AddLocation({
    location = "lavaarena",
    version = 2,
    overrides = {
        task_set = "lavaarena_taskset",
        start_location = "lavaarena",
        season_start = "default",
        world_size = "small",
        layout_mode = "RestrictNodesByKey",
        wormhole_prefab = nil,
        roads = "never",
        keep_disconnected_tiles = true,
		no_wormholes_to_disconnected_tiles = true,
		no_joining_islands = true,
    },
    required_prefabs = {
        "lavaarena_portal",
    },
})

AddLocation({
    location = "quagmire",
    version = 2,
    overrides = {
        task_set = "quagmire_taskset",
        start_location = "quagmire_startlocation",
        season_start = "default",
        world_size = "small",
        layout_mode = "RestrictNodesByKey",
        wormhole_prefab = nil,
        roads = "never",
        loop_percent = 0,
	    branching = "random",
        keep_disconnected_tiles = false,
		no_wormholes_to_disconnected_tiles = true,
		no_joining_islands = true,
    },
    required_prefabs = {
        "quagmire_portal",
    },
})

