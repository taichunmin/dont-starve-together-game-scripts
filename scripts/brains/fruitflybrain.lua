require "behaviours/wander"
require "behaviours/chaseandattack"
local BrainCommon = require("brains/braincommon")

local MAX_WANDER_DIST = 15
local GO_HOME_DIST = 30
local SEE_DIST = 20
local RUN_AWAY_DIST = 2
local STOP_RUN_AWAY_DIST = 4

local function CanSpawnChild(inst)
    return inst:GetTimeAlive() > 5
        and inst:NumFruitFliesToSpawn() > 0
        and inst.components.combat:HasTarget() or inst.planttarget or inst.soiltarget
end

local function GetFollowPos(inst)
    if inst.components.follower and inst.components.follower.leader then
        return inst.components.follower.leader:GetPosition()
    elseif inst.components.knownlocations then
        return inst.components.knownlocations:GetLocation("home") or inst:GetPosition()
    end
    return inst:GetPosition()
end

local function GetLeader(inst)
    if inst.components.leader then
        return inst
    elseif inst.components.follower then
        return inst.components.follower.leader
    end
end

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local homePos = GetFollowPos(inst)
    return homePos ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, homePos, nil, .2)
        or nil
end

local function ShouldGoHome(inst)
    local homePos = GetFollowPos(inst)
    return homePos ~= nil and inst:GetDistanceSqToPoint(homePos:Get()) > GO_HOME_DIST * GO_HOME_DIST
end

local function IsNearFollowPos(inst, soil)
    local followpos = GetFollowPos(inst)
    local soilpos = soil:GetPosition()
    return distsq(followpos.x, followpos.z, soilpos.x, soilpos.z) < SEE_DIST * SEE_DIST
end
local SOIL_MUSTTAGS = { "soil" }
local SOIL_CANTTAGS = { "NOCLICK" }
local function SowWeedsAction(inst)
    return inst.soiltarget and BufferedAction(inst, inst.soiltarget, ACTIONS.PLANTWEED, nil, nil, nil, 0.1) or nil
end

local function ShouldSowWeeds(inst)
    inst.soiltarget = FindEntity(inst, SEE_DIST, function(soil)
        local leader = GetLeader(inst)
        return IsNearFollowPos(inst, soil) and (leader == nil or not leader:IsTargetedByOther(inst, soil))
    end, SOIL_MUSTTAGS, SOIL_CANTTAGS)
    return inst.soiltarget ~= nil
end

local function ShouldTargetPlant(inst, plant)
    local leader = GetLeader(inst)
    return leader == nil or not leader:IsTargetedByOther(inst, plant)
end

local FruitFlyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function FruitFlyBrain:OnStart()
    local brain =
    {
		BrainCommon.PanicTrigger(self.inst),
        --LordFruitFly:
            --needs follower
            --AttackMomentarily
            --Dodge
        --FruitFly:
            --lacks leader
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true )),
        FindFarmPlant(self.inst, ACTIONS.ATTACKPLANT, false, GetFollowPos, ShouldTargetPlant),
        WhileNode(function() return ShouldSowWeeds(self.inst) end, "Should Sow Weeds",
            DoAction(self.inst, SowWeedsAction, "Sow Weeds", true )),
        Wander(self.inst, GetFollowPos, MAX_WANDER_DIST),
    }
    if self.inst:HasTag("lordfruitfly") then
        table.insert(brain, 2, MinPeriod(self.inst, TUNING.LORDFRUITFLY_SUMMONPERIOD, false,
                                IfNode(function() return CanSpawnChild(self.inst) end, "needs follower",
                                    ActionNode(function()
                                        self.inst.sg:GoToState("buzz")
                                        return SUCCESS
                                    end, "Summon Mini Fruit Flies"))))

        table.insert(brain, 3, WhileNode(function()
                return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown()
            end, "AttackMomentarily", ChaseAndAttack(self.inst)))

        table.insert(brain, 4, WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)))
    else
        table.insert(brain, 2, WhileNode(function() return self.inst:CanTargetAndAttack() end, "lacks leader", ChaseAndAttack(self.inst)))
    end
    local root = PriorityNode(brain, .25)
    self.bt = BT(self.inst, root)
end

return FruitFlyBrain