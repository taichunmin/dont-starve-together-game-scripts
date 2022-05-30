require "behaviours/chaseandattack"
require "behaviours/wander"
require "behaviours/panic"
require "behaviours/faceentity"
require "behaviours/follow"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 8
local TARGET_FOLLOW_DIST = 5

local MAX_WANDER_DIST = 3

local FIND_FOOD_ACTION_DIST = 12

local function GetOwner(inst)
    local leader = inst.components.follower.leader
    return leader ~= nil and leader.components.inventoryitem ~= nil and leader.components.inventoryitem:GetGrandOwner() or nil
end

local GetFaceTargetFn = GetOwner

local function KeepFaceTargetFn(inst, target)
    return target == GetOwner(inst)
end

local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        return target ~= nil
            and BufferedAction(inst, target, ACTIONS.EAT)
            or nil
    end
end

local MAKE_FOOD_TAGS = { "canlight", "fire", "smolder" }
local NO_MAKE_FOOD_TAGS = { "INLIMBO", "_equippable", "outofreach" }
for k, v in pairs(FUELTYPE) do
    if v ~= FUELTYPE.USAGE then --Not a real fuel
        table.insert(NO_MAKE_FOOD_TAGS, v.."_fueled")
    end
end

local function MakeFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local target = FindEntity(inst, FIND_FOOD_ACTION_DIST, nil, nil, NO_MAKE_FOOD_TAGS, MAKE_FOOD_TAGS)
    return target ~= nil and BufferedAction(inst, target, ACTIONS.NUZZLE) or nil
end

local function CanPickup(item)
    return item.components.inventoryitem.canbepickedup and item:IsOnValidGround()
end

local FINDFOOD_MUST_TAGS = { "edible_BURNT", "_inventoryitem" }
local FINDFOOD_CANT_TAGS = { "INLIMBO", "fire", "catchable", "outofreach" }
local function FindFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local target = FindEntity(inst, FIND_FOOD_ACTION_DIST, CanPickup, FINDFOOD_MUST_TAGS, FINDFOOD_CANT_TAGS)
    return target ~= nil and BufferedAction(inst, target, ACTIONS.PICKUP) or nil
end

local function OwnerIsClose(inst)
    local owner = GetOwner(inst)
    return owner ~= nil and owner:IsNear(inst, 2.5)
end

local function LoveOwner(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local owner = GetOwner(inst)
    return owner ~= nil
        and owner:HasTag("player")
        and inst.components.hunger:GetPercent() > 0.5
        and math.random() < 0.5
        and BufferedAction(inst, owner, ACTIONS.NUZZLE)
        or nil
end

local LavaePetBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function LavaePetBrain:OnStart()
    local root =
    PriorityNode({

        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),

        WhileNode(function() return self.inst.components.hunger:GetPercent() < 0.05 end, "STARVING BABY ALERT!",
            PriorityNode{
                --Eat the foods
                DoAction(self.inst, EatFoodAction),
                --Find the foods
                DoAction(self.inst, FindFoodAction),
                --Make the foods!
                SequenceNode{
                    DoAction(self.inst, MakeFoodAction),
                    WaitNode(10),
                },
            }),

        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        DoAction(self.inst, EatFoodAction),

        FailIfRunningDecorator(FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),

        WhileNode(function() return OwnerIsClose(self.inst) end, "Owner Is Close",
            SequenceNode{
                WaitNode(4),
                DoAction(self.inst, LoveOwner),
            }),

    }, 1)
    self.bt = BT(self.inst, root)
end

return LavaePetBrain
