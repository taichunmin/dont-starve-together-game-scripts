require("behaviours/chaseandattackandavoid")
require("behaviours/leashandavoid")
require("behaviours/panicandavoid")
require("behaviours/standstill")
require("behaviours/wander")

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 6

local PigEliteFighterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.follower.leader
end

function PigEliteFighterBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("jumping") end, "Standby",
            ActionNode(function() --[[do nothing]] end)),
        WhileNode(function() return self.inst.components.hauntable.panic end, "PanicHaunted",
            ChattyNode(self.inst, "PIG_TALK_PANICHAUNT",
                Panic(self.inst))),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
            ChattyNode(self.inst, "PIG_TALK_PANICFIRE",
                Panic(self.inst))),
        WhileNode(function() return self.inst._should_despawn end, "Standby",
            ParallelNode{
                StandStill(self.inst),
                LoopNode({ ActionNode(function() self.inst:PushEvent("despawn") end) }),
            }),

		ChaseAndAttack(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        WhileNode(function() return GetLeader(self.inst) == nil end, "Standby",
            ParallelNode{
                StandStill(self.inst),
                LoopNode({ ActionNode(function() self.inst:PushEvent("despawn") end) }),
            }),
    }, .5)

    self.bt = BT(self.inst, root)
end

return PigEliteFighterBrain
