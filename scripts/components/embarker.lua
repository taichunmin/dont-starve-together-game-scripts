local Embarker = Class(function(self, inst)
    self.inst = inst
    self.embarkable = nil
    self.start_x, self.start_y, self.start_z = self.inst.Transform:GetWorldPosition()
    self.embark_speed = 10
    self.last_embark_x = nil
    self.last_embark_z = nil
end)

function Embarker:UpdateEmbarkingPos(dt)
    local embark_x, embark_z = self:GetEmbarkPosition()
    self.last_embark_x, self.last_embark_z = embark_x, embark_z

    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
	local dir_x, dir_z = embark_x - my_x, embark_z - my_z
	local reaming_dist = VecUtil_Length(dir_x, dir_z)
    local frame_travel_dist = self.embark_speed * dt

	if reaming_dist <= frame_travel_dist then
		self.inst.Physics:TeleportRespectingInterpolation(embark_x, 0, embark_z)
        self.inst:PushEvent("done_embark_movement")
    else
		local dist_traveled_sq = VecUtil_DistSq(self.hop_start_pt.x, self.hop_start_pt.z, my_x, my_z)
		if dist_traveled_sq > self.max_hop_dist_sq then
			self:Cancel()
			self.inst:PushEvent("done_embark_movement")
		else
			self.inst.Transform:SetRotation(self.inst:GetAngleToPoint(embark_x, 0, embark_z)) -- seek to the embark point
			self.inst.Physics:SetMotorVel(self.embark_speed, 0, 0)
		end
    end
end

function Embarker:SetEmbarkable(embarkable)
    self.embarkable = embarkable
    self.last_embark_x, self.last_embark_z = self:GetEmbarkPosition()
    self.inst:ForceFacePoint(self.last_embark_x, 0, self.last_embark_z)

    self.disembark_x = nil
    self.disembark_z = nil
end

function Embarker:SetDisembarkPos(pos_x, pos_z)
    self.disembark_x, self.disembark_z = pos_x, pos_z


    self.inst:ForceFacePoint(self.disembark_x, 0, self.disembark_z)

    self.embarkable = nil
    self.last_embark_x = nil
    self.last_embark_z = nil
end

function Embarker:SetDisembarkActionPos(pos_x, pos_z)
    self.disembark_x, self.disembark_z = GetDisembarkPosAndDistance(self.inst, pos_x, pos_z)
end

function Embarker:StartMoving()
    if not self.max_hop_dist_sq then
        self.inst.Physics:Stop()
        self.inst:StartUpdatingComponent(self)

		self.max_hop_dist_sq = self.inst.components.locomotor:GetHopDistance(self.inst.components.locomotor:GetSpeedMultiplier()) * 1.5
		self.max_hop_dist_sq = self.max_hop_dist_sq * self.max_hop_dist_sq
		self.hop_start_pt = self.inst:GetPosition()

        self.inst:PushEvent("start_embark_movement")
    end
end

function Embarker:OnUpdate(dt)
    self:UpdateEmbarkingPos(dt)
end

function Embarker:HasDestination()
	return (self.embarkable ~= nil and self.embarkable:IsValid()) or self.disembark_x ~= nil
end

function Embarker:GetEmbarkPosition()
    if self.embarkable ~= nil and self.embarkable:IsValid() then
        local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
        return self.embarkable.components.walkableplatform:GetEmbarkPosition(my_x, my_z, self.embarker_min_dist)
    else
        local x, z = (self.disembark_x or self.last_embark_x), (self.disembark_z or self.last_embark_z)
        if x == nil or z == nil then
            local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
            x, z = my_x, my_z
        end
        return x, z
    end
end

function Embarker:Embark()
    self.inst.Physics:Stop()
	self.inst.components.locomotor.hopping = false
    --SendRPCToServer(RPC.FinishHop, self.inst, embark_x, embark_z)
    local embark_x, embark_z = self:GetEmbarkPosition()
	self.inst.Transform:SetPosition(embark_x, 0, embark_z)
    self.embarkable = nil
    self.disembark_x = nil
    self.disembark_z = nil
    self.last_embark_x = nil
    self.last_embark_z = nil
	self.max_hop_dist_sq = nil
	self.hop_start_pt = nil
    self.inst:StopUpdatingComponent(self)
end

function Embarker:Cancel()
    self.inst.Physics:Stop()
	self.inst.components.locomotor.hopping = false
    self.embarkable = nil
    self.disembark_x = nil
    self.disembark_z = nil
    self.last_embark_x = nil
    self.last_embark_z = nil
	self.max_hop_dist_sq = nil
	self.hop_start_pt = nil
    self.inst:StopUpdatingComponent(self)
end

function GetDisembarkPosAndDistance(inst, target_x, target_z)
    local disembark_distance = 4

    local doer_x, doer_y, doer_z = inst.Transform:GetWorldPosition()

    local delta_x, delta_z = VecUtil_Sub(doer_x, doer_z, target_x, target_z)
    local delta_length = VecUtil_Length(delta_x, delta_z)

    if delta_length < disembark_distance then
        return target_x, target_z, disembark_distance
    else
        local delta_norm_x, delta_norm_z = VecUtil_Scale(delta_x, delta_z, 1 / delta_length)
        local nearest_distance = delta_length - disembark_distance
        local vec_to_nearest_land_pos_x, vec_to_nearest_land_pos_z = VecUtil_Scale(delta_norm_x, delta_norm_z, nearest_distance)

        local nearest_land_pos_x, nearest_land_pos_z = VecUtil_Add(target_x, target_z, vec_to_nearest_land_pos_x, vec_to_nearest_land_pos_z)
        if TheWorld.Map:GetPlatformAtPoint(nearest_land_pos_x, nearest_land_pos_z) == nil and TheWorld.Map:IsAboveGroundAtPoint(nearest_land_pos_x, 0, nearest_land_pos_z) then
            return nearest_land_pos_x, nearest_land_pos_z, delta_length
        else
            return target_x, target_z, 0
        end
    end
end

return Embarker