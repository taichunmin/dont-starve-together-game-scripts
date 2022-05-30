
local function SpawnWaveShimmerMedium(inst, x, y, z)
	local wave = SpawnPrefab( "wave_shimmer_med" )
	wave.Transform:SetPosition( x, y, z )
end

local function SpawnWaveShimmerDeep(inst, x, y, z)
	local wave = SpawnPrefab( "wave_shimmer_deep" )
	wave.Transform:SetPosition( x, y, z )
end

local function GetWaveBearing(ex, ey, ez, lines)
	-- TheSim:ProfilerPush("GetWaveBearing")

	local offs =
	{
		{-2,-2}, {-1,-2}, {0,-2}, {1,-2}, {2,-2},
		{-2,-1}, {-1,-1}, {0,-1}, {1,-1}, {2,-1},
		{-2, 0}, {-1, 0},		  {1, 0}, {2, 0},
		{-2, 1}, {-1, 1}, {0, 1}, {1, 1}, {2, 1},
		{-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2}
	}

	local map = TheWorld.Map
	local width, height = map:GetSize()
	local halfw, halfh = 0.5 * width, 0.5 * height
	local x, y = map:GetTileXYAtPoint(ex, ey, ez)
	local xtotal, ztotal, n = 0, 0, 0
	for i = 1, #offs, 1 do
		local ground = map:GetTile( x + offs[i][1], y + offs[i][2] )
		if IsLandTile(ground) then
			xtotal = xtotal + ((x + offs[i][1] - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offs[i][2] - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

	local bearing = nil
	if n > 0 then
		local a = math.atan2(ztotal/n - ez, xtotal/n - ex)
		bearing = -a/DEGREES - 90
	end

	-- TheSim:ProfilerPop()

	return bearing
end

local function SpawnWaveShore(inst, x, y, z)
	-- TheSim:ProfilerPush("SpawnWaveShore")
	local bearing = GetWaveBearing(x, y, z)
	if bearing then
		local wave = SpawnPrefab( "wave_shore" )
		wave.Transform:SetPosition( x, y, z )
		wave.Transform:SetRotation(bearing)
		wave:SetAnim()
	end
	-- TheSim:ProfilerPop()
end

local function SpawnWaves(inst, x, y, z)
	local is_surrounded_by_water = TheWorld.Map:IsSurroundedByWater(x, y, z, 4.5)

	if is_surrounded_by_water then
		local wave = SpawnPrefab( "wave_shimmer" )
		wave.Transform:SetPosition( x, y, z )
	else
		local is_nearby_ground = not TheWorld.Map:IsSurroundedByWater(x, y, z, 3.5)
		if is_nearby_ground then
			local is_nearby_surrounded_by_water = TheWorld.Map:IsSurroundedByWater(x, y, z, 2.5)
			if is_nearby_surrounded_by_water then
				SpawnWaveShore(inst, x,y,z)
			end
		end
	end
end

local function checkground(inst, map, x, y, z, ground)
	local is_ground = map:GetTileAtPoint( x, y, z ) == ground
	if not is_ground then return false end

	local radius = 2
	return map:IsValidTileAtPoint( x - radius, y, z )
			and map:IsValidTileAtPoint( x + radius, y, z )
			and map:IsValidTileAtPoint( x, y, z - radius )
			and map:IsValidTileAtPoint( x, y, z + radius )
end

local WaveManager = Class(function(self, inst)
	self.inst = inst

	self.shimmer =
	{
		[GROUND.OCEAN_COASTAL_SHORE] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaves},
		[GROUND.OCEAN_BRINEPOOL_SHORE] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaves},

		[GROUND.OCEAN_COASTAL] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaves},
		[GROUND.OCEAN_BRINEPOOL] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaves},
		[GROUND.OCEAN_SWELL] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaveShimmerMedium},
		[GROUND.OCEAN_ROUGH] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaveShimmerDeep},
		[GROUND.OCEAN_HAZARDOUS] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaveShimmerDeep},
		[GROUND.OCEAN_WATERLOG] = {per_sec = 80, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnWaves},
	}

	self.ripple_per_sec = 10
	self.ripple_idle_time = 5

	self.shimmer_per_sec_mod = 1.0

	self.inst:StartUpdatingComponent(self)
end)

local function calcShimmerRadius()
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local radius = (75 - 30) * percent + 30
	--print("Shimmer ", TheCamera:GetDistance(), radius)
	return radius
end

local function calcPerSecMult(min, max)
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local mult = (1.5 - 1) * percent + 1 -- 1x to 1.5x
	--print("Per sec", TheCamera:GetDistance(), mult)
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

			if shimmer.checkfn(self, map, x, y, z, g) then
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
