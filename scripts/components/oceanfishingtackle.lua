


local OceanFishingTackle = Class(function(self, inst)
    self.inst = inst


--[[
	self.projectile_prefab = nil
	self.casting_data = {
		dist_max = 5,
		max_dist_offset = 1,
		max_angle_offset = 20,
	}
]]

end)

function OceanFishingTackle:SetCastingData(data, projectile_prefab)
	self.casting_data = data
	self.projectile_prefab = projectile_prefab
end

function OceanFishingTackle:SetupLure(data)
	self.lure_data = data.lure_data
	self.lure_setup = data
end

function OceanFishingTackle:IsSingleUse()
	return self.lure_setup ~= nil and self.lure_setup.single_use or false
end

return OceanFishingTackle