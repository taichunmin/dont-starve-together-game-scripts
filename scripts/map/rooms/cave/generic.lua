require "map/room_functions"

---------------------------------------------
-- Generic Caves
---------------------------------------------

AddRoom("PitRoom", {
    colour={r=.25,g=.28,b=.25,a=.50},
    value = WORLD_TILES.IMPASSABLE,
    type = NODE_TYPE.Room,
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
    contents = {},
})

AddRoom("CaveExitRoom", {
    colour={r=.25,g=.28,b=.25,a=.50},
    value = WORLD_TILES.SINKHOLE,
    contents =  {
        countstaticlayouts = {
            ["CaveExit"] = 1,
        },
        distributepercent = .2,
        distributeprefabs=
        {
            cavelight = 0.05,
            cavelight_small = 0.05,
            cavelight_tiny = 0.05,
            flower_cave = 0.5,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.05,
            cave_fern=0.5,
            fireflies = 0.01,

            red_mushroom = 0.1,
            green_mushroom = 0.1,
            blue_mushroom = 0.1,
        }
    }
})


