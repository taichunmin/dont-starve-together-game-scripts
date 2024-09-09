require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 6
local TARGET_FOLLOW_DIST = 4

local MAX_WANDER_DIST = 10

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetFollowPos(inst)
    return inst.components.follower.leader and inst.components.follower.leader:GetPosition() or
    inst:GetPosition()
end

local function WanderOff(inst)
    if inst.ShouldLeaveWorld then
        return BufferedAction(inst, nil, ACTIONS.GOHOME)
    end
end

local GlommerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function GlommerBrain:OnStart()
    local root =
    PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        DoAction(self.inst, WanderOff),
        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, GetFollowPos, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return GlommerBrain