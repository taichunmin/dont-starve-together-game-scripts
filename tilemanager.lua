local GroundTiles = require("worldtiledefs")
local assets = GroundTiles.assets
local minimapassets = GroundTiles.minimapassets

mod_protect_TileManager = false

local TILE_RANGES = {}

local function RegisterTileRange(range_name, range_start, range_end)
    assert(mod_protect_TileManager == false, "Calling RegisterTileRange directly is not allowed")
    range_name = string.upper(range_name)

    assert(range_end - range_start >= 256, "tile range must be atleast 256 tiles")
    assert(TILE_RANGES[range_name] == nil, "tile range "..range_name.." already exists")
    TILE_RANGES[range_name] =
    {
        range_start = range_start,
        --due to how lua for loops work, add 1 for the range end
        range_end = range_end + 1,
    }
end

local function GroundImage(name)
    local trimmed_name = name:gsub("%.tex$", "")..".tex"
    if resolvefilepath_soft(trimmed_name, true) then
        return resolvefilepath(trimmed_name, true)
    end
    return resolvefilepath("levels/tiles/"..trimmed_name, true)
end

local function GroundAtlas(name)
    local trimmed_name = name:gsub("%.tex$", ""):gsub("%.xml$", "")..".xml"
    if resolvefilepath_soft(trimmed_name, true) then
        return resolvefilepath(trimmed_name, true)
    end
    return resolvefilepath("levels/tiles/"..trimmed_name, true)
end

local function GroundNoise(name)
    local trimmed_name = name:gsub("%.tex$", "")..".tex"
    if softresolvefilepath(trimmed_name, true) then
        return resolvefilepath(trimmed_name, true)
    end
    return resolvefilepath("levels/textures/"..trimmed_name, true)
end

local function AddAssets(properties, asset_tbl)
    table.insert(asset_tbl, Asset("IMAGE", properties.noise_texture))
    table.insert(asset_tbl, Asset("IMAGE", properties.texture_name))
    table.insert(asset_tbl, Asset("FILE", properties.atlas))
end

local function SetProperty(tilegroup, tile_id, propertyname, value)
    for i, ground in ipairs(tilegroup) do
        if ground[1] ~= nil and ground[1] == tile_id then
            ground[2][propertyname] = value
            return
        end
    end
end

local function ChangeRenderOrder(tilegroup, tile_id, target_tile_id, moveafter)
    local idx = nil
    for i, ground in ipairs(tilegroup) do
        if ground[1] ~= nil and ground[1] == tile_id then
            idx = i
            break
        end
    end

    local item = table.remove(tilegroup, idx)

    local targetidx = nil
    for i, ground in ipairs(tilegroup) do
        if ground[1] ~= nil and ground[1] == target_tile_id then
            targetidx = i
            break
        end
    end
    targetidx = moveafter and targetidx + 1 or targetidx
    table.insert(tilegroup, targetidx, item)
end

local DEFAULT_COLOUR = -- Color for blending to the land ground tiles
{
    primary_color =         {0,  0,  0,  25},
    secondary_color =       {0,  20, 33, 0},
    secondary_color_dusk =  {0,  20, 33, 80},
    minimap_color =         {23, 51, 62, 102},
}

local function ValidateGroundTileDef(ground_tile_def)
    assert(ground_tile_def.name, "ground_tile_def must contain a name")
    assert(ground_tile_def.noise_texture, "ground_tile_def must contain a noise_texture")

    ground_tile_def.texture_name = GroundImage(ground_tile_def.name)
    ground_tile_def.atlas = GroundAtlas(ground_tile_def.atlas or ground_tile_def.name)
    ground_tile_def.noise_texture = GroundNoise(ground_tile_def.noise_texture)

    ground_tile_def.runsound = ground_tile_def.runsound or "dontstarve/movement/run_dirt"
    ground_tile_def.walksound = ground_tile_def.walksound or "dontstarve/movement/walk_dirt"
    ground_tile_def.snowsound = ground_tile_def.snowsound or "dontstarve/movement/run_snow"
    ground_tile_def.mudsound = ground_tile_def.mudsound or "dontstarve/movement/run_mud"
    ground_tile_def.flashpoint_modifier = ground_tile_def.flashpoint_modifier or 0
    ground_tile_def.colors = ground_tile_def.colors or DEFAULT_COLOUR
end

local function ValidateMinimapTileDef(minimap_tile_def)
    assert(minimap_tile_def.name, "minimap_tile_def must contain a name")
    assert(minimap_tile_def.noise_texture, "minimap_tile_def must contain a noise_texture")

    minimap_tile_def.texture_name = GroundImage(minimap_tile_def.name)
    minimap_tile_def.atlas = GroundAtlas(minimap_tile_def.atlas or minimap_tile_def.name)
    minimap_tile_def.noise_texture = GroundNoise(minimap_tile_def.noise_texture)
end

local function ValidateTurfDef(turf_def)
    assert(turf_def.name, "turf_def must contain a name")

    turf_def.anim = turf_def.anim or turf_def.name
    turf_def.bank_build = turf_def.bank_build or "turf"
    -- NOTES(JBK): Do not validate the following parameters these are for mods and they allow finer control over turf generation in turfs.lua.
    -- bank_override, build_override, animzip_override, inv_override
end

allow_existing_GROUND_entry = false

local function GetTileID(tile_name, range, old_static_id)
    if GROUND[tile_name] then
        assert(allow_existing_GROUND_entry == true, "Only vanilla tiles can have an existing entry in GROUND")
        assert(old_static_id, "GROUND."..tile_name.." exists, but old_static_id is nil")
        assert(old_static_id >= 0 and old_static_id <= 255, "old_static_id: "..old_static_id.." is outside the old static id range of 0-255")
        assert(GROUND[tile_name] == old_static_id, "old_static_id: "..old_static_id.." doesn't match the ID in GROUND."..tile_name..": "..GROUND[tile_name])
        return GROUND[tile_name]
    end

    assert(WORLD_TILES[tile_name] == nil, "Tile "..tile_name.." is already defined")

    for i = range.range_start, range.range_end do
        if INVERTED_WORLD_TILES[i] == nil then
            return i
        end
    end
    error("TILE RANGE is full")
end

local function AddTile(tile_name, tile_range, tile_data, ground_tile_def, minimap_tile_def, turf_def)
    assert(mod_protect_TileManager == false, "Calling AddTile directly is not allowed")
    tile_name = string.upper(tile_name)
    tile_range = string.upper(tile_range)
    tile_data = tile_data or {}

    assert(TILE_RANGES[tile_range], "invalid tile_range: "..tile_range)

    local tile_id = GetTileID(tile_name, TILE_RANGES[tile_range], tile_data.old_static_id)

    WORLD_TILES[tile_name] = tile_id
    INVERTED_WORLD_TILES[tile_id] = tile_name
    GROUND_NAMES[tile_id] = tile_data.ground_name or tile_name

    if ground_tile_def then
        ValidateGroundTileDef(ground_tile_def)

        ground_tile_def.old_static_id = tile_data.old_static_id

        table.insert(GroundTiles.ground, {tile_id, ground_tile_def})

        if ground_tile_def.flooring then
            GROUND_FLOORING[tile_id] = true
        end
        if ground_tile_def.hard then
            GROUND_HARD[tile_id] = true
        end
        if ground_tile_def.roadways then
            GROUND_ROADWAYS[tile_id] = true
        end
        if ground_tile_def.cannotbedug then
            TERRAFORM_IMMUNE[tile_id] = true
        end
        if ground_tile_def.nogroundoverlays then
            -- NOTES(JBK): This is tied to rendering so it must be immutable after initialization so there are no mutexes needed for speed.
            GROUND_NOGROUNDOVERLAYS[tile_id] = true
        end
        if ground_tile_def.isinvisibletile then
            -- NOTES(JBK): This is tied to rendering so it must be immutable after initialization so there are no mutexes needed for speed.
            GROUND_INVISIBLETILES[tile_id] = true
        end
        if ground_tile_def.istemptile then
            -- NOTES(JBK): This is used to be able to tell if a current tile is temporary and uses the undertile component, to allow for avoiding placement on them.
            GROUND_ISTEMPTILE[tile_id] = true
        end

        AddAssets(ground_tile_def, assets)
    end

    if minimap_tile_def then
        ValidateMinimapTileDef(minimap_tile_def)

        table.insert(GroundTiles.minimap, {tile_id, minimap_tile_def})

        --minimap assets get added from minimap.lua
        AddAssets(minimap_tile_def, minimapassets)
    end

    if turf_def then
        ValidateTurfDef(turf_def)

        GroundTiles.turf[tile_id] = turf_def
    end
end

local function ChangeTileRenderOrder(tile_id, target_tile_id, moveafter)
    assert(mod_protect_TileManager == false, "Calling ChangeTileRenderOrder directly is not allowed")
    ChangeRenderOrder(GroundTiles.ground, tile_id, target_tile_id, moveafter)
end

local function SetTileProperty(tile_id, propertyname, value)
    assert(mod_protect_TileManager == false, "Calling SetTileProperty directly is not allowed")
    SetProperty(GroundTiles.ground, tile_id, propertyname, value)
end

local function ChangeMiniMapTileRenderOrder(tile_id, target_tile_id, moveafter)
    assert(mod_protect_TileManager == false, "Calling ChangeMiniMapTileRenderOrder directly is not allowed")
    ChangeRenderOrder(GroundTiles.minimap, tile_id, target_tile_id, moveafter)
end

local function SetMiniMapTileProperty(tile_id, propertyname, value)
    assert(mod_protect_TileManager == false, "Calling SetMiniMapTileProperty directly is not allowed")
    SetProperty(GroundTiles.minimap, tile_id, propertyname, value)
end

local function ValidateFalloffDef(falloff_def)
    assert(falloff_def.name, "falloff_def must contain a name")
    assert(falloff_def.noise_texture, "falloff_def must contain a noise_texture")

    if not rawget(_G, "lfs") then --don't do these asserts when being called from exportprefabs.lua
        assert(falloff_def.should_have_falloff, "falloff_def must contain should_have_falloff")
        assert(falloff_def.should_have_falloff_result ~= nil, "falloff_def must contain should_have_falloff_result")
        assert(falloff_def.neighbor_needs_falloff, "falloff_def must contain neighbor_needs_falloff")
        assert(falloff_def.neighbor_needs_falloff_result ~= nil, "falloff_def must contain neighbor_needs_falloff_result")
    end

    falloff_def.texture_name = GroundImage(falloff_def.name)
    falloff_def.atlas = GroundAtlas(falloff_def.atlas or falloff_def.name)
    falloff_def.noise_texture = GroundNoise(falloff_def.noise_texture)
end

local function AddFalloffTexture(falloff_id, falloff_def)
    assert(mod_protect_TileManager == false, "Calling AddFalloffTexture directly is not allowed")
    if falloff_def then
        ValidateFalloffDef(falloff_def)

        table.insert(GroundTiles.falloff, {falloff_id, falloff_def})

        AddAssets(falloff_def, assets)
    end
end

local function ChangeFalloffRenderOrder(falloff_id, target_falloff_id, moveafter)
    assert(mod_protect_TileManager == false, "Calling ChangeFalloffRenderOrder directly is not allowed")
    ChangeRenderOrder(GroundTiles.falloff, falloff_id, target_falloff_id, moveafter)
end

local function SetFalloffProperty(falloff_id, propertyname, value)
    assert(mod_protect_TileManager == false, "Calling SetFalloffProperty directly is not allowed")
    SetProperty(GroundTiles.falloff, falloff_id, propertyname, value)
end

local function ValidateGroundCreepDef(groundcreep_def)
    assert(groundcreep_def.name, "groundcreep_def must contain a name")
    assert(groundcreep_def.noise_texture, "groundcreep_def must contain a noise_texture")

    groundcreep_def.texture_name = GroundImage(groundcreep_def.name)
    groundcreep_def.atlas = GroundAtlas(groundcreep_def.atlas or groundcreep_def.name)
    groundcreep_def.noise_texture = GroundNoise(groundcreep_def.noise_texture)
end

local function AddGroundCreep(groundcreep_id, groundcreep_def)
    if groundcreep_def then
        ValidateGroundCreepDef(groundcreep_def)

        table.insert(GroundTiles.creep, {groundcreep_id, groundcreep_def})

        AddAssets(groundcreep_def, assets)
    end
end

local function ChangeGroundCreepRenderOrder(groundcreep_id, target_groundcreep_id, moveafter)
    ChangeRenderOrder(GroundTiles.creep, groundcreep_id, target_groundcreep_id, moveafter)
end

local function SetGroundCreepProperty(groundcreep_id, propertyname, value)
    SetProperty(GroundTiles.creep, groundcreep_id, propertyname, value)
end

return {
    RegisterTileRange = RegisterTileRange,

    AddTile = AddTile,
    SetTileProperty = SetTileProperty,
    ChangeTileRenderOrder = ChangeTileRenderOrder,
    ChangeMiniMapTileRenderOrder = ChangeMiniMapTileRenderOrder,
    SetMiniMapTileProperty = SetMiniMapTileProperty,

    AddFalloffTexture = AddFalloffTexture,
    ChangeFalloffRenderOrder = ChangeFalloffRenderOrder,
    SetFalloffProperty = SetFalloffProperty,

    AddGroundCreep = AddGroundCreep,
    ChangeGroundCreepRenderOrder = ChangeGroundCreepRenderOrder,
    SetGroundCreepProperty = SetGroundCreepProperty,
}