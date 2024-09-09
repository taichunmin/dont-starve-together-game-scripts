local MaxHealer = Class(function(self, inst)
    self.inst = inst
    self.healamount = TUNING.MAX_HEALING_NORMAL
end)

--NOTE: This is set as a factor of num revives! not an HP amount
function MaxHealer:SetHealthAmount(health)
    self.healamount = health
end

function MaxHealer:Heal(target)
    if target.components.health ~= nil then
        target.components.health:DeltaPenalty(self.healamount) --remove x% from the penalty.
        --print(target.components.health.penalty)
        if self.inst.components.stackable ~= nil and self.inst.components.stackable:IsStack() then
            self.inst.components.stackable:Get():Remove()
        else
            self.inst:Remove()
        end
        return true
    end
end

return MaxHealer
