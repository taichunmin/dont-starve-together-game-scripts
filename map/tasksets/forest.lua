AddTaskSet("default", {
		name = STRINGS.UI.CUSTOMIZATIONSCREEN.TASKSETNAMES.DEFAULT,
        location = "forest",
		tasks = {
			"Make a pick",
			"Dig that rock",
			"Great Plains",
			"Squeltch",
			"Beeeees!",
			"Speak to the king",
			"Forest hunters",
			"Badlands",
			"For a nice walk",
			"Lightning Bluff",
			
			-- meteor island
			"MoonIsland_IslandShards",
			"MoonIsland_Beach",
			"MoonIsland_Forest",
			"MoonIsland_Baths",
			"MoonIsland_Mine",
		},
		numoptionaltasks = 5,
		optionaltasks = {
			"Befriend the pigs",
			"Kill the spiders",
			"Killer bees!",
			"Make a Beehat",
			"The hunters",
			"Magic meadow",
			"Frogs and bugs",
			"Mole Colony Deciduous",
			"Mole Colony Rocks",
			"MooseBreedingTask",
		},
        valid_start_tasks = {
            "Make a pick",
        },
		set_pieces = {
			["ResurrectionStone"] = { count = 2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Badlands" } },
			["WormholeGrass"] = { count = 8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands"} },
			["MooseNest"] = { count = 9, tasks={"Make a pick", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Make a Beehat", "Magic meadow", "Frogs and bugs"} },
			["CaveEntrance"] = { count = 10, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
			["MoonAltarRockGlass"] = { count = 1, tasks={"MoonIsland_Mine"} },
			["MoonAltarRockIdol"] = { count = 1, tasks={"MoonIsland_Mine"} },
			["MoonAltarRockSeed"] = { count = 1, tasks={"MoonIsland_Mine"} },
            ["BathbombedHotspring"] = {count = 1, tasks={"MoonIsland_Baths"}},
		},
		ocean_prefill_setpieces = {
			--["AbandonedWarf1"] = {count = 2},
			--["AbandonedWarf2"] = {count = 1},
			--["AbandonedWarf3"] = {count = 1},
		},

		ocean_population = {
			"OceanCoastal", 
			"OceanSwell",
			"OceanRough",
			"OceanReef",
			"OceanHazardous",
		},
		-- ocean_population_setpieces =
		-- {
		-- },
	})

AddTaskSet("classic", {
		name = STRINGS.UI.CUSTOMIZATIONSCREEN.TASKSETNAMES.CLASSIC,
        location = "forest",
		tasks = {
			"Make a pick",
			"Dig that rock",
			"Great Plains",
			"Squeltch",
			"Beeeees!",
			"Speak to the king classic",
			"Forest hunters",
			"For a nice walk",
		},
		numoptionaltasks = 4,
		optionaltasks = {
			"Befriend the pigs",
			"Kill the spiders",
			"Killer bees!",
			"Make a Beehat",
			"The hunters",
			"Magic meadow",
			"Frogs and bugs",
		},
        valid_start_tasks = {
            "Make a pick",
        },
		set_pieces = {
			["ResurrectionStone"] = { count=2, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters" } },
			["WormholeGrass"] = { count=8, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs" } },
			["CaveEntrance"] = { count = 10, tasks={"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king classic", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs"} },
		},
	})
