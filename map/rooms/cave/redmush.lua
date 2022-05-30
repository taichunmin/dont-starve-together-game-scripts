require "map/room_functions"


---------------------------------------------
-- Red Mush
-- Summer, spiders, cave stuff
---------------------------------------------

-- Red mush forest
AddRoom("RedMushForest", {
    colour={r=0.8,g=0.1,b=0.1,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_medium = 6.0,
            red_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite = 0.5,
            pillar_cave = 0.1,
            spiderhole = 0.05,

            slurper = 0.001,
        },
    }
})

-- Spider mush forest
AddRoom("RedSpiderForest", {
    colour={r=0.8,g=0.1,b=0.4,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_medium = 3.0,
            red_mushroom = 0.25,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite = 1.5,
            pillar_cave = 0.2,
            spiderhole = 0.4,

            slurper = 0.001,
        },
    }
})

-- Pillar Red Mush Meadow
AddRoom("RedMushPillars", {
    colour={r=0.8,g=0.1,b=0.4,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            mushtree_medium = 2.0,
            red_mushroom = 1.5,
            flower_cave = 0.5,
            flower_cave_double = 0.2,
            flower_cave_triple = 0.2,

            stalagmite = 0.5,
            pillar_cave = 0.5,
            spiderhole = 0.01,

            slurper = 0.001,
        },
    }
})

-- Stalagmite Forest
AddRoom("StalagmiteForest", {
    colour={r=0.8,g=0.1,b=0.1,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_medium = 1.0,
            red_mushroom = 0.25,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite = 3.5,
            pillar_cave = 1.0,
            spiderhole = 0.15,

            slurper = 0.001,
        },
    }
})

-- Spillagmite meadow
AddRoom("SpillagmiteMeadow", {
    colour={r=0.8,g=0.1,b=0.1,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            mushtree_medium = 0.5,
            red_mushroom = 0.25,
            flower_cave = 0.5,
            flower_cave_double = 0.2,
            flower_cave_triple = 0.2,

            stalagmite = 1.5,
            pillar_cave = 0.05,
            spiderhole = 0.45,

            slurper = 0.001,
        },
    }
})

local bgredmush = {
    colour={r=0.8,g=0.1,b=0.1,a=0.9},
    value = GROUND.FUNGUSRED,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_medium = 6.0,
            red_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite = 0.2,
            pillar_cave = 0.05,
            spiderhole = 0.01,

            slurper = 0.001,
        },
    }
}
AddRoom("BGRedMush", bgredmush)
AddRoom("BGRedMushRoom", Roomify(bgredmush))

