require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/runaway")
require("behaviours/wander")

local RESET_COMBAT_DELAY = 10

local MIN_STALKING_TIME = 2 --before triggering proximity attack
local MAX_STALKING_CHASE_TIME = 4

local RUN_AWAY_DIST = 8
local STOP_RUN_AWAY_DIST = 13
local HUNTER_PARAMS =
{
	tags = { "_combat" },
	notags = { "INLIMBO", "playerghost", "invisible", "hidden", "flight", "shadowcreature" },
	oneoftags = { "character", "monster", "largecreature", "shadowminion" },
	fn = function(ent, inst)
		--Don't run away from non-hostile animals unless they are attacking us
		return ent.components.combat:TargetIs(inst)
			or ent:HasTag("character")
			or ent:HasTag("monster")
			or ent:HasTag("shadowminion")
	end,
}

local DaywalkerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("prison")
end

local function ShouldStalk(inst)
	return inst:IsStalking() and (inst.components.combat:InCooldown() or not inst.components.combat:HasTarget())
end

local function ShouldDodge(inst)
	return inst.components.combat:HasTarget() and inst.components.combat:InCooldown() and not inst:IsStalking()
end

local function ShouldChase(inst)
	return inst.components.combat:HasTarget() and not inst.components.combat:InCooldown()
end

local function DoStalking(inst)
	local target = inst:GetStalking()
	if target ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		local dist = math.sqrt(dx * dx + dz * dz)
		local strafe_angle = Remap(math.clamp(dist, 4, RUN_AWAY_DIST), 4, RUN_AWAY_DIST, 135, 75)
		local rot = inst.Transform:GetRotation()
		local rot1 = math.atan2(-dz, dx) * RADIANS
		local rota = rot1 - strafe_angle
		local rotb = rot1 + strafe_angle
		if DiffAngle(rot, rota) < 30 then
			rot1 = rota
		elseif DiffAngle(rot, rotb) < 30 then
			rot1 = rotb
		else
			rot1 = math.random() < 0.5 and rota or rotb
		end
		rot1 = rot1 * DEGREES
		return Vector3(x + math.cos(rot1) * 10, 0, z - math.sin(rot1) * 10)
	end
end

local function IsStalkingFar(inst)
	local target = inst:GetStalking()
	return target ~= nil and not inst:IsNear(target, RUN_AWAY_DIST)
end

local function IsStalkingTooClose(inst)
	local target = inst:GetStalking()
	return target ~= nil and inst:IsNear(target, TUNING.DAYWALKER_ATTACK_RANGE)
end

local function GetFaceTargetFn(inst)
	return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
	return inst.components.combat:TargetIs(target)
end

function DaywalkerBrain:OnStart()
	local root = PriorityNode({
		WhileNode(
			function()
				return not (self.inst.sg:HasStateTag("jumping") or
							self.inst.sg:HasStateTag("tired"))
			end,
			"<busy state guard>",
			PriorityNode({
				WhileNode(function() return ShouldDodge(self.inst) end, "Kiting",
					PriorityNode({
						RunAway(self.inst, HUNTER_PARAMS, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
						NotDecorator(ActionNode(function()
							if self.inst.canstalk and not self.inst.components.timer:TimerExists("stalk_cd") then
								self.inst:SetStalking(self.inst.components.combat.target)
							end
							if self.inst:IsStalking() then
								self.inst:StartAttackCooldown()
							else
								self.inst.components.combat:ResetCooldown()
							end
						end)),
					}, 0.5)),
				WhileNode(function() return ShouldStalk(self.inst) end, "Stalking",
					ParallelNode{
						SequenceNode{
							ParallelNodeAny{
								WaitNode(MIN_STALKING_TIME),
								ConditionWaitNode(function() return IsStalkingFar(self.inst) end),
							},
							ConditionWaitNode(function() return IsStalkingTooClose(self.inst) end),
							ActionNode(function() self.inst.components.combat:ResetCooldown() end),
						},
						Leash(self.inst, DoStalking, 0, 0, false),
					}),
				WhileNode(function() return ShouldChase(self.inst) end, "Chase",
					PriorityNode({
						WhileNode(function() return self.inst:IsStalking() end, "Stalking Chase",
							ParallelNodeAny{
								SequenceNode{
									WaitNode(MAX_STALKING_CHASE_TIME),
									ActionNode(function() self.inst:SetStalking(nil) end),
								},
								ChaseAndAttack(self.inst, nil, nil, nil, nil, true),
							}),
						ChaseAndAttack(self.inst),
					}, 0.5)),
				FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
				ParallelNode{
					SequenceNode{
						WaitNode(RESET_COMBAT_DELAY),
						ActionNode(function() self.inst:SetEngaged(false) end),
					},
					PriorityNode({
						FailIfSuccessDecorator(Leash(self.inst, GetHomePos, 16, 2, true)),
						Wander(self.inst, nil, nil, nil, nil, nil, nil, { should_run = true }),
					}, 0.5),
				},
			}, 0.5)),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return DaywalkerBrain
