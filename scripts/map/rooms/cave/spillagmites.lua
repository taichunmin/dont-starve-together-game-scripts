require "map/room_functions"

---------------------------------------------
-- Spillagmites
-- Spiders and pillars, a little bit of nightmare
---------------------------------------------

-- Spillagmite Forest
AddRoom("SpillagmiteForest", {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.1,
            pillar_stalactite = 0.1,
            spiderhole = 0.05,

            fissure = 0.01,
        },
    }
})

-- Dropper Canyon
AddRoom("DropperCanyon", {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.2,
            pillar_stalactite = 0.2,
            dropperweb = 0.15,

            boneshard = 0.2,
            houndbone = 0.2,

            fissure = 0.01,
        },
    }
})

-- Stalagmites and Lights
AddRoom("StalagmitesAndLights", {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.1,
            pillar_stalactite = 0.1,
            spiderhole = 0.01,

            flower_cave = 0.1,

            fissure = 0.1,
            slurper = 0.001,
        },
    }
})

-- Spiders and Bats
AddRoom("SpidersAndBats", {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.1,
            pillar_stalactite = 0.1,
            spiderhole = 0.05,
            batcave = 0.05,

            fissure = 0.01,
        },
    }
})

-- Thulecite debris
AddRoom("ThuleciteDebris", {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.1,
            pillar_stalactite = 0.1,
            spiderhole = 0.01,
            batcave = 0.01,

            fissure = 0.1,
            thulecite = 0.01,
            thulecite_pieces = 0.05,
        },
    }
})

local bgspillagmite = {
    colour={r=0.4,g=0.4,b=0.4,a=0.9},
    value = WORLD_TILES.UNDERROCK,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            stalagmite = 0.35,
            stalagmite_med = 0.1,
            stalagmite_low = 0.05,
            pillar_cave = 0.1,
            pillar_stalactite = 0.1,
            spiderhole = 0.05,

            fissure = 0.01,
        },
    }
}
AddRoom("BGSpillagmite", bgspillagmite)
AddRoom("BGSpillagmiteRoom", Roomify(bgspillagmite))

