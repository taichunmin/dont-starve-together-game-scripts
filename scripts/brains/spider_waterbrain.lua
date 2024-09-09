require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"

local BrainCommon = require "brains/braincommon"

local SpiderWaterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local TRADE_DIST = 20
local GETTRADER_MUST_TAGS = { "player" }
local function GetTraderFn(inst)
    return inst.components.trader ~= nil
        and FindEntity(inst, TRADE_DIST, function(target)
                return inst.components.trader:IsTryingToTradeWithMe(target)
            end, GETTRADER_MUST_TAGS)
        or nil
end

local function KeepTraderFn(inst, target)
    return inst.components.trader ~= nil
        and inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GoHomeAction(inst)
    local home = (inst.components.homeseeker ~= nil and inst.components.homeseeker.home)
        or nil
    return (home ~= nil and home:IsValid())
        and home.components.childspawner ~= nil
        and (home.components.health == nil or not home.components.health:IsDead())
        and (home.components.burnable == nil or not home.components.burnable:IsBurning())
        and BufferedAction(inst, home, ACTIONS.GOHOME)
        or nil
end

local function InvestigateAction(inst)
    local investigatePos = inst.components.knownlocations ~= nil and inst.components.knownlocations:GetLocation("investigate") or nil
    return investigatePos ~= nil and BufferedAction(inst, nil, ACTIONS.INVESTIGATE, nil, investigatePos, nil, 1) or nil
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function fish_target_valid_on_action(ba)
    local target = ba.target
    return target ~= nil
        and not (target.components.inventoryitem and target.components.inventoryitem:IsHeld())
end

local EATFOOD_CANT_TAGS = { "outofreach" }
local SEE_FOOD_DIST = 10
local function EatFoodAction(inst)
    if inst.components.timer:TimerExists("eat_cooldown") then
        return nil
    end

    local target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return inst.components.eater:CanEat(item)
                and item:IsOnValidGround()
                and item:GetTimeAlive() > TUNING.SPIDER_EAT_DELAY
        end,
        nil,
        EATFOOD_CANT_TAGS
    )
    return target ~= nil and BufferedAction(inst, target, ACTIONS.EAT) or nil
end

local SEE_FISH_DISTANCE = 15
local OCEANFISH_TAGS = {"oceanfish"}
local function EatFishAction(inst)
    if inst.components.timer:TimerExists("eat_cooldown") then
        return nil
    end

    -- First, find our own target fish. We wouldn't reach this point if we already had one,
    -- or if our eat cooldown wasn't done (obviously).
    local target_fish = FindEntity(inst, SEE_FISH_DISTANCE,
        function(fish)
            return TheWorld.Map:IsOceanAtPoint(fish.Transform:GetWorldPosition())
        end,
        OCEANFISH_TAGS)
    if not target_fish then
        return nil
    end

    inst._fishtarget = target_fish

    local eat_action = BufferedAction(inst, target_fish, ACTIONS.EAT)
    eat_action.validfn = fish_target_valid_on_action
    return eat_action
end

local MAX_CHASE_TIME = 8
local DEF_MIN_FOLLOW_DIST = 2
local DEF_TARGET_FOLLOW_DIST = 5
local DEF_MAX_FOLLOW_DIST = 8
local AGG_MIN_FOLLOW_DIST = 2
local AGG_TARGET_FOLLOW_DIST = 6
local AGG_MAX_FOLLOW_DIST = 10
local MAX_WANDER_DIST = 32
function SpiderWaterBrain:OnStart()
    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .3),
			BrainCommon.PanicTrigger(self.inst),
            IfNode(function()
                    return not self.inst.bedazzled and self.inst.components.follower.leader == nil
                end, "AttackWall",
                AttackWall(self.inst)
            ),
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME)),

            IfNode(function() return self.inst.defensive end, "DefensiveFollow",
                Follow(self.inst, function()
                        return self.inst.components.follower.leader
                    end,
                    DEF_MIN_FOLLOW_DIST, DEF_TARGET_FOLLOW_DIST, DEF_MAX_FOLLOW_DIST
                )
            ),

            IfNode(function() return not self.inst.defensive end, "AggressiveOrNoFollow",
                PriorityNode({
                    DoAction(self.inst, EatFishAction, "Try Eating A Fish", nil, 15),
                    DoAction(self.inst, EatFoodAction, "Try Eating Food", nil, 15),
                    Follow(self.inst, function()
                            return self.inst.components.follower.leader
                        end,
                        AGG_MIN_FOLLOW_DIST, AGG_TARGET_FOLLOW_DIST, AGG_MAX_FOLLOW_DIST
                    )
                }, 1.0)
            ),

            IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
            ),

            DoAction(self.inst, function()
                return InvestigateAction(self.inst)
            end),

            WhileNode(function()
                    return (TheWorld.state.iscaveday or self.inst._quaking)
                        and not self.inst.summoned
                        and not self.inst.components.timer:TimerExists("investigating")
                end, "IsDay",
                DoAction(self.inst, function()
                    return GoHomeAction(self.inst)
                end)
            ),

            FaceEntity(self.inst, GetTraderFn, KeepTraderFn),

            Wander(self.inst, function()
                    local kl = self.inst.components.knownlocations
                    return (kl ~= nil and kl:GetLocation("home")) or nil
                end,
                MAX_WANDER_DIST
            )
        }, 1.0)

    self.bt = BT(self.inst, root)
end

function SpiderWaterBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))
end

return SpiderWaterBrain
