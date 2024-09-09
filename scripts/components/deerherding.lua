
local UPDATE_RATE = 0.2
local ACTIVE_HERD_RADIUS = 25
local WALKING_OFFSET = 10

local INACTIVE_HERD_RADIUS = 35
local NUM_STRUCTURES_FOR_URBAN = 20
local STRUCTURES_FOR_URBAN_RADIUS = 10

local ROAMING_TIME = 20
local GRAZING_TIME = 20

local ROAMING_FORMATION_DIST = 5

local DeerHerding = Class(function(self, inst)
    self.inst = inst

    self.inst:StartUpdatingComponent(self)

	self.herdhomelocation = nil
    self.herdlocation = Vector3(0,0,0)
    self.herdheading = 0
    self.herdspawner = nil
    self.lastupdate = 0

	self.grazetimer = GRAZING_TIME
	self.isgrazing = false
	self.keepheading = nil

	self.grazing_time = GRAZING_TIME
	self.roaming_time = ROAMING_TIME

	--self.disable_spooked = false
	--self.valid_area_check = nil -- ! Use SetValidAareaCheckFn() to set this. A custom function to check if the target location is okay, if this function fails on all points then the deer will not get a new location...
	--self.force_keep_herd_together = false -- enable this if you don't want deer to leave the herd when too far away. This will have issues the deer can be walled in.

	self.alerttargets = {}
end)

function DeerHerding:Init(startingpt, herdspawner)
	self.herdhomelocation = startingpt
	self.herdlocation = startingpt
    self.herdspawner = herdspawner
end

function DeerHerding:SetValidAareaCheckFn(fn)
	self.valid_area_check = function(x, y, z) return fn(self.inst, x, y, z) end
end

function DeerHerding:CalcHerdCenterPoint(detailedinfo)
	local activedeer = {}
	local count = 0
	local center = Vector3(0,0,0)
	local facing = 0
	local max_dist = 3 -- minimum max dist is 3

	for k, _ in pairs(self.herdspawner:GetDeer()) do
		if k:IsValid() then
			local dist = k:GetDistanceSqToPoint(self.herdlocation:Get())
			if dist < ACTIVE_HERD_RADIUS * ACTIVE_HERD_RADIUS then
				center = center + k:GetPosition()
				count = count + 1

				if detailedinfo then
					table.insert(activedeer, k)
					facing = facing + k.Transform:GetRotation()
					max_dist = math.max(max_dist, dist)
				end
			end
		end
	end

	if count == 0 then
		return nil
	end

	return center / count, facing / count, max_dist, activedeer
end

function DeerHerding:UpdateHerdLocation(radius)
	local center, facing, max_dist, activedeer = self:CalcHerdCenterPoint(true)
	if center == nil then
		return
	end

	--not moving herd, too many members are far away
	if not self.isspooked and distsq(center, self.herdlocation) > radius * 2.8 then
		return
	end

	-- psudo flocking
	max_dist = math.sqrt(max_dist)
	for i,v in ipairs(activedeer) do
		local offset = ((v:GetPosition() - center) / max_dist) * ROAMING_FORMATION_DIST
		v.components.knownlocations:RememberLocation("herdoffset", offset)
	end

	if self.keepheading then
		facing = self.herdheading
	end
	facing = GetRandomWithVariance(facing, 50)

	local result_offset, result_angle, deflected = FindWalkableOffset(center, facing*DEGREES, radius, 8, true, false, self.valid_area_check) -- try avoiding walls
	if result_angle == nil then
		result_offset, result_angle, deflected = FindWalkableOffset(center, facing*DEGREES, radius, 8, true, true, self.valid_area_check) -- ok don't try to avoid walls, but at least avoid water
	end

	if result_angle ~= nil then
		self.herdlocation = center + result_offset
		self.herdheading = result_angle / DEGREES
	end

	for i,v in ipairs(activedeer) do
		if v.brain ~= nil then
			v.brain:ForceUpdate()
		end
	end

end

function DeerHerding:IsActiveInHerd(deer)
	return self.herdspawner ~= nil and self.herdspawner:GetDeer()[deer] and true or false
end

local STRUCTURES_CANT_TAGS = { "INLIMBO", "fire", "burnt" }
local STRUCTURES_ONEOF_TAGS = { "wall", "structure" }
local SALTLICK_MUST_TAGS = { "saltlick" }
local SALTLICK_CANT_TAGS = { "INLIMBO", "fire", "burnt" }

function DeerHerding:UpdateDeerHerdingStatus()
	local herd_center = self:CalcHerdCenterPoint()

	local alldeer = self.herdspawner:GetDeer()
	for deer, wasactive in pairs(alldeer) do
		local isactive = true
		if not deer:IsValid() then
			isactive = false
		else
		    local x, y, z = deer.Transform:GetWorldPosition()
			if (herd_center == nil or deer:GetDistanceSqToPoint(herd_center) > (INACTIVE_HERD_RADIUS * INACTIVE_HERD_RADIUS))
				or #(TheSim:FindEntities(x, y, z, STRUCTURES_FOR_URBAN_RADIUS, nil, STRUCTURES_CANT_TAGS, STRUCTURES_ONEOF_TAGS)) > NUM_STRUCTURES_FOR_URBAN
				or #(TheSim:FindEntities(x, y, z, TUNING.SALTLICK_CHECK_DIST, SALTLICK_MUST_TAGS, SALTLICK_CANT_TAGS)) > 0
				then

				isactive = false
			end
		end

		if isactive ~= wasactive then
			alldeer[deer] = isactive
		end
	end
end

function DeerHerding:CalcIsHerdSpooked()
	if self.disable_spooked then
		return false
	end

	for deer, _ in pairs(self.herdspawner:GetDeer()) do
		if deer:IsValid() and self:IsActiveInHerd(deer) then
			if deer.components.health.takingfiredamage
				or deer.components.combat:HasTarget()
				or (deer.components.hauntable and deer.components.hauntable.panic)
				then

				return true
			end
		end
	end

	return false
end

function DeerHerding:IsAnyEntityAsleep()
	for deer, isactive in pairs(self.herdspawner:GetDeer()) do
		if isactive and deer:IsAsleep() then
			return true
		end
	end
	return false
end


function DeerHerding:OnUpdate(dt)
	if self.herdspawner == nil then
		return
	end

	local curtime = GetTime()

	local was_spooked = self.isspooked
	self.isspooked = self:CalcIsHerdSpooked()

	if not self.isspooked then
		if not self.isgrazing and self:IsAnyEntityAsleep() then
			self.isgrazing = true
		end
		self.grazetimer = self.grazetimer - dt
		if self.grazetimer <= 0 then
			self.isgrazing = not self.isgrazing or self:IsAnyEntityAsleep()
			self.grazetimer = self.isgrazing and self.grazing_time or self.roaming_time
		end
	else
		if was_spooked ~= self.isspooked then
			self.isgrazing = false
			self.grazetimer = self.roaming_time * 0.5
			self.lastupdate = curtime
		end
	end

	if curtime - self.lastupdate < UPDATE_RATE then
		return
	end
	self.lastupdate = curtime + math.random() * 2

	if not self.force_keep_herd_together then
		self:UpdateDeerHerdingStatus()
	end

	if self.isspooked then
		local herd_center = self:CalcHerdCenterPoint()
		if herd_center ~= nil then
			local x, y, z = herd_center:Get()
			local threats = FindPlayersInRange(x, y, z, TUNING.DEER_HERD_MOVE_DIST * 2)
			if #threats > 0 then
				local spookdir = Vector3(0,0,0)
				for i,v in ipairs(threats) do
					spookdir = spookdir + v:GetPosition()
				end
				spookdir = spookdir / #threats

				self.herdheading = math.atan2(spookdir.z - herd_center.z, herd_center.x - spookdir.x)/DEGREES
			end

			self.keepheading = true

			self:UpdateHerdLocation(TUNING.DEER_HERD_MOVE_DIST * 2)
			--print (" ???", self.herdlocation, herd_center + (spookdir * TUNING.DEER_HERD_MOVE_DIST * 2))
		end
	elseif not self.isgrazing then
		self:UpdateHerdLocation(TUNING.DEER_HERD_MOVE_DIST)
		self.keepheading = false
	end

end

function DeerHerding:IsGrazing()
	return self.isgrazing
end

function DeerHerding:SetHerdAlertTarget(deer, target)
	if self.herdspawner ~= nil and self.herdspawner:GetDeer()[deer] then
		self.alerttargets[deer] = target

		if next(self.alerttargets) == nil then
			self.keepheading = true
		end
	else
		self.alerttargets[deer] = nil
	end
end

function DeerHerding:GetClosestHerdAlertTarget(deer)
	local closest = nil
	local closest_dist = 500
	for k,v in pairs(self.alerttargets) do
		if v:IsValid() then
			local dist = deer:GetDistanceSqToInst(v)
			if dist < closest_dist then
				closest_dist = dist
				closest = v
			end
		end
	end
	return closest
end

function DeerHerding:HerdHasAlertTarget()
	return next(self.alerttargets) ~= nil
end

function DeerHerding:IsAHerdAlertTarget(target)
	for k,v in pairs(self.alerttargets) do
		if v == target then
			return true
		end
	end
	return false
end

function DeerHerding:OnSave()
	if self.herdspawner == nil then
		return nil
	end

	local data = {}
	data.herdhomelocation = self.herdhomelocation ~= nil and {x=self.herdhomelocation.x, z=self.herdhomelocation.z} or nil
	data.herdlocation = {x=self.herdlocation.x, z=self.herdlocation.z}
	data.grazetimer = self.grazetimer
	data.isgrazing = self.isgrazing
	return data
end

function DeerHerding:OnLoad(data)
	if data ~= nil then
		self.herdlocation = Vector3(data.herdlocation.x, 0, data.herdlocation.z)
		self.herdhomelocation = data.herdhomelocation ~= nil and Vector3(data.herdhomelocation.x, 0, data.herdhomelocation.z) or nil
		self.grazetimer = data.grazetimer
		self.isgrazing = data.isgrazing
	end
end

function DeerHerding:LoadPostPass(newents, data)
	if self.herdspawner == nil then
		self.herdspawner = TheWorld.components.deerherdspawner
	end
end

function DeerHerding:GetDebugString()
	local s = ""
	if self.herdspawner ~= nil then
	    s = s .. string.format("%s: %.2f : %s, %s", self.isgrazing and "Grazing" or "Roaming", self.grazetimer, tostring(GetTableSize(self.alerttargets)), self.isspooked and "sooked" or "not spooked")
	    if self:IsAnyEntityAsleep() then
			s = s .. " Some Entity is asleep"
	    end
	else
		s = s .. "Dormant: Waiting for deer."
	end
	return s
end


return DeerHerding
