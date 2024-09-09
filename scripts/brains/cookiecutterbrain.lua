require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/leash"
require "behaviours/wander"
require "behaviours/standstill"

local CookieCutterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local BOARD_BOAT_TIMEOUT = 5

local SCATTER_DIST = 3
local SCATTER_STOP = 5

local FLEE_DIST = 15.5
local FLEE_STOP = 14.5 -- Should for now be larger than the longeinst range weapon

local WANDER_DIST = TUNING.COOKIECUTTER.WANDER_DIST
local WANDER_TIMES = {minwalktime=2.0, randwalktime=4.0, minwaittime=3.0, randwaittime=6.0}

local function EatFoodAction(inst)
	local target = inst.target_wood
	return (target ~= nil and target:IsValid()
				and inst:IsNear(target, 2)
				and target:HasTag("edible_WOOD") and not target:HasTag("INLIMBO")
				and (target.components.burnable == nil or (not target.components.burnable:IsBurning() and not target.components.burnable:IsSmoldering()))
				and TheWorld.Map:IsOceanAtPoint(target.Transform:GetWorldPosition()))
			and BufferedAction(inst, target, ACTIONS.EAT)
			or nil
end

local function GetTargetPosition(inst)
	return (inst.target_wood ~= nil and inst.target_wood:IsValid()) and inst.target_wood:GetPosition() or nil
end

local function GetWanderPoint(inst)
	return inst.components.knownlocations:GetLocation("home")
end

local function IsTooFarFromHome(inst)
	local home_pt = inst.components.knownlocations:GetLocation("home")
	return home_pt ~= nil and inst:GetDistanceSqToPoint(home_pt:Get()) > WANDER_DIST * WANDER_DIST * 4
end

local function CalcWanderDir(inst)
	local r = math.random() * 2 - 1
	return (inst.Transform:GetRotation() + r*r*r * 60) * DEGREES
end

local function BoatInRange(inst)
	return not inst.sg:HasStateTag("busy") and inst.target_wood ~= nil and inst.target_wood:HasTag("boat") and inst.target_wood:IsValid() and inst:IsNear(inst.target_wood, 6)
end

local function TryToBoardBoat(inst)
	local boat_pos = (inst.target_wood ~= nil and inst.target_wood:IsValid() and inst.target_wood:HasTag("boat")) and inst.target_wood:GetPosition() or nil
	inst.sg:GoToState("jump_pre", boat_pos)
end

function CookieCutterBrain:OnStart()
    local root = PriorityNode(
        {
	        WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "pause for jump",
	            PriorityNode({
					WhileNode(function() return self.inst.sg:HasStateTag("drilling") end, "Drilling",
						StandStill(self.inst)),

					RunAway(self.inst, {tags = {"scarytocookiecutters"}}, SCATTER_DIST, SCATTER_STOP),
					WhileNode(function() return self.inst.is_fleeing end, "Fleeing",
						RunAway(self.inst, "scarytoprey", FLEE_DIST, FLEE_STOP)),

					WhileNode(function() return IsTooFarFromHome(self.inst) end, "AwayFromHome",
						SequenceNode{
							ActionNode(function() self.inst:PushEvent("gohome") end, "TryToBoard"),
							ConditionWaitNode(function() return false end),
						}),

					WhileNode(function() return BoatInRange(self.inst) end, "BoatInRange",
						SequenceNode{
							ActionNode(function() TryToBoardBoat(self.inst) end, "TryToBoard"),
							WaitNode(BOARD_BOAT_TIMEOUT),
						}),

					DoAction(self.inst, EatFoodAction, "Eat Floating", false),

					Leash(self.inst, GetTargetPosition, 0.1, 0.1, false),

					Wander(self.inst, function() return GetWanderPoint(self.inst) end, WANDER_DIST, WANDER_TIMES, CalcWanderDir),
            }, .25)),
        }, .25)

    self.bt = BT(self.inst, root)
end

function CookieCutterBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return CookieCutterBrain
