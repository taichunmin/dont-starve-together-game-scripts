local function onrepairmaterial(self, repairmaterial, old_repairmaterial)
    if old_repairmaterial ~= nil then
        self.inst:RemoveTag("repairable_"..old_repairmaterial)
    end
    if repairmaterial ~= nil then
        self.inst:AddTag("repairable_"..repairmaterial)
    end
end

local function onhealthrepairable(self, healthrepairable)
    if healthrepairable then
        self.inst:AddTag("healthrepairable")
    else
        self.inst:RemoveTag("healthrepairable")
    end
end

local function onworkrepairable(self, workrepairable)
    if workrepairable then
        self.inst:AddTag("workrepairable")
    else
        self.inst:RemoveTag("workrepairable")
    end
end


local Repairable = Class(function(self, inst)
    self.inst = inst
    self.repairmaterial = nil
    self.healthrepairable = nil
    self.workrepairable = nil
    self.noannounce = nil
    self.checkmaterialfn = nil
    self.testvalidrepairfn = nil

    local workable = inst.components.workable
    if workable then
        self:SetWorkRepairable(workable.maxwork ~= nil and workable.workleft < workable.maxwork and workable.workable)
    end

    local health = inst.components.health
    if health then
        self:SetHealthRepairable(health.currenthealth < health.maxhealth)
    end
end,
nil,
{
    repairmaterial = onrepairmaterial,
    healthrepairable = onhealthrepairable,
    workrepairable = onworkrepairable,
})

function Repairable:SetHealthRepairable(repairable)
    self.healthrepairable = repairable
end

function Repairable:SetWorkRepairable(repairable)
    self.workrepairable = repairable
end

function Repairable:OnRemoveFromEntity()
    if self.repairmaterial ~= nil then
        self.inst:RemoveTag("repairable_"..self.repairmaterial)
    end
    if self.healthrepairable then
        self.inst:RemoveTag("healthrepairable")
    end
    if self.workrepairable then
        self.inst:RemoveTag("workrepairable")
    end
end

local NEEDSREPAIRS_THRESHOLD = 0.95 -- don't complain about repairs if we're basically full.

function Repairable:NeedsRepairs()
    if self.inst.components.health ~= nil then
        return self.inst.components.health:GetPercent() < NEEDSREPAIRS_THRESHOLD
    elseif self.inst.components.workable ~= nil and self.inst.components.workable.workleft ~= nil then
        return self.inst.components.workable.workable and self.inst.components.workable.workleft < self.inst.components.workable.maxwork * NEEDSREPAIRS_THRESHOLD
    elseif self.inst.components.perishable ~= nil and self.inst.components.perishable.perishremainingtime ~= nil then
        return self.inst.components.perishable.perishremainingtime < self.inst.components.perishable.perishtime * NEEDSREPAIRS_THRESHOLD
    end
    return false
end

function Repairable:Repair(doer, repair_item)
    if self.testvalidrepairfn and not self.testvalidrepairfn(self.inst, repair_item) then
        return false
    elseif repair_item.components.repairer == nil or self.repairmaterial ~= repair_item.components.repairer.repairmaterial then
        --wrong material
        return false
    elseif self.checkmaterialfn ~= nil then
        local success, reason = self.checkmaterialfn(self.inst, repair_item)
        if not success then
            return false, reason
        end
    end

    if self.inst.components.health ~= nil then
        if self.inst.components.health:GetPercent() >= 1 then
            return false
        end
        self.inst.components.health:DoDelta(repair_item.components.repairer.healthrepairvalue)
        self.inst.components.health:DoDelta(repair_item.components.repairer.healthrepairpercent * self.inst.components.health.maxhealth)
    elseif self.inst.components.workable ~= nil and self.inst.components.workable.workleft ~= nil then
        if not self.inst.components.workable.workable or self.inst.components.workable.workleft >= self.inst.components.workable.maxwork then
            return false
        end
        self.inst.components.workable:SetWorkLeft(self.inst.components.workable.workleft + repair_item.components.repairer.workrepairvalue)
    elseif self.inst.components.perishable ~= nil and self.inst.components.perishable.perishremainingtime ~= nil then
        if self.inst.components.perishable.perishremainingtime >= self.inst.components.perishable.perishtime then
            return false
        end
        self.inst.components.perishable:SetPercent(self.inst.components.perishable:GetPercent() + repair_item.components.repairer.perishrepairpercent)
    else
        --not repairable
        return false
    end

    if repair_item.components.repairer.boatrepairsound then
        self.inst.SoundEmitter:PlaySound(repair_item.components.repairer.boatrepairsound)
    end

    if repair_item.components.stackable ~= nil then
        repair_item.components.stackable:Get():Remove()
    else
        repair_item:Remove()
    end

    if self.onrepaired ~= nil then
        self.onrepaired(self.inst, doer, repair_item)
    end

    return true
end

return Repairable
