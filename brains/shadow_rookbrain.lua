require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"

local START_FACE_DIST = 8
local KEEP_FACE_DIST = 15

local Shadow_RookBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    self._shouldchase = false
end)

local function GetFaceTargetFn(inst)
    local target = inst.components.combat.target or FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return target.components.health ~= nil
        and not target.components.health:IsDead()
        and not target:HasTag("playerghost")
        and not target:HasTag("notarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldChase(self)
    self._shouldchase =
        not self.inst.components.combat:HasTarget() or
        not self.inst.components.combat:InCooldown() or
        not self.inst:IsNear(self.inst.components.combat.target, self.inst.components.combat.attackrange + (self._shouldchase and -2 or 2))

    return self._shouldchase
end

function Shadow_RookBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return ShouldChase(self) end, "Chase",
            ChaseAndAttack(self.inst, nil, 40)),
        ParallelNode{
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
            LoopNode({
                WaitNode(3),
                ActionNode(function()
                    if self.inst.sg:HasStateTag("idle") then
                        self.inst.sg:GoToState("taunt")
                    end
                end),
            }),
        },
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

return Shadow_RookBrain
