require "constants"

-- Update terrain.lua to keep GROUND definitions in sync

---------------- Ground colors ----------------
-- primary == noise textures
-- secondary == base colour

local GROUND_OCEAN_COLOR = -- Color for blending to the land ground tiles 
{ 
    primary_color =         {  0,   0,   0,  25 },
    secondary_color =       { 0,  20,  33,  0 },
    secondary_color_dusk =  { 0,  20,  33,  80 },
    minimap_color =         {  23,  51,  62, 102 },
}

---------------- Ocean colors ----------------


local COASTAL_SHORE_OCEAN_COLOR = 
{ 
    primary_color =         { 220, 240, 255,  60 },
    secondary_color =       {  21,  96, 110, 140 },
    secondary_color_dusk =  {   0,   0,   0,  50 },
    minimap_color =         {   23, 51,  62, 102 },
}

local COASTAL_OCEAN_COLOR = 
{ 
    primary_color =         { 220, 255, 255,  28 },
    secondary_color =       {  25, 123, 167, 100 },
    secondary_color_dusk =  {  10, 120, 125, 120 },
    minimap_color =         {  23,  51,  62, 102 },
}

local SWELL_OCEAN_COLOR = 
{ 
    primary_color =         {  150, 255, 255,  18 },
    secondary_color =       {  0,  45,  80, 220 },
    secondary_color_dusk =  {  9,  52,  57, 150 },
    minimap_color =         {  14,  34,  61, 204 },
}

local ROUGH_OCEAN_COLOR = 
{ 
    primary_color =         {  10, 200, 220,  30 },
    secondary_color =       {  1,  20,  45, 230 },
    secondary_color_dusk =  {  5,  20,  25, 230 },
    minimap_color =         {  19,  20,  40, 230 },
}

local HAZARDOUS_OCEAN_COLOR = 
{ 
    primary_color =         { 255, 255, 255,  25 },
    secondary_color =       {   0,   8,  18,  51 },
    secondary_color_dusk =  {   0,   0,  0,  150 },
    minimap_color =         {   8,   8,  14,  51 },
}

local BRINEPOOL_OCEAN_COLOR = 
{ 
    primary_color =         {   5, 185, 220,  60 },
    secondary_color =       {   5,  20,  45, 200 },
    secondary_color_dusk =  {   5,  15,  20, 200 },
    minimap_color =         {  40,  87,  93,  51 },
}
--[[
local WATERLOG_OCEAN_COLOR = 
{ 
    primary_color =         { 98,   207, 207,  180 },-- { 108,   149, 149,  60 },
    secondary_color =       { 62,   168, 112,   60 }, -- { 28,    39,  39,  140 },
    secondary_color_dusk =  { 31,    74,  56,   30 },
    minimap_color =         { 52,    86,  86,  102 },
}
]]
local WATERLOG_OCEAN_COLOR = 
{ 
    primary_color =         { 220, 255, 255,  28 },
    secondary_color =       {  25, 123, 167, 100 },
    secondary_color_dusk =  {  10, 120, 125, 120 },
    minimap_color =         {  40,  87,  93,  51 },
}

local BRINEPOOL_SHORE_OCEAN_COLOR = 
{ 
    primary_color =         { 255, 255, 255,  25 },
    secondary_color =       { 255,   0,   0, 255 },
    secondary_color_dusk =  { 255,   0,   0, 255 },
    minimap_color =         { 255,   0,   0, 255 },
}



local WAVETINTS =
{
    shallow =               {0.8,   0.9,    1},
    rough =                 {0.65,  0.84,   0.94},
    swell =                 {0.65,  0.84,   0.94},
    brinepool =             {0.65,  0.92,   0.94},
    hazardous =             {0.40,  0.50,   0.62},
    waterlog =              {1,   1,    1},
}

local GROUND_PROPERTIES =
{
	{ GROUND.OCEAN_COASTAL_SHORE,	{ name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",		      runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, is_shoreline = true, ocean_depth="SHALLOW", colors=COASTAL_SHORE_OCEAN_COLOR, wavetint = WAVETINTS.shallow  } },
	{ GROUND.OCEAN_BRINEPOOL_SHORE, { name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",			  runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, is_shoreline = true, ocean_depth="SHALLOW", colors=BRINEPOOL_SHORE_OCEAN_COLOR, wavetint = WAVETINTS.brinepool } },

	{ GROUND.OCEAN_COASTAL,			{ name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",	          runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="SHALLOW", colors=COASTAL_OCEAN_COLOR, wavetint = WAVETINTS.shallow } },
    { GROUND.OCEAN_WATERLOG,        { name = "cave",        noise_texture = "levels/textures/ocean_noise.tex",            runsound="dontstarve/movement/run_marsh",     walksound="dontstarve/movement/walk_marsh",     snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="SHALLOW", colors=WATERLOG_OCEAN_COLOR, wavetint = WAVETINTS.waterlog  } },
	{ GROUND.OCEAN_BRINEPOOL,		{ name = "cave",	    noise_texture = "levels/textures/ocean_noise.tex",	          runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="SHALLOW", colors=BRINEPOOL_OCEAN_COLOR, wavetint = WAVETINTS.brinepool} },
	{ GROUND.OCEAN_SWELL,			{ name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",	          runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="BASIC", colors=SWELL_OCEAN_COLOR, wavetint = WAVETINTS.swell  } },
	{ GROUND.OCEAN_ROUGH,			{ name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",	          runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="DEEP", colors=ROUGH_OCEAN_COLOR, wavetint = WAVETINTS.rough  } },
	{ GROUND.OCEAN_HAZARDOUS,	    { name = "cave",		noise_texture = "levels/textures/ocean_noise.tex",	          runsound="dontstarve/movement/run_marsh",		walksound="dontstarve/movement/walk_marsh",		snowsound="dontstarve/movement/run_ice", mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, ocean_depth="VERY_DEEP", colors=HAZARDOUS_OCEAN_COLOR, wavetint = WAVETINTS.hazardous  } },

    { GROUND.QUAGMIRE_GATEWAY,      { name = "grass3",     noise_texture = "levels/textures/quagmire_gateway_noise.tex",      runsound="dontstarve/movement/run_woods",       walksound="dontstarve/movement/walk_woods",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },
    { GROUND.QUAGMIRE_CITYSTONE,    { name = "cave",       noise_texture = "levels/textures/quagmire_citystone_noise.tex",    runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },
    { GROUND.QUAGMIRE_PARKFIELD,    { name = "deciduous",  noise_texture = "levels/textures/quagmire_parkfield_noise.tex",    runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },
    { GROUND.QUAGMIRE_PARKSTONE,    { name = "cave",       noise_texture = "levels/textures/quagmire_parkstone_noise.tex",    runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },
    { GROUND.QUAGMIRE_PEATFOREST,   { name = "grass2",     noise_texture = "levels/textures/quagmire_peatforest_noise.tex",   runsound="dontstarve/movement/run_marsh",       walksound="dontstarve/movement/walk_marsh",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },

    { GROUND.ROAD,					{ name = "cobblestone", noise_texture = "images/square.tex",                          runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.PEBBLEBEACH,			{ name = "rocky",		noise_texture = "levels/textures/noise_pebblebeach.tex",      runsound="turnoftides/movement/run_pebblebeach",        walksound="turnoftides/movement/run_pebblebeach",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR } },
    { GROUND.SHELLBEACH,            { name = "cave",       noise_texture = "levels/textures/ground_noise_shellbeach.tex",runsound="turnoftides/movement/run_pebblebeach",        walksound="turnoftides/movement/run_pebblebeach",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },

    { GROUND.MARSH,      { name = "marsh",      noise_texture = "levels/textures/Ground_noise_marsh.tex",           runsound="dontstarve/movement/run_marsh",       walksound="dontstarve/movement/walk_marsh",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.ROCKY,      { name = "rocky",      noise_texture = "levels/textures/noise_rocky.tex",                  runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.SAVANNA,    { name = "yellowgrass",noise_texture = "levels/textures/Ground_noise_grass_detail.tex",    runsound="dontstarve/movement/run_tallgrass",   walksound="dontstarve/movement/walk_tallgrass", snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.FOREST,     { name = "forest",     noise_texture = "levels/textures/Ground_noise.tex",                 runsound="dontstarve/movement/run_woods",       walksound="dontstarve/movement/walk_woods",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.GRASS,      { name = "grass",      noise_texture = "levels/textures/Ground_noise.tex",                 runsound="dontstarve/movement/run_grass",       walksound="dontstarve/movement/walk_grass",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.DIRT,       { name = "dirt",       noise_texture = "levels/textures/Ground_noise_dirt.tex",            runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.DECIDUOUS,  { name = "deciduous",  noise_texture = "levels/textures/Ground_noise_deciduous.tex",       runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.DESERT_DIRT,{ name = "desert_dirt",noise_texture = "levels/textures/Ground_noise_dirt.tex",            runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.CAVE,       { name = "cave",       noise_texture = "levels/textures/noise_cave.tex",                   runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.FUNGUS,     { name = "cave",       noise_texture = "levels/textures/noise_fungus.tex",                 runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.FUNGUSRED,  { name = "cave",       noise_texture = "levels/textures/noise_fungus_red.tex",             runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.FUNGUSGREEN,{ name = "cave",       noise_texture = "levels/textures/noise_fungus_green.tex",           runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.FUNGUSMOON, { name = "cave",       noise_texture = "levels/textures/Ground_noise_moon_fungus.tex",     runsound="grotto/movement/grotto_footstep",     walksound="grotto/movement/grotto_footstep",    snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.SINKHOLE,   { name = "cave",       noise_texture = "levels/textures/noise_sinkhole.tex",               runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.UNDERROCK,  { name = "cave",       noise_texture = "levels/textures/noise_rock.tex",                   runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.MUD,        { name = "cave",       noise_texture = "levels/textures/noise_mud.tex",                    runsound="dontstarve/movement/run_mud",         walksound="dontstarve/movement/walk_mud",       snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.ARCHIVE,    { name = "blocky",       noise_texture = "levels/textures/Ground_noise_archive.tex",         runsound="dontstarve/movement/run_marble",       walksound="dontstarve/movement/run_marble",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.BRICK_GLOW, { name = "cave",       noise_texture = "levels/textures/noise_ruinsbrick.tex",             runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.BRICK,      { name = "cave",       noise_texture = "levels/textures/noise_ruinsbrickglow.tex",         runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.TILES_GLOW, { name = "cave",       noise_texture = "levels/textures/noise_ruinstile.tex",              runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.TILES,      { name = "cave",       noise_texture = "levels/textures/noise_ruinstileglow.tex",          runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.TRIM_GLOW,  { name = "cave",       noise_texture = "levels/textures/noise_ruinstrim.tex",              runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.TRIM,       { name = "cave",       noise_texture = "levels/textures/noise_ruinstrimglow.tex",          runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.METEOR,	 { name = "meteor",		noise_texture = "levels/textures/noise_meteor.tex",					runsound="turnoftides/movement/run_meteor",      walksound="turnoftides/movement/run_meteor",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },

    { GROUND.SCALE,      { name = "cave",       noise_texture = "levels/textures/Ground_noise_dragonfly.tex",       runsound="dontstarve/movement/run_marble",      walksound="dontstarve/movement/run_marble",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 250, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.WOODFLOOR,  { name = "blocky",     noise_texture = "levels/textures/noise_woodfloor.tex",              runsound="dontstarve/movement/run_wood",        walksound="dontstarve/movement/walk_wood",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR     } },
    { GROUND.CHECKER,    { name = "blocky",     noise_texture = "levels/textures/noise_checker.tex",                runsound="dontstarve/movement/run_marble",      walksound="dontstarve/movement/walk_marble",    snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR     } },
    { GROUND.CARPET,     { name = "carpet",     noise_texture = "levels/textures/noise_carpet.tex",                 runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR     } },

    { GROUND.QUAGMIRE_SOIL,         { name = "carpet",     noise_texture = "levels/textures/quagmire_soil_noise.tex",         runsound="dontstarve/movement/run_mud",         walksound="dontstarve/movement/walk_mud",       snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },
    { GROUND.FARMING_SOIL,         { name = "farmsoil",     noise_texture = "levels/textures/quagmire_soil_noise.tex",         runsound="dontstarve/movement/run_mud",         walksound="dontstarve/movement/walk_mud",       snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR  } },


    { GROUND.LAVAARENA_TRIM, { name = "lavaarena_trim_ms",       noise_texture = "levels/textures/lavaarena_trim_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
    { GROUND.LAVAARENA_FLOOR,{ name = "lavaarena_floor_ms",		noise_texture = "levels/textures/lavaarena_floor_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0, colors=GROUND_OCEAN_COLOR   } },
}

local WALL_PROPERTIES =
{
    { GROUND.UNDERGROUND,   { name = "falloff", noise_texture = "images/square.tex" } },
    { GROUND.WALL_MARSH,    { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_marsh_01.tex" } },
    { GROUND.WALL_ROCKY,    { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_rock_01.tex" } },
    { GROUND.WALL_DIRT,     { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_dirt_01.tex" } },

    { GROUND.WALL_CAVE,     { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
    { GROUND.WALL_FUNGUS,   { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
    { GROUND.WALL_SINKHOLE, { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
    { GROUND.WALL_MUD,      { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
    { GROUND.WALL_TOP,      { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },
    { GROUND.WALL_WOOD,     { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },

    { GROUND.WALL_HUNESTONE_GLOW,       { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
    { GROUND.WALL_HUNESTONE,    { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
    { GROUND.WALL_STONEEYE_GLOW, { name = "walls",  noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
    { GROUND.WALL_STONEEYE,     { name = "walls",   noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
}

-- player craftable turf prefab data
local TURF_PROPERTIES =
{
    [GROUND.ROAD] =         { name = "road",            anim = "road"           ,   bank_build = "turf" },
    [GROUND.ROCKY] =        { name = "rocky",           anim = "rocky"          ,   bank_build = "turf" },
    [GROUND.FOREST] =       { name = "forest",          anim = "forest"         ,   bank_build = "turf" },
    [GROUND.MARSH] =        { name = "marsh",           anim = "marsh"          ,   bank_build = "turf" },
    [GROUND.GRASS] =        { name = "grass",           anim = "grass"          ,   bank_build = "turf" },
    [GROUND.SAVANNA] =      { name = "savanna",         anim = "savanna"        ,   bank_build = "turf" },
    [GROUND.WOODFLOOR] =    { name = "woodfloor",       anim = "woodfloor"      ,   bank_build = "turf" },
    [GROUND.CARPET] =       { name = "carpetfloor",     anim = "carpet"         ,   bank_build = "turf" },
    [GROUND.CHECKER] =      { name = "checkerfloor",    anim = "checker"        ,   bank_build = "turf" },
    [GROUND.METEOR] =       { name = "meteor",          anim = "meteor"         ,   bank_build = "turf_moon" },
    [GROUND.PEBBLEBEACH] =  { name = "pebblebeach",     anim = "pebblebeach"    ,   bank_build = "turf_moon" },
    [GROUND.SHELLBEACH] =   { name = "shellbeach",      anim = "shellbeach"     ,   bank_build = "turf_shellbeach" },

    [GROUND.CAVE] =         { name = "cave",            anim = "cave"           ,   bank_build = "turf" },
    [GROUND.FUNGUS] =       { name = "fungus",          anim = "fungus"         ,   bank_build = "turf" },
    [GROUND.FUNGUSRED] =    { name = "fungus_red",      anim = "fungus_red"     ,   bank_build = "turf" },
    [GROUND.FUNGUSGREEN] =  { name = "fungus_green",    anim = "fungus_green"   ,   bank_build = "turf" },
    [GROUND.FUNGUSMOON] =   { name = "fungus_moon",     anim = "fungus_moon"	,   bank_build = "turf_fungus_moon" },

    [GROUND.ARCHIVE] =		{ name = "archive",			anim = "archive"		,   bank_build = "turf_archives" },

    [GROUND.SINKHOLE] =     { name = "sinkhole",        anim = "sinkhole"       ,   bank_build = "turf" },
    [GROUND.UNDERROCK] =    { name = "underrock",       anim = "rock"           ,   bank_build = "turf" },
    [GROUND.MUD] =          { name = "mud",             anim = "mud"            ,   bank_build = "turf" },
    [GROUND.DECIDUOUS] =    { name = "deciduous",       anim = "deciduous"      ,   bank_build = "turf" },
    [GROUND.DESERT_DIRT] =  { name = "desertdirt",      anim = "dirt"           ,   bank_build = "turf" },
    [GROUND.SCALE] =        { name = "dragonfly",       anim = "dragonfly"      ,   bank_build = "turf" },
}

local underground_layers =
{
    { GROUND.UNDERGROUND, { name = "falloff", noise_texture = "images/square.tex" } },
}

local GROUND_CREEP_PROPERTIES =
{
    { 1, { name = "web", noise_texture = "levels/textures/web_noise.tex" } },
}

function GroundImage(name)
    return "levels/tiles/"..name..".tex"
end

function GroundAtlas(name)
    return "levels/tiles/"..name..".xml"
end

local function AddAssets(assets, layers)
    for i, data in ipairs(layers) do
        local tile_type, properties = unpack(data)
        table.insert(assets, Asset("IMAGE", properties.noise_texture))
        table.insert(assets, Asset("IMAGE", GroundImage(properties.name)))
        table.insert(assets, Asset("FILE", GroundAtlas(properties.name)))
    end
end

local assets = {}
AddAssets(assets, WALL_PROPERTIES)
AddAssets(assets, GROUND_PROPERTIES)
AddAssets(assets, underground_layers)
AddAssets(assets, GROUND_CREEP_PROPERTIES)

local GROUND_PROPERTIES_CACHE
local function CacheAllTileInfo()
    assert(GROUND_PROPERTIES_CACHE == nil, "Tile info already initialized")
    GROUND_PROPERTIES_CACHE = {}
    for i, data in ipairs(GROUND_PROPERTIES) do
        local tile_type, tile_info = unpack(data)
        assert(tile_type ~= nil and type(tile_info) == "table" and next(tile_info) ~= nil, "Invalid tile info")
        if GROUND_PROPERTIES_CACHE[tile_type] ~= nil then
            print("Ignored duplicate tile info: "..tostring(tile_type))
        else
            GROUND_PROPERTIES_CACHE[tile_type] = tile_info
        end
    end
end

--Valid only after tile info has been cached
--See gamelogic.lua GroundTiles.Initialize()
function GetTileInfo(tile)
    return GROUND_PROPERTIES_CACHE[tile]
end

--Legacy, slow table lookup instead of using cached info
function LookupTileInfo(tile)
    for i, data in ipairs(GROUND_PROPERTIES) do
        local tile_type, tile_info = unpack(data)
        if tile == tile_type then
            return tile_info
        end
    end
    return nil
end

function PlayFootstep(inst, volume, ispredicted)
    local sound = inst.SoundEmitter
    if sound ~= nil then
        local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
        local map = TheWorld.Map
        local my_platform = inst:GetCurrentPlatform()

        local tile = inst.components.locomotor ~= nil and inst.components.locomotor:TempGroundTile() or nil
        local tileinfo = tile ~= nil and GetTileInfo(tile) or nil

        local size_inst = inst
        if inst:HasTag("player") then
            local rider = inst.components.rider or inst.replica.rider
            if rider ~= nil and rider:IsRiding() then
                size_inst = rider:GetMount() or inst
            end
        end

        if my_platform ~= nil then
            sound:PlaySound(
                (   inst.sg ~= nil and inst.sg:HasStateTag("running") and "dontstarve/movement/run_wood" or "dontstarve/movement/walk_wood"
                )..
                (   (size_inst:HasTag("smallcreature") and "_small") or
                    (size_inst:HasTag("largecreature") and "_large" or "")
                ),
                nil,
                volume or 1,
                ispredicted
                )
        elseif tileinfo ~= nil then
            sound:PlaySound(
                (   inst.sg ~= nil and inst.sg:HasStateTag("running") and tileinfo.runsound or tileinfo.walksound
                )..
                (   (size_inst:HasTag("smallcreature") and "_small") or
                    (size_inst:HasTag("largecreature") and "_large" or "")
                ),
                nil,
                volume or 1,
                ispredicted
            )
        else
            tile, tileinfo = inst:GetCurrentTileType()
            if tile ~= nil and tileinfo ~= nil then
                local x, y, z = inst.Transform:GetWorldPosition()
                local oncreep = TheWorld.GroundCreep:OnCreep(x, y, z)
                local onsnow = TheWorld.state.snowlevel > 0.15
                local onmud = TheWorld.state.wetness > 15

                local size_inst = inst
                if inst:HasTag("player") then
                    --this is only for players for the time being because isonroad is suuuuuuuper slow.
                    if not oncreep and RoadManager ~= nil and RoadManager:IsOnRoad(x, 0, z) then
                        tile = GROUND.ROAD
                        tileinfo = GetTileInfo(GROUND.ROAD)
                    end
                    local rider = inst.components.rider or inst.replica.rider
                    if rider ~= nil and rider:IsRiding() then
                        size_inst = rider:GetMount() or inst
                    end
                end

                sound:PlaySound(
                    (   (oncreep and "dontstarve/movement/run_web") or
                        (onsnow and tileinfo.snowsound) or
                        (onmud and tileinfo.mudsound) or
                        (inst.sg ~= nil and inst.sg:HasStateTag("running") and tileinfo.runsound or tileinfo.walksound)
                    )..
                    (   (size_inst:HasTag("smallcreature") and "_small") or
                        (size_inst:HasTag("largecreature") and "_large" or "")
                    ),
                    nil,
                    volume or 1,
                    ispredicted
                )
            end
        end
    end
end

return
{
    --Internal use
    Initialize = CacheAllTileInfo,

    --Public use
    ground = GROUND_PROPERTIES,
    creep = GROUND_CREEP_PROPERTIES,
    wall = WALL_PROPERTIES,
    turf = TURF_PROPERTIES,
    underground = underground_layers,
    assets = assets,
}
