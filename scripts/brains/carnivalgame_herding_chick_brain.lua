require "behaviours/wander"
require "behaviours/runaway"

local GOHOME_SEE_SCARY_DIST = 2
local GOHOME_STOP_SCARY_DIST= 4

local SEE_HOME_DIST = 4
local STOP_HOME_DIST = 6

local MAX_WANDER_DIST = 12

local CarnivalGame_Herding_ChickBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local RUNAWAY_PARAMS = { oneoftags = {"minigame_participator", "minigame_spectator"} }
local AVOID_HOME_TAG = "carnivalgame_herding_station"

function CarnivalGame_Herding_ChickBrain:OnStart()

	local root =
	PriorityNode(
	{
	    WhileNode(function() return self.inst.components.locomotor ~= nil end, "landed",
	        PriorityNode({
				RunAway(self.inst, RUNAWAY_PARAMS, GOHOME_SEE_SCARY_DIST, GOHOME_STOP_SCARY_DIST, nil, nil, true, nil, function() return self.inst.components.knownlocations:GetLocation("home") end),
				RunAway(self.inst, AVOID_HOME_TAG, SEE_HOME_DIST, STOP_HOME_DIST, nil, nil, true, true),
				Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST,
					{minwalktime=1.5,  randwalktime=1, minwaittime=0.5, randwaittime=1.5})
        }, 0)),
    }, 0)

	self.bt = BT(self.inst, root)
end

return CarnivalGame_Herding_ChickBrain
