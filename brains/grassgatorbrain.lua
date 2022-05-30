require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/runaway"

local BrainCommon = require("brains/braincommon")

local MAX_CHASE_TIME = 6
local WANDER_DIST = TUNING.SHADE_CANOPY_RANGE -2

local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 14
local START_FACE_DIST = 10
local KEEP_FACE_DIST = 12

local function GetFaceTargetFn(inst)
    if not BrainCommon.ShouldSeekSalt(inst) then
        local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
        if not inst.components.timer:TimerExists("facetarget") then          
            inst.components.timer:StartTimer("facetarget",3)
        end
        return target ~= nil and not target:HasTag("notarget") and target or nil
    end
end

local function KeepFaceTargetFn(inst, target)
    return not BrainCommon.ShouldSeekSalt(inst)
        and not target:HasTag("notarget")
        and inst.components.timer:TimerExists("facetarget")
        and inst:IsNear(target, KEEP_FACE_DIST)
end

local function ShouldRunAway(guy)
    return guy:HasTag("character") and not guy:HasTag("notarget")
end

local function ShouldRunAwayFn(hunterfn,inst)
    return inst.isovershallowwater(inst)
end

local GrassgatorBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function findwater(inst)
    local position = Vector3(inst.Transform:GetWorldPosition())
    local offset = FindSwimmableOffset(position, math.random()*PI*2, 30, 12, true)
    if offset then
        position.x = position.x + offset.x
        position.z = position.z + offset.z
        return position
    else
        return nil
    end
end

local function isonland(inst)
    return TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition())
end

local function getwanderloc(inst)
  if inst.test then print("GET WANDER LOC") end
    if isonland(inst) then      
        return nil
    else
 if inst.test  then     print("ON WATER. STAY HOME") end
        return inst.components.knownlocations:GetLocation("home")
    end
end

function GrassgatorBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("diving") end, "Not Diving",
            PriorityNode(
            {
                WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
                WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
                ChaseAndAttack(self.inst, MAX_CHASE_TIME),
                SequenceNode{                    
                    RunAway(self.inst, ShouldRunAway, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),  -- ShouldRunAwayFn
                    FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 0.5)
                },
                FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),    
                Wander(self.inst, function() return getwanderloc(self.inst) end, WANDER_DIST)
            }, .25)),
    }, .25)

    self.bt = BT(self.inst, root)
end

return GrassgatorBrain
