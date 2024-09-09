require "behaviours/wander"
require "behaviours/leash"
require "behaviours/follow"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/standstill"

local SPLASH_AVOID_DIST = 2
local SPLASH_AVOID_STOP = 5

local SCARY_AVOID_DIST = 6
local SCARY_AVOID_STOP = 10

local SEE_FOOD_DIST = 4
local EAT_DELAY = 10

local SEE_LURE_MAX_DIST = 5

local SEE_LURE_OR_FOOD_DIST = math.max(SEE_FOOD_DIST, SEE_LURE_MAX_DIST)

local FOOD_WANDER_DIST = 4
local FOOD_WANDER_TIMES = {minwalktime=0.6, randwalktime=0.2, minwaittime=0.0, randwaittime=0.0}
local FOOD_WANDER_DATA = {wander_dist = 2}

local FLEEING_DURATION = 3.5
local FLEEING_MAX_WANDER_DIST = 50
local FLEEING_WANDER_TIMES = {minwalktime=1, randwalktime=0.5, minwaittime=0.0, randwaittime=0.0}
local FLEEING_WANDER_DATA = {should_run = true}

local MAX_FISER_DIST = TUNING.OCEAN_FISHING.MAX_HOOK_DIST

local STRUGGLE_WANDER_TIMES = {minwalktime=0.3, randwalktime=0.2, minwaittime=0.0, randwaittime=0.0}
local STRUGGLE_WANDER_DATA = {wander_dist = 6, should_run = true}

local TIREDOUT_WANDER_TIMES = {minwalktime=0.5, randwalktime=0.5, minwaittime=0.0, randwaittime=0.0}
local TIREDOUT_WANDER_DATA = {wander_dist = 2.5, should_run = false}
local TIREDOUT_WANDER_DATA_FAST_MOVING = {wander_dist = 4, should_run = false}
local function GetTiredoutWanderData(inst)
	return (inst.fish_def ~= nil and inst.fish_def.walkspeed ~= nil and inst.fish_def.walkspeed >= 2) and TIREDOUT_WANDER_DATA_FAST_MOVING or TIREDOUT_WANDER_DATA
end

local WANDER_TIMES = {minwalktime=0.25, randwalktime=0.5, minwaittime=0.0, randwaittime=0.0}
local function getWanderDist(inst)
	return (inst.components.herdmember ~= nil and inst.components.herdmember.enabled) and 2 
			or inst.fish_def ~= nil and inst.fish_def.herdless_wander_dist
			or 16
end

local function WanderTarget(inst)
	if inst.components.knownlocations:GetLocation("herd_offset") then
		return inst.components.knownlocations:GetLocation("herd_offset")
	else
		return inst.components.knownlocations:GetLocation("home")
	end
end

local function getWanderData(inst)
	if inst.fish_def ~= nil and inst.fish_def.wander_seek_dist ~= nil then
		return {wander_dist = inst.fish_def.wander_seek_dist}
	end
	return nil
end

local function GetFisherPosition(inst)
	local rod = inst.components.oceanfishable:GetRod()
	return rod ~= nil and rod:GetPosition() or nil
end

local function GetFoodTarget(inst)
	local ft = inst.food_target
	if ft ~= nil then
		if ft:IsValid() and not ft:HasTag("INLIMBO") and TheWorld.Map:IsOceanAtPoint(ft.Transform:GetWorldPosition()) then
			if not ft:HasTag("oceantrawler") then
				return ft
			end
			if ft.components.oceantrawler and ft.components.oceantrawler:IsLowered() then
				return ft
			end
		end
		inst.food_target = nil
	end
end

local function GetFoodTargetPos(inst)
	local target = GetFoodTarget(inst)
	return target ~= nil and target:GetPosition() or nil
end

local FINDFOOD_CANT_TAGS = {"planted", "INLIMBO"}
local FINDFOOD_ONEOF_TAGS = {"fishinghook", "oceantrawler"}
local function FindFoodAction(inst)
	if GetFoodTarget(inst) == nil then
		local target = FindEntity(inst, SEE_LURE_OR_FOOD_DIST, function(food)
							if food:HasTag("fishinghook") then
								return food.components.oceanfishinghook ~= nil
									and TheWorld.Map:IsOceanAtPoint(food.Transform:GetWorldPosition())
									and not food.components.oceanfishinghook:HasLostInterest(inst)
									and food.components.oceanfishinghook:TestInterest(inst)
							elseif food:HasTag("oceantrawler") then
								return food.components.oceantrawler ~= nil
									and food.components.oceantrawler:IsLowered()
									and food.components.oceantrawler:GetBait(inst.prefab) ~= nil
							end
							return inst:IsNear(food, SEE_FOOD_DIST) and TheWorld.Map:IsOceanAtPoint(food.Transform:GetWorldPosition())
						end,
						nil,
						FINDFOOD_CANT_TAGS,
						JoinArrays(inst.components.eater:GetEdibleTags(), FINDFOOD_ONEOF_TAGS))

		inst.food_target = target
		inst.num_nibbles = 1
	end

	return false
end

local function NibbleFoodAction(inst)
	local act = nil
	local food = GetFoodTarget(inst)
	if food ~= nil then
		if not food:HasTag("fishinghook") then
			if inst.num_nibbles == nil or math.random() <= (.25*inst.num_nibbles) then
				act = BufferedAction(inst, food, ACTIONS.EAT)
			else
				act = BufferedAction(inst, food, ACTIONS.WALKTO)
				act:AddSuccessAction(function() inst:PushEvent("dobreach") end)
			end
		else
			local interest = food.components.oceanfishinghook:UpdateInterestForFishable(inst)
			if interest == 0 then
				inst.food_target = nil
			elseif inst.num_nibbles >= 5 then
				food.components.oceanfishinghook:SetLostInterest(inst)
				inst.food_target = nil
			elseif interest > 0.85 or ((interest >= TUNING.OCEANFISH_MIN_INTEREST_TO_BITE or inst.num_nibbles > 1) and math.random() <= interest) then
				act = BufferedAction(inst, food, ACTIONS.EAT)
			else
				act = BufferedAction(inst, food, ACTIONS.WALKTO)
			end
		end
		inst.num_nibbles = inst.num_nibbles + 1
	end
	return act
end

local function getdirectionFn(inst)
	local r = math.random() * 2 - 1
	return (inst.Transform:GetRotation() + r*r*r * 60) * DEGREES
end

local function getstruggledirectionFn(inst)
	local rod = inst.components.oceanfishable:GetRod()
	return (inst:GetAngleToPoint(rod.Transform:GetWorldPosition()) + 180 + (math.random(7) - 3.5) * 20) * DEGREES
end

local DEFAULT_TIREDOUT_ANGLES = {has_tention = 80, low_tention = 120}
local function gettiredoutdirectionFn(inst)
	local rod = inst.components.oceanfishable:GetRod()
	local angle = rod ~= nil and inst:GetAngleToPoint(rod.Transform:GetWorldPosition()) or inst.Transform:GetRotation()
	local tiredout_angles = inst.components.oceanfishable.stamina_def ~= nil and inst.components.oceanfishable.stamina_def.tiredout_angles or DEFAULT_TIREDOUT_ANGLES
	local theta = (rod ~= nil and rod.components.oceanfishingrod ~= nil and rod.components.oceanfishingrod:IsLineTensionGood()) and tiredout_angles.has_tention or tiredout_angles.low_tention

	local r = math.random() * 2 - 1
	return (angle + r*r*r * theta) * DEGREES
end

local function getfleedirectionFn(inst)
	local r = math.random() * 2 - 1
	return (inst.Transform:GetRotation() + r*r*r * 80) * DEGREES
end

local OceanFishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function OceanFishBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "<jump guard>",
            PriorityNode({
				WhileNode(function() return self.inst.leaving end, "leaving",
					ParallelNode{
						LoopNode{
							WaitNode(FLEEING_DURATION + math.random()),
							ActionNode(function() self.inst:PushEvent("doleave") end),
						},
						Wander(self.inst, self.inst.components.knownlocations:GetLocation("home"), FLEEING_MAX_WANDER_DIST, FLEEING_WANDER_TIMES, getfleedirectionFn, nil, nil, FLEEING_WANDER_DATA)
					}
				),

				WhileNode(function() return self.inst.components.oceanfishable ~= nil and self.inst.components.oceanfishable:GetRod() ~= nil end, "Hooked",
					PriorityNode({
				        WhileNode(function() return self.inst:HasTag("partiallyhooked") end, "partiallyhooked",
							StandStill(self.inst)),
						PriorityNode({
							WhileNode(function() self.inst.components.oceanfishable:UpdateStruggleState() return self.inst.components.oceanfishable:IsStruggling() end, "struggle",
								Wander(self.inst, GetFisherPosition, MAX_FISER_DIST, STRUGGLE_WANDER_TIMES, getstruggledirectionFn, nil, nil, STRUGGLE_WANDER_DATA)),
							Wander(self.inst, GetFisherPosition, MAX_FISER_DIST, TIREDOUT_WANDER_TIMES, gettiredoutdirectionFn, nil, nil, GetTiredoutWanderData(self.inst)),
						}),
					})
				),

				RunAway(self.inst, "oceansplash", SPLASH_AVOID_DIST, SPLASH_AVOID_STOP),
				RunAway(self.inst, {tags = {"scarytooceanprey"}}, SCARY_AVOID_DIST, SCARY_AVOID_STOP), -- using this to disable the "NOCLICK" no tag

				NotDecorator(ActionNode(function() FindFoodAction(self.inst) end)),
				WhileNode(function() return GetFoodTarget(self.inst) ~= nil end, "FeedingTime",
					LoopNode{
						ParallelNodeAny{
							WaitNode(function() return 1 + math.random() * 1 end),
							Wander(self.inst, GetFoodTargetPos, FOOD_WANDER_DIST, FOOD_WANDER_TIMES, nil, nil, nil, FOOD_WANDER_DATA),
						},
						DoAction(self.inst, NibbleFoodAction),
						ConditionWaitNode(function() return self.inst:GetBufferedAction() == nil end),
					}
				),

				FindClosest(self.inst, TUNING.OCEANFISH_SEE_CHUM_DIST, 0, { "chum" }),
				Wander(self.inst, WanderTarget, getWanderDist(self.inst), WANDER_TIMES, getdirectionFn, nil, nil, getWanderData(self.inst))
            }, 0.25)),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

function OceanFishBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), true)
end

return OceanFishBrain
