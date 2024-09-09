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

local function onfiniteusesrepairable(self, finiteusesrepairable)
    if finiteusesrepairable then
        self.inst:AddTag("finiteusesrepairable")
    else
        self.inst:RemoveTag("finiteusesrepairable")
    end
end


local Repairable = Class(function(self, inst)
    self.inst = inst
    self.repairmaterial = nil
    self.healthrepairable = nil
    self.workrepairable = nil
    self.finiteusesrepairable = nil
    self.noannounce = nil
    self.checkmaterialfn = nil
    self.testvalidrepairfn = nil

    local workable = inst.components.workable
    if workable then
        self:SetWorkRepairable(workable.workable and workable.maxwork ~= nil and workable.workleft < workable.maxwork)
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
    finiteusesrepairable = onfiniteusesrepairable,
    workrepairable = onworkrepairable,
})

function Repairable:SetHealthRepairable(repairable)
    self.healthrepairable = repairable
end

function Repairable:SetWorkRepairable(repairable)
    self.workrepairable = repairable
end

function Repairable:SetFiniteUsesRepairable(repairable)
    self.finiteusesrepairable = repairable
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
    if self.finiteusesrepairable then
        self.inst:RemoveTag("finiteusesrepairable")
    end
end

local NEEDSREPAIRS_THRESHOLD = 0.95 -- don't complain about repairs if we're basically full.

function Repairable:NeedsRepairs()
    if self.inst.components.health ~= nil then
        return self.inst.components.health:GetPercent() < NEEDSREPAIRS_THRESHOLD
    elseif self.inst.components.workable ~= nil and self.inst.components.workable.workleft ~= nil then
        return self.inst.components.workable.workable
            and self.inst.components.workable.workleft < self.inst.components.workable.maxwork * NEEDSREPAIRS_THRESHOLD
    elseif self.inst.components.perishable ~= nil and self.inst.components.perishable.perishremainingtime ~= nil then
        return self.inst.components.perishable.perishremainingtime < self.inst.components.perishable.perishtime * NEEDSREPAIRS_THRESHOLD
    elseif self.inst.components.finiteuses ~= nil then
        return self.inst.components.finiteuses:GetPercent() < NEEDSREPAIRS_THRESHOLD
    end
    return false
end

local function address_repair_amount(self, repair_item_repairer)
    local health = self.inst.components.health
    if health and (repair_item_repairer.healthrepairvalue > 0 or repair_item_repairer.healthrepairpercent > 0) then
        if health:GetPercent() >= 1 then
            return false
        end
        health:DoDelta(repair_item_repairer.healthrepairvalue)
        health:DoDelta(repair_item_repairer.healthrepairpercent * health.maxhealth)
        return true
    end

    local workable = self.inst.components.workable
    if workable ~= nil and workable.workleft ~= nil and repair_item_repairer.workrepairvalue > 0 then
        if not workable.workable or workable.workleft >= workable.maxwork then
            return false
        end
        workable:SetWorkLeft(workable.workleft + repair_item_repairer.workrepairvalue)
        return true
    end

    local perishable = self.inst.components.perishable
    if perishable ~= nil and perishable.perishremainingtime ~= nil and repair_item_repairer.perishrepairpercent > 0 then
        if perishable.perishremainingtime >= perishable.perishtime then
            return false
        end
        perishable:SetPercent(perishable:GetPercent() + repair_item_repairer.perishrepairpercent)
        return true
    end

    local finiteuses = self.inst.components.finiteuses
    if finiteuses and repair_item_repairer.finiteusesrepairvalue > 0 then
        if finiteuses:GetPercent() >= 1 then
            return false
        end
        finiteuses:Repair(repair_item_repairer.finiteusesrepairvalue)
        return true
    end

    -- If not justrunonrepaired either, this is not repairable, and we should fail out.
    return self.inst.components.repairable.justrunonrepaired
end

function Repairable:Repair(doer, repair_item)
    if self.testvalidrepairfn and not self.testvalidrepairfn(self.inst, repair_item) then
        return false
    end

    local repair_item_repairer = repair_item.components.repairer
    if not repair_item_repairer or self.repairmaterial ~= repair_item_repairer.repairmaterial then
        --wrong material
        return false
    elseif self.checkmaterialfn then
        local success, reason = self.checkmaterialfn(self.inst, repair_item)
        if not success then
            return false, reason
        end
    end

    if not address_repair_amount(self, repair_item_repairer) then
        return false
    end

    if repair_item_repairer.boatrepairsound then
        self.inst.SoundEmitter:PlaySound(repair_item.components.repairer.boatrepairsound)
    end

    if repair_item.components.stackable then
        repair_item.components.stackable:Get():Remove()
    else
        repair_item:Remove()
    end

    if self.onrepaired then
        self.onrepaired(self.inst, doer, repair_item)
    end

    return true
end

return Repairable
