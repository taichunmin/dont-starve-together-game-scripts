local FishingRod = Class(function(self, inst)
    self.inst = inst

    self._target = net_entity(inst.GUID, "fishingrod._target")
    self._hashookedfish = net_bool(inst.GUID, "fishingrod._hashookedfish")
    self._hascaughtfish = net_bool(inst.GUID, "fishingrod._hascaughtfish")
end)

function FishingRod:SetTarget(target)
    self._target:set(target)
end

function FishingRod:GetTarget()
    return self._target:value()
end

function FishingRod:SetHookedFish(hookedfish)
    self._hashookedfish:set(hookedfish ~= nil)
end

function FishingRod:HasHookedFish()
    return self._hashookedfish:value() and self._target:value() ~= nil
end

function FishingRod:SetCaughtFish(caughtfish)
    self._hascaughtfish:set(caughtfish ~= nil)
end

function FishingRod:HasCaughtFish()
    return self._hascaughtfish:value()
end

return FishingRod