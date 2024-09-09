require "map/tasks/dst_tasks_forestworld" 

AddTask("Oasis", {
		locks={LOCKS.ADVANCED_COMBAT,LOCKS.TIER4, LOCKS.MONSTERS_DEFEATED},
		keys_given={KEYS.ROCKS, KEYS.TIER5},
		room_choices={
			["Badlands"] = 3,
			["PondyGrass"] = 1,
			["BuzzardyBadlands"] = 2,
		},
		room_bg=WORLD_TILES.DIRT,
		background_room="BGBadlands",
		colour={r=.05,g=.5,b=.05,a=1},
	})

