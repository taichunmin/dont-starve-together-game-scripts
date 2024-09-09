require "behaviours/wander"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/follow"

-------------------------------------------------------------------------------------------------------------

local BrainCommon = require("brains/braincommon")

-------------------------------------------------------------------------------------------------------------

local MIN_FOLLOW_DIST = 3
local TARGET_FOLLOW_DIST = 8
local MAX_FOLLOW_DIST = 12

local MAX_LEASH_DIST = 20
local MAX_WANDER_DIST = 6
local RUN_AWAY_DIST = 4
local STOP_RUN_AWAY_DIST = 8

local MAX_CHASE_DIST = 8
local MAX_CHASE_TIME = 10

-------------------------------------------------------------------------------------------------------------

local function GoHomeAction(inst)
    if inst.components.homeseeker and
       inst.components.homeseeker.home and
       inst.components.homeseeker.home:IsValid()
    then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower:GetLeader() or nil
end

local function WanderTarget(inst)
    local combat = inst.components.combat

    if combat:ValidateTarget() then
        return inst.components.combat.target:GetPosition()
    end

    local leader = GetLeader(inst)

    if leader ~= nil and leader:IsValid() then
        return leader:GetPosition()
    end

    return inst.components.knownlocations:GetLocation("home")
end

local function ShouldGoHome(inst)
    return TheWorld.state.iswinter or (TheWorld.state.isday and not inst.override_stay_out)
end

local function GetNoLeaderHomePos(inst)
    if GetLeader(inst) then
        return nil
    else
        return inst.components.knownlocations:GetLocation("home")
    end
end

local function ShouldChaseAndAttack(inst)
    return inst.components.combat.target == nil or not inst.components.combat:InCooldown()
end

local function ShouldRunAway(inst)
    return inst.components.combat.target ~= nil and inst.components.combat:InCooldown()
end

local function GetRunawayTarget(target, inst)
    return inst.components.combat.target == target
end

-------------------------------------------------------------------------------------------------------------

local WANDERTIMES = { minwalktime=0.1, randwalktime=0.1, minwaittime=0.0, randwaittime=0.0 }

local MosquitoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MosquitoBrain:OnStart()

    local root = PriorityNode(
    {
        BrainCommon.PanicTrigger(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        Leash(self.inst, GetNoLeaderHomePos, MAX_LEASH_DIST, MAX_WANDER_DIST),
        WhileNode(function() return ShouldChaseAndAttack(self.inst) end, "AttackMomentarily", ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST)) ),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "go home", true )),
        WhileNode( function() return ShouldRunAway(self.inst) end, "Dodge", RunAway(self.inst, GetRunawayTarget, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),
        Wander(self.inst, WanderTarget, MAX_WANDER_DIST, WANDERTIMES)
    }, .25)

    self.bt = BT(self.inst, root)
end

function MosquitoBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), true)
end

-------------------------------------------------------------------------------------------------------------

return MosquitoBrain
