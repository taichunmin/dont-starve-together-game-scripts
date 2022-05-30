require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/minperiod"
require "behaviours/follow"

local START_FACE_DIST = 8
local KEEP_FACE_DIST = 15
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 7

local Shadow_KnightBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return target.components.health ~= nil
        and not target.components.health:IsDead()
        and not target:HasTag("playerghost")
        and not target:HasTag("notarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

function Shadow_KnightBrain:OnStart()
    local root = PriorityNode(
    {
		WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
					ChaseAndAttack(self.inst, nil, 40)),
        WhileNode(function() return self.inst.components.combat.target ~= nil end, "Dodge",
				RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
        ),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        ParallelNode{
            SequenceNode{
                WaitNode(TUNING.SHADOW_CHESSPIECE_DESPAWN_TIME),
                ActionNode(function() self.inst:PushEvent("despawn") end),
            },
            Wander(self.inst),
        },
    }, .25)

    self.bt = BT(self.inst, root)
end

return Shadow_KnightBrain