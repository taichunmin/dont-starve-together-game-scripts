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

local BrainCommon = require "brains/braincommon"

local MIN_FOLLOW_DIST = 2
local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_WANDER_DIST = 20

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 30

local START_RUN_DIST = 3
local STOP_RUN_DIST = 5
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 30
local SEE_LIGHT_DIST = 20
local TRADE_DIST = 20
local SEE_TREE_DIST = 15
local SEE_TARGET_DIST = 20
local SEE_FOOD_DIST = 10

local SEE_BURNING_HOME_DIST_SQ = 20*20

local COMFORT_LIGHT_LEVEL = 0.3

local KEEP_CHOPPING_DIST = 10

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local function ShouldRunAway(inst, target)
    return not inst.components.trader:IsTryingToTradeWithMe(target)
end

local function GetTraderFn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TRADE_DIST, true)
    for i, v in ipairs(players) do
        if inst.components.trader:IsTryingToTradeWithMe(v) then
            return v
        end
    end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local FINDFOOD_CANT_TAGS = { "outofreach" }
local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target ~= nil then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

	if inst.components.minigame_spectator ~= nil then
		return
	end

    local time_since_eat = inst.components.eater:TimeSinceLastEating()
    if time_since_eat ~= nil and time_since_eat <= TUNING.PIG_MIN_POOP_PERIOD * 2 then
        return
    end

    local noveggie = time_since_eat ~= nil and time_since_eat < TUNING.PIG_MIN_POOP_PERIOD * 4

    local target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return item:GetTimeAlive() >= 8
                and item.prefab ~= "mandrake"
                and item.components.edible ~= nil
                and (not noveggie or item.components.edible.foodtype == FOODTYPE.MEAT)
                and item:IsOnPassablePoint()
                and inst.components.eater:CanEat(item)
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return item.components.shelf ~= nil
                and item.components.shelf.itemonshelf ~= nil
                and item.components.shelf.cantakeitem
                and item.components.shelf.itemonshelf.components.edible ~= nil
                and (not noveggie or item.components.shelf.itemonshelf.components.edible.foodtype == FOODTYPE.MEAT)
                and item:IsOnPassablePoint()
                and inst.components.eater:CanEat(item.components.shelf.itemonshelf)
        end,
        nil,
        FINDFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end
end

local function IsDeciduousTreeMonster(guy)
    return guy.monster and guy.prefab == "deciduoustree"
end

local CHOP_MUST_TAGS = { "CHOP_workable" }
local function FindDeciduousTreeMonster(inst)
    return FindEntity(inst, SEE_TREE_DIST / 3, IsDeciduousTreeMonster, CHOP_MUST_TAGS)
end

local function KeepChoppingAction(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, KEEP_CHOPPING_DIST))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function StartChoppingCondition(inst)
    return inst.tree_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst.components.follower.leader.sg ~= nil and
            inst.components.follower.leader.sg:HasStateTag("chopping"))
        or FindDeciduousTreeMonster(inst) ~= nil
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_TREE_DIST, nil, CHOP_MUST_TAGS)
    if target ~= nil then
        if inst.tree_target ~= nil then
            target = inst.tree_target
            inst.tree_target = nil
        else
            target = FindDeciduousTreeMonster(inst) or target
        end
        return BufferedAction(inst, target, ACTIONS.CHOP)
    end
end

local function HasValidHome(inst)
    local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
    return home ~= nil
        and home:IsValid()
        and not (home.components.burnable ~= nil and home.components.burnable:IsBurning())
        and not home:HasTag("burnt")
end

local function GoHomeAction(inst)
    if not inst.components.follower.leader and
        HasValidHome(inst) and
        not inst.components.combat.target then
            return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
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
    end
    return GetHomePos(inst)
end

local LIGHTSOURCE_TAGS = {"lightsource"}
local function GetNearestLightPos(inst)
    local light = GetClosestInstWithTag(LIGHTSOURCE_TAGS, inst, SEE_LIGHT_DIST)
    if light then
        return Vector3(light.Transform:GetWorldPosition())
    end
    return nil
end

local function GetNearestLightRadius(inst)
    local light = GetClosestInstWithTag(LIGHTSOURCE_TAGS, inst, SEE_LIGHT_DIST)
    if light then
        return light.Light:GetCalculatedRadius()
    end
    return 1
end

local function RescueLeaderAction(inst)
    return BufferedAction(inst, GetLeader(inst), ACTIONS.UNPIN)
end

local function WantsToGivePlayerPigTokenAction(inst)
	local leader = GetLeader(inst)
	return leader ~= nil and inst.components.follower:GetLoyaltyPercent() >= TUNING.PIG_FULL_LOYALTY_PERCENT and inst.components.inventory:Has(inst._pig_token_prefab, 1)
end

local function GivePlayerPigTokenAction(inst)
	local leader = GetLeader(inst)
	if leader ~= nil then
		local note = next(inst.components.inventory:GetItemByName(inst._pig_token_prefab, 1))
		if note ~= nil then
			return BufferedAction(inst, leader, ACTIONS.DROP, note)
		end
	end
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFaceTargetNearestPlayerFn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	return FindClosestPlayerInRange(x, y, z, START_RUN_DIST + 1, true)
end

local function KeepFaceTargetNearestPlayerFn(inst, target)
    return GetFaceTargetNearestPlayerFn(inst) == target
end

local function SafeLightDist(inst, target)
    return (target:HasTag("player") or target:HasTag("playerlight")
            or (target.inventoryitem and target.inventoryitem:GetGrandOwner() and target.inventoryitem:GetGrandOwner():HasTag("player")))
        and 4
        or target.Light:GetCalculatedRadius() / 3
end

local function IsHomeOnFire(inst)
    return inst.components.homeseeker
        and inst.components.homeseeker.home
        and inst.components.homeseeker.home.components.burnable
        and inst.components.homeseeker.home.components.burnable:IsBurning()
        and inst:GetDistanceSqToInst(inst.components.homeseeker.home) < SEE_BURNING_HOME_DIST_SQ
end

local function WatchingMinigame(inst)
	return inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame()
end

local function WatchingMinigame_MinDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_min
end
local function WatchingMinigame_TargetDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_target
end
local function WatchingMinigame_MaxDist(inst)
	return inst.components.minigame_spectator:GetMinigame().components.minigame.watchdist_max
end

local function WatchingCheaters(inst)
    local minigame = WatchingMinigame(inst) or nil
    if minigame ~= nil and minigame._minigame_elites ~= nil then
        for k, v in pairs(minigame._minigame_elites) do
            if k:WasCheated() then
                return minigame
            end
        end
    end
end


local function WatchingCheaters(inst)
    local minigame = WatchingMinigame(inst) or nil
    if minigame ~= nil and minigame._minigame_elites ~= nil then
        for k, v in pairs(minigame._minigame_elites) do
            if k:WasCheated() then
                return minigame
            end
        end
    end
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

local function IsWatchingMinigameIntro(inst)
	local minigame = inst.components.minigame_spectator ~= nil and inst.components.minigame_spectator:GetMinigame() or nil
	return minigame ~= nil and minigame.sg ~= nil and minigame.sg:HasStateTag("intro")
end

local function GetGameLocation(inst)
	return inst.components.knownlocations:GetLocation("pigking")
end

local PigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function PigBrain:OnStart()
    --print(self.inst, "PigBrain:OnStart")

    local in_contest = WhileNode( function() return self.inst:HasTag("NPC_contestant") end, "In contest",
        PriorityNode({
--            IfNode(function() return self.inst.yotb_post_to_mark end, "mark post",
                DoAction(self.inst, CollctPrize, "collect prize", true ),
                DoAction(self.inst, MarkPost, "mark post", true ),   --)
            WhileNode( function() return self.inst.components.timer and self.inst.components.timer:TimerExists("contest_panic") end, "Panic Contest",
                ChattyNode(self.inst, "PIG_TALK_CONTEST_PANIC",
                    Panic(self.inst))),
            ChattyNode(self.inst, "PIG_TALK_CONTEST_OOOH",
                FaceEntity(self.inst, CurrentContestTarget, CurrentContestTarget ), 5, 15),
        }, 0.1))

	local watch_game = WhileNode( function() return WatchingMinigame(self.inst) end, "Watching Game",
        PriorityNode({
			IfNode(function() return WatchingMinigame(self.inst).components.minigame.gametype == "pigking_wrestling" end, "Is Pig King Wrestling",
				PriorityNode({
					ChattyNode(self.inst, "PIG_TALK_GAME_GOTO",
						Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist)),
					WhileNode(function() return IsWatchingMinigameIntro(self.inst) end, "Is Intro",
						PriorityNode({
							RunAway(self.inst, "minigame_participator", 5, 7),
							ChattyNode(self.inst, "PIG_TALK_FIND_MEAT",
								DoAction(self.inst, FindFoodAction )),
							FaceEntity(self.inst, WatchingMinigame, WatchingMinigame),
						}, 0.1)),
					ChattyNode(self.inst, "PIG_TALK_GAME_CHEER",
						RunAway(self.inst, "minigame_participator", 5, 7)),
					ChattyNode(self.inst, "PIG_TALK_FIND_MEAT",
						DoAction(self.inst, FindFoodAction )),
					ChattyNode(self.inst, "PIG_ELITE_SALTY",
						FaceEntity(self.inst, WatchingCheaters, WatchingCheaters ), 5, 15),
					ChattyNode(self.inst, "PIG_TALK_GAME_CHEER",
						FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ), 5, 15),
				}, 0.1)
			),
			PriorityNode({
				ChattyNode(self.inst, "PIG_TALK_MISC_GAME_GOTO",
					Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist)),
				ChattyNode(self.inst, "PIG_TALK_MISC_GAME_CHEER",
					RunAway(self.inst, "minigame_participator", 5, 7)),
				ChattyNode(self.inst, "PIG_TALK_FIND_MEAT",
					DoAction(self.inst, FindFoodAction )),
				ChattyNode(self.inst, "PIG_TALK_MISC_GAME_CHEER",
					FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ), 5, 15),
			}, 0.1),
        }, 0.1)
	)

    local day = WhileNode( function() return TheWorld.state.isday end, "IsDay",
        PriorityNode{
            ChattyNode(self.inst, "PIG_TALK_FIND_MEAT",
                DoAction(self.inst, FindFoodAction )),
            IfThenDoWhileNode(function() return StartChoppingCondition(self.inst) end, function() return KeepChoppingAction(self.inst) end, "chop",
                LoopNode{
                    ChattyNode(self.inst, "PIG_TALK_HELP_CHOP_WOOD",
                        DoAction(self.inst, FindTreeToChopAction ))}),
            ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
            IfNode(function() return GetLeader(self.inst) end, "has leader",
                ChattyNode(self.inst, "PIG_TALK_FOLLOWWILSON",
                    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn ))),

            Leash(self.inst, GetNoLeaderHomePos, LEASH_MAX_DIST, LEASH_RETURN_DIST),

            ChattyNode(self.inst, "PIG_TALK_RUNAWAY_WILSON",
                RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST)),
            ChattyNode(self.inst, "PIG_TALK_LOOKATWILSON",
                FaceEntity(self.inst, GetFaceTargetNearestPlayerFn, KeepFaceTargetNearestPlayerFn)),
            Wander(self.inst, GetNoLeaderHomePos, MAX_WANDER_DIST)
        }, .5)

    local night = WhileNode( function() return not TheWorld.state.isday end, "IsNight",
        PriorityNode{
            ChattyNode(self.inst, "PIG_TALK_RUN_FROM_SPIDER",
                RunAway(self.inst, "spider", 4, 8)),
            ChattyNode(self.inst, "PIG_TALK_FIND_MEAT",
                DoAction(self.inst, FindFoodAction )),
            RunAway(self.inst, "player", START_RUN_DIST, STOP_RUN_DIST, function(target) return ShouldRunAway(self.inst, target) end ),
            ChattyNode(self.inst, "PIG_TALK_GO_HOME",
                WhileNode( function() return not TheWorld.state.iscaveday or not self.inst:IsInLight() end, "Cave nightness",
                    DoAction(self.inst, GoHomeAction, "go home", true ))),
            WhileNode(function() return TheWorld.state.isnight and self.inst:IsLightGreaterThan(COMFORT_LIGHT_LEVEL) end, "IsInLight", -- wants slightly brighter light for this
                Wander(self.inst, GetNearestLightPos, GetNearestLightRadius, {
                    minwalktime = 0.6,
                    randwalktime = 0.2,
                    minwaittime = 5,
                    randwaittime = 5
                })
            ),
            ChattyNode(self.inst, "PIG_TALK_FIND_LIGHT",
                FindLight(self.inst, SEE_LIGHT_DIST, SafeLightDist)),
            ChattyNode(self.inst, "PIG_TALK_PANIC",
                Panic(self.inst)),
        }, 1)

    local root =
        PriorityNode(
        {
            BrainCommon.PanicWhenScared(self.inst, .25, "PIG_TALK_PANICBOSS"),
            WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted",
                ChattyNode(self.inst, "PIG_TALK_PANICHAUNT",
                    Panic(self.inst))),
            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
                ChattyNode(self.inst, "PIG_TALK_PANICFIRE",
                    Panic(self.inst))),
            ChattyNode(self.inst, "PIG_TALK_FIGHT",
                WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                    ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST) )),
            ChattyNode(self.inst, "PIG_TALK_RESCUE",
                WhileNode( function() return GetLeader(self.inst) and GetLeader(self.inst).components.pinnable and GetLeader(self.inst).components.pinnable:IsStuck() end, "Leader Phlegmed",
                    DoAction(self.inst, RescueLeaderAction, "Rescue Leader", true) )),
            ChattyNode(self.inst, "PIG_TALK_FIGHT",
                WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                    RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) )),
            WhileNode(function() return IsHomeOnFire(self.inst) end, "OnFire",
                ChattyNode(self.inst, "PIG_TALK_PANICHOUSEFIRE",
                    Panic(self.inst))),
            RunAway(self.inst, function(guy) return guy:HasTag("pig") and guy.components.combat and guy.components.combat.target == self.inst end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST ),
            ChattyNode(self.inst, "PIG_TALK_ATTEMPT_TRADE",
                FaceEntity(self.inst, GetTraderFn, KeepTraderFn)),
            ChattyNode(self.inst, "PIG_TALK_GIVE_GIFT",
                WhileNode( function() return WantsToGivePlayerPigTokenAction(self.inst) end, "Wants To Give Token", -- todo: check for death and valid
                    DoAction(self.inst, GivePlayerPigTokenAction, "Giving Token", true) )),
            in_contest,
			watch_game,
            day,
            night,
        }, .5)

    self.bt = BT(self.inst, root)
end

return PigBrain
