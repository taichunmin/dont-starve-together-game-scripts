
AddRoom("BeeClearing", {
					colour={r=.8,g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					contents =  {
					                countprefabs= {
                                        fireflies= 1,
					                    flower=6,
					                    beehive=1,
					                }
					            }
					})

AddRoom("BeeQueenBee", {
					colour={r=.8,g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					contents =  {
					                countprefabs= {
                                        beequeenhive=1,
										beehive=1,
										wasphive=function() return math.random(2) end,
					                },
					                distributepercent = .45,
					                distributeprefabs=
					                {
										flower=5,
										berrybush=0.5,
										berrybush_juicy=0.25,
										sapling=0.2,
					                },
					            }
					})
