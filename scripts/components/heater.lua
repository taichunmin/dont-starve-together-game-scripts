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

function Heater:SetShouldFalloff(should_falloff)
    self.stop_falloff = not should_falloff
end

function Heater:ShouldFalloff()
    return not self.stop_falloff
end

function Heater:SetHeatRadiusCutoff(radius_cutoff)
    self.radius_cutoff = radius_cutoff
end

function Heater:GetHeatRadiusCutoff()
    return self.radius_cutoff
end

function Heater:GetHeat(observer)
    return (self.heatfn ~= nil and self.heatfn(self.inst, observer))
        or self.heat
end

function Heater:GetEquippedHeat(observer)
    return (self.equippedheatfn ~= nil and self.equippedheatfn(self.inst, observer))
        or self.equippedheat
end

function Heater:GetCarriedHeat(observer)
	if self.carriedheatfn then
		return self.carriedheatfn(self.inst, observer), self.carriedheatmultiplier
    else
	    return self.carriedheat, self.carriedheatmultiplier
    end
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