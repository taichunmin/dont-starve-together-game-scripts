require "map/room_functions"

---------------------------------------------
-- Swamp
---------------------------------------------

-- Vast sinkhole swamp
AddRoom("SinkholeSwamp", {
    colour={r=0.4,g=0.1,b=0.6,a=0.9},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            tentacle = 1,
            reeds = 0.5,
            marsh_bush = 1.5,
            marsh_tree = 0.2,
            spiderden = 0.2,

            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
        },
    }
})

-- Dark swamp
AddRoom("DarkSwamp", {
    colour={r=0.4,g=0.1,b=0.6,a=0.9},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            tentacle = 0.5,
            reeds = 0.1,
            marsh_bush = 1.5,
            spiderden = 0.02,

            cavelight_tiny = 0.5,
        },
    }
})

-- Tentacle mud (noise)
AddRoom("TentacleMud", {
    colour={r=0.4,g=0.1,b=0.6,a=0.9},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        countstaticlayouts={
            ["Mudlights"]=6,
        },
        distributepercent = .25,
        distributeprefabs=
        {
            tentacle = 1,
            marsh_bush = 1.5,
            reeds = 0.1,
            spiderden = 0.05,

            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
        },
    }
})

-- Tentacle forest (noise)
AddRoom("TentaclesAndTrees", {
    colour={r=0.4,g=0.1,b=0.6,a=0.9},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        countstaticlayouts={
            ["EvergreenSinkhole"]=3,
        },
        distributepercent = .25,
        distributeprefabs=
        {
            tentacle = 1,
            marsh_bush = 1.5,
            marsh_tree = 1.2,
            spiderden = 0.2,

            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
        },
    }
})

AddRoom("SpiderSinkholeMarsh", {
    colour={r=.45,g=.75,b=.45,a=.50},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .1,
        distributeprefabs=
        {
            evergreen = 1.0,
            tentacle = 2,
            pond_mos = 0.1,
            blue_mushroom = 0.1,
            reeds =  4,
            spiderden=3.15,

            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
        },
        prefabdata = {
            spiderden = function() if math.random() < 0.2 then
                return { growable={stage=2}}
            else
                return { growable={stage=1}}
            end
        end,
    },
}
                    })

local bgsinkholeswamp = {
    colour={r=0.4,g=0.1,b=0.6,a=0.9},
    value = WORLD_TILES.MARSH,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .35,
        distributeprefabs=
        {
            tentacle = 1,
            reeds = 0.5,
            marsh_bush = 1.5,
            marsh_tree = 0.2,
            spiderden = 0.2,

            cavelight = 0.5,
            cavelight_small = 0.5,
            cavelight_tiny = 0.5,
        },
    }
}
AddRoom("BGSinkholeSwamp", bgsinkholeswamp)
AddRoom("BGSinkholeSwampRoom", Roomify(bgsinkholeswamp))
