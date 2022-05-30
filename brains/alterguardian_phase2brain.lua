require "behaviours/chaseandattack"
require "behaviours/standstill"

local AlterGuardian_Phase2Brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local START_FACE_DIST = TUNING.ALTERGUARDIAN_PHASE2_SPIN_RANGE
local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local KEEP_FACE_DIST = TUNING.ALTERGUARDIAN_PHASE2_SPIN_RANGE + 3
local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetWanderHome(inst)
    return inst.components.knownlocations:GetLocation("spawnpoint")
end

local MAX_CHASE_TIME = 60
local GIVE_UP_DIST = 40
function AlterGuardian_Phase2Brain:OnStart()
    local main_behaviour = PriorityNode({
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetWanderHome, 2 * TUNING.ALTERGUARDIAN_PHASE2_TARGET_DIST),
    }, .25)

    local root = PriorityNode({
        WhileNode(
            function() return not self.inst.sg:HasStateTag("spin") end,
            "Not Spinning",
            main_behaviour
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

function AlterGuardian_Phase2Brain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return AlterGuardian_Phase2Brain
