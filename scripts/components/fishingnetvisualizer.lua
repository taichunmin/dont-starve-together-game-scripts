local FishingNetVisualizer = Class(function(self, inst)
    self.inst = inst
    self.velocity = 10
    self.retrieve_velocity = 12
    self.collect_radius = 2
    self.collect_velocity = 4
    self.retrieve_distance = 1.5
    self.distance_to_play_open_anim = 1.65
    self.has_played_throw_pst = false
    self.max_captured_entity_collect_distance = 0.25
    self.captured_entities = {}
    self.captured_entities_collect_distance = {}
    self.retrieve_distance_traveled = 0
end)

function FishingNetVisualizer:BeginCast(thrower, target_x, target_z)
	self.thrower = thrower
	local thrower_x, thrower_y, thrower_z = thrower.Transform:GetWorldPosition()
	self.inst.Transform:SetPosition(thrower_x, 0, thrower_z)

	local travel_vec_x, travel_vec_z = VecUtil_Sub(target_x, target_z, thrower_x, thrower_z)
    local spawn_distance = 0.5
	self.distance_remaining = math.max(VecUtil_Length(travel_vec_x, travel_vec_z) - spawn_distance, 0)

	self.total_distance = self.distance_remaining + spawn_distance

	self.dir_x, self.dir_z = VecUtil_Normalize(VecUtil_Sub(target_x, target_z, thrower_x, thrower_z))
    self.target_x = target_x
    self.target_z = target_z

    --TODO(YOG): Fix me
    self.thrower.AnimState:Hide("ARM_carry")
    self.thrower.AnimState:Show("ARM_normal")
    self.thrower:FacePoint(target_x, 0, target_z)
end

function FishingNetVisualizer:UpdateWhenMovingToTarget(dt)
	local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
	local distance_traveled = dt * self.velocity
	self.distance_remaining = self.distance_remaining or 0 -- just add this to stop a crash that modds were causing
	if distance_traveled >= self.distance_remaining then
		distance_traveled = self.distance_remaining

		self.distance_remaining = 0

		self.inst:PushEvent("begin_opening")
	else
		self.distance_remaining = self.distance_remaining - distance_traveled
	end

    if not self.has_played_throw_pst and self.distance_remaining <= self.distance_to_play_open_anim then
        self.inst:PushEvent("play_throw_pst")
        self.has_played_throw_pst = true
    end

	if self.total_distance == nil then
		-- adding this here to stop mods from crashing, no idea if this is rigth or not, but we arent using this thing anyway...
		self.total_distance = self.distance_remaining
	end
	local y = self:CalculateY(self.total_distance - self.distance_remaining - self.total_distance * 0.5, self.total_distance, 0.2)

	if distance_traveled > 0 then
		my_x, my_z = VecUtil_Add(my_x, my_z, VecUtil_Scale(self.dir_x or 1, self.dir_z or 0, distance_traveled))
	end
	self.inst.Transform:SetPosition(my_x, y, my_z)
end

function FishingNetVisualizer:CalculateY(x, x_span, scale)
	local x_intersect = x_span * 0.5
	return ((x * x) - x_intersect * x_intersect) * -scale
end

function FishingNetVisualizer:UpdateWhenOpening(dt)
	local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    for i, v in ipairs(self.captured_entities) do
    	if v:IsValid() then
    		local accumulated_collect_distance = self.captured_entities_collect_distance[v]

    		if accumulated_collect_distance < self.max_captured_entity_collect_distance then

				local entity_position_x, entity_position_y, entity_position_z = v.Transform:GetWorldPosition()
				local delta_x, delta_z = VecUtil_Normalize(my_x - entity_position_x, my_z - entity_position_z)
				local collect_distance = self.collect_velocity * dt

				delta_x, delta_z = delta_x * collect_distance, delta_z * collect_distance

		        local physics = v.Physics
		        if physics ~= nil then
		            physics:TeleportOffset(delta_x, 0, delta_z)
		        else
				    v.Transform:OffsetPosition(delta_x, 0, delta_z)
		        end

		        self.captured_entities_collect_distance[v] = accumulated_collect_distance + collect_distance
	    	end
    	end
    end
end

function FishingNetVisualizer:BeginOpening()
    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(my_x,my_y,my_z, self.collect_radius + TUNING.MAX_FISH_SCHOOL_SIZE)
    for k,v in pairs(entities) do
    	v:PushEvent("on_pre_net", self.inst)
    end

    entities = TheSim:FindEntities(my_x,my_y,my_z, self.collect_radius)
    for k,v in pairs(entities) do
    	if v ~= self.inst and v.components.inventoryitem ~= nil then
    		table.insert(self.captured_entities, v)
            self.captured_entities_collect_distance[v] = 0
        end
    end
end

function FishingNetVisualizer:DropItem(item, last_dir_x, last_dir_z, idx)

    local thrower_x, thrower_y, thrower_z = self.thrower.Transform:GetWorldPosition()

    local time_between_drops = 0.25
    local initial_delay = 0.15
    item:DoTaskInTime(idx * time_between_drops + initial_delay, function(inst)

        item:ReturnToScene()
        item:PushEvent("on_release_from_net")

        local drop_vec_x = TheCamera:GetRightVec().x
        local drop_vec_z = TheCamera:GetRightVec().z

        local camera_up_vec_x, camera_up_vec_z = -TheCamera:GetDownVec().x, -TheCamera:GetDownVec().z

        if VecUtil_Dot(last_dir_x, last_dir_z, drop_vec_x, drop_vec_z) < 0 then
            drop_vec_x = -drop_vec_x
            drop_vec_z = -drop_vec_z
        end

        local up_offset_dist = 0.1

        local drop_offset = GetRandomWithVariance(1, 0.2)
        local pt_x = drop_vec_x * drop_offset + thrower_x + camera_up_vec_x * up_offset_dist
        local pt_z = drop_vec_z * drop_offset + thrower_z + camera_up_vec_z * up_offset_dist

        local physics = item.Physics
        if physics ~= nil then
            local drop_height = GetRandomWithVariance(0.65, 0.2)
            local pt_y = drop_height + thrower_y
            item.Transform:SetPosition(pt_x, pt_y, pt_z)
            physics:SetVel(0, -0.25, 0)
        else
            item.Transform:SetPosition(pt_x, 0, pt_z)
        end
    end)

end

function FishingNetVisualizer:BeginRetrieving()

    self.thrower:PushEvent("begin_retrieving")
    for k,v in pairs(self.captured_entities) do

        if v:IsValid() then
            v:RemoveFromScene()
        end
    end
end

function FishingNetVisualizer:BeginFinalPickup()

    self.thrower:PushEvent("begin_final_pickup")

    local thrower_x, thrower_y, thrower_z = self.thrower.Transform:GetWorldPosition()
    local idx = 0
    for k,v in pairs(self.captured_entities) do

        self:DropItem(v, self.last_dir_x, self.last_dir_z, idx)
        idx = idx + 1
    end

    --TODO(YOG): Fix me
    self.thrower.AnimState:Show("ARM_carry")
    self.thrower.AnimState:Hide("ARM_normal")

    self.inst:Remove()
end

function FishingNetVisualizer:UpdateWhenRetrieving(dt)
	local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
	local thrower_x, thrower_y, thrower_z = self.thrower.Transform:GetWorldPosition()
	local distance_traveled = dt * self.retrieve_velocity

    self.retrieve_distance_traveled = self.retrieve_distance_traveled + distance_traveled

	local dir_x, dir_z = thrower_x - my_x, thrower_z - my_z
	local dir_length = VecUtil_Length(dir_x, dir_z)
	local dir_x_normalized, dir_z_normalized = VecUtil_Scale(dir_x, dir_z, 1 / dir_length)
	local delta_x, delta_z = dir_x_normalized * distance_traveled, dir_z_normalized * distance_traveled

    local y = self:CalculateY(self.retrieve_distance_traveled- self.total_distance * 0.5, self.total_distance, 0.15)

	if distance_traveled >= dir_length or dir_length <= self.retrieve_distance then
		self.inst:PushEvent("begin_final_pickup")


        self.last_dir_x, self.last_dir_z = -dir_x_normalized, -dir_z_normalized
	else
		my_x, my_z = my_x + delta_x, my_z + delta_z
		self.inst.Transform:SetPosition(my_x, y, my_z)
	end
end

return FishingNetVisualizer
