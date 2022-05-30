
AddRoom("BurntForestStart", {
					colour={r=.010,g=.010,b=.010,a=.50},
					value = GROUND.FOREST,
					contents =  {
									countprefabs= {
										firepit=1,
									},
									distributepercent = 0.6,
									distributeprefabs= {
										evergreen = function() return 3 + math.random(4) end,
										charcoal = 0.2,
									},
									prefabdata={
										evergreen = {burnt=true},
									}
								}
					})
AddRoom("SafeSwamp", {
					colour={r=0.2,g=0.0,b=0.2,a=0.3},
					value = GROUND.MARSH,
					contents =  {
					                distributepercent = 0.2,
									distributeprefabs = {
										marsh_tree=1,
										marsh_bush=1,
					                }
					            }
					})

