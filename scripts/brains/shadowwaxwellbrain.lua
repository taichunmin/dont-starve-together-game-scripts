require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/follow"
require "behaviours/attackwall"
require "behaviours/standstill"
require "behaviours/leash"
require "behaviours/runaway"

local BrainCommon = require("brains/braincommon")

local ShadowWaxwellBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

--Images will help chop, mine and fight.

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local START_FACE_DIST = 4
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 14
local SEE_WORK_DIST = 10

local KEEP_DANCING_DIST = 2

local KITING_DIST = 3
local STOP_KITING_DIST = 5

local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local AVOID_EXPLOSIVE_DIST = 5

local DIG_TAGS = { "stump", "grave", "farm_debris" }

local WANDER_TIMING = {minwaittime = 6, randwaittime = 6}

local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end
local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] ~= nil and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = {worker = worker,}
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function GetFaceLeaderFn(inst)
	local target = GetLeader(inst)
	return target ~= nil and target.entity:IsVisible() and inst:IsNear(target, START_FACE_DIST) and target or nil
end

local function KeepFaceLeaderFn(inst, target)
	return target.entity:IsVisible() and inst:IsNear(target, KEEP_FACE_DIST)
end

local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, dist)
end

local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO", "NOCLICK", "carnivalgame_part" }
local function FindEntityToWorkAction(inst, action, addtltags) -- DEPRECATED, use FindAnyEntityToWorkActionsOn.
    local leader = GetLeader(inst)
    if leader ~= nil then
        --Keep existing target?
        local target = inst.sg.statemem.target
        if target ~= nil and
            target:IsValid() and
            not (target:IsInLimbo() or
                target:HasTag("NOCLICK") or
                target:HasTag("event_trigger")) and
            target:IsOnValidGround() and
            target.components.workable ~= nil and
            target.components.workable:CanBeWorked() and
            target.components.workable:GetWorkAction() == action and
            not (target.components.burnable ~= nil
                and (target.components.burnable:IsBurning() or
                    target.components.burnable:IsSmoldering())) and
            target.entity:IsVisible() and
            target:IsNear(leader, KEEP_WORKING_DIST) then

            if addtltags ~= nil then
                for i, v in ipairs(addtltags) do
                    if target:HasTag(v) then
                        return BufferedAction(inst, target, action)
                    end
                end
            else
                return BufferedAction(inst, target, action)
            end
        end

        --Find new target
        target = FindEntity(leader, SEE_WORK_DIST, nil, { action.id.."_workable" }, TOWORK_CANT_TAGS, addtltags)
        return target ~= nil and BufferedAction(inst, target, action) or nil
    end
end

local ANY_TOWORK_ACTIONS = {ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.DIG}
local ANY_TOWORK_MUSTONE_TAGS = {"CHOP_workable", "MINE_workable", "DIG_workable"}
local function PickValidActionFrom(target)
    if target.components.workable == nil then
        return nil
    end

    local desiredact = target.components.workable:GetWorkAction()
    for _, act in ipairs(ANY_TOWORK_ACTIONS) do
        if desiredact == act then
            return act
        end
    end
    return nil
end
local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker)
    for _, sometarget in ipairs(targets) do
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- Ignore me!
        elseif sometarget.components.burnable == nil or (not sometarget.components.burnable:IsBurning() and not sometarget.components.burnable:IsSmoldering()) then
            if sometarget:HasTag("DIG_workable") then
                for _, tag in ipairs(DIG_TAGS) do
                    if sometarget:HasTag(tag) then
                        if sometarget.components.workable:GetWorkLeft() == 1 then
                            IgnoreThis(sometarget, ignorethese, leader, worker)
                        end
                        return sometarget
                    end
                end
            else -- CHOP_workable and MINE_workable has no special cases to handle.
                if sometarget.components.workable:GetWorkLeft() == 1 then
                    IgnoreThis(sometarget, ignorethese, leader, worker)
                end
                return sometarget
            end
        end
    end
    return nil
end

local function GetSpawn(inst)
	return inst.GetSpawnPoint ~= nil and inst:GetSpawnPoint() or nil
end

local function FindAnyEntityToWorkActionsOn(inst, ignorethese) -- This is similar to FindEntityToWorkAction, but to be very mod safe FindEntityToWorkAction has been deprecated.
	if inst.sg:HasStateTag("busy") then
		return nil
	end
    local leader = GetLeader(inst)
    if leader == nil then -- There is no purpose for a puppet without strings attached.
        return nil
    end

    local target = inst.sg.statemem.target
    local action = nil
    if target ~= nil and target:IsValid() and not (target:IsInLimbo() or target:HasTag("NOCLICK") or target:HasTag("event_trigger") or target:HasTag("waxedplant")) and
        target:IsOnValidGround() and target.components.workable ~= nil and target.components.workable:CanBeWorked() and
        not (target.components.burnable ~= nil and (target.components.burnable:IsBurning() or target.components.burnable:IsSmoldering())) and
        target.entity:IsVisible() then
        -- Check if action is the one desired still.
        action = PickValidActionFrom(target)

        if action ~= nil and ignorethese[target] == nil then
            if target.components.workable:GetWorkLeft() == 1 then
                IgnoreThis(target, ignorethese, leader, inst)
            end
            return BufferedAction(inst, target, action)
        end
    end
    -- 'target' is invalid at this point, find a new one.

    local spawn = GetSpawn(inst)
    if spawn == nil then
        return nil
    end

    local px, py, pz = inst.Transform:GetWorldPosition()
    local target = FilterAnyWorkableTargets(TheSim:FindEntities(px, py, pz, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    if target ~= nil then
        local maxdist = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS + TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL
        local dx, dz = px - spawn.x, pz - spawn.z
        if dx * dx + dz * dz > maxdist * maxdist then
            target = nil
        end
    end
    if target == nil then
        target = FilterAnyWorkableTargets(TheSim:FindEntities(spawn.x, spawn.y, spawn.z, TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS), ignorethese, leader, inst)
    end
    action = target ~= nil and PickValidActionFrom(target) or nil
    return action ~= nil and BufferedAction(inst, target, action) or nil
end

local function DanceParty(inst)
    inst:PushEvent("dance")
end

local function ShouldDanceParty(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.sg:HasStateTag("dancing")
end

local function ShouldAvoidExplosive(target)
    return target.components.explosive == nil
        or target.components.burnable == nil
        or target.components.burnable:IsBurning()
end

local function ShouldRunAway(target, inst)
	if target.components.health ~= nil and target.components.health:IsDead() then
		return false
	elseif target:HasTag("shadowcreature") then
		if target.HostileToPlayerTest ~= nil then
			local leader = GetLeader(inst)
			return leader ~= nil and target:HostileToPlayerTest(leader)
		end
		return false
	elseif target:HasTag("stalker") then
		return target.atriumstalker
			or (target.canfight and target.components.combat ~= nil and target.components.combat:HasTarget())
	end
	return true
end

local function ShouldKite(target, inst)
    return inst.components.combat:TargetIs(target)
        and target.components.health ~= nil
        and not target.components.health:IsDead()
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

local function CreateWanderer(self, maxdist)
    return Wander(self.inst,
		function() return GetSpawn(self.inst) end,
        maxdist,
        nil, nil, nil, nil,
        { -- Small wander radius with a dapper stroll.
            should_run = false,
            wander_dist = 4,
        }
    )
end

local function CreateIdleOblivion(self, delay, range)
	range = range * range
	return LoopNode{
		WaitNode(delay),
		ActionNode(function()
			local leader = GetLeader(self.inst)
			local spawnpt = GetSpawn(self.inst)
			--NOTE: range is squared already
			if leader ~= nil and spawnpt ~= nil and leader:GetDistanceSqToPoint(spawnpt) >= range then
				self.inst:PushEvent("seekoblivion")
			end
		end),
	}
end

local COMBAT_TIMEOUT = 6
local function IsLeaderInCombat(leader)
    local leader_combat = leader.components.combat
    if leader_combat == nil then
        -- Leader can not attack nor be attacked by standard means.
        return false
    end

    local timeout_time = GetTime() - COMBAT_TIMEOUT
    local attack_time = math.max(leader_combat.laststartattacktime or 0, leader_combat.lastdoattacktime or 0)
    if attack_time > timeout_time then
        -- Recently attacked something.
        return true
    end

    if leader_combat:GetLastAttackedTime() > timeout_time then
        -- Recent damage.
        if leader_combat.lastattacker ~= nil and leader_combat.lastattacker.components.combat == nil then
            -- Done by something that is unable to attack, presume environmental.
            return false
        end
        return true
    end

    -- No threats known at this time.
    return false
end

function ShadowWaxwellBrain:OnStart()
    -- Common AI for most of the shadow minions.
	local watch_game = WhileNode( function() return ShouldWatchMinigame(self.inst) end, "Watching Game",
        PriorityNode({
            Follow(self.inst, WatchingMinigame, WatchingMinigame_MinDist, WatchingMinigame_TargetDist, WatchingMinigame_MaxDist),
            RunAway(self.inst, "minigame_participator", 5, 7),
            FaceEntity(self.inst, WatchingMinigame, WatchingMinigame),
        }, 0.25))
    
    local dance_party = WhileNode(function() return ShouldDanceParty(self.inst) end, "Dance Party",
            PriorityNode({
                Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
                ActionNode(function() DanceParty(self.inst) end),
        }, 0.25))

    local avoid_explosions = RunAway(self.inst, { fn = ShouldAvoidExplosive, tags = { "explosive" }, notags = { "INLIMBO" } }, AVOID_EXPLOSIVE_DIST, AVOID_EXPLOSIVE_DIST)
    local avoid_danger = RunAway(self.inst, { fn = ShouldRunAway, oneoftags = { "monster", "hostile" }, notags = { "player", "INLIMBO", "companion", "spiderden" } }, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)

    local face_player = WhileNode(function() return GetLeader(self.inst) ~= nil end, "Face Player",
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn))

	local face_leader = FaceEntity(self.inst, GetFaceLeaderFn, KeepFaceLeaderFn)

    -- Select which shadow Waxwell brain to focus on based off of prefab.
    local root = nil
    if self.inst.prefab == "shadowworker" then
        local leader = GetLeader(self.inst)
        local ignorethese = nil
        if leader ~= nil then
            ignorethese = leader._brain_pickup_ignorethese or {}
            leader._brain_pickup_ignorethese = ignorethese
        end
		local function ShouldPickup() return not self.inst.sg:HasStateTag("phasing") end
		local function ShouldDeliver()
			if self.inst.sg:HasStateTag("phasing") then
				return false
			end
			local leader = GetLeader(self.inst)
			return leader ~= nil and not IsLeaderInCombat(leader)
		end
        local pickupparams = {
			cond = ShouldPickup,
            range = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS,
            range_local = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS_LOCAL,
			give_cond = ShouldDeliver,
			give_range = TUNING.SHADOWWAXWELL_WORKER_WORK_RADIUS,
            furthestfirst = false,
			positionoverride = GetSpawn, --pass as function
            ignorethese = ignorethese,
            wholestacks = true,
            allowpickables = true,
        }
        root = PriorityNode({ -- This worker is set to do work and then vanish.
            -- Fun stuff.
            dance_party,
            watch_game,
            -- Keep watch out for danger.
            avoid_explosions,
            avoid_danger,
			WhileNode(
				function()
					return not (self.inst.sg:HasStateTag("phasing") or
								self.inst.sg:HasStateTag("recoil"))
				end,
				"<busy state guard>",
				PriorityNode({
					-- Do the work needed to be done.
					WhileNode(
						function()
							self.keepworking = false
							return true
						end,
						"Keep Working",
						DoAction(self.inst, function()
							local act = FindAnyEntityToWorkActionsOn(self.inst, pickupparams.ignorethese)
							if act then
								--@V2C: check if our action matches "prechop", "premine", "predig" etc.
								--      because the stategraph would just reject the same action.
								if self.inst.sg:HasStateTag("pre"..string.lower(act.action.id)) then
									self.keepworking = true
								else
									return act
								end
							end
						end)),
					--@V2C: This is very gnarly, but this is so we can stay as "Keep Working" even when
					--      DoAction failed above, when we're still waiting on the stategraph to repeat
					--      work actions.
					FailIfSuccessDecorator(ConditionWaitNode(
						function() return not self.keepworking end, "Repeating action")),
					-- This Leash is to stop chasing after leader with loot if they keep moving too far away.
					Leash(self.inst, GetSpawn, pickupparams.range + 4, math.min(6, pickupparams.range)),
					BrainCommon.NodeAssistLeaderPickUps(self, pickupparams),
					-- Leashing is low priority.
					Leash(self.inst, GetSpawn, math.min(8, pickupparams.range), math.min(4, pickupparams.range)),
					-- Wander around and stare.
					face_leader,
					ParallelNode{
						CreateWanderer(self, math.min(6, pickupparams.range)),
						CreateIdleOblivion(self, TUNING.SHADOWWAXWELL_MINION_IDLE_DESPAWN_TIME, pickupparams.range),
					},
				}, 0.25)),
        }, 0.25)
    elseif self.inst.prefab == "shadowprotector" then
        root = PriorityNode({ -- This protector is set to defend an area and then vanish.
            -- Fun stuff.
            dance_party,
            watch_game,
            -- Keep watch out for immediate danger.
            avoid_explosions,
            -- Attack.
            ChaseAndAttack(self.inst),
            -- Leashing is low priority.
            Leash(self.inst, GetSpawn, math.min(8, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS), math.min(4, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS)),
            -- Wander around and stare.
			face_leader,
			ParallelNode{
				CreateWanderer(self, math.min(6, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS)),
				CreateIdleOblivion(self, TUNING.SHADOWWAXWELL_MINION_IDLE_DESPAWN_TIME, TUNING.SHADOWWAXWELL_PROTECTOR_DEFEND_RADIUS),
			},
        }, 0.25)
    else -- Fallback to DEPRECATED thinking.
        root = PriorityNode({
            --#1 priority is dancing beside your leader. Obviously.
            dance_party,
            watch_game,
    
            WhileNode(function() return IsNearLeader(self.inst, KEEP_WORKING_DIST) end, "Leader In Range",
                PriorityNode({
                    --All shadows will avoid explosives
                    avoid_explosions,
                    --Duelists will try to fight before fleeing
                    IfNode(function() return self.inst.prefab == "shadowduelist" end, "Is Duelist",
                        PriorityNode({
                            WhileNode(function() return self.inst.components.combat:GetCooldown() > .5 and ShouldKite(self.inst.components.combat.target, self.inst) end, "Dodge",
                                RunAway(self.inst, { fn = ShouldKite, tags = { "_combat", "_health" }, notags = { "INLIMBO" } }, KITING_DIST, STOP_KITING_DIST)),
                            ChaseAndAttack(self.inst),
                    }, .25)),
                    --All shadows will flee from danger at this point
                    avoid_danger,
                    --Workers will try to work if not fleeing
					WhileNode(function() return self.inst.prefab == "shadowlumber" and not self.inst.sg:HasStateTag("phasing") end, "Keep Chopping",
                        DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.CHOP) end)),
					WhileNode(function() return self.inst.prefab == "shadowminer" and not self.inst.sg:HasStateTag("phasing") end, "Keep Mining",
                        DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.MINE) end)),
					WhileNode(function() return self.inst.prefab == "shadowdigger" and not self.inst.sg:HasStateTag("phasing") end, "Keep Digging",
                        DoAction(self.inst, function() return FindEntityToWorkAction(self.inst, ACTIONS.DIG, DIG_TAGS) end)),
            }, 0.25)),
    
            Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
    
            face_player,
        }, 0.25)
    end

    self.bt = BT(self.inst, root)
end

function ShadowWaxwellBrain:OnInitializationComplete()
	if self.inst.SaveSpawnPoint ~= nil then
		self.inst:SaveSpawnPoint(true) --true: dont_overwrite
	end
end

return ShadowWaxwellBrain
