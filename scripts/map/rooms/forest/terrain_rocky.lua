AddRoom("BGChessRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = WORLD_TILES.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_1"},
					contents =  {
									countstaticlayouts = {
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										tallbirdnest=0.008,
					                },
					            }
					})

AddRoom("BGRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = WORLD_TILES.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_2", "CharlieStage_Spawner"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
										flint=0.5,
										rock1=1,
										rock2=1,
										rock_ice=0.4,
										tallbirdnest=0.008,
										grassgekko = 0.3,
					                },
					            }
					})
	-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
AddRoom("Rocky", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = WORLD_TILES.DIRT,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_1"},
					contents =  {
									countprefabs=
									{
										meteorspawner = function() return math.random(1,2) end,
										rock_moon = function() return math.random(1,2) - 1 end,
										burntground_faded = function() return math.random(3,5) end,
										tallbirdnest = 1,
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    rock1 = 2,
					                    rock2 = 2,
										rock_ice = 1,
					                    tallbirdnest=.1,
					                    spiderden=.01,
					                    blue_mushroom = .002,
					                    grassgekko = 0.3,
					                },
					            }
					})
AddRoom("RockyBuzzards", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = WORLD_TILES.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_2"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                	rock1 = 2,
					                    rock2 = 2,
					                    buzzardspawner = .1,
					                    blue_mushroom = .002,
					                },
					            }
					})

AddRoom("GenericRockyNoThreat", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = WORLD_TILES.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_1"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                	rock1 = 2,
					                    rock2 = 2,
					                    rock_ice = .75,
					                    rocks = 1,
					                    flint = 1,
					                    blue_mushroom = .002,
					                    green_mushroom = .002,
					                    red_mushroom = .002,
					                    grassgekko = 0.3,
					                },
					            }
					})

AddRoom("MolesvilleRocky", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = WORLD_TILES.ROCKY,
					contents =  {
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = 0.2,
										rock1 = 1,
										rock2 = 1,
										rock_ice = .3,
										rocks = .5,
										flint = .1,
										grass = 0.1,
										molehill = 1,
										grassgekko = 0.3,
									},
					            }
					})
