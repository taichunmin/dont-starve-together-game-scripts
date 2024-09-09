require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")

local HoundBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
    --self.reanimatetime = nil
end)

local SEE_DIST = 30

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 6
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER + MIN_FOLLOW_LEADER) / 2

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50

local SIT_BOY_DIST = 10

local function EatFoodAction(inst)
	if inst.sg:HasStateTag("busy") and not inst.sg:HasStateTag("wantstoeat") then
		return
	end
    local target = FindEntity(inst, SEE_DIST, function(item) return inst.components.eater:CanEat(item) and item:IsOnPassablePoint(true) end)
    return target ~= nil and BufferedAction(inst, target, ACTIONS.EAT) or nil
end

local function GetLeader(inst)
    return inst.components.follower ~= nil and inst.components.follower.leader or nil
end

local function GetHome(inst)
    return inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
end

local function GetHomePos(inst)
    local home = GetHome(inst)
    return home ~= nil and home:GetPosition() or nil
end

local function GetNoLeaderLeashPos(inst)
    return GetLeader(inst) == nil and GetHomePos(inst) or nil
end

local function GetWanderPoint(inst)
    local target = GetLeader(inst) or inst:GetNearestPlayer(true)
    return target ~= nil and target:GetPosition() or nil
end

local function ShouldStandStill(inst)
    return inst:HasTag("pet_hound") and not TheWorld.state.isday and not GetLeader(inst) and not inst.components.combat:HasTarget() and inst:IsNear(GetHome(inst), SIT_BOY_DIST)
end

local function TryReanimate(self)
    local leader = GetLeader(self.inst)
    if leader ~= nil then
        if leader.sg ~= nil and leader.sg:HasStateTag("statue") then
            self.reanimatetime = nil
        elseif self.reanimatetime == nil then
            self.reanimatetime = GetTime() + math.random() * .5
        elseif self.reanimatetime == true then
            self.inst:PushEvent("reanimate", { target = leader.components.combat.target })
        elseif self.reanimatetime < GetTime() then
            self.reanimatetime = true
        end
    else
        local player, dsq = self.inst:GetNearestPlayer(true)
        if player == nil or dsq >= 25 then
            self.reanimatetime = nil
        elseif self.reanimatetime == nil then
            self.reanimatetime = GetTime() + 3
        elseif self.reanimatetime == true then
            self.inst:PushEvent("reanimate", { target = player })
        elseif self.reanimatetime < GetTime() then
            self.reanimatetime = true
        end
    end
end

local function ShouldBecomeStatue(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("statue") and inst:IsNear(leader, 10)
end

local function GetClayLeaderLeashPos(inst)
    local leader = GetLeader(inst)
    if leader == nil or inst.leader_offset == nil then
        return
    end
    local x, y, z = leader.Transform:GetWorldPosition()
    return Vector3(x + inst.leader_offset.x, 0, z + inst.leader_offset.z)
end

local function FaceFormation(inst)
    if inst.sg:HasStateTag("canrotate") then
        local leader = GetLeader(inst)
        if leader ~= nil then
            inst.Transform:SetRotation(leader.Transform:GetRotation())
        end
    end
end

--------------------------------------------------------------------------

local CARCASS_TAGS = { "meat_carcass" }
local CARCASS_NO_TAGS = { "fire" }
function HoundBrain:SelectCarcass()
	self.carcass = FindEntity(self.inst, SEE_DIST, nil, CARCASS_TAGS, CARCASS_NO_TAGS)
	return self.carcass ~= nil
end

function HoundBrain:CheckCarcass()
	return not (self.carcass.components.burnable ~= nil and self.carcass.components.burnable:IsBurning())
		and self.carcass:IsValid()
		and self.carcass:HasTag("meat_carcass")
end

function HoundBrain:GetCarcassPos()
	return self:CheckCarcass() and self.carcass:GetPosition() or nil
end

--------------------------------------------------------------------------

function HoundBrain:OnStart()
	local root
	if self.inst:HasTag("clay") then
		root = PriorityNode(
        {
            WhileNode(function() return self.inst.sg:HasStateTag("statue") end, "Statue",
                ActionNode(function() TryReanimate(self) end, "TryReanimate")),

            WhileNode(function() return GetLeader(self.inst) == nil end, "NoLeader", AttackWall(self.inst)),

            ChaseAndAttack(self.inst, 10),

            WhileNode(function() return ShouldBecomeStatue(self.inst) end, "BecomeStatue",
                ParallelNode{
                    LoopNode{
                        WaitNode(3),
                        ActionNode(function() self.inst:PushEvent("becomestatue") end),
                    },
                    PriorityNode({
                        Leash(self.inst, GetClayLeaderLeashPos, 1, 1),
                        FailIfSuccessDecorator(ActionNode(function() FaceFormation(self.inst) end, "FaceFormation")),
                        StandStill(self.inst),
                    }, .25),
                }),

            Leash(self.inst, GetClayLeaderLeashPos, 1, 1),

            Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
            FaceEntity(self.inst, GetLeader, GetLeader),

            WhileNode(function() return GetLeader(self.inst) == nil end, "Abandoned",
                ParallelNode{
                    LoopNode{
                        WaitNode(3),
                        ActionNode(function() self.inst:PushEvent("becomestatue") end),
                    },
                    PriorityNode({
                        WhileNode(function() return GetHome(self.inst) end, "HasHome", Wander(self.inst, GetHomePos, 8)),
                        Wander(self.inst, GetWanderPoint, 20),
                    }, .25),
                }),

            WhileNode(function() return GetHome(self.inst) end, "HasHome", Wander(self.inst, GetHomePos, 8)),
            Wander(self.inst, GetWanderPoint, 20),
		}, .25)
	else
		local ismutated = self.inst:HasTag("lunar_aligned")
		root = PriorityNode(
        {
            WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "NotJumpingBehaviour",
                PriorityNode({
					BrainCommon.PanicTrigger(self.inst),
                    WhileNode(function() return GetLeader(self.inst) == nil end, "NoLeader", AttackWall(self.inst)),

					--Eat carcass behaviour (for non-mutated hounds)
					WhileNode(
						function()
							return not ismutated and (
								not self.inst.components.combat:HasTarget() or
								self.inst.components.combat:GetLastAttackedTime() + TUNING.HOUND_FIND_CARCASS_DELAY < GetTime()
							)
						end,
						"not attacked",
						IfNode(function() return self:SelectCarcass() end, "eat carcass",
							PriorityNode({
								FailIfSuccessDecorator(
									Leash(self.inst,
										function() return self:GetCarcassPos() end,
										function() return self.inst.components.combat:GetHitRange() + self.carcass:GetPhysicsRadius(0) - 0.5 end,
										function() return self.inst.components.combat:GetHitRange() + self.carcass:GetPhysicsRadius(0) - 1 end,
										true)),
								IfNode(function() return self:CheckCarcass() and not self.inst.components.combat:InCooldown() end, "chomp",
									ActionNode(function() self.inst.sg:HandleEvent("chomp", { target = self.carcass }) end)),
								FaceEntity(self.inst,
									function() return self.carcass end,
									function() return self:CheckCarcass() end),
							}, .25))),
					--

                    WhileNode(function() return self.inst:HasTag("pet_hound") end, "Is Pet", ChaseAndAttack(self.inst, 10)),
                    WhileNode(function() return not self.inst:HasTag("pet_hound") and GetHome(self.inst) ~= nil end, "No Pet Has Home", ChaseAndAttack(self.inst, 10, 20)),
                    WhileNode(function() return not self.inst:HasTag("pet_hound") and GetHome(self.inst) == nil end, "Not Pet", ChaseAndAttack(self.inst, 100)),

                    Leash(self.inst, GetNoLeaderLeashPos, HOUSE_MAX_DIST, HOUSE_RETURN_DIST),

					IfNode(function() return not ismutated end, "non-mutated hound eat food",
						DoAction(self.inst, EatFoodAction, "eat food", true)),
                    Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
                    FaceEntity(self.inst, GetLeader, GetLeader),

                    StandStill(self.inst, ShouldStandStill),

                    WhileNode(function() return GetHome(self.inst) end, "HasHome", Wander(self.inst, GetHomePos, 8)),
                    Wander(self.inst, GetWanderPoint, 20),
                }, .25)
            ),
        }, .25 )
	end

    self.bt = BT(self.inst, root)
end

return HoundBrain
