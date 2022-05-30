local shader_filename = "shaders/minimap.ksh"
local fs_shader = "shaders/minimapfs.ksh"
local atlas_filename = "minimap/minimap_atlas.tex"
local atlas_info_filename = "minimap/minimap_data.xml"

local MINIMAP_GROUND_PROPERTIES =
{
    { GROUND.PEBBLEBEACH,{ name = "map_edge",      noise_texture = "levels/textures/mini_pebblebeach.tex" } },
    { GROUND.SHELLBEACH, { name = "map_edge",      noise_texture = "levels/textures/mini_pebblebeach.tex" } },
    { GROUND.OCEAN_COASTAL_SHORE,      { name = "map_edge",      noise_texture = "levels/textures/mini_water_shallow.tex" } },
    { GROUND.OCEAN_BRINEPOOL_SHORE,      { name = "map_edge",      noise_texture = "levels/textures/mini_water_coral.tex" } },

    { GROUND.METEOR,	 { name = "map_edge",      noise_texture = "levels/textures/mini_meteor.tex" } },

    { GROUND.ROAD,       { name = "map_edge",      noise_texture = "levels/textures/mini_cobblestone_noise.tex" } },
    { GROUND.MARSH,      { name = "map_edge",      noise_texture = "levels/textures/mini_marsh_noise.tex" } },
    { GROUND.ROCKY,      { name = "map_edge",      noise_texture = "levels/textures/mini_rocky_noise.tex" } },
    { GROUND.SAVANNA,    { name = "map_edge",      noise_texture = "levels/textures/mini_grass2_noise.tex" } },
    { GROUND.GRASS,      { name = "map_edge",      noise_texture = "levels/textures/mini_grass_noise.tex" } },
    { GROUND.FOREST,     { name = "map_edge",      noise_texture = "levels/textures/mini_forest_noise.tex" } },
    { GROUND.DIRT,       { name = "map_edge",      noise_texture = "levels/textures/mini_dirt_noise.tex" } },
    { GROUND.WOODFLOOR,  { name = "map_edge",      noise_texture = "levels/textures/mini_woodfloor_noise.tex" } },
    { GROUND.CARPET,     { name = "map_edge",      noise_texture = "levels/textures/mini_carpet_noise.tex" } },
    { GROUND.CHECKER,    { name = "map_edge",      noise_texture = "levels/textures/mini_checker_noise.tex" } },
    { GROUND.DECIDUOUS,  { name = "map_edge",      noise_texture = "levels/textures/mini_deciduous_noise.tex"} },
    { GROUND.DESERT_DIRT,{ name = "map_edge",      noise_texture = "levels/textures/mini_desert_dirt_noise.tex"} },
    { GROUND.SCALE,      { name = "map_edge",      noise_texture = "levels/textures/mini_dragonfly_noise.tex"} },

    { GROUND.CAVE,       { name = "map_edge",      noise_texture = "levels/textures/mini_cave_noise.tex" } },
    { GROUND.FUNGUS,     { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_noise.tex" } },
    { GROUND.FUNGUSRED,  { name = "map_edge",      noise_texture = "levels/textures/mini_fungus_red_noise.tex" } },
    { GROUND.FUNGUSGREEN,{ name = "map_edge",      noise_texture = "levels/textures/mini_fungus_green_noise.tex" } },
    { GROUND.SINKHOLE,   { name = "map_edge",      noise_texture = "levels/textures/mini_sinkhole_noise.tex" } },
    { GROUND.UNDERROCK,  { name = "map_edge",      noise_texture = "levels/textures/mini_rock_noise.tex" } },
    { GROUND.MUD,        { name = "map_edge",      noise_texture = "levels/textures/mini_mud_noise.tex" } },
    { GROUND.BRICK,      { name = "map_edge",      noise_texture = "levels/textures/mini_ruinsbrick_noise.tex" } },
    { GROUND.TILES,      { name = "map_edge",      noise_texture = "levels/textures/mini_ruinstile_noise.tex" } },
    { GROUND.TRIM,       { name = "map_edge",      noise_texture = "levels/textures/mini_ruinstrim_noise.tex" } },

    { GROUND.ARCHIVE,    { name = "map_edge",      noise_texture = "levels/textures/Ground_noise_archive_mini.tex" } },
    { GROUND.FUNGUSMOON, { name = "map_edge",      noise_texture = "levels/textures/Ground_noise_moon_fungus_mini.tex" } },


    { GROUND.LAVAARENA_TRIM, { name = "lavaarena_floor_ms",      noise_texture = "levels/textures/lavaarena_trim_mini.tex" } },
    { GROUND.LAVAARENA_FLOOR,{ name = "lavaarena_floor_ms",      noise_texture = "levels/textures/lavaarena_floor_mini.tex" } },

    { GROUND.QUAGMIRE_PARKFIELD,   { name = "map_edge",      noise_texture = "levels/textures/quagmire_parkfield_mini.tex" } },
    { GROUND.QUAGMIRE_PEATFOREST,  { name = "map_edge",      noise_texture = "levels/textures/quagmire_peatforest_mini.tex" } },
    { GROUND.QUAGMIRE_PARKSTONE,   { name = "map_edge",      noise_texture = "levels/textures/quagmire_parkstone_mini.tex" } },
    { GROUND.QUAGMIRE_CITYSTONE,   { name = "map_edge",      noise_texture = "levels/textures/quagmire_citystone_mini.tex" } },
    { GROUND.QUAGMIRE_GATEWAY,     { name = "map_edge",      noise_texture = "levels/textures/quagmire_gateway_mini.tex" } },
    { GROUND.QUAGMIRE_SOIL,        { name = "map_edge",      noise_texture = "levels/textures/quagmire_soil_mini.tex" } },
    { GROUND.FARMING_SOIL,         { name = "map_edge",      noise_texture = "levels/textures/quagmire_soil_mini.tex" } },

    { GROUND.OCEAN_COASTAL,    { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
    { GROUND.OCEAN_BRINEPOOL,  { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
    { GROUND.OCEAN_SWELL,      { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
    { GROUND.OCEAN_ROUGH,      { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
    { GROUND.OCEAN_HAZARDOUS,  { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
    { GROUND.OCEAN_WATERLOG,   { name = "map_edge",      noise_texture = "levels/textures/ocean_noise.tex" } },
}

local assets =
{
    Asset( "ATLAS", atlas_info_filename ),
    Asset( "IMAGE", atlas_filename ),

    Asset( "ATLAS", "images/hud.xml" ),
    Asset( "IMAGE", "images/hud.tex" ),

    Asset(  "ATLAS", "images/hud2.xml" ),
    Asset(  "IMAGE", "images/hud2.tex" ),

    Asset( "SHADER", shader_filename ),
    Asset( "SHADER", fs_shader ),

    Asset( "IMAGE", "images/minimap_paper.tex" ),
}

function GroundImage( name )
    return "levels/tiles/" .. name .. ".tex"
end

function GroundAtlas( name )
    return "levels/tiles/" .. name .. ".xml"
end

local function AddAssets( layers )
    for k, data in pairs( layers ) do
        local tile_type, properties = unpack( data )
        table.insert( assets, Asset( "IMAGE", ""..properties.noise_texture ) )
        table.insert( assets, Asset( "IMAGE", ""..GroundImage( properties.name ) ) )
        table.insert( assets, Asset( "FILE", ""..GroundAtlas( properties.name ) ) )
    end
end

AddAssets( MINIMAP_GROUND_PROPERTIES )

local function fn()
    local inst = CreateEntity()
    inst.entity:AddUITransform()
    inst.entity:AddMiniMap() --c side renderer

    inst:AddTag("minimap")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)

    inst.MiniMap:SetEffects( shader_filename, fs_shader )

    inst.MiniMap:AddAtlas( resolvefilepath(atlas_info_filename) )
    for i,atlases in ipairs(ModManager:GetPostInitData("MinimapAtlases")) do
        for i,path in ipairs(atlases) do
            inst.MiniMap:AddAtlas( resolvefilepath(path) )
        end
    end

    for i, data in pairs( MINIMAP_GROUND_PROPERTIES ) do
        local tile_type, layer_properties = unpack( data )
        inst.MiniMap:AddRenderLayer(
            MapLayerManager:CreateRenderLayer(
                tile_type,
                resolvefilepath(GroundAtlas( layer_properties.name )),
                resolvefilepath(GroundImage( layer_properties.name )),
                resolvefilepath(layer_properties.noise_texture)
            )
        )
    end

    return inst
end

return Prefab( "minimap", fn, assets)
