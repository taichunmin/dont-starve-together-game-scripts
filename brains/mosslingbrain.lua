require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"

local TIME_BETWEEN_EATING = 3.5

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 500
local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30

local BASE_TAGS = {"structure"}
local STEAL_TAGS = {"structure"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO"}

local PICKABLE_FOODS =
{
	"berries",
	"cave_banana",
	"carrot",
	"red_cap",
	"blue_cap",
	"green_cap",
}

local function GoHome(inst)
	if inst.shouldGoAway and not inst.components.combat.target then
		return BufferedAction(inst, nil, ACTIONS.GOHOME)
	end
end

local function TargetNotClaimed(inst, target)
	local herd = inst.components.herdmember.herd
	if herd and herd.components.herd.members then
		for k,v in pairs(herd.components.herd.members) do
			if k then
				local ba = k:GetBufferedAction()
				if ba and ba.target == target then
					return false
				end
			end
		end
	end
	return true
end

local function EatFoodAction(inst)	--Look for food to eat

	local target = nil
	local action = nil

	if inst.sg:HasStateTag("busy")
		and not inst.sg:HasStateTag("wantstoeat") then
		return
	end

	if inst.components.inventory and inst.components.eater then
		target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
		if target then return BufferedAction(inst,target,ACTIONS.EAT) end
	end

	local pt = inst:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST, nil, NO_TAGS, inst.components.eater:GetEdibleTags())

	if not target then
		for k,v in pairs(ents) do
			if v and v:IsOnValidGround() and
			inst.components.eater:CanEat(v) and
			v:GetTimeAlive() > 5 and
			v.components.inventoryitem and not
			v.components.inventoryitem:IsHeld() and
			TargetNotClaimed(inst, v) then
				target = v
				break
			end
		end
	end

	if target then
		local action = BufferedAction(inst,target,ACTIONS.PICKUP)
		return action
	end
end

local function StealFoodAction(inst) --Look for things to take food from (EatFoodAction handles picking up/ eating)

	-- Food On Ground > Pots = Farms = Drying Racks > Plants

	local target = nil

	if inst.sg:HasStateTag("busy") or
	(inst.components.inventory and inst.components.inventory:IsFull()) then
		return
	end

	local pt = inst:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_STRUCTURE_DIST, nil, NO_TAGS)
	--Look for crop/ cookpots/ drying rack, harvest them.
	if not target then
		for k,item in pairs(ents) do
            -- Since we can't swim or jump to boats, don't investigate containers that are in the water or on boats
			if item:IsOnValidGround() and (
                    (item.components.stewer and item.components.stewer:IsDone()) or
			        (item.components.dryer and item.components.dryer:IsDone()) or
			        (item.components.crop and item.components.crop:IsReadyForHarvest())
                    ) then
				if TargetNotClaimed(inst, item) then
					target = item
					break
				end
			end
		end
	end

	if target then
		return BufferedAction(inst, target, ACTIONS.HARVEST)
	end

	--Berrybushes, carrots etc.
	if not target then
		for k,item in pairs(ents) do
			if item:IsOnValidGround() and
                    item.components.pickable and
			        item.components.pickable.caninteractwith and
			        item.components.pickable:CanBePicked() and
			        table.contains(PICKABLE_FOODS, item.components.pickable.product)
			        and TargetNotClaimed(inst, item) then
				target = item
				break
			end
		end
	end

	if target then
		return BufferedAction(inst, target, ACTIONS.PICK)
	end
end

local function SummonGuardian(inst)
	local gs = inst.components.herdmember.herd
	if gs and (not gs.components.guardian:HasGuardian() or not gs.components.guardian:SummonsAtMax())
	and inst.components.combat.target ~= nil and not inst.sg:HasStateTag("busy") then
		return BufferedAction(inst, gs, ACTIONS.SUMMONGUARDIAN)
	end
end

local MosslingBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function MosslingBrain:OnStart()

	local eatnode =
	PriorityNode(
	{
		DoAction(self.inst, StealFoodAction),
	}, 2)

	local hasbase = --When the mosslings are wandering the base
	PriorityNode(
	{
		DoAction(self.inst, EatFoodAction),
		MinPeriod(self.inst, math.random(4,6), true, eatnode),
		Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, 15),
	},.25)

	local isthreatened = --When the mosslings have a combat target
	PriorityNode(
	{
		RunAway(self.inst, "scarytoprey", 6, 10, function(target) return true end, false),
		Leash(self.inst,
			function()
				if self.inst:HasGuardian() and self.inst.components.herdmember.herd.components.guardian.guardian:IsValid() then
					return self.inst.components.herdmember.herd.components.guardian.guardian:GetPosition()
				end
			end, 5, 6),
		DoAction(self.inst, SummonGuardian),
		FaceEntity(self.inst, function() return self.inst.components.combat.target end, function() return self.inst:HasGuardian() end),
	}, .25)

	local root =
	PriorityNode(
	{
		WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

		WhileNode(function() return self.inst.shouldGoAway end, "Go Away",
			DoAction(self.inst, GoHome)),

		WhileNode(function() return self.inst.mother_dead end, "Attack!",
			ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),

		WhileNode(function() return self.inst.components.combat.target ~= nil or self.inst:HasGuardian() end, "Is Threatened",
			isthreatened),

		WhileNode(function() return self.inst.components.knownlocations:GetLocation("herd") ~= nil end, "Has Base",
			hasbase),

		--Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("herd") end, 10),

	},.25)

	self.bt = BT(self.inst, root)

end

function MosslingBrain:OnInitializationComplete()
	self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return MosslingBrain
