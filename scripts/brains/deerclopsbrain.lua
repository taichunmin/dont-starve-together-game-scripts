require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require("behaviours/leash")
require("behaviours/faceentity")
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

local function GetTarget(inst)
	return inst.components.combat.target
end

local function IsTarget(inst, target)
	return inst.components.combat:TargetIs(target)
end

local function GetTargetPos(inst)
	local target = GetTarget(inst)
	return target ~= nil and target:GetPosition() or nil
end

local function ShouldGrowIce(inst)
	if not inst.hasicelance or inst.sg:HasStateTag("staggered") then
		return false
	end
	local burning = inst.components.burnable:IsBurning()
	if not inst.components.combat:HasTarget() then
		--out of combat: regrow missing ice when not burning
		return not burning and inst._disengagetask == nil
			and (	inst.sg.mem.noice ~= nil or
					(inst.sg.mem.noeyeice and not (inst.hasfrenzy and inst:ShouldStayFrenzied()))
				)
	end
	--in combat:
	--  -when EYE spike is NOT burning
	--    -either summon circle if needed (can be burning)
	--    -or regrow ice when both are missing and when not burning
	return not (burning and inst.sg.mem.noice == 1 and not inst.sg.mem.noeyeice)
		and (	(inst.hasiceaura and inst.sg.mem.circle == nil and not (inst.hasfrenzy and inst:ShouldStayFrenzied())) or
				(not burning and inst.sg.mem.noice == 1)
			)
end

local DeerclopsBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function DeerclopsBrain:OnStart()
    local root =
        PriorityNode(
        {
			WhileNode(function() return ShouldGrowIce(self.inst) end, "IceGrow",
				ActionNode(function()
					self.inst:PushEvent("doicegrow")
				end)),
			ParallelNode{
				AttackWall(self.inst),
				ActionNode(function()
					self.inst.components.combat.battlecryenabled = true
				end),
			},
			WhileNode(function() return self.inst.components.combat:InCooldown() end, "Chase",
				PriorityNode({
					FailIfSuccessDecorator(
						Leash(self.inst, GetTargetPos, TUNING.DEERCLOPS_ATTACK_RANGE, 3)),
					FaceEntity(self.inst, GetTarget, IsTarget),
				}, 0.5)),
            ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST, nil, nil, nil, OceanChaseWaryDistance),
			FailIfSuccessDecorator(
				ActionNode(function()
					self.inst.components.combat.battlecryenabled = true
				end)),
            DoAction(self.inst, BaseDestroy, "DestroyBase", true),
            WhileNode(function() return self.inst:WantsToLeave() end, "Trying To Leave",
                Wander(self.inst, GetHomePos, 30)),

            Wander(self.inst, GetWanderPos, 30, {minwwwalktime = 10}),
		}, 0.5)

    self.bt = BT(self.inst, root)
end

function DeerclopsBrain:OnInitializationComplete()
	self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition(), true)
end

return DeerclopsBrain
