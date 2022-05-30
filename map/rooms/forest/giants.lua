require ("map/room_functions")

AddRoom("MooseGooseBreedingGrounds", {
	colour={r=0.2,g=0.0,b=0.2,a=0.3},
	value = GROUND.GRASS,
	tags = {"ForceConnected", "RoadPoison"},
	contents =
	{
        countprefabs=
        {
			moose_nesting_ground = 4,
        },
        distributepercent = 0.275,
        distributeprefabs =
        {
        	berrybush = 0.5,
        	berrybush_juicy = 0.25,
        	carrot_planted = 0.5,
			flower = 0.333,
			grass = 0.8,
			flint = 0.1,
			sapling = 0.8,
			twiggytree = .32,
            evergreen = 1,
			pond = 0.01,
        },
    }
})

-- AddRoom("MooseGooseNestGrass", {
-- 	colour={r=0.2,g=0.0,b=0.2,a=0.3},
-- 	value = GROUND.GRASS,
-- 	tags = {"ForceConnected", "RoadPoison"},
-- 	contents =
-- 	{
--         countprefabs=
--         {
-- 			moose_nesting_ground = 1,
--         },
--         distributepercent = 0.275,
--         distributeprefabs =
--         {
--         	berrybush = 0.5,
--         	carrot_planted = 0.5,
-- 			flower = 0.333,
-- 			grass = 0.8,
-- 			flint = 0.1,
-- 			sapling = 0.8,
-- 			evergreen = 1,
-- 			pond = 0.01,
--         },
--     }
-- })

-- AddRoom("MooseGooseNestForest", {
-- 	colour={r=0.2,g=0.0,b=0.2,a=0.3},
-- 	value = GROUND.FOREST,
-- 	tags = {"ForceConnected", "RoadPoison"},
-- 	contents =
-- 	{
--         countprefabs=
--         {
-- 			moose_nesting_ground = 1,
--         },
--         distributepercent = 0.275,
--         distributeprefabs =
--         {
--         	berrybush = 0.5,
--         	carrot_planted = 0.5,
-- 			flower = 0.333,
-- 			grass = 0.8,
-- 			flint = 0.1,
-- 			sapling = 0.8,
-- 			evergreen = 1,
-- 			pond = 0.01,
--         },
--     }
-- })