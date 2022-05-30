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

local OUTSIDE_CATAPULT_RANGE = TUNING.WINONA_CATAPULT_MAX_RANGE + TUNING.WINONA_CATAPULT_KEEP_TARGET_BUFFER + TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 1
local function OceanChaseWaryDistance(inst, target)
    -- We already know the target is on water. We'll approach if our attack can reach, but stay away otherwise.
    return (CanProbablyReachTargetFromShore(inst, target, TUNING.DEERCLOPS_ATTACK_RANGE - 0.25) and 0) or OUTSIDE_CATAPULT_RANGE
end

local BASEDESTROY_CANT_TAGS = {"wall"}

local function BaseDestroy(inst)
    if inst.components.knownlocations:GetLocation("targetbase") then
    	local target = FindEntity(inst, SEE_DIST, function(item)
    			if item.components.workable and item:HasTag("structure")
    				    and item.components.workable.action == ACTIONS.HAMMER
                        and item:IsOnValidGround() then
    				return true
    			end
    		end, nil, BASEDESTROY_CANT_TAGS)
    	if target then
    		return BufferedAction(inst, target, ACTIONS.HAMMER)
    	end
    end
end

-- local function GoHome(inst)
--     if inst.components.knownlocations:GetLocation("home") then
--         return BufferedAction(inst, nil, ACTIONS.GOHOME, nil, inst.components.knownlocations:GetLocation("home") )
--     else
--     	-- Pick a point to go to that is some distance away from here.
--     	local targetPos = Vector3(inst.Transform:GetWorldPosition())
--     	local wanderAwayPoint = GetWanderAwayPoint(targetPos)
--         if wanderAwayPoint then
--             inst.components.knownlocations:RememberLocation("home", wanderAwayPoint)
--         end
--     end
-- end

local function GetWanderPos(inst)
    if inst.components.knownlocations:GetLocation("targetbase") then
        return inst.components.knownlocations:GetLocation("targetbase")
	elseif inst.components.knownlocations:GetLocation("home") then
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

local function GetHomePos(inst)
    if not inst.components.knownlocations:GetLocation("home") then
        GetNewHome(inst)
    end
    return inst.components.knownlocations:GetLocation("home")
end

local DeerclopsBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DeerclopsBrain:OnStart()
    local root =
        PriorityNode(
        {
            AttackWall(self.inst),
            ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST, nil, nil, nil, OceanChaseWaryDistance),
            DoAction(self.inst, BaseDestroy, "DestroyBase", true),
            WhileNode(function() return self.inst:WantsToLeave() end, "Trying To Leave",
                Wander(self.inst, GetHomePos, 30)),

            Wander(self.inst, GetWanderPos, 30, {minwwwalktime = 10}),
        },1)

    self.bt = BT(self.inst, root)
end

function DeerclopsBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return DeerclopsBrain
