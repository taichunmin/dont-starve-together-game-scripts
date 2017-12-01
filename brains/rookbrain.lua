require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandram"
require "behaviours/follow"

local START_FACE_DIST = 14
local KEEP_FACE_DIST = 16
local GO_HOME_DIST = 40
local MAX_CHASE_TIME = 5
local MAX_CHARGE_DIST = 25
local CHASE_GIVEUP_DIST = 10
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local RookBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, .2)
        or nil
end

local function GetFaceTargetFn(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) > GO_HOME_DIST * GO_HOME_DIST then
        return
    end
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    return (homePos == nil or
            inst:GetDistanceSqToPoint(homePos:Get()) <= GO_HOME_DIST * GO_HOME_DIST)
        and not target:HasTag("notarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldGoHome(inst)
    if inst.components.follower ~= nil and inst.components.follower.leader ~= nil then
        return false
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos == nil then
        return
    end

    local dist_sq = inst:GetDistanceSqToPoint(homePos:Get())
    return dist_sq > GO_HOME_DIST * GO_HOME_DIST
        or (inst.components.combat.target == nil and
            dist_sq > CHASE_GIVEUP_DIST * CHASE_GIVEUP_DIST)
end

function RookBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end,
            "RamAttack",
            ChaseAndRam(self.inst, MAX_CHASE_TIME, CHASE_GIVEUP_DIST, MAX_CHARGE_DIST)),
        WhileNode(function()
                return self.inst.components.combat.target ~= nil
                    and self.inst.components.combat:InCooldown()
                    and not (self.inst.components.follower ~= nil and
                            self.inst.components.follower.leader ~= nil)
            end,
            "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", false)),

        Follow(self.inst, function() return self.inst.components.follower ~= nil and self.inst.components.follower.leader or nil end,
            5, 7, 12, false),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        StandStill(self.inst)
    }, .25)

    self.bt = BT(self.inst, root)
end

return RookBrain
