require "behaviours/follow"
require "behaviours/wander"

local AbigailBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}

--[[
local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end
]]

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function DanceParty(inst)
    inst:PushEvent("dance")
end

local function ShouldDanceParty(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.sg:HasStateTag("dancing")
end

local function GetTraderFn(inst)
	local leader = inst.components.follower ~= nil and inst.components.follower.leader
	if leader ~= nil then
		return inst.components.trader:IsTryingToTradeWithMe(leader) and leader or nil
	end
end

local function KeepTraderFn(inst, target)
    return inst.components.trader:IsTryingToTradeWithMe(target)
end

local function ShouldWatchMinigame(inst)
	if inst.components.follower.leader ~= nil and inst.components.follower.leader.components.minigame_participator ~= nil then
		if inst.components.combat.target == nil or inst.components.combat.target.components.minigame_participator ~= nil then
			return true
		end
	end
	return false
end

local function WatchingMinigame(inst)
	return (inst.components.follower.leader ~= nil and inst.components.follower.leader.components.minigame_participator ~= nil) and inst.components.follower.leader.components.minigame_participator:GetMinigame() or nil
end

local function DefensiveCanFight(inst)

    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end

    if inst:IsWithinDefensiveRange() then
        return true
    elseif inst._playerlink ~= nil and target ~= nil then
        inst.components.combat:GiveUp()
    end

    return false
end

local MAX_AGGRESSIVE_FIGHT_DSQ = math.pow(TUNING.ABIGAIL_COMBAT_TARGET_DISTANCE + 2, 2)
local function AggressiveCanFight(inst)

    local target = inst.components.combat.target
    if target ~= nil and not inst.auratest(inst, target) then
        inst.components.combat:GiveUp()
        return false
    end

    if inst._playerlink then
        if inst:GetDistanceSqToInst(inst._playerlink) < MAX_AGGRESSIVE_FIGHT_DSQ then
            return true
        elseif target ~= nil then
            inst.components.combat:GiveUp()
        end
    end

    return false
end

function AbigailBrain:OnStart()
	local watch_game = WhileNode( function() return ShouldWatchMinigame(self.inst) end, "Watching Game",
        PriorityNode({
            Follow(self.inst, WatchingMinigame, TUNING.MINIGAME_CROWD_DIST_MIN, TUNING.MINIGAME_CROWD_DIST_TARGET, TUNING.MINIGAME_CROWD_DIST_MAX),
            RunAway(self.inst, "minigame_participator", 5, 7),
            FaceEntity(self.inst, WatchingMinigame, WatchingMinigame),
		}, 0.25))

    --#1 priority is dancing beside your leader. Obviously.
    local dance = WhileNode(function() return ShouldDanceParty(self.inst) end, "Dance Party",
        PriorityNode({
            Leash(self.inst, GetLeaderPos, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW),
            ActionNode(function() DanceParty(self.inst) end),
    }, .25))


    local defensive_mode = WhileNode(function() return self.inst.is_defensive end, "DefensiveMove",
        PriorityNode({
            dance,
            watch_game,

            WhileNode(function() return DefensiveCanFight(self.inst) end, "CanFight",
                ChaseAndAttack(self.inst, TUNING.ABIGAIL_DEFENSIVE_MAX_CHASE_TIME)),

			FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
            Follow(self.inst, function() return self.inst.components.follower.leader end,
                    TUNING.ABIGAIL_DEFENSIVE_MIN_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, TUNING.ABIGAIL_DEFENSIVE_MAX_FOLLOW, true),
            Wander(self.inst, nil, nil, WANDER_TIMING),
        }, .25)
    )


    local aggressive_mode = PriorityNode({
        dance,
        watch_game,

        WhileNode(function() return AggressiveCanFight(self.inst) end, "CanFight",
            ChaseAndAttack(self.inst, TUNING.ABIGAIL_AGGRESSIVE_MAX_CHASE_TIME)),

        FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
        Follow(self.inst, function() return self.inst.components.follower.leader end,
                TUNING.ABIGAIL_AGGRESSIVE_MIN_FOLLOW, TUNING.ABIGAIL_AGGRESSIVE_MED_FOLLOW, TUNING.ABIGAIL_AGGRESSIVE_MAX_FOLLOW, true),
        Wander(self.inst),
    }, .25)

    local root = PriorityNode({
        defensive_mode,
        aggressive_mode,
    }, .25)

    self.bt = BT(self.inst, root)
end

return AbigailBrain
