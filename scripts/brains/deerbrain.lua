require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/leash"
require "behaviours/minperiod"
require "behaviours/standstill"

local BrainCommon = require("brains/braincommon")

local WANDER_DIST_DAY = 10

local RUN_AWAY_DIST = 3
local STOP_RUN_AWAY_DIST = 12
local SOLO_START_FACE_DIST = 2
local SOLO_KEEP_FACE_DIST = 4

-- NEW VARS
local HERD_KEEPUP_DIST = 18
local START_ALERT_DIST = 6
local KEEP_ALERT_DIST = 8

local function ResetData(inst)
    if TheWorld.components.deerherding ~= nil then
       TheWorld.components.deerherding:SetHerdAlertTarget(inst, FindClosestPlayerToInst(inst, START_ALERT_DIST, true))
    end
end

local function GetAlertTargetFn(inst)
    if inst:IsValid() then
        return TheWorld.components.deerherding:GetClosestHerdAlertTarget(inst)
    end
end

local function KeepAlertTargetFn(inst, target)
    if inst:IsValid() then
        return TheWorld.components.deerherding:HerdHasAlertTarget()
    end
end

local function GetNonHerdingFaceTargetFn(inst)
    return FindClosestPlayerToInst(inst, SOLO_START_FACE_DIST, true)
end

local function KeepNonHerdingFaceTargetFn(inst, target)
    return not target:HasTag("notarget")
        and inst:IsNear(target, SOLO_KEEP_FACE_DIST)
end

local function GetWanderDistFn(inst)
    return WANDER_DIST_DAY
end

local function GetLocationInHerd(inst)
    local herdpt = TheWorld.components.deerherding.herdlocation
    local offset = inst.components.knownlocations:GetLocation("herdoffset")
    return (herdpt and offset) and (herdpt + offset) or nil
end

local function ShouldMoveAsHerd(self)
    local herd_pt = GetLocationInHerd(self.inst)
    return herd_pt and (self.inst:GetDistanceSqToPoint(herd_pt:Get()) > (TUNING.DEER_HERD_MOVE_DIST * 0.5))
end

local function GetGrazingLocation(inst)
    local herdpt = TheWorld.components.deerherding.herdlocation
    local offset = inst.components.knownlocations:GetLocation("herdoffset")
    return (herdpt and offset) and (herdpt + offset * 2) or nil
end

local function GetGrazingAngle(inst)
    local offset = inst.components.knownlocations:GetLocation("herdoffset")
    return GetRandomWithVariance(math.atan2(offset.z, offset.x), 66*DEGREES)
end

local function IsHerdGrazing(self)
    return TheWorld.components.deerherding:IsGrazing()
    -- todo: Ask TheWorld.components.deerherding if it is grazing
end

local DeerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DeerBrain:OnStart()
    local solomentality = PriorityNode(
    {
		--NOTE: haunt is the only panic trigger higher priority than fleeing
        WhileNode(function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.combat:HasTarget() end, "Flee",
            PriorityNode{
                AttackWall(self.inst),
                RunAway(self.inst, {fn=function(guy) return self.inst.components.combat:TargetIs(guy) end, tags={"player"}}, TUNING.DEER_ATTACKER_REMEMBER_DIST, TUNING.DEER_ATTACKER_REMEMBER_DIST),
            }),
		BrainCommon.PanicTrigger(self.inst),

        FaceEntity(self.inst, GetNonHerdingFaceTargetFn, KeepNonHerdingFaceTargetFn),
        BrainCommon.AnchorToSaltlick(self.inst),
        --Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("nonherdhome") end, GetWanderDistFn),
        Wander(self.inst),

    })

    local herdmentality = PriorityNode(
    {
        Leash(self.inst, GetLocationInHerd, HERD_KEEPUP_DIST, 5, true),
        FaceEntity(self.inst, GetAlertTargetFn, KeepAlertTargetFn, 0.25),
        WhileNode(function() return IsHerdGrazing(self) end, "Grazing",
            SequenceNode{
                WaitNode(2),
                Wander(self.inst, GetGrazingLocation, 2, nil, GetGrazingAngle),
            }
        ),
        Leash(self.inst, GetLocationInHerd, 2, 2, false)
    })

    local root =
    PriorityNode(
    {
        FailIfSuccessDecorator(ActionNode(function() ResetData(self.inst) end, "Reset Data")),

        WhileNode(function() return TheWorld.components.deerherding ~= nil and TheWorld.components.deerherding:IsActiveInHerd(self.inst) end, "Herd Mentality",
            herdmentality
        ),
        solomentality,

        StandStill(self.inst),
    },.25)

    self.bt = BT(self.inst, root)
end

return DeerBrain
