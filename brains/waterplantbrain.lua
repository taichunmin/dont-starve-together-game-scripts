require "behaviours/faceentity"
require "behaviours/standandattack"

local START_FACE_DIST = 10
local KEEP_FACE_DIST = 15

local WaterPlantBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function should_emergency_pollen(inst)
    return inst._can_cloud and
            inst.components.burnable ~= nil and
            (inst.components.burnable:IsBurning() or inst.components.burnable:IsSmoldering())
end

local CLOUD_HASTAGS = { "pollen" }
local CLOUD_NOTAGS = { "DECOR", "INLIMBO" }
local CLOUD_DISTANCE = TUNING.OCEANFISH.SPRINKLER_DETECT_RANGE + 3 -- Only spawn if there isn't pollen within fish spray range already.
local function should_spray_cloud(inst)
    if inst._can_cloud ~= true then
        return false
    end

    if (inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep())
            or (inst.components.health ~= nil and inst.components.health:IsDead()) then
        return false
    else
        return true
    end
end

local function spray_cloud(inst)
    inst:PushEvent("spray_cloud")
end

function WaterPlantBrain:OnStart()
    local root = PriorityNode(
    {
        IfNode(function() return should_emergency_pollen(self.inst) end, "Emergency Cloud Spray?",
            ActionNode(function() spray_cloud(self.inst) end)
        ),
        WhileNode(
            function() return self.inst._stage == 3 end,
            "Is Open",
            PriorityNode({
                StandAndAttack(self.inst),
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
            }, .25)
        ),
        IfNode(function() return should_spray_cloud(self.inst) end, "Should I Spray A Cloud?",
            ActionNode(function() spray_cloud(self.inst) end)
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

return WaterPlantBrain
