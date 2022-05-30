local SourceModifierList = require("util/sourcemodifierlist")

local WorkMultiplier = Class(function(self, inst)
    self.inst = inst
    self.actions = {}
end)

function WorkMultiplier:GetMultiplier(action)
    return self.actions[action] and self.actions[action]:Get() or 1
end

function WorkMultiplier:AddMultiplier(action, multiplier, source)
    if not self.actions[action] then
        self.actions[action] = SourceModifierList(self.inst)
    end

    self.actions[action]:SetModifier(source, multiplier)
end

function WorkMultiplier:RemoveMultiplier(action, source)
    if self.actions[action] then
        self.actions[action]:RemoveModifier(source)
    end
end

return WorkMultiplier
