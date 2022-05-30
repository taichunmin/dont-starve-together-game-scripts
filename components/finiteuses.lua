local FiniteUses = Class(function(self, inst)
    self.inst = inst
    self.total = 100
    self.current = 100
    self.consumption = {}
end)

function FiniteUses:OnRemoveFromEntity()
	self.inst:RemoveTag("usesdepleted")
end

function FiniteUses:SetConsumption(action, uses)
    self.consumption[action] = uses
end

function FiniteUses:GetDebugString()
    return string.format("%.2f/%d", self.current, self.total)
end

function FiniteUses:OnSave()
    if self.current ~= self.total then
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

function FiniteUses:OnUsedAsItem(action, doer, target)
    local uses = self.consumption[action]
    if uses ~= nil then
		if doer ~= nil and doer:IsValid() and doer.components.efficientuser ~= nil then
			uses = uses * (doer.components.efficientuser:GetMultiplier(action) or 1)
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

return FiniteUses
