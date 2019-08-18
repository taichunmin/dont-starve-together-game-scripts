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
    local delta_x, delta_z = embark_x - my_x, embark_z - my_z
    local delta_dist = math.max(VecUtil_Length(delta_x, delta_z), 0.0001)    
    local travel_dist = self.embark_speed * dt    

    delta_x, delta_z = travel_dist * delta_x / delta_dist, travel_dist * delta_z / delta_dist
    self.inst.Physics:TeleportRespectingInterpolation(my_x + delta_x, my_y, my_z + delta_z)

    if delta_dist <= travel_dist then
        self.inst:PushEvent("done_embark_movement")
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
	self.inst.Physics:Stop()
    self.inst:StartWallUpdatingComponent(self)

    self.inst:PushEvent("start_embark_movement")
end

function Embarker:OnWallUpdate(dt)
    self:UpdateEmbarkingPos(dt)
end

function Embarker:HasDestination()
	return (self.embarkable ~= nil and self.embarkable:IsValid()) or self.disembark_x ~= nil 
end

function Embarker:GetEmbarkPosition()
    if self.embarkable ~= nil and self.embarkable:IsValid() then
        local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
        return self.embarkable.components.walkableplatform:GetEmbarkPosition(my_x, my_z)
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
	self.inst.components.locomotor.hopping = false
    --SendRPCToServer(RPC.FinishHop, self.inst, embark_x, embark_z)
    local embark_x, embark_z = self:GetEmbarkPosition()
	self.inst.Transform:SetPosition(embark_x, 0, embark_z)
    self.embarkable = nil    
    self.disembark_x = nil
    self.disembark_z = nil
    self.last_embark_x = nil
    self.last_embark_z = nil
    self.inst:StopWallUpdatingComponent(self)
end

function Embarker:Cancel()
	self.inst.components.locomotor.hopping = false
    self.embarkable = nil    
    self.disembark_x = nil
    self.disembark_z = nil
    self.last_embark_x = nil
    self.last_embark_z = nil
    self.inst:StopWallUpdatingComponent(self)    
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