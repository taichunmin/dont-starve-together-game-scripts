require "map/room_functions"


---------------------------------------------
-- Fungus Noise
---------------------------------------------

-- Fungus noise
AddRoom("FungusNoiseForest", {
    colour={r=1.0,g=1.0,b=1.0,a=0.9},
    value = GROUND.FUNGUS_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .4,
        distributeprefabs=
        {
            mushtree_medium = 6.0,
            mushtree_tall = 6.0,
            mushtree_small = 6.0,
            red_mushroom = 0.5,
            green_mushroom = 0.5,
            blue_mushroom = 0.5,

            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            slurper = 0.001,
        },
    }
})

-- Fungus meadow
AddRoom("FungusNoiseMeadow", {
    colour={r=1.0,g=1.0,b=1.0,a=0.9},
    value = GROUND.FUNGUS_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            mushtree_medium = 1.0,
            mushtree_tall = 1.0,
            mushtree_small = 1.0,
            red_mushroom = 2.5,
            green_mushroom = 2.5,
            blue_mushroom = 2.5,

            flower_cave = 1.5,
            flower_cave_double = 1.0,
            flower_cave_triple = 1.0,

            slurper = 0.001,
        },
    }
})


