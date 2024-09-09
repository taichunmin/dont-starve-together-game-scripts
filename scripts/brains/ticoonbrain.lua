require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/runaway"
require "behaviours/leash"
require "behaviours/standstill"

local BrainCommon = require "brains/braincommon"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 4
local TARGET_FOLLOW_DIST = 2

local TRACKING_MAX_WANDER_DIST = 5
local TRACKING_ACTION_DIST = TRACKING_MAX_WANDER_DIST - 1

local TRACKING_LEADER_START_WAITING_DIST = 6
local TRACKING_LEADER_LEASH_DIST = 14
local TRACKING_LEADER_RETURN_DIST = 4

local MAX_CHASE_TIME = 4
local MAX_CHASE_DIST = 12



local TicoonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeader(inst)
    return inst.components.follower.leader
end

local function WaitForLeader(inst)
    return inst.components.follower.leader == nil or not inst:IsNear(inst.components.follower.leader, TRACKING_LEADER_START_WAITING_DIST)
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader ~= nil and inst.components.follower.leader:GetPosition() or nil
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetTrackingTarget(inst)
	return inst.components.entitytracker:GetEntity("tracking") 
end

local function GetTrackingPos(inst)
	local target = inst.components.entitytracker:GetEntity("tracking")
	return target ~= nil and target:GetPosition() or nil
end

local function GoToTrackingTarget(inst)
    local target = inst.components.entitytracker:GetEntity("tracking")
    return target ~= nil
        and BufferedAction(inst, nil, ACTIONS.WALKTO, nil, target:GetPosition(), nil, TRACKING_ACTION_DIST)
		or nil
end

function TicoonBrain:OnStart()
    local root =
    PriorityNode(
    {
	    WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "not jumping",
            PriorityNode({
				BrainCommon.PanicWhenScared(self.inst),
				BrainCommon.PanicTrigger(self.inst),
				ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),

				WhileNode(function() return self.inst.components.entitytracker:GetEntity("tracking") ~= nil end, "Tracking Kitcoon",
					PriorityNode({
						WhileNode(function() return self.inst.components.questowner.questing end, "Searching",
							PriorityNode{
								SequenceNode{
									Leash(self.inst, GetLeaderPos, TRACKING_LEADER_LEASH_DIST, TRACKING_LEADER_RETURN_DIST, true),
									ActionNode(function() self.inst:PushEvent("ticoon_getattention") end, "Get Attention"),
								},
								StandStill(self.inst, WaitForLeader, WaitForLeader),
								SequenceNode{
									DoAction(self.inst, GoToTrackingTarget, "Walking To Kitcoon"),
									ActionNode(function() self.inst.components.questowner:CompleteQuest() end, "Set Arrived Flag"),
								},
							}),
						Wander(self.inst, GetTrackingPos, TRACKING_MAX_WANDER_DIST, { minwalktime = 2.5, randwalktime = 1, minwaittime = 1, randwaittime = 1 }),
					})),

				Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
				FaceEntity(self.inst, GetLeader, KeepFaceTargetFn),
				StandStill(self.inst),
			}, .25)
		),
    }, .25)
    self.bt = BT(self.inst, root)
end

return TicoonBrain
