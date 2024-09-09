
require "map/tasks/dst_tasks_forestworld" 

local blockersets = require("map/blockersets")

-- The standard tasks

AddTask("Resource-rich Tier2", {
		locks=LOCKS.NONE, -- Special story starting node
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1,KEYS.TIER2},
		room_choices={
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["BarePlain"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Resource-Rich", {
		locks=LOCKS.NONE,
		keys_given={KEYS.TIER1}, -- Special story node has only one key
		room_choices={
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["BarePlain"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Wasps and Frogs and bugs", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.GRASS,KEYS.HONEY,KEYS.TIER2},
		entrance_room=blockersets.all_bees,
		room_choices={
			["Pondopolis"] = 1,
			["BeeClearing"] = 1,
			["EvilFlowerPatch"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 2,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Hounded Magic meadow", {
		locks={LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOD,KEYS.HOUNDS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_hounds,
		room_choices={
			["Pondopolis"] = 2,
			["Clearing"] = 2, -- have to have at least a few rooms for tagging
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="Clearing",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Waspy The hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER5},
		entrance_room=blockersets.all_bees,
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["Clearing"] = 2,
			["BGGrass"] = 2,
			["BGRocky"] = 2,
		},
		room_bg=WORLD_TILES.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Guarded Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		entrance_room=ArrayUnion(blockersets.rocky_hard, blockersets.all_walls),
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["BGRocky"] = 2,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Walrus Desolate", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.HARD_WALRUS,KEYS.TIER5},
		room_choices={
			["WalrusHut_Plains"] = 1,
			["WalrusHut_Grassy"] = 1,
			["WalrusHut_Rocky"] = 1,
			["BGRocky"] = 2,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Insanity-Blocked Necronomicon", {
		locks={LOCKS.TIER3},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		entrance_room=blockersets.all_walls,
		room_choices={
			["Graveyard"] = 3,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["DeepForest"] = 2,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	})
AddTask("Necronomicon", {
		locks={LOCKS.ROCKS,LOCKS.TIER2},
		keys_given={KEYS.TRINKETS,KEYS.WOOD,KEYS.TIER3},
		room_choices={
			["Graveyard"] = 3,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["DeepForest"] = 2,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=0,g=1,b=0,a=1}
	})

AddTask("Easy Blocked Dig that rock", {
		locks={LOCKS.ROCKS,LOCKS.TIER1},
		keys_given={KEYS.TRINKETS,KEYS.STONE,KEYS.WOOD,KEYS.TIER1},
		entrance_room_chance=0.5,
		entrance_room=blockersets.all_easy,
		room_choices={
			["Graveyard"] = 1,
			--["Wormhole"] = 1,
			["Rocky"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGNoise",
		colour={r=0,g=0,b=1,a=1}
	})

AddTask("Tentacle-Blocked The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER3},
		keys_given={KEYS.TENTACLES,KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER3},
		entrance_room=blockersets.all_tentacles,
		room_choices={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
			["BGForest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Marsh"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return 1+math.random(SIZE_VARIATION) end,
			["Clearing"] = 1
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	})
AddTask("The Deep Forest", {
		locks={LOCKS.TREES,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.WOOD,KEYS.MEAT,KEYS.TIER2},
		room_choices={
			--["Wormhole"] = 1,
			["PigVillage"] = 1,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Marsh"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return 1+math.random(SIZE_VARIATION) end,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGDeepForest",
		colour={r=1,g=0,b=0,a=1}
	})


----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Pigs
----------------------------------------------------------------------------------------------------------------------------------------------------------------
AddTask("Trapped Befriend the pigs", {
		locks={LOCKS.PIGGIFTS,LOCKS.TIER2},
		keys_given={KEYS.PIGS,KEYS.MEAT,KEYS.GRASS,KEYS.WOOD,KEYS.TIER2},
		entrance_room="Trapfield",
		room_choices={
			["PigVillage"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Marsh"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = 1
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	})
AddTask("Pigs in the city", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigCity"] = 1,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["DeepForest"] = 1,
		},
		room_bg=WORLD_TILES.SAVANNA,
		background_room="BGSavanna",
		colour={r=1,g=0,b=0,a=1}
	})
AddTask("The Pigs are back in town", {
		locks=LOCKS.PIGGIFTS,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigTown"] = 1,
			["Forest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["DeepForest"] = 1,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGForest",
		colour={r=1,g=0,b=0,a=1}
	})
 AddTask("Guarded King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room="PigGuardpost",
		room_choices={
			["PigKingdom"] = 1,
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	})
 AddTask("Guarded Speak to the king", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		entrance_room=blockersets.all_pigs,
		room_choices={
			["PigKingdom"] = 1,
			--["Wormhole"] = 1,
			["DeepForest"] = function() return 3 + math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGForest",
		colour={r=1,g=1,b=0,a=1}
	})
 AddTask("King and Spiders", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices={
			["PigKingdom"] = 1,
			--["Wormhole"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 1,
			["SpiderForest"] = 3,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGCrappyForest",
		colour={r=1,g=1,b=0,a=1}
	})
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Beefalo
----------------------------------------------------------------------------------------------------------------------------------------------------------------
AddTask("Hounded Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.HOUNDS,KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_hounds,
		room_choices={
			["BeefalowPlain"] = function() return 3 + math.random(SIZE_VARIATION) end,
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	})
AddTask("Greater Plains", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.WALRUS,KEYS.TIER4},
		room_choices={
			["BeefalowPlain"] = function() return 3 + math.random(SIZE_VARIATION) end,
			--["Wormhole_Plains"] = 1,
			["WalrusHut_Plains"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	})
AddTask("Sanity-Blocked Great Plains", {
		locks={LOCKS.ROCKS,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.MEAT,KEYS.POOP,KEYS.WOOL,KEYS.GRASS,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices={
			["BeefalowPlain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			--["Wormhole_Plains"] = 1,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Clearing"] = 2,
		},
		room_bg=WORLD_TILES.SAVANNA,
		background_room="BGSavanna",
		colour={r=0,g=1,b=1,a=1}
	})
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Hounds
----------------------------------------------------------------------------------------------------------------------------------------------------------------
AddTask("Rock-Blocked HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room="DenseRocks",
		room_choices={
			["Moundfield"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	})
AddTask("HoundFields", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		room_choices={
			["Moundfield"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Plain"] = function() return 1 + math.random(SIZE_VARIATION) end,
			},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGRocky",
		colour={r=0,g=1,b=1,a=1}
	})
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Merms
----------------------------------------------------------------------------------------------------------------------------------------------------------------
AddTask("Merms ahoy", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.MERMS,KEYS.MEAT,KEYS.SPIDERS,KEYS.SILK,KEYS.TIER4},
		room_choices={
			["MermTown"] = function() return 1+math.random(SIZE_VARIATION) end,
			["SpiderMarsh"] = function() return 3+math.random(SIZE_VARIATION) end,
			["Marsh"] = function() return 3+math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return 2+math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=1,g=0,b=0,a=1}
	})
AddTask("Sane-Blocked Swamp", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.TENTACLES,KEYS.WOOD,KEYS.TIER2},
		entrance_room="SanityWall",
		room_choices={
			--["Wormhole"] = 1,
			["Marsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return 1+math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	})
AddTask("Guarded Squeltch", {
		locks={LOCKS.SPIDERDENS,LOCKS.TIER2},
		keys_given={KEYS.MEAT,KEYS.SILK,KEYS.SPIDERS,KEYS.TIER2},
		entrance_room_chance=0.7,
		entrance_room=blockersets.all_marsh,
		room_choices={
			--["Wormhole"] = 1,
			["Marsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["DeepForest"] = function() return 1+math.random(SIZE_VARIATION) end,
			["SlightlyMermySwamp"]=1,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.05,a=1}
	})
AddTask("Swamp start", {
		locks=LOCKS.NONE,
		keys_given={KEYS.MERMS,KEYS.TIER2,KEYS.TIER3},
		room_choices={
			["SafeSwamp"] = 2,
			--["Wormhole_Swamp"] = 1,
			["Marsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["SlightlyMermySwamp"]=1,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.5,a=1}
	})
AddTask("Tentacle-Blocked Spider Swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.TENTACLES,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		entrance_room=blockersets.all_tentacles,
		room_choices={
			["SpiderVillageSwamp"] = 1,
			["SpiderMarsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["Forest"] = 2,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.5,g=.05,b=.05,a=1}
	})
AddTask("Lots-o-Spiders", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.SPIDERS,KEYS.TIER3,KEYS.AXE},
		entrance_room=blockersets.all_spiders,
		room_choices={
			["SpiderCity"] = 1,
			["SpiderVillage"] = 2,
			["SpiderMarsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["CrappyForest"] = 2,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	})
AddTask("Lots-o-Tentacles", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TENTACLES,KEYS.TIER3,KEYS.AXE},
		entrance_room="TentaclelandA",
		room_choices={
			["MermTown"] = 1,
			["Marsh"] = function() return 1+math.random(SIZE_VARIATION) end,
			["SlightlyMermySwamp"] = function() return 1+math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.05,b=.5,a=1}
	})
AddTask("Lots-o-Tallbirds", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.TALLBIRDS,KEYS.MEAT,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD,KEYS.AXE},
		entrance_room=blockersets.all_tallbirds,
		room_choices={
			["WalrusHut_Rocky"] = 1,
			["WalrusHut_Plains"] = 1,
			["BeefalowPlain"] = function() return 1+math.random(SIZE_VARIATION) end,
			["TallbirdNests"] = function() return 1+math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=.5,g=.3,b=.05,a=1}
	})
AddTask("Lots-o-Chessmonsters", {
		locks={LOCKS.ONLYTIER1}, -- note: adventure level, tier1 lock and abundant keys is to control world shape
		keys_given={KEYS.CHESSMEN,KEYS.GEARS,KEYS.WOOL,KEYS.POOP,KEYS.TIER3,KEYS.TIER4,KEYS.GOLD},
		entrance_room=blockersets.all_chess,
		room_choices={
			["ChessForest"] = function() return 1+math.random(SIZE_VARIATION) end,
			["ChessBarrens"] = function() return 1+math.random(SIZE_VARIATION) end,
			["ChessMarsh"] = function() return 1+math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGChessRocky",
		colour={r=.8,g=.08,b=.05,a=1}
	})
AddTask("Spider swamp", {
		locks={LOCKS.SPIDERDENS,LOCKS.BASIC_COMBAT,LOCKS.TIER3},
		keys_given={KEYS.MEAT,KEYS.SPIDERS,KEYS.TIER3,KEYS.GOLD},
		room_choices={
			--["Wormhole_Swamp"] = 1,
			["SpiderVillageSwamp"] = 1,
			["SpiderMarsh"] = function() return 2+math.random(SIZE_VARIATION) end,
			["Forest"] = 2,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.15,g=.05,b=.7,a=1}
	})
	--Task("Into the Nothing small", {
		--lock,LOCKS.ROCKS,
		--keys_given=KEYS.MEAT,
		--room_choices={
		--},
		--room_choices={
			--["Forest"] = 1,
			--["Nothing"] = function() return 1+math.random(SIZE_VARIATION) end,
		--},
		--room_bg=WORLD_TILES.IMPASSABLE,
		--colour={r=.05,g=.05,b=.05,a=1}
	--}),
 AddTask("Sanity-Blocked Spider Queendom", {
		locks={LOCKS.PIGKING,LOCKS.SPIDERDENS,LOCKS.ADVANCED_COMBAT,LOCKS.TIER5},
		keys_given={KEYS.SPIDERS,KEYS.HARD_SPIDERS,KEYS.TIER5,KEYS.TRINKETS},
		entrance_room=blockersets.all_walls,
		room_choices={
			["SpiderCity"] = 4,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 2,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0,a=1}
	})
 AddTask("Spider Queendom", {
		locks=LOCKS.PIGKING,
		keys_given=KEYS.PIGS,
		room_choices={
			["SpiderCity"] = 4,
			--["Wormhole_Plains"] = 1,
			["Graveyard"] = 1,
			["CrappyDeepForest"] = 2,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="SpiderForest",
		colour={r=1,g=1,b=0.2,a=1}
	})

AddTask("Guarded For a nice walk", {
		locks={LOCKS.BASIC_COMBAT,LOCKS.TIER2},
		keys_given={KEYS.POOP,KEYS.WOOL,KEYS.WOOD,KEYS.GRASS,KEYS.TIER2},
		entrance_room_chance=0.3,
		entrance_room=ArrayUnion(blockersets.forest_easy, blockersets.all_grass, blockersets.walls_easy),
		room_choices={
			["BeefalowPlain"] = 1,
			["MandrakeHome"] = function() return 1 + math.random(SIZE_VARIATION) end,
			--["Wormhole"] = 1,
			["DeepForest"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGForest",
		colour={r=1,g=0,b=1,a=1}
	})
AddTask("Mine Forest", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.MEAT,
		room_choices={
			["Trapfield"] = 4,
			["Clearing"] = 2
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGCrappyForest",
		colour={r=.05,g=.5,b=.05,a=1}
	})
AddTask("Battlefield", {
		locks={LOCKS.SPIDERDEN,LOCKS.BASIC_COMBAT,LOCKS.TIER4},
		keys_given={KEYS.SPIDERS,KEYS.PIGS,KEYS.SILK,KEYS.TIER5},
		entrance_room="Trapfield",
		room_choices={
			["Trapfield"] = 1,
			["SpiderVillage"] = 2,
			--["Wormhole"] = 1,
			["PigCamp"] = 2,
			["BGForest"] = 1,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=.05,g=.8,b=.05,a=1}
	})
AddTask("Guarded Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room=blockersets.all_forest,
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["BGForest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	})
AddTask("Trapped Forest hunters", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER4},
		keys_given={KEYS.WALRUS,KEYS.TIER4},
		entrance_room="Trapfield",
		room_choices={
			["WalrusHut_Grassy"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = 2,
			["DeepForest"] = 1,
			["Clearing"] = 1,
		},
		room_bg=WORLD_TILES.FOREST,
		background_room="BGForest",
		colour={r=.05,g=.5,b=.15,a=1}
	})
AddTask("Walled Kill the spiders", {
		locks={LOCKS.SPIDERDENS,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER3},
		keys_given={KEYS.SPIDERS,KEYS.TIER4},
		entrance_room_chance=0.4,
		entrance_room=blockersets.walls_easy,
		room_choices={
			["SpiderVillage"] = 2,
			--["Wormhole"] = 1,
			["CrappyForest"] = function() return math.random(SIZE_VARIATION) end,
			["CrappyDeepForest"] = function() return math.random(SIZE_VARIATION) end,
			["Clearing"] = 1
		},
		room_bg=WORLD_TILES.ROCKY,
		background_room="BGRocky",
		colour={r=.15,g=.5,b=.15,a=1}
	})
AddTask("Waspy Beeeees!", {
		locks={LOCKS.BEEHIVE,LOCKS.TIER1},
		keys_given={KEYS.HONEY,KEYS.TIER2},
		entrance_room_chance=0.8,
		entrance_room=blockersets.all_bees,
		room_choices={
			["BeeClearing"] = 1,
			--["Wormhole"] = 1,
			["Forest"] = function() return math.random(SIZE_VARIATION) end,
			["FlowerPatch"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0.3,a=1}
	})
AddTask("Pretty Rocks Burnt", {
		locks=LOCKS.SPIDERDENS,
		keys_given=KEYS.BEEHAT,
		room_choices={
			--["Wormhole_Plains"] = 1,
			["Rocky"] = function() return math.random(SIZE_VARIATION) end,
			["FlowerPatch"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	})
AddTask("The charcoal forest", {
		locks=LOCKS.NONE,
		keys_given=KEYS.NONE,
		room_choices={
			--["Wormhole_Burnt"] = 1,
			["BurntForestStart"] = 1,
			["BurntForest"] = function() return math.random(SIZE_VARIATION) end,
			["BurntClearing"] = function() return math.random(SIZE_VARIATION) end,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrassBurnt",
		colour={r=1,g=1,b=0.5,a=1}
	})
AddTask("Land of Plenty", {
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices={
			["PigCamp"] = 2,
			["PigTown"] = 2,
			["PigCity"] = 1,
			["BeeClearing"] = 1,
			["MandrakeHome"] = 2,
			["BeefalowPlain"] = 2,
			["Graveyard"] = 2,
			["Forest"] = 2,
			["DeepForest"] = 1,
			["BGRocky"] = 1,
		},
		room_bg=WORLD_TILES.GRASS,
		background_room="BGGrass",
		colour={r=.05,g=.5,b=.05,a=1}
	})
AddTask("The other side", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.NONE,
		entrance_room = "SanityWormholeBlocker",
		room_choices={
			["Graveyard"] = function() return math.random(2) end,
			["SpiderCity"] = function() return math.random(SIZE_VARIATION) end,
			["Waspnests"] = 1,
			["WalrusHut_Rocky"] = function() return math.random(1) end,
			["Pondopolis"] = function() return math.random(2) end,
			["Tentacleland"] = function() return math.random(SIZE_VARIATION) end,
			["Moundfield"] = function() return math.random(2) end,
			["MermTown"] = function() return 1 + math.random(SIZE_VARIATION) end,
			["Trapfield"] = function() return 1 + math.random(2) end,
			["ChessArea"] = function() return math.random(2) end,
			["ChessMarsh"] = 1,
			["SpiderMarsh"] = function() return 2+math.random(2) end,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGMarsh",
		colour={r=.05,g=.5,b=.05,a=1}
	})
AddTask("Chessworld", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.MONSTERS_DEFEATED,LOCKS.TIER5},
		keys_given={KEYS.CHESSMEN,KEYS.TIER5},
		entrance_room=blockersets.all_chess,
		room_choices={
			["ChessArea"] = 2,
			["MarbleForest"] = function() return 1+ math.random(SIZE_VARIATION) end,
			["ChessBarrens"] = 2,
		},
		room_bg=WORLD_TILES.MARSH,
		background_room="BGChessRocky",
		colour={r=.05,g=.5,b=.05,a=1},
	})

------------------------------------------------------------------------------------------------------------------------
-- GIANTS ROOMS
------------------------------------------------------------------------------------------------------------------------

