require "map/room_functions"

---------------------------------------------
-- Bat Caves
---------------------------------------------

-- Classic bat cave
AddRoom("BatCave", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.CAVE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .15,
        distributeprefabs=
        {
            batcave = 0.05,
            guano = 0.27,
            goldnugget=.05,
            flint=0.05,
            stalagmite_tall=0.4,
            stalagmite_tall_med=0.4,
            stalagmite_tall_low=0.4,
            pillar_cave_rock = 0.08,
            fissure = 0.05,
        }
    }
})

-- Very batty bat cave
AddRoom("BattyCave", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.CAVE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            batcave = 0.15,
            guano = 0.27,
            goldnugget=.05,
            flint=0.05,
            stalagmite_tall=0.4,
            stalagmite_tall_med=0.4,
            stalagmite_tall_low=0.4,
            pillar_cave_rock = 0.08,
            fissure = 0.05,
        }
    }
})
-- Ferny bat cave
AddRoom("FernyBatCave", {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.CAVE,
    tags = {"Hutch_Fishbowl"},
    type = NODE_TYPE.Room,
    contents =  {
        distributepercent = .25,
        distributeprefabs=
        {
            cave_fern = 0.5,
            batcave = 0.05,
            guano = 0.27,
            goldnugget=.05,
            flint=0.05,
            stalagmite_tall=0.1,
            stalagmite_tall_med=0.1,
            stalagmite_tall_low=0.1,
            pillar_cave_rock = 0.08,
            fissure = 0.05,
        }
    }
})

local bgbatcave = {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = GROUND.CAVE,
    tags = {"Hutch_Fishbowl"},
    contents =  {
        distributepercent = .13,
        distributeprefabs=
        {
            batcave = 0.05,
            stalagmite_tall=0.4,
            stalagmite_tall_med=0.4,
            stalagmite_tall_low=0.4,
            pillar_cave_rock = 0.01,
            fissure = 0.05,
        }
    }
}
AddRoom("BGBatCave", bgbatcave)
AddRoom("BGBatCaveRoom", Roomify(bgbatcave))

