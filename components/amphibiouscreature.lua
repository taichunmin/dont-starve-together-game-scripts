
local AmphibiousCreature = Class(function(self, inst)
	self.inst = inst
	self.tile = nil
	self.tileinfo = nil
	self.ontilechangefn = nil
	self.in_water = false
	self.onwaterchangefn = nil

	self.land_bank = nil
	self.ocean_bank = nil

	if not self.inst:IsAsleep() then
		self.inst:StartUpdatingComponent(self)
	end

end)

function AmphibiousCreature:OnEntitySleep()
	self.inst:StopUpdatingComponent(self)
end

function AmphibiousCreature:OnEntityWake()
	self.inst:StartUpdatingComponent(self)
end

function AmphibiousCreature:SetBanks(land, ocean)
	self.land_bank = land
	self.ocean_bank = ocean
end

function AmphibiousCreature:OnUpdate(dt)
	if self.inst.sg == nil or not self.inst.sg:HasStateTag("jumping") then
		local x, y, z = self.inst.Transform:GetWorldPosition()
		local is_on_land = TheWorld.Map:IsPassableAtPoint(x, y, z)

		if self.in_water == is_on_land then
			if is_on_land then
				self:OnExitOcean()
			else
				self:OnEnterOcean()
			end
		end
	end
end

function AmphibiousCreature:ShouldTransition(x, z)
	if self.in_water then
		return TheWorld.Map:IsVisualGroundAtPoint(x, 0, z)
	end

	return not TheWorld.Map:IsVisualGroundAtPoint(x, 0, z)
end

function AmphibiousCreature:OnEnterOcean()
	if not self.in_water then
		self.inst.AnimState:SetBank(self.ocean_bank)
		self.in_water = true
		self.inst:AddTag("swimming")
		if self.enterwaterfn then
			self.enterwaterfn(self.inst)
		end
	end
end

function AmphibiousCreature:OnExitOcean()
	if self.in_water then
		self.inst.AnimState:SetBank(self.land_bank)
		self.in_water = false
		self.inst:RemoveTag("swimming")
		if self.exitwaterfn then
			self.exitwaterfn(self.inst)
		end
	end
end

function AmphibiousCreature:SetOnTileChangeFn(fn)
--	self.ontilechangefn = fn
end

function AmphibiousCreature:SetOnWaterChangeFn(fn)
--	self.onwaterchangefn = fn
end

function AmphibiousCreature:SetEnterWaterFn(fn)
	self.enterwaterfn = fn
end

function AmphibiousCreature:SetExitWaterFn(fn)
	self.exitwaterfn = fn
end

function AmphibiousCreature:GetDebugString()
	return "in water: " .. tostring(self.in_water)
end

return AmphibiousCreature
