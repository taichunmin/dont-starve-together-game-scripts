require("behaviours/chaseandattack")
require("behaviours/faceentity")
require("behaviours/wander")

local WANDER_DIST = 6
local FORMATION_DIST = 6

local ShadowThrallHornsBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GetHome(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
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

local function GetFormationPos(inst)
	if inst.formation ~= nil then
		local pos = GetTargetPos(inst)
		if pos ~= nil then
			local angle = inst.formation * DEGREES
			pos.x = pos.x + math.cos(angle) * FORMATION_DIST
			pos.z = pos.z - math.sin(angle) * FORMATION_DIST
			return pos
		end
	end
end

local function IsTheirTurnToAttack(inst, teammate)
	teammate = inst.components.entitytracker:GetEntity(teammate)
	return teammate ~= nil
		and teammate.sg ~= nil
		and teammate.sg.mem.lastattack ~= nil
		and teammate.sg.mem.lastattack < inst.sg.mem.lastattack
		and teammate.components.combat ~= nil
		and inst.components.combat:TargetIs(teammate.components.combat.target)
end

local function IsMyTurnToAttack(inst)
	if inst.components.combat:InCooldown() then
		return false
	elseif inst.sg.mem.lastattack ~= nil and (
			IsTheirTurnToAttack(inst, "hands") or
			IsTheirTurnToAttack(inst, "wings")
		) then
		return false
	end
	return true
end

function ShadowThrallHornsBrain:OnStart()
	local root = PriorityNode({
		WhileNode(
			function() return not self.inst.sg:HasStateTag("jumping") end, "<busy state guard>",
			PriorityNode({
				WhileNode(function() return not IsMyTurnToAttack(self.inst) end, "WaitingTurn",
					PriorityNode({
						FailIfSuccessDecorator(
							Leash(self.inst, GetFormationPos, 2, 0.5)),
						FailIfSuccessDecorator(
							Leash(self.inst, GetTargetPos, TUNING.SHADOWTHRALL_HORNS_ATTACK_RANGE + 2, TUNING.SHADOWTHRALL_HORNS_ATTACK_RANGE - 2)),
						FaceEntity(self.inst, GetTarget, IsTarget),
					}, 0.5)),
				ParallelNode{
					ChaseAndAttack(self.inst),
					SequenceNode{
						WaitNode(1),
						ConditionWaitNode(function()
							if not self.inst.sg:HasStateTag("attack") and IsMyTurnToAttack(self.inst) then
								self.inst:PushEvent("doattack", { target = self.inst.components.combat.target })
							end
							return false
						end, "ForceAttack"),
					},
				},
				Wander(self.inst, GetHome, WANDER_DIST),
			}, 0.5)),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return ShadowThrallHornsBrain
