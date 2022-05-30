
AddRoom("BGGrassBurnt", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_1"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
					                	rock1=0.01,
										rock2=0.01,
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										smallmammal = {weight = 0.02, prefabs = {"rabbithole", "molehill"}},
										flint=0.05,
										sapling=0.2,
										twiggytree = 0.2,
										ground_twigs = 0.08,
										evergreen=0.3,
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					})
AddRoom("BGGrass", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_2", "StagehandGarden"},
					contents =  {
									countprefabs = {
    										spawnpoint_multiplayer = 1,
    									},
					                distributepercent = .275,
					                distributeprefabs=
					                {
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										smallmammal = {weight = 0.02, prefabs = {"rabbithole", "molehill"}},
										carrot_planted=0.05,
										flint=0.05,
										berrybush=0.05,
										berrybush_juicy = 0.025,
										sapling=0.2,
										twiggytree = 0.2,
										ground_twigs = 0.08,
										tree = {weight = 0.3, prefabs = {"evergreen", "deciduoustree"}},
										pond=.001,
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                },
					            }
					})
AddRoom("FlowerPatch", {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_1", "StagehandGarden"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower=2,
					                    beehive=1,
					                },
					            }
					})
AddRoom("GrassyMoleColony", {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_2"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        flower = 1,
					                    molehill=2,
					                    rocks=.3,
					                    flint=.3,
					                },
					            }
					})
AddRoom("EvilFlowerPatch", {
					colour={r=.8,g=1,b=.4,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone", "Astral_1"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower_evil=2,
					                    wasphive=0.5,
					                },
					            }
					})
