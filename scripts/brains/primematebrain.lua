require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/leash"
local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 5
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 10

local RUN_AWAY_DIST = 7
local STOP_RUN_AWAY_DIST = 15

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local TIME_BETWEEN_EATING = 30

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 20

local NO_LOOTING_TAGS = { "INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "outofreach", "spider" }
local NO_PICKUP_TAGS = deepcopy(NO_LOOTING_TAGS)
table.insert(NO_PICKUP_TAGS, "_container")

local PICKUP_ONEOF_TAGS = { "_inventoryitem", "pickable", "readyforharvest" }

local PrimemateBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldRunFn(inst, hunter)
    --[[
    if inst.components.combat.target then
        return hunter:HasTag("player")
    end
    ]]
end


local function findmaxwanderdistfn(inst)
    local dist = MAX_WANDER_DIST
    local boat = inst:GetCurrentPlatform()
    if boat then
        dist = boat.components.walkableplatform and boat.components.walkableplatform.platform_radius -1 or dist
    end
    return dist
end

local function findwanderpointfn(inst)
    local loc = inst.components.knownlocations:GetLocation("home")
    local boat = inst:GetCurrentPlatform()
    if boat then
        loc = Vector3(boat.Transform:GetWorldPosition())
    end
    return loc
end

function rowboat(inst)

    if not inst.components.crewmember or not inst.components.crewmember:Shouldrow() then
        return nil
    end

    local pos = inst.rowpos
    local boat = inst:GetCurrentPlatform() == inst.components.crewmember.boat and inst:GetCurrentPlatform()

    if boat and not pos then
        local radius = boat.components.walkableplatform.platform_radius - 0.35 
        pos = boat:GetPosition()

        local offset = FindWalkableOffset(pos, math.random()*TWOPI, radius, 12, false,false,nil,false,true)
        if offset then
            pos = pos + offset
        end
    end
    if pos and boat then
        inst.rowpos = pos
        return BufferedAction(inst, nil, ACTIONS.ROW, nil, pos)
    end
end

local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }

function shouldfix(inst)
    if inst.components.timer:TimerExists("patch_boat_cooldown") then
        return nil
    end

    local leaktarget = nil
    local item = inst.components.inventory:FindItem(function(testitem)
        if testitem.components.boatpatch then

            return true
        end
    end)

    local pos = inst.components.crewmember and inst.components.crewmember.boat and Vector3(inst.components.crewmember.boat.Transform:GetWorldPosition()) or nil

    if pos then
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 4, nil, NO_TAGS)

        for i, ent in ipairs(ents) do
            if ent.components.boatleak and ent.components.boatleak.has_leaks ~= false then
                leaktarget = ent
                break
            end
        end
    end

    if item and leaktarget then
        inst.fixboat = {item = item, leaktarget = leaktarget}
        return true
    end
end

function fixboat(inst) 
   if inst.components.timer:TimerExists("patch_boat_cooldown") then
        return nil
    end

    local leaktarget = nil
    local item = inst.components.inventory:FindItem(function(testitem)
        if testitem.components.boatpatch then

            return true
        end
    end)

    local pos = inst.components.crewmember and inst.components.crewmember.boat and Vector3(inst.components.crewmember.boat.Transform:GetWorldPosition()) or nil

    if pos then
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 4, nil, NO_TAGS)

        for i, ent in ipairs(ents) do
            if ent.components.boatleak and ent.components.boatleak.has_leaks ~= false then
                leaktarget = ent
                break
            end
        end
    end

    if item and leaktarget then
        return BufferedAction(inst, leaktarget, ACTIONS.REPAIR_LEAK, item)
    end
end

local function GetBoat(inst)
    return inst:GetCurrentPlatform()
end

local function DoAbandon(inst)
    if inst:GetCurrentPlatform() and inst:GetCurrentPlatform().components.health:IsDead() then
        inst.abandon = true
    end

    if not inst.abandon then
        return
    end

    local pos = Vector3(0,0,0)
    local platform = inst:GetCurrentPlatform()
    if platform then
        local x,y,z = inst.Transform:GetWorldPosition()
        local theta = platform:GetAngleToPoint(x, y, z)* DEGREES
        local radius = platform.components.walkableplatform.platform_radius - 0.5
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

        local boat_x, boat_y, boat_z = platform.Transform:GetWorldPosition()

        pos = Vector3( boat_x+offset.x, 0, boat_z+offset.z )

        return BufferedAction(inst, nil, ACTIONS.ABANDON, nil, pos)
    end

    return nil
end

local function cangettotarget(inst)
    -- IF NOT ON A BOAT, IGNORE ALL THIS
    if not inst:GetCurrentPlatform() and inst.components.combat and inst.components.combat.target then
        return true
    end

    local boat = inst:GetCurrentPlatform()
    if inst.components.combat and inst.components.combat.target then
        local target = inst.components.combat.target
        local range = inst.components.combat:GetAttackRange() + boat.components.walkableplatform.platform_radius
        if target:GetCurrentPlatform() == inst:GetCurrentPlatform() or boat:GetDistanceSqToInst(target) <  range*range then
            return true
        end
    end
end

function PrimemateBrain:OnStart()

    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),

        ChattyNode(self.inst, "MONKEY_TALK_ABANDON",
            DoAction(self.inst, DoAbandon, "abandon", true )),

        DoAction(self.inst, fixboat),

        WhileNode( function() return cangettotarget(self.inst) end, "canGetToTarget",
            ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

        DoAction(self.inst, rowboat, "rowing", nil, 3),

        Follow(self.inst, GetBoat, 0, 1, 2),
        Wander(self.inst, function() return findwanderpointfn(self.inst) end, function() return findmaxwanderdistfn(self.inst) end, {minwalktime=0.2,randwalktime=0.2,minwaittime=1,randwaittime=5})

    }, .25)
    self.bt = BT(self.inst, root)
end

return PrimemateBrain