local function GetTileForFungusMoonNoise(noise)
	if noise < 0.25 then
		return WORLD_TILES.FUNGUS
	elseif noise < 0.35 then
		return WORLD_TILES.FUNGUSMOON
	elseif noise < 0.4 then
		return WORLD_TILES.FUNGUS
	elseif noise < 0.45 then
		return WORLD_TILES.FUNGUSMOON
	elseif noise < 0.55 then
		return WORLD_TILES.FUNGUS
	elseif noise < 0.65 then
		return WORLD_TILES.FUNGUSMOON
	end

	return WORLD_TILES.FUNGUS
end

local function GetTileForDirtNoise(noise)
	if noise < 0.4 then
		return WORLD_TILES.DIRT
	end

	return WORLD_TILES.DESERT_DIRT
end

local function GetTileForAbyssNoise(noise)
	if noise < 0.75 then
		return WORLD_TILES.IMPASSABLE
	elseif noise < 0.85 then
		return WORLD_TILES.CAVE
	end

	return WORLD_TILES.IMPASSABLE
end

local function GetTileForCaveNoise(noise)
	if noise < 0.25 then
		return WORLD_TILES.IMPASSABLE
	elseif noise < 0.4 then
		return WORLD_TILES.CAVE
	elseif noise < 0.7 then
		return WORLD_TILES.UNDERROCK
	end

	return WORLD_TILES.IMPASSABLE
end

local function GetTileForFungusNoise(noise)
	if noise < 0.25 then
		return WORLD_TILES.IMPASSABLE
	elseif noise < 0.35 then
		return WORLD_TILES.MUD
	elseif noise < 0.4 then
		return WORLD_TILES.DIRT
	elseif noise < 0.45 then
		return WORLD_TILES.FUNGUS
	elseif noise < 0.55 then
		return WORLD_TILES.DIRT
	elseif noise < 0.65 then
		return WORLD_TILES.UNDERROCK
	end

	return WORLD_TILES.IMPASSABLE
end

local function GetTileForMeteorCoastNoise(noise)
	if noise < 0.55 then
		return WORLD_TILES.PEBBLEBEACH
	elseif noise < 0.75 then
		return WORLD_TILES.METEOR
	end

	return WORLD_TILES.PEBBLEBEACH
end

local function GetTileForMeteorMineNoise(noise)
	if noise < 0.4 then
		return WORLD_TILES.ROCKY
	elseif noise < 0.6 then
		return WORLD_TILES.METEOR
	elseif noise < 0.8 then
		return WORLD_TILES.ROCKY
	end

	return WORLD_TILES.METEOR
end

local function GetTileForGroundNoise(noise)
	if noise < 0.25 then
		return WORLD_TILES.IMPASSABLE
	elseif noise < 0.26 then
		return WORLD_TILES.ROAD
	elseif noise < 0.35 then
		return WORLD_TILES.ROCKY
	elseif noise < 0.4 then
		return WORLD_TILES.DIRT
	elseif noise < 0.5 then
		return WORLD_TILES.GRASS
	elseif noise < 0.75 then
		return WORLD_TILES.FOREST
	end

	return WORLD_TILES.MARSH
end

return
{
    [WORLD_TILES.FUNGUSMOON_NOISE] = GetTileForFungusMoonNoise,
    [WORLD_TILES.DIRT_NOISE] = GetTileForDirtNoise,
    [WORLD_TILES.ABYSS_NOISE] = GetTileForAbyssNoise,
    [WORLD_TILES.CAVE_NOISE] = GetTileForCaveNoise,
    [WORLD_TILES.FUNGUS_NOISE] = GetTileForFungusNoise,
    [WORLD_TILES.METEORCOAST_NOISE] = GetTileForMeteorCoastNoise,
    [WORLD_TILES.METEORMINE_NOISE] = GetTileForMeteorMineNoise,
    [WORLD_TILES.GROUND_NOISE] = GetTileForGroundNoise,
    default = GetTileForGroundNoise,
}