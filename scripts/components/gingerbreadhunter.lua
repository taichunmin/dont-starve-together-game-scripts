local PLAYER_CHECK_DISTANCE = 40
local CRUMB_DISTANCE = 15
local GINGERWARG_CHANCE = 0.2

local GINGERBREADHOUSE_MIN = 2
local GINGERBREADHOUSE_MAX = 5

local MAX_SPAWN_ATTEMPTS = 20
local MAX_HUNT_COUNT = 3

local SPAWN_PERIOD = 3

local GingerbreadHunter = Class(function(self, inst)
    self.inst = inst
    self.hunt_count = 0
    self.crumb_pts = {}

    self.activeplayers = {}
    self.availableplayers = {}

    self.days = 0

    for i, player in ipairs(AllPlayers) do
    	self:OnPlayerJoined(player)
	end

	self.inst:ListenForEvent("ms_playerjoined", function(src, player) self:OnPlayerJoined(player) end, TheWorld)
	self.inst:ListenForEvent("ms_playerleft",   function(src, player) self:OnPlayerLeft(player)   end, TheWorld)
	self.inst:WatchWorldState("cycles", function() self:OnIsDay() end)

end)

function GingerbreadHunter:OnIsDay()

	self.days = self.days + 1
	if self.days >= SPAWN_PERIOD then
		if self.newhunttask then
			self.newhunttask:Cancel()
			self.newhunttask = nil
		end

		self.newhunttask = self.inst:DoTaskInTime(math.random() * TUNING.TOTAL_DAY_TIME / 2, function() self:StartNewHunt() end)
		self.days = 0
	end
end

function GingerbreadHunter:OnPlayerJoined(player)
    for i,v in ipairs(self.activeplayers) do
        if v == player then
            return
        end
    end

    table.insert(self.activeplayers, player)
    table.insert(self.availableplayers, player)
end

function GingerbreadHunter:OnPlayerLeft(player)
    for i,v in ipairs(self.activeplayers) do
        if v == player then
            table.remove(self.activeplayers, i)
            return
        end
    end

    for i,v in ipairs(self.availableplayers) do
        if v == player then
            table.remove(self.availableplayers, i)
            return
        end
    end
end

-- Merged get run angle into this
local function GetNextSpawnAngle(pt, radius)

    local base_angle = math.random() * PI
    local deviation = math.random(-TUNING.TRACK_ANGLE_DEVIATION, TUNING.TRACK_ANGLE_DEVIATION)*DEGREES
    local start_angle = base_angle + deviation

    local offset, result_angle = FindWalkableOffset(pt, start_angle, radius, 14, true, true)

    return result_angle
end

local function GetSpawnPoint(pt, radius)

	local angle = GetNextSpawnAngle(pt, radius)
	if angle then
	    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
	    local spawn_point = pt + offset
	    return spawn_point
	end

	return nil
end

function GingerbreadHunter:StartNewHunt()
	self.hunt_count = 0
	local succeeded = false
	local selected_index = -1
	local _availableplayers = shallowcopy(self.availableplayers)

	-- We select a random player and try to find a valid point to spawn the gingerbread near them
	-- If we fail all attempts we select a different player until we succeed or the list is empty
	while #_availableplayers > 0 and not succeeded do

		selected_index = math.random(#_availableplayers)
		local selected_player = table.remove(_availableplayers, selected_index)

		local origin_pt = selected_player:GetPosition()
		local attempts = 0

		while attempts < MAX_SPAWN_ATTEMPTS do
			local spawn_pt = GetSpawnPoint(origin_pt, PLAYER_CHECK_DISTANCE + 5)
			if spawn_pt and not IsAnyPlayerInRange(spawn_pt.x, 0, spawn_pt.z, PLAYER_CHECK_DISTANCE) then

				local gingerbreadpig = SpawnPrefab("gingerbreadpig")
				gingerbreadpig.Transform:SetPosition(spawn_pt:Get())

				gingerbreadpig.killtask = gingerbreadpig:DoTaskInTime(1.5 * TUNING.TOTAL_DAY_TIME, function() gingerbreadpig.components.health:Kill() end)
				gingerbreadpig.leash_target = selected_player

				succeeded = true
				break
			else
				attempts = attempts + 1
			end
		end
	end


	if succeeded then
		table.remove(self.availableplayers, selected_index)
	else
		print ("Hunt failed")
	end

	if #self.availableplayers == 0 or not succeeded then
		for i,v in ipairs(self.activeplayers) do
			table.insert(self.availableplayers, v)
		end
	end
end

function GingerbreadHunter:GenerateCrumbPoints(origin_pt, amount)
	self.crumb_pts = {}

	for i=1, amount do

		local attempts = 0
		while attempts < MAX_SPAWN_ATTEMPTS do
			local spawn_pt = GetSpawnPoint(origin_pt, CRUMB_DISTANCE)
			if spawn_pt and not IsAnyPlayerInRange(spawn_pt.x, 0, spawn_pt.z, PLAYER_CHECK_DISTANCE) then
				table.insert(self.crumb_pts, spawn_pt)
				origin_pt = spawn_pt
				break
			else
				attempts = attempts + 1
				if attempts >= MAX_SPAWN_ATTEMPTS then
					print ("Could not generate points")
					return false
				end
			end
		end
	end

	self.hunt_count = self.hunt_count + 1

	return true
end

function GingerbreadHunter:SpawnCrumbTrail(killtime)

	local house_positions =
    {
    	{ x =  0, 	z =  0 },
        { x =  1.5, z =  1.5 },
        { x = -1.5, z =  1.5 },
        { x =  1.5, z = -1.5 },
        { x = -1.5, z = -1.5 },
    }

	for i, pt in ipairs(self.crumb_pts) do
		if i == #self.crumb_pts then
			if self.hunt_count > MAX_HUNT_COUNT then
				local num_houses = 0
				if math.random() > GINGERWARG_CHANCE then
					local house_amount = math.random(GINGERBREADHOUSE_MIN, GINGERBREADHOUSE_MAX)
					for i = 1, house_amount do
						local x,y,z = pt:Get()
						x = x + house_positions[i].x + math.random(-0.5, 0.5)
						z = z + house_positions[i].z + math.random(-0.5, 0.5)

						if TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then
							local house = SpawnPrefab("gingerbreadhouse")
							house.Transform:SetPosition(x, y, z)
							num_houses = num_houses + 1
						end
					end
				end
				if num_houses == 0 then
					local warg = SpawnPrefab("gingerbreadwarg")
					warg.Transform:SetPosition(pt:Get())
				end
				self.hunt_count = 0
			else
				local gingerpig = SpawnPrefab("gingerbreadpig")
				gingerpig.Transform:SetPosition(pt:Get())
				gingerpig.chased = true
				gingerpig.killtask = gingerpig:DoTaskInTime(killtime, function() gingerpig.components.health:Kill() end)
			end
		else
			local crumbs = SpawnPrefab("crumbs")
			crumbs.Transform:SetPosition(pt:Get())
		end
	end
end

function GingerbreadHunter:OnSave()
	local data = { hunt_count = self.hunt_count, days = self.days }
	local ents = {}

	return data, ents
end

function GingerbreadHunter:Load(data, ents)
	if data.hunt_count then
		self.hunt_count = data.hunt_count
	end

	if data.days then
		self.days = data.days
	end
end

function GingerbreadHunter:LoadPostPass(newents, savedata)
end

return GingerbreadHunter