require "behaviours/wander"
require "behaviours/leash"
require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
local BrainCommon = require("brains/braincommon")

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 20
local SEE_BUSH_DIST = 40
local SEE_SHRINE_DIST = 30
local MIN_SHRINE_WANDER_DIST = 4
local MAX_SHRINE_WANDER_DIST = 6
local MAX_WANDER_DIST = 80
local SHRINE_LOITER_TIME = 4
local SHRINE_LOITER_TIME_VAR = 3

local PerdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local BUSH_TAGS = { "bush" }
local function FindNearestBush(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_BUSH_DIST, BUSH_TAGS)
    local emptybush = nil
    for i, v in ipairs(ents) do
        if v ~= inst and v.entity:IsVisible() and v.components.pickable ~= nil then
            -- NOTE: if a bush that can be in the ocean gets made, we should test for that here (unless perds learn to swim!)
            if v.components.pickable:CanBePicked() then
                return v
            elseif emptybush == nil then
                emptybush = v
            end
        end
    end
    return emptybush
        or (inst.components.homeseeker ~= nil and inst.components.homeseeker.home)
        or nil
end

local function HomePos(inst)
    local bush = FindNearestBush(inst)
    return bush ~= nil and bush:GetPosition() or nil
end

local function GoHomeAction(inst)
    local bush = FindNearestBush(inst)
    return bush ~= nil and BufferedAction(inst, bush, ACTIONS.GOHOME, nil, bush:GetPosition()) or nil
end

local EATFOOD_MUST_TAGS = { "edible_"..FOODTYPE.VEGGIE }
local EATFOOD_CANT_TAGS = { "INLIMBO" }
local SCARY_TAGS = { "scarytoprey" }
local function EatFoodAction(inst, checksafety)
    local target =
        inst.components.inventory ~= nil and
        inst.components.eater ~= nil and
        inst.components.inventory:FindItem(
            function(item)
                return inst.components.eater:CanEat(item)
            end)
        or nil

    if target == nil then
        target = FindEntity(inst, SEE_FOOD_DIST, nil, EATFOOD_MUST_TAGS, EATFOOD_CANT_TAGS)
        --check for scary things near the food, or if it's in the water
        if target == nil or not target:IsOnValidGround() or
                ( checksafety and GetClosestInstWithTag(SCARY_TAGS, target, SEE_PLAYER_DIST) ~= nil ) then
            return nil
        end
    end

    local act = BufferedAction(inst, target, ACTIONS.EAT)
    act.validfn = function()
        return target.components.inventoryitem == nil
            or target.components.inventoryitem.owner == nil
            or target.components.inventoryitem.owner == inst
    end
    return act
end

local function EatFoodWhenSafe(inst)
    return EatFoodAction(inst, true)
end

local function EatFoodAnytime(inst)
    return EatFoodAction(inst, false)
end

local function HasBerry(item)
    return item.components.pickable ~= nil and (item.components.pickable.product == "berries" or item.components.pickable.product == "berries_juicy")
end

local PICKBERRIES_MUST_TAGS = { "pickable" }
local function PickBerriesAction(inst)
    local target = FindEntity(inst, SEE_FOOD_DIST, HasBerry, PICKBERRIES_MUST_TAGS)
    --check for scary things near the bush
    return target ~= nil
        and GetClosestInstWithTag(SCARY_TAGS, target, SEE_PLAYER_DIST) == nil
        and BufferedAction(inst, target, ACTIONS.PICK)
        or nil
end

--------------------------------------------------------------------------
--[[ For special event ]]
--------------------------------------------------------------------------
local FINDSHRING_MUST_TAGS = { "perdshrine" }
local FINDSHRING_CANT_TAGS = { "burnt", "fire" }

local function FindShrine(inst)
    if not inst.seekshrine then
        inst._shrine = nil
    elseif inst._shrine == nil
        or not inst._shrine:IsValid()
        or not inst._shrine:IsNear(inst, SEE_SHRINE_DIST)
        or (inst._shrine.components.burnable ~= nil and
            inst._shrine.components.burnable:IsBurning() or
            inst._shrine:HasTag("burnt")) then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst._shrine = TheSim:FindEntities(x, y, z, SEE_SHRINE_DIST, FINDSHRING_MUST_TAGS, FINDSHRING_CANT_TAGS)[1]
    end
    return inst._shrine
end

local function ShrinePos(inst)
    return inst._shrine:GetPosition()
end

local function ShrineWanderPos(inst)
    inst._lastshrinewandertime = GetTime()
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = inst._shrine.Transform:GetWorldPosition()
    local dx, dz = x - x1, z - z1
    local nlen = MIN_SHRINE_WANDER_DIST / math.sqrt(dx * dx + dz * dz)
    return Vector3(x1 + dx * nlen, 0, z1 + dz * nlen)
end

local function ShouldLoiter(inst)
    if inst._lastshrinewandertime == nil or inst:IsNear(inst._shrine, MAX_SHRINE_WANDER_DIST) then
        return false
    end
    local t = GetTime() - inst._lastshrinewandertime - SHRINE_LOITER_TIME
    if t <= 0 or math.random() * SHRINE_LOITER_TIME_VAR >= t then
        return true
    end
    inst._lastshrinewandertime = nil
    return false
end

--------------------------------------------------------------------------

function PerdBrain:OnStart()
    local root = PriorityNode(
    {
		BrainCommon.PanicTrigger(self.inst),
        WhileNode(function() return not TheWorld.state.isday end, "IsNight",
            DoAction(self.inst, GoHomeAction, "Go Home", true)),
        IfNode(function() return self.inst.seekshrine end, "Seek Shrine",
            WhileNode(function() return FindShrine(self.inst) ~= nil end, "Approach Shrine",
                PriorityNode({
                    DoAction(self.inst, EatFoodAnytime, "Eat Food"),
                    WhileNode(function() return ShouldLoiter(self.inst) end, "Loiter",
                        StandStill(self.inst)),
                    Leash(self.inst, ShrinePos, MAX_SHRINE_WANDER_DIST, MIN_SHRINE_WANDER_DIST),
                    Wander(self.inst, ShrineWanderPos, MAX_SHRINE_WANDER_DIST - MIN_SHRINE_WANDER_DIST, { minwaittime = SHRINE_LOITER_TIME * .5, randwaittime = SHRINE_LOITER_TIME_VAR }),
                }, .25))),
        DoAction(self.inst, EatFoodWhenSafe, "Eat Food"),
        RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST),
        DoAction(self.inst, PickBerriesAction, "Pick Berries", true),
        Wander(self.inst, HomePos, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return PerdBrain
