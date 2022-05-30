require "constants"
require "mathutil"
require "map/terrain"

local obj_layout = require("map/object_layout")

local PrefabSwaps = require("prefabswaps")

local world = nil

function Ocean_SetWorldForOceanGen(w)
	world = w
end

local function is_waterlined(tile)
	-- should this tile have a water outline around it?
	return IsLandTile(tile) --or tile == GROUND.OCEAN_BRINEPOOL
end

local function IsSurroundedByWater(x, y, radius)
	for i = -radius, radius, 1 do
		if not IsOceanTile(world:GetTile(x - radius, y + i)) or not IsOceanTile(world:GetTile(x + radius, y + i)) then
			return false
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if not IsOceanTile(world:GetTile(x + i, y - radius)) or not IsOceanTile(world:GetTile(x + i, y + radius)) then
			return false
		end
	end
	return true
end

local function isWaterOrInvalid(ground)
	return IsOceanTile(ground) or ground == GROUND.INVALID
end

local function IsSurroundedByWaterOrInvalid(x, y, radius)
	for i = -radius, radius, 1 do
		if not isWaterOrInvalid(world:GetTile(x - radius, y + i)) or not isWaterOrInvalid(world:GetTile(x + radius, y + i)) then
			return false
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if not isWaterOrInvalid(world:GetTile(x + i, y - radius)) or not isWaterOrInvalid(world:GetTile(x + i, y + radius)) then
			return false
		end
	end
	return true
end

local function IsCloseToWater(x, y, radius)
	for i = -radius, radius, 1 do
		if IsOceanTile(world:GetTile(x - radius, y + i)) or IsOceanTile(world:GetTile(x + radius, y + i)) then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if IsOceanTile(world:GetTile(x + i, y - radius)) or IsOceanTile(world:GetTile(x + i, y + radius)) then
			return true
		end
	end
	return false
end

local function IsCloseToLand(x, y, radius)
	for i = -radius, radius, 1 do
		if IsLandTile(world:GetTile(x - radius, y + i)) or IsLandTile(world:GetTile(x + radius, y + i)) then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if IsLandTile(world:GetTile(x + i, y - radius)) or IsLandTile(world:GetTile(x + i, y + radius)) then
			return true
		end
	end
	return false
end

local function IsCloseToTileType(x, y, radius, tile)
	for i = -radius, radius, 1 do
		if world:GetTile(x - radius, y + i) == tile or world:GetTile(x + radius, y + i) == tile then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if world:GetTile(x + i, y - radius) == tile or world:GetTile(x + i, y + radius) == tile then
			return true
		end
	end
	return false
end

local function fillGroundType(width, height, x, y, offset, depth, ground)
	if depth <= 0 then
		return
	end

	if not (0 <= x and x < width and 0 <= y and y < height) then
		return
	end

	local t = world:GetTile(x, y)
	if is_waterlined(t) then
		return
	end
	--[[if t ~= GROUND.IMPASSABLE and not (ground == GROUND.OCEAN_COASTAL and t == GROUND.OCEAN_SWELL) then
		return
	end]]

	world:SetTile(x, y, ground)
	depth = depth - 1

	fillGroundType(width, height, x + offset, y, offset, depth, ground)
	fillGroundType(width, height, x - offset, y, offset, depth, ground)
	fillGroundType(width, height, x, y + offset, offset, depth, ground)
	fillGroundType(width, height, x, y - offset, offset, depth, ground)
end

local function placeGroundType(width, height, x, y, offx, offy, depth, ground)
	local i = 0;
	while i < depth and 0 <= x and x < width and 0 < y and y < height do
		local t = world:GetTile(x, y)
		if not is_waterlined(t) then --if t == GROUND.IMPASSABLE then
			world:SetTile(x, y, ground)
			x = x + offx
			y = y + offy
			i = i + 1
		else
			break
		end
	end
	return x, y
end

local function placeFilledGroundType(width, height, x, y, offx, offy, depth, ground, fillOffset, fillDepth)
	local i = 0;
	while i < depth and 0 <= x and x < width and 0 < y and y < height do
		local t = world:GetTile(x, y)
		if not is_waterlined(t) then --if t == ground then
			fillGroundType(width, height, x + fillOffset, y, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x - fillOffset, y, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x, y + fillOffset, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x, y - fillOffset, fillOffset, fillDepth, ground)
			x = x + offx
			y = y + offy
			i = i + 1
		else
			break
		end
	end
	return x, y
end

local function placeWaterline(width, height, x, y, offx, offy, depthShallow, depthMed)
	x, y = placeGroundType(width, height, x, y, offx, offy, depthShallow, GROUND.OCEAN_COASTAL)
	x, y = placeGroundType(width, height, x, y, offx, offy, depthMed, GROUND.OCEAN_SWELL)
end

local function placeWaterlineFilled(width, height, x, y, offx, offy, depthShallow, depthMed, fillOffset, fillDepth)
	placeWaterline(width, height, x, y, offx, offy, depthShallow, depthMed)
	x, y = placeFilledGroundType(width, height, x, y, offx, offy, depthMed, GROUND.OCEAN_SWELL, fillOffset, fillDepth)
	x, y = placeFilledGroundType(width, height, x, y, offx, offy, depthShallow, GROUND.OCEAN_COASTAL, fillOffset, fillDepth)
end

local function squareFill(width, height, x, y, radius, ground)
	for yy = y - radius, y + radius, 1 do
		for xx = x - radius, x + radius, 1 do
			if 0 <= xx and xx < width and 0 <= yy and yy < height then
				local t = world:GetTile(xx, yy)
				if not is_waterlined(t) then
					world:SetTile(xx, yy, ground)
				end
			end
		end
	end
end

local function getEdgeFalloff(x, y, width, height, mindist, maxdist, min, max)
	local distx = math.min(x, width - x)
	local disty = math.min(y, height - y)
	assert(distx >= 0)
	assert(disty >= 0)
	local edgedist = math.min(distx, disty)
	local dist = (edgedist - mindist) / (maxdist - mindist)
	return (max - min) * math.clamp(dist, 0.0, 1.0) + min
end

local function simplexnoise2d(x, y, octaves, persistence)
	local noise = 0
	local amps = 0
	local amp = 1
	local freq = 2
	for i = 0, math.max(octaves-1, 1), 1 do
		noise = noise + amp * perlin(freq * x, freq * y, 0)
		amps = amps + amp
		amp = amp * persistence
		freq = freq * 2
	end
	return noise / amps
end

function Ocean_ConvertImpassibleToWater(width, height, data)
	print("[Ocean] Convert impassible to water...")

	if data == nil then
		data = {}
	end

	local function do_groundfill(fillTile, fillOffset, fillDepth, landRadius)
		print("[Ocean]  Ground fill...")
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = world:GetTile(x, y)
				if is_waterlined(ground) then
					fillGroundType(width, height, x + 1, y, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x - 1, y, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x, y + 1, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x, y - 1, fillOffset, fillDepth, fillTile)
				end
			end
			--print(string.format("  Ground fill %4.2f", (y * width) / (width * height) * 100))
		end
		--print("  Ground fill done.")
	end

	local function do_squarefill(shallowRadius)
		print("[Ocean]  Square fill...")
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = world:GetTile(x, y)
				if is_waterlined(ground) and (IsCloseToTileType(x, y, shallowRadius, GROUND.IMPASSABLE) or IsCloseToWater(x, y, shallowRadius)) then
					squareFill(width, height, x, y, shallowRadius, GROUND.OCEAN_COASTAL)
				end
			end
			--print(string.format("  Square fill %4.2f", (y * width) / (width * height) * 100))
		end
		--print("  Square fill done.")
	end

	local function do_noise()
		print("[Ocean]  Noise...")
		local offx_water, offy_water = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		local offx_coral, offy_coral = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		local offx_grave, offy_grave = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		local noise_octave_water = data.noise_octave_water or 6
		local noise_octave_coral = data.noise_octave_coral or 4
		local noise_octave_grave = data.noise_octave_grave or 4
		local noise_persistence_water = data.noise_persistence_water or 0.5
		local noise_persistence_coral = data.noise_persistence_coral or 0.5
		local noise_persistence_grave = data.noise_persistence_grave or 0.5
		local noise_scale_water = data.noise_scale_water or 3
		local noise_scale_coral = data.noise_scale_coral or 6
		local noise_scale_grave = data.noise_scale_grave or 6
		local init_level_coral = data.init_level_coral or 0.65
		local init_level_grave = data.init_level_grave or 0.65
		local init_level_medium = data.init_level_medium or 0.5
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = world:GetTile(x, y)
				if ground == GROUND.IMPASSABLE then
					local nx, ny = x/width - 0.5, y/height - 0.5
					--if simplexnoise2d(noise_scale_coral * (nx + offx_coral), noise_scale_coral * (ny + offy_coral), noise_octave_coral, noise_persistence_coral) > init_level_coral then
					--	world:SetTile(x, y, GROUND.OCEAN_BRINEPOOL)
					--else
						if simplexnoise2d(noise_scale_water * (nx + offx_water), noise_scale_water * (ny + offy_water), noise_octave_water, noise_persistence_water) > init_level_medium then
							world:SetTile(x, y, GROUND.OCEAN_SWELL)
						else
							if simplexnoise2d(noise_scale_grave * (nx + offx_grave), noise_scale_grave * (ny + offy_grave), noise_octave_grave, noise_persistence_grave) > init_level_grave then
								world:SetTile(x, y, GROUND.OCEAN_HAZARDOUS)
							else
								world:SetTile(x, y, GROUND.OCEAN_ROUGH)
							end
						end
					--end
				end
			end
		end
	end

	local function do_blend()
		print("[Ocean]  Blend...")
		local kernelSize = data.kernelSize or 15 --don't recommend increasing this
		local sigma = data.sigma or 2.0 --used for blending

		local cmlevels =
		{
			{GROUND.OCEAN_BRINEPOOL, 1.0}
		}
		local cm, cmw, cmh = world:GenerateBlendedMap(kernelSize, sigma, cmlevels, 0.0)
		--print(width, height, cmw, cmh)
		--assert(width == cmw)
		--assert(height == cmh)

		local glevels =
		{
			{GROUND.OCEAN_HAZARDOUS, 1.0}
		}
		local g, gw, gh = world:GenerateBlendedMap(kernelSize, sigma, glevels, 0.0)

		local el, elw, elh = world:GenerateBlendedMap(kernelSize, sigma, data.ellevels, 1.0)
		--print(width, height, elw, elh)
		--assert(width == elw)
		--assert(height == elh)

		local final_level_shallow = data.final_level_shallow or 0.7
		local final_level_medium = data.final_level_medium or 0.004
		local final_level_coral = data.final_level_coral or 0.2
		local final_level_mangrove = data.final_level_mangrove or 0.2
		local final_level_grave = data.final_level_grave or 0.3
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local tile = world:GetTile(x, y)
				if IsOceanTile(tile) or tile == GROUND.IMPASSABLE then
					local falloff = getEdgeFalloff(x, y, width, height, OCEAN_MAPWRAPPER_WARN_RANGE + 1, OCEAN_MAPWRAPPER_WARN_RANGE + 5, 0.0, 1.0)
					local ellevel = el[y * width + x]
					local cmlevel = cm[y * width + x] * falloff
					local glevel = g[y * width + x] * falloff
					if ellevel > final_level_shallow then
						if tile == GROUND.OCEAN_WATERLOG then
							world:SetTile(x, y, GROUND.OCEAN_WATERLOG)
						elseif cmlevel > final_level_coral and tile == GROUND.OCEAN_BRINEPOOL then
							world:SetTile(x, y, GROUND.OCEAN_BRINEPOOL)
						else
							world:SetTile(x, y, GROUND.OCEAN_COASTAL)
						end
					elseif ellevel > final_level_medium then
						world:SetTile(x, y, GROUND.OCEAN_SWELL)
					else
						if glevel > final_level_grave then
							world:SetTile(x, y, GROUND.OCEAN_HAZARDOUS)
						else
							world:SetTile(x, y, GROUND.OCEAN_ROUGH)
						end
					end
				end
			end
		end
	end

	local function do_void_outline()
		print("[Ocean] Void Outline...")

		local function calc_next(s, tunings)
			local r = math.random()
			s[1] = math.max((s[1] < tunings.max and r <= tunings.deeper_chance) and (s[1]+1)
						or r > 1.0 - tunings.shallower_chance and (s[1]-1)
						or s[1],
						1)

			if s[1] == s[3] and s[1] ~= s[2] then -- simple noise filter so we dont get zig-zags
				s[1] = s[2]
			end
			s[3] = s[2]
			s[2] = s[1]

			return s[1]
		end

		local function add_boarder(x, y)
			if world:GetTile(x, y) ~= GROUND.IMPASSABLE then
				world:SetTile(x, y, GROUND.OCEAN_ROUGH)
			end

		end

		local offset = OCEAN_WATERFALL_MAX_DIST
		local init_d = OCEAN_WATERFALL_MAX_DIST
		local state = {init_d, init_d, init_d}

		local tunings = {
			middle = {max = math.floor(OCEAN_WATERFALL_MAX_DIST * .7), deeper_chance = 0.25, shallower_chance = 0.25},
			corner = {max = init_d, deeper_chance = 0.75, shallower_chance = 0.1},
		}

		for i = 0, height, 1 do
			local d = calc_next(state, (i <= offset or i >= height - offset - offset) and tunings.corner or tunings.middle)
			for ii = 0, d do
				world:SetTile(ii, i, GROUND.IMPASSABLE)
			end
			add_boarder(d + 1, i)
			add_boarder(d + 2, i)
		end
		state = {init_d, init_d, init_d}
		for i = 0, height, 1 do
			local d = calc_next(state, (i <= offset or i >= height - offset - offset) and tunings.corner or tunings.middle)
			for ii = 0, d do
				world:SetTile(width - ii, i, GROUND.IMPASSABLE)
			end
			add_boarder(width - d - 1, i)
			add_boarder(width - d - 2, i)
		end

		state = {init_d, init_d, init_d}
		for i = 0, width, 1 do
			local d = calc_next(state, (i <= offset or i >= width - offset - offset) and tunings.corner or tunings.middle)
			for ii = 0, d do
				world:SetTile(i, ii, GROUND.IMPASSABLE)
			end
			add_boarder(i, d + 1)
			add_boarder(i, d + 2)
		end
		state = {init_d, init_d, init_d}
		for i = 0, width, 1 do
			local d = calc_next(state, (i <= offset or i >= width - offset - offset) and tunings.corner or tunings.middle)
			for ii = 0, d do
				world:SetTile(i, height - ii, GROUND.IMPASSABLE)
			end
			add_boarder(i, height - d - 1)
			add_boarder(i, height - d - 2)
		end
	end

	local depthShallow = data.depthShallow or 10
	local depthMed = data.depthMed or 20
	local fillDepth = data.fillDepth or 5
	local fillOffset = data.fillOffset or 4

	do_squarefill(data.shallowRadius)
	do_groundfill(GROUND.OCEAN_COASTAL, fillOffset, fillDepth, data.shallowRadius or 5)
	do_noise()
	do_blend()

	AddShoreline(width, height)

	do_void_outline()
end

function AddShoreline(width, height)
	print("[Ocean]  Adding shoreline...")

	for y = 0, height - 1, 1 do
		for x = 0, width - 1, 1 do
			local ground = world:GetTile(x, y)
			if IsOceanTile(ground) and not IsSurroundedByWaterOrInvalid(x, y, 1) then
				if ground == GROUND.OCEAN_BRINEPOOL then
					world:SetTile(x, y, GROUND.OCEAN_BRINEPOOL_SHORE)
				else
					world:SetTile(x, y, GROUND.OCEAN_COASTAL_SHORE)
				end
			end
		end
	end
end

local function checkTile(x, y, populating_tile, ignore_reserverd)
	return (ignore_reserverd or not world:IsTileReserved(x, y)) and world:GetTile(x, y) == populating_tile
end

function GetRandomWaterPoints(populating_tile, width, height, edge_dist, needed)
	local get_points = function(points,  width, height, edge_dist, needed, inc)
		local adj_width, adj_height = width - 2 * edge_dist, height - 2 * edge_dist
		local start_x, start_y = math.random(0, adj_width), math.random(0, adj_height)
		local i, j = 0, 0
		while j < adj_height and #points < needed do
			local y = ((start_y + j) % adj_height) + edge_dist
			while i < adj_width and #points < needed do
				local x = ((start_x + i) % adj_width) + edge_dist
				--local ground = world:GetTile(x, y)
				--if checkFn(ground, x, y) then
				if checkTile(x, y, populating_tile) then
					table.insert(points, {x=x, y=y})
				end
				i = i + inc
			end
			j = j + inc
			i = 0
		end
	end

	local points = {}
	local points_x = {}
	local points_y = {}
	local incs = {263, 137, 67, 31, 17, 9, 5, 3, 1}

	for i = 1, #incs, 1 do
		if #points < needed then
			get_points(points, width, height, edge_dist, needed, incs[i])
			--print(string.format("%d (of %d) points found", #points, needed))
		end
	end

	points = shuffleArray(points)
	for i = 1, #points, 1 do
		table.insert(points_x, points[i].x)
		table.insert(points_y, points[i].y)
	end

	return points_x, points_y
end

local function checkAllTiles(populating_tile, x1, y1, x2, y2)
	for j = y1, y2, 1 do
		for i = x1, x2, 1 do
			if not checkTile(i, j, populating_tile) then
				return false, i, j
			end
		end
	end
	return true, 0, 0
end

local function findLayoutPositions(size, edge_dist, populating_tile, count, min_dist_from_land)
	local positions = {}
	edge_dist = edge_dist or 0
	min_dist_from_land = min_dist_from_land or 0

	local width, height = world:GetWorldSize()
	local adj_width, adj_height = width - 2 * edge_dist - size, height - 2 * edge_dist - size
	local start_x, start_y = math.random(0, adj_width), math.random(0, adj_height)
	local i, j = 0, 0

	while j < adj_height and (count == nil or #positions < count) do
		local y = ((start_y + j) % adj_height) + edge_dist
		while i < adj_width and (count == nil or #positions < count) do
			-- check the corners first
			local x = ((start_x + i) % adj_width) + edge_dist
			local x2, y2 = x + size - 1, y + size - 1
			if checkTile(x2 + min_dist_from_land, y - min_dist_from_land, populating_tile) and checkTile(x2 + min_dist_from_land, y2 + min_dist_from_land, populating_tile) then
				if checkTile(x - min_dist_from_land, y - min_dist_from_land, populating_tile) and checkTile(x - min_dist_from_land, y2 + min_dist_from_land, populating_tile) then
					--print("Found 4 corners", x, y, x2, y2)
					--check all tiles
					local ok, last_x, last_y = checkAllTiles(populating_tile, x - min_dist_from_land, y - min_dist_from_land, x2 + min_dist_from_land, y2 + min_dist_from_land)
					if ok == true then
						--bottom-left
						--print(string.format("Location found (%4.2f, %4.2f)", x, y))
						--local adj = 0.5 * (size - actualsize)
						--return {x + adj, y2 - adj} --{0.5 * (x + x2), 0.5 * (y + y2)}
						--table.insert(positions, {x = x + adj, y = y2 - adj})
						table.insert(positions, {x = x, y = y, x2 = x2, y2 = y2, size = size})
						i = i + size + 1
					else
						--print(string.format("Failed at (%4.2f, %4.2f) skip, (%4.2f, %4.2f)", last_x, last_y, x, y))
						last_x = math.clamp(last_x, x, x2)
						i = i + last_x - x + 1
					end
				else
					i = i + 1
				end
			else
				--print(string.format("Failed on x2, skip (%4.2f, %4.2f)", x, y))
				i = i + size + 1
			end
		end
		j = j + 1
		i = 0
	end

	return positions
end

local function GetLayoutSize(layout, prefabs) -- box diameter
	assert(layout ~= nil)
	assert(prefabs ~= nil)
	local size = 2

	if layout.ground then
		size = math.max(size, #layout.ground)
	else
		local extents = {xmin = 1000000, ymin = 1000000, xmax = -1000000, ymax = -1000000}
		for i = 1, #prefabs, 1 do
			--print(string.format("Prefab %s (%4.2f, %4.2f)", tostring(prefabs[i].prefab), prefabs[i].x, prefabs[i].y))
			if prefabs[i].x < extents.xmin then extents.xmin = prefabs[i].x end
			if prefabs[i].x > extents.xmax then extents.xmax = prefabs[i].x end
			if prefabs[i].y < extents.ymin then extents.ymin = prefabs[i].y end
			if prefabs[i].y > extents.ymax then extents.ymax = prefabs[i].y end
		end

		local e_width, e_height = extents.xmax - extents.xmin, extents.ymax - extents.ymin
		size = math.ceil(layout.scale * math.max(e_width, e_height))
	end

	--print(string.format("Layout %s dims (%4.2f x %4.2f), size %4.2f, scale %4.2f", layout.layout_file, e_width, e_height, size, layout.scale))
	return size
end

local function PlaceOceanLayout(layout, prefabs, populating_tile, ReserveAndPlaceLayoutFn, min_dist_from_land)
	local layoutsize = GetLayoutSize(layout, prefabs)
	local positions = findLayoutPositions(layoutsize, OCEAN_WATERFALL_MAX_DIST + 2, populating_tile, 1, min_dist_from_land)
	if #positions > 0 then
		local pos = math.random(#positions)
		local adj = 0.5 * (positions[pos].size - layoutsize)
		local x, y = positions[pos].x + adj, positions[pos].y + adj --bottom-left
		--print(string.format("PlaceWaterLayout (%f, %f) from %d of %d", x, y, pos, #positions))
		ReserveAndPlaceLayoutFn(layout, prefabs, {x, y}, layoutsize)

		for yy = positions[pos].y, positions[pos].y2, 1 do
			for xx = positions[pos].x, positions[pos].x2, 1 do
				world:ReserveTile(xx, yy)
			end
		end

		return true
	end
	return false
end
               
local function AddSquareTopology(encoded_topology, left, top, size, add_topology) -- less than ideal, but it will have to do
	local index = #encoded_topology.ids + 1
	encoded_topology.ids[index] = add_topology.room_id
	encoded_topology.story_depths[index] = 0

	local node = {}
	node.area = size * size
	node.c = 1 -- colour index
	node.cent = {left + (size / 2), top + (size / 2)}
	node.neighbours = {}
	node.poly = { {left, top},
				  {left + size, top},
				  {left + size, top + size},
				  {left, top + size}
				}
	node.tags  = add_topology.tags
	node.type = add_topology.node_type or NODE_TYPE.Default
	node.x = node.cent[1]
	node.y = node.cent[2]

	node.validedges = {}

	encoded_topology.nodes[index] = node

	for x = left, left + size do
		for y = top, top + size do
			world:SetTileNodeId(x, y, index)
		end
	end
end

function Ocean_PlaceSetPieces(set_pieces, add_entity, obj_layout, populating_tile, min_dist_from_land, encoded_topology, map_width, map_height)
	print("[Ocean] Placing ocean set pieces.")

	local total = 0
	local num_placed = 0

    if set_pieces ~= nil then
	    populating_tile = populating_tile or GROUND.IMPASSABLE

	    local function ReserveAndPlaceLayoutFn(layout, prefabs, position, area_size)
		    obj_layout.ReserveAndPlaceLayout("POSITIONED", layout, prefabs, add_entity, position, world)

			if layout.add_topology ~= nil then
				local topology_delta = 0
				AddSquareTopology(encoded_topology, (position[1]-topology_delta)*TILE_SCALE - (map_width * 0.5 * TILE_SCALE), (position[2]-topology_delta)*TILE_SCALE - (map_height * 0.5 * TILE_SCALE), (area_size + (topology_delta*2))*TILE_SCALE, layout.add_topology)
			end
	    end

		local set_pieces_to_place = {}

	    for name, data in pairs(set_pieces) do
		    local layout = obj_layout.LayoutForDefinition(name)
		    local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)
		    local count = type(data) == "number" and data
						    or type(data) == "table" and data.count
						    or data
		    count = FunctionOrValue(count)
		    for i = 1, count or 1 do
				table.insert(set_pieces_to_place, {layout = layout, prefabs = prefabs})
			end
	    end

		shuffleArray(set_pieces_to_place)
		for _, v in ipairs(set_pieces_to_place) do
			if PlaceOceanLayout(v.layout, v.prefabs, populating_tile, ReserveAndPlaceLayoutFn, v.layout.min_dist_from_land or min_dist_from_land) then
				num_placed = num_placed + 1
			end
			total = total + 1
		end
    end

	print("[Ocean] Placed "..tostring(num_placed).." of "..tostring(total).." ocean set pieces.")
	return total
end

function PopulateWaterPrefabWorldGenCustomizations(populating_tile, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices, prefab_list)
	-- this is populating extra entities based on worldgen customization
--	print("[Ocean] Populate water extras...")

	local amount_to_generate = {}
	local pos_needed = 0

	if world_gen_choices == nil then
		return
	end

	for prefab, amt in pairs(world_gen_choices) do
		if not PrefabSwaps.IsPrefabInactive(prefab) then
			if prefab_list[prefab] then
				amount_to_generate[prefab] = math.floor(prefab_list[prefab]*amt) - prefab_list[prefab]
				pos_needed = pos_needed + amount_to_generate[prefab]
			end
		end
	end

	--print("generate_these, before", pos_needed)
	--dumptable(prefab_list, 1, 2)
	--dumptable(generate_these, 1, 2)

	local points_x, points_y = GetRandomWaterPoints(populating_tile, width, height, edge_dist, pos_needed)

	for idx = 1, math.min(#points_x, pos_needed) do
		local prefab = spawnFn.pickspawnprefab(amount_to_generate, populating_tile)

		if prefab ~= nil then
			local prefab_data = {}
			prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
			PopulateWorld_AddEntity(prefab, points_x[idx], points_y[idx], populating_tile, entitiesOut, width, height, prefab_list, prefab_data)

			amount_to_generate[prefab] = amount_to_generate[prefab] - 1

			-- Remove any complete items from the list
			if amount_to_generate[prefab] <= 0 then
				--print("Generated enough",prefab)
				amount_to_generate[prefab] = nil
			end
		end
	end

	--print("generate_these, after", pos_needed)
	--dumptable(prefab_list, 1, 2)
end

local function PopulateWaterType(populating_tile, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices, min_dist_from_land, encoded_topology)
	--add IsTileReserved check back in

	local prefab_list = {}
	local setpiece_prefab_list = {}
	local generate_these = {}
	local pos_needed = 0

	assert(edge_dist < width)
	assert(edge_dist < height)

	if water_contents.countstaticlayouts ~= nil and next(water_contents.countstaticlayouts) ~= nil then
		local add_fn = {
			fn=function(prefab, points_x, points_y, idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
				PopulateWorld_AddEntity(prefab, points_x[idx], points_y[idx], populating_tile, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
			end,
			args={entitiesOut=entitiesOut, width=width, height=height, rand_offset = true, debug_prefab_list=setpiece_prefab_list}
		}
		Ocean_PlaceSetPieces(water_contents.countstaticlayouts, add_fn, obj_layout, populating_tile, min_dist_from_land, encoded_topology, width, height)
	end

	if water_contents.countprefabs ~= nil then
		for prefab, count in pairs(water_contents.countprefabs) do
			if type(count) == "function" then
				count = count()
			end
			generate_these[prefab] = count
			pos_needed = pos_needed + count
		end

		--get a bunch of points
		local points_x, points_y = GetRandomWaterPoints(populating_tile, width, height, edge_dist, 2 * pos_needed + 10)

		local pos_cur = 1
		for prefab, count in pairs(generate_these) do
			local added = 0
			while added < count and pos_cur <= #points_x do
				if terrain.filter[prefab] == nil or not table.contains(terrain.filter[prefab], populating_tile) then
					local prefab_data = {}
					prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
					PopulateWorld_AddEntity(prefab, points_x[pos_cur], points_y[pos_cur], populating_tile, entitiesOut, width, height, prefab_list, prefab_data)
					added = added + 1
				end

				pos_cur = pos_cur + 1
			end
		end
	end

	if water_contents.distributepercent and water_contents.distributeprefabs then
		for y = edge_dist, height - edge_dist - 1, 1 do
			for x = edge_dist, width - edge_dist - 1, 1 do
				if world:GetTile(x, y) == populating_tile then
					if math.random() < water_contents.distributepercent then
						local prefab = spawnFn.pickspawnprefab(water_contents.distributeprefabs, populating_tile)
						if prefab ~= nil then
							local prefab_data = {}
							prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
							PopulateWorld_AddEntity(prefab, x, y, populating_tile, entitiesOut, width, height, prefab_list, prefab_data)
						end
					end
				end
			end
		end
	end

	PopulateWaterPrefabWorldGenCustomizations(populating_tile, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices, prefab_list)

	for prefab, num in pairs(setpiece_prefab_list) do
		if prefab_list[prefab] == nil then
			prefab_list[prefab] = 0
		end
		prefab_list[prefab] = prefab_list[prefab] + num
	end
end

function PopulateOcean(spawnFn, entitiesOut, width, height, ocean_contents, world_gen_choices, min_dist_from_land, encoded_topology)
	print("[Ocean] Populating the ocean with lots of fun things to do...")

    if ocean_contents ~= nil then
	    for i, room in ipairs(ocean_contents) do
		    PopulateWaterType(room.data.value, spawnFn, entitiesOut, width, height, OCEAN_POPULATION_EDGE_DIST, room.data.contents, world_gen_choices, min_dist_from_land, encoded_topology)
	    end
    end
end
