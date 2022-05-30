require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"
require "behaviours/chaseandram"
--require "behaviours/beargeroffscreen"

local MAX_CHASE_TIME = 8
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60
local SEE_FOOD_DIST = 15
local SEE_STRUCTURE_DIST = 30

local BASE_TAGS = { "structure" }
local NO_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt" }

--local OFFSCREEN_RANGE = 64

local PICKABLE_FOODS =
{
    berries = true,
    cave_banana = true,
    carrot = true,
    red_cap = true,
    blue_cap = true,
    green_cap = true,
}

local function EatFoodAction(inst) --Look for food to eat
    -- If we don't check that the target is not a beehive, we will keep doing targeting stuff while there's precious honey on the ground
    if inst.sg:HasStateTag("busy")
            and not inst.sg:HasStateTag("wantstoeat")
            and (inst.components.combat ~= nil and
            inst.components.combat.target ~= nil and
            not inst.components.combat.target:HasTag("beehive")) then
        return
    end

    if inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target ~= nil then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_FOOD_DIST, nil, NO_TAGS, inst.components.eater:GetEdibleTags())
    local target = nil
    for i, v in ipairs(ents) do
        if v:IsValid() and v:IsOnValidGround() and inst.components.eater:CanEat(v) then
            if v:HasTag("honeyed") then
                return BufferedAction(inst, v, ACTIONS.PICKUP)
            elseif target == nil then
                target = v
            end
        end
    end

    --no honey found, but was there something else edible?
    return target ~= nil and BufferedAction(inst, target, ACTIONS.PICKUP) or nil
end

local function StealFoodAction(inst) --Look for things to take food from (EatFoodAction handles picking up/ eating)
    -- Food On Ground > Pots = Farms = Drying Racks > Beebox > Mushroom Farm > Look In Fridge > Chests > Backpacks (on ground) > Plants

    if inst.sg:HasStateTag("busy")
        or (inst.components.inventory ~= nil and
            inst.components.inventory:IsFull()) then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_STRUCTURE_DIST, nil, NO_TAGS)
    local targets = {}

    --Gather all targets in one pass
    for i, item in ipairs(ents) do
        if item:IsValid() and item:IsOnValidGround() then
            if item.components.stewer ~= nil then
                if targets.stewer == nil and item.components.stewer:IsDone() then
                    targets.stewer = item
                end
            elseif item.components.dryer ~= nil then
                if targets.harvestable == nil and item.components.dryer:IsDone() then
                    targets.harvestable = item
                end
            elseif item.components.crop ~= nil then
                if targets.harvestable == nil and item.components.crop:IsReadyForHarvest() then
                    targets.harvestable = item
                end
            elseif item:HasTag("beebox") then
                if targets.beebox == nil and item.components.harvestable ~= nil and item.components.harvestable:CanBeHarvested() then
                    targets.beebox = item
                end
            elseif item:HasTag("mushroom_farm") then
                if targets.mushroom_farm == nil and item.components.harvestable ~= nil and item.components.harvestable:CanBeHarvested() then
                    targets.mushroom_farm = item
                end
            elseif item.components.container ~= nil then
                if not item.components.container:IsEmpty() then
                    if item:HasTag("fridge") and item.components.workable ~= nil then
                        if targets.honeyed_fridge == nil then
                            if item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end) ~= nil then
                                targets.honeyed_fridge = item
                                targets.fridge = nil
                            elseif targets.fridge == nil and item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end) ~= nil then
                                targets.fridge = item
                            end
                        end
                    elseif item:HasTag("chest") and item.components.workable ~= nil then
                        if targets.honeyed_chest == nil then
                            if item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end) ~= nil then
                                targets.honeyed_chest = item
                                targets.chest = nil
                            elseif targets.chest == nil and item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end) ~= nil then
                                targets.chest = item
                            end
                        end
                    elseif item:HasTag("backpack") then
                        if targets.honeyed_backpack == nil then
                            targets.honeyed_backpack = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) and food:HasTag("honeyed") end)
                            if targets.honeyed_backpack ~= nil then
                                targets.backpack = nil
                            elseif targets.backpack == nil then
                                targets.backpack = item.components.container:FindItem(function(food) return inst.components.eater:CanEat(food) end)
                            end
                        end
                    end
                end
            elseif item.components.pickable ~= nil then
                if targets.pickable == nil and
                    item.components.pickable.caninteractwith and
                    item.components.pickable:CanBePicked() and
                    PICKABLE_FOODS[item.components.pickable.product] then
                    targets.pickable = item
                end
            end
        end
    end

    --Pick action by priority on all gathered targets
    if targets.stewer ~= nil then
        return BufferedAction(inst, targets.stewer, ACTIONS.HARVEST)
    elseif targets.beebox ~= nil then
        return BufferedAction(inst, targets.beebox, ACTIONS.HARVEST)
    elseif targets.honeyed_fridge ~= nil then
        return BufferedAction(inst, targets.honeyed_fridge, ACTIONS.HAMMER)
    elseif targets.honeyed_chest ~= nil then
        return BufferedAction(inst, targets.honeyed_chest, ACTIONS.HAMMER)
    elseif targets.honeyed_backpack ~= nil then
        return BufferedAction(inst, targets.honeyed_backpack, ACTIONS.STEAL)
    elseif targets.harvestable ~= nil then
        return BufferedAction(inst, targets.harvestable, ACTIONS.HARVEST)
    elseif targets.mushroom_farm ~= nil then
        return BufferedAction(inst, targets.mushroom_farm, ACTIONS.HARVEST)
    elseif targets.fridge ~= nil then
        return BufferedAction(inst, targets.fridge, ACTIONS.HAMMER)
    elseif targets.chest ~= nil then
        return BufferedAction(inst, targets.chest, ACTIONS.HAMMER)
    elseif targets.backpack ~= nil then
        return BufferedAction(inst, targets.backpack, ACTIONS.STEAL)
    elseif targets.pickable ~= nil then
        return BufferedAction(inst, targets.pickable, ACTIONS.PICK)
    end
end

local BEEHIVE_TAGS = { "beehive" }

local function AttackHiveAction(inst)
    local hive = FindEntity(inst, SEE_STRUCTURE_DIST, function(guy)
            return inst.components.combat:CanTarget(guy) and guy:IsOnValidGround()
        end,
        BEEHIVE_TAGS)
    return hive ~= nil and BufferedAction(inst, hive, ACTIONS.ATTACK) or nil
end

local function ShouldEatFoodFn(inst)
    if not inst.seenbase then
        --check if we're near player base
        local x, y, z = inst.Transform:GetWorldPosition()
        if #TheSim:FindEntities(x, y, z, SEE_STRUCTURE_DIST, BASE_TAGS) >= 2 then
            inst.seenbase = true
        end
    end
    return inst.seenbase
end

local function GetHome(inst)
    return TheWorld.state.season == "summer" and inst.homelocation or nil
end

local function GetTargetDistance(inst)
    local season = TheWorld.state.season
    return (season == "summer" and TUNING.BEARGER_SHORT_TRAVEL)
        or (season == "autumn" and TUNING.BEARGER_LONG_TRAVEL)
        or 0
end

local function GetWanderDirection(inst)
    --print("returning wander direction ", inst.wanderdirection)
    return inst.wanderdirection
end

local function SetWanderDirection(inst, angle)
    --print("Got wander direction", angle)
    inst.wanderdirection = angle
end

local OUTSIDE_CATAPULT_RANGE = TUNING.WINONA_CATAPULT_MAX_RANGE + TUNING.WINONA_CATAPULT_KEEP_TARGET_BUFFER + TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 1
local function OceanDistanceTest(inst, target)
    if inst.cangroundpound and not target:HasTag("beehive") and
            CanProbablyReachTargetFromShore(inst, target, TUNING.BEARGER_ATTACK_RANGE - 0.25) then
        return TUNING.BEARGER_ATTACK_RANGE - 0.25
    else
        return OUTSIDE_CATAPULT_RANGE
    end
end

local function InRamDistance(inst, target)
    local target_is_close = inst:IsNear(target, 10)
    if target_is_close then
        return false
    elseif target:IsOnValidGround() then
        -- Our target is on land, and we already know we're far enough away because the above test failed!
        return true
    else
        -- If our target is not on land, they are on a boat or in the water.
        -- In that case, check whether we can stand close enough for them to be within our attack range.
        return CanProbablyReachTargetFromShore(inst, target, TUNING.BEARGER_ATTACK_RANGE - 0.25)
    end
end

--[[local function OutsidePlayerRange(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    return TheWorld.state.isautumn and (not IsAnyPlayerInRange(x, y, z, OFFSCREEN_RANGE)) -- only run offscreen behaviour in autumn
end]]

local BeargerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function BeargerBrain:OnStart()

    local root =
        PriorityNode(
        {
            -- Liz: Removed offscreen behaviour at Jamie's request, pending a solution to repopulate trees & stuff over time.
            -- Also, this will need to be done by a periodic task instead since brain updates don't run when the entity is asleep.
            -- (It does trigger before the entity goes to sleep, so we can probably just have BeargerOffScreen set up its own periodic task)
            --WhileNode(function() return OutsidePlayerRange(self.inst) end, "OffScreen", BeargerOffScreen(self.inst)),

            WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

            WhileNode(function()
                    return self.inst.cangroundpound
                        and self.inst.components.combat.target ~= nil
                        and not self.inst.components.combat.target:HasTag("beehive")
                        and (self.inst.sg:HasStateTag("running") or InRamDistance(self.inst, self.inst.components.combat.target))
                end,
                "Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),

            ChaseAndAttack(self.inst, TUNING.BEARGER_MAX_CHASE_TIME, 60, nil, nil, true, OceanDistanceTest),

            WhileNode(function() return ShouldEatFoodFn(self.inst) end, "At Base",
                PriorityNode(
                {
                    DoAction(self.inst, EatFoodAction),
                    DoAction(self.inst, StealFoodAction),
                })),

            DoAction(self.inst, EatFoodAction),
            DoAction(self.inst, StealFoodAction),
            DoAction(self.inst, AttackHiveAction, "AttackHive", nil, 7),

            Wander(self.inst,
                    GetHome,
                    GetTargetDistance,
                    {
                        minwalktime = 2,
                        randwalktime = 3,
                        minwaittime = .1,
                        randwaittime = .6,
                    },
                    GetWanderDirection,
                    SetWanderDirection
                ),

            StandStill(self.inst),

        }, .25)

    self.bt = BT(self.inst, root)
end

function BeargerBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("spawnpoint", Point(self.inst.Transform:GetWorldPosition()))
end

return BeargerBrain
