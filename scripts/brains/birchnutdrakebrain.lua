require "behaviours/chaseandattack"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local BirchNutDrakeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local MAX_WANDER_DIST = 5

local function GetHomePos(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

function BirchNutDrakeBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        Leash(self.inst, GetHomePos, 20, 5),
        ChaseAndAttack(self.inst, 12, 21),
        ActionNode(function() self.inst:PushEvent("exit", { force = true, idleanim = true }) end),
    }, .25)

    self.bt = BT(self.inst, root)
end

function BirchNutDrakeBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return BirchNutDrakeBrain
