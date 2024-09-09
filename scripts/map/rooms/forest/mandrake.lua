
AddRoom("MandrakeHome", {
					colour={r=0.3,g=0.4,b=0.8,a=0.3},
					value = WORLD_TILES.GRASS,
					contents =  {
									countstaticlayouts=
									{
										["InsanePighouse"]=function() if math.random(1000)> 995 then
																		return 1
																	  else
																	  	return 0
																	  end
															end,
									},
					                countprefabs= {
                                        mandrake_planted = 1,
					                },
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    flower = 4,
                                        fireflies = 0.3,
					                    evergreen = 6,
					                    grass = .05,
					                    sapling=.5,
					                    twiggytree=0.2,
					                    berrybush=.05,
					                    berrybush_juicy = 0.025,
					                },
					            }
					})
