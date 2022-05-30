local function onremovematerial(self, material)
    self.inst:RemoveTag("work_"..material)
    self.inst:RemoveTag("health_"..material)
    self.inst:RemoveTag("freshen_"..material)
end

local function onrepairvalue(self)
    if self.repairmaterial ~= nil then
        onremovematerial(self, self.repairmaterial)
        if self.workrepairvalue > 0 then
            self.inst:AddTag("work_"..self.repairmaterial)
        end
        if self.healthrepairvalue > 0 or self.healthrepairpercent > 0 then
            self.inst:AddTag("health_"..self.repairmaterial)
        end
        if self.perishrepairpercent > 0 then
            self.inst:AddTag("freshen_"..self.repairmaterial)
        end
    end
end

local function onrepairmaterial(self, repairmaterial, old_repairmaterial)
    if old_repairmaterial ~= nil then
        onremovematerial(self, old_repairmaterial)
    end
    if repairmaterial ~= nil then
        onrepairvalue(self)
    end
end

local Repairer = Class(function(self, inst)
    self.inst = inst
    self.workrepairvalue = 0
    self.healthrepairvalue = 0
    self.healthrepairpercent = 0
    self.perishrepairpercent = 0
    self.repairmaterial = nil

    self.inst:AddTag("repairer")
end,
nil,
{
    workrepairvalue = onrepairvalue,
    healthrepairvalue = onrepairvalue,
    healthrepairpercent = onrepairvalue,
    perishrepairpercent = onrepairvalue,
    repairmaterial = onrepairmaterial,
})

function Repairer:OnRemoveFromEntity()
    if self.repairmaterial ~= nil then
        onremovematerial(self, self.repairmaterial)
    end
end

return Repairer
