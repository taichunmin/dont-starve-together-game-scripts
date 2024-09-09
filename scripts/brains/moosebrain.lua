require "behaviours/standandattack"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/leash"

local START_FACE_DIST = 15
local KEEP_FACE_DIST = 20

local function GoHome(inst)
    return inst.shouldGoAway
        and inst.components.combat.target == nil
        and BufferedAction(inst, nil, ACTIONS.GOHOME)
        or nil
end

local function GetFaceTargetFn(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not (inst.sg:HasStateTag("busy") or
                inst:HasTag("notarget"))
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function LayEgg(inst)
    return inst.WantsToLayEgg
        and not inst.components.entitytracker:GetEntity("egg")
        and BufferedAction(inst, nil, ACTIONS.LAYEGG)
        or nil
end

local MooseBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MooseBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.shouldGoAway end, "Go Away",
                DoAction(self.inst, GoHome)),

            Leash(self.inst, self.inst.components.knownlocations:GetLocation("landpoint"), 25, 3),

            ChaseAndAttack(self.inst),

            DoAction(self.inst, LayEgg),

            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),

            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("landpoint") end, 15),
        }, 1)

    self.bt = BT(self.inst, root)
end

function MooseBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return MooseBrain
