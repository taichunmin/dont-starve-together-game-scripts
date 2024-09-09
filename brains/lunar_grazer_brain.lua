require("behaviours/chaseandattack")
require("behaviours/leash")
require("behaviours/wander")

local STRAFE_INNER_DIST = TUNING.LUNAR_GRAZER_ATTACK_RANGE
local STRAFE_OUTER_DIST = STRAFE_INNER_DIST + 2
local WANDER_DIST = 4

local LunarGrazerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function IsSleeper(target)
	return target.components.grogginess ~= nil
		or target.components.sleeper ~= nil
end

local function SleepCheck(target)
	if target.components.grogginess ~= nil then
		return target.components.grogginess:IsKnockedOut() and not (target.sg ~= nil and target.sg:HasStateTag("dismounting"))
	elseif target.components.sleeper ~= nil then
		return target.components.sleeper:IsAsleep()
	end
	return false
end

local function DoStalking(inst)
	local target = inst.components.combat.target
	if target ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = target.Transform:GetWorldPosition()
		local dx = x1 - x
		local dz = z1 - z
		local dist = math.sqrt(dx * dx + dz * dz)
		local strafe_angle = Remap(math.clamp(dist, STRAFE_INNER_DIST, STRAFE_OUTER_DIST), STRAFE_INNER_DIST, STRAFE_OUTER_DIST, 90, 0)
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

local function GetTargetPos(inst)
	return inst.components.combat.target:GetPosition()
end

local function GetHome(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end

function LunarGrazerBrain:OnStart()
	local root = PriorityNode({
		WhileNode(function()
				return self.inst.sg:HasStateTag("debris")
					and self.inst.components.combat:HasTarget()
					and not self.inst.components.health:IsHurt()
					or self.inst.sg:HasStateTag("invisible")
			end,
			"Debris",
			NotDecorator(ActionNode(function()
				self.inst:PushEvent("lunar_grazer_respawn")
			end))),
		WhileNode(function()
				return not self.inst.sg:HasStateTag("debris")
					and not self.inst.sg:HasStateTag("invisible")
			end,
			"Awake",
			PriorityNode({
				WhileNode(function()
						return not self.inst.components.combat:InCooldown()
							and self.inst.components.combat:HasTarget()
					end,
					"EngageTarget",
					PriorityNode({
						IfNode(function()
								local target = self.inst.components.combat.target
								return target ~= nil and not IsSleeper(target)
							end,
							"AttackNonSleeper",
							ChaseAndAttack(self.inst)),
						WhileNode(function()
								local target = self.inst.components.combat.target
								return target ~= nil and SleepCheck(target)
							end,
							"AttackSleeper",
							SequenceNode{
								ParallelNodeAny{
									WaitNode(2),
									Leash(self.inst, DoStalking, 0, 0),
								},
								ChaseAndAttack(self.inst),
							}),
					}, 0.5)),
				Leash(self.inst, DoStalking, 0, 0),
				ParallelNode{
					WhileNode(function() return not self.inst.components.combat:HasTarget() end, "Loiter",
						SequenceNode{
							WaitNode(6),
							ConditionWaitNode(function()
								local pos = GetHome(self.inst)
								if pos == nil or self.inst:GetDistanceSqToPoint(pos) < WANDER_DIST * WANDER_DIST then
									self.inst:PushEvent("lunar_grazer_despawn")
								end
								return false
							end, "Despawn"),
						}),
					Wander(self.inst, GetHome, WANDER_DIST),
				}
			}, 0.5)),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return LunarGrazerBrain
