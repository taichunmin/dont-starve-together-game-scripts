require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/avoidlight"
require "behaviours/attackwall"
require "behaviours/useshield"

local BrainCommon = require "brains/braincommon"

local SEE_FOOD_DIST = 10

local TRADE_DIST = 20

local MAX_WANDER_DIST = 32

local DAMAGE_UNTIL_SHIELD = 50
local SHIELD_TIME = 3
local AVOID_PROJECTILE_ATTACKS = false
local HIDE_WHEN_SCARED = true

local SpiderBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local GETTRADER_MUST_TAGS = { "player" }
local function GetTraderFn(inst)
    return inst.components.trader ~= nil
        and FindEntity(inst, TRADE_DIST, function(target) return inst.components.trader:IsTryingToTradeWithMe(target) end, GETTRADER_MUST_TAGS)
        or nil
end

local function KeepTraderFn(inst, target)
    return inst.components.trader ~= nil
        and inst.components.trader:IsTryingToTradeWithMe(target)
end

local EATFOOD_CANT_TAGS = { "outofreach" }
local function EatFoodAction(inst)
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

local function GoHomeAction(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil

    if home ~= nil and ((home.components.burnable ~= nil and home.components.burnable:IsBurning()) or
                        (home.components.freezable ~= nil and home.components.freezable:IsFrozen()) or
                        (home.components.health ~= nil and home.components.health:IsDead())) then
        home = nil
    end 

    return home ~= nil
        and home:IsValid()
        and home.components.childspawner ~= nil
        and (home.components.health == nil or not home.components.health:IsDead())
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

------------------------------------------------------------------------------------------

local function Is_AcidInfusedSpitter(inst)
    if not inst:HasTag("spider_spitter") or inst.components.acidinfusible == nil then
        return false
    end

    if not inst.components.acidinfusible:IsInfused() then
        return false
    end

    return true
end

local function AcidInfusedSpitter_GetFaceTargetFn(inst)
    return Is_AcidInfusedSpitter(inst) and inst.components.combat:InCooldown() and inst.components.combat.target or nil
end

local function AcidInfusedSpitter_KeepFaceTargetFn(inst, target)
    return Is_AcidInfusedSpitter(inst) and inst.components.combat:InCooldown() and inst.components.combat.target == target
end

local function AcidInfusedSpitter_ShouldRunAway(hunter, inst)
    if not Is_AcidInfusedSpitter(inst) then
        return false
    end

    local target = inst.components.combat.target

    if target == nil or target ~= hunter then
        return false
    end

    if inst:IsNear(hunter, TUNING.SPIDER_SPITTER_MELEE_RANGE) and not inst.components.combat:InCooldown() then
        return false
    end

    return true
end

------------------------------------------------------------------------------------------

function SpiderBrain:OnStart()
    local SPITTER_SEE_DIST  = TUNING.SPIDER_SPITTER_ATTACK_RANGE - .5
    local SPITTER_SAFE_DIST = TUNING.SPIDER_SPITTER_ATTACK_RANGE

    local pre_nodes = PriorityNode({
        BrainCommon.PanicWhenScared(self.inst, .3),
		BrainCommon.PanicTrigger(self.inst),
    })

    local post_nodes = PriorityNode({
        DoAction(self.inst, function() return InvestigateAction(self.inst) end ),
            
        WhileNode(function() return (TheWorld.state.iscaveday or self.inst._quaking) and not self.inst.summoned end, "IsDay",
                DoAction(self.inst, function() return GoHomeAction(self.inst) end ) ),
        
        FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    })

    local hider_nodes = PriorityNode({
        IfNode(function() return self.inst:HasTag("spider_hider") end, "IsHider",
                UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS, HIDE_WHEN_SCARED)),
    })

    local attack_nodes = PriorityNode({
        IfNode(function() return not self.inst.bedazzled and self.inst.components.follower.leader == nil end, "AttackWall",
            AttackWall(self.inst)
        ),

        RunAway(self.inst,    AcidInfusedSpitter_ShouldRunAway, SPITTER_SEE_DIST, SPITTER_SAFE_DIST),
        FaceEntity(self.inst, AcidInfusedSpitter_GetFaceTargetFn, AcidInfusedSpitter_KeepFaceTargetFn),

        ChaseAndAttack(self.inst, SpringCombatMod(TUNING.SPIDER_AGGRESSIVE_MAX_CHASE_TIME)),
    })

    local aggressive_follow = PriorityNode({
        DoAction(self.inst, function() return EatFoodAction(self.inst) end ),
        Follow(self.inst, function() return self.inst.components.follower.leader end, 
                TUNING.SPIDER_AGGRESSIVE_MIN_FOLLOW, TUNING.SPIDER_AGGRESSIVE_MED_FOLLOW, TUNING.SPIDER_AGGRESSIVE_MAX_FOLLOW),
    })

    local defensive_follow = PriorityNode({
        Follow(self.inst, function() return self.inst.components.follower.leader end, 
                TUNING.SPIDER_DEFENSIVE_MIN_FOLLOW, TUNING.SPIDER_DEFENSIVE_MED_FOLLOW, TUNING.SPIDER_DEFENSIVE_MAX_FOLLOW),  
    })

    local follow_nodes = PriorityNode({
        IfNode(function() return self.inst.defensive end, "DefensiveFollow",
            defensive_follow),
        
        IfNode(function() return not self.inst.defensive end, "AggressiveFollow",
            aggressive_follow),

        IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn )),
    })

    local root =
        PriorityNode(
        {
            pre_nodes,
            hider_nodes,
            attack_nodes,
            follow_nodes,
            post_nodes,

        }, 1)
        
    self.bt = BT(self.inst, root)
end

function SpiderBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()))

end

return SpiderBrain