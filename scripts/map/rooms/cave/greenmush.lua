require "map/room_functions"


---------------------------------------------
-- Green Mush
-- Spring, plants, overworld
---------------------------------------------

-- Green mush forest
AddRoom("GreenMushForest", {
    colour={r=0.1,g=0.8,b=0.1,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            mushtree_small = 6.0,
            green_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            rabbithouse = 0.02,

            cave_fern = 2.5,

            slurper = 0.001,
        },
    }
})

-- Mush and ponds -- overworld ponds, not cave ponds!
AddRoom("GreenMushPonds", {
    colour={r=0.1,g=0.8,b=0.3,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .3,
        distributeprefabs=
        {
            mushtree_small = 3.0,
            green_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            pond = 0.5,

            cave_fern = 2.5,

            slurper = 0.001,
            rabbithouse = 0.005,
        },
    }
})

-- Greenmush Sinkhole
AddRoom("GreenMushSinkhole", {
    colour={r=0.1,g=0.8,b=0.3,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts={
            ["EvergreenSinkhole"]=1,
        },
        distributepercent = .2,
        distributeprefabs=
        {
            mushtree_small = 1.0,
            green_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            cavelight = 0.05,
            cavelight_small = 0.05,

            evergreen = 0.1,
            grass = 0.1,
            sapling = 0.1,
            twiggytree = 0.04,
            berrybush = 0.05,
            berrybush_juicy = 0.025,

            cave_fern = 3.5,

            slurper = 0.001,
            rabbithouse = 0.005,
        },
    }
})

-- Mush and Ferns meadow
AddRoom("GreenMushMeadow", {
    colour={r=0.1,g=0.8,b=0.3,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            mushtree_small = 2.0,
            green_mushroom = 2.0,
            flower_cave = 0.5,
            flower_cave_double = 0.2,
            flower_cave_triple = 0.2,

            cave_fern = 3.5,

            slurper = 0.001,
            rabbithouse = 0.005,
        },
    }
})

-- Mushy Rabbit Hangout
AddRoom("GreenMushRabbits", {
    colour={r=0.1,g=0.8,b=0.3,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts={
            ["RabbitTown"]=1,
        },
        distributepercent = .2,
        distributeprefabs=
        {
            mushtree_small = 2.0,
            green_mushroom = 0.5,
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            cavelight = 0.05,
            cavelight_small = 0.05,

            evergreen = 0.1,
            grass = 0.1,
            sapling = 0.1,
            twiggytree = 0.04,
            berrybush = 0.05,
            berrybush_juicy = 0.025,

            cave_fern = 3.5,

            slurper = 0.001,
            rabbithouse = 0.005,
        },
    }
})

-- Green Mush and Sinkhole Noise
AddRoom("GreenMushNoise", {
    colour={r=.36,g=.32,b=.38,a=.50},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    custom_tiles={
        GeneratorFunction = RUNCA.GeneratorFunction,
        data = {iterations=8, seed_mode=CA_SEED_MODE.SEED_RANDOM, num_random_points=2,
            translate={
                {tile=WORLD_TILES.FUNGUSGREEN, items={"mushtree_small", "flower_cave", "cave_fern"}, item_count=20},
                {tile=WORLD_TILES.FUNGUSGREEN, items={"mushtree_small", "flower_cave", "cave_fern"}, item_count=20},
                {tile=WORLD_TILES.FUNGUSGREEN, items={"mushtree_small", "flower_cave", "cave_fern"}, item_count=20},
                {tile=WORLD_TILES.SINKHOLE, items={"evergreen", "grass", "sapling", "berrybush"}, item_count=20},
                {tile=WORLD_TILES.SINKHOLE, items={"evergreen", "grass", "sapling"}, item_count=20},
            },
        },
    },
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            mushtree_small = 2.0,
            green_mushroom = 2.0,
            flower_cave = 0.5,
            flower_cave_double = 0.2,
            flower_cave_triple = 0.2,

            cave_fern = 3.5,

            slurper = 0.001,
            rabbithouse = 0.005,
        },
    }
})

local bggreenmush = {
    colour={r=0.1,g=0.8,b=0.1,a=0.9},
    value = WORLD_TILES.FUNGUSGREEN,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            mushtree_small = 6.0,
            green_mushroom = 0.5,
            flower_cave = 0.1,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            rabbithouse = 0.02,

            cave_fern = 2.5,

            slurper = 0.001,
        },
    }
}
AddRoom("BGGreenMush", bggreenmush)
AddRoom("BGGreenMushRoom", Roomify(bggreenmush))

