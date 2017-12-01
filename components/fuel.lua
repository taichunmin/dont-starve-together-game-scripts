local function onfueltype(self, fueltype, old_fueltype)
    if old_fueltype ~= nil then
        self.inst:RemoveTag(old_fueltype.."_fuel")
    end
    if fueltype ~= nil then
        self.inst:AddTag(fueltype.."_fuel")
    end
end

local Fuel = Class(function(self, inst)
    self.inst = inst
    self.fuelvalue = 1
    self.fueltype = FUELTYPE.BURNABLE
    self.ontaken = nil
end,
nil,
{
    fueltype = onfueltype,
})

function Fuel:OnRemoveFromEntity()
    if self.fueltype ~= nil then
        self.inst:RemoveTag(self.fueltype.."_fuel")
    end
end

function Fuel:SetOnTakenFn(fn)
    self.ontaken = fn
end

function Fuel:Taken(taker)
    self.inst:PushEvent("fueltaken", {taker = taker})
    if self.ontaken then
        self.ontaken(self.inst, taker)
    end
end

return Fuel