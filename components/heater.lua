local Heater = Class(function(self, inst)
    self.inst = inst
    self.heat = nil
    self.heatfn = nil
	self.equippedheat = nil
	self.equippedheatfn = nil
	self.carriedheat = nil
	self.carriedheatfn = nil
	self.carriedheatmultiplier = 1
	self.exothermic = true
	self.endothermic = false

    --V2C: Recommended to explicitly add tag to prefab pristine state
	inst:AddTag("HASHEATER")
end)

function Heater:OnRemoveFromEntity()
    self.inst:RemoveTag("HASHEATER")
end

function Heater:SetThermics(exo, endo)
	self.exothermic = exo
	self.endothermic = endo
end

function Heater:IsEndothermic()
	return self.endothermic
end

function Heater:IsExothermic()
	return self.exothermic
end

function Heater:GetHeat(observer)
	if self.heatfn then
		return self.heatfn(self.inst, observer)
	end
	return self.heat
end

function Heater:GetEquippedHeat(observer)
	if self.equippedheatfn then
		return self.equippedheatfn(self.inst, observer)
	end
	return self.equippedheat
end

function Heater:GetCarriedHeat(observer)
	if self.carriedheatfn then
		return self.carriedheatfn(self.inst, observer), self.carriedheatmultiplier
	end
	return self.carriedheat, self.carriedheatmultiplier
end

function Heater:GetDebugString()
	return string.format("heat: %s carriedheat: %s equippedheat: %s EXO:%s ENDO:%s",
			self.heatfn and "<fn>" or self.heat or "<nil>",
			self.carriedheatfn and "<fn>" or self.carriedheat or "<nil>",
			self.equippedheatfn and "<fn>" or self.equippedheat or "<nil>",
			tostring(self:IsExothermic()),
			tostring(self:IsEndothermic()))
end

return Heater