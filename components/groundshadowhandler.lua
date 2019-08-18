local GroundShadowHandler = Class(function(self, inst)
    self.inst = inst    
    self.inst:StartUpdatingComponent(self)

    self.inst:ListenForEvent("onremove", function() self:OnRemove() end)
    self.ground_shadow = SpawnPrefab("groundshadow")    
end)

function GroundShadowHandler:SetSize(width, height)    
    self.original_width = width
    self.original_height = height
    self.ground_shadow.DynamicShadow:SetSize(width, height)
end

function GroundShadowHandler:OnUpdate(dt)    
	local pos_x, pos_y, pos_z = self.inst.Transform:GetWorldPosition()

	local max_lerp_height = 4

	local min_scale = 0.3
	local max_scale = 1

	local percent = math.min(pos_y / max_lerp_height, 1)
	percent = percent * percent

	local scale = Lerp(max_scale, min_scale, math.min(math.max(pos_y - 2, 1) / max_lerp_height, 1))

	self.ground_shadow.Transform:SetPosition(pos_x, 0, pos_z)
    self.ground_shadow.DynamicShadow:SetSize(self.original_width * scale, self.original_height * scale)
end

function GroundShadowHandler:OnRemove()
    self.ground_shadow:Remove()
end

return GroundShadowHandler
