require("behaviours/chaseandattackandavoid")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/leashandavoid")
require("behaviours/standstill")
require("behaviours/wander")

local AVOID_JUNK_DIST = 7

local Daywalker2Brain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
	self.lastjunk = nil
end)

local function GetJunk(inst)
	return inst.components.entitytracker:GetEntity("junk")
end

local function GetJunkPos(inst)
	local junk = GetJunk(inst)
	return junk and junk:GetPosition() or nil
end

local function GetTarget(inst)
	return inst.components.combat.target
end

local function GetTargetPos(inst)
	local target = inst.components.combat.target
	return target and target:GetPosition() or nil
end

local function IsTarget(inst, target)
	return inst.components.combat:TargetIs(target)
end

local function ShouldRunToJunk(inst)
	return inst.components.combat:HasTarget()
end

local function GetCurrentJunkLoot(inst, ignorerange)
	local junk, item = inst:GetNextItem()
	if junk then
		if item and inst.candoublerummage then
			local numequipped =
				(inst.canswing and 1 or 0) +
				(inst.cantackle and 1 or 0) +
				(inst.cancannon and 1 or 0)
			if numequipped >= 2 then
				item = nil
			end
		end
		if item then
			return junk, item
		end
		if inst.canthrow then
			local target = inst.components.combat.target
			if target then
				if not ignorerange then
					local threshold = inst:IsNear(target, 12) and 20 or 16
					if target:IsNear(junk, threshold) then
						return
					end
				end
				return junk, "ball"
			end
		end
	end
end

local function MaxTargetLeashDist(inst)
	local target = inst.components.combat.target
	if target and inst.cantackle and not inst:TestTackle(target, TUNING.DAYWALKER2_TACKLE_RANGE) then
		--use forced tackle range (2(aoe radius) + 1(offset))
		--This is to prevent stopping short of target, but not tackling due to failed junk collision test
		return 3 + (target and target:GetPhysicsRadius(0) or 0)
	end
	return 4 + (target and target:GetPhysicsRadius(0) or 0)
end

local function MinTargetLeashDist(inst)
	local target = inst.components.combat.target
	return 3 + (target and target:GetPhysicsRadius(0) or 0)
end

local function LeashShouldRun(inst)
	if inst.sg:HasStateTag("running") then
		return true
	elseif inst.components.stuckdetection:IsStuck() then
		return true
	elseif inst.canswing or inst.cancannon then
		local target = inst.components.combat.target
		if target then
			local cd = inst.components.combat:GetCooldown()
			return cd <= 0.5 and not inst:IsNear(target, 6)
		end
	elseif inst.cantackle then
		local target = inst.components.combat.target
		if target then
			if not inst.components.combat:InCooldown() then
				if not inst:IsNear(target, TUNING.DAYWALKER2_TACKLE_RANGE + 2) then
					return true --far, so run to chase
				elseif not inst:TestTackle(target, TUNING.DAYWALKER2_TACKLE_RANGE + 2) then
					return true --close, but hiding around junk, so run to chase
				end
			end
		end
	end
	return false
end

--Once we've decided to go rummage, stick to the decision unless target gets too close
local function ShouldRummage(inst, self)
	if not inst.components.combat:HasTarget() then
		self.cachedrummage = false
		return false
	end
	local junk, loot = GetCurrentJunkLoot(inst, false)
	if loot then
		self.cachedrummage = loot == "ball" and not inst.sg:HasStateTag("busy")
		return true
	end
	if self.cachedrummage then
		if inst.sg:HasStateTag("busy") then
			self.cachedrummage = false
		elseif inst.canswing or inst.cancannon or inst.cantackle then
			local target = inst.components.combat.target
			if target and not inst.components.combat:InCooldown() and inst:IsNear(target, 6) then
				self.cachedrummage = false
			end
		end
	end
	return self.cachedrummage
end

local function ShouldStalk(inst)
	local target = inst.components.combat.target
	if target then
		if inst.canswing or inst.cancannon then
			return inst.components.combat:InCooldown()
		elseif inst.cantackle then
			return true
		end
	end
	return false
end

local function ShouldChase(inst)
	return (inst.canswing or inst.cancannon) and not inst.components.combat:InCooldown()
end

local function ShouldTackle(inst)
	if inst.cantackle then
		local target = inst.components.combat.target
		if target then
			return inst:TestTackle(target, TUNING.DAYWALKER2_TACKLE_RANGE)
		end
	end
	return false
end

local function TryStuckAttack(inst)
	if (inst.components.rooted or inst.components.stuckdetection:IsStuck()) and not inst.components.combat:InCooldown() then
		inst.components.combat:TryAttack()
	end
end

local function GetThief(inst)
	local thief = not inst.hostile and (inst.sg.statemem.thief or inst._thief) or nil
	return thief and thief:IsValid() and thief or nil
end

function Daywalker2Brain:OnStart()
	local root = PriorityNode({
		WhileNode(
			function()
				return not self.inst.sg:HasStateTag("jumping")
			end,
			"<busy state guard>",
			PriorityNode({
				--Out of combat warning junk thief
				WhileNode(function() return GetThief(self.inst) ~= nil end, "Warning",
					--"SUCCEED" instead of "FAIL" so we don't get rotated by Wander immediately
					--in case we were just failing to force target switch (_thieflevel changed)
					NotDecorator(FaceEntity(self.inst,
						function(inst)
							local thief = GetThief(inst)
							if thief then
								self._thieflevel = inst._thieflevel
								return thief
							end
						end,
						function(inst, thief)
							return thief
								and not inst.hostile
								and (inst.sg.statemem.thief or inst._thief) == thief
								and inst._thieflevel == self._thieflevel
						end))),

				WhileNode(function() return ShouldRummage(self.inst, self) end, "Rummage",
					PriorityNode({
						ParallelNode{
							FailIfSuccessDecorator(Leash(self.inst, GetJunkPos, 5.5, 5, ShouldRunToJunk)),
							ConditionWaitNode(function() TryStuckAttack(self.inst) end, "StuckAttack"),
						},
						ActionNode(function()
							local junk, loot = GetCurrentJunkLoot(self.inst, true)
							if loot then
								self.inst:PushEvent("rummage", { junk = junk, loot = loot })
							end
						end),
					}, 0.5)),

				--When in cooldown, or if can only tackle
				WhileNode(function() return ShouldStalk(self.inst) end, "Stalking",
					PriorityNode({
						ConditionNode(function()
							if not (self.inst.canswing or self.inst.cancannon or self.inst.components.combat:InCooldown()) and ShouldTackle(self.inst) then
								self.inst:PushEvent("tackle", self.inst.components.combat.target)
								return true
							end
						end, "HighPriorityTackle"),
						FailIfSuccessDecorator(LeashAndAvoid(self.inst, GetJunk, AVOID_JUNK_DIST, GetTargetPos, MaxTargetLeashDist, MinTargetLeashDist, LeashShouldRun)),
						NotDecorator(ActionNode(function()
							if self.inst.components.combat:GetCooldown() < 0.5 then
								self.inst.components.combat:ResetCooldown()
							end
						end)),
						--Note: rechecking ShouldStalk because we may have reset cooldown,
						--      in which case we want it to immediately move to next node.
						IfNode(function() return ShouldStalk(self.inst) end, "ReachedTargetEarly",
							PriorityNode({
								WhileNode(function() return self.inst:IsStalking() end, "StationaryStalking",
									StandStill(self.inst)), --let head tracking do it's thing, don't want flippy body
								WhileNode(function() return not self.inst:IsStalking() end, "StationaryNoStalking",
									FaceEntity(self.inst, GetTarget, IsTarget)),
							}, 0.5)),
					}, 0.5)),

				--When ready to attack with weapon (or optionally tackle)
				WhileNode(function() return ShouldChase(self.inst) end, "Chasing",
					ParallelNode{
						ChaseAndAttackAndAvoid(self.inst, GetJunk, AVOID_JUNK_DIST),
						ConditionWaitNode(function()
							if ShouldTackle(self.inst) then
								self.inst:PushEvent("tackle", self.inst.components.combat.target)
								return true
							end
						end, "LowPriorityTackle"),
					}),

				IfNode(function() return not self.inst.sg.statemem.thief end, "Wander",
					Wander(self.inst, GetJunkPos, 8)),
			}, 0.5)),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return Daywalker2Brain
