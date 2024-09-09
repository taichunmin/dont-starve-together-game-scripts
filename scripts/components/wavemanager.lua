local function GetWaveBearing(map, ex, ey, ez)
	local radius = 3.5
	local tx, tz = ex % TILE_SCALE, ez % TILE_SCALE
	local left = tx - radius < 0
	local right = tx + radius > TILE_SCALE
	local up = tz - radius < 0
	local down = tz + radius > TILE_SCALE


	local offs_1 =
	{
		{-1,-1, left and up},   {0,-1, up},   {1,-1, right and up},
		{-1, 0, left},		    			  {1, 0, right},
		{-1, 1, left and down}, {0, 1, down}, {1, 1, right and down},
	}

	local width, height = map:GetSize()
	local halfw, halfh = 0.5 * width, 0.5 * height
	local x, y = map:GetTileXYAtPoint(ex, ey, ez)
	local xtotal, ztotal, n = 0, 0, 0

	local is_nearby_land_tile = false

	for i = 1, #offs_1, 1 do
		local curoff = offs_1[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsLandTile(ground) then
			if curoff[3] then
				return false
			else
				is_nearby_land_tile = true
			end
			xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

	radius = 4.5
	local minoffx, maxoffx, minoffy, maxoffy
	if not is_nearby_land_tile then
		minoffx = math.floor((tx - radius) / TILE_SCALE)
		maxoffx = math.floor((tx + radius) / TILE_SCALE)
		minoffy = math.floor((tz - radius) / TILE_SCALE)
		maxoffy = math.floor((tz + radius) / TILE_SCALE)
	end

	local offs_2 =
	{
		{-2,-2}, {-1,-2}, {0,-2}, {1,-2}, {2,-2},
		{-2,-1}, 						  {2,-1},
		{-2, 0}, 						  {2, 0},
		{-2, 1}, 						  {2, 1},
		{-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2}
	}
	for i = 1, #offs_2, 1 do
		local curoff = offs_2[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsLandTile(ground) then
			if not is_nearby_land_tile then
				is_nearby_land_tile = offx >= minoffx and offx <= maxoffx and offy >= minoffy and offy <= maxoffy
			end
			xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

	if n == 0 then return true end
	if not is_nearby_land_tile then return false end
	return -math.atan2(ztotal/n - ez, xtotal/n - ex)/DEGREES - 90
end

local function TrySpawnWavesOrShore(self, map, x, y, z)
	local bearing = GetWaveBearing(map, x, y, z)
	if bearing == false then return end

	if bearing == true then
		SpawnPrefab("wave_shimmer").Transform:SetPosition(x, y, z)
	else
		local wave = SpawnPrefab("wave_shore")
		wave.Transform:SetPosition( x, y, z )
		wave.Transform:SetRotation(bearing)
		wave:SetAnim()
	end
end

local function TrySpawnWaveShimmerMedium(self, map, x, y, z)
	if map:IsSurroundedByWater(x, y, z, 4) then
		local wave = SpawnPrefab( "wave_shimmer_med" )
		wave.Transform:SetPosition( x, y, z )
	end
end

local function TrySpawnWaveShimmerDeep(self, map, x, y, z)
	if map:IsSurroundedByWater(x, y, z, 5) then
		local wave = SpawnPrefab( "wave_shimmer_deep" )
		wave.Transform:SetPosition( x, y, z )
	end
end

local WaveManager = Class(function(self, inst)
	self.inst = inst

	self.shimmer =
	{
		[WORLD_TILES.OCEAN_COASTAL_SHORE] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWavesOrShore},
		[WORLD_TILES.OCEAN_COASTAL] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWavesOrShore},
		[WORLD_TILES.OCEAN_BRINEPOOL] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWavesOrShore},
		[WORLD_TILES.OCEAN_SWELL] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWaveShimmerMedium},
		[WORLD_TILES.OCEAN_ROUGH] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWaveShimmerDeep},
		[WORLD_TILES.OCEAN_HAZARDOUS] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWaveShimmerDeep},
		[WORLD_TILES.OCEAN_WATERLOG] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnWavesOrShore},
	}

	self.ripple_per_sec = 10
	self.ripple_idle_time = 5

	self.shimmer_per_sec_mod = 1.0

	self.inst:StartUpdatingComponent(self)
end)

local function calcShimmerRadius()
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local radius = (75 - 30) * percent + 30
	return radius
end

local function calcPerSecMult(min, max)
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local mult = (1.5 - 1) * percent + 1 -- 1x to 1.5x
	return mult
end

function WaveManager:OnUpdate(dt)
	if ThePlayer == nil then return end

	local map = TheWorld.Map
	if map == nil then return end

	local px, py, pz = ThePlayer.Transform:GetWorldPosition()
	local mult = calcPerSecMult()

	local radius = calcShimmerRadius()
	for g, shimmer in pairs(self.shimmer) do
		shimmer.spawn_rate = shimmer.spawn_rate + shimmer.per_sec * self.shimmer_per_sec_mod * mult * dt
		while shimmer.spawn_rate > 1.0 do
			local dx, dz = radius * UnitRand(), radius * UnitRand()
			local x, y, z = px + dx, py, pz + dz

			if shimmer.tryspawn then
				if map:GetTileAtPoint(x, y, z) == g then
					shimmer.tryspawn(self, map, x, y, z)
				end
			elseif shimmer.checkfn(self, map, x, y, z, g) then
				shimmer.spawnfn(self, x, y, z)
			end

			shimmer.spawn_rate = shimmer.spawn_rate - 1.0
		end

	end

	if self.shimmer_per_sec_mod <= 0.0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function WaveManager:GetDebugString()
	return "Shimmer: " .. tostring(calcShimmerRadius()) .. ", Mult: " .. tostring(calcPerSecMult)
end

return WaveManager
