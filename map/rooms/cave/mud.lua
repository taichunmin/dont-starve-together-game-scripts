require "map/room_functions"


---------------------------------------------
-- Mud and spikes
-- Forms the center of the cave
-- Light plants, ferns, slurtles, and cave spikes
---------------------------------------------

-- Light plant field
AddRoom("LightPlantField", {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .2,
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

            slurtlehole = 0.01,

            slurper = 0.001,
        },
    }
})

-- Worm light field
AddRoom("WormPlantField", {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            flower_cave = 0.5,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite_tall=0.05,
            stalagmite_tall_med=0.05,
            stalagmite_tall_low=0.1,
            pillar_cave_rock = 0.01,

            cave_fern = 0.1,
            wormlight_plant = 0.2,

            slurtlehole = 0.01,

            slurper = 0.001,
        },
    }
})

-- Fern gully
AddRoom("FernGully", {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite_tall=0.5,
            stalagmite_tall_med=0.3,
            stalagmite_tall_low=0.2,
            pillar_cave_rock = 0.1,

            cave_fern = 2.0,
            wormlight_plant = 0.05,

            slurtlehole = 0.01,

            slurper = 0.001,
        },
    }
})

-- Slurtle plains
AddRoom("SlurtlePlains", {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .20,
        distributeprefabs=
        {
            flower_cave = 0.2,
            flower_cave_double = 0.1,
            flower_cave_triple = 0.1,

            stalagmite_tall=1.5,
            stalagmite_tall_med=0.5,
            stalagmite_tall_low=0.5,
            pillar_cave_rock = 0.1,

            cave_fern = 0.5,
            wormlight_plant = 0.01,

            slurtlehole = 0.5,
        },
    }
})

-- Rabbit hermit
AddRoom("MudWithRabbit", {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        countstaticlayouts =
        {
            ["RabbitHermit"] = 1,
        },
        distributepercent = .15,
        distributeprefabs=
        {
            flower_cave = 0.5,
            flower_cave_double = 0.3,
            flower_cave_triple = 0.2,

            stalagmite_tall=0.5,
            stalagmite_tall_med=0.3,
            stalagmite_tall_low=0.2,
            pillar_cave_rock = 0.1,

            cave_fern = 1.0,

            slurper = 0.001,
        },
    }
})

local bgmud = {
    colour={r=0.7,g=0.5,b=0.3,a=0.9},
    value = GROUND.MUD,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            flower_cave = 0.1,

            stalagmite_tall=1.5,
            stalagmite_tall_med=1.0,
            stalagmite_tall_low=0.5,
            pillar_cave_rock = 0.1,

            cave_fern = 1.0,

            slurtlehole = 0.05,

            slurper = 0.001,
        },
    }
}
AddRoom("BGMud", bgmud)
AddRoom("BGMudRoom", Roomify(bgmud))

