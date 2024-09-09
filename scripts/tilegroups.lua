local TileGroupManager__index = getmetatable(TileGroupManager).__index

function TileGroupManager__index:IsLandTile(tile)
    if (tile >= LEGACY_WORLD_TILES_LAND_START and tile <= LEGACY_WORLD_TILES_LAND_END) then
        return true
    end

    if (tile >= WORLD_TILES_LAND_START and tile <= WORLD_TILES_LAND_END) then
        return true
    end

    return false
end

function TileGroupManager__index:IsOceanTile(tile)
    if (tile >= LEGACY_WORLD_TILES_OCEAN_START and tile <= LEGACY_WORLD_TILES_OCEAN_END) then
        return true
    end

    if (tile >= WORLD_TILES_OCEAN_START and tile <= WORLD_TILES_OCEAN_END) then
        return true
    end

    return false
end

function TileGroupManager__index:IsImpassableTile(tile)
    if tile == WORLD_TILES.IMPASSABLE then
        return true
    end

    if (tile >= LEGACY_WORLD_TILES_IMPASSABLE_START and tile <= LEGACY_WORLD_TILES_IMPASSABLE_END) then
        return true
    end

    if (tile >= WORLD_TILES_IMPASSABLE_START and tile <= WORLD_TILES_IMPASSABLE_END) then
        return true
    end

    return false
end

function TileGroupManager__index:IsInvalidTile(tile)
    if (self:IsImpassableTile(tile)) then
        return true
    end

    return tile == WORLD_TILES.INVALID
end

function TileGroupManager__index:IsNoiseTile(tile)
    if (tile >= LEGACY_WORLD_TILES_NOISE_START and tile <= LEGACY_WORLD_TILES_NOISE_END) then
        return true
    end

    if (tile >= WORLD_TILES_NOISE_START and tile <= WORLD_TILES_NOISE_END) then
        return true
    end

    return false
end

function TileGroupManager__index:IsTemporaryTile(tile)
    -- A group for tiles that are used with the undertile component,
    -- to help avoid collisions in temporary tiles trying to go onto
    -- the same spot.
    return GROUND_ISTEMPTILE[tile]
end

local is_worldgen = rawget(_G, "WORLDGEN_MAIN") ~= nil
if is_worldgen then return end

--Land Tiles
TileGroups.Legacy_LandTiles = TileGroupManager:AddTileGroup()
TileGroupManager:SetValidTileRange(TileGroups.Legacy_LandTiles, LEGACY_WORLD_TILES_LAND_START, LEGACY_WORLD_TILES_LAND_END)

TileGroups.LandTiles = TileGroupManager:AddTileGroup(TileGroups.Legacy_LandTiles)
TileGroupManager:SetValidTileRange(TileGroups.LandTiles, WORLD_TILES_LAND_START, WORLD_TILES_LAND_END)

--Ocean Tiles
TileGroups.Legacy_OceanTiles = TileGroupManager:AddTileGroup()
TileGroupManager:SetValidTileRange(TileGroups.Legacy_OceanTiles, LEGACY_WORLD_TILES_OCEAN_START, LEGACY_WORLD_TILES_OCEAN_END)

TileGroups.OceanTiles = TileGroupManager:AddTileGroup(TileGroups.Legacy_OceanTiles)
TileGroupManager:SetValidTileRange(TileGroups.OceanTiles, WORLD_TILES_OCEAN_START, WORLD_TILES_OCEAN_END)

--Identical to Ocean Tiles, for mods.
TileGroups.TransparentOceanTiles = TileGroupManager:AddTileGroup(TileGroups.Legacy_OceanTiles)
TileGroupManager:SetValidTileRange(TileGroups.TransparentOceanTiles, WORLD_TILES_OCEAN_START, WORLD_TILES_OCEAN_END)

--Impassable Tiles
TileGroups.Legacy_ImpassableTiles = TileGroupManager:AddTileGroup()
TileGroupManager:SetValidTileRange(TileGroups.Legacy_ImpassableTiles, LEGACY_WORLD_TILES_IMPASSABLE_START, LEGACY_WORLD_TILES_IMPASSABLE_END)

TileGroups.ImpassableTiles = TileGroupManager:AddTileGroup(TileGroups.Legacy_ImpassableTiles)
TileGroupManager:SetValidTileRange(TileGroups.ImpassableTiles, WORLD_TILES_IMPASSABLE_START, WORLD_TILES_IMPASSABLE_END)
TileGroupManager:AddValidTile(TileGroups.ImpassableTiles, WORLD_TILES.IMPASSABLE)

--Invalid Tiles
TileGroups.InvalidTiles = TileGroupManager:AddTileGroup(TileGroups.ImpassableTiles)
TileGroupManager:AddValidTile(TileGroups.InvalidTiles, WORLD_TILES.INVALID)

--Noise Tiles
TileGroups.Legacy_NoiseTiles = TileGroupManager:AddTileGroup()
TileGroupManager:SetValidTileRange(TileGroups.Legacy_NoiseTiles, LEGACY_WORLD_TILES_NOISE_START, LEGACY_WORLD_TILES_NOISE_END)

TileGroups.NoiseTiles = TileGroupManager:AddTileGroup(TileGroups.Legacy_NoiseTiles)
TileGroupManager:SetValidTileRange(TileGroups.NoiseTiles, WORLD_TILES_NOISE_START, WORLD_TILES_NOISE_END)

TileGroupManager:SetInvalidTile(WORLD_TILES.INVALID)
TileGroupManager:SetDefaultImpassableTile(WORLD_TILES.IMPASSABLE)
TileGroupManager:SetFakeGroundTile(WORLD_TILES.FAKE_GROUND)

--Set default tile groups
TileGroupManager:SetIsLandTileGroup(TileGroups.LandTiles)
TileGroupManager:SetIsOceanTileGroup(TileGroups.OceanTiles)
TileGroupManager:SetIsTransparentOceanTileGroup(TileGroups.TransparentOceanTiles) --tiles that get the special see through property.
TileGroupManager:SetIsImpassableTileGroup(TileGroups.ImpassableTiles)
TileGroupManager:SetIsInvalidTileGroup(TileGroups.InvalidTiles)
TileGroupManager:SetIsNoiseTileGroup(TileGroups.NoiseTiles)

--falloff groups
TileGroups.LandTilesNotDock = TileGroupManager:AddTileGroup(TileGroups.LandTiles) -- Deprecated for TileGroups.LandTilesWithDefaultFalloff.
TileGroupManager:AddInvalidTile(TileGroups.LandTilesNotDock, WORLD_TILES.MONKEY_DOCK) -- Deprecated!

TileGroups.LandTilesWithDefaultFalloff = TileGroupManager:AddTileGroup(TileGroups.LandTiles)
TileGroupManager:AddInvalidTile(TileGroups.LandTilesWithDefaultFalloff, WORLD_TILES.MONKEY_DOCK)

TileGroups.DockTiles = TileGroupManager:AddTileGroup()
TileGroupManager:AddValidTile(TileGroups.DockTiles, WORLD_TILES.MONKEY_DOCK)

TileGroups.OceanIceTiles = TileGroupManager:AddTileGroup()
TileGroupManager:AddValidTile(TileGroups.OceanIceTiles, WORLD_TILES.OCEAN_ICE)

TileGroups.LandTilesInvisible = TileGroupManager:AddTileGroup(TileGroups.LandTiles)
