require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/useshield"
require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/runaway"
local BrainCommon = require("brains/braincommon")

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8
local GO_HOME_DIST = 1
local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40
local RUN_AWAY_DIST = 12
local STOP_RUN_AWAY_DIST = 14
local DAMAGE_UNTIL_SHIELD = TUNING.SNURTLE_DAMAGE_UNTIL_SHIELD
local AVOID_PROJECTILE_ATTACKS = true
local HIDE_WHEN_SCARED = true
local SHIELD_TIME = 2
local SEE_FOOD_DIST = 13
local HUNGER_TOLERANCE = 70


local SlurtleSnailBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    local homeseeker = inst.components.homeseeker
    if homeseeker
        and homeseeker.home
        and homeseeker.home:IsValid()
        and (not homeseeker.home.components.burnable or not homeseeker.home.components.burnable:IsBurning()) then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function ShouldGoHome(inst)
    return GetTime() - inst.lastmeal > HUNGER_TOLERANCE
end

local function ShouldRunAway(guy)
    return guy:HasTag("character") and not guy:HasTag("notarget") and not guy:HasDebuff("healingsalve_acidbuff")
end

local EATFOOD_CANT_TAGS = { "outofreach" }

local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    elseif inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target ~= nil then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

    local target = FindEntity(inst,
        30,
        function(item)
            return item:GetTimeAlive() >= 8
                and item:IsOnValidGround()
                and inst.components.eater:CanEat(item)
        end,
        nil,
        EATFOOD_CANT_TAGS
    )
    if target ~= nil then
        return BufferedAction(inst, target, ACTIONS.PICKUP)
    end
end

local STEALFOOD_CANT_TAGS = { "playerghost", "fire", "burnt", "INLIMBO", "outofreach" }
local STEALFOOD_ONEOF_TAGS = { "player", "_container" }
local function StealFoodAction(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_FOOD_DIST, nil, STEALFOOD_CANT_TAGS, STEALFOOD_ONEOF_TAGS)

    for i, v in ipairs(ents) do
        if not v:HasDebuff("healingsalve_acidbuff") then
            --go through player inv and find valid food
            local inv = v.components.inventory
            if inv and v:IsOnValidGround() then
                local pack = inv:GetEquippedItem(EQUIPSLOTS.BODY)
                local validfood = {}
                if pack and pack.components.container then
                    for k = 1, pack.components.container.numslots do
                        local item = pack.components.container.slots[k]
                        if item and item.components.edible and inst.components.eater:CanEat(item) then
                            table.insert(validfood, item)
                        end
                    end
                end

                for k = 1, inv.maxslots do
                    local item = inv.itemslots[k]
                    if item and item.components.edible and inst.components.eater:CanEat(item) then
                        table.insert(validfood, item)
                    end
                end

                if #validfood > 0 then
                    local itemtosteal = validfood[math.random(1, #validfood)]
                    local act = BufferedAction(inst, itemtosteal, ACTIONS.STEAL)
                    act.validfn = function() return (itemtosteal.components.inventoryitem and itemtosteal.components.inventoryitem:IsHeld()) end
                    act.attack = true
                    return act
                end
            end

            local container = v.components.container
            if container then
                local validfood = {}
                for k = 1, container.numslots do
                    local item = container.slots[k]
                    if item and item.components.edible and inst.components.eater:CanEat(item) then
                        table.insert(validfood, item)
                    end
                end

                if #validfood > 0 then
                    local itemtosteal = validfood[math.random(1, #validfood)]
                    local act = BufferedAction(inst, itemtosteal, ACTIONS.STEAL)
                    act.validfn = function() return (itemtosteal.components.inventoryitem and itemtosteal.components.inventoryitem:IsHeld()) end
                    act.attack = true
                    return act
                end
            end
        end
    end
end

function SlurtleSnailBrain:OnStart()
    local root = PriorityNode(
    {
        UseShield(self.inst, DAMAGE_UNTIL_SHIELD, SHIELD_TIME, AVOID_PROJECTILE_ATTACKS, HIDE_WHEN_SCARED),
		BrainCommon.PanicTrigger(self.inst),
        RunAway(self.inst, ShouldRunAway, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST),
        DoAction(self.inst, EatFoodAction),
        DoAction(self.inst, StealFoodAction),
        WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome",
            DoAction(self.inst, GoHomeAction, "Go Home", true )),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, 40),
    }, .25)

    self.bt = BT(self.inst, root)
end

return SlurtleSnailBrain
