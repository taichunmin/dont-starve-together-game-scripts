require("behaviours/chaseandattack")
require("behaviours/chattynode")
require("behaviours/faceentity")
require("behaviours/leash")
require("behaviours/wander")

local FAR_TRADE_DIST_SQ = 20 * 20
local NEAR_TRADE_DIST_SQ = 4 * 4

local SharkboiBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

--see "idle" state
local function TryRestoreCanRotate(inst)
	if inst.sg:HasStateTag("try_restore_canrotate") then
		inst.sg:RemoveStateTag("try_restore_canrotate")
		inst.sg:AddStateTag("canrotate")
		inst.Transform:SetFourFaced()
		inst.components.locomotor.pusheventwithdirection = false
	end
end

local function GetTarget(inst)
	return inst.components.combat.target
end

local function IsTarget(inst, target)
	return inst.components.combat:TargetIs(target)
end

local function GetTargetPos(inst)
	local target = GetTarget(inst)
	return target and target:GetPosition() or nil
end

local function GetNearbyPlayerFn(inst)
	local player, distsq = FindClosestPlayerToInst(inst, 6, true)
	if player then
		TryRestoreCanRotate(inst)
		return player
	end
end

local function KeepNearbyPlayerFn(inst, target)
	return not (target.components.health and target.components.health:IsDead() or
				target:HasTag("playerghost"))
end

local function _GetTraderFn(inst, minrangesq, maxrangesq)
	if inst.components.trader then
		local x, y, z = inst.Transform:GetWorldPosition()
		for i, v in ipairs(AllPlayers) do
			if not (v.components.health:IsDead() or v:HasTag("playerghost")) and v.entity:IsVisible() then
				local distsq = v:GetDistanceSqToPoint(x, y, z)
				if distsq < maxrangesq and distsq >= minrangesq and inst.components.trader:IsTryingToTradeWithMe(v) then
					inst:SetIsTradingFlag(true, 0.5 + FRAMES)
					TryRestoreCanRotate(inst)
					return v
				end
			end
		end
	end
end

local function GetFarTraderFn(inst)
	return _GetTraderFn(inst, NEAR_TRADE_DIST_SQ, FAR_TRADE_DIST_SQ)
end

local function GetNearTraderFn(inst)
	return _GetTraderFn(inst, 0, NEAR_TRADE_DIST_SQ)
end

local function GetTraderFn(inst)
	return _GetTraderFn(inst, 0, FAR_TRADE_DIST_SQ)
end

local function KeepTraderFn(inst, target)
	if inst.components.trader and inst.components.trader:IsTryingToTradeWithMe(target) then
		inst:SetIsTradingFlag(true, 0.5 + FRAMES)
		return true
	end
	inst:SetIsTradingFlag(false)
end

local function GetWanderDir(inst)
	if inst.hole then
		local x, y, z = inst.Transform:GetWorldPosition()
		local x1, y1, z1 = inst.hole.Transform:GetWorldPosition()
		if x ~= x1 or z ~= z1 then
			local dx = x1 - x
			local dz = z1 - z
			local dsq = dx * dx + dz * dz
			local angle = math.atan2(-dz, dx)
			local rad = inst.hole:GetPhysicsRadius(0) + 2.5
			if dsq <= rad * rad then
				return angle + PI
			end
			local theta = math.abs(math.asin(rad / math.sqrt(dsq)))
			return angle + theta + math.random() * (PI2 - 2 * theta)
		end
	end
end

local WANDER_DATA = { wander_dist = 5.5 }
local function WanderAroundHole(inst)
	return Wander(inst, nil, nil, nil, GetWanderDir, nil, nil, WANDER_DATA)
end

local CHATTERPARAMS_LOW = {
	echotochatpriority = CHATPRIORITIES.LOW,
}
local CHATTERPARAMS_HIGH = {
	echotochatpriority = CHATPRIORITIES.HIGH,
}

function SharkboiBrain:OnStart()
	local root = PriorityNode({
		WhileNode(
			function()
				return not self.inst.sg:HasAnyStateTag("jumping", "defeated", "sleeping")
			end,
			"<busy state guard>",
			PriorityNode({
				WhileNode(function() return self.inst.components.combat:InCooldown() end, "Chase",
					PriorityNode({
						FailIfSuccessDecorator(
							Leash(self.inst, GetTargetPos, TUNING.SHARKBOI_MELEE_RANGE, 3, true)),
						FaceEntity(self.inst, GetTarget, IsTarget),
					}, 0.5)),
				ChattyNode(self.inst, {
						name = "SHARKBOI_TALK_FIGHT",
						chatterparams = CHATTERPARAMS_LOW,
					},
					ParallelNode{
						ConditionWaitNode(function()
							local target = self.inst.components.combat.target
							if target and not self.inst.components.combat:InCooldown() and
								self.inst:IsNear(target, TUNING.SHARKBOI_ATTACK_RANGE + target:GetPhysicsRadius(0))
							then
								self.inst.components.combat.ignorehitrange = true
								self.inst.components.combat:TryAttack(target)
								self.inst.components.combat.ignorehitrange = false
							end
							return false
						end),
						ChaseAndAttack(self.inst),
					}),
				--Sharkboi won the battle? (or all targets deaggroed?)
				IfNode(function() return self.inst:HasTag("hostile") end, "Gloating",
					ChattyNode(self.inst, {
							name = "SHARKBOI_TALK_GLOAT",
							chatterparams = CHATTERPARAMS_LOW,
						},
						WanderAroundHole(self.inst))),
				--Out of stock (after defeated)
				IfNode(function() return self.inst.components.trader and self.inst.stock <= 0 end, "Out of stock",
					PriorityNode({
						FaceEntity(self.inst, GetTraderFn, KeepTraderFn),
						WanderAroundHole(self.inst),
					}, 0.5)),
				--Trader (after defeated)
				WhileNode(function() return self.inst.components.trader and self.inst.stock > 0 end, "Friendly",
					PriorityNode({
						ChattyNode(self.inst, {
								name = "SHARKBOI_TALK_ATTEMPT_TRADE",
								chatterparams = CHATTERPARAMS_HIGH,
							},
							FaceEntity(self.inst, GetFarTraderFn, KeepTraderFn)),
						FaceEntity(self.inst, GetNearTraderFn, KeepTraderFn),
						SequenceNode{
							ChattyNode(self.inst, {
									name = "SHARKBOI_TALK_FRIENDLY",
									chatterparams = CHATTERPARAMS_HIGH,
								},
								FaceEntity(self.inst, GetNearbyPlayerFn, KeepNearbyPlayerFn, 6)),
							ParallelNodeAny{
								WanderAroundHole(self.inst),
								WaitNode(7),
							},
						},
						WanderAroundHole(self.inst),
					}, 0.5)),
				--When first spawned; alternate between wandering and looking at you
				SequenceNode{
					ChattyNode(self.inst, {
							name = "SHARKBOI_TALK_IDLE",
							chatterparams = CHATTERPARAMS_LOW,
						},
						FaceEntity(self.inst, GetNearbyPlayerFn, KeepNearbyPlayerFn, 4)),
					ParallelNodeAny{
						WanderAroundHole(self.inst),
						WaitNode(10),
					},
				},
				WanderAroundHole(self.inst),
			}, 0.5)),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return SharkboiBrain
