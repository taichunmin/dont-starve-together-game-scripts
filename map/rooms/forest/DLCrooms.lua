AddRoom("BGBadlands", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									distributepercent = 0.07,
									distributeprefabs =
									{
										marsh_bush = 0.05,
										marsh_tree = 0.2,
										rock_flintless = 1,
										--rock_ice = .5,
										grass = 0.1,
										grassgekko = 0.4,
										houndbone = 0.2,
										cactus = 0.2,
										tumbleweedspawner = .05,
									},
					            }
					})

AddRoom("Lightning", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									distributepercent = 0.05,
									distributeprefabs =
									{
										marsh_bush = .8,
										grass = .5,
										grassgekko = 0.4,
										--rock_ice = .5,
										lightninggoat = 1,
										cactus = .8,
										tumbleweedspawner = .1,
									},
								}
					})

AddRoom("Badlands", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									distributepercent = 0.07,
									distributeprefabs =
									{
										rock_flintless = .8,
										--rock_ice = .5,
										marsh_bush = 0.25,
										marsh_tree = 0.75,
										grass = .5,
										grassgekko = 0.6,
										cactus = .7,
										houndbone = .6,
										tumbleweedspawner = .1,
									},
					            }
					})

AddRoom("DragonflyArena", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									countstaticlayouts={["DragonflyArena"]=1}, -- using a static layout because this can force it to be in the center of the room
									distributepercent = 0.1,
									distributeprefabs =
									{
										rock_flintless = .8,
										marsh_bush = 0.25,
										marsh_tree = 0.75,
										cactus = .7,
										houndbone = .6,
									},
					            }
					})

AddRoom("HoundyBadlands", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									distributepercent = 0.2,
									distributeprefabs =
									{
										rock1 = .5,
										rock2 = 1,
										--rock_ice = .1,
										houndbone = .5,
										houndmound = .33,
									},
					            }
					})

AddRoom("BuzzardyBadlands", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					contents =  {
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = .66,
										marsh_tree = 1,
										grass = .33,
										grassgekko = 0.4,
										buzzardspawner = .25,
										houndbone = .15,
										tumbleweedspawner = .1,
									},
					            }
					})

AddRoom("BGDeciduous", {
					colour={r=.1,g=.8,b=.1,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_2"},
					contents =  {
					                countprefabs= {
					                    pumpkin = function () return IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and (0 + math.random(3)) or 0 end,
					                    deerspawningground = 1,
					                },

					                distributepercent = .2,
					                distributeprefabs=
					                {
										deciduoustree=6,

										pighouse=.1,
										catcoonden=.1,

										rock1=0.05,
										rock2=0.05,

										sapling=1,
					                    twiggytree=0.4,
										grass=0.03,

										flower=0.75,

					                    red_mushroom = 0.3,
					                    blue_mushroom = 0.3,
					                    green_mushroom = 0.3,
										berrybush=0.1,
										berrybush_juicy = 0.05,
										carrot_planted = 0.1,

										fireflies = 1,

										pond=.01,
					                },
					            }
					})

AddRoom("DeepDeciduous", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_1"},
					contents =  {
					                countprefabs =
					                {
					                    deerspawningground = 1,
					                },
					                distributepercent = .4,
					                distributeprefabs=
					                {
					                    grass = .03,
					                    sapling=1,
					                    twiggytree=0.4,
					                    berrybush=.1,
					                    berrybush_juicy = 0.05,

					                    deciduoustree = 10,
					                    catcoonden = .05,

					                    red_mushroom = 0.15,
					                    blue_mushroom = 0.15,
					                    green_mushroom = 0.15,

                                        fireflies = 3,

					                },
					            }
					})

AddRoom("MagicalDeciduous", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_2"},
                    required_prefabs = {"statueglommer"},
					contents =  {
					                countprefabs =
					                {
					                    catcoonden = 1,
					                },
									countstaticlayouts={
										["DeciduousPond"] = 1,
									},

					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    grass = .03,
					                    sapling=1,
					                    twiggytree=0.4,

					                    red_mushroom = 2,
					                    blue_mushroom = 2,
					                    green_mushroom = 2,

                                        fireflies = 4,
										flower=5,

										molehill = 2,
										catcoonden = .25,

										berrybush = 3,
										berrybush_juicy = 1.5,
					                },
					            }
					})

AddRoom("DeciduousMole", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_1"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
                                        fireflies = 0.2,
					                    rock1 = 0.05,
					                    grass = .05,
					                    sapling=.8,
					                    twiggytree=0.32,
					                    rocks=.05,
					                    flint=.05,
					                    molehill=.5,
					                    catcoonden=.05,
					                    berrybush=.03,
					                    berrybush_juicy = 0.015,
					                    deciduoustree = 6,
					                    red_mushroom = 0.3,
					                    blue_mushroom = 0.3,
					                    green_mushroom = 0.3,
					                },
					            }
					})

AddRoom("MolesvilleDeciduous", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_2"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
                                        fireflies = 0.1,
					                    molehill=.7,
					                    grass = .05,
					                    sapling=.5,
					                    twiggytree=0.2,
					                    rocks=.03,
					                    flint=.03,
					                    berrybush=.02,
					                    berrybush_juicy = 0.01,
					                    deciduoustree = 6,
					                    red_mushroom = 0.3,
					                    blue_mushroom = 0.3,
					                    green_mushroom = 0.3,
					                },
					            }

					})

AddRoom("DeciduousClearing", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.DECIDUOUS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_1"},
					contents =  {
									countstaticlayouts={["MushroomRingLarge"]=function()
																				if math.random(0,1000) > 985 then
																					return 1
																				end
																				return 0
																			   end},
					                distributepercent = .2,
					                distributeprefabs=
					                {

					                	deciduoustree = 1,

                                        fireflies = 1,

					                    grass = .5,
					                    sapling = .5,
					                    twiggytree = .2,
										berrybush = .5,
					                    berrybush_juicy = 0.25,

					                    red_mushroom = .5,
					                    blue_mushroom = .5,
					                    green_mushroom = .5,
					                },
					            }
					})


AddRoom("PondyGrass", {
					colour={r=0,g=.9,b=0,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone","Astral_2"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
                                        fireflies = 0.1,
					                    grass = .05,
					                    sapling=.2,
					                    twiggytree=0.08,
					                    berrybush=.02,
					                    berrybush_juicy = 0.01,
					                    pond = 0.15,
					                    deciduoustree = 1,
					                    catcoonden = .05,

					                },
					            }

					})

AddRoom("BGLightningBluff", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					tags = {"RoadPoison", "sandstorm"},
					contents =  {
									distributepercent = 0.06,
									distributeprefabs =
									{
										marsh_bush = 0.15,
										rock_flintless = .5,
										houndbone = 0.2,
										oasis_cactus = 0.2,
										buzzardspawner = .05,
									},
					            }
					})

AddRoom("LightningBluffAntlion", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					tags = {"RoadPoison", "sandstorm"},
					contents =  {
									countstaticlayouts={["AntlionSpawningGround"]=1}, -- using a static layout because this can force it to be in the center of the room
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = .66,
										oasis_cactus = 0.1,
										houndbone = .5,
									},
					            }
					})

AddRoom("LightningBluffOasis", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					tags = {"RoadPoison", "sandstorm"},
					contents =  {
									countstaticlayouts={["Oasis"]=1}, -- using a static layout because this can force it to be in the center of the room
									distributepercent = 0.06,
									distributeprefabs =
									{
										marsh_bush = 0.15,
										houndbone = 0.2,
										oasis_cactus = 0.02,
										buzzardspawner = .05,
									},
					            }
					})

AddRoom("LightningBluffLightning", {
					colour={r=0.3,g=0.2,b=0.1,a=0.3},
					value = GROUND.DIRT_NOISE,
					tags = {"RoadPoison", "sandstorm"},
					contents =  {
					                countprefabs= {
					                    lightninggoat = function () return 2 + math.random(4) end,
					                },
									distributepercent = 0.08,
									distributeprefabs =
									{
										marsh_bush = .8,
										oasis_cactus = 0.8,
									},
								}
					})

