

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
local tile_data = {}
local LORDFRUITFLY_TIMERNAME = "lordfruitfly_spawntime"

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

local function GetTileDataAtPoint(lazy_init, _x, _y, _z)
    local x, y = _map:GetTileCoordsAtPoint(_x, _y, _z)
	if lazy_init then
		tile_data[x] = tile_data[x] or {}
		tile_data[x][y] = tile_data[x][y] or {}
		return tile_data[x][y]
	else
		return (tile_data[x] ~= nil and tile_data[x][y] ~= nil) and tile_data[x][y] or nil
	end
end

local function SetSoilMoisture(data, soil_moisture)
	local prev_moisture = data.soilmoisture or 0
	data.soilmoisture = Clamp(soil_moisture, TheWorld.state.wetness, MAX_SOIL_MOISTURE)
	local new_moisture = data.soilmoisture or 0

	if data.nutrients_overlay ~= nil then
		data.nutrients_overlay:UpdateMoisture(data.soilmoisture / MAX_SOIL_MOISTURE)
	end

	if prev_moisture ~= new_moisture then
		-- we only push events when we go from 0 to non-0 and vice verse
		if new_moisture == 0 or prev_moisture == 0 then
			if data.soil_drinkers ~= nil then
				for obj, _ in pairs(data.soil_drinkers) do
					--obj:PushEvent("onsoilmoisturestatechange", {is_soil_moist = new_moisture > 0, was_soil_moist = prev_moisture > 0})
					obj.components.farmsoildrinker:OnSoilMoistureStateChange(new_moisture > 0, prev_moisture > 0)
					if new_moisture == 0 then
						inst:RemoveTag("wildfireprotected")
					elseif prev_moisture == 0 then
						inst:AddTag("wildfireprotected")
					end
				end
			end
		end
	end

end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTerraform(inst, data, isloading)
    --isloading can only be set if called internally
    local x, y = data.x, data.y
    tile_data[x] = tile_data[x] or {}
    tile_data[x][y] = tile_data[x][y] or {}
    local tile_entities = tile_data[x][y]

    if data.tile == GROUND.FARMING_SOIL then
        if not isloading and not tile_entities.nutrients then
            self:SetTileNutrients(x, y, GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX), GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX), GetRandomMinMax(TUNING.STARTING_NUTRIENTS_MIN, TUNING.STARTING_NUTRIENTS_MAX))
        end
		tile_entities.belowsoiltile = data.original_tile or GROUND.DIRT
        if tile_entities.nutrients_overlay == nil then
            local nutrients_overlay = SpawnPrefab("nutrients_overlay")
            nutrients_overlay.Transform:SetPosition(_map:GetTileCenterPoint(x,y))
            nutrients_overlay:UpdateOverlay(self:GetTileNutrients(x, y))
            tile_entities.nutrients_overlay = nutrients_overlay
        end
		SetSoilMoisture(tile_entities, tile_entities.soilmoisture or TheWorld.state.wetness)
    else
        tile_entities.belowsoiltile = nil
		tile_entities.soilmoisture = nil
        if tile_entities.nutrients_overlay then
            tile_entities.nutrients_overlay:Remove()
            tile_entities.nutrients_overlay = nil
        end
    end
end

local function OnRemoveSoilDrinker(drinker)
	local data = GetTileDataAtPoint(false, drinker.Transform:GetWorldPosition())
	if data ~= nil and data.soil_drinkers ~= nil then
		data.soil_drinkers[drinker] = nil
		if next(data.soil_drinkers) == nil then
			data.soil_drinkers = nil
		end
	end
end

local function OnRegisterSoilDrinker(drinker)
	local data = GetTileDataAtPoint(true, drinker.Transform:GetWorldPosition())
	data.soil_drinkers = data.soil_drinkers or {}
	data.soil_drinkers[drinker] = true
	if data.soilmoisture == nil then
		data.soilmoisture = TheWorld.state.wetness
	end

	if data.soilmoisture > 0 then
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
	local data = tile_data[x] ~= nil and tile_data[x][y] or nil
	if data ~= nil and data.nutrients_overlay ~= nil and data.nutrients_overlay:IsValid() then
		local half_tile = TILE_SCALE * 0.9 / 2

		local in_soil, spawn_x, spawn_y, spawn_z

		local _x, _y, _z = data.nutrients_overlay.Transform:GetWorldPosition()
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
		local world_width = TheWorld.Map:GetSize()
		local spawn_window = TheWorld.state.remainingdaysinseason * 0.25

		-- start updating weeds
		for x, ylist in pairs(tile_data) do
			for y, data in pairs(ylist) do
				if data.nutrients_overlay ~= nil then
					if math.random() < weed_chance then
						table.insert(_remaining_weed_spawns, {loc = x + y * world_width, season_time = math.random() * spawn_window})
					end
				end
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
	local world_temp = TheWorld.state.temperature

    for x, ylist in pairs(tile_data) do
        for y, data in pairs(ylist) do
            if data.soilmoisture ~= nil then
				if data.soilmoisture < world_wetness then
					-- the soil will never by dryer than the ground's wetness
					SetSoilMoisture(data, world_wetness)
				else
					-- if its raining, then add moisture based on how hard its raining, otherwise, the world temp may do some drying
					local world_rate = rain_rate > 0 and (rain_rate * SOIL_RAIN_MOD)
								or Remap(Clamp(world_temp, MIN_DRYING_TEMP, MAX_DRYING_TEMP), MIN_DRYING_TEMP, MAX_DRYING_TEMP, SOIL_MIN_TEMP_DRY_RATE, SOIL_MAX_TEMP_DRY_RATE)	--

					local obj_rate = 0
					if data.soil_drinkers ~= nil then
						for obj, _ in pairs(data.soil_drinkers) do
							obj_rate = obj_rate + obj.components.farmsoildrinker:GetMoistureRate()
						end
					end
					--print ("_RefreshSoilMoisture", data.soilmoisture, data.soilmoisture, dt * (obj_rate + world_rate), dt,obj_rate, world_rate)
					SetSoilMoisture(data, data.soilmoisture + dt * (obj_rate + world_rate))
				end
			end
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
    self:_RefreshSoilMoisture(dt)
	if _weed_spawning_task ~= nil then
		self:_UpdateWeedSpawning()
	end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetTileNutrients(x, y)
    local data = tile_data[x] and tile_data[x][y] or {}
    if data.nutrients then
        return DecodeNutrients(data.nutrients)
    end
    local nutrients = GetTileInfo(_map:GetTile(x, y)).nutrients
    if nutrients then
        return unpack(nutrients)
    end
    return 0, 0, 0
end

function self:SetTileNutrients(x, y, n1, n2, n3)
    tile_data[x] = tile_data[x] or {}
    tile_data[x][y] = tile_data[x][y] or {}
    local data = tile_data[x][y]
    data.nutrients = EncodeNutrients(n1, n2, n3)
    if data.nutrients_overlay then
        data.nutrients_overlay:UpdateOverlay(n1, n2, n3)
    end
end

function self:AddTileNutrients(x, y, nutrient1, nutrient2, nutrient3)
    local _n1, _n2, _n3 = self:GetTileNutrients(x, y)
    self:SetTileNutrients(x, y, math.clamp(_n1 + nutrient1, 0, 100), math.clamp(_n2 + nutrient2, 0, 100), math.clamp(_n3 + nutrient3, 0, 100))
	return true
end

function self:CycleNutrientsAtPoint(_x, _y, _z, consume, restore, test_only)
	local data = GetTileDataAtPoint(false, _x, _y, _z)
	if data == nil or data.nutrients_overlay == nil then
		return true --soil is depleted
	end

    local x, y = TheWorld.Map:GetTileCoordsAtPoint(_x, _y, _z)
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
    return tile_data[x] and tile_data[x][y] and tile_data[x][y].belowsoiltile
end

function self:AddSoilMoistureAtPoint(x, y, z, moisture_delta)
	if moisture_delta ~= 0 then
		local data = GetTileDataAtPoint(false, x, y, z) -- if the tile is not used for farming then there is no need to track the moisture
		if data ~= nil then
			SetSoilMoisture(data, (data.soilmoisture or TheWorld.state.wetness) + moisture_delta)
		end
	end
end

function self:IsSoilMoistAtPoint(x, y, z)
	local data = GetTileDataAtPoint(false, x, y, z)
	return (data ~= nil and data.soilmoisture ~= nil) and data.soilmoisture > 0 or TheWorld.state.wetness > 0
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {tile_data = {}}

	if #_remaining_weed_spawns > 0 then
		data.remaining_weed_spawns = _remaining_weed_spawns
	end

    for x, ylist in pairs(tile_data) do
        data.tile_data[x] = {}
        for y, entries in pairs(ylist) do
            data.tile_data[x][y] = {}
            if entries.nutrients then
                data.tile_data[x][y].nutrients = entries.nutrients
            end
            if entries.belowsoiltile then
                data.tile_data[x][y].belowsoiltile = entries.belowsoiltile
            end
            if entries.soilmoisture then
                data.tile_data[x][y].soilmoisture = entries.soilmoisture
            end
        end
    end

	data.lordfruitfly_queued_spawn = not _worldsettingstimer:ActiveTimerExists(LORDFRUITFLY_TIMERNAME)

	return ZipAndEncodeSaveData(data)
end

function self:OnLoad(data)
    data = DecodeAndUnzipSaveData(data)

    if data ~= nil then
        if data.tile_data then
            for x, ylist in pairs(data.tile_data) do
                tile_data[x] = {}
                for y, entries in pairs(ylist) do
                    tile_data[x][y] = {}

                    if entries.nutrients then
                        tile_data[x][y].nutrients = entries.nutrients
                    end

                    if entries.soilmoisture then
                        tile_data[x][y].soilmoisture = entries.soilmoisture
                    end

					local map_tile = _map:GetTile(x, y)
                    if map_tile == GROUND.FARMING_SOIL then
                        OnTerraform(_world, {x = x, y = y, original_tile = entries.belowsoiltile, tile = map_tile}, true)
                    end
                end
            end
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
end


--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local s = ""

	local target = ConsoleCommandPlayer()
	if target ~= nil and target.Transform ~= nil then
	    local x, y = _map:GetTileCoordsAtPoint(target.Transform:GetWorldPosition())
		local data = tile_data[x] ~= nil and tile_data[x][y] or nil
		if data ~= nil then
			if data.soilmoisture ~= nil then
				s = s .. "M: ".. string.format("%.3f", data.soilmoisture) .. " (# " .. tostring(data.soil_drinkers ~= nil and GetTableSize(data.soil_drinkers) or 0) .. ")"
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

self.inst:DoPeriodicTask(TUNING.SOIL_MOISTURE_UPDATE_TIME, function() self:_RefreshSoilMoisture(TUNING.SOIL_MOISTURE_UPDATE_TIME) end)

self:WatchWorldState("season", OnSeasonChange)

end)
