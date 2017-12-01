require("constants")

local StaticLayout = require("map/static_layout")
local ExampleLayout = 
	{
		["Farmplot"] = 
						{
							-- Choose layout type
							type = LAYOUT.STATIC,
							
							-- Add any arguments for the layout function
							args = nil,
							
							-- Define a choice list for substitution below
							defs = 
								{
								 	unknown_plant = { "carrot_planted","flower", "grass", "berrybush2" },
								},
							
							-- Lay the objects in whatever pattern
							layout = 
								{
									unknown_plant = {
													 {x=-1,y=-1}, {x=0,y=-1}, {x=1,y=-1},
													 {x=-1, y=0}, {x=0, y=0}, {x=1, y=0},
													 {x=-1, y=1}, {x=0, y=1}, {x=1, y=1}
													},
								},
								
							-- Either choose to specify the objects positions or a number of objects
							count = nil,
								
							-- Choose a scale on which to place everything
							scale = 0.3
						},
		["StoneHenge"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "rock2", "rock1", "evergreen_tall", "evergreen_normal", "evergreen_short", "sapling"},
								},
							count = 
								{
									unknown_plant = 9,
								},
							scale = 1.2
						},						 
		["CropCircle"] = 
						{
							type = LAYOUT.CIRCLE_RANDOM,
							defs = 
								{
								 	unknown_plant = { "carrot_planted", "grass", "flower", "berrybush2"},
								},
							count = 
								{
									unknown_plant = 15,
								},
							scale = 1.5
						},
		["HalloweenPumpkins"] = 
						{
							type = LAYOUT.CIRCLE_RANDOM,
							defs = 
								{
								 	unknown_plant = { "pumpkin" },
								},
							count = 
								{
									unknown_plant = 15,
								},
							scale = 1.5
						},
		["TreeFarm"] = 
						{
							type = LAYOUT.GRID,
							count = 
								{
									evergreen_short = 16,
								},
							scale = 0.9
						},
		["MushroomRingSmall"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 7,
								},
							scale = 1
						},
		["MushroomRingMedium"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 10,
								},
							scale = 1.2
						},
		["MushroomRingLarge"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 15,
								},
							scale = 1.5
						},
		["SimpleBase"] = StaticLayout.Get("map/static_layouts/simple_base", {
							areas = {
								construction_area = function() return PickSome(2, { "birdcage", "cookpot", "firepit", "homesign", "beebox", "meatrack", "icebox", "tent" }) end,
							},
						}),
		["RuinedBase"] = StaticLayout.Get("map/static_layouts/ruined_base", {
							areas = {
								construction_area = function() return PickSome(2, { "birdcage", "cookpot", "firepit", "homesign", "beebox", "meatrack", "icebox", "tent" }) end,
							},
						}),
		["Grotto"] = StaticLayout.Get("map/static_layouts/grotto"),


		["ResurrectionStone"] = StaticLayout.Get("map/static_layouts/resurrectionstone"),
		["ResurrectionStoneLit"] = StaticLayout.Get("map/static_layouts/resurrectionstonelit"),
		["ResurrectionStoneWinter"] = StaticLayout.Get("map/static_layouts/resurrectionstone_winter", {
				areas = {
					item_area = function() return nil end,							
					resource_area = function() 
							local choices = {{"cutgrass","cutgrass","twigs", "twigs"}, {"cutgrass","cutgrass","cutgrass","log", "log"}}
							return choices[math.random(1,#choices)] 
						end,
					},
			}),

		["LivingTree"] = StaticLayout.Get("map/static_layouts/livingtree", {
							
						}),

		
--------------------------------------------------------------------------------
-- MacTusk 
--------------------------------------------------------------------------------
		["MacTuskTown"] = StaticLayout.Get("map/static_layouts/mactusk_village"),
		["MacTuskCity"] = StaticLayout.Get("map/static_layouts/mactusk_city", {
							start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),

--------------------------------------------------------------------------------
-- Pigs 
--------------------------------------------------------------------------------
		["MaxMermShrine"] = StaticLayout.Get("map/static_layouts/maxwell_merm_shrine"),

		["MaxPigShrine"] = StaticLayout.Get("map/static_layouts/maxwell_pig_shrine"),
		["VillageSquare"] = 
						{
							type = LAYOUT.RECTANGLE_EDGE,
							count = 
								{
									pighouse = 8,
								},
							scale = 0.5
						},
		["PigTown"] = StaticLayout.Get("map/static_layouts/pigtown"),
		["InsanePighouse"] = StaticLayout.Get("map/static_layouts/insane_pig"),
		["DefaultPigking"] = StaticLayout.Get("map/static_layouts/default_pigking", {
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER
        }),
		["TorchPigking"] = StaticLayout.Get("map/static_layouts/torch_pigking"),
		["FisherPig"] = 
						{
							type = LAYOUT.STATIC,
							defs = 
								{
								 	unknown_hanging = { "drumstick", "smallmeat", "monstermeat", "meat"},
								 	unknown_fruit = { "pumpkin", "eggplant", "durian", "pomegranate", "dragonfruit"},
								},
							ground_types = {GROUND.IMPASSABLE, GROUND.WOODFLOOR},
							ground =
								{
									{0, 0, 1, 1, 1, 1, 1, 0},
									{0, 1, 1, 1, 1, 1, 1, 1},
									{0, 1, 1, 1, 1, 1, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 1, 2, 1, 1, 1},
									{0, 0, 1, 1, 2, 1, 1, 0},
								},
							layout = 
								{
									unknown_fruit = 	{ {x=-0.3, y=   0} },
									pighouse = 			{ {x=   0, y=   0} },
									unknown_hanging =  	{ {x= 0.8, y=-0.5} },
									firepit =  			{ {x=   1, y=   1} },
									wall_wood = {
													 {x=-1.5,y=1.5},{x=-1.25,y=1.5}, {x=-1,y=1.5}, {x=-0.75,y=1.5},       {x=0.75,y=1.5}, {x=1,y=1.5}, {x=1.25,y=1.5}, {x=1.5,y=1.5},
																		 		  {x=-0.5,y=1.75}, {x=0.5,y=1.75},
																		 		  {x=-0.5,y=   2}, {x=0.5,y=   2}, 
																		 		  {x=-0.5,y=2.25}, {x=0.5,y=2.25},
																		 		  {x=-0.5,y= 2.5}, {x=0.5,y= 2.5}, 
																		 		  {x=-0.5,y=2.75}, {x=0.5,y=2.75}, 
																		 		  {x=-0.5,y=   3}, {x=0.5,y=   3}, 
																		 		  {x=-0.5,y=3.25}, {x=0.5,y=3.25}, 
																		 		  {x=-0.5,y= 3.5}, {x=0.5,y= 3.5}, 
												},
								},
							scale = 1 -- scale must be 1 if we set grount tiles
						},
		["SwampPig"] = 
						{
							type = LAYOUT.STATIC,
							defs = 
								{
								 	unknown_bird = { "crow", "robin"},
								 	unknown_fruit = { "pumpkin", "eggplant", "durian", "pomegranate", "dragonfruit"},
								 	unknown_bird = { "carrot_planted","flower", "grass"},
								},
							layout = 
								{
									unknown_plant = {
													 {x=-1,y=-1}, {x=0,y=-1}, {x=1,y=-1},
													 {x=-1,y= 0}, {x=0,y= 0}, {x=1,y= 0},
													 {x=-1,y= 1}, {x=0,y= 1}, {x=1,y= 1}
													},
								},
							scale = 0.3
						},
						
--------------------------------------------------------------------------------
-- Start Nodes 
--------------------------------------------------------------------------------
		["DefaultStart"] = StaticLayout.Get("map/static_layouts/default_start", {
            start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
            fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
            layout_position = LAYOUT_POSITION.CENTER,
            
			defs={
				welcomitem = IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) and {"pumpkin_lantern"} or {"flower"},
			},

        }),
		["CaveStart"] = StaticLayout.Get("map/static_layouts/cave_start", {
            start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
            fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
            layout_position = LAYOUT_POSITION.CENTER,
        }),
		["RuinsStart"] = StaticLayout.Get("map/static_layouts/ruins_start"),
		["RuinsStart2"] = StaticLayout.Get("map/static_layouts/ruins_start2"),
		["CaveTestStart"] = StaticLayout.Get("map/static_layouts/cave_test_start"),
		["DefaultPlusStart"] = StaticLayout.Get("map/static_layouts/default_plus_start"),
		["NightmareStart"] = StaticLayout.Get("map/static_layouts/nightmare"),
		["BargainStart"] = StaticLayout.Get("map/static_layouts/bargain_start"),
		["ThisMeansWarStart"] = StaticLayout.Get("map/static_layouts/thismeanswar_start"),
		["WinterStartEasy"] = StaticLayout.Get("map/static_layouts/winter_start_easy"),
		["WinterStartMedium"] = StaticLayout.Get("map/static_layouts/winter_start_medium"),
		["WinterStartHard"] = StaticLayout.Get("map/static_layouts/winter_start_hard"),
		["PreSummerStart"] = StaticLayout.Get("map/static_layouts/presummer_start"),
		["DarknessStart"] =StaticLayout.Get("map/static_layouts/total_darkness_start"),
		
--------------------------------------------------------------------------------
-- Chess bits
--------------------------------------------------------------------------------
		
		["ChessSpot1"] = StaticLayout.Get("map/static_layouts/chess_spot", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["ChessSpot2"] = StaticLayout.Get("map/static_layouts/chess_spot2", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["ChessSpot3"] = StaticLayout.Get("map/static_layouts/chess_spot3", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["Maxwell1"] = StaticLayout.Get("map/static_layouts/maxwell_1"),
		["Maxwell2"] = StaticLayout.Get("map/static_layouts/maxwell_2"),
		["Maxwell3"] = StaticLayout.Get("map/static_layouts/maxwell_3"),
		["Maxwell4"] = StaticLayout.Get("map/static_layouts/maxwell_4"),
		["Maxwell5"] = StaticLayout.Get("map/static_layouts/maxwell_5",
		{
			start_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
		}),
		["Maxwell6"] = StaticLayout.Get("map/static_layouts/maxwell_6"),
		["Maxwell7"] = StaticLayout.Get("map/static_layouts/maxwell_7"),

--------------------------------------------------------------------------------
-- Blockers 
--------------------------------------------------------------------------------
		["TreeBlocker"] = 
						{
							type = LAYOUT.CIRCLE_RANDOM,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.FOREST},
							ground =
								{
									{1,1},{1,1},
									--{0, 0, 1, 1, 0, 0},
									--{0, 1, 1, 1, 1, 0},
									--{1, 1, 1, 1, 1, 1},
									--{1, 1, 1, 1, 1, 1},
									--{0, 1, 1, 1, 1, 0},
									--{0, 0, 1, 1, 0, 0},
								},
							defs = 
								{
								 	trees = { "evergreen_short", "evergreen_normal", "evergreen_tall"},
								},
							count = 
								{
									trees = 185,
								},
							scale = 0.9,
						},
		["RockBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "rock1", "rock2"},
								},
							count = 
								{
									rocks = 35,
								},
							scale = 1.9,
						},
		["InsanityBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "insanityrock"},
								},
							count = 
								{
									rocks = 55,
								},
							scale = 4.0,
						},
		["SanityBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "sanityrock"},
								},
							count = 
								{
									rocks = 55,
								},
							scale = 4.0,
						},
		["InsaneFlint"] = StaticLayout.Get("map/static_layouts/insane_flint"),
		["PigGuardsEasy"] = StaticLayout.Get("map/static_layouts/pigguards_easy", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["PigGuards"] = StaticLayout.Get("map/static_layouts/pigguards", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["PigGuardsB"] = StaticLayout.Get("map/static_layouts/pigguards_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["TallbirdBlockerSmall"] = StaticLayout.Get("map/static_layouts/tallbird_blocker_small", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TallbirdBlocker"] = StaticLayout.Get("map/static_layouts/tallbird_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TallbirdBlockerB"] = StaticLayout.Get("map/static_layouts/tallbird_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TentacleBlockerSmall"] = StaticLayout.Get("map/static_layouts/tentacles_blocker_small", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TentacleBlocker"] = StaticLayout.Get("map/static_layouts/tentacles_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerEasy"] = StaticLayout.Get("map/static_layouts/spider_blocker_easy", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerEasyB"] = StaticLayout.Get("map/static_layouts/spider_blocker_easy_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlocker"] = StaticLayout.Get("map/static_layouts/spider_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerB"] = StaticLayout.Get("map/static_layouts/spider_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerC"] = StaticLayout.Get("map/static_layouts/spider_blocker_c", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["ChessBlocker"] = StaticLayout.Get("map/static_layouts/chess_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["ChessBlockerB"] = StaticLayout.Get("map/static_layouts/chess_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							areas={
								flower_area = ExtendedArray({}, "flower_evil", 15),
							},
						}),
		["ChessBlockerC"] = StaticLayout.Get("map/static_layouts/chess_blocker_c", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["MaxwellHome"] = StaticLayout.Get("map/static_layouts/maxwellhome", {
							areas = 
							{								
								barren_area = function(area) return PickSomeWithDups( 0.5 * area
									, {"marsh_tree", "marsh_bush", "rock1", "rock2", "evergreen_burnt", "evergreen_stump"}) end,
								gold_area = function() return PickSomeWithDups(math.random(15,20), {"goldnugget"}) end,
								livinglog_area = function() return PickSomeWithDups(math.random(5, 10), {"livinglog"}) end,
								nightmarefuel_area = function() return PickSomeWithDups(math.random(5, 10), {"nightmarefuel"}) end,
								deadlyfeast_area = function() return PickSomeWithDups(math.random(25,30), {"monstermeat", "green_cap", "red_cap", "spoiled_food", "meat"}) end,
								marblegarden_area = function(area) return PickSomeWithDups(1.5*area, {"marbletree", "flower_evil"}) end,
							},
							start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							disable_transform = true
						}),

		["PermaWinterNight"] = StaticLayout.Get("map/static_layouts/nightmare_begin_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
				
--------------------------------------------------------------------------------
-- Wormhole 
--------------------------------------------------------------------------------
		-- "Generic" wormholes
		["WormholeGrass"] = StaticLayout.Get("map/static_layouts/wormhole_grass"),

		-- "Fancy" wormholes
		["InsaneEnclosedWormhole"] = StaticLayout.Get("map/static_layouts/insane_wormhole"),
		["InsaneWormhole"] = StaticLayout.Get("map/static_layouts/insanity_wormhole_1"),
		["SaneWormhole"] = StaticLayout.Get("map/static_layouts/sanity_wormhole_1"),
		["SaneWormholeOneShot"] = StaticLayout.Get("map/static_layouts/sanity_wormhole_oneshot"),
		["WormholeOneShot"] = StaticLayout.Get("map/static_layouts/wormhole_oneshot", {
			areas= {
				bones_area = {"houndbone"},
			},
		}),
        ["TentaclePillar"] = StaticLayout.Get("map/static_layouts/tentacle_pillar"),
		
--------------------------------------------------------------------------------
-- Eyebone 
--------------------------------------------------------------------------------
		["InsaneEyebone"] = StaticLayout.Get("map/static_layouts/insane_eyebone"),

--------------------------------------------------------------------------------
-- TELEPORTATO 
--------------------------------------------------------------------------------
		["TeleportatoBoxLayout"] = StaticLayout.Get("map/static_layouts/teleportato_box_layout"),
		["TeleportatoRingLayout"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.GRASS},
							ground = {
									{0, 1, 1, 1, 0},
									{1, 1, 1, 1, 1},
									{1, 1, 1, 1, 1},
									{1, 1, 1, 1, 1},
									{0, 1, 1, 1, 0},
								},
							count = {
									flower_evil = 15,
								},
							layout = {
									teleportato_ring = { {x=0,y=0} },
								},

							scale = 1,
						},
		["TeleportatoPotatoLayout"] = StaticLayout.Get("map/static_layouts/teleportato_potato_layout"),
		["TeleportatoCrankLayout"] = StaticLayout.Get("map/static_layouts/teleportato_crank_layout"),
		["TeleportatoBaseLayout"] = StaticLayout.Get("map/static_layouts/teleportato_base_layout"),
		["TeleportatoBaseAdventureLayout"] = StaticLayout.Get("map/static_layouts/teleportato_base_layout_adv"),
		["AdventurePortalLayout"] = StaticLayout.Get("map/static_layouts/adventure_portal_layout"),

--------------------------------------------------------------------------------
-- MAX PUZZLE 
--------------------------------------------------------------------------------
		--["SymmetryTest"] = StaticLayout.Get("map/static_layouts/symmetry_test"),
		--["SymmetryTest2"] = StaticLayout.Get("map/static_layouts/symmetry_test2"),
		["test"] = StaticLayout.Get("map/static_layouts/test", {
			areas = {
				area_1 = {"rocks","log"},
				area_2 = {"grass","berrybush"},
			},
		}),
		["MaxPuzzle1"] = StaticLayout.Get("map/static_layouts/MAX_puzzle1"),
		["MaxPuzzle2"] = StaticLayout.Get("map/static_layouts/MAX_puzzle2"),
		["MaxPuzzle3"] = StaticLayout.Get("map/static_layouts/MAX_puzzle3"),



--------------------------------------------------------------------------------
-- CAVES 
--------------------------------------------------------------------------------

    ["CaveEntrance"] = StaticLayout.Get("map/static_layouts/cave_entrance", {
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.RANDOM,
    }),
    ["CaveExit"] = StaticLayout.Get("map/static_layouts/cave_exit", {
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.RANDOM,
    }),
	["CaveBase"] = StaticLayout.Get("map/static_layouts/cave_base_1"),
	["MushBase"] = StaticLayout.Get("map/static_layouts/cave_base_2"),
	["SinkBase"] = StaticLayout.Get("map/static_layouts/cave_base_3"),
	["RabbitTown"] = StaticLayout.Get("map/static_layouts/rabbittown"),
	["RabbitHermit"] = StaticLayout.Get("map/static_layouts/rabbithermit"),
	["CaveArtTest"] = StaticLayout.Get("map/static_layouts/cave_art_test_start"),
	["Mudlights"] = StaticLayout.Get("map/static_layouts/mudlights"),
    ["RabbitCity"] = StaticLayout.Get("map/static_layouts/rabbitcity", {
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.RANDOM,
    }),
    ["TorchRabbitking"] = StaticLayout.Get("map/static_layouts/torch_rabbit_cave", {
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.RANDOM,
    }),
    ["EvergreenSinkhole"] = StaticLayout.Get("map/static_layouts/evergreensinkhole", {
        areas = {
            lights = {"cavelight", "cavelight"},
            innertrees = function(area) return PickSomeWithDups(area*.5, {"evergreen"}) end,
            outertrees = function(area) return PickSomeWithDups(area*.2, {"evergreen", "sapling"}) end,
        },
    }),
    ["GrassySinkhole"] = StaticLayout.Get("map/static_layouts/grasssinkhole", {
        areas = {
            lights = {"cavelight", "cavelight"},
            grassarea = function(area) return PickSomeWithDups(area*.4, {"grass"}) end,
        },
    }),
    ["PondSinkhole"] = StaticLayout.Get("map/static_layouts/pondsinkhole", {
        areas = {
            lights = {"cavelight", "cavelight"},
            pondarea = { "pond", "grass", "grass", "berrybush", "sapling", "sapling" },
        },
    }),
    ["SlurtleEnclave"] = 
    {
        type = LAYOUT.CIRCLE_EDGE,
        ground_types = {GROUND.CAVE},
        ground =
        {
            {0, 0, 1, 1, 1, 1, 1, 0},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 1, 1, 1, 1, 1, 1, 1},
            {0, 0, 1, 1, 1, 1, 1, 0},
        },
        defs =
        {
            hole = { "slurtlehole" },
        },
        count =
        {
            hole = 5,
        },
        scale = 1.9,
    },
	["ToadstoolArena"] = StaticLayout.Get("map/static_layouts/toadstool_arena", {
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true
    }),

--------------------------------------------------------------------------------
-- RUINS
--------------------------------------------------------------------------------


	["WalledGarden"] = StaticLayout.Get("map/static_layouts/walledgarden",
		{
			areas = 
			{
				plants = function(area) return PickSomeWithDups(0.3 * area, {"cave_fern", "lichen", "flower_cave", "flower_cave_double", "flower_cave_triple"}) end,
			},
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER
		}),
	["MilitaryEntrance"] = StaticLayout.Get("map/static_layouts/military_entrance", {			
			areas = 
			{
				cave_hole_area = function(area) return {"cave_hole"} end,
			},
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	
	--SACRED GROUNDS

	["AltarRoom"] = StaticLayout.Get("map/static_layouts/altar",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	["SacredBarracks"] = StaticLayout.Get("map/static_layouts/barracks",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	["Barracks"] = StaticLayout.Get("map/static_layouts/barracks",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	["Barracks2"] = StaticLayout.Get("map/static_layouts/barracks_two",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	["Spiral"] = StaticLayout.Get("map/static_layouts/spiral",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
            areas={
                relics = function() return PickSomeWithDups(15, {"ruins_plate", "ruins_bowl", "ruins_chair", "ruins_chipbowl", "ruins_vase", "ruins_table", "ruins_rubble_table", "ruins_rubble_chair", "ruins_rubble_vase", "thulecite_pieces", "rocks"}) end
            },
            }),
	["BrokenAltar"] = StaticLayout.Get("map/static_layouts/brokenaltar",{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),

	--

	["CornerWall"] = StaticLayout.Get("map/static_layouts/walls_corner"),
	["StraightWall"] = StaticLayout.Get("map/static_layouts/walls_straight"),

	["CornerWall2"] = StaticLayout.Get("map/static_layouts/walls_corner2"),
	["StraightWall2"] = StaticLayout.Get("map/static_layouts/walls_straight2"),

	["RuinsCamp"] = StaticLayout.Get("map/static_layouts/ruins_camp"),

	["DeciduousPond"] = StaticLayout.Get("map/static_layouts/deciduous_pond", {disable_transform = true}),

	["Chessy_1"] = StaticLayout.Get("map/static_layouts/chessy_1"),
	["Chessy_2"] = StaticLayout.Get("map/static_layouts/chessy_2"),
	["Chessy_3"] = StaticLayout.Get("map/static_layouts/chessy_3"),
	["Chessy_4"] = StaticLayout.Get("map/static_layouts/chessy_4"),
	["Chessy_5"] = StaticLayout.Get("map/static_layouts/chessy_5"),
	["Chessy_6"] = StaticLayout.Get("map/static_layouts/chessy_6"),

	["Warzone_1"] = StaticLayout.Get("map/static_layouts/warzone_1"),
	["Warzone_2"] = StaticLayout.Get("map/static_layouts/warzone_2"),
	["Warzone_3"] = StaticLayout.Get("map/static_layouts/warzone_3"),

--------------------------------------------------------------------------------
-- DST
--------------------------------------------------------------------------------

	["MooseNest"] = StaticLayout.Get("map/static_layouts/moose_nest",
	{
		areas =
		{
			randomtree = function(area) return PickSomeWithDups(1, {"evergreen", "deciduoustree"}) end,
		},
	}),

	["DragonflyArena"] = StaticLayout.Get("map/static_layouts/dragonfly_arena",
	{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
	}),

	["BlueMushyStart"] = StaticLayout.Get("map.static_layouts/blue_mushy_entrance"),
	
	["AntlionSpawningGround"] = 
	{
		type = LAYOUT.STATIC,
		layout = 
		{
			antlion_spawner = {{x=0, y=0}},
		},
		ground_types = {GROUND.DESERT_DIRT, GROUND.DIRT},
		ground =
			{
				{1, 2, 1, 2},
				{1, 1, 1, 2},
				{1, 1, 1, 1},
				{2, 1, 2, 1},
			},
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
	},
	

--------------------------------------------------------------------------------
-- ANR - A New Reign
--------------------------------------------------------------------------------

	["MoonbaseOne"] = StaticLayout.Get("map/static_layouts/moonbaseone",
	{
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
			disable_transform = true
	}),

	["StagehandGarden"] = StaticLayout.Get("map/static_layouts/stagehandgarden",
	{
		start_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
	}),
	
	["Sculptures_1"] = StaticLayout.Get("map/static_layouts/sculptures_1",
	{
		start_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_BARREN_RESERVED,
	}),
	
	["Sculptures_2"] = StaticLayout.Get("map/static_layouts/sculptures_2",
	{
		areas =
		{
			sculpture_random = function(area) return PickSomeWithDups(1, {"statue_marble_muse", "statue_marble_pawn", "sculpture_knight", "sculpture_bishop"}) end,
		},
	}),
	
	["Sculptures_3"] = StaticLayout.Get("map/static_layouts/sculptures_3"),
	["Sculptures_4"] = StaticLayout.Get("map/static_layouts/sculptures_4"),

	["Sculptures_5"] = StaticLayout.Get("map/static_layouts/sculptures_5",
	{
		areas =
		{
			sculpture_random = function(area) return (math.random(2) == 1) and PickSomeWithDups(1, {"statue_marble", "marblepillar", "sculpture_knight", "sculpture_bishop"}) or {nil} end,
		},
	}),

	["Oasis"] = StaticLayout.Get("map/static_layouts/oasis",
	{
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true
	}),

--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------

	["LavaArenaLayout"] = StaticLayout.Get("map/static_layouts/events/lava_arena", 
    {
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true,
    }),



--------------------------------------------------------------------------------
}

return {Layouts = ExampleLayout}
