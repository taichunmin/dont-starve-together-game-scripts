
-- These are all the tasks that are actually being used in DST's forest world

local blockersets = require("map/blockersets")

-----------------------------------------------------
-- Required Tasks
AddTask("Make a pick", {
		locks=LOCKS.NONE,
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1},
		room_choices={
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["BarePlain"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 1,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})

AddTask("Dig that rock", {
		locks={LOCKS.ROCKS},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		room_choices={
			["Graveyard"] = 1,
			["Rocky"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["CritterDen"] = function() return 1 end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	})

AddTask("Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		room_choices={
			["BeefalowPlain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			--["Wormhole_Plains"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 2,
		},
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	})

AddTask("Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER2},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER3},
		room_choices={
			["Marsh"] = function() return 5+math.random(SIZE_VARIATION) end,
			--["Forest"] = function() return math.random(SIZE_VARIATION) end,
			--["DeepForest"] = function() return 1+math.random(SIZE_VARIATION) end,
			["SlightlyMermySwamp"]=1,
		},
		room_bg=GROUND.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	})

AddTask("Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		room_choices={
			["BeeClearing"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = function() return math.random(SIZE_VARIATION)-1 end,
			["BeeQueenBee"] = 1,
			["FlowerPatch"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	})

 AddTask("Speak to the king", {
		locks={LOCKS.PIGKING,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.GOLD,KEYS.TIER3},
		room_choices={
			["PigKingdom"] = 1,
			["MagicalDeciduous"] = 1,
			["DeepDeciduous"] = function() return 3 + math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.GRASS,
		background_room="BGDeciduous",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = 1,
			["ForestMole"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
			["MoonbaseOne"] = 1,
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=.15,g=.5,b=.05,a=1}
	})

AddTask("For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		room_choices={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = function() return 1 + math.random(SIZE_VARIATION) end,
			--["Wormhole"] = 1,
			["DeepForest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	})

AddTask("Badlands", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HOUNDS,KEYS.TIER5, KEYS.ROCKS},
		room_choices={
			["DragonflyArena"] = 1,
			["Badlands"] = 2,
			["HoundyBadlands"] = function() return (math.random() < 0.33) and 2 or 1 end,
			["BarePlain"] = 1,
			["BuzzardyBadlands"] = function() return (math.random() < 0.5) and 2 or 1 end,
		},
		room_bg=GROUND.DIRT,
		background_room="BGBadlands",
		colour={r=1,g=0.6,b=1,a=1},
	})

AddTask("Lightning Bluff", {
		locks={LOCKS.SPIDERS_DEFEATED},
		keys_given={KEYS.PICKAXE, KEYS.TIER2},
		room_choices={
			["LightningBluffAntlion"] = 1,
			["LightningBluffLightning"] = 1,
			["LightningBluffOasis"] = 1,
			["BGLightningBluff"] = 2,
		},
		room_bg=GROUND.DIRT,
		background_room="BGLightningBluff",
		colour={r=.05,g=.5,b=.05,a=1},
	})


-----------------------------------------------------
-- Optional Tasks

AddTask("Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER1},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		room_choices={
			["PigVillage"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Marsh"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = 1
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	})

AddTask("Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		room_choices={
			["SpiderVillage"] = 2,
			--["Wormhole"] = 1,
			["CrappyForest"] = function() return math.random(SIZE_VARIATION) end,
			["CrappyDeepForest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = 1
		},
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=.25,g=.4,b=.06,a=1}
	})

AddTask("Killer bees!", {
		locks={LOCKS.KILLERBEES,LOCKS.TIER3},
		keys_given={KEYS.HONEY,KEYS.TIER3},
		entrance_room= "Waspnests",
		room_choices={
			--["Wormhole"] = 1,
			["Waspnests"] = function() return math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["FlowerPatch"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=0.1,b=0.1,a=1}
	})

AddTask("Make a Beehat", {
		locks={LOCKS.SPIDERS_DEFEATED,LOCKS.TIER1},
		keys_given={KEYS.BEEHAT,KEYS.GRASS,KEYS.TIER1},
		room_choices={
			--["Wormhole_Plains"] = 1,
			["Rocky"] = function() return math.random(SIZE_VARIATION) end,
			["FlowerPatch"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=1,b=0.5,a=1}
	})

AddTask("The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		},
		room_bg=GROUND.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	})

AddTask("Magic meadow", {
		locks={LOCKS.TIER1},
		keys_given={KEYS.GRASS,KEYS.MEAT,KEYS.TIER1},
		room_choices={
			["Pondopolis"] = 2,
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		},
		room_bg=GROUND.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	})

AddTask("Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER1},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		room_choices={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
			["FlowerPatch"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 2,
			["GrassyMoleColony"] = 1,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})

 AddTask("Mole Colony Deciduous", {
		locks={LOCKS.TIER1},
		keys_given={KEYS.TIER2},
		room_choices={
			["MolesvilleDeciduous"] = 1,
			["DeepDeciduous"] = 2,
			["DeciduousMole"] = 2,
			["DeciduousClearing"] = 1,
		},
		room_bg=GROUND.DECIDUOUS,
		background_room="BGDeciduous",
		colour={r=.15,g=.5,b=.05,a=1}
	})

  AddTask("Mole Colony Rocks", {
		locks={LOCKS.TIER1},
		keys_given={KEYS.ROCKS, KEYS.GOLD,KEYS.TIER2},
		room_choices={
			["RockyBuzzards"] = 1,
			--["Wormhole"] = 1,
			["GenericRockyNoThreat"] = function() return 2 + math.random(SIZE_VARIATION) end,
			["MolesvilleRocky"] = 1,
		},
		room_bg=GROUND.ROCKY,
		background_room="BGRocky",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("MooseBreedingTask", {
		locks={LOCKS.TREES,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER2},
		room_choices={
			["MooseGooseBreedingGrounds"] = 1,
		},
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=1,g=0.7,b=1,a=1},
})


-----------------------------------------------------
-- Moon Island Tasks

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
	required_prefabs = {"moon_fissure", "moon_fissure", "moon_altar_rock_glass", "moon_altar_rock_seed", "moon_altar_rock_idol"},
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

-----------------------------------------------------
-- Classic
 AddTask("Speak to the king classic", {
		locks={LOCKS.PIGKING,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.GOLD,KEYS.TIER3},
		room_choices={
			["PigKingdom"] = 1,
			--["Wormhole"] = 1,
			["DeepForest"] = function() return 3 + math.random(SIZE_VARIATION) end,
		},
		room_bg=GROUND.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	})
