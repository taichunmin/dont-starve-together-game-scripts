require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"

local BrainCommon = require "brains/braincommon"

local TARGET_FOLLOW_DIST = 2.5
local MAX_FOLLOW_DIST = 4.5

local TOY_FOLLOW_DIST = 0.5
local MAX_TOY_FOLLOW_DIST = 1.0

local COMBAT_TOO_CLOSE_DIST = 5                 -- distance for find enitities check
local COMBAT_TOO_CLOSE_DIST_SQ = COMBAT_TOO_CLOSE_DIST * COMBAT_TOO_CLOSE_DIST
local COMBAT_SAFE_TO_WATCH_FROM_DIST = 8        -- will run to this distance and watch if was too close
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST = 12   -- combat is quite far away now, better catch up
local COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ = COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST * COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST
local COMBAT_TIMEOUT = 6

local PLAYFUL_OFFSET = 2

local AVOID_SCARY_DIST = 6
local AVOID_SCARY_STOP = 10

local DEN_WANDER_DIST = 10
local DEN_LEASH_MAX_DIST = DEN_WANDER_DIST + 4
local DEN_LEASH_RETURN_DIST = DEN_WANDER_DIST / 2

local function GetOwner(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function OwnerIsClose(inst)
    local owner = GetOwner(inst)
    return owner ~= nil and owner:IsNear(inst, MAX_FOLLOW_DIST)
end

local function GetDenPos(inst)
    local den = inst.components.entitytracker:GetEntity("home")
    return den ~= nil and den:GetPosition() or nil
end

-------------------------------------------------------------------------------
--  Nuzzle Owner

local function LoveOwner(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local owner = GetOwner(inst)
    return owner ~= nil
        and not owner:HasTag("playerghost")
        and (GetTime() - (inst.sg.mem.prevnuzzletime or 0) > TUNING.CRITTER_NUZZLE_DELAY)
        and math.random() < 0.05
        and BufferedAction(inst, owner, ACTIONS.NUZZLE)
        or nil
end

-------------------------------------------------------------------------------
--  Combat Avoidance (Same as critterbrain)

local function _avoidtargetfn(self, target)
    if target == nil or not target:IsValid() then
        return false
    end

    local owner = self.inst.components.follower.leader
    local owner_combat = owner ~= nil and owner.components.combat or nil
    local target_combat = target.components.combat
    if owner_combat == nil or target_combat == nil then
        return false
    elseif target_combat:TargetIs(owner)
        or (target.components.grouptargeter ~= nil and target.components.grouptargeter:IsTargeting(owner)) then
        return true
    end

    local distsq = owner:GetDistanceSqToInst(target)
    if distsq >= COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST_SQ then
        -- Too far
        return false
    elseif distsq < COMBAT_TOO_CLOSE_DIST_SQ and target_combat:HasTarget() then
        -- Too close to any combat
        return true
    end

    -- Is owner in combat with target?
    -- Are owner and target both in any combat?
    local t = GetTime()
    return  (   (owner_combat:IsRecentTarget(target) or target_combat:HasTarget()) and
                math.max(owner_combat.laststartattacktime or 0, owner_combat.lastdoattacktime or 0) + COMBAT_TIMEOUT > t
            ) or
            (   owner_combat.lastattacker == target and
                owner_combat:GetLastAttackedTime() + COMBAT_TIMEOUT > t
            )
end

local function CombatAvoidanceFindEntityCheck(self)
    return function(ent)
            if _avoidtargetfn(self, ent) then
                self.inst:PushEvent("critter_avoidcombat", {avoid=true})
                self.runawayfrom = ent
                return true
            end
            return false
        end
end

local function ValidateCombatAvoidance(self)
    if self.runawayfrom == nil then
        return false
    end

    if not self.runawayfrom:IsValid() then
        self.inst:PushEvent("critter_avoidcombat", {avoid=false})
        self.runawayfrom = nil
        return false
    end

    if not self.inst:IsNear(self.runawayfrom, COMBAT_SAFE_TO_WATCH_FROM_MAX_DIST) then
        return false
    end

    if not _avoidtargetfn(self, self.runawayfrom) then
        self.inst:PushEvent("critter_avoidcombat", {avoid=false})
        self.runawayfrom = nil
        return false
    end

    return true
end

local function ShouldPanic(inst)
	if inst.components.timer:TimerExists("panic") then 
		return true 
	end

	local den = inst.components.entitytracker:GetEntity("home")
	return den ~= nil and den.components.burnable ~= nil and den.components.burnable:IsBurning()
end

-------------------------------------------------------------------------------
--  Play With Other Kitcoons

local MAX_PLAYFUL_FIND_DIST = 4
local MAX_PLAYFUL_KEEP_DIST = 8

local PLAYMATE_NO_TAGS = {"busy"}
local PLAYMATE_TAGS = {"kitcoon"}
local function PlayWithPlaymate(self)
    self.inst:PushEvent("start_playwithplaymate", {target=self.playfultarget})
	self.playfultarget = nil
end

local function TargetCanPlay(self, target, owner)
	return (target.IsPlayful == nil or target:IsPlayful()) 
			and (target.next_play_time == nil or target.next_play_time <= GetTime())
			and target:IsOnPassablePoint()
			and (target.components.sleeper == nil or not target.components.sleeper:IsAsleep())
end

local function FindPlaymate(self)
	if (self.inst.next_play_time ~= nil and self.inst.next_play_time > GetTime()) then
		return false
	end

    local owner = GetOwner(self.inst)
--    local can_play = (owner ~= nil and self.inst:IsNear(owner, MAX_PLAYFUL_FIND_DIST) and not owner.components.locomotor:WantsToMoveForward())
--					or self.inst.components.entitytracker:GetEntity("home") ~= nil
    local can_play = owner == nil or (not owner.components.locomotor:WantsToMoveForward() and self.inst:IsNear(owner, MAX_PLAYFUL_FIND_DIST))

    -- Try to keep the current playmate
    if can_play and self.playfultarget ~= nil and self.playfultarget:IsValid() and TargetCanPlay(self, self.playfultarget, owner) and self.playfultarget:IsNear(owner or self.inst, MAX_PLAYFUL_KEEP_DIST) then
        return true
    end

    -- Find a new playmate
    self.playfultarget = can_play
		and FindEntity(owner or self.inst, MAX_PLAYFUL_FIND_DIST, function(v) return TargetCanPlay(self, v, owner) end, nil, PLAYMATE_NO_TAGS, PLAYMATE_TAGS)
        or nil

    return self.playfultarget ~= nil
end

-------------------------------------------------------------------------------
-- Play with objects in the world, same as catcoon 
local function restore_toy_tag(targ, tag)
	targ:AddTag(tag)
end

local PLAY_NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO", "stump", "burnt", "notarget", "flight", "fire", "irreplaceable"}
local PLAY_TAGS = {"cattoy", "cattoyairborne", "catfood"}

local function PlayAction(inst)
    if (inst.next_play_time ~= nil and inst.next_play_time > GetTime()) or inst.sg:HasStateTag("busy")  then 
		return
	end

	local search_inst = inst.components.entitytracker:GetEntity("home") or inst

    local target = FindEntity(inst, 4, function(item) 
			local den = inst.components.entitytracker:GetEntity("home")
			return (den == nil or den:IsNear(item, DEN_LEASH_MAX_DIST - 1)) and item:IsOnPassablePoint() end, nil, PLAY_NO_TAGS, PLAY_TAGS)

	if target ~= nil then
		local action = nil
		local cattoyairborne = target:HasTag("cattoyairborne")
		local tag = cattoyairborne and "cattoyairborne" 
					or target:HasTag("cattoy") and "cattoy" 
					or "catfood"

		-- reserve the target so nothing else will play with it while i'm running up to it
		target:RemoveTag(tag)
		target:DoTaskInTime(30, restore_toy_tag, tag)

		inst.next_play_time = GetTime() + TUNING.KITCOON_PLAY_DELAY

		local play_action = BufferedAction(inst, target, cattoyairborne and ACTIONS.CATPLAYAIR or ACTIONS.CATPLAYGROUND)
        if play_action then
            play_action:AddSuccessAction(function()
                inst:PushEvent("on_played_with", target)
            end)
        end
        return play_action
	end
end

local function GetFollowToy(inst)
    return (inst._toy_follow_target ~= nil and inst._toy_follow_target:IsValid()
            and not inst._toy_follow_target:IsInLimbo() and inst._toy_follow_target)
        or nil
end

local function IsBeingNamed(inst)
	return inst.is_being_named
end

-------------------------------------------------------------------------------
--- Minigames
local function WatchingMinigame(inst)
	return (inst.components.follower.leader ~= nil and inst.components.follower.leader.components.minigame_participator ~= nil) and inst.components.follower.leader.components.minigame_participator:GetMinigame() or nil
end
local function WatchingMinigame_MinDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_min or 0
end
local function WatchingMinigame_TargetDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_target or 0
end
local function WatchingMinigame_MaxDist(inst)
	local minigame = WatchingMinigame(inst)
	return minigame ~= nil and minigame.components.minigame.watchdist_max or 0
end

-------------------------------------------------------------------------------
--  Brain

local KitcoonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function KitcoonBrain:OnStart()
	local watch_game = WhileNode( function() return WatchingMinigame(self.inst) end, "Watching Game",
        PriorityNode{
				Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
				RunAway(self.inst, "minigame_participator", 5, 7),
				FaceEntity(self.inst, WatchingMinigame, WatchingMinigame ),
        }, 0.1)
	local find_playmate = WhileNode(function() return FindPlaymate(self) end, "Playful",
		SequenceNode{
			PriorityNode{
				Leash(self.inst, function() return self.playfultarget:GetPosition() end, PLAYFUL_OFFSET, PLAYFUL_OFFSET),
				ActionNode(function() PlayWithPlaymate(self) end),
				StandStill(self.inst),
			},
		})



    local root = PriorityNode({
        StandStill(self.inst, IsBeingNamed, IsBeingNamed),
		
        WhileNode( function() return ShouldPanic(self.inst) end, "Should Panic", 
			Panic(self.inst)),
		
        WhileNode( function() return self.inst.components.follower.leader end, "Has Owner",
            PriorityNode{
                -- Combat Avoidance
                PriorityNode{
                    RunAway(self.inst, {tags={"_combat", "_health"}, notags={"wall", "INLIMBO"}, fn=CombatAvoidanceFindEntityCheck(self)}, COMBAT_TOO_CLOSE_DIST, COMBAT_SAFE_TO_WATCH_FROM_DIST),
                    WhileNode( function() return ValidateCombatAvoidance(self) end, "Is Near Combat",
                        FaceEntity(self.inst, GetOwner, KeepFaceTargetFn)),
                },
				watch_game,
				find_playmate,
                Follow(self.inst, GetOwner, 0, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST, true),
                FailIfRunningDecorator(FaceEntity(self.inst, GetOwner, KeepFaceTargetFn)),
                WhileNode(function() return OwnerIsClose(self.inst) end, "Affection",
                    SequenceNode{
                        WaitNode(4),
                        DoAction(self.inst, LoveOwner),
                    }),
                StandStill(self.inst),
            }),

        Follow(self.inst, GetFollowToy, 0, TOY_FOLLOW_DIST, MAX_TOY_FOLLOW_DIST, true),
		Leash(self.inst, GetDenPos, DEN_LEASH_MAX_DIST, DEN_LEASH_RETURN_DIST, true),
        RunAway(self.inst, {tags={"scarytoprey"}, notags={"player"}}, AVOID_SCARY_DIST, AVOID_SCARY_STOP),
        DoAction(self.inst, PlayAction, "play", false, 5),
		find_playmate,
        Wander(self.inst, function() return GetDenPos(self.inst) end, DEN_WANDER_DIST, {minwalktime = 2, randwalktime = 3, minwaittime = 2, randwaittime = 4 }),
        Wander(self.inst, nil, nil, {minwalktime = 2, randwalktime = 3, minwaittime = 5, randwaittime = 8 }),
    }, .25)
    self.bt = BT(self.inst, root)
end

return KitcoonBrain
