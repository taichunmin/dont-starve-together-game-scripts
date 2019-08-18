
-----------------------------------------------------

AddTask("MoonIsland_IslandShards", {
	locks={},
	keys_given={KEYS.ISLAND_TIER2},
	region_id = "island1",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "nohunt", "nohasslers", "lunacyarea", "not_mainland"},
    room_choices =
    {
        ["MoonIsland_IslandShard"] = function() return 3 + math.random(2) end,
        ["Empty_Cove"] = 2,
    },
    room_bg = GROUND.PEBBLEBEACH,
    background_room = "Empty_Cove", 
	cove_room_name = "Blank",
    make_loop = true,
	crosslink_factor = 2,
	cove_room_chance = 1,
	cove_room_max_edges = 2,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("MoonIsland_Beach", {
	locks={LOCKS.ISLAND_TIER2},
	keys_given={KEYS.ISLAND_TIER3},
	region_id = "island1",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
    entrance_room = "MoonIsland_Blank",
    room_choices =
    {
        ["MoonIsland_Beach"] = 2,
    },
    room_bg = GROUND.PEBBLEBEACH,
    background_room = "Empty_Cove", 
	cove_room_name = "Empty_Cove",
	cove_room_chance = 1,
    make_loop = true,
	cove_room_max_edges = 2,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("MoonIsland_Forest", {
	locks={LOCKS.ISLAND_TIER4},
	keys_given={},
	region_id = "island1",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
    room_choices =
    {
        ["MoonIsland_Forest"] = 3,
    },
    room_bg = GROUND.METEOR,
    background_room = "Empty_Cove", 
	cove_room_name = "Empty_Cove",
	crosslink_factor = 1,
	cove_room_chance = 1,
	cove_room_max_edges = 2,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("MoonIsland_Mine", { 
	locks={LOCKS.ISLAND_TIER4},
	keys_given={},
	region_id = "island1",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
	room_choices={
		["MoonIsland_Mine"] = 3,
	},  
	room_bg=GROUND.METEOR,
	background_room = "Empty_Cove",
	cove_room_name = "Empty_Cove",
	cove_room_chance = 1,
	cove_room_max_edges = 2,
	colour={r=.05,g=.5,b=.05,a=1},
})

AddTask("MoonIsland_Baths", {
	locks={LOCKS.ISLAND_TIER3},
	keys_given={KEYS.ISLAND_TIER4},
	region_id = "island1",
	level_set_piece_blocker = true,
	room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
    room_choices =
    {
        ["MoonIsland_Baths"] = 2,
		["MoonIsland_Meadows"] = 2,
    },
    room_bg = GROUND.METEOR,
    background_room = "MoonIsland_Meadows", 
	cove_room_name = "Empty_Cove",
	cove_room_chance = 1,
	cove_room_max_edges = 2,
	required_prefabs = {"moon_fissure", "moon_altar_rock_glass", "moon_altar_rock_seed", "moon_altar_rock_idol"},
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

