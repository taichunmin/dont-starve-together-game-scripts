require "constants"

-- Update terrain.lua to keep GROUND definitions in sync

local GROUND_PROPERTIES =
{
    { GROUND.QUAGMIRE_GATEWAY,      { name = "grass3",     noise_texture = "levels/textures/quagmire_gateway_noise.tex",           runsound="dontstarve/movement/run_woods",       walksound="dontstarve/movement/walk_woods",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.QUAGMIRE_CITYSTONE,    { name = "cave",       noise_texture = "levels/textures/quagmire_citystone_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.QUAGMIRE_PARKFIELD,    { name = "deciduous",  noise_texture = "levels/textures/quagmire_parkfield_noise.tex",         runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.QUAGMIRE_PARKSTONE,    { name = "cave",       noise_texture = "levels/textures/quagmire_parkstone_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.QUAGMIRE_PEATFOREST,   { name = "grass2",     noise_texture = "levels/textures/quagmire_peatforest_noise.tex",        runsound="dontstarve/movement/run_marsh",       walksound="dontstarve/movement/walk_marsh",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.QUAGMIRE_SOIL,         { name = "carpet",     noise_texture = "levels/textures/quagmire_soil_noise.tex",              runsound="dontstarve/movement/run_mud",         walksound="dontstarve/movement/walk_mud",       snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },

    { GROUND.ROAD,       { name = "cobblestone",noise_texture = "images/square.tex",                                runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.MARSH,      { name = "marsh",      noise_texture = "levels/textures/Ground_noise_marsh.tex",           runsound="dontstarve/movement/run_marsh",       walksound="dontstarve/movement/walk_marsh",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.ROCKY,      { name = "rocky",      noise_texture = "levels/textures/noise_rocky.tex",                  runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.SAVANNA,    { name = "yellowgrass",noise_texture = "levels/textures/Ground_noise_grass_detail.tex",    runsound="dontstarve/movement/run_tallgrass",   walksound="dontstarve/movement/walk_tallgrass", snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.FOREST,     { name = "forest",     noise_texture = "levels/textures/Ground_noise.tex",                 runsound="dontstarve/movement/run_woods",       walksound="dontstarve/movement/walk_woods",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.GRASS,      { name = "grass",      noise_texture = "levels/textures/Ground_noise.tex",                 runsound="dontstarve/movement/run_grass",       walksound="dontstarve/movement/walk_grass",     snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.DIRT,       { name = "dirt",       noise_texture = "levels/textures/Ground_noise_dirt.tex",            runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.WOODFLOOR,  { name = "blocky",     noise_texture = "levels/textures/noise_woodfloor.tex",              runsound="dontstarve/movement/run_wood",        walksound="dontstarve/movement/walk_wood",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.CHECKER,    { name = "blocky",     noise_texture = "levels/textures/noise_checker.tex",                runsound="dontstarve/movement/run_marble",      walksound="dontstarve/movement/walk_marble",    snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.CARPET,     { name = "carpet",     noise_texture = "levels/textures/noise_carpet.tex",                 runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.DECIDUOUS,  { name = "deciduous",  noise_texture = "levels/textures/Ground_noise_deciduous.tex",       runsound="dontstarve/movement/run_carpet",      walksound="dontstarve/movement/walk_carpet",    snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.DESERT_DIRT,{ name = "desert_dirt",noise_texture = "levels/textures/Ground_noise_dirt.tex",            runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.SCALE,      { name = "cave",       noise_texture = "levels/textures/Ground_noise_dragonfly.tex",       runsound="dontstarve/movement/run_marble",      walksound="dontstarve/movement/run_marble",     snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 250}},

    { GROUND.CAVE,       { name = "cave",       noise_texture = "levels/textures/noise_cave.tex",                   runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.FUNGUS,     { name = "cave",       noise_texture = "levels/textures/noise_fungus.tex",                 runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.FUNGUSRED,  { name = "cave",       noise_texture = "levels/textures/noise_fungus_red.tex",             runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.FUNGUSGREEN,{ name = "cave",       noise_texture = "levels/textures/noise_fungus_green.tex",           runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.SINKHOLE,   { name = "cave",       noise_texture = "levels/textures/noise_sinkhole.tex",               runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.UNDERROCK,  { name = "cave",       noise_texture = "levels/textures/noise_rock.tex",                   runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.MUD,        { name = "cave",       noise_texture = "levels/textures/noise_mud.tex",                    runsound="dontstarve/movement/run_mud",         walksound="dontstarve/movement/walk_mud",       snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.BRICK_GLOW, { name = "cave",       noise_texture = "levels/textures/noise_ruinsbrick.tex",             runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.BRICK,      { name = "cave",       noise_texture = "levels/textures/noise_ruinsbrickglow.tex",         runsound="dontstarve/movement/run_moss",        walksound="dontstarve/movement/walk_moss",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.TILES_GLOW, { name = "cave",       noise_texture = "levels/textures/noise_ruinstile.tex",              runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.TILES,      { name = "cave",       noise_texture = "levels/textures/noise_ruinstileglow.tex",          runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.TRIM_GLOW,  { name = "cave",       noise_texture = "levels/textures/noise_ruinstrim.tex",              runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.TRIM,       { name = "cave",       noise_texture = "levels/textures/noise_ruinstrimglow.tex",          runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_ice",    mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },

    { GROUND.LAVAARENA_TRIM, { name = "lavaarena_trim_ms",       noise_texture = "levels/textures/lavaarena_trim_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },
    { GROUND.LAVAARENA_FLOOR,{ name = "lavaarena_floor_ms",		noise_texture = "levels/textures/lavaarena_floor_noise.tex",         runsound="dontstarve/movement/run_dirt",        walksound="dontstarve/movement/walk_dirt",      snowsound="dontstarve/movement/run_snow",   mudsound = "dontstarve/movement/run_mud", flashpoint_modifier = 0   } },

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

local TURF_PROPERTIES =
{
    [GROUND.ROAD] =         { name = "road",            anim = "road"           },
    [GROUND.ROCKY] =        { name = "rocky",           anim = "rocky"          },
    [GROUND.FOREST] =       { name = "forest",          anim = "forest"         },
    [GROUND.MARSH] =        { name = "marsh",           anim = "marsh"          },
    [GROUND.GRASS] =        { name = "grass",           anim = "grass"          },
    [GROUND.SAVANNA] =      { name = "savanna",         anim = "savanna"        },
    [GROUND.WOODFLOOR] =    { name = "woodfloor",       anim = "woodfloor"      },
    [GROUND.CARPET] =       { name = "carpetfloor",     anim = "carpet"         },
    [GROUND.CHECKER] =      { name = "checkerfloor",    anim = "checker"        },

    [GROUND.CAVE] =         { name = "cave",            anim = "cave"           },
    [GROUND.FUNGUS] =       { name = "fungus",          anim = "fungus"         },
    [GROUND.FUNGUSRED] =    { name = "fungus_red",      anim = "fungus_red"     },
    [GROUND.FUNGUSGREEN] =  { name = "fungus_green",    anim = "fungus_green"   },

    [GROUND.SINKHOLE] =     { name = "sinkhole",        anim = "sinkhole"       },
    [GROUND.UNDERROCK] =    { name = "underrock",       anim = "rock"           },
    [GROUND.MUD] =          { name = "mud",             anim = "mud"            },
    [GROUND.DECIDUOUS] =    { name = "deciduous",       anim = "deciduous"      },
    [GROUND.DESERT_DIRT] =  { name = "desertdirt",      anim = "dirt"           },
    [GROUND.SCALE] =        { name = "dragonfly",       anim = "dragonfly"      },
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
        local tile = inst.components.locomotor ~= nil and inst.components.locomotor:TempGroundTile() or nil
        local tileinfo = tile ~= nil and GetTileInfo(tile) or nil
        if tileinfo ~= nil then
            local size_inst = inst
            if inst:HasTag("player") then
                local rider = inst.components.rider or inst.replica.rider
                if rider ~= nil and rider:IsRiding() then
                    size_inst = rider:GetMount() or inst
                end
            end

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
