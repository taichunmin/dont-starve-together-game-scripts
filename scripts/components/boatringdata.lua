local BoatRingData = Class(function(self, inst)
    self.inst = inst

    self.radius = 4
    self.segments = 8

    self._isrotating = net_bool(inst.GUID, "boatringdata._isrotating")
    self._isrotating:set(false)
end)

--------------------------------------------------------------------------
--Client & Server

function BoatRingData:GetRadius()
    return self.radius
end

function BoatRingData:SetRadius(radius)
    self.radius = radius
end

function BoatRingData:GetNumSegments()
    return self.segments
end

function BoatRingData:SetNumSegments(segments)
    self.segments = segments
end

function BoatRingData:IsRotating()
    return self._isrotating:value()
end

--------------------------------------------------------------------------
--Master Sim

function BoatRingData:SetIsRotating(isrotating)
    assert(TheWorld.ismastersim)
    self._isrotating:set(isrotating)
end

return BoatRingData
