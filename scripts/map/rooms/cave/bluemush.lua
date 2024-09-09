require "map/room_functions"

---------------------------------------------
-- Blue Mush
-- Winter, dense trees, droppers, bones, bats
---------------------------------------------

-- Blue mush forest
AddRoom("BlueMushForest", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUS,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .6,
        distributeprefabs=
        {
            mushtree_tall = 6.0,
            blue_mushroom = 0.5,
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,

            batcave = 0.005,
            dropperweb = 0.015,

            slurper = 0.001,
        },
    }
})

-- Blue light meadow
AddRoom("BlueMushMeadow", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUS,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_tall = 1.0,
            blue_mushroom = 2.5,
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,

            batcave = 0.005,
            dropperweb = 0.015,

            slurper = 0.001,
        },
    }
})

-- Dropper forest
AddRoom("BlueSpiderForest", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUS,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .4,
        distributeprefabs=
        {
            mushtree_tall = 3.0,
            blue_mushroom = 2.5,
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,

            dropperweb = 0.1,
            boneshard = 0.2,
            houndbone = 0.2,

            slurper = 0.001,
        },
    }
})

-- Dropper desolation
AddRoom("DropperDesolation", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUS,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .2,
        distributeprefabs=
        {
            mushtree_tall = 2.0,
            blue_mushroom = 1.5,
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,

            dropperweb = 1.5,
            boneshard = 0.4,
            houndbone = 1.6,

            slurper = 0.001,
        },
    }
})

local bgbluemush = {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUS,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .6,
        distributeprefabs=
        {
            mushtree_tall = 6.0,
            blue_mushroom = 0.5,
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,

            batcave = 0.005,
            dropperweb = 0.015,

            slurper = 0.001,
        },
    }
}

AddRoom("BGBlueMush", bgbluemush)
AddRoom("BGBlueMushRoom", Roomify(bgbluemush))

AddRoom("MoonMushForest", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUSMOON,
    tags = {},
    random_node_entrance_weight = 0,
    contents =  {
        countstaticlayouts =
        {
            ["GrottoPoolBig"] = 1,
            ["GrottoPoolSmall"] = 4,
        },
        countprefabs =
        {
            mushgnome_spawner = 1,
        },
        distributepercent = 0.35,
        distributeprefabs =
        {
            mushtree_moon = 0.075,

            lightflier_flower = 0.02,

            cavelightmoon = 0.003,
            cavelightmoon_small = 0.003,
            cavelightmoon_tiny = 0.003,

            moonglass_stalactite1 = 0.007,
            moonglass_stalactite2 = 0.007,
            moonglass_stalactite3 = 0.007,
        },
    }
})

AddRoom("MoonMushForest_entrance", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = WORLD_TILES.FUNGUSMOON_NOISE,
    tags = {"GrottoWarEntrance"},
	random_node_exit_weight = 0,
    contents =  {
		distributepercent = 0.20,
        distributeprefabs =
        {
			-- mushroom only
			mushtree_tall =	0.30,
            flower_cave = 0.10,

			-- moon only
            mushtree_moon = 0.40,
            lightflier_flower = 0.01,

			-- anywhere
            cavelightmoon_small = 0.003,
            cavelightmoon_tiny = 0.003,
        },
    }
})