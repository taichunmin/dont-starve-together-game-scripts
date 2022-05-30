require "behaviours/follow"
require "behaviours/wander"
require "behaviours/standstill"
require "behaviours/faceentity"

local BRIGHTMARE_AVOID_DIST = 2
local BRIGHTMARE_AVOID_STOP = 4

local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 20

local ATTACK_CHASE_TIME = 5

local WANDER_TIMES = { minwalktime = 2, randwalktime = 2, minwaittime = 3, randwaittime = 3 }

local RELOCATED_DISTSQ = 3*3

local GETFACINGTARGET_DISTSQ = TUNING.GESTALTGUARD_WATCHING_RANGE*TUNING.GESTALTGUARD_WATCHING_RANGE

local GestaltGuardBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function IsPlayerTooClose(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return IsAnyPlayerInRangeSq(x, y, z, RELOCATED_DISTSQ, true)
end

local function Relocate(inst)
	inst.sg:GoToState("relocate")
end

local function GetFacingTarget(inst)
	local target = inst.behaviour_level == 2 and inst.components.combat.target or nil
	if target ~= nil and target:IsValid() then
		local p1x, _, p1z = inst.Transform:GetWorldPosition()
		local p2x, _, p2z = target.Transform:GetWorldPosition()
		return (distsq(p1x, p1z, p2x, p2z) <= GETFACINGTARGET_DISTSQ) and target or nil
	end
end

local function KeepFacingTarget(inst, target)
	return GetFacingTarget(inst) == target
end

function GestaltGuardBrain:OnStart()
    local root = PriorityNode({
		WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "",
			PriorityNode({
				WhileNode( function() return self.inst.behaviour_level == 3 end, "Aggressive",
					ChaseAndAttack(self.inst, ATTACK_CHASE_TIME, nil, nil, nil, true)
				),

				WhileNode( function() return IsPlayerTooClose(self.inst) end, "Relocate",
					SequenceNode{
						ActionNode(function() Relocate(self.inst) end),
						StandStill(self.inst),
					}
				),

				FaceEntity(self.inst, GetFacingTarget, KeepFacingTarget),
				Wander(self.inst, nil, nil, WANDER_TIMES),
			}, 0.1)),
		}, 0.1)

    self.bt = BT(self.inst, root)
end

function GestaltGuardBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition(), true)
end

return GestaltGuardBrain