require "behaviours/wander"
require "behaviours/leash"

local TornadoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local wanderTimes = 
{
    minwalktime = .25,
    randwalktime = .25,
    minwaittime = .25,
    randwaittime = .25,
}

function TornadoBrain:OnStart()
    local root = 
    PriorityNode(
    {
        Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("target") end, 3, 1, true),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("target") end, 2, wanderTimes),
    }, .25)
    self.bt = BT(self.inst, root)
end

return TornadoBrain