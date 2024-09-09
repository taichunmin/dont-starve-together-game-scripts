local function onfiniteuses(self)
    local repairable = self.inst.components.repairable
    if repairable then
        repairable:SetFiniteUsesRepairable(self.current < self.total)
	elseif self.inst.components.forgerepairable ~= nil then
		self.inst.components.forgerepairable:SetRepairable(self.current < self.total)
    end
end

local FiniteUses = Class(function(self, inst)
    self.inst = inst
    self.total = 100
    self.current = 100
    self.consumption = {}
    self.ignorecombatdurabilityloss = false
end,
nil,
{
    current = onfiniteuses,
    total = onfiniteuses,
})

function FiniteUses:OnRemoveFromEntity()
	self.inst:RemoveTag("usesdepleted")
end

function FiniteUses:SetConsumption(action, uses)
    self.consumption[action] = uses
end

function FiniteUses:GetDebugString()
    return string.format("%.2f/%d", self.current, self.total)
end

function FiniteUses:SetDoesNotStartFull(enabled) -- NOTES(JBK): Removes the assumption that the item starts at 100% uses by default for saving.
    self.doesnotstartfull = enabled
end

function FiniteUses:OnSave()
    if self.current ~= self.total or self.doesnotstartfull then
        return { uses = self.current }
    end
end

function FiniteUses:OnLoad(data)
    if data.uses ~= nil then
        self:SetUses(data.uses)
    end
end

function FiniteUses:SetMaxUses(val)
    self.total = val
end

function FiniteUses:SetUses(val)
    local was_positive = self.current > 0
    self.current = val
    self.inst:PushEvent("percentusedchange", {percent = self:GetPercent()})
    if self.current <= 0 then
        self.current = 0
        if was_positive then
			self.inst:AddTag("usesdepleted")
			if self.onfinished ~= nil then
			    self.onfinished(self.inst)
			end
        end
	elseif not was_positive then
		self.inst:RemoveTag("usesdepleted")
    end
end

function FiniteUses:GetUses()
    return self.current
end

function FiniteUses:Use(num)
    self:SetUses(self.current - (num or 1))
end

function FiniteUses:IgnoresCombatDurabilityLoss()
    return self.ignorecombatdurabilityloss
end

function FiniteUses:SetIgnoreCombatDurabilityLoss(value)
    self.ignorecombatdurabilityloss = value
end

function FiniteUses:OnUsedAsItem(action, doer, target)
    local uses = self.consumption[action]
    if uses ~= nil then
		if doer ~= nil and doer:IsValid() and doer.components.efficientuser ~= nil then
			uses = uses * (doer.components.efficientuser:GetMultiplier(action) or 1)
		end

        if self.modifyuseconsumption then
            uses = self.modifyuseconsumption(uses, action, doer, target)
        end

        self:Use(uses)
    end
end

function FiniteUses:GetPercent()
    return self.current / self.total
end

function FiniteUses:SetPercent(amount)
    self:SetUses(self.total * amount)
end

function FiniteUses:SetOnFinished(fn)
    self.onfinished = fn
end

function FiniteUses:Repair(repairvalue)
    self:SetUses(math.min(self.current + repairvalue, self.total))
end

return FiniteUses
