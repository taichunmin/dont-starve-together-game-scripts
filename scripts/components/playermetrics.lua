local Stats = require("stats")

local function PushEvent(id, player, values)
    Stats.PushMetricsEvent(id, player, values)
end

local function OnUnlockRecipe(inst, data)
    if data ~= nil and data.recipe ~= nil then
        PushEvent("character.prototyped", inst, { prefab = data.recipe })
    end
end

local PlayerMetrics = Class(function(self, inst)
    self.inst = inst

    inst:ListenForEvent("unlockrecipe", OnUnlockRecipe)
end)

function PlayerMetrics:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("unlockrecipe", OnUnlockRecipe);
end

return PlayerMetrics
