local HullHealth = Class(function(self, inst)
    self.inst = inst

	self.inst:ListenForEvent("on_collide", function(inst,data) self:OnCollide(data) end)

	self.leak_point_count = 6
	self.leak_radius = 2.5
	self.leak_radius_variance = 1
	self.leak_angle_variance = math.pi / 8

	self.leak_damage = {}
	self.leak_indicators = {}
	self.leak_indicators_dynamic = {}
	self.small_leak_dmg = 0.1
	self.med_leak_dmg = 0.75
	self.hull_dmg = 0

	for leak_idx = 1, self.leak_point_count do
		self.leak_damage[leak_idx] = 0
		self.leak_indicators[leak_idx] = nil
	end

	self.inst:DoPeriodicTask(1, function(inst) self:UpdateHealth() end)
end)

function HullHealth:UpdateHealth()
	if self.inst.components.health:IsDead() then return end

	if TheWorld.Map:IsVisualGroundAtPoint(self.inst.Transform:GetWorldPosition()) then
		self.inst.components.health:Kill()
	end

	local hull_damage = 0
	for k,v in pairs(self.leak_indicators) do
		if v ~= nil and v:IsValid() then
			local state = v.components.boatleak.current_state
			if state == "small_leak" then
				hull_damage = hull_damage + 0.5
			elseif state == "med_leak" then
				hull_damage = hull_damage + 1
			end
		end
	end
	for _,v in pairs(self.leak_indicators_dynamic) do
		if v ~= nil and v:IsValid() then
			local state = v.components.boatleak.current_state
			if state == "small_leak" then
				hull_damage = hull_damage + 0.5
			elseif state == "med_leak" then
				hull_damage = hull_damage + 1
			end
		end
	end

	self.inst.components.health:DoDelta(-hull_damage)

	if hull_damage > 0 then
		self.inst:AddTag("is_leaking")
	else
		self.inst:RemoveTag("is_leaking")
	end
end

function HullHealth:GetLeakPosition(idx)
	local angle = GetRandomWithVariance(self:GetLeakAngle(idx), self.leak_angle_variance)
	local boat_x, boat_y, boat_z = self.inst.Transform:GetWorldPosition()
	local pos_x, pos_z = math.cos(angle) * self.leak_radius, math.sin(angle) * GetRandomWithVariance(self.leak_radius, self.leak_radius_variance)
	return pos_x + boat_x, pos_z + boat_z
end

function HullHealth:GetLeakAngle(idx)
	return idx * math.pi * 2 / self.leak_point_count
end

function HullHealth:RefreshLeakIndicator(leak_idx)
	local leak_damage = self.leak_damage[leak_idx]
	if leak_damage >= self.small_leak_dmg then
		local leak_indicator = self.leak_indicators[leak_idx]
		if leak_indicator == nil then
			leak_indicator = SpawnPrefab("boat_leak")
			local leak_x, leak_z = self:GetLeakPosition(leak_idx)
			leak_indicator.Transform:SetPosition(leak_x, 0, leak_z)
			self.leak_indicators[leak_idx] = leak_indicator
			leak_indicator.components.boatleak:SetBoat(self.inst)
		end

		if leak_damage >= self.med_leak_dmg then
			leak_indicator.components.boatleak:SetState("med_leak")
		else
			leak_indicator.components.boatleak:SetState("small_leak")
		end
		return true
	end
	return false
end

local THROAWAY_ALIGNMENT_VALUE = 0.258 -- math.cos(75 degrees)
function HullHealth:OnCollide(data)
	local boat_x, boat_y, boat_z = self.inst.Transform:GetWorldPosition()
	local hit_pos_x, hit_pos_z = data.world_position_on_a_x, data.world_position_on_a_z
	local boat_to_hit_x, boat_to_hit_z = VecUtil_Normalize(hit_pos_x - boat_x, hit_pos_z - boat_z)
	local hit_angle = VecUtil_GetAngleInRads(boat_to_hit_x, boat_to_hit_z)

	local delta_angle = math.pi * 2
	local leak_idx = 1
	for k = 1,6 do
		local leak_angle = self:GetLeakAngle(k)
		local leak_delta_angle = math.abs(leak_angle - hit_angle)
		if leak_delta_angle > math.pi then
			leak_delta_angle = math.pi * 2 - leak_delta_angle
		end

		if leak_delta_angle < delta_angle then
			leak_idx = k
			delta_angle = leak_delta_angle
		end
	end

    local absolute_hit_normal_overlap_percentage = math.abs(data.hit_dot_velocity)

	local damage_alignment = absolute_hit_normal_overlap_percentage/(data.speed_damage_factor or 1)

    -- This functionally throws away every collision where the hit normal is about 60 degrees away from our velocity normal.
    -- Helps give the 'grazing' effect.
	if damage_alignment > THROAWAY_ALIGNMENT_VALUE then
		local boat_physics = self.inst.components.boatphysics

        local hit_adjacent_speed = boat_physics:GetVelocity() * absolute_hit_normal_overlap_percentage

		if hit_adjacent_speed > 2 then
			local leak_dmg = self.leak_damage[leak_idx]

			if leak_dmg < 1 then
				local damage_applied = math.min(hit_adjacent_speed - 2, 1 - leak_dmg)
				leak_dmg = leak_dmg + damage_applied
				self.leak_damage[leak_idx] = leak_dmg
			end

			if self:RefreshLeakIndicator(leak_idx) and self.inst.components.walkableplatform ~= nil then
	            for k in pairs(self.inst.components.walkableplatform:GetPlayersOnPlatform()) do
	                k:PushEvent("on_standing_on_new_leak")
	            end
			end
		end

        if hit_adjacent_speed > TUNING.BOAT.OARS.MALBATROSS.FORCE then
            local velocity_damage_percent = math.min(hit_adjacent_speed / TUNING.BOAT.MAX_ALLOWED_VELOCITY, 1)
		    self.inst.components.health:DoDelta(-1 * math.floor(TUNING.BOAT.MAX_HULL_HEALTH_DAMAGE * velocity_damage_percent))
        end
	end
end

function HullHealth:OnSave()
    local leaks = {}
    for k,leak in pairs(self.leak_indicators) do
        if leak ~= nil and leak:IsValid() then
            table.insert(leaks, {
                leak_point = k,
                leak_damage = self.leak_damage[k],
                leak_state = leak.components.boatleak.current_state,
            })
        end
    end

    return (#leaks > 0 and { boat_leaks = leaks }) or nil
end

function HullHealth:LoadPostPass(newents, data)
    if data ~= nil and data.boat_leaks ~= nil then
        for i, leak_data in ipairs(data.boat_leaks) do
            self.leak_damage[leak_data.leak_point] = leak_data.leak_damage
            if self:RefreshLeakIndicator(leak_data.leak_point) then
                local leak_i = self.leak_indicators[leak_data.leak_point]
                leak_i.components.boatleak:SetState(leak_data.leak_state)
            end
        end
    end
end

return HullHealth
