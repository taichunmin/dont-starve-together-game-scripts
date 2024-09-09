local Worker = Class(function(self, inst)
    self.inst = inst
    self.actions = {}
end)

function Worker:GetEffectiveness(action)
    return self.actions[action] or 0
end

function Worker:SetAction(action, effectiveness)
    self.actions[action] = effectiveness or 1
end

function Worker:CanDoAction(action)
    return self.actions[action] ~= nil
end

return Worker
