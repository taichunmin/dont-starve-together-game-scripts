local SourceModifierList = require("util/sourcemodifierlist")

local EfficientUser = Class(function(self, inst)
    self.inst = inst
    self.actions = {}
end)

function EfficientUser:GetMultiplier(action)
    return self.actions[action] and self.actions[action]:Get() or 1
end

function EfficientUser:AddMultiplier(action, multiplier, source)
    if not self.actions[action] then
        self.actions[action] = SourceModifierList(self.inst)
    end

    self.actions[action]:SetModifier(source, multiplier)
end

function EfficientUser:RemoveMultiplier(action, source)
    if self.actions[action] then
        self.actions[action]:RemoveModifier(source)
    end
end

return EfficientUser
