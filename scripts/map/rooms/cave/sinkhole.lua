require "map/room_functions"

---------------------------------------------
-- Sinkhole
---------------------------------------------

-- Sprawling forest
AddRoom("SinkholeForest", {
    colour={r=0.2,g=1,b=0.5,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .55,
        distributeprefabs=
        {
            grass = 1,
            sapling = .8,
            twiggytree = .32,
            evergreen = 6.3,
            fireflies = .1,
            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
            spiderden = 0.3,
        },
    }
})

-- Patchy Forest
AddRoom("SinkholeCopses", {
    colour={r=0.2,g=1,b=0.5,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts={
            ["EvergreenSinkhole"]=3,
        },
        distributepercent = .15,
        distributeprefabs=
        {
            grass = 1,
            sapling = .8,
            twiggytree = .32,
            evergreen = .3,
            cave_fern = .75,
            berrybush = .2,
            berrybush_juicy = 0.1,
            fireflies = .1,
            cavelight = 0.01,
            cavelight_small = 0.01,
            cavelight_tiny = 0.01,
            spiderden = 0.03,
        },
    }
})

-- Sparse sinkholes
AddRoom("SparseSinkholes", {
    colour={r=0.1,g=0.8,b=0.2,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            grass = 1,
            sapling = .8,
            twiggytree = .32,
            evergreen = .3,
            cave_fern = .75,
            fireflies = .1,
            cavelight = 0.06,
            cavelight_small = 0.06,
            cavelight_tiny = 0.06,
            spiderden = 0.03,
        },
    }
})

-- Oasis
AddRoom("SinkholeOasis", {
    colour={r=0.1,g=0.8,b=0.2,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts={
            ["PondSinkhole"]=1,
        },
        distributepercent = .15,
        distributeprefabs=
        {
            grass = 1,
            sapling = .8,
            twiggytree = .32,
            pond = .05,
            stalagmite = 0.02,
            stalagmite_med = 0.007,
            stalagmite_low = 0.003,
            cave_fern = .75,
            berrybush = .2,
            berrybush_juicy = 0.1,
            fireflies = .1,
            cavelight = 0.01,
            cavelight_small = 0.01,
            cavelight_tiny = 0.01,
            spiderden = 0.03,
        },
    }
})

-- Grasslands
AddRoom("GrasslandSinkhole", {
    colour={r=0.1,g=0.8,b=0.2,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts={
            ["GrassySinkhole"]=1,
        },
        distributepercent = .05,
        distributeprefabs=
        {
            grass = 2,
            cavelight = 0.6,
            cavelight_small = 0.6,
            cavelight_tiny = 0.6,
        },
    }
})


local bgsinkhole = {
    colour={r=0.1,g=0.8,b=0.2,a=0.9},
    value = WORLD_TILES.SINKHOLE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            grass = 1,
            sapling = .8,
            twiggytree = .32,
            evergreen = .3,
            cave_fern = .75,
            fireflies = .1,
            cavelight = 0.06,
            cavelight_small = 0.06,
            cavelight_tiny = 0.06,
            spiderden = 0.03,
        },
    }
}
AddRoom("BGSinkhole", bgsinkhole)
AddRoom("BGSinkholeRoom", Roomify(bgsinkhole))

