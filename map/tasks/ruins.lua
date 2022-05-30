
------------------------------------------------------------
-- Caves Ruins Level
------------------------------------------------------------

--


AddTask("LichenLand", {
    locks={LOCKS.TIER1},
    keys_given= {KEYS.TIER2, KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices={
        ["WetWilds"] = function() return math.random(1,2) end,
        ["LichenMeadow"] = function() return math.random(1,2) end,
        ["LichenLand"] = 3,
        ["PitRoom"] = 2,
    },
    room_bg=GROUND.MUD,
    background_room="BGWilds",
    colour={r=0,g=0,b=0.0,a=1},
})

AddTask("CaveJungle", {
    locks={LOCKS.TIER2, LOCKS.RUINS},
    keys_given= {KEYS.TIER3, KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices={
        ["WetWilds"] = function() return math.random(1,2) end,
        ["LichenMeadow"] = 1,
        ["CaveJungle"] = function() return math.random(1,2) end,
        ["MonkeyMeadow"] = function() return math.random(1,2) end,
        ["PitRoom"] = 2,
    },
    room_bg=GROUND.MUD,
    background_room="BGWildsRoom",
    colour={r=0,g=0,b=0.0,a=1},
})

AddTask("Residential", {
    locks={LOCKS.TIER2, LOCKS.RUINS},
    keys_given= {KEYS.TIER3, KEYS.RUINS},
    room_tags = {"Nightmare"},
    entrance_room = "RuinedCityEntrance",
    room_choices =
    {
        ["Vacant"] = 3,
        --["LightHut"] = 1,
        ["PitRoom"] = 2,
    },
    room_bg = GROUND.TILES,
    maze_tiles = {rooms = {"room_residential", "room_residential_two", "hallway_residential", "hallway_residential_two"}, bosses = {"room_residential"}},
    background_room="RuinedCity",
    colour={r=0.2,g=0.2,b=0.0,a=1},
})


AddTask("MilitaryPits", {
    locks={LOCKS.TIER3, LOCKS.RUINS},
    keys_given= {KEYS.TIER4, KEYS.RUINS},
    room_tags = {"Nightmare"},
    entrance_room = "MilitaryEntrance",
    room_choices =
    {
        ["MilitaryMaze"] = 3,
        ["Barracks"] = 3,
    },
    room_bg = GROUND.TILES,
    maze_tiles = {rooms = {"pit_room_armoury", "pit_hallway_armoury", "pit_room_armoury_two"}, bosses = {"pit_room_armoury_two"}},
    background_room="MilitaryMaze",
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("Military", {
    locks={LOCKS.TIER3, LOCKS.RUINS},
    keys_given= {KEYS.TIER4, KEYS.RUINS},
    room_tags = {"Nightmare"},
    entrance_room = "MilitaryEntrance",
    room_choices =
    {
        ["MilitaryMaze"] = 4,
        ["Barracks"] = 1,
    },
    room_bg = GROUND.TILES,
    maze_tiles = {rooms = {"room_armoury", "hallway_armoury", "room_armoury_two"}, bosses = {"room_armoury_two"}},
    background_room="MilitaryMaze",
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("Sacred", {
    locks={LOCKS.TIER3, LOCKS.RUINS},
    keys_given= {KEYS.TIER4, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    entrance_room = "BridgeEntrance",
    room_choices =
    {
        ["SacredBarracks"] = function() return math.random(1,2) end,
        ["Bishops"] = function() return math.random(1,2) end,
        ["Spiral"] = function() return math.random(1,2) end,
        ["BrokenAltar"] = function() return math.random(1,2) end,
        ["PitRoom"] = 2,
    },
    room_bg = GROUND.TILES,
    background_room="Blank",
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("TheLabyrinth", {
    locks={LOCKS.TIER4, LOCKS.RUINS},
    keys_given= {KEYS.TIER5, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    entrance_room="LabyrinthEntrance",
    room_choices={
        ["Labyrinth"] = function() return 4+math.random(2) end,
        ["RuinedGuarden"] = 1,
    },
    room_bg=GROUND.IMPASSABLE,
    background_room="Labyrinth",
    colour={r=0.4,g=0.4,b=0.0,a=1},
})

AddTask("SacredAltar",{
    locks={LOCKS.TIER4, LOCKS.RUINS},
    keys_given= {KEYS.TIER5, KEYS.RUINS, KEYS.SACRED},
    room_tags = {"Nightmare"},
    room_choices =
    {
        ["Altar"] = 1,
        ["PitRoom"] = 2,
    },
    room_bg = GROUND.TILES,
    entrance_room="BridgeEntrance",
    background_room="Blank",
    colour={r=0.6,g=0.3,b=0.0,a=1},
})



----Optional Ruins Tasks----



AddTask("MoreAltars", {
    locks = {LOCKS.SACRED, LOCKS.RUINS, LOCKS.OUTERTIER},
    keys_given = {KEYS.SACRED, KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices =
    {
        ["BrokenAltar"] = 1,
        ["PitRoom"] = 2,
    },
    room_bg = GROUND.TILES,
    background_room="Blank",
    colour={r=1,g=0,b=0.6,a=1},
})
AddTask("SacredDanger", {
    locks = {LOCKS.SACRED, LOCKS.RUINS, LOCKS.OUTERTIER},
    keys_given = {KEYS.SACRED, KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices =
    {
        ["SacredBarracks"] = function() return math.random(1,2) end,
        ["Barracks"] = function() return math.random(1,2) end,
    },
    room_bg = GROUND.TILES,
    background_room="BGSacred",
    colour={r=1,g=0,b=0.6,a=1},
})

AddTask("MuddySacred", {
    locks = {LOCKS.SACRED, LOCKS.RUINS, LOCKS.OUTERTIER},
    keys_given = {KEYS.SACRED, KEYS.RUINS, KEYS.TIER4},
    room_tags = {"Nightmare"},
    room_choices =
    {
        ["SacredBarracks"] = function() return math.random(0,1) end,
        ["Bishops"] = function() return math.random(0,1) end,
        ["Spiral"] = function() return math.random(0,1) end,
        ["BrokenAltar"] = function() return math.random(0,1) end,
        ["WetWilds"] = 1,
        ["MonkeyMeadow"] = 1,
    },
    room_bg = GROUND.TILES,
    background_room="BGWildsRoom",
    colour={r=1,g=0,b=0.6,a=1},
})

AddTask("Residential2", {
    locks = {LOCKS.RUINS},
    keys_given = {KEYS.RUINS},
    room_tags = {"Nightmare"},
    entrance_room = "RuinedCityEntrance",
    room_choices =
    {
        ["CaveJungle"] = 1,
        ["Vacant"] = 1,
        ["RuinedCity"] = 2,
    },
    room_bg = GROUND.TILES,
    maze_tiles = {rooms = {"room_residential", "room_residential_two", "hallway_residential", "hallway_residential_two"}, bosses = {"room_residential"}},
    background_room="BGWilds",
    colour={r=1,g=0,b=0.6,a=1},
})

AddTask("Residential3", {
    locks = {LOCKS.RUINS},
    keys_given = {KEYS.RUINS},
    room_tags = {"Nightmare"},
    room_choices =
    {
        ["Vacant"] = function() return math.random(3,4) end,
    },
    room_bg = GROUND.TILES,
    background_room="BGWilds",
    colour={r=1,g=0,b=0.6,a=1},
})

AddTask("AtriumMaze", {
    locks={LOCKS.TIER3, LOCKS.RUINS},
    keys_given= {},
    room_tags = {"Atrium", "Nightmare"},
    required_prefabs = {"atrium_gate"},
    entrance_room = "AtriumMazeEntrance",
    room_choices =
    {
        ["AtriumMazeRooms"] = 8,
    },
    room_bg = GROUND.TILES,
    maze_tiles = {rooms = {"atrium_hallway", "atrium_hallway_two", "atrium_hallway_three"}, bosses = {"atrium_hallway_three"}, special = {start={"atrium_start"}, finish={"atrium_end"}}, bridge_ground=GROUND.FAKE_GROUND},
    background_room="AtriumMazeRooms",
    make_loop = true,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddTask("ArchiveMaze", {
    locks={LOCKS.ARCHIVE},
    keys_given= {},
    room_tags = {"nocavein"},
    required_prefabs = {"archive_orchestrina_main", "archive_lockbox_dispencer", "archive_lockbox_dispencer", "archive_lockbox_dispencer"},
    entrance_room = "ArchiveMazeEntrance",
    room_choices =
    {
        ["ArchiveMazeRooms"] = 4,
    },
    room_bg = GROUND.ARCHIVE,
--    maze_tiles = {rooms = {"archive_hallway"}, bosses = {"archive_hallway"}, keyroom = {"archive_keyroom"}, archive = {start={"archive_start"}, finish={"archive_end"}}, bridge_ground=GROUND.FAKE_GROUND},
    maze_tiles = {rooms = {"archive_hallway","archive_hallway_two"}, bosses = {"archive_hallway"}, archive = {keyroom = {"archive_keyroom"}}, special = {finish={"archive_end"},start={"archive_start"}},  bridge_ground=GROUND.FAKE_GROUND},
    background_room="ArchiveMazeRooms",
	cove_room_chance = 0,
	cove_room_max_edges = 0,
    make_loop = true,
    colour={r=1,g=0,b=0.0,a=1},
})
