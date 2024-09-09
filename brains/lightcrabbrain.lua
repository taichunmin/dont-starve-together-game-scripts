require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
local BrainCommon = require("brains/braincommon")

local AVOID_PLAYER_DIST = 5
local AVOID_PLAYER_STOP = 9

local SEE_BAIT_DIST = 5

local WANDER_TIMING = {minwaittime = 10, randwaittime = 10}

local LightCrabBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.homeseeker and
       inst.components.homeseeker.home and
       inst.components.homeseeker.home:IsValid() and
	   inst.sg:HasStateTag("trapped") == false then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_BAIT_DIST, function(item, i)
            return i.components.eater:CanEat(item) and
                item.components.bait and
                not item:HasTag("planted") and
                not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) and
                item:IsOnPassablePoint() and
                item:GetCurrentPlatform() == i:GetCurrentPlatform()
        end)

    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not target:IsInLimbo() end
        return act
    end
end


function LightCrabBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.sg:HasStateTag("jumping") end, "Standby",
            ActionNode(function() --[[do nothing]] end)),

		BrainCommon.PanicTrigger(self.inst),
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        DoAction(self.inst, EatFoodAction),
        Wander(self.inst, nil, nil, WANDER_TIMING),
    }, .25)
    self.bt = BT(self.inst, root)
end

return LightCrabBrain
