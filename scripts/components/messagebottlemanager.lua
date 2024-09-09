local messagebottletreasures = require("messagebottletreasures")

--------------------------------------------------------------------------
--[[ MessageBottleManager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "MessageBottleManager should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local BORDER_SCALE = .85 -- 0 < BORDER_SCALE < 1
local SPAWN_POINTS_PER_SIDE = 8
local SPAWN_OFFSET_ATTEMPTS = 8

local DOER_CHECK_RADIUS_SQ = 200*200 -- Minimum distance a treasure can spawn from the player using the message bottle
local ALLPLAYERS_CHECK_RADIUS_SQ = 50*50 -- Minimum distance from any player

local WATER_RADIUS_CHECK_BIAS = -4

local SHORE_CHECK_RADIUS = 2
local SHORE_CHECK_ATTEMPTS = 12

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
self.hermitcrab = nil -- Set from hermitcrab prefab
self.hermit_has_been_found_by = {}
self.active_treasure_hunt_markers = {}

self.player_has_used_a_bottle = {}

--Private
local treasure_spawn_positions = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function gettreasurespawnpointfromindex(ind)
	if treasure_spawn_positions[ind] == nil then
		local scaled_mapdim = TheWorld.Map:GetSize() * 2 * BORDER_SCALE
		local i = ind - (ind % 4)
		local c = ((i / 4) / SPAWN_POINTS_PER_SIDE) * 2 * scaled_mapdim - scaled_mapdim

		-- Spawn points are placed along a square inside the boundaries of the map. Once one point
		-- is calculated it's possible to figure out three more points relative to their respective
		-- sides of the square, which can be cached.
		treasure_spawn_positions[i] = Vector3(scaled_mapdim, 0, -c)
		treasure_spawn_positions[i + 1] = Vector3(-c, 0, scaled_mapdim)
		treasure_spawn_positions[i + 2] = Vector3(-scaled_mapdim, 0, -c)
		treasure_spawn_positions[i + 3] = Vector3(c, 0, -scaled_mapdim)
	end
	return treasure_spawn_positions[ind]
end

-- Returns a swimmable position at on offset from a spawn point given an index
local function getoffsetfromtreasurespawnpoint(point_ind, radius, attempts, doer)
	local pt = gettreasurespawnpointfromindex(point_ind)

	-- Checks for a point in the ocean around the given point
	local offset = FindSwimmableOffset(pt, math.random() * TWOPI, radius, attempts)
	if offset == nil then
		return nil
	end

	local x, y, z = pt.x + offset.x, pt.y + offset.y, pt.z + offset.z

	if doer ~= nil and doer:GetDistanceSqToPoint(x, y, z) <= DOER_CHECK_RADIUS_SQ then
		return nil
	end

	-- If a point was found a check is also made to make sure it's not right next to land
	if FindSwimmableOffset(Vector3(x, y, z), 0, SHORE_CHECK_RADIUS, SHORE_CHECK_ATTEMPTS) == nil then
		return nil
	end

	for _, v in ipairs(AllPlayers) do
		if v:GetDistanceSqToPoint(x, y, z) <= ALLPLAYERS_CHECK_RADIUS_SQ then
			return nil
		end
	end

	return offset
end

local function gettreasurepos(doer)
	local offset = nil
	local offset_radius = math.max(TheWorld.Map:GetSize() * (1 - BORDER_SCALE) + WATER_RADIUS_CHECK_BIAS, 0)

	if treasure_spawn_positions == nil then
		treasure_spawn_positions = {}
	end

	local point_total = SPAWN_POINTS_PER_SIDE * 4
	local ind = math.random(1, point_total)
	local i = ind
	while offset == nil and i <= point_total do
		offset = getoffsetfromtreasurespawnpoint(i, offset_radius, SPAWN_OFFSET_ATTEMPTS, doer)
		i = i + 1
	end
	if offset == nil then
		i = 1
		while offset == nil and i < ind do
			offset = getoffsetfromtreasurespawnpoint(i, offset_radius, SPAWN_OFFSET_ATTEMPTS, doer)
			i = i + 1
		end
	end

	local base_point = treasure_spawn_positions[i - 1]

	if not offset or not base_point then
		return false, "NO_VALID_SPAWN_POINT_FOUND"
	end

	return Vector3(
		base_point.x + offset.x,
		0,
		base_point.z + offset.z
		)
end

--------------------------------------------------------------------------
--[[ Event handlers ]]
--------------------------------------------------------------------------

local function AddMinimapMarker(treasure, data)
	if data.underwater_object ~= nil then
		if data.underwater_object.components.treasuremarked ~= nil then
			data.underwater_object.components.treasuremarked:TurnOn()
		end
	end

	treasure:RemoveEventCallback("on_submerge", AddMinimapMarker)
end

local function OnMarkerAdded(worldinst, marker)
	worldinst.components.messagebottlemanager.active_treasure_hunt_markers[marker] = true
end

local function OnMarkerRemoved(worldinst, marker)
	worldinst.components.messagebottlemanager.active_treasure_hunt_markers[marker] = nil
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self.inst:ListenForEvent("messagebottletreasure_marker_added", OnMarkerAdded)
self.inst:ListenForEvent("messagebottletreasure_marker_removed", OnMarkerRemoved)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetHermitCrab()
	return self.hermitcrab ~= nil and self.hermitcrab:IsValid() and self.hermitcrab or nil
end

function self:SetPlayerHasFoundHermit(player)
	self.hermit_has_been_found_by[player.userid] = true
end

function self:GetPlayerHasFoundHermit(player)
	return self.hermit_has_been_found_by[player.userid]
end

function self:SetPlayerHasUsedABottle(player)
	self.player_has_used_a_bottle[player.userid] = true
end

function self:GetPlayerHasUsedABottle(player)
	return self.player_has_used_a_bottle[player.userid]
end

function self:UseMessageBottle(bottle, doer, is_not_from_hermit)
	local hermitcrab = self:GetHermitCrab()

	if not is_not_from_hermit and hermitcrab ~= nil and not self:GetPlayerHasFoundHermit(doer) then
		return hermitcrab:GetPosition()--, reason=nil
	else
		local pos, reason
		local num_active_hunts = GetTableSize(self.active_treasure_hunt_markers)

		if num_active_hunts < TUNING.MAX_ACTIVE_TREASURE_HUNTS then
			pos, reason = gettreasurepos(doer)

			if pos and pos.x ~= nil then
				local treasure = messagebottletreasures.GenerateTreasure(pos)
				treasure.Transform:SetPosition(pos.x, pos.y, pos.z)
				treasure:ListenForEvent("on_submerge", AddMinimapMarker)
			end

			return pos, reason
		else
			local active_hunt = nil

			-- Iterate in random order
			local rand = math.random(TUNING.MAX_ACTIVE_TREASURE_HUNTS)
			for i = 1, TUNING.MAX_ACTIVE_TREASURE_HUNTS do
				local ind = ((i + rand) % TUNING.MAX_ACTIVE_TREASURE_HUNTS) + 1

				local keys = {}
				for k, v in pairs(self.active_treasure_hunt_markers) do
					table.insert(keys, k)
				end
				active_hunt = keys[ind]

				if active_hunt ~= nil and active_hunt:IsValid() then
					return active_hunt:GetPosition()--, reason=nil
				else
					self.active_treasure_hunt_markers[keys[ind]] = nil
				end
			end

			return nil, "STALE_ACTIVE_HUNT_REFERENCES"
		end
	end
end

--------------------------------------------------------------------------
--[[ Save / Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	local data = {}

	if next(self.hermit_has_been_found_by) ~= nil then
		data.hermit_has_been_found_by = self.hermit_has_been_found_by
	end

	if next(self.player_has_used_a_bottle) ~= nil then
		data.player_has_used_a_bottle = self.player_has_used_a_bottle
	end

    return data
end

function self:OnLoad(data)
	if data ~= nil then
		if data.hermit_has_been_found_by ~= nil and next(data.hermit_has_been_found_by) ~= nil then
			for k, v in pairs(data.hermit_has_been_found_by) do
				self.hermit_has_been_found_by[k] = true
			end
		end

		if data.player_has_used_a_bottle ~= nil and next(data.player_has_used_a_bottle) ~= nil then
			for k, v in pairs(data.player_has_used_a_bottle) do
				self.player_has_used_a_bottle[k] = true
			end
		end
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

-- function self:GetDebugString()
-- end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
