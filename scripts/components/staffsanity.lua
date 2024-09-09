local StaffSanity = Class(function(self, inst)
    self.inst = inst
end)

function StaffSanity:SetMultiplier(mult)
    self.multiplier = mult
end

function StaffSanity:DoCastingDelta(amount)
    if self.inst.components.sanity then
        self.inst.components.sanity:DoDelta(amount * (self.multiplier or 1))
    end
end

return StaffSanity