require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "giantutils"

local SEE_DIST = 40

local CHASE_DIST = 32
local CHASE_TIME = 20
--local START_FACE_DIST = 7
--local KEEP_FACE_DIST = 9
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 6

local RETURNTOFIGHT_DIST = 5


local function GetWanderPos(inst)
    if inst.components.knownlocations:GetLocation("home") then
		return inst.components.knownlocations:GetLocation("home")
	elseif inst.components.knownlocations:GetLocation("spawnpoint") then
		return inst.components.knownlocations:GetLocation("spawnpoint")
	end
end

local function GetNewHome(inst)
    if inst.forgethometask then
        inst.forgethometask:Cancel()
        inst.forgethometask = nil
    end
    -- Pick a point to go to that is some distance away from here.
    local targetPos = Vector3(inst.Transform:GetWorldPosition())
    local wanderAwayPoint = GetWanderAwayPoint(targetPos)
    if wanderAwayPoint then
        inst.components.knownlocations:RememberLocation("home", wanderAwayPoint)
    end

    inst.forgethometask = inst:DoTaskInTime(30, function() inst.components.knownlocations:ForgetLocation("home") end)
end

local function GetCombatFaceTargetFn(inst)
    -- if the malbatross is fleeing, don't Face
    -- if it has a target and should stardown, then staredown
    -- if it's just wandering and a target comes close, stare

    local target = nil
    if inst.components.combat and inst.components.combat.target then
        if inst.staredown then
            target = inst.components.combat.target
        end
    end

    local dist = TUNING.MALBATROSS_MAX_CHASEAWAY_DIST - 10
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > dist * dist then
        return nil
    end

    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepCombatFaceTargetFn(inst, target)

    if inst and inst.components.combat and inst.components.combat.target then

        local potential = FindClosestPlayerToInst(inst, RETURNTOFIGHT_DIST, true)
        if potential then
            inst.components.combat.target = potential
            inst.staredown = nil
            return nil
        end

        if not inst.staredown then
            return nil
        end
    end

    local dist = TUNING.MALBATROSS_MAX_CHASEAWAY_DIST - 10
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > dist * dist then
        return nil
    end

    return inst ~= nil
        and target ~= nil
        and inst:IsValid()
        and target:IsValid()
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost"))
end
--[[
local function GetFaceTargetFn(inst)
    -- if the malbatross is fleeing, don't Face
    -- if it has a target and should stardown, then staredown
    -- if it's just wandering and a target comes close, stare
    if inst and inst.components.combat and inst.components.combat.target then
        return nil
    end

    local target = nil

    target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)

    local dist = TUNING.MALBATROSS_MAX_CHASEAWAY_DIST - 10
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > dist * dist then
        return nil
    end

    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)

    if inst and inst.components.combat and inst.components.combat.target then
        return nil
    end

    if not inst:IsNear(target, KEEP_FACE_DIST) then
        return nil
    end

    local dist = TUNING.MALBATROSS_MAX_CHASEAWAY_DIST - 10
    local home = inst.components.knownlocations:GetLocation("home")
    if home and inst:GetDistanceSqToPoint(home:Get()) > dist * dist then
        return nil
    end

    return inst ~= nil
        and target ~= nil
        and inst:IsValid()
        and target:IsValid()
        and not (target:HasTag("notarget") or
                target:HasTag("playerghost"))
end
]]

local function GetHomePos(inst)
    if not inst.components.knownlocations:GetLocation("home") then
        GetNewHome(inst)
    end
    return inst.components.knownlocations:GetLocation("home")
end

local function CheckForFleeAndDive(inst)
    if inst.components.combat and inst.components.combat.target then
        local distsq = inst:GetDistanceSqToInst(inst.components.combat.target)
        if distsq < RUN_AWAY_DIST * RUN_AWAY_DIST and ( inst.willswoop and inst.readytoswoop ) then

            if inst.readytoswoop and inst.willswoop then
                inst.readytoswoop = false
                inst.swooptask = inst:DoTaskInTime(3, function(inst)
                    if inst:IsValid() then
                        inst:PushEvent("doswoop", inst.components.combat.target)
                    end
                end)
            end
            return inst.components.combat.target
        end

        if inst.willdive and inst.readytodive and (not inst.readytoswoop or not inst.willswoop) and not inst.swooptask then
            inst:PushEvent("dosplash")
            return inst.components.combat.target
        end
    end
end

local SEE_BAIT_DIST = 15
local EAT_MUST_TAGS = {"oceanfish", "oceanfishable"}
local EAT_MUST_NOT_TAGS = {"INLIMBO", "outofreach", "FX"}
local function GetEatAction(inst)
    if not inst:IsHungry() then
        return nil
    end

    local target = FindEntity(
        inst,
        SEE_BAIT_DIST,
        function(found_entity)
            return not (found_entity.components.inventoryitem and found_entity.components.inventoryitem:IsHeld()) and
                    not found_entity:IsOnPassablePoint()
        end,
        EAT_MUST_TAGS,
        EAT_MUST_NOT_TAGS
    )

    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function()
            return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) and
                    not target:IsOnPassablePoint()
        end
        return act
    end
end

local function ShouldLeaveLand(inst)
    local map = TheWorld.Map
    local x,y,z = inst.Transform:GetWorldPosition()
    if map:IsVisualGroundAtPoint(x, y, z) then
        if not inst.landtimer then
            inst.landtimer = GetTime()
        end
        if GetTime() -  inst.landtimer > 5 then
            inst:PushEvent("depart")
        end
    else
        inst.landtimer = nil
    end
    return nil
end

local MalbatrossBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MalbatrossBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("swoop") end, "not swooping",
            PriorityNode({

                DoAction(self.inst, ShouldLeaveLand, "leave the land"),

                RunAway(self.inst, function() return CheckForFleeAndDive(self.inst) end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),

                FaceEntity(self.inst, GetCombatFaceTargetFn, KeepCombatFaceTargetFn),

                ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST),
                DoAction(self.inst, GetEatAction, "Dive For Fish"),
                Wander(self.inst, GetWanderPos, 30, {minwaittime = 6}),
            }, 1)),
    }, 1)

    self.bt = BT(self.inst, root)
end

function MalbatrossBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return MalbatrossBrain
