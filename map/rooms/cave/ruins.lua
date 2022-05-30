require "map/room_functions"

------------------------------------------------------------------------------------
-- Ruins ---------------------------------------------------------------------------
------------------------------------------------------------------------------------


---------------------------------------------
-- Ruins Wilds
-- Lichen, ponds, monkeys, bananas, ferns
---------------------------------------------

--Wet Wilds
AddRoom("WetWilds", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = 0.25,
        distributeprefabs=
        {
            lichen = .25,
            cave_fern = 0.1,
            pillar_algae = .01,
            pond_cave = 0.1,
            slurper_spawner = .05,
            fissure_lower = 0.05,
        }
    }
})

--Lichen Meadow
AddRoom("LichenMeadow", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = 0.15,
        distributeprefabs=
        {
            lichen = 1.0,
            cave_fern = 1.0,
            pillar_algae = 0.1,
            slurper_spawner = 0.35,
            fissure_lower = 0.05,

            flower_cave = .05,
            flower_cave_double = .03,
            flower_cave_triple = .01,

            worm_spawner = 0.07,
            wormlight_plant = 0.15,
        }
    }
})

--Jungle
AddRoom("CaveJungle", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = 0.35,
        distributeprefabs=
        {
            lichen = 0.3,
            cave_fern = 1,
            pillar_algae = 0.05,

            cave_banana_tree = 0.5,
            monkeybarrel_spawner = 0.1,

            slurper_spawner = 0.06,
            pond_cave = 0.07,
            fissure_lower = 0.04,
            worm_spawner = 0.04,
            wormlight_plant = 0.08,
        }
    }
})

--Monkey Meadow
AddRoom("MonkeyMeadow", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = 0.1,
        distributeprefabs=
        {
            lichen = 0.3,
            cave_fern = 1,
            pillar_algae = 0.05,

            cave_banana_tree = 0.1,
            monkeybarrel_spawner = 0.06,

            slurper_spawner = 0.06,
            pond_cave = 0.07,
            fissure_lower = 0.04,
            worm_spawner = 0.04,
            wormlight_plant = 0.08,
        }
    }
})

--Lichen Land
AddRoom("LichenLand", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = 0.35,
        distributeprefabs=
        {
            lichen = 2.0,
            cave_fern = 0.5,
            pillar_algae = 0.5,
            slurper_spawner = 0.05,
            fissure_lower = 0.05,
        }
    }
})

bgwilds = {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countprefabs=
        {
            cave_hole = function() return math.random(2) - 1 end,
        },
        distributepercent = 0.15,
        distributeprefabs=
        {
            lichen = 0.1,
            cave_fern = 1,
            pillar_algae = 0.01,

            cave_banana_tree = 0.01,
            monkeybarrel_spawner = 0.01,

            flower_cave = 0.05,
            flower_cave_double = 0.03,
            flower_cave_triple = 0.01,

            worm_spawner = 0.07,
            wormlight_plant = 0.15,

            fissure_lower = 0.04,
        }
    }
}
AddRoom("BGWilds", bgwilds)
AddRoom("BGWildsRoom", Roomify(bgwilds))

---------------------------------------------
-- Residential
-- Debris, monkeys, light plants, ferns
---------------------------------------------

--Entrance
AddRoom("RuinedCityEntrance", {
    colour={r=0.2,g=0.0,b=0.2,a=0.3},
    value = GROUND.MUD,
    tags = {"ForceConnected", "MazeEntrance", "Nightmare"},--"Maze",
    contents =  {
        distributepercent = .07,
        distributeprefabs=
        {
            blue_mushroom = 1,
            cave_fern = 1,
            lichen = .5,
        },
    }
})

--City
AddRoom("RuinedCity", {-- Maze used to define room connectivity
    colour={r=.25,g=.28,b=.25,a=.50},
    value = GROUND.CAVE,
    tags = {"Maze", "Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
    contents =  {
        countprefabs=
        {
            cave_hole = function() return math.random() < 0.25 and 1 or 0 end,
        },
        distributepercent = 0.09,
        distributeprefabs=
        {
            lichen = .3,
            cave_fern = 1,
            pillar_algae = .05,

            cave_banana_tree = 0.1,
            monkeybarrel_spawner = 0.06,
            slurper_spawner = 0.06,
            pond_cave = 0.07,
            fissure_lower = 0.04,
            worm_spawner = 0.04,
        }
    }
})

--Houses
AddRoom("Vacant", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Nightmare"},
    contents =  {
        countstaticlayouts =
        {
            ["CornerWall"] = function() return math.random(2,3) end,
            ["StraightWall"] = function() return math.random(2,3) end,
            ["CornerWall2"] = function() return math.random(2,3) end,
            ["StraightWall2"] = function() return math.random(2,3) end,
        },
        distributepercent = 0.5,
        distributeprefabs=
        {
            lichen = .4,
            cave_fern = .6,
            pillar_algae = .01,
            slurper_spawner = .15,
            cave_banana_tree = .1,
            monkeybarrel_spawner = .2,
            dropperweb = .1,
            ruins_rubble_table = 0.1,
            ruins_rubble_chair = 0.1,
            ruins_rubble_vase = 0.1,
        }
    }
})

--Light Hut
AddRoom("LightHut", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Nightmare"},
    contents =  {
        countstaticlayouts =
        {
            ["THREE_WAY_N"] = 1,
        },
        distributepercent = 0.2,
        distributeprefabs=
        {
            lichen = 0.4,
            cave_fern = 0.6,
            pillar_algae = 0.01,
            slurper_spawner = 0.15,
            cave_banana_tree = 0.1,
            monkeybarrel_spawner = 0.2,
            dropperweb = 0.1,

            flower_cave = 0.5,
            flower_cave_double = 0.5,
            flower_cave_triple = 0.5,
        }
    }
})

---------------------------------------------
-- Military
-- Fat maze, ruins, thulecite walls, chessjunk
---------------------------------------------

--Entrance
AddRoom("MilitaryEntrance", {
    colour={r=0.2,g=0.0,b=0.2,a=0.3},
    value = GROUND.UNDERROCK,
    tags = {"ForceConnected", "MazeEntrance", "Nightmare"},
    contents =  {
        countstaticlayouts =
        {
            ["MilitaryEntrance"] = 1,
        },
    }
})

--Maze
AddRoom("MilitaryMaze",  { -- layout contents determined by maze
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.WALL_ROCKY,
    tags = {"Maze", "Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
})

--Barracks
AddRoom("Barracks",{
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.CAVE,
    tags = {"Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["Barracks"] = 1,
        },
        distributepercent = 0.03,
        distributeprefabs=
        {
            chessjunk_spawner = .3,

            nightmarelight = 1,

            rook_nightmare_spawner = .07,
            bishop_nightmare_spawner = .07,
            knight_nightmare_spawner = .07,
        }
    }
})

---------------------------------------------
-- Sacred
-- Ground patterns, statues, debris, pits, pillars
---------------------------------------------

--Bridge Entrance
AddRoom("BridgeEntrance",{
    colour={r=0.0,g=0.2,b=0.2,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"ForceConnected", "RoadPoison", "Nightmare"},
    contents = {},
})

--Worship Area
AddRoom("Bishops",{
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["Barracks2"] = 1,
        },
    }
})

--Sacred Barracks
AddRoom("SacredBarracks",{
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["SacredBarracks"] = 1,
        },
    }
})

--Living quarters
AddRoom("Spiral",{
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["Spiral"] = 1,
        },
    }
})

--BrokenAltar
AddRoom("BrokenAltar", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"Nightmare"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["BrokenAltar"] = 1,
        },
    }
})

bgsacred = {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.BRICK,
    tags = {"Nightmare"},
    contents =  {
        countprefabs=
        {
            cave_hole = 1,
        },

        distributepercent = 0.03,
        distributeprefabs=
        {
            chessjunk_spawner = .3,

            nightmarelight = 1,

            pillar_ruins = 0.5,

            ruins_statue_head_spawner = .1,
            ruins_statue_head_nogem_spawner = .2,

            ruins_statue_mage_spawner =.1,
            ruins_statue_mage_nogem_spawner = .2,

            rook_nightmare_spawner = .07,
            bishop_nightmare_spawner = .07,
            knight_nightmare_spawner = .07,
        }
    }
}
AddRoom("BGSacred", bgsacred)
AddRoom("BGSacredRoom", Roomify(bgsacred))

---------------------------------------------
-- Altar
-- Altar, statues, thulecite walls, pillars, sacred_chest
---------------------------------------------

--The Altar
AddRoom("Altar", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.IMPASSABLE,
    tags = {"Nightmare"},
    required_prefabs = {"sacred_chest"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts =
        {
            ["AltarRoom"] = 1,
        },
    }
})

---------------------------------------------
-- Labyrith
-- Thin maze, spider droppers, treasure, guardian
---------------------------------------------

--Entrance
AddRoom("LabyrinthEntrance", {
    colour={r=0.2,g=0.0,b=0.2,a=0.3},
    value = GROUND.MUD,
    tags = {"ForceConnected",  "LabyrinthEntrance", "Nightmare"},--"Labyrinth",
    contents =  {
        distributepercent = .2,
        distributeprefabs=
        {
            lichen = .8,
            cave_fern = 1,
            pillar_algae = .05,

            flower_cave = .2,
            flower_cave_double = .1,
            flower_cave_triple = .05,
        },
    }
})

--Maze
AddRoom("Labyrinth", {-- Not a real Labyrinth.. more of a maze really.
    colour={r=.25,g=.28,b=.25,a=.50},
    value = GROUND.BRICK,
    tags = {"Labyrinth", "Nightmare"},
    --internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
    contents =  {
        distributepercent = 0.1,
        distributeprefabs = {
            dropperweb = 0.5,

            ruins_rubble_vase = 0.1,
            ruins_rubble_chair = 0.1,
            ruins_rubble_table = 0.1,

            chessjunk_spawner = 0.03,

            rook_nightmare_spawner = 0.01,
            bishop_nightmare_spawner = 0.01,
            knight_nightmare_spawner = 0.01,

            thulecite_pieces = 0.05,
        },
    }
})

--Guarden
AddRoom("RuinedGuarden", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.MUD,
    tags = {"Nightmare"},
    required_prefabs = {"minotaur_spawner"},
    type = NODE_TYPE.Room,
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeSite,
    contents =  {
        countstaticlayouts = {
            ["WalledGarden"] = 1,
        },
        countprefabs= {

            flower_cave = function () return 5 + math.random(3) end,
            gravestone = function () return 4 + math.random(4) end,
            mound = function () return 4 + math.random(4) end
        }
    }
})

--Atrium Maze
AddRoom("AtriumMazeEntrance", {
    colour={r=0.2,g=0.0,b=0.2,a=0.3},
    value = GROUND.MUD,
    tags = {"MazeEntrance", "RoadPoison", "Hutch_Fishbowl"},
    contents =  {
        countprefabs=
        {
            cave_hole = 1,
        },
        distributepercent = .2,
        distributeprefabs=
        {
            lichen = .8,
            cave_fern = 1,
            pillar_algae = .05,

            flower_cave = .2,
            flower_cave_double = .1,
            flower_cave_triple = .05,
        },
    }
})

--Atrium Maze
AddRoom("AtriumMazeRooms",  { -- layout contents determined by maze
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.FAKE_GROUND,
    tags = {"ForceDisconnected", "Maze", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
})

--Archive Maze
AddRoom("ArchiveMazeEntrance", {
    colour={r=0.1,g=0.1,b=0.8,a=0.9},
    value = GROUND.FUNGUSMOON,
    tags = {"MazeEntrance", "RoadPoison", "lunacyarea"},
    contents =  {
        countstaticlayouts =
        {
            ["GrottoPoolSmall"] = 1,
        },
        distributepercent = 0.6,
        distributeprefabs =
        {
            mushtree_moon = 0.05,

            lightflier_flower = 0.005,

            cavelightmoon = 0.003,
            cavelightmoon_small = 0.003,
            cavelightmoon_tiny = 0.003,

            moonglass_stalactite1 = 0.007,
            moonglass_stalactite2 = 0.007,
            moonglass_stalactite3 = 0.007,
        },
    }
})

AddRoom("ArchiveMazeRooms",  { -- layout contents determined by maze
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.FAKE_GROUND,
    tags = {"ForceDisconnected", "Maze", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
})

---------------------------------------------
-- Expedition
-- Little bits to scatter elsewhere
-- Would this be better as just setpieces?? Easier to add tags if it's rooms...
---------------------------------------------
