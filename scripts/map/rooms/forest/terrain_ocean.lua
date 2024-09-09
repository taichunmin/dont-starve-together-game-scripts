
-- these are rooms used to populate the ocean as if each ocean tile type is a room (instead of a node being a room)

AddRoom("OceanCoastalShore", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_COASTAL_SHORE,
					contents =  {
						distributepercent = 0.005,
						distributeprefabs =
						{
							wobster_den_spawner_shore = 1,
						},
					}})

AddRoom("OceanCoastal", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_COASTAL,
					contents =  {
						distributepercent = 0.01,
						distributeprefabs =
						{
							driftwood_log = 3,
							bullkelp_plant = 6,
							messagebottle = 0.24,
							boat_otterden = 1,
						},

						countstaticlayouts =
						{
							["BullkelpFarmSmall"] = 6,
							["BullkelpFarmMedium"] = 3,
						},
					}})

AddRoom("OceanSwell", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_SWELL,
				    required_prefabs = {"crabking_spawner"},
					contents =  {
						distributepercent = 0.004,
						distributeprefabs =
						{
							seastack = 1.0,
							seastack_spawner_swell = 0.10,
							oceanfish_shoalspawner = 0.08,
                        },
						countstaticlayouts =
						{
							["CrabKing"] = 1,
							["AbandonedBoat1"] = function () return math.random(0, 1) end,
							["AbandonedBoat2"] = function () return math.random(0, 1) end,
							["OceanMonument"]  = function () return math.random(0, 2) end,
						},
					}})

AddRoom("OceanRough", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_ROUGH,
				    required_prefabs = {
                        "hermithouse_construction1",
                        "waterplant",
						"monkeyqueen",
                    },
					contents =  {
						distributepercent = 0.01,
						distributeprefabs =
						{
							seastack = 1,
							seastack_spawner_rough = 0.09,
                            waterplant_spawner_rough = 0.04,
						},
						countstaticlayouts =
						{
							["HermitcrabIsland"] = 1,
							["MonkeyIsland"] = 1,
						},
					}})

AddRoom("OceanHazardous", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_HAZARDOUS,
					contents =  {
		                countprefabs = {
		                },
						distributepercent = 0.15,
						distributeprefabs =
						{
							boatfragment03 = 1,
							boatfragment04 = 1,
							boatfragment05 = 1,
							seastack = 1,
						},
					}})


AddRoom("OceanReef", { -- OceanReef is deprecated
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = WORLD_TILES.OCEAN_REEF,
					contents =  {
						distributepercent = 0,
						distributeprefabs =
						{
						},
					}})
