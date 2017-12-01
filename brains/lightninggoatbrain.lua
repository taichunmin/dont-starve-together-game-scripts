require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"

local BrainCommon = require("brains/braincommon")

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local WANDER_DIST_DAY = 20
local WANDER_DIST_NIGHT = 5
local MAX_CHASE_TIME = 6

local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 12
local START_FACE_DIST = 10
local KEEP_FACE_DIST = 14

local function GetFaceTargetFn(inst)
    if not BrainCommon.ShouldSeekSalt(inst) then
        local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
        return target ~= nil and not target:HasTag("notarget") and target or nil
    end
end

local function KeepFaceTargetFn(inst, target)
    return not BrainCommon.ShouldSeekSalt(inst)
        and not target:HasTag("notarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldRunAway(guy)
    return guy:HasTag("character") and not guy:HasTag("notarget")
end

local function GetWanderDistFn(inst)
    return TheWorld.state.isday and WANDER_DIST_DAY or WANDER_DIST_NIGHT
end

local LightningGoatBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function LightningGoatBrain:OnStart()
    local root =
    PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        IfNode(function() return self.inst.components.combat.target ~= nil end, "hastarget", AttackWall(self.inst)),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        SequenceNode{
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 0.25),
            RunAway(self.inst, ShouldRunAway, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
        },
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        BrainCommon.AnchorToSaltlick(self.inst),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, GetWanderDistFn)
    },.25)

    self.bt = BT(self.inst, root)
end

function LightningGoatBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return LightningGoatBrain
