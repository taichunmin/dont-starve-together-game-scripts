require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"
--require "behaviours/runaway"
--require "behaviours/doaction"

local BrainCommon = require("brains/braincommon")

-- states
local GREETING = "greeting"
local LOITERING = "loitering"
local WANDERING = "wandering"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local WANDER_DIST_DAY = 20
local WANDER_DIST_NIGHT = 5
local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6

local MAX_CHASE_TIME = 6

local MIN_FOLLOW_DIST = 1
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 5

local MIN_BUDDY_DIST = 0
local TARGET_BUDDY_DIST = 4
local MAX_BUDDY_DIST = 18

local GREET_SEARCH_RADIUS = 15
local GREET_SEARCH_RSQ = GREET_SEARCH_RADIUS * GREET_SEARCH_RADIUS
local GREET_DURATION = 3

local MIN_GREET_DIST = 1
local TARGET_GREET_DIST = 3
local MAX_GREET_DIST = 5

local LOITER_SEARCH_RADIUS = 30
local TARGET_LOITER_DIST = 10
local LOITER_DURATION = TUNING.SEG_TIME * 4

local LOITER_ANCHOR_RESET_DIST = 20
local LOITER_ANCHOR_HERD_DIST = 40

local function GetFaceTargetFn(inst)
    if not (inst.components.domesticatable ~= nil and inst.components.domesticatable:IsDomesticated()) and
        not BrainCommon.ShouldSeekSalt(inst) then
        local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
        return target ~= nil and not target:HasTag("notarget") and target or nil
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst ~= nil
        and target ~= nil
        and inst:IsValid()
        and target:IsValid()
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost"))
        and inst:IsNear(target, KEEP_FACE_DIST)
        and not BrainCommon.ShouldSeekSalt(inst)
end

local function GetWanderDistFn(inst)
    return TheWorld.state.isday and WANDER_DIST_DAY or WANDER_DIST_NIGHT
end

local function GetLoiterTarget(inst)
    return FindClosestPlayerToInst(inst, LOITER_SEARCH_RADIUS, true)
end

local function GetGreetTarget(inst)
    if inst._beef_bell ~= nil
            and inst:GetDistanceSqToInst(inst._beef_bell) < GREET_SEARCH_RSQ then
        return inst._beef_bell
    else
        return FindClosestPlayerToInstOnLand(inst, GREET_SEARCH_RADIUS, true)
    end
end

local function GetGreetTargetPosition(inst)
    local greetTarget = GetGreetTarget(inst)
    return greetTarget ~= nil and greetTarget:GetPosition() or inst:GetPosition()
end

local function GetLoiterAnchor(inst)
    if inst.components.knownlocations:GetLocation("loiteranchor") == nil then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())

    elseif inst.components.knownlocations:GetLocation("herd") ~= nil and inst:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("herd")) < LOITER_ANCHOR_HERD_DIST*LOITER_ANCHOR_HERD_DIST then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst.components.knownlocations:GetLocation("herd"))

    elseif inst:GetDistanceSqToPoint(inst.components.knownlocations:GetLocation("loiteranchor")) > LOITER_ANCHOR_RESET_DIST*LOITER_ANCHOR_RESET_DIST then
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
    end

    return inst.components.knownlocations:GetLocation("loiteranchor")
end

local function TryBeginLoiterState(inst)
    if inst:GetIsInMood() then
        return false
    end

    if GetTime() - inst._startgreettime < GREET_DURATION then
        inst._startgreettime = GetTime() - GREET_DURATION
        return true
    end
    return false
end

local function TryBeginGreetingState(inst)
    if inst:GetIsInMood() then
        return false
    end

    if inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication() > 0.0
        and GetGreetTarget(inst) ~= nil then

        inst._startgreettime = GetTime()
        return true
    end
    return false
end

local function ShouldWaitForHeavyLifter(inst, target)
    if target ~= nil and target.components.inventoryitem ~= nil then
        local owner = target.components.inventoryitem:GetGrandOwner()
        if owner ~= nil then
            target = owner
        end
    end

    if target ~= nil
        and (
            target.components.inventory ~= nil and
            target.components.inventory:IsHeavyLifting()
        )
        and inst.components.rideable.canride then
        --Check if target is heavy lifting towards me
        --(dot product between target's facing and target to me > 0)
        local x, y, z = target.Transform:GetWorldPosition()
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        local dx = x1 - x
        local dz = z1 - z
        if dx * dx + dz * dz < MAX_FOLLOW_DIST * MAX_FOLLOW_DIST then
            local theta = -target.Transform:GetRotation() * DEGREES
            --local dx1 = math.cos(theta)
            --local dz1 = math.sin(theta)
            return dx * math.cos(theta) + dz * math.sin(theta) > 0
        end
    end
    return false
end

local function GetWaitForHeavyLifter(inst)
    local target = GetGreetTarget(inst)
    return ShouldWaitForHeavyLifter(inst, target) and target or nil
end

local function gottohitchspot(inst)

    if inst.hitchingspot then
        if inst:HasTag("hitched") then
            inst.components.hitchable:Unhitch()
        end
        return BufferedAction(inst, inst.hitchingspot, ACTIONS.HITCH)
    end
end

local function InState(inst, state)
    if inst._startgreettime == nil then
        inst._startgreettime = -1000000
    end
    local timedelta = GetTime() - inst._startgreettime
    if timedelta < GREET_DURATION then
        return state == GREETING
    elseif timedelta < LOITER_DURATION then
        return state == LOITERING
    else
        return state == WANDERING
    end
end

local BeefaloBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BeefaloBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
            Panic(self.inst)),
        IfNode(function() return self.inst.components.combat.target ~= nil end, "hastarget",
            AttackWall(self.inst)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME),

        WhileNode(function() return self.inst.components.writeable ~= nil
                        and self.inst.components.writeable:IsBeingWritten() end, "Name Being Written",
            StandStill(self.inst)),

        WhileNode(function() return self.inst:HasTag("hitched") and not self.inst.hitchingspot end, "hitched",
            StandStill(self.inst)),

        IfNode(function() return self.inst.hitchingspot end, "get hitched",
            DoAction(self.inst, gottohitchspot, "hitchup",true)),

        Follow(self.inst, function()
                local bell_owner = self.inst:GetBeefBellOwner() or self.inst.components.follower:GetLeader()
                return (bell_owner ~= nil and bell_owner:IsOnValidGround() and bell_owner)
                        or nil
            end, MIN_BUDDY_DIST, TARGET_BUDDY_DIST, MAX_BUDDY_DIST, true),
        Follow(self.inst, function()
                local follower = self.inst.components.follower
                return (follower ~= nil
                    and follower.leader ~= nil
                    and not follower.leader:HasTag("bell")
                    and follower.leader:IsOnValidGround()
                    and follower.leader)
                    or nil
            end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),

        -- hanging around herd
        ConditionNode(function() return InState(self.inst, WANDERING) and TryBeginGreetingState(self.inst) end, "Wandering"),

        -- wants to greet feeder
        WhileNode(function() return InState(self.inst, GREETING) end, "Greeting", PriorityNode{
            Follow(self.inst, GetGreetTarget, MIN_GREET_DIST, TARGET_GREET_DIST, MAX_GREET_DIST, true),
            ActionNode(function() TryBeginLoiterState(self.inst) end, "Finish greeting")
        }),

        -- anchor to nearest saltlick
        BrainCommon.AnchorToSaltlick(self.inst),

        -- waiting for feeder
        WhileNode(function() return InState(self.inst, LOITERING) end, "Loitering", PriorityNode{
            WhileNode(function() return GetLoiterTarget(self.inst) ~= nil end, "Anyone nearby?", PriorityNode{
                FailIfSuccessDecorator(ActionNode(function() TryBeginLoiterState(self.inst) end, "Reset Loiter Time")),
                FaceEntity(self.inst, GetWaitForHeavyLifter, ShouldWaitForHeavyLifter),
                Follow(self.inst, GetGreetTarget, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),
                Wander(self.inst, function() return GetGreetTargetPosition(self.inst) end, TARGET_LOITER_DIST)
            }),
            Wander(self.inst, function() return GetLoiterAnchor(self.inst) end, GetWanderDistFn),
        }),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)
    }, .25)

    self.bt = BT(self.inst, root)
end

return BeefaloBrain
