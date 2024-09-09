require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chaseandattack"
local BrainCommon = require("brains/braincommon")

local SlurperBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function SlurperBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        ChaseAndAttack(self.inst, 60, 100),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 20),
    }, .25)
    self.bt = BT(self.inst, root)
end

return SlurperBrain