require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/standandattack"
require "behaviours/leashandavoid"

local WAMDER_DIST = 2
local LEASH_DIST = 18
local TARGET_LEASH_DIST = 3
local CRABKING_RADIUS = 5

local function findavoidanceobjectfn(inst)
    if inst.crabking then
        return inst.crabking
    end
end

local function AttackTarget(inst)
    if inst.components.combat:InCooldown() then 
        return nil
    end
    local target = inst.components.combat.target
    if not target then
        return nil
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local tx, ty, tz = target.Transform:GetWorldPosition()
    local range = inst.components.combat.attackrange

    if inst:GetDistanceSqToInst(target) > range * range then
        return nil
    end

    inst:FacePoint(target:GetPosition())
    return BufferedAction(inst, target, ACTIONS.ATTACK)
end

local function CircleBoat(inst)
    local target = inst.components.combat.target
    if not target then
        return nil
    end    
    local platform = target:GetCurrentPlatform()
    if not platform then
        return nil
    end

    local x,y,z = target.Transform:GetWorldPosition()
    local px,py,pz = platform.Transform:GetWorldPosition()
    local theta = platform:GetAngleToPoint(x,y,z)*DEGREES
    local radius= platform.components.hull:GetRadius() + 1

    local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    local pos = offset and Vector3(px,py,pz) + offset

    if pos and inst:GetDistanceSqToPoint(pos) > 1 then
        return pos
    end    
end

local CrabkingClawBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CrabkingClawBrain:OnStart()
    local root = PriorityNode(
    {

        DoAction(self.inst, AttackTarget, "AttackTarget"),

        IfNode(function() return CircleBoat(self.inst) and true or false end, "circle",
            LeashAndAvoid(self.inst, findavoidanceobjectfn, CRABKING_RADIUS, function() return CircleBoat(self.inst) end, 1, 1.5, false)),

        LeashAndAvoid(self.inst, findavoidanceobjectfn, CRABKING_RADIUS, function() return self.inst.components.combat.target and Vector3(self.inst.components.combat.target.Transform:GetWorldPosition())  end, TARGET_LEASH_DIST, 5, false),

        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpoint") end, WAMDER_DIST,
            {
                minwalktime=0.5,
                randwalktime=0.5,
                minwaittime=1,
                randwaittime=5,
            }
        )

    }, 0.2)

    self.bt = BT(self.inst, root)
end

function CrabkingClawBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return CrabkingClawBrain
