require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/doaction"
--require "behaviours/choptree"
require "behaviours/findlight"
require "behaviours/panic"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 20

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 30

local STOP_RUN_DIST = 30
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local TRADE_DIST = 20
local SEE_FOOD_DIST = 10

local SEE_BURNING_HOME_DIST_SQ = 20*20

local SEE_PLAYER_DIST = 6

local GETTRADER_MUST_TAGS = { "player" }
local FINDFOOD_CANT_TAGS = { "outofreach" }

local function GetTraderFn(inst)
    return FindEntity(inst, TRADE_DIST,
        function(target)
            return inst.components.trader:IsTryingToTradeWithMe(target)
        end, GETTRADER_MUST_TAGS)
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    inst._can_eat_test = inst._can_eat_test or function(item)
        return inst.components.eater:CanEat(item)
    end

    local target =
        (inst.components.inventory ~= nil and
        inst.components.eater ~= nil and
        inst.components.inventory:FindItem(inst._can_eat_test)) or
        nil

    if not target then
        local time_since_eat = inst.components.eater:TimeSinceLastEating()
        if not time_since_eat or (time_since_eat > 2 * TUNING.PIG_MIN_POOP_PERIOD) then
            local noveggie = time_since_eat ~= nil and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD * 4
            target = FindEntity(inst,
                SEE_FOOD_DIST,
                function(item)
                    return item.prefab ~= "mandrake"
                        and item.components.edible ~= nil
                        and (not noveggie or item.components.edible.foodtype == FOODTYPE.MEAT)
                        and inst.components.eater:CanEat(item)
                        and item:GetTimeAlive() >= 8
                        and item:IsOnPassablePoint()
                end,
                nil,
                FINDFOOD_CANT_TAGS
            )
        end
    end

    return (target ~= nil and BufferedAction(inst, target, ACTIONS.EAT)) or nil
end

local function HasValidHome(inst)
    local home = (inst.components.homeseeker ~= nil and inst.components.homeseeker.home) or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
            not inst.components.combat.target and
            HasValidHome(inst) then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function IsHomeOnFire(inst)
    local homeseeker = inst.components.homeseeker
    return homeseeker ~= nil
        and homeseeker.home ~= nil
        and homeseeker.home.components.burnable ~= nil
        and homeseeker.home.components.burnable:IsBurning()
        and inst:GetDistanceSqToInst(homeseeker.home) < SEE_BURNING_HOME_DIST_SQ
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetHomePos(inst)
    return HasValidHome(inst) and inst.components.homeseeker:GetHomePos()
end

local function GetNoLeaderHomePos(inst)
    if GetLeader(inst) then
        return nil
    else
        return GetHomePos(inst)
    end
end

local BunnymanBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BunnymanBrain:OnStart()
    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "RABBIT_PANICBOSS"),
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted",
                ChattyNode(self.inst, "RABBIT_PANICHAUNT",
                    Panic(self.inst))),
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                ChattyNode(self.inst, "RABBIT_PANICFIRE",
                    Panic(self.inst))),
            WhileNode(function() return self.inst.components.health:GetPercent() < TUNING.BUNNYMAN_PANIC_THRESH end, "LowHealth",
                ChattyNode(self.inst, "RABBIT_RETREAT",
                    RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST))),
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
            WhileNode(function() return IsHomeOnFire(self.inst) end, "OnFire",
                ChattyNode(self.inst, "RABBIT_PANICHOUSEFIRE",
                    Panic(self.inst))),
            WhileNode(function() return TheWorld.state.isacidraining end, "IsAcidRaining", -- TODO @stevenm do we need the beardlord restriction...?
                DoAction(self.inst, GoHomeAction, "go home", true ), 1),
            FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
            DoAction(self.inst, FindFoodAction),
            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
            WhileNode(function() return not self.inst.beardlord and TheWorld.state.iscaveday end, "IsDay",
                DoAction(self.inst, GoHomeAction, "go home", true ), 1),
            Leash(self.inst, GetNoLeaderHomePos, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST)
        }, .5)

    self.bt = BT(self.inst, root)
end

return BunnymanBrain
