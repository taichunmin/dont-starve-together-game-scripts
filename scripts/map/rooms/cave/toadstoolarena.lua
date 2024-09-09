require "map/room_functions"


---------------------------------------------
---------------------------------------------

AddRoom("ToadstoolArenaBGMud", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.MUD,
    tags = {},
    contents =  {
        distributepercent = .12,
        distributeprefabs=
        {
            pond_cave = 0.2,

            flower_cave = 0.1,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite_tall=.01,
            stalagmite_tall_med=0.1,
            stalagmite_tall_low=0.1,
            pillar_cave_rock = 0.01,

            cave_fern = 1.0,

            slurtlehole = 0.001,
        }
    }
})


AddRoom("ToadstoolArenaMud", {
    colour={r=1.0,g=0.0,b=0.0,a=0.9},
    value = WORLD_TILES.MUD,
    tags = {},
    contents = {
        countstaticlayouts = {
            ["ToadstoolArena"] = 1,
        },
        distributepercent = .1,
        distributeprefabs=
        {
            flower_cave = 1.0,
            flower_cave_double = 0.5,
            flower_cave_triple = 0.5,

            stalagmite_tall=0.05,
            stalagmite_tall_med=0.05,
            stalagmite_tall_low=0.1,
            pillar_cave_rock = 0.01,

            cave_fern = 0.1,
            wormlight_plant = 0.02,
        },
    }
})

AddRoom("ToadstoolArenaBGCave", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.CAVE,
    tags = {},
    contents =  {
        distributepercent = .12,
        distributeprefabs=
        {
            flower_cave = 0.1,
            flower_cave_double = 0.05,
            flower_cave_triple = 0.05,
            stalagmite_tall=0.4,
            stalagmite_tall_med=0.4,
            stalagmite_tall_low=0.4,
            pillar_cave_rock = 0.01,
            fissure = 0.05,
            pond_cave = 0.15,
            batcave = 0.01,
        }
    }
})

AddRoom("ToadstoolArenaCave", {
    colour={r=1.0,g=0.0,b=0.0,a=0.9},
    value = WORLD_TILES.CAVE,
    tags = {},
    contents = {
        countstaticlayouts = {
            ["ToadstoolArena"] = 1,
        },
        distributepercent = 0,
        distributeprefabs =
        {

        },
    }
})
