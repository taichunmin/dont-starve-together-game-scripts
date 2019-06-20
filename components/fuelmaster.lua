local FuelMaster = Class(function(self, inst)
    self.inst = inst
    self.bonusmult = 1
    self.bonusfn = nil
end)

function FuelMaster:SetBonusMult(mult)
    self.bonusmult = mult
end

function FuelMaster:SetBonusFn(fn)
    self.bonusfn = fn
end

function FuelMaster:GetBonusMult(item, target)
    return (self.bonusfn ~= nil and self.bonusfn(self.inst, item, target) or 1) * self.bonusmult
end

return FuelMaster
