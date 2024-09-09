
AddRoom("MoonIsland_IslandShard",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.METEORCOAST_NOISE,
    tags = {"RoadPoison"}, --"ForceDisconnected"
	type = NODE_TYPE.SeparatedRoom,
	contents = {
		countprefabs =
		{
		},
		distributepercent = 0.17,
		distributeprefabs =
		{
			trap_starfish = 1.0,
			bullkelp_beachedroot = 1.5,
			moon_fissure = 0.5,
			driftwood_log = 0.5,
			driftwood_small1 = 0.5,
			driftwood_small2 = 0.5,
			dead_sea_bones = 0.75,
			lunar_island_rocks = 1.0,
			flint = 0.5,
			reeds = 0.75,
			twigs = 0.5,
			moonglass_rock = 0.3,
			moonglass = 0.1,
		},
	},
})

AddRoom("MoonIsland_Beach",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.PEBBLEBEACH,
	contents = {
		countprefabs =
		{
			moonspiderden = 1,
		},
		distributepercent = 0.18,
		distributeprefabs =
		{
			dead_sea_bones = 0.75,
			trap_starfish = 0.75,
			bullkelp_beachedroot = 1.25,
			driftwood_small1 = 0.5,
			driftwood_small2 = 0.5,
			driftwood_tall = 0.25,
			lunar_island_rocks = 0.5,
			flint = 0.5,
			lunar_island_rock1 = 0.5,
			reeds = 0.75,
			twigs = 0.25,
		},
	},
})

AddRoom("MoonIsland_Blank",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.IMPASSABLE,
    tags = {"ForceDisconnected", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
})

AddRoom("MoonIsland_Forest",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.METEOR,
    --tags = {"ForceDisconnected", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	contents = {
		countstaticlayouts =
		{
			["moontrees_2"] = function(area) return 2 + math.max(1, math.floor(area / 75)) end,
            ["MoonTreeHiddenAxe"] = 1,
		},
		countprefabs =
		{
			moonspiderden = function(area) return math.max(1, math.floor(area / 100)) end,
		},
		distributepercent = 0.22,
		distributeprefabs =
		{
			moon_tree = 0.3,
			sapling_moon = 0.3,
			carrat_planted = 0.2,
			moon_tree_blossom_worldgen = 0.2,
			ground_twigs = 0.1,
			rock_avocado_bush = 0.1,
			moonglass_rock = 0.05,
			moon_fissure = 0.2,
		},
	},
})

AddRoom("MoonIsland_Mine",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.METEORMINE_NOISE,
    --tags = {"ForceDisconnected", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	contents = {
		distributepercent = 0.12,
		distributeprefabs =
		{
			moonglass_rock = 1,
			lunar_island_rock1 = 0.4,
			lunar_island_rock2 = 0.2,
			rock_moon = 0.2,
			moonglass = 0.2,
			moonrocknugget = 0.1,
			lunar_island_rocks = 0.1,
			flint = 0.1,
			moon_fissure = 0.5,
		},
	},
})

AddRoom("MoonIsland_Baths",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.METEOR,
	tags = {"RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	random_node_entrance_weight = 0,
	contents = {
		countprefabs =
		{
			hotspring = function(area) return math.max(1, math.floor(area / 50)) end,
			fruitdragon = function(area) return math.max(1, math.floor(area / 25)) end,
		},
		distributepercent = 0.17,
		distributeprefabs =
		{
			sapling_moon = 1.0,
			rock_avocado_bush = 1.0,
			moon_tree = 1.0,
			moonglass_rock = 1.0,
			moon_fissure = 1,
			carrat_planted = .25,
		},
	},
})

AddRoom("MoonIsland_Meadows",  {
    colour={r=0.3,g=0.2,b=0.1,a=0.3},
    value = WORLD_TILES.METEOR,
    --tags = {"ForceDisconnected", "RoadPoison"},
    internal_type = NODE_INTERNAL_CONNECTION_TYPE.EdgeCentroid,
	random_node_exit_weight = 0,
	contents = {
		distributepercent = 0.12,
		distributeprefabs =
		{
			moon_fissure = 1.5,
			moon_tree = 1,
			sapling_moon = 1,
			ground_twigs = 1,
			carrat_planted = 1,
			rock_avocado_bush = 1,
			moon_tree_blossom_worldgen = 0.5,
			moonglass_rock = 0.5,
			twigs = 0.5,
		},
	},
})

-------------------------------------------------------------------------------
AddRoom("Empty_Cove",  {
    colour={r=1.0,g=1.0,b=1.0,a=0.3},
    value = WORLD_TILES.IMPASSABLE,
	type = NODE_TYPE.Blank,
	tags = {"ForceDisconnected", "RoadPoison"},
	random_node_entrance_weight = 0,
	random_node_exit_weight = 0,
	contents = {
	},
})

