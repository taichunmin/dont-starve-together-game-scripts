local TileManager = require("tilemanager")

local COASTAL_SHORE_OCEAN_COLOR =
{
    primary_color =        {220, 240, 255, 60},
    secondary_color =      {21,  96,  110, 140},
    secondary_color_dusk = {0,   0,   0,   50},
    minimap_color =        {23,  51,  62,  102},
}

local COASTAL_OCEAN_COLOR =
{
    primary_color =        {220, 255, 255, 28},
    secondary_color =      {25,  123, 167, 100},
    secondary_color_dusk = {10,  120, 125, 120},
    minimap_color =        {23,  51,  62,  102},
}

local SWELL_OCEAN_COLOR =
{
    primary_color =        {150, 255, 255, 18},
    secondary_color =      {0,   45,  80,  220},
    secondary_color_dusk = {9,   52,  57,  150},
    minimap_color =        {14,  34,  61,  204},
}

local ROUGH_OCEAN_COLOR =
{
    primary_color =        {10, 200, 220, 30},
    secondary_color =      {1,  20,  45,  230},
    secondary_color_dusk = {5,  20,  25,  230},
    minimap_color =        {19, 20,  40,  230},
}

local HAZARDOUS_OCEAN_COLOR =
{
    primary_color =        {255, 255, 255, 25},
    secondary_color =      {0,   8,   18,  51},
    secondary_color_dusk = {0,   0,   0,   150},
    minimap_color =        {8,   8,   14,  51},
}

local BRINEPOOL_OCEAN_COLOR =
{
    primary_color =        {5,  185, 220, 60},
    secondary_color =      {5,  20,  45,  200},
    secondary_color_dusk = {5,  15,  20,  200},
    minimap_color =        {40, 87,  93,  51},
}

local WATERLOG_OCEAN_COLOR =
{
    primary_color =        {220, 255, 255,  28},
    secondary_color =      {25,  123, 167, 100},
    secondary_color_dusk = {10,  120, 125, 120},
    minimap_color =        {40,  87,  93,  51},
}

local BRINEPOOL_SHORE_OCEAN_COLOR =
{
    primary_color =        {255, 255, 255,  25},
    secondary_color =      {255,   0,   0, 255},
    secondary_color_dusk = {255,   0,   0, 255},
    minimap_color =        {255,   0,   0, 255},
}

local WAVETINTS =
{
    shallow =   {0.8,   0.9,    1},
    rough =     {0.65,  0.84,   0.94},
    swell =     {0.65,  0.84,   0.94},
    brinepool = {0.65,  0.92,   0.94},
    hazardous = {0.40,  0.50,   0.62},
    waterlog =  {1,     1,      1},
}

local TileRanges =
{
    LAND = "LAND",
    NOISE = "NOISE",
    OCEAN = "OCEAN",
    IMPASSABLE = "IMPASSABLE",
}

mod_protect_TileManager = false
allow_existing_GROUND_entry = true

TileManager.RegisterTileRange(TileRanges.LAND, WORLD_TILES_LAND_START, WORLD_TILES_LAND_ONLY_END)
TileManager.RegisterTileRange(TileRanges.NOISE, WORLD_TILES_NOISE_START, WORLD_TILES_NOISE_END)
TileManager.RegisterTileRange(TileRanges.OCEAN, WORLD_TILES_OCEAN_START, WORLD_TILES_OCEAN_END)
TileManager.RegisterTileRange(TileRanges.IMPASSABLE, WORLD_TILES_IMPASSABLE_START, WORLD_TILES_IMPASSABLE_END)

--these are done in RENDER order

--impassable tiles
TileManager.AddTile(
    "IMPASSABLE",
    TileRanges.IMPASSABLE,
    {ground_name = "Impassable", old_static_id = GROUND.IMPASSABLE}
)
TileManager.AddTile(
    "FAKE_GROUND",
    TileRanges.IMPASSABLE,
    {ground_name = "Fake Ground", old_static_id = GROUND.FAKE_GROUND}
)

--ocean tiles
TileManager.AddTile(
    "OCEAN_COASTAL_SHORE",
    TileRanges.OCEAN,
    {ground_name = "Coastal Shore", old_static_id = GROUND.OCEAN_COASTAL_SHORE},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        is_shoreline = true,
        ocean_depth = "SHALLOW",
        colors = COASTAL_SHORE_OCEAN_COLOR,
        wavetint = WAVETINTS.shallow,
    },
    {
        name = "map_edge",
        noise_texture = "mini_water_shallow",
    }
)

TileManager.AddTile(
    "OCEAN_BRINEPOOL_SHORE",
    TileRanges.OCEAN,
    {ground_name = "Brinepool Shore", old_static_id = GROUND.OCEAN_BRINEPOOL_SHORE},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        is_shoreline = true,
        ocean_depth = "SHALLOW",
        colors = BRINEPOOL_SHORE_OCEAN_COLOR,
        wavetint = WAVETINTS.brinepool,
    },
    {
        name = "map_edge",
        noise_texture = "mini_water_coral",
    }
)

TileManager.AddTile(
    "OCEAN_COASTAL",
    TileRanges.OCEAN,
    {ground_name = "Coastal Ocean", old_static_id = GROUND.OCEAN_COASTAL},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "SHALLOW",
        colors = COASTAL_OCEAN_COLOR,
        wavetint = WAVETINTS.shallow,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

TileManager.AddTile(
    "OCEAN_WATERLOG",
    TileRanges.OCEAN,
    {ground_name = "Waterlogged Ocean", old_static_id = GROUND.OCEAN_WATERLOG},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "SHALLOW",
        colors = WATERLOG_OCEAN_COLOR,
        wavetint = WAVETINTS.waterlog,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

TileManager.AddTile(
    "OCEAN_BRINEPOOL",
    TileRanges.OCEAN,
    {ground_name = "Brinepool", old_static_id = GROUND.OCEAN_BRINEPOOL},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "SHALLOW",
        colors = BRINEPOOL_OCEAN_COLOR,
        wavetint = WAVETINTS.brinepool,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

TileManager.AddTile(
    "OCEAN_SWELL",
    TileRanges.OCEAN,
    {ground_name = "Swell Ocean", old_static_id = GROUND.OCEAN_SWELL},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "BASIC",
        colors = SWELL_OCEAN_COLOR,
        wavetint = WAVETINTS.swell,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

TileManager.AddTile(
    "OCEAN_ROUGH",
    TileRanges.OCEAN,
    {ground_name = "Rough Ocean", old_static_id = GROUND.OCEAN_ROUGH},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "DEEP",
        colors = ROUGH_OCEAN_COLOR,
        wavetint = WAVETINTS.rough,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

TileManager.AddTile(
    "OCEAN_HAZARDOUS",
    TileRanges.OCEAN,
    {ground_name = "Hazardous Ocean", old_static_id = GROUND.OCEAN_HAZARDOUS},
    {
        name = "cave",
        noise_texture = "ocean_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        ocean_depth = "VERY_DEEP",
        colors = HAZARDOUS_OCEAN_COLOR,
        wavetint = WAVETINTS.hazardous,
    },
    {
        name = "map_edge",
        noise_texture = "ocean_noise",
    }
)

--land tiles
TileManager.AddTile(
    "QUAGMIRE_GATEWAY",
    TileRanges.LAND,
    {ground_name = "Gorge Gateway", old_static_id = GROUND.QUAGMIRE_GATEWAY},
    {
        name = "grass3",
        noise_texture = "quagmire_gateway_noise",
        runsound="dontstarve/movement/run_woods",
        walksound="dontstarve/movement/walk_woods",
        snowsound="dontstarve/movement/run_snow",
        mudsound = "dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_gateway_mini",
    }
)

TileManager.AddTile(
    "QUAGMIRE_CITYSTONE",
    TileRanges.LAND,
    {ground_name = "Gorge Citystone", old_static_id = GROUND.QUAGMIRE_CITYSTONE},
    {
        name = "cave",
        noise_texture = "quagmire_citystone_noise",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_citystone_mini",
    }
)

TileManager.AddTile(
    "QUAGMIRE_PARKFIELD",
    TileRanges.LAND,
    {ground_name = "Gorge Park Grass", old_static_id = GROUND.QUAGMIRE_PARKFIELD},
    {
        name = "deciduous",
        noise_texture = "quagmire_parkfield_noise",
        runsound="dontstarve/movement/run_carpet",
        walksound="dontstarve/movement/walk_carpet",
        snowsound="dontstarve/movement/run_snow",
        mudsound = "dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_parkfield_mini",
    }
)

TileManager.AddTile(
    "QUAGMIRE_PARKSTONE",
    TileRanges.LAND,
    {ground_name = "Gorge Park Path", old_static_id = GROUND.QUAGMIRE_PARKSTONE},
    {
        name = "cave",
        noise_texture = "quagmire_parkstone_noise",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_parkstone_mini",
    }
)

TileManager.AddTile(
    "QUAGMIRE_PEATFOREST",
    TileRanges.LAND,
    {ground_name = "Gorge Peat Forest", old_static_id = GROUND.QUAGMIRE_PEATFOREST},
    {
        name = "grass2",
        noise_texture = "quagmire_peatforest_noise",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_peatforest_mini",
    }
)

TileManager.AddTile(
    "ROAD",
    TileRanges.LAND,
    {ground_name = "Road", old_static_id = GROUND.ROAD},
    {
        name = "cobblestone",
        noise_texture = "images/square.tex",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud",
        hard = true,
		roadways = true,
    },
    {
        name = "map_edge",
        noise_texture = "mini_cobblestone_noise",
    },
    {
        name = "road",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "COTL_BRICK",
    TileRanges.LAND,
    {ground_name = "CotL_Brick"},
    {
        name="blocky",
        noise_texture="ground_noise_cotl_brick",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        hard = true,
		roadways = true,
    },
    {
        name="map_edge",
        noise_texture="ground_noise_cotl_brick_mini"
    },
    {
        name = "cotl_brick", -- Inventory item
        anim = "cotl_brick", -- Ground item
        bank_build = "turf_cotl",
    }
)

TileManager.AddTile(
    "PEBBLEBEACH",
    TileRanges.LAND,
    {ground_name = "Pebble Beach", old_static_id = GROUND.PEBBLEBEACH},
    {
        name = "rocky",
        noise_texture = "noise_pebblebeach",
        runsound="turnoftides/movement/run_pebblebeach",
        walksound="turnoftides/movement/run_pebblebeach",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud"
    },
    {
        name="map_edge",
        noise_texture="mini_pebblebeach",
    },
    {
        name = "pebblebeach",
        bank_build = "turf_moon",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "MONKEY_GROUND",
    TileRanges.LAND,
    {ground_name = "Pirate Beach"},
    {
        name="cave",
        noise_texture="ground_noise_monkeyisland",
        runsound="turnoftides/movement/run_pebblebeach",
        walksound="turnoftides/movement/run_pebblebeach",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_pebblebeach",
    },
    {
        name = "monkey_ground",
        anim = "monkey_ground",
        bank_build = "turf_monkey_ground",
        pickupsound = "grainy",
    }
)

TileManager.AddTile(
    "SHELLBEACH",
    TileRanges.LAND,
    {ground_name = "Shell Beach", old_static_id = GROUND.SHELLBEACH},
    {
        name = "cave",
        noise_texture = "ground_noise_shellbeach",
        runsound="turnoftides/movement/run_pebblebeach",
        walksound="turnoftides/movement/run_pebblebeach",
        snowsound="dontstarve/movement/run_ice",
        mudsound = "dontstarve/movement/run_mud"
    },
    {
        name="map_edge",
        noise_texture="mini_pebblebeach",
    },
    {
        name = "shellbeach",
        bank_build = "turf_shellbeach",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "MARSH",
    TileRanges.LAND,
    {ground_name = "Marsh", old_static_id = GROUND.MARSH},
    {
        name="marsh",
        noise_texture="Ground_noise_marsh",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_marsh_noise",
    },
    {
        name = "marsh",
        pickupsound = "squidgy",
    }
)

TileManager.AddTile(
    "LUNAR_MARSH",
    TileRanges.LAND,
    {ground_name = "Lunar Marsh"},
    {
        name="marsh",
        noise_texture="Ground_noise_marsh",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        cannotbedug = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="mini_marsh_noise",
    }
)

TileManager.AddTile(
    "SHADOW_MARSH",
    TileRanges.LAND,
    {ground_name = "Shadow Marsh"},
    {
        name="marsh",
        noise_texture="Ground_noise_marsh",
        runsound="dontstarve/movement/run_marsh",
        walksound="dontstarve/movement/walk_marsh",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        cannotbedug = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="mini_marsh_noise",
    }
)

TileManager.AddTile(
    "ROCKY",
    TileRanges.LAND,
    {ground_name = "Rocky", old_static_id = GROUND.ROCKY},
    {
        name="rocky",
        noise_texture="noise_rocky",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_rocky_noise",
    },
    {
        name = "rocky",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "SAVANNA",
    TileRanges.LAND,
    {ground_name = "Savanna", old_static_id = GROUND.SAVANNA},
    {
        name="yellowgrass",
        noise_texture="Ground_noise_grass_detail",
        runsound="dontstarve/movement/run_tallgrass",
        walksound="dontstarve/movement/walk_tallgrass",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_grass2_noise",
    },
    {
        name = "savanna",
        pickupsound = "vegetation_grassy",
    }
)

TileManager.AddTile(
    "FOREST",
    TileRanges.LAND,
    {ground_name = "Forest", old_static_id = GROUND.FOREST},
    {
        name="forest",
        noise_texture="Ground_noise",
        runsound="dontstarve/movement/run_woods",
        walksound="dontstarve/movement/walk_woods",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_forest_noise",
    },
    {
        name = "forest",
        pickupsound = "vegetation_grassy",
    }
)

TileManager.AddTile(
    "GRASS",
    TileRanges.LAND,
    {ground_name = "Grass", old_static_id = GROUND.GRASS},
    {
        name="grass",
        noise_texture="Ground_noise",
        runsound="dontstarve/movement/run_grass",
        walksound="dontstarve/movement/walk_grass",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_grass_noise",
    },
    {
        name = "grass",
        pickupsound = "vegetation_grassy",
    }
)

TileManager.AddTile(
    "DIRT",
    TileRanges.LAND,
    {ground_name = "Dirt", old_static_id = GROUND.DIRT},
    {
        name="dirt",
        noise_texture="Ground_noise_dirt",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        cannotbedug = true,
    },
    {
        name="map_edge",
        noise_texture="mini_dirt_noise",
        pickupsound = "grainy",
    }
)

TileManager.AddTile(
    "DECIDUOUS",
    TileRanges.LAND,
    {ground_name = "Deciduous", old_static_id = GROUND.DECIDUOUS},
    {
        name="deciduous",
        noise_texture="Ground_noise_deciduous",
        runsound="dontstarve/movement/run_carpet",
        walksound="dontstarve/movement/walk_carpet",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_deciduous_noise",
    },
    {
        name = "deciduous",
        pickupsound = "cloth",
    }
)

TileManager.AddTile(
    "DESERT_DIRT",
    TileRanges.LAND,
    {ground_name = "Desert Dirt", old_static_id = GROUND.DESERT_DIRT},
    {
        name="desert_dirt",
        noise_texture="Ground_noise_dirt",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_desert_dirt_noise",
    },
    {
        name = "desertdirt", -- Inventory item
        anim = "dirt", -- Ground item
        pickupsound = "grainy",
    }
)

TileManager.AddTile(
    "CAVE",
    TileRanges.LAND,
    {ground_name = "Cave", old_static_id = GROUND.CAVE},
    {
        name="cave",
        noise_texture="noise_cave",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_cave_noise",
    },
    {
        name = "cave",
        pickupsound = "squidgy",
    }
)

TileManager.AddTile(
    "FUNGUS",
    TileRanges.LAND,
    {ground_name = "Blue Fungus", old_static_id = GROUND.FUNGUS},
    {
        name="cave",
        noise_texture="noise_fungus",
        runsound="dontstarve/movement/run_moss",
        walksound="dontstarve/movement/walk_moss",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_fungus_noise",
    },
    {
        name = "fungus",
        pickupsound = "vegetation_firm",
    }
)

TileManager.AddTile(
    "FUNGUSRED",
    TileRanges.LAND,
    {ground_name = "Red Fungus", old_static_id = GROUND.FUNGUSRED},
    {
        name="cave",
        noise_texture="noise_fungus_red",
        runsound="dontstarve/movement/run_moss",
        walksound="dontstarve/movement/walk_moss",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_fungus_red_noise",
    },
    {
        name = "fungus_red",
        pickupsound = "vegetation_firm",
    }
)

TileManager.AddTile(
    "FUNGUSGREEN",
    TileRanges.LAND,
    {ground_name = "Green Fungus", old_static_id = GROUND.FUNGUSGREEN},
    {
        name="cave",
        noise_texture="noise_fungus_green",
        runsound="dontstarve/movement/run_moss",
        walksound="dontstarve/movement/walk_moss",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_fungus_green_noise",
    },
    {
        name = "fungus_green",
        pickupsound = "vegetation_firm",
    }
)

TileManager.AddTile(
    "FUNGUSMOON",
    TileRanges.LAND,
    {ground_name = "Moon Fungus", old_static_id = GROUND.FUNGUSMOON},
    {
        name="cave",
        noise_texture="Ground_noise_moon_fungus",
        runsound="grotto/movement/grotto_footstep",
        walksound="grotto/movement/grotto_footstep",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="Ground_noise_moon_fungus_mini",
    },
    {
        name = "fungus_moon",
        bank_build = "turf_fungus_moon",
        pickupsound = "vegetation_firm",
    }
)

TileManager.AddTile(
    "SINKHOLE",
    TileRanges.LAND,
    {ground_name = "Sinkhole", old_static_id = GROUND.SINKHOLE},
    {
        name="cave",
        noise_texture="noise_sinkhole",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_sinkhole_noise",
    },
    {
        name = "sinkhole",
        pickupsound = "squidgy",
    }
)

TileManager.AddTile(
    "UNDERROCK",
    TileRanges.LAND,
    {ground_name = "Under Rock", old_static_id = GROUND.UNDERROCK},
    {
        name="cave",
        noise_texture="noise_rock",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_rock_noise",
    },
    {
        name = "underrock", -- Inventory item
        anim = "rock", -- Ground item
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "MUD",
    TileRanges.LAND,
    {ground_name = "Mud", old_static_id = GROUND.MUD},
    {
        name="cave",
        noise_texture="noise_mud",
        runsound="dontstarve/movement/run_mud",
        walksound="dontstarve/movement/walk_mud",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_mud_noise",
    },
    {
        name = "mud",
        pickupsound = "squidgy",
    }
)

TileManager.AddTile(
    "ARCHIVE",
    TileRanges.LAND,
    {ground_name = "Archives", old_static_id = GROUND.ARCHIVE},
    {
        name="blocky",
        noise_texture="Ground_noise_archive",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/run_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="Ground_noise_archive_mini",
    },
    {
        name = "archive",
        bank_build = "turf_archives",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "BRICK_GLOW",
    TileRanges.LAND,
    {ground_name = "Pale Bricks", old_static_id = GROUND.BRICK_GLOW},
    {
        name="cave",
        noise_texture="noise_ruinsbrick",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinsbrick_noise",
    },
    {
        name = "ruinsbrick_glow",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "BRICK",
    TileRanges.LAND,
    {ground_name = "Glowing Bricks", old_static_id = GROUND.BRICK},
    {
        name="cave",
        noise_texture="noise_ruinsbrickglow",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinsbrick_noise",
    },
    {
        name = "ruinsbrick",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "TILES_GLOW",
    TileRanges.LAND,
    {ground_name = "Pale Tiles", old_static_id = GROUND.TILES_GLOW},
    {
        name="cave",
        noise_texture="noise_ruinstile",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinstile_noise",
    },
    {
        name = "ruinstiles_glow",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "TILES",
    TileRanges.LAND,
    {ground_name = "Glowing Tiles", old_static_id = GROUND.TILES},
    {
        name="cave",
        noise_texture="noise_ruinstileglow",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinstile_noise",
    },
    {
        name = "ruinstiles",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "TRIM_GLOW",
    TileRanges.LAND,
    {ground_name = "Pale Trim", old_static_id = GROUND.TRIM_GLOW},
    {
        name="cave",
        noise_texture="noise_ruinstrim",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinstile_noise",
    },
    {
        name = "ruinstrim_glow",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "TRIM",
    TileRanges.LAND,
    {ground_name = "Glowing Trim", old_static_id = GROUND.TRIM},
    {
        name="cave",
        noise_texture="noise_ruinstrimglow",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_ruinstrim_noise",
    },
    {
        name = "ruinstrim",
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "METEOR",
    TileRanges.LAND,
    {ground_name = "Meteor", old_static_id = GROUND.METEOR},
    {
        name="meteor",
        noise_texture="noise_meteor",
        runsound="turnoftides/movement/run_meteor",
        walksound="turnoftides/movement/run_meteor",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="mini_meteor",
    },
    {
        name = "meteor",
        bank_build = "turf_moon",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "MONKEY_DOCK",
    TileRanges.LAND,
    {ground_name = "Docks"},
    {
        name="cave",
        noise_texture="ground_noise_dock",
        runsound="monkeyisland/dock/run_dock",
        walksound="monkeyisland/dock/walk_dock",
        snowsound="monkeyisland/dock/walk_dock",
        mudsound="monkeyisland/dock/walk_dock",
        cannotbedug = true,
        flooring = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="mini_marsh_noise",
    }
)

TileManager.AddTile(
    "OCEAN_ICE",
    TileRanges.LAND,
    {ground_name = "Ice Floe"},
    {
        name="ocean_ice",
        noise_texture="noise_oceanice",
		runsound="dontstarve/movement/run_iceslab",
		walksound="dontstarve/movement/walk_iceslab",
		snowsound="dontstarve/movement/run_iceslab", --shouldn't actually be used:
		mudsound="dontstarve/movement/run_iceslab", --nogroundoverlays flag should ignore snow/mud levels
        nogroundoverlays = true,
        cannotbedug = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="mini_oceanice_noise",
    }
)

TileManager.AddTile(
    "CHARLIE_VINE",
    TileRanges.LAND,
    {ground_name = "Charlie Vine"},
    {
        name="grass2",
        noise_texture="ground_noise_vines",
        runsound="dontstarve/movement/run_grass",
        walksound="dontstarve/movement/walk_grass",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        nogroundoverlays = true,
        isinvisibletile = true,
        cannotbedug = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="mini_grass2_noise",
    }
)

TileManager.AddTile(
    "SCALE",
    TileRanges.LAND,
    {ground_name = "Scale", old_static_id = GROUND.SCALE},
    {
        name="cave",
        noise_texture="Ground_noise_dragonfly",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/run_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flashpoint_modifier = 250,
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_dragonfly_noise",
    },
    {
        name = "dragonfly",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "WOODFLOOR",
    TileRanges.LAND,
    {ground_name = "Wood", old_static_id = GROUND.WOODFLOOR},
    {
        name="blocky",
        noise_texture="noise_woodfloor",
        runsound="dontstarve/movement/run_wood",
        walksound="dontstarve/movement/walk_wood",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_woodfloor_noise",
    },
    {
        name = "woodfloor",
        pickupsound="wood",
    }
)



TileManager.AddTile(
    "COTL_GOLD",
    TileRanges.LAND,
    {ground_name = "CotL_Gold"},
    {
        name="blocky",
        noise_texture="ground_noise_cotl_gold",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/walk_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="ground_noise_cotl_gold_mini"
    },
    {
        name = "cotl_gold", -- Inventory item
        anim = "cotl_gold", -- Ground item
        bank_build = "turf_cotl",
    }
)

TileManager.AddTile(
    "CHECKER",
    TileRanges.LAND,
    {ground_name = "Checkers", old_static_id = GROUND.CHECKER},
    {
        name="blocky",
        noise_texture="noise_checker",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/walk_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_checker_noise",
    },
    {
        name = "checkerfloor", -- Inventory item
        anim = "checker", -- Ground item
        pickupsound = "rock",
    }
)


TileManager.AddTile(
    "MOSAIC_GREY",
    TileRanges.LAND,
    {ground_name = "Grey Mosaic", old_static_id = GROUND.MOSAIC_GREY},
    {
        name="blocky",
        noise_texture="noise_mosaictiles_grey",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/walk_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_mosaictiles_grey_noise",
    },
    {
        name = "mosaic_grey", -- Inventory item
        anim = "mosaic_grey", -- Ground item
        bank_build = "turf_drama", 
        pickupsound = "rock",
    }
)
TileManager.AddTile(
    "MOSAIC_RED",
    TileRanges.LAND,
    {ground_name = "Red Mosaic", old_static_id = GROUND.MOSAIC_RED},
    {
        name="blocky",
        noise_texture="noise_mosaictiles_red",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/walk_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_mosaictiles_red_noise",
    },
    {
        name = "mosaic_red", -- Inventory item
        anim = "mosaic_red", -- Ground item
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)
TileManager.AddTile(
    "MOSAIC_BLUE",
    TileRanges.LAND,
    {ground_name = "Blue Mosaic", old_static_id = GROUND.MOSAIC_BLUE},
    {
        name="blocky",
        noise_texture="noise_mosaictiles_blue",
        runsound="dontstarve/movement/run_marble",
        walksound="dontstarve/movement/walk_marble",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_mosaictiles_blue_noise",
    },
    {
        name = "mosaic_blue", -- Inventory item
        anim = "mosaic_blue", -- Ground item
        bank_build = "turf_drama",
        pickupsound = "rock",
    }
)

TileManager.AddTile(
    "CARPET2",
    TileRanges.LAND,
    {ground_name = "Carpet", old_static_id = GROUND.CARPET2},
    {
        name="carpet",
        noise_texture="noise_carpet2",
        runsound="dontstarve/movement/run_carpet",
        walksound="dontstarve/movement/walk_carpet",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_carpet2_noise",
    },
    {
        name = "carpetfloor2", -- Inventory item
        anim = "carpet2", -- Ground item
        bank_build = "turf_drama",
        pickupsound = "cloth",
    }
)

TileManager.AddTile(
    "CARPET",
    TileRanges.LAND,
    {ground_name = "Carpet", old_static_id = GROUND.CARPET},
    {
        name="carpet",
        noise_texture="noise_carpet",
        runsound="dontstarve/movement/run_carpet",
        walksound="dontstarve/movement/walk_carpet",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_carpet_noise",
    },
    {
        name = "carpetfloor", -- Inventory item
        anim = "carpet", -- Ground item
        pickupsound = "cloth",
    }
)

TileManager.AddTile(
    "QUAGMIRE_SOIL",
    TileRanges.LAND,
    {ground_name = "Gorge Soil", old_static_id = GROUND.QUAGMIRE_SOIL},
    {
        name="carpet",
        noise_texture="quagmire_soil_noise",
        runsound="dontstarve/movement/run_mud",
        walksound="dontstarve/movement/walk_mud",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="map_edge",
        noise_texture="quagmire_soil_mini",
    }
)

TileManager.AddTile(
    "BEARD_RUG",
    TileRanges.LAND,
    {ground_name = "Beard Rug", old_static_id = GROUND.BEARDRUG},
    {
        name="carpet",
        noise_texture="Ground_beard_hair",
        runsound="dontstarve/movement/run_carpet",
        walksound="dontstarve/movement/walk_carpet",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        flooring = true,
        hard = true,
    },
    {
        name="map_edge",
        noise_texture="mini_beard_hair",
    },
    {
        name = "beard_rug", -- Inventory item
        anim = "turf_beard", -- Ground item
        bank_build = "turf_beard",
        pickupsound = "cloth",
    }
)

TileManager.AddTile(
    "FARMING_SOIL",
    TileRanges.LAND,
    {ground_name = "Farming Soil", old_static_id = GROUND.FARMING_SOIL},
    {
        name="farmsoil",
        noise_texture="quagmire_soil_noise",
        runsound="dontstarve/movement/run_mud",
        walksound="dontstarve/movement/walk_mud",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="quagmire_soil_mini",
    }
)

TileManager.AddTile(
    "LAVAARENA_TRIM",
    TileRanges.LAND,
    {ground_name = "Forge Trim", old_static_id = GROUND.LAVAARENA_TRIM},
    {
        name="lavaarena_trim_ms",
        noise_texture="lavaarena_trim_noise",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="lavaarena_floor_ms",
        noise_texture="lavaarena_trim_mini",
        --pickupsound = "grainy",
    }
)

TileManager.AddTile(
    "LAVAARENA_FLOOR",
    TileRanges.LAND,
    {ground_name = "Forge Floor", old_static_id = GROUND.LAVAARENA_FLOOR},
    {
        name="lavaarena_floor_ms",
        noise_texture="lavaarena_floor_noise",
        runsound="dontstarve/movement/run_dirt",
        walksound="dontstarve/movement/walk_dirt",
        snowsound="dontstarve/movement/run_snow",
        mudsound="dontstarve/movement/run_mud",
    },
    {
        name="lavaarena_floor_ms",
        noise_texture="lavaarena_floor_mini",
    }
)

TileManager.AddTile(
    "RIFT_MOON",
    TileRanges.LAND,
    {ground_name = "Lunar Rift"},
    {
        name="meteor",
        noise_texture="ground_noise_lunarrift",
        runsound="turnoftides/movement/run_meteor",
        walksound="turnoftides/movement/run_meteor",
        snowsound="dontstarve/movement/run_ice",
        mudsound="dontstarve/movement/run_mud",
        cannotbedug = true,
        hard = true,
        istemptile = true,
    },
    {
        name="map_edge",
        noise_texture="Ground_noise_lunarrift_mini",
    }
)



--noise tiles
TileManager.AddTile(
    "FUNGUSMOON_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.FUNGUSMOON_NOISE}
)
TileManager.AddTile(
    "METEORMINE_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.METEORMINE_NOISE}
)
TileManager.AddTile(
    "METEORCOAST_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.METEORCOAST_NOISE}
)
TileManager.AddTile(
    "DIRT_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.DIRT_NOISE}
)
TileManager.AddTile(
    "ABYSS_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.ABYSS_NOISE}
)
TileManager.AddTile(
    "GROUND_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.GROUND_NOISE}
)
TileManager.AddTile(
    "CAVE_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.CAVE_NOISE}
)
TileManager.AddTile(
    "FUNGUS_NOISE",
    TileRanges.NOISE,
    {old_static_id = GROUND.FUNGUS_NOISE}
)

mod_protect_TileManager = true
allow_existing_GROUND_entry = false