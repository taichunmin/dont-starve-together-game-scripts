
AddRoom("BGNoise", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = WORLD_TILES.GROUND_NOISE,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                countprefabs= {
					                    deerspawningground = 1,
					                },
					                distributepercent = .15,
									-- A bit of everything, and let terrain filters handle the rest.
					                distributeprefabs=
					                {
										flint=0.4,
										rocks=0.4,
										rock1=0.1,
										rock2=0.1,
										grass=0.09,
										smallmammal = {weight = 0.025, prefabs = {"rabbithole", "molehill"}},
										flower=0.003,
										spiderden=0.001,
										beehive=0.003,
										berrybush=0.05,
										berrybush_juicy = 0.025,
										sapling=0.2,
										twiggytree = 0.2,
										ground_twigs = 0.06,
										pond=.001,
					                    blue_mushroom = .001,
					                    green_mushroom = .001,
					                    red_mushroom = .001,
										evergreen=1.5,
					                },
					            }
					})
