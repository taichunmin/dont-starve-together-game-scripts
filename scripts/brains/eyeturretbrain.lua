require "behaviours/standandattack"
require "behaviours/faceentity"

local START_FACE_DIST = 10
local KEEP_FACE_DIST = 15

local EyeTurretBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

function EyeTurretBrain:OnStart()
    local root = PriorityNode(
    {
        StandAndAttack(self.inst),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
    }, .25)

    self.bt = BT(self.inst, root)
end

return EyeTurretBrain
