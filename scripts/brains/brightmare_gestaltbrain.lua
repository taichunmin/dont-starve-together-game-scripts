require "behaviours/follow"
require "behaviours/wander"
require "behaviours/standstill"

local BRIGHTMARE_AVOID_DIST = 2
local BRIGHTMARE_AVOID_STOP = 4

local AVOID_SHADOW_DIST = 5
local AVOID_SHADOW_STOP = 8

local L1_AVOID_PLAYER_DIST = 3
local L1_AVOID_PLAYER_STOP = 6

local L2_FACE_PLAYER_DIST = 6
local L2_FACE_PLAYER_DURATION = 5
local L2_AVOID_PLAYER_DIST = L2_FACE_PLAYER_DIST + 0.1
local L2_AVOID_PLAYER_STOP = L2_FACE_PLAYER_DIST + 2

local L3_ATTACK_CHASE_START_DIST = L2_FACE_PLAYER_DIST
local L3_ATTACK_CHASE_DIST = L3_ATTACK_CHASE_START_DIST + 3
local L3_ATTACK_CHASE_TIME = 5
local L3_AVOID_PLAYER_DIST = L3_ATTACK_CHASE_START_DIST + 0.1
local L3_AVOID_PLAYER_STOP = L3_AVOID_PLAYER_DIST + 2


local SHADOW_TAGS = {oneoftags = {"nightmarecreature", "shadowcreature", "shadow", "shadowminion", "stalker", "stalkerminion", "nightmare", "shadow_fire"}}

local GestaltBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldRelocate(inst)
    return not inst._ignorerelocating
        and not inst.sg:HasStateTag("busy")
        and (inst.tracking_target == nil or not inst:IsNearPlayer(TUNING.GESTALT_RELOCATED_FAR_DIST, true))
end

local function Relocate(inst)
	inst.sg:GoToState("relocate")
end

local function onrunaway(target, inst)
	inst.components.combat:DropTarget()
	return true
end

function GestaltBrain:OnStart()
    local root = PriorityNode({
		WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "AttackAndWander",
			PriorityNode({
				WhileNode( function() return ShouldRelocate(self.inst) end, "relocate",
					SequenceNode{
						ActionNode(function() Relocate(self.inst) end),
						StandStill(self.inst),
					}),


				RunAway(self.inst, SHADOW_TAGS, AVOID_SHADOW_DIST, AVOID_SHADOW_STOP, onrunaway),
				WhileNode( function() return self.inst.behaviour_level == 1 end, "level1",
					PriorityNode({
						RunAway(self.inst, "player", L1_AVOID_PLAYER_DIST, L1_AVOID_PLAYER_STOP),
					}, 0.1)),

				WhileNode( function() return self.inst.behaviour_level == 2 end, "level2",
					PriorityNode({
						WhileNode( function() return self.inst.components.combat.target ~= nil end, "aggressive",
							SequenceNode{
								ActionNode(function() self.inst.components.locomotor:Stop() end),
								StandAndAttack(self.inst, nil, L3_ATTACK_CHASE_TIME),
							}),
						IfNode(function() return self.inst.components.combat:InCooldown() end, "combat_pst",
							RunAway(self.inst, "player", L2_AVOID_PLAYER_DIST, L2_AVOID_PLAYER_STOP)),
					}, 0.1)),

				WhileNode( function() return self.inst.behaviour_level == 3 end, "level3",
					PriorityNode({
						ChaseAndAttack(self.inst, L3_ATTACK_CHASE_TIME, L3_ATTACK_CHASE_DIST, nil, nil, true),
						IfNode(function() return self.inst.components.combat:InCooldown() end, "combat_pst",
							RunAway(self.inst, "player", L2_AVOID_PLAYER_DIST, L2_AVOID_PLAYER_STOP)),
					}, 0.1)),

				RunAway(self.inst, "brightmare", BRIGHTMARE_AVOID_DIST, BRIGHTMARE_AVOID_STOP),
				Wander(self.inst, nil, nil, { minwaittime = 0, randwaittime = 0 }),
			}, 0.1)),
		}, 0.1)

    self.bt = BT(self.inst, root)
end

return GestaltBrain