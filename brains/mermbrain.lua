require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/follow"

local BrainCommon = require "brains/braincommon"

local SEE_PLAYER_DIST     = 5
local SEE_FOOD_DIST       = 10
local MAX_WANDER_DIST     = 15
local MAX_CHASE_TIME      = 10
local MAX_CHASE_DIST      = 20
local RUN_AWAY_DIST       = 5
local STOP_RUN_AWAY_DIST  = 8

local MIN_FOLLOW_DIST     = 1
local TARGET_FOLLOW_DIST  = 5
local MAX_FOLLOW_DIST     = 9

local SEE_THRONE_DISTANCE = 50

local FACETIME_BASE       = 2
local FACETIME_RAND       = 2


local MermBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local shouldface = inst.components.follower.leader or FindClosestPlayerToInst(inst, SEE_PLAYER_DIST, true)
    if shouldface and not inst.components.timer:TimerExists("facetime") then
        inst.components.timer:StartTimer("facetime", FACETIME_BASE + math.random()*FACETIME_RAND)
    end
    return shouldface
end

local function KeepFaceTargetFn(inst, target)
    if inst.components.timer:TimerExists("dontfacetime") then
        return nil
    end
    local keepface = (inst.components.follower.leader and inst.components.follower.leader == target) or (target:IsValid() and inst:IsNear(target, SEE_PLAYER_DIST))
    if not keepface then
        inst.components.timer:StopTimer("facetime")
    end
    return keepface
end


local EATFOOD_MUST_TAGS = { "edible_VEGGIE" }
local EATFOOD_CANOT_TAGS = { "INLIMBO" }
local SCARY_TAGS = { "scarytoprey" }
local function EatFoodAction(inst)
    if inst.sg:HasStateTag("waking") then
        return
    end

    local target = nil
    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
    end
    if target == nil and inst.components.follower.leader == nil then
        target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end, EATFOOD_MUST_TAGS, EATFOOD_CANOT_TAGS)
        --check for scary things near the food
        if target ~= nil and (GetClosestInstWithTag(SCARY_TAGS, target, SEE_PLAYER_DIST) ~= nil or not target:IsOnValidGround()) then  -- NOTE this ValidGround check should be removed if merms start swimming
            target = nil
        end
    end
    if target ~= nil then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return target.components.inventoryitem == nil or target.components.inventoryitem.owner == nil or target.components.inventoryitem.owner == inst end
        return act
    end
end


-----------------------------------------------------------------------------------------------
-- Merm king things
local function IsThroneValid(inst)
    if TheWorld.components.mermkingmanager then
        local throne = TheWorld.components.mermkingmanager:GetThrone(inst)
        return throne ~= nil
            and throne:IsValid()
            and not (throne.components.burnable ~= nil and throne.components.burnable:IsBurning())
            and not throne:HasTag("burnt")
            and TheWorld.components.mermkingmanager:ShouldGoToThrone(inst, throne)
    end

    return false
end

local GOTOTHRONE_TAGS = { "mermthrone" }
local function ShouldGoToThrone(inst)
    if TheWorld.components.mermkingmanager then
        local throne = TheWorld.components.mermkingmanager:GetThrone(inst)
        if throne == nil then
            throne = FindEntity(inst, SEE_THRONE_DISTANCE, nil, GOTOTHRONE_TAGS)
        end

        return throne and TheWorld.components.mermkingmanager:ShouldGoToThrone(inst, throne)
    end

    return false
end

local function GetThronePosition(inst)
    if TheWorld.components.mermkingmanager then
        local throne = TheWorld.components.mermkingmanager:GetThrone(inst)
        if throne then
            return throne:GetPosition()
        end
    end
end

-----------------------------------------------------------------------------------------------

local function GoHomeAction(inst)
    if inst.components.combat.target ~= nil then
        return
    end
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
        and BufferedAction(inst, home, ACTIONS.GOHOME)
        or nil
end

local function ShouldGoHome(inst)
    if not TheWorld.state.isday or (inst.components.follower ~= nil and inst.components.follower.leader ~= nil) then
        return false
    end

    --one merm should stay outside
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home == nil
        or home.components.childspawner == nil
        or home.components.childspawner:CountChildrenOutside() > 1
end

local function IsHomeOnFire(inst)
    return inst.components.homeseeker
        and inst.components.homeseeker.home
        and inst.components.homeseeker.home.components.burnable
        and inst.components.homeseeker.home.components.burnable:IsBurning()
end

local function GetNoLeaderHomePos(inst)
    if inst.components.follower and inst.components.follower.leader ~= nil then
        return nil
    end

    return inst.components.knownlocations:GetLocation("home")
end

local function CurrentContestTarget(inst)
    local stage = inst.npc_stage
    if stage.current_contest_target then
        return stage.current_contest_target
    else
        return stage
    end
end

local function MarkPost(inst)
    if inst.yotb_post_to_mark ~= nil then
        return BufferedAction(inst, inst.yotb_post_to_mark, ACTIONS.MARK)
    end
end


local function CollctPrize(inst)
    if inst.yotb_prize_to_collect ~= nil then
        local x,y,z = inst.yotb_prize_to_collect.Transform:GetWorldPosition()
        if y < 0.1 and y > -0.1 and not inst.yotb_prize_to_collect:HasTag("INLIMBO") then
            return BufferedAction(inst, inst.yotb_prize_to_collect, ACTIONS.PICKUP)
        end
    end
end

function MermBrain:OnStart()

    local in_contest = WhileNode( function() return self.inst:HasTag("NPC_contestant") end, "In contest",
        PriorityNode({
--            IfNode(function() return self.inst.yotb_post_to_mark end, "mark post",
                DoAction(self.inst, CollctPrize, "collect prize", true ),
                DoAction(self.inst, MarkPost, "mark post", true ),   --)
            WhileNode( function() return self.inst.components.timer and self.inst.components.timer:TimerExists("contest_panic") end, "Panic Contest",
                ChattyNode(self.inst, "MERM_TALK_CONTEST_PANIC",
                    Panic(self.inst))),
            ChattyNode(self.inst, "MERM_TALK_CONTEST_OOOH",
                FaceEntity(self.inst, CurrentContestTarget, CurrentContestTarget ), 5, 15),
        }, 0.1))


    local root = PriorityNode(
    {
        IfNode(function() return TheWorld.components.mermkingmanager and TheWorld.components.mermkingmanager.king end,"panic with king",
            BrainCommon.PanicWhenScared(self.inst, .25, "MERM_TALK_PANICBOSS_KING")),
        IfNode(function() return not TheWorld.components.mermkingmanager or not TheWorld.components.mermkingmanager.king  end,"panic with no king",
            BrainCommon.PanicWhenScared(self.inst, .25, "MERM_TALK_PANICBOSS")),
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
            ChaseAndAttack(self.inst, SpringCombatMod(MAX_CHASE_TIME), SpringCombatMod(MAX_CHASE_DIST))),
        WhileNode(function() return self.inst.components.combat.target ~= nil and self.inst.components.combat:InCooldown() end, "Dodge",
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),

        in_contest,

        ChattyNode(self.inst, "MERM_TALK_FIND_FOOD",
            DoAction(self.inst, EatFoodAction, "Eat Food")),

        WhileNode(function() return ShouldGoToThrone(self.inst) and self.inst.components.combat.target == nil end, "ShouldGoToThrone",
            PriorityNode({
                Leash(self.inst, GetThronePosition, 0.2, 0.2, true),
                IfNode(function() return IsThroneValid(self.inst) end, "IsThroneValid",
                    ActionNode(function() self.inst:PushEvent("onarrivedatthrone") end)
                ),
            }, .25)),

        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "CHOP", -- Required.
            chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
        }),

        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "MINE", -- Required.
            chatterstring = "MERM_TALK_HELP_MINE_ROCK",
        }),

        ChattyNode(self.inst, "MERM_TALK_FOLLOWWILSON",
		  Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),

        IfNode(function() return self.inst.components.follower.leader ~= nil end, "HasLeader",
            ChattyNode(self.inst, "MERM_TALK_FOLLOWWILSON",
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn ))),


        WhileNode( function() return IsHomeOnFire(self.inst) end, "HomeOnFire", Panic(self.inst)),

        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true)),

        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST),
    }, .25)

    self.bt = BT(self.inst, root)
end

return MermBrain
