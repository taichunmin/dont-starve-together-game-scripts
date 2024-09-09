local Moisture = Class(function(self, inst)
    self.inst = inst

    self._iswet = net_bool(inst.GUID, "moisture._iswet")
end)

function Moisture:SetIsWet(iswet)
    self._iswet:set(iswet)
end

function Moisture:IsWet()
    return self._iswet:value()
end

return Moisture