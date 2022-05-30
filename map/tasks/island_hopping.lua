------------------------------------------------------------
-- Island Hopping
------------------------------------------------------------

AddTask("IslandHop_Start", { -- Sweet starting node, horrid other than that (leave the island)
		locks=LOCKS.NONE,
		keys_given=KEYS.MEAT,
		room_choices={
			["SpiderMarsh"] = function() return 1+math.random(2) end,
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={1,.5,.5,.2},
	})

AddTask("IslandHop_Hounds", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SpiderForest"] = function() return 1+math.random(2) end,
		},
		room_bg=GROUND.DIRT,
		background_room="BGBadlands",
		colour={1,.5,.5,.2},
	})

AddTask("IslandHop_Forest", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["Waspnests"] = function() return 1+math.random(2) end,
		},
		-- room_choices={
		-- 	["DeepForest"] = function() return 1+math.random(2) end,
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGDeepForest",
		colour={1,.5,.5,.2},
	})

AddTask("IslandHop_Savanna", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["BeefalowPlain"] = function() return 1+math.random(2) end,
		},
		-- room_choices={
		-- 	["BeefalowPlain"] = function() return 1+math.random(2) end,
		-- },
		room_bg=GROUND.DIRT,
		background_room="BGSavanna",
		colour={1,.5,.5,.2},
	})

AddTask("IslandHop_Rocky", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["Rocky"] = function() return 1+math.random(2) end,
		},
		room_bg=GROUND.DIRT,
		background_room="BGRocky",
		colour={1,.5,.5,.2},
	})

AddTask("IslandHop_Merm", {
		locks=LOCKS.MEAT,
		keys_given=KEYS.MEAT,
		entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["SlightlyMermySwamp"] = function() return 1+math.random(2) end,
		},
		room_bg=GROUND.DIRT,
		background_room="BGMarsh",
		colour={1,.5,.5,.2},
	})
