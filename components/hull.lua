local Hull = Class(function(self, inst)
    self.inst = inst
end)

function Hull:FinishRemovingEntity(entity)
    if entity:IsValid() then
        entity:Remove()
    end
end

function Hull:AttachEntityToBoat(obj, offset_x, offset_z, parent_to_boat)
	obj:ListenForEvent("onremove", function() self:FinishRemovingEntity(obj) end, self.inst)

    if parent_to_boat then
    	obj.entity:SetParent(self.inst.entity)
    	obj.Transform:SetPosition(offset_x, 0, offset_z)
	else
		self.inst:DoTaskInTime(0, function(boat)
    		local boat_x, boat_y, boat_z = boat.Transform:GetWorldPosition()
			obj.Transform:SetPosition(boat_x + offset_x, boat_y, boat_z + offset_z)
		end)
	end
end

function Hull:SetPlank(obj)
    self.plank = obj
end

function Hull:SetBoatLip(obj)
	self.boat_lip = obj
	self.inst:AddPlatformFollower(obj)
	self:AttachEntityToBoat(obj, 0, 0)
end

function Hull:SetRadius(radius)
	self.radius = radius
end

function Hull:GetRadius(radius)
    return self.radius
end

function Hull:OnDeployed()
	self.boat_lip.AnimState:PlayAnimation("place_lip")
	self.boat_lip.AnimState:PushAnimation("lip", true)
    self.plank:Hide()
    self.plank:DoTaskInTime(1.25, function() self.plank:Show() self.plank.AnimState:PlayAnimation("plank_place") end)
end

return Hull
