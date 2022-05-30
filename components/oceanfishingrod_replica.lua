local OceanFishingRod = Class(function(self, inst)
    self.inst = inst

    self._target = net_entity(inst.GUID, "oceanfishingrod._hook")
    self._line_tension = net_tinybyte(inst.GUID, "oceanfishingrod._line_tension") --  [0..7]
    self._max_cast_dist = net_smallbyte(inst.GUID, "oceanfishingrod._max_cast_dist") --  [0..63]
end)

function OceanFishingRod:GetTarget()
	local target = self._target:value()
    return (target ~= nil and target:IsValid()) and target or nil
end

function OceanFishingRod:_SetTarget(target)
	self._target:set(target)
end

function OceanFishingRod:_SetLineTension(line_tension)
	self._line_tension:set( line_tension > TUNING.OCEAN_FISHING.LINE_TENSION_HIGH and 2
					or line_tension > TUNING.OCEAN_FISHING.LINE_TENSION_GOOD and 1
					or 0)
end

function OceanFishingRod:IsLineTensionHigh()
	return self._line_tension:value() == 2
end

function OceanFishingRod:IsLineTensionGood()
	return self._line_tension:value() == 1
end

function OceanFishingRod:IsLineTensionLow()
	return self._line_tension:value() == 0
end

function OceanFishingRod:SetClientMaxCastDistance(dist)
	self._max_cast_dist:set(math.floor(dist))
end

function OceanFishingRod:GetMaxCastDist()
	return self._max_cast_dist:value()
end

function OceanFishingRod:GetDebugString()
	return "Target: " .. tostring(self._target:value()) .. ", Tension: " .. (self:IsTensionHigh() and "High" or self:IsTensionGood() and "Good" or "Low")
end

return OceanFishingRod