require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"

local MoleBatBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function CleanUpNest(inst)
    local burrow = inst.components.entitytracker:GetEntity("burrow")
    if burrow == nil then
        -- Someone else probably cleaned us up; we can stop trying.
        inst._nest_needs_cleaning = false
        return nil
    end

    return BufferedAction(inst, burrow, ACTIONS.BREAK, nil, burrow:GetPosition())
end

local MOLEHILL_RADIUS       = 19
local MOLEHILL_HASTAGS      = {"molebathill"}
local MOLEHILL_NONETAGS     = {"DECOR", "FX", "NOCLICK", "INLIMBO"}
local function ShouldBuildHome(inst)
    if inst.sg:HasStateTag("busy")
            or inst.components.entitytracker:GetEntity("burrow") ~= nil
            or (inst.WantsToNap ~= nil and not inst:WantsToNap()) then
        return false
    end

    local nearby_home = FindEntity(inst, MOLEHILL_RADIUS, nil, MOLEHILL_HASTAGS, MOLEHILL_NONETAGS)
    if nearby_home == nil then
        return true
    else
        inst.components.entitytracker:TrackEntity("burrow", nearby_home)
        return false
    end
end

local function CreateBurrow(inst)
    local burrow_position = inst:GetPosition()
    local offset = FindWalkableOffset(burrow_position, math.random()*2*PI, math.random(4, 7), 10, true, false)
    if offset ~= nil then
        burrow_position = burrow_position + offset
    end

    return BufferedAction(inst, nil, ACTIONS.MAKEMOLEHILL, nil, burrow_position, nil, 1)
end

local function ShouldGoSleepAtHome(inst)
    -- Not busy, wants to nap, and has a burrow to nap at: let's go nap!!
    return not inst.sg:HasStateTag("busy")
        and (inst.WantsToNap ~= nil and inst:WantsToNap())
        and inst.components.entitytracker:GetEntity("burrow") ~= nil
end

local function GoSleepAtHomeAction(inst)
    local burrow = inst.components.entitytracker:GetEntity("burrow")

    return BufferedAction(inst, burrow, ACTIONS.TRAVEL, nil, burrow:GetPosition(), nil, 1.5)
end

local GO_HOME_DSQ          = 900 -- 30^2
local function ShouldGoHome(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    if homePos == nil then
        return false
    end

    local dsq_to_home = inst:GetDistanceSqToPoint(homePos:Get())
    return (dsq_to_home > GO_HOME_DSQ)
end

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local homePos = inst.components.knownlocations:GetLocation("home")
    return homePos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, .2)
        or nil
end

local SEE_FOOD_DIST         = 25
local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()
    local target = FindEntity(
        inst,
        SEE_FOOD_DIST,
        function(item)
            return item:GetTimeAlive() >= 8
                and item:IsOnPassablePoint(true)
                and inst.components.eater:CanEat(item)
                and item:GetDistanceSqToPoint(ix, iy, iz) < GO_HOME_DSQ -- too far from home = bouncing
        end,
        nil,
        NO_TAGS,
        inst.components.eater:GetEdibleTags()
    )
    return target ~= nil and BufferedAction(inst, target, ACTIONS.EAT) or nil
end

local START_FACE_DIST       = 6
local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local KEEP_FACE_DIST        = 8
local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local MAX_CHASE_TIME        = 10
local MAX_CHASE_DIST        = 20
local RUN_AWAY_DIST         = 5
local STOP_RUN_AWAY_DIST    = 8
local WANDER_TIMES =
{
    minwaittime = 2.5
}

local MAX_CLEAN_ATTEMPT_TIME = 20

function MoleBatBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function()
                return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic
            end, "Haunted",
            Panic(self.inst)
        ),
        WhileNode(function()
                return self.inst.components.health.takingfiredamage
            end, "On Fire",
            Panic(self.inst)
        ),
        WhileNode(function()
                return self.inst._quaking
            end, "Quaking",
            Panic(self.inst)
        ),
        WhileNode(function()
                return (self.inst.components.combat.target ~= nil and
                        self.inst.ShouldSummonAllies ~= nil and
                        self.inst:ShouldSummonAllies()) or
                        false
            end, "Summon Allies",
            ActionNode(function() self.inst:PushEvent("summon") end)
        ),
        WhileNode(function()
                return self.inst.components.combat.target == nil
                    or not self.inst.components.combat:InCooldown()
            end,
            "Attack Momentarily",
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)
        ),
        WhileNode(function()
                return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown()
            end, "Dodge",
            RunAway(self.inst, function()
                    return self.inst.components.combat.target
                end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
        ),
        WhileNode(function() return self.inst._nest_needs_cleaning == true end, "Nest Needs Cleaning Up",
            DoAction(self.inst, CleanUpNest, "Clean Up Nest", true)
        ),
        WhileNode(function() return ShouldBuildHome(self.inst) end, "Wants To Build A Home",
            DoAction(self.inst, CreateBurrow, "Build A Home", true)
        ),
        WhileNode(function() return ShouldGoSleepAtHome(self.inst) end, "Wants To Sleep At Home",
            DoAction(self.inst, GoSleepAtHomeAction, "Sleep At Home", true)
        ),
        WhileNode(function() return ShouldGoHome(self.inst) end, "Should Go Home",
            DoAction(self.inst, GoHomeAction, "Go Home", true)
        ),
        DoAction(self.inst, EatFoodAction, "Find and Eat", true),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst,
            function()
                return self.inst.components.knownlocations:GetLocation("home")
            end,
            MAX_CHASE_DIST * 2,
            WANDER_TIMES
        ),
    }, .25)

    self.bt = BT(self.inst, root)
end

return MoleBatBrain
