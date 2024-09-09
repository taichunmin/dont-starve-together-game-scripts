require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")

local SharkBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local SEE_DIST = 30

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50
local SEE_FOOD_DIST = 15

local WANDER_TIMES = {minwalktime=2, randwalktime=0.5, minwaittime=0.0, randwaittime=0.0}

local function GetHome(inst)
    return inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
end

local function GetHomePos(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetLeashPos(inst)
    return GetHomePos(inst) or nil
end

local function GetWanderPoint(inst)
    local target = inst:GetNearestPlayer(true)
    return target ~= nil and target:GetPosition() or nil
end

local function isOnWater(inst)
    return not inst:GetCurrentPlatform() and not TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition())
end

local function getdirectionFn(inst)
    local DIST = 6
    local theta = inst.Transform:GetRotation() * DEGREES
    local offset = Vector3(DIST * math.cos( theta ), 0, -DIST * math.sin( theta ))
    local x,y,z = inst.Transform:GetWorldPosition()

    local r = math.random() * 2 - 1
    local newdir = (inst.Transform:GetRotation() + r*r*r * 60) * DEGREES

    if TheWorld.Map:IsVisualGroundAtPoint(x+offset.x,0,z+offset.z) then
        newdir =  newdir + PI
    end

    return newdir
end

local function Attack(inst)
    inst:PushEvent("dobite")
end

local function removefood(inst, target)
	if inst._removefood ~= nil then
		inst.foodtoeat = nil
		inst:RemoveEventCallback("onremove", inst._removefood, target)
		inst:RemoveEventCallback("onpickup", inst._removefood, target)
		inst._removefood = nil
	end
end

local function isfoodnearby(inst)
    local target = FindEntity(inst, SEE_DIST, function(item) return inst.components.eater:CanEat(item) and not item:GetCurrentPlatform() and not TheWorld.Map:IsVisualGroundAtPoint(item.Transform:GetWorldPosition()) end)

    -- don't target food if its too close..ironically
    if target and target:GetDistanceSqToInst(inst) < 6*6 then
        return nil
    end

	if inst.foodtoeat ~= target then
		removefood(inst)
		if target then
			inst.foodtoeat = target
			inst._removefood = function() removefood(inst, target) end
			inst:ListenForEvent("onremove", inst._removefood, target)
			inst:ListenForEvent("onpickup", inst._removefood, target)

			return BufferedAction(inst, target, ACTIONS.EAT)
		end
	end
end

local function EatFishAction(inst)
    if not inst.components.timer:TimerExists("gobble_cooldown") then
        local target = FindEntity(inst, SEE_FOOD_DIST, function(food)
                return TheWorld.Map:IsOceanAtPoint(inst.Transform:GetWorldPosition())
            end,
            nil,
            nil,
            {"oceanfish"})

        if target then
            inst.foodtarget = target
            local targetpos = Vector3(target.Transform:GetWorldPosition())

            local act = BufferedAction(inst, target, ACTIONS.EAT)
            act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
            return act
        end
    end

    return nil
end

local SHARK_WALK_SQ = TUNING.SHARK.WALK_SPEED * TUNING.SHARK.WALK_SPEED

local MUST_BOAT = {"boat"}
local function GetBoatFollowPosition(inst)

    if not inst.targetboat and not inst.components.timer:TimerExists("targetboatdelay")  then
        inst.targetboat = FindEntity(inst, 20,nil,MUST_BOAT)
        if inst.targetboat then
            inst.components.timer:StartTimer("targetboatdelay", 10)
        end
    end

    if not inst.targetboat then
        return nil
    end

    -- From here on, our leader has a platform!
    local platform_velocity = Vector3( inst.targetboat.components.boatphysics.velocity_x or 0, 0,  inst.targetboat.components.boatphysics.velocity_z or 0)
    local platform_speed_sq = platform_velocity:LengthSq()
    if platform_speed_sq > 1 then
        local offset = inst:GetFormationOffsetNormal(platform_velocity)

        return inst:GetPosition() + offset
    else
        local myx, myy, myz = inst.Transform:GetWorldPosition()
        local px, py, pz =  inst.targetboat.Transform:GetWorldPosition()
        local direction_to_inst = Vector3(myx - px, myy - py, myz - pz):Normalize()

        return  inst.targetboat:GetPosition() + (direction_to_inst * BOAT_TARGET_DISTANCE)
    end
end

local function GetBoatFollowDistance(inst)
    if not inst.targetboat then
        return MAX_BOAT_FOLLOW_DIST
    end

    if not inst.targetboat then
        return MAX_BOAT_FOLLOW_DIST
    end

    local platform_speed_sq = (inst.targetboat.components.boatphysics.velocity_x or 0)^2 + (inst.targetboat.components.boatphysics.velocity_z or 0)^2
    if platform_speed_sq > TUNING.SHARK.WALK_SPEED^2 then
        return 0.5
    else
        return MAX_BOAT_FOLLOW_DIST
    end
end

local function ShouldLeashRun(inst)

    local platform = inst.targetboat
    if not platform then
        return false
    end

    local pvx = platform.components.boatphysics.velocity_x or 0
    local pvz = platform.components.boatphysics.velocity_z or 0
    return ((pvx * pvx) + (pvz * pvz)) >= SHARK_WALK_SQ
end


function SharkBrain:OnStart()
    local root = PriorityNode(
        {
            WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "NotJumpingBehaviour",
                PriorityNode({
                    WhileNode(function() return not isOnWater(self.inst) and not self.inst.components.timer:TimerExists("getdistance") end, "NOT on water",
                        PriorityNode({
                            DoAction(self.inst, Attack, "attack", true),
                        })),

                    WhileNode(function() return isOnWater(self.inst) end, "on water",
                        PriorityNode({
							BrainCommon.PanicTrigger(self.inst),
                            RunAway(self.inst, function() return self.inst.components.timer:TimerExists("getdistance") and self.inst.components.combat.target end, 10, 20),
                            ChaseAndAttack(self.inst, 100),
                            DoAction(self.inst, isfoodnearby, "gotofood", true),
                            DoAction(self.inst, EatFishAction, "eat fish", true),

                            --Leash(self.inst, GetBoatFollowPosition, GetBoatFollowDistance, 0.5, ShouldLeashRun),

                            Wander(self.inst, GetWanderPoint, 40, WANDER_TIMES, getdirectionFn)
                        })),
                }, .25)
            ),
        }, .25 )

    self.bt = BT(self.inst, root)
end

return SharkBrain
