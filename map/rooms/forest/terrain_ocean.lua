
-- these are rooms used to populate the ocean as if each ocean tile type is a room (instead of a node being a room)

AddRoom("OceanCoastal", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_COASTAL,
					contents =  {
						distributepercent = 0.01,
						distributeprefabs =
						{
							driftwood_log = 1,
							bullkelp_plant = 2,
						},

						countstaticlayouts =
						{
							["BullkelpFarmSmall"] = 6,
							["BullkelpFarmMedium"] = 3,
						},
					}})

AddRoom("OceanSwell", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_SWELL,
					contents =  {
						distributepercent = 0.005,
						distributeprefabs =
						{
							seastack = 1.0,
							seastack_spawner_swell = 0.1,
						},						
					}})

AddRoom("OceanRough", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_ROUGH,
					contents =  {
						distributepercent = 0.01 ,
						distributeprefabs =
						{
							seastack = 1,
							seastack_spawner_rough = 0.13,
						},							
					}})

AddRoom("OceanReef", {
					colour={r=.5,g=0.6,b=.080,a=.10}, 
					value = GROUND.OCEAN_REEF,
					contents =  {
						distributepercent = 0.3, 
						distributeprefabs =
						{

						},						
					}})

AddRoom("OceanHazardous", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_HAZARDOUS,
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
