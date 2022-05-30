require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/runaway"
require "behaviours/leash"


local CHALLENGE_LOST_RUN_AWAY_DIST = 10
local CHALLENGE_LOST_STOP_RUN_AWAY_DIST = 15

local MAX_HOME_WANDER_DIST = TUNING.FRUITDRAGON.NAP_DIST_FROM_HOME * 2

local MAX_CHASE_DIST = 12

local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST = 4.5

local function GetHome(inst)
	return inst.components.entitytracker:GetEntity("home")
end

local function IsHomeMoveable(inst)
	local home = inst.components.entitytracker:GetEntity("home")
	home = (home ~= nil and home.components.inventoryitem ~= nil) and home.components.inventoryitem:GetGrandOwner() or home
	return home ~= nil and home.components.locomotor ~= nil
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.entitytracker:GetEntity("home") == target
end

local function GetHomePos(inst)
	return inst.components.entitytracker:GetEntity("home") and inst.components.entitytracker:GetEntity("home"):GetPosition() or nil
end

local FruitDragonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local wander_timing = {minwalktime = 4, randwalktime = 4, randwaittime = 1}

function FruitDragonBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.timer:TimerExists("panicing") end, "LostChallenge",
			RunAway(self.inst, "fruitdragon", CHALLENGE_LOST_RUN_AWAY_DIST, CHALLENGE_LOST_STOP_RUN_AWAY_DIST)),
        ChaseAndAttack(self.inst, nil, MAX_CHASE_DIST),

	    WhileNode(function() return GetHome(self.inst) ~= nil end, "HasHome",
	        PriorityNode{
				IfNode(function() return IsHomeMoveable(self.inst) end, "MoveableHome",
			        PriorityNode{
		                Follow(self.inst, function() return GetHome(self.inst) end, 0, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
                        FaceEntity(self.inst, GetHome, KeepFaceTargetFn)
					}),

			    WhileNode(function() return GetHome(self.inst) ~= nil end, "HasHome",
			        PriorityNode{
						WhileNode(function() return TheWorld.state.isnight end, "IsNight",
							Wander(self.inst, GetHomePos, TUNING.FRUITDRAGON.NAP_DIST_FROM_HOME, wander_timing)),
						Wander(self.inst, GetHomePos, MAX_HOME_WANDER_DIST, wander_timing)
					}),
			}
		),

        Wander(self.inst, nil, nil, wander_timing),
    }, .25)
    self.bt = BT(self.inst, root)
end


return FruitDragonBrain