require "map/room_functions"

---------------------------------------------
-- Rocky
---------------------------------------------

-- Slurtle Canyon
AddRoom("SlurtleCanyon", {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 1.2,

            slurtlehole = 0.5,

            fissure = 0.01,
        },
    }
})

-- Bats and Slurtles
AddRoom("BatsAndSlurtles", {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 0.2,

            stalagmite_tall=0.5,
            stalagmite_tall_med=0.2,
            stalagmite_tall_low=0.2,
            pillar_cave_rock = 0.1,

            slurtlehole = 0.5,
            batcave = 0.1,

            fissure = 0.01,
        },
    }
})

-- Rocky Plains
AddRoom("RockyPlains", {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .10,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 0.2,

            rocky = 0.5,
            goldnugget=.05,
            rocks=.1,
            flint=0.05,

            slurtlehole = 0.05,

            fissure = 0.01,
        },
    }
})

-- Rocky Hatching Grounds
AddRoom("RockyHatchingGrounds", {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 0.2,

            rocky = 1.0,
            goldnugget=.05,
            rocks=.1,
            flint=0.05,

            slurtlehole = 0.05,

            fissure = 0.01,
        },
    }
})

-- Bats and Rocky
AddRoom("BatsAndRocky", {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .20,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 0.8,

            stalagmite_tall=0.5,
            stalagmite_tall_med=0.2,
            stalagmite_tall_low=0.2,
            pillar_cave_rock = 0.1,

            rocky = 0.5,
            goldnugget=.05,
            rocks=.1,
            flint=0.05,

            slurtlehole = 0.05,
            batcave = 0.10,

            fissure = 0.01,
        },
    }
})

local bgrocky = {
    colour={r=0.7,g=0.7,b=0.7,a=0.9},
    value = WORLD_TILES.CAVE_NOISE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .10,
        distributeprefabs=
        {
            rock_flintless = 1.0,
            rock_flintless_med = 1.0,
            rock_flintless_low = 1.0,
            pillar_cave_flintless = 0.2,

            slurtlehole = 0.05,

            fissure = 0.01,
        },
    }
}
AddRoom("BGRockyCave", bgrocky)
AddRoom("BGRockyCaveRoom", Roomify(bgrocky))

