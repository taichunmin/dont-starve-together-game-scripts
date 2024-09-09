local Healer = Class(function(self, inst)
    self.inst = inst
    self.health = TUNING.HEALING_SMALL

    --self.canhealfn = nil
    --self.onhealfn = nil
end)

function Healer:SetHealthAmount(health)
    self.health = health
end

function Healer:SetOnHealFn(fn)
    self.onhealfn = fn
end

function Healer:SetCanHealFn(fn)
    self.canhealfn = fn
end

function Healer:Heal(target, doer)
    local health = target.components.health

    if health == nil then
        return false
    end

    if self.canhealfn ~= nil then
        local valid, reason = self.canhealfn(self.inst, target, doer)

        if not valid then
            return false, reason
        end
    end

    if health.canheal then -- NOTES(JBK): Tag healerbuffs can make this heal function be invoked but we do not want to apply health to things that can not be healed.
        health:DoDelta(self.health, false, self.inst.prefab)
    end

    if self.onhealfn ~= nil then
        self.onhealfn(self.inst, target, doer)
    end

    if self.inst.components.stackable ~= nil and self.inst.components.stackable:IsStack() then
        self.inst.components.stackable:Get():Remove()
    else
        self.inst:Remove()
    end

    return true
end

return Healer
