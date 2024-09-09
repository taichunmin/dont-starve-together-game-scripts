

-- Soil Moisture
--  Soil Moisture is updated in real time (every X seconds)
--	each plant sucks up moisture form the ground at its own rate
--	world tempeture and percipitation affects soild moisture
--	world percipitation will never cause soaked soil unless we add things to shelter plants or suck up extra moisture
--	each plant can have its own tolerance for what percent of dry vs wet it can withstand
--  if the soil does not have enough nutrients for the plant, it the plant will be stressed for the entire growth state

-- Soil Nutrients
--	Soil Nutrients are only update when a plant transitions to its next growth state, or when the gound is fertilized
--	each plant consumes a set of nutrients and restores one type of nutrient when it goes through a growth stage
--  if the soil does not have enough nutrients for the plant, it the plant will be stressed for the entire growth state, fertilizing will only help the next growth state



--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Farming_Manager class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "Farming_Manager should not exist on client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------
local SOIL_RAIN_MOD = TUNING.SOIL_RAIN_MOD
local MIN_DRYING_TEMP = TUNING.SOIL_MIN_DRYING_TEMP
local MAX_DRYING_TEMP = TUNING.SOIL_MAX_DRYING_TEMP
local SOIL_MIN_TEMP_DRY_RATE = TUNING.SOIL_MIN_TEMP_DRY_RATE
local SOIL_MAX_TEMP_DRY_RATE = TUNING.SOIL_MAX_TEMP_DRY_RATE
local MAX_SOIL_MOISTURE = TUNING.SOIL_MAX_MOISTURE_VALUE

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _map = _world.Map
local _worldsettingstimer = TheWorld.components.worldsettingstimer
local LORDFRUITFLY_TIMERNAME = "lordfruitfly_spawntime"

local _nutrientgrid --this grid contains the soil nutrients
local _moisturegrid --this grid contains the soil moisture
local _drinkersgrid	--this grid contains the list of soil drinkers
local _overlaygrid	--this grid contains the soil overlay entity

local _remaining_weed_spawns = {}
local _weed_spawning_task = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function OnFruitFlyTimerFinished()
    TheWorld:PushEvent("ms_fruitflytimerfinished")
end

local function StopFruitFlyTimer()
	_worldsettingstimer:StopTimer(LORDFRUITFLY_TIMERNAME)
end

local function StartFruitFlyTimer(time)
	StopFruitFlyTimer()
	_worldsettingstimer:StartTimer(LORDFRUITFLY_TIMERNAME, time)
end
_worldsettingstimer:AddTimer(LORDFRUITFLY_TIMERNAME, TUNING.LORDFRUITFLY_RESPAWN_TIME, TUNING.SPAWN_LORDFRUITFLY, OnFruitFlyTimerFinished)

local function AdvanceFruitFlyTimer(time)
	if _worldsettingstimer:ActiveTimerExists(LORDFRUITFLY_TIMERNAME) then
		_worldsettingstimer:SetTimeLeft(LORDFRUITFLY_TIMERNAME, math.max(0, _worldsettingstimer:GetTimeLeft(LORDFRUITFLY_TIMERNAME) - time))
	end
end

StartFruitFlyTimer(TUNING.LORDFRUITFLY_INITIALSPAWN_TIME)

local function EncodeNutrients(n1, n2, n3)
    return bit.lshift(bit.band(n1, 0xFF), 16) + bit.lshift(bit.band(n2, 0xFF), 8) + bit.band(n3, 0xFF)
end

local function DecodeNutrients(nutrients)
    return bit.band(bit.rshift(nutrients, 16), 0xFF), bit.band(bit.rshift(nutrients, 8), 0xFF), bit.band(nutrients, 0xFF)
end

local function SetSoilMoisture(index, soil_moisture)

	local prev_moisture = _moisturegrid:GetDataAtIndex(index)
	local new_moisture = Clamp(soil_moisture, TheWorld.state.wetness, MAX_SOIL_MOISTURE) or 0

	if prev_moisture ~= new_moisture then
		_moisturegrid:SetDataAtIndex(index, new_moisture)

		local nutrients_overlay = _overlaygrid:GetDataAtIndex(index)
		if nutrients_overlay ~= nil then
			nutrients_overlay:UpdateMoisture(soil_moisture / MAX_SOIL_MOISTURE)
		end

		-- we only push events when we go from 0 to non-0 and vice verse
		if new_moisture == 0 or prev_moisture == 0 then
			local soil_drinkers = _drinkersgrid:GetDataAtIndex(index)
			if soil_drinkers ~= nil then
				for obj, _ in pairs(soil_drinkers) do
					--obj:PushEvent("onsoilmoisturestatechange", {is_soil_moist = new_moisture > 0, was_soil_moist = prev_moisture > 0})
					obj.components.farmsoildrinker:OnSoilMoistureStateChange(new_moisture > 0, prev_moisture > 0)
					if new_moisture == 0 then
						obj:RemoveTag("wildfireprotected")
					elseif prev_moisture == 0 then
						obj:AddTag("wildfireprotected")
					end
				end
			end
		end
	end
end

local function InitializeDataGrids()
    if _nutrientgrid ~= nil then return end --only check one since the rest will all be in the same state

	local w, h = _map:GetSize()
	_nutrientgrid = DataGrid(w, h)
	_moisturegrid = DataGrid(w, h)
	_drinkersgrid = DataGrid(w, h)
	_overlaygrid = DataGrid(w, h)

	self.inst:DoPeriodicTask(TUNING.SOIL_MOISTURE_UPDATE_TIME, function() self:_RefreshSoilMoisture(TUNING.SOIL_MOISTURE_UPDATE_TIME) end)
end
inst:ListenForEvent("worldmapsetsize", InitializeDataGrids, _world)

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTerraform(inst, data, isloading)
    --isloading can only be set if called internally
    local x, y = data.x, data.y

	local index = _nutrientgrid:GetIndex(x, y)
	local nutrients = _nutrientgrid:GetDataAtIndex(index)
	local soilmoisture = _moisturegrid:GetDataAtIndex(index)
	local nutrients_overlay = _overlaygrid:GetDataAtIndex(index)

    if data.tile == WORLD_TILES.FARMING_SOIL then
		if not isloading then
			if not nutrients then
				self:SetTileNutrients(
					x, y,
					GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX),
					GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX),
					GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX)
				)
			end
			TheWorld.components.undertile:SetTileUnderneath(x, y, data.original_tile or nil)
		end

        if nutrients_overlay == nil then
            nutrients_overlay = SpawnPrefab("nutrients_overlay")
            nutrients_overlay.Transform:SetPosition(_map:GetTileCenterPoint(x,y))
            nutrients_overlay:UpdateOverlay(self:GetTileNutrients(x, y))
			_overlaygrid:SetDataAtIndex(index, nutrients_overlay)
        end
		SetSoilMoisture(index, soilmoisture or TheWorld.state.wetness)
    else
		TheWorld.components.undertile:ClearTileUnderneath(x, y)
		_moisturegrid:SetDataAtIndex(index, nil)
        if nutrients_overlay then
            nutrients_overlay:Remove()
			_overlaygrid:SetDataAtIndex(index, nil)
        end
    end
end

local function OnRemoveSoilDrinker(drinker)
	local index = _drinkersgrid:GetIndex(_map:GetTileCoordsAtPoint(drinker.Transform:GetWorldPosition()))
	local soil_drinkers = _drinkersgrid:GetDataAtIndex(index)
	if soil_drinkers ~= nil then
		soil_drinkers[drinker] = nil
		if IsTableEmpty(soil_drinkers) then
			_drinkersgrid:SetDataAtIndex(index, nil)
		end
	end
end

local function OnRegisterSoilDrinker(drinker)
	local index = _drinkersgrid:GetIndex(_map:GetTileCoordsAtPoint(drinker.Transform:GetWorldPosition()))
	local soil_drinkers = _drinkersgrid:GetDataAtIndex(index)
	if not soil_drinkers then
		soil_drinkers = {}
		_drinkersgrid:SetDataAtIndex(index, soil_drinkers)
	end

	soil_drinkers[drinker] = true

	local soilmoisture = _moisturegrid:GetDataAtIndex(index)
	if soilmoisture == nil then
		soilmoisture = TheWorld.state.wetness
		_moisturegrid:SetDataAtIndex(index, soilmoisture)
	end

	if soilmoisture > 0 then
		drinker:AddTag("wildfireprotected")
	end

	inst:ListenForEvent("onremove", OnRemoveSoilDrinker, drinker)
end

local FRUITFLYSPAWNER_MUST_TAGS = { "fruitflyspawner" }
local function OnFruitFlySpawnerActive(data)
    local plant = data.plant
    if not TUNING.SPAWN_LORDFRUITFLY or plant:IsAsleep() or _worldsettingstimer:ActiveTimerExists(LORDFRUITFLY_TIMERNAME) or TheSim:FindFirstEntityWithTag("lordfruitfly") or (data.check_others == true and not plant:IsNearPlayer(15, true)) then
        return
    end
    local x, y, z = plant.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.LORDFRUITFLY_SPAWNERRADIUS, FRUITFLYSPAWNER_MUST_TAGS)
    if #ents >= TUNING.LORDFRUITFLY_SPAWNERCOUNT then
		local lordfruitfly = SpawnPrefab("lordfruitfly")
        lordfruitfly.Transform:SetPosition(x, 20, z)
        lordfruitfly.sg:GoToState("land")
        return
    end
    if data.check_others then
        for i, ent in ipairs(ents) do
            OnFruitFlySpawnerActive({plant = ent, check_others = false})
        end
    end
end

local FIND_SOIL_TAG = {"soil"}
local WEIGHTED_SEED_TABLE = require("prefabs/weed_defs").weighted_seed_table

local function TrySpawnWeed(x, y)
	local nutrients_overlay = _overlaygrid:GetDataAtPoint(x, y)
	if nutrients_overlay ~= nil and nutrients_overlay:IsValid() then
		local half_tile = TILE_SCALE * 0.9 / 2

		local in_soil, spawn_x, spawn_y, spawn_z

		local _x, _y, _z = nutrients_overlay.Transform:GetWorldPosition()
		local soils = TheSim:FindEntities(_x, _y, _z, half_tile, FIND_SOIL_TAG)
		if #soils > 0 then
			local soil = soils[#soils == 1 and 1 or math.random(#soils)]
			spawn_x, spawn_y, spawn_z = soil.Transform:GetWorldPosition()
			soil:Remove()
			in_soil = true
		else
			for i = 1, 4 do
				local offset_x, offset_z = GetRandomMinMax(-half_tile, half_tile), GetRandomMinMax(-half_tile, half_tile)
				if TheWorld.Map:CanTillSoilAtPoint(_x + offset_x, 0, _z + offset_z) then
					spawn_x, spawn_y, spawn_z = _x + offset_x, 0, _z + offset_z
					TheWorld.Map:CollapseSoilAtPoint(spawn_x, spawn_y, spawn_z)
					break
				end
			end
		end

		if spawn_x ~= nil then
			local new_weed = SpawnPrefab(weighted_random_choice(WEIGHTED_SEED_TABLE))
			new_weed.Transform:SetPosition(spawn_x, spawn_y, spawn_z)
			new_weed:PushEvent("on_planted", {in_soil = in_soil})
		end
	end
end

local function OnSeasonChange(inst, season)
	_remaining_weed_spawns = {}

	local weed_chance = TUNING.SEASONAL_WEED_SPAWN_CAHNCE[season]
	if weed_chance ~= nil and weed_chance > 0 then
		local spawn_window = TheWorld.state.remainingdaysinseason * 0.25

		-- start updating weeds
		for index in pairs(_overlaygrid.grid) do
			if math.random() < weed_chance then
				table.insert(_remaining_weed_spawns, {loc = index, season_time = math.random() * spawn_window})
			end
		end

		if #_remaining_weed_spawns > 0 then
			table.sort(_remaining_weed_spawns, function(a, b) return a.season_time > b.season_time end) -- sort descending so we can remove from the end of the array instead of the front
			 _weed_spawning_task = TheWorld:DoPeriodicTask(TUNING.SEG_TIME, self._UpdateWeedSpawning)
		end
	end
end


--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
function self:_RefreshSoilMoisture(dt)
	local rain_rate = TheWorld.state.israining and TheWorld.state.precipitationrate or 0
	local world_wetness = TheWorld.state.wetness

	for index, soilmoisture in pairs(_moisturegrid.grid) do
		if soilmoisture < world_wetness then
			-- the soil will never by dryer than the ground's wetness
			SetSoilMoisture(index, world_wetness)
		else
			local tx, ty = _moisturegrid:GetXYFromIndex(index)
			local x, y, z = TheWorld.Map:GetTileCenterPoint(tx, ty)

			local world_temp = GetTemperatureAtXZ(x, z)

			-- if its raining, then add moisture based on how hard its raining, otherwise, the world temp may do some drying
			local world_rate = rain_rate > 0 and (rain_rate * SOIL_RAIN_MOD)
						or Remap(Clamp(world_temp, MIN_DRYING_TEMP, MAX_DRYING_TEMP), MIN_DRYING_TEMP, MAX_DRYING_TEMP, SOIL_MIN_TEMP_DRY_RATE, SOIL_MAX_TEMP_DRY_RATE)	--

			local obj_rate = 0

			local soil_drinkers = _drinkersgrid:GetDataAtIndex(index)

			if soil_drinkers ~= nil then
				for obj, _ in pairs(soil_drinkers) do
					obj_rate = obj_rate + obj.components.farmsoildrinker:GetMoistureRate()
				end
			end
			--print ("_RefreshSoilMoisture", soilmoisture, soilmoisture, dt * (obj_rate + world_rate), dt,obj_rate, world_rate)
			SetSoilMoisture(index, soilmoisture + dt * (obj_rate + world_rate))
		end
	end
end

function self:_UpdateWeedSpawning()
	local season_time = inst.state.elapseddaysinseason + inst.state.time
	local world_width = inst.Map:GetSize()

	for i = #_remaining_weed_spawns, 1, -1 do
		local data = _remaining_weed_spawns[i]
		if data.season_time < season_time then
			local y = math.floor(data.loc / world_width)
			local x = math.floor((data.loc / world_width - y) * world_width + 0.5)
			TrySpawnWeed(x, y)
			_remaining_weed_spawns[i] = nil
		else
			break
		end
	end

	if #_remaining_weed_spawns == 0 and _weed_spawning_task ~= nil then
		_weed_spawning_task:Cancel()
		_weed_spawning_task = nil
	end
end


function self:LongUpdate(dt)
	if _moisturegrid ~= nil then
    	self:_RefreshSoilMoisture(dt)
	end
	if _weed_spawning_task ~= nil then
		self:_UpdateWeedSpawning()
	end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetTileNutrients(x, y)
	local nutrients = _nutrientgrid:GetDataAtPoint(x, y)

	if nutrients then
        return DecodeNutrients(nutrients)
	end
	nutrients = GetTileInfo(_map:GetTile(x, y)).nutrients
    if nutrients then
        return unpack(nutrients)
    end
    return 0, 0, 0
end

function self:SetTileNutrients(x, y, n1, n2, n3)
    local nutrients = EncodeNutrients(n1, n2, n3)
	_nutrientgrid:SetDataAtPoint(x, y, nutrients)

	local nutrients_overlay = _overlaygrid:GetDataAtPoint(x, y)
	if nutrients_overlay then
		nutrients_overlay:UpdateOverlay(n1, n2, n3)
    end
end

function self:AddTileNutrients(x, y, nutrient1, nutrient2, nutrient3)
    local _n1, _n2, _n3 = self:GetTileNutrients(x, y)
    self:SetTileNutrients(x, y, math.clamp(_n1 + nutrient1, 0, 100), math.clamp(_n2 + nutrient2, 0, 100), math.clamp(_n3 + nutrient3, 0, 100))
	return true
end

function self:CycleNutrientsAtPoint(_x, _y, _z, consume, restore, test_only)
    local x, y = TheWorld.Map:GetTileCoordsAtPoint(_x, _y, _z)
	local nutrients_overlay = _overlaygrid:GetDataAtPoint(x, y)
	if nutrients_overlay == nil then
		return true --soil is depleted
	end

    local nutrients = {self:GetTileNutrients(x, y)}

	local depleted = false
    if consume ~= nil then
        local updatenutrients = {0, 0, 0}
        local total_restore_count = 0
        for n_type, count in ipairs(consume) do
            local consumptioncount = math.min(nutrients[n_type], count)
            updatenutrients[n_type] = updatenutrients[n_type] + -consumptioncount
            total_restore_count = total_restore_count + consumptioncount
			depleted = depleted or consumptioncount ~= count
		end

		if test_only then
			return depleted
		end

        if restore then
            --amount of valid nutrient types to restore
            local nutrients_to_restore_count = GetTableSize(restore)
            --the amount of nutrients to restore to all nutrients in the restore table
            local nutrient_restore_count = math.floor(total_restore_count/nutrients_to_restore_count)

            --if the number doesn't divide evenly between the nutrients, randomly restore the excess nutrients to a valid type
            local excess_restore_count = total_restore_count - (nutrient_restore_count * nutrients_to_restore_count)
            --if excess_restore_count is 0 we do nothing
            --if excess_restore_count is 1, we add it to the nutrient determined by math.random
            --if excess_restore_count is 2, we add it to all other nutrients except the one determined by math.random
            --due to our total nutrient count, excess_restore_count will always come to be a valid number
            local excess_restore_rand = math.random(nutrients_to_restore_count)

            for n_type = 1, 3 do
                if restore[n_type] then
                    updatenutrients[n_type] = updatenutrients[n_type] + nutrient_restore_count

                    excess_restore_rand = excess_restore_rand - 1
                    if (excess_restore_count == 1 and excess_restore_rand == 0) or
                    (excess_restore_count == 2 and excess_restore_rand ~= 0) then
                        updatenutrients[n_type] = updatenutrients[n_type] + 1
                    end
                end
            end
        end

        self:AddTileNutrients(x, y, unpack(updatenutrients))
    end

	return depleted
end

function self:GetTileBelowSoil(x, y)
	return TheWorld.components.undertile:GetTileUnderneath(x, y)
end

function self:AddSoilMoistureAtPoint(x, y, z, moisture_delta)
	if moisture_delta ~= 0 then
		local index = _overlaygrid:GetIndex(_map:GetTileCoordsAtPoint(x, y, z))
		local nutrients_overlay = _overlaygrid:GetDataAtIndex(index) --if the tile is not used for farming then there is no need to track the moisture
		if nutrients_overlay then
			local soilmoisture = _moisturegrid:GetDataAtIndex(index)
			SetSoilMoisture(index, (soilmoisture or TheWorld.state.wetness) + moisture_delta)
		end
	end
end

function self:IsSoilMoistAtPoint(x, y, z)
	local soilmoisture = _moisturegrid:GetDataAtPoint(_map:GetTileCoordsAtPoint(x, y, z))
	return soilmoisture ~= nil and soilmoisture > 0 or TheWorld.state.wetness > 0
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------
local FARMING_MANAGER_SAVE_VERSION = 2

function self:OnSave()
    local data = {}

	if #_remaining_weed_spawns > 0 then
		data.remaining_weed_spawns = _remaining_weed_spawns
	end

	data.nutrientgrid = _nutrientgrid:Save()
	data.moisturegrid = _moisturegrid:Save()

	data.lordfruitfly_queued_spawn = not _worldsettingstimer:ActiveTimerExists(LORDFRUITFLY_TIMERNAME)

	data.version = FARMING_MANAGER_SAVE_VERSION

	return ZipAndEncodeSaveData(data)
end

local function LoadVersion1Tiledata(data)
	if data.tile_data then
		local tile_id_conversion_map = TheWorld.tile_id_conversion_map
		for x, ylist in pairs(data.tile_data) do
			for y, entries in pairs(ylist) do
				local index = _nutrientgrid:GetIndex(x, y)

				if entries.nutrients then
					_nutrientgrid:SetDataAtIndex(index, entries.nutrients)
				end

				if entries.soilmoisture then
					_moisturegrid:SetDataAtIndex(index, entries.soilmoisture)
				end

				local map_tile = _map:GetTile(x, y)
				if map_tile == WORLD_TILES.FARMING_SOIL then
					local undertile = entries.belowsoiltile
					if undertile then
						if tile_id_conversion_map then
							undertile = tile_id_conversion_map[undertile] or undertile
						end
						TheWorld.components.undertile:SetTileUnderneath(x, y, undertile)
					end
					OnTerraform(_world, {x = x, y = y, tile = map_tile}, true)
				end
			end
		end
	end
end

local function LoadVersion2Tiledata(data)
	_nutrientgrid:Load(data.nutrientgrid)
	_moisturegrid:Load(data.moisturegrid)

	local w, h = _map:GetSize()
	for x = 0, w - 1 do
		for y = 0, h - 1 do
			local map_tile = _map:GetTile(x, y)
			if map_tile == WORLD_TILES.FARMING_SOIL then
				OnTerraform(_world, {x = x, y = y, tile = map_tile}, true)
			end
		end
	end
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)
    if data == nil then return end

	local version = data.version or 1

	if version == 1 then
		LoadVersion1Tiledata(data)
	else
		LoadVersion2Tiledata(data)
	end

	if data.remaining_weed_spawns then
		_remaining_weed_spawns = data.remaining_weed_spawns
		if _weed_spawning_task == nil then
			_weed_spawning_task = TheWorld:DoPeriodicTask(TUNING.SEG_TIME, self._UpdateWeedSpawning)
		end
	end
	if data.lordfruitfly_spawntime then
		StartFruitFlyTimer(data.lordfruitfly_spawntime)
	elseif data.lordfruitfly_queued_spawn ~= false then
		StopFruitFlyTimer()
	end
end


--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local s = ""

	local target = ConsoleCommandPlayer()
	if target ~= nil and target.Transform ~= nil then
	    local x, y = _map:GetTileCoordsAtPoint(target.Transform:GetWorldPosition())

		local index = _overlaygrid:GetIndex(x, y)
		local nutrients_overlay = _overlaygrid:GetDataAtIndex(index)

		if nutrients_overlay ~= nil then
			local soilmoisture = _moisturegrid:GetDataAtIndex(index)
			if soilmoisture ~= nil then
				local soil_drinkers = _drinkersgrid:GetDataAtIndex(index)
				s = s .. "M: ".. string.format("%.3f", soilmoisture) .. " (# " .. tostring(soil_drinkers ~= nil and GetTableSize(soil_drinkers) or 0) .. ")"
			end
		    local _n1, _n2, _n3 = self:GetTileNutrients(x, y)
			s = s .. ", N: " .. tostring(_n1) .. ", " .. tostring(_n2) .. ", " .. tostring(_n3)
		else
			s = s .. "No data"
		end
    end
	local spawntime = _worldsettingstimer:GetTimeLeft(LORDFRUITFLY_TIMERNAME)
    if spawntime then
        s = s .. ", LotFF spawntime: "..string.format("%0.2f", spawntime)
	elseif TheSim:FindFirstEntityWithTag("lordfruitfly") then
		s = s .. ", LotFF spawned!"
	else
        s = s .. ", LotFF spawntime: spawn pending!"
    end
	return s
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self.inst:ListenForEvent("onterraform", OnTerraform)
self.inst:ListenForEvent("ms_registersoildrinker", function(i, m) OnRegisterSoilDrinker(m) end)
self.inst:ListenForEvent("ms_unregistersoildrinker", function(i, m) OnRemoveSoilDrinker(m) end)
self.inst:ListenForEvent("ms_fruitflyspawneractive", function(world, data) OnFruitFlySpawnerActive(data) end)
self.inst:ListenForEvent("ms_lordfruitflykilled", function() StartFruitFlyTimer(TUNING.LORDFRUITFLY_RESPAWN_TIME) end)
self.inst:ListenForEvent("ms_oncroprotted", function() AdvanceFruitFlyTimer(TUNING.LORDFRUITFLY_CROP_ROTTED_ADVANCE_TIME) end)

self:WatchWorldState("season", OnSeasonChange)

end)
