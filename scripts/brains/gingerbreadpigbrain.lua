require "behaviours/wander"
require "behaviours/leash"
require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
local BrainCommon = require("brains/braincommon")

local STOP_RUN_DIST = 50
local SEE_PLAYER_DIST = 15

local LEASH_START_DIST = 20
local LEASH_STOP_DIST = 18

local START_FACE_DIST = 20
local KEEP_FACE_DIST = 20

local GingerBreadPigBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetLeashTargetPosition(inst)
	return inst.leash_target and inst.leash_target:GetPosition()
end

local function GetTarget(inst)
	return inst.leash_target
end

local function GetFaceTargetFn(inst)
	return GetTarget(inst) or FindClosestPlayerToInst(inst, START_FACE_DIST, true)
end

local function KeepFaceTargetFn(inst, target)
	return inst ~= nil
        and target ~= nil
        and inst:IsValid()
        and target:IsValid()
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost"))
        and (inst.leash_target == target or inst:IsNear(target, KEEP_FACE_DIST))
end


--------------------------------------------------------------------------

function GingerBreadPigBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
    	RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST, function(hunter) return self.inst.chased_by_player end, nil, true),

    	IfNode(function() return self.inst.leash_target ~= nil and not self.inst.chased end, "shouldapproach",
    		Leash(self.inst, GetLeashTargetPosition, LEASH_START_DIST, LEASH_STOP_DIST, true)),

    	FaceEntity(self.inst, GetTarget, KeepFaceTargetFn)
    }, 0.01)

    self.bt = BT(self.inst, root)
end

return GingerBreadPigBrain
