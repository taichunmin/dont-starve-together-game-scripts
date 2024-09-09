require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/useshield"
local BrainCommon = require("brains/braincommon")

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 6
local MAX_CHASE_TIME = 20
local MAX_CHASE_DIST = 16
local WANDER_DIST = 16

local MIN_FOLLOW_DIST = 4
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 10

local DAMAGE_UNTIL_SHIELD = 200
local AVOID_PROJECTILE_ATTACKS = true
local HIDE_WHEN_SCARED = true
local SHIELD_TIME = 5

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return (target ~= nil and not target:HasTag("notarget") and target)
        or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function CanPickup(item)
    return item.components.inventoryitem.canbepickedup
        and item:GetTimeAlive() >= 8
        and item:IsOnValidGround()
end

local EATFOOD_MUST_TAGS = { "edible_ELEMENTAL", "_inventoryitem" }
local EATFOOD_CANT_TAGS = { "INLIMBO", "fire", "catchable", "outofreach" }

local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    elseif inst.components.inventory ~= nil and inst.components.eater ~= nil then
        inst._can_eat_food_test = inst._can_eat_food_test or function(item)
            return inst.components.eater:CanEat(item)
        end
        local target = inst.components.inventory:FindItem(inst._can_eat_food_test)
        if target then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

    local target = FindEntity(inst, 15, CanPickup, EATFOOD_MUST_TAGS, EATFOOD_CANT_TAGS)
    if target then
        local ba = BufferedAction(inst, target, ACTIONS.PICKUP)
        ba.distance = 1.5
        return ba
    end
end

local function ScaredLoseLoyalty(self)
    local t = GetTime()
    if t >= self.scareendtime then
        self.scaredelay = nil
    elseif not self.scaredelay then
        self.scaredelay = t + 3
    elseif t >= self.scaredelay then
        self.scaredelay = t + 3
        if math.random() < .2 and
                self.inst.components.follower ~= nil and
                self.inst.components.follower:GetLoyaltyPercent() > 0 and
                self.inst.components.follower:GetLeader() ~= nil then
            self.inst.components.follower:SetLeader(nil)
            if self.inst.components.combat then
                self.inst.components.combat:SetTarget(nil)
            end
        end
    end
end

local RockyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function RockyBrain:OnStop()
    if self.onepicscarefn then
        self.inst:RemoveEventCallback("epicscare", self.onepicscarefn)
        self.onepicscarefn = nil
        self.scareendtime = nil
    end
end

function RockyBrain:OnStart()
    if not self.scareendtime then
        self.scareendtime = 0
        self.onepicscarefn = function(inst, data)
            self.scareendtime = math.max(self.scareendtime, data.duration + GetTime() + math.random())
        end
        self.inst:ListenForEvent("epicscare", self.onepicscarefn)
    end

    local root = PriorityNode(
    {
        ParallelNode{
            LoopNode{
                ActionNode(function() ScaredLoseLoyalty(self) end),
            },
            UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS, HIDE_WHEN_SCARED),
        },
		BrainCommon.PanicTrigger(self.inst),
        ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST)),
        DoAction(self.inst, EatFoodAction),
        Follow(self.inst, function(inst)
                return inst.components.follower.leader
            end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function()
                return self.inst.components.knownlocations:GetLocation("herd")
            end, WANDER_DIST),
    }, .25)

    self.bt = BT(self.inst, root)
end

return RockyBrain
