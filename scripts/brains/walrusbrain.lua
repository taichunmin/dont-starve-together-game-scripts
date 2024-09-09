require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/follow"
require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local RUN_START_DIST = 5
local RUN_STOP_DIST = 15

local SEE_FOOD_DIST = 10
local MAX_WANDER_DIST = 40
local MAX_CHASE_TIME = 10

local MIN_FOLLOW_DIST = 8
local MAX_FOLLOW_DIST = 15
local TARGET_FOLLOW_DIST = (MAX_FOLLOW_DIST+MIN_FOLLOW_DIST)/2
local MAX_PLAYER_STALK_DISTANCE = 40

local LEASH_RETURN_DIST = 40
local LEASH_MAX_DIST = 80

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 4
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER)/2

local START_FACE_DIST = MAX_FOLLOW_DIST
local KEEP_FACE_DIST = MAX_FOLLOW_DIST

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end

local function GetNoLeaderFollowTarget(inst)
    return GetLeader(inst) == nil
        and FindClosestPlayerToInst(inst, MAX_PLAYER_STALK_DISTANCE, true)
        or nil
end

local function GetHome(inst)
    return inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
end

local function ShouldRunAway(guy)
    return not (guy:HasTag("walrus") or
                guy:HasTag("hound") or
                guy:HasTag("notarget"))
        and (guy:HasTag("character") or
            guy:HasTag("monster"))
end

local EATFOOD_MUST_TAGS = { "edible_MEAT" }
local CHARACTER_TAGS = {"character"}
local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, nil, EATFOOD_MUST_TAGS)
    --check for scary things near the food, or if it's in the water
    if target ~= nil and (not target:IsOnValidGround() or GetClosestInstWithTag(CHARACTER_TAGS, target, RUN_START_DIST) ~= nil) then
        target = nil
    end
    if target ~= nil then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return target.components.inventoryitem == nil or target.components.inventoryitem.owner == nil or target.components.inventoryitem.owner == inst end
        return act
    end
end

local function ShouldGoHomeAtNight(inst)
    return TheWorld.state.isnight
        and GetLeader(inst) == nil
        and GetHome(inst) ~= nil
        and inst.components.combat.target == nil
end

local function ShouldGoHomeScared(inst)
    if not inst:HasTag("taunt_attack") or inst.components.leader:CountFollowers() ~= 0 then
        return false
    end
    local leader = GetLeader(inst)
    return leader == nil or not leader:IsValid()
end

local function GoHomeAction(inst)
    local home = GetHome(inst)
    return home ~= nil
        and home:IsValid()
        and BufferedAction(inst, home, ACTIONS.GOHOME, nil, home:GetPosition())
        or nil
end

local function GetHomeLocation(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetNoLeaderLeashPos(inst)
    if not inst:HasTag("flare_summoned") then
        return GetLeader(inst) == nil and GetHomeLocation(inst) or nil
    end
end

local function CanAttackNow(inst)
    return inst.components.combat.target == nil or not inst.components.combat:InCooldown()
end

local WalrusBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function WalrusBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),

        Leash(self.inst, GetNoLeaderLeashPos, LEASH_MAX_DIST, LEASH_RETURN_DIST),

        RunAway(self.inst, ShouldRunAway, RUN_START_DIST, RUN_STOP_DIST),
        WhileNode(function() return ShouldGoHomeScared(self.inst) end, "ShouldGoHomeScared", DoAction(self.inst, GoHomeAction, "Go Home Scared", true)),

        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER, false),

        WhileNode(function() return CanAttackNow(self.inst) end, "AttackMomentarily", ChaseAndAttack(self.inst, MAX_CHASE_TIME)),
        Follow(self.inst, function() return self.inst.components.combat.target end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, true),

        WhileNode(function() return ShouldGoHomeAtNight(self.inst) end, "ShouldGoHomeAtNight", DoAction(self.inst, GoHomeAction, "Go Home Night")),

        Follow(self.inst, GetNoLeaderFollowTarget, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, false),

        DoAction(self.inst, EatFoodAction, "Eat Food"),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        FaceEntity(self.inst, GetLeader, GetLeader),

        Wander(self.inst, GetHomeLocation, MAX_WANDER_DIST),
    }, .25)

    self.bt = BT(self.inst, root)
end

return WalrusBrain
