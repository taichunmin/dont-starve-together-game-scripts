require "behaviours/chaseandattack"
require "behaviours/doaction"

require "brains/braincommon"

local OtterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)

    self.max_wander_dist = 30
end)

local function GetHomeLocation(inst)
    local home = (inst.components.homeseeker and inst.components.homeseeker:GetHome()) or nil
    return (home ~= nil and home:GetPosition()) or inst.components.knownlocations:GetLocation("home")
end

-- Food behaviours
local function HasEnoughItems(inst)
    -- We don't want to pick up any items if we no longer have a home to store them in.
    if not inst.components.homeseeker or not inst.components.homeseeker:GetHome() then
        return true
    end

    local items_in_inventory = inst.components.inventory:NumStackedItems()
    return items_in_inventory > TUNING.OTTER_MAX_INVENTORY_ITEMS
end

local INTERACT_COOLDOWN_NAME = "picked_something_up_recently"
local function TryDroppingInventoryFood(inst)
    -- Test for the interact state cooldown so that we don't end up dropping multiple items
    -- before we can eat.
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(INTERACT_COOLDOWN_NAME) then
        return nil
    end

    inst._can_eat_fn = inst._can_eat_fn or function(item)
        return inst.components.eater:CanEat(item)
    end
    local food_in_inventory = inst.components.inventory:FindItem(inst._can_eat_fn)
    if not food_in_inventory then return nil end

    local buffered_action = BufferedAction(inst, nil, ACTIONS.DROP, food_in_inventory, inst:GetPosition())
    inst._start_interact_cooldown_callback = inst._start_interact_cooldown_callback or function()
        inst.components.timer:StartTimer(INTERACT_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
    end
    buffered_action:AddSuccessAction(inst._start_interact_cooldown_callback)
    return buffered_action
end

local FINDITEMS_CANT_TAGS = { "FX", "INLIMBO", "DECOR", "outofreach" }
local SEE_ITEM_DISTANCE = 20
local BOAT_SIZE_SQ = (TUNING.BOAT.GRASS_BOAT.RADIUS * TUNING.BOAT.GRASS_BOAT.RADIUS)
local ISNT_HUNGRY_NAME = "ate_recently"
local function FindGroundItemAction(inst)
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(INTERACT_COOLDOWN_NAME) then
        return nil
    end

    -- Try to avoid picking up things that are on our home boat,
    -- because they'll get dropped there when our den is full.
    local home_position = GetHomeLocation(inst)
    local test_ground_item_for_food = function(item)
        return item:GetTimeAlive() >= 1
            and item.prefab ~= "mandrake"
            and item.components.edible ~= nil
            and item.components.inventoryitem ~= nil
            and (not home_position or item:GetDistanceSqToPoint(home_position) > BOAT_SIZE_SQ)
    end
    local target = FindEntity(inst, SEE_ITEM_DISTANCE, test_ground_item_for_food, nil, FINDITEMS_CANT_TAGS)
    if not target then return nil end

    local buffered_action = BufferedAction(inst, target, ACTIONS.PICKUP)

    inst._start_interact_cooldown_callback = inst._start_interact_cooldown_callback or function()
        inst.components.timer:StartTimer(INTERACT_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
    end
    buffered_action:AddSuccessAction(inst._start_interact_cooldown_callback)
    buffered_action.validfn = function()
        return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld())
    end
    return buffered_action
end

local function FindGroundFoodToEatAction(inst)
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(INTERACT_COOLDOWN_NAME) then
        return nil
    end

    -- Try to avoid picking up things that are on our home boat,
    -- because they'll get dropped there when our den is full.
    local home_position = GetHomeLocation(inst)
    local test_ground_item_for_food = function(item)
        return item:GetTimeAlive() >= 1
            and item.prefab ~= "mandrake"
            and item.components.edible ~= nil
            and item.components.edible.foodtype == FOODTYPE.MEAT
            and inst.components.eater:CanEat(item)
            and item.components.inventoryitem ~= nil
            and (not home_position or item:GetDistanceSqToPoint(home_position) > BOAT_SIZE_SQ)
    end
    local target = FindEntity(inst, SEE_ITEM_DISTANCE, test_ground_item_for_food, nil, FINDITEMS_CANT_TAGS)
    if not target then return nil end

    local buffered_action = BufferedAction(inst, target, ACTIONS.EAT)
    buffered_action:AddSuccessAction(function()
        inst.components.timer:StartTimer(ISNT_HUNGRY_NAME, TUNING.OTTER_EAT_DELAY)
    end)

    inst._start_interact_cooldown_callback = inst._start_interact_cooldown_callback or function()
        inst.components.timer:StartTimer(INTERACT_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
    end
    buffered_action:AddSuccessAction(inst._start_interact_cooldown_callback)
    buffered_action.validfn = function()
        return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld())
    end
    return buffered_action
end

local CONTAINER_MUST_TAGS = {"_container"}
local CONTAINER_CANT_TAGS = { "INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "outofreach", "spider" }
local STEAL_COOLDOWN_NAME = "steallootcooldown"
local function LootContainerFood(inst)
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(STEAL_COOLDOWN_NAME) then
        return
    end

    local ix, iy, iz = inst.Transform:GetWorldPosition()

    local containers = TheSim:FindEntities(
        ix, iy, iz, SEE_ITEM_DISTANCE,
        CONTAINER_MUST_TAGS, CONTAINER_CANT_TAGS
    )

    local items = {}
    local item_found_count, max_item_count = 0, 20
    for _, container in ipairs(containers) do
        if container.components.container.canbeopened and
                not container.components.container:IsOpen() then
            for k = 1, container.components.container.numslots do
                local item = container.components.container.slots[k]
                if item and inst.components.eater:CanEat(item) then
                    table.insert(items, item)
                    item_found_count = item_found_count + 1
                end
            end

            -- We can go over a bit, but we don't want to have to check
            -- every container every time if there's a lot of them around.
            if item_found_count > max_item_count then
                break
            end
        end
    end

    if #items == 0 then return end

    local item = items[math.random(#items)]
    local buffered_action = BufferedAction(inst, item, ACTIONS.STEAL)
    buffered_action.validfn = function()
        local owner = (item.components.inventoryitem ~= nil and item.components.inventoryitem.owner) or nil
        return owner ~= nil
            and not (owner.components.inventoryitem ~= nil and owner.components.inventoryitem:IsHeld())
            and not (owner.components.burnable ~= nil and owner.components.burnable:IsBurning())
            and (owner.components.container ~= nil and owner.components.container.canbeopened)
            and not owner.components.container:IsOpen()
    end
    inst._start_steal_cooldown_callback = inst._start_steal_cooldown_callback or function()
        inst.components.timer:StartTimer(STEAL_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
    end
    buffered_action:AddSuccessAction(inst._start_steal_cooldown_callback)
    return buffered_action
end

local CHARACTER_MUST_TAGS = { "_inventory" }
local CHARACTER_CANT_TAGS = { "playerghost", "fire", "burnt", "INLIMBO", "outofreach", "FX" }
local CHARACTER_ONEOF_TAGS = { "player", "character" }
local function StealCharacterFood(inst)
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(STEAL_COOLDOWN_NAME) then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local characters = TheSim:FindEntities(
        x, y, z, 0.5*SEE_ITEM_DISTANCE,
        CHARACTER_MUST_TAGS, CHARACTER_CANT_TAGS, CHARACTER_ONEOF_TAGS
    )
    for _, character in ipairs(characters) do
        local character_food = nil

        local character_inventory = character.components.inventory
        if character_inventory ~= nil and character:IsOnPassablePoint(true) then
            inst._can_eat_fn = inst._can_eat_fn or function(item)
                return inst.components.eater:CanEat(item)
            end
            character_inventory:ForEachItem(function(item)
                if item and inst._can_eat_fn(item) then
                    character_food = character_food or {}
                    table.insert(character_food, item)
                end
            end)
        end

        if character_food ~= nil and #character_food > 0 then
            local food_to_steal = character_food[math.random(#character_food)]
            local buffered_action = BufferedAction(inst, food_to_steal, ACTIONS.STEAL, nil, nil, nil, TUNING.OTTER_ATTACK_RANGE)
            buffered_action.validfn = function()
                return (food_to_steal.components.inventoryitem ~= nil
                    and food_to_steal.components.inventoryitem:IsHeld())
            end
            inst._start_steal_cooldown_callback = inst._start_steal_cooldown_callback or function()
                inst.components.timer:StartTimer(STEAL_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
            end
            buffered_action:AddSuccessAction(inst._start_steal_cooldown_callback)
            return buffered_action
        end
    end

    return nil
end

local PICKABLE_MUST_TAGS = {"pickable"}
local PICKABLE_CANT_TAGS = {"burnt", "fire", "FX", "INLIMBO", "outofreach"}
local PICKABLE_ONEOF_TAGS = {"kelp"}
local function TryToPickPickables(inst)
    if inst.sg:HasStateTag("busy") or inst.components.timer:TimerExists(INTERACT_COOLDOWN_NAME) then
        return
    end

    local closest_pickable = FindEntity(
        inst, SEE_ITEM_DISTANCE, nil,
        PICKABLE_MUST_TAGS, PICKABLE_CANT_TAGS, PICKABLE_ONEOF_TAGS
    )
    if not closest_pickable then return nil end

    local buffered_action = BufferedAction(inst, closest_pickable, ACTIONS.PICK)
    inst._start_interact_cooldown_callback = inst._start_interact_cooldown_callback or function()
        inst.components.timer:StartTimer(INTERACT_COOLDOWN_NAME, GetRandomWithVariance(5, 2))
    end
    buffered_action:AddSuccessAction(inst._start_interact_cooldown_callback)
    return buffered_action
end

-- Home behaviours
local function GoHomeAction(inst)
    local homeseeker = inst.components.homeseeker
    if homeseeker and homeseeker.home then
        return BufferedAction(inst, homeseeker.home, ACTIONS.GOHOME)
    end
end

local function on_reach_destination(inst, data)
    if data and data.target
            and data.target:IsValid() -- TODO @stevenm check if locomotor GoToEntity covers this test
            and data.target:HasTag("oceanfishable_creature")
            and data.target:IsOnOcean(false) then
        inst.sg:GoToState("toss_fish", data.target)
    end
end

local MUST_TOSSABLE_TAGS = {"oceanfishable_creature"}
local NOT_TOSSABLE_TAGS = {"INLIMBO", "outofreach", "FX", "fishmeat"}
local function GetNearbyFishTarget(inst)
    return (not inst.components.timer:TimerExists("fished_recently") and
            FindEntity(inst, SEE_ITEM_DISTANCE,
                function(item)
                    return item:IsOnOcean(false)
                end,
                MUST_TOSSABLE_TAGS,
                NOT_TOSSABLE_TAGS
            )
        ) or nil
end

local function TryToFish(inst)
    local nearest_fish = GetNearbyFishTarget(inst)
    if nearest_fish then
        inst.components.locomotor:GoToEntity(nearest_fish)
    end
end

local UPDATE_RATE = 0.25
local ACTION_TIMEOUT_TIME = 10
local STEAL_CHASE_TIMEOUT_TIME = 4
function OtterBrain:OnStart()
    local function GetHomeLocation_Redirect() return GetHomeLocation(self.inst) end
    local function DoesntHaveEnoughItems_Redirect() return not HasEnoughItems(self.inst) end
    local function IsHungry_Redirect() return not self.inst.components.timer:TimerExists(ISNT_HUNGRY_NAME) end

    self.inst:ListenForEvent("onreachdestination", on_reach_destination)

    local root = PriorityNode({
        FailIfSuccessDecorator(ConditionWaitNode(function() return not self.inst.sg:HasStateTag("jumping") end, "Block While Jumping")),
        -----------------------------------------------------------------------------------------

        WhileNode( function() return (self.inst.components.health ~= nil and self.inst.components.health.takingfiredamage)
                                or (self.inst.components.burnable ~= nil and self.inst.components.burnable:IsBurning()) end,
                                "OnFire",
            Panic(self.inst)),
        ChaseAndAttack(self.inst, STEAL_CHASE_TIMEOUT_TIME, 1.5 * self.max_wander_dist),
        WhileNode( IsHungry_Redirect, "Is Hungry",
            -- TODO @stevenm do we want to condition any of this behaviour on time-of-year...?
            PriorityNode({
                DoAction(self.inst, FindGroundFoodToEatAction, "Look For Ground Food", nil, ACTION_TIMEOUT_TIME),
                DoAction(self.inst, TryDroppingInventoryFood, "Drop Food From Pockets", nil, ACTION_TIMEOUT_TIME),
                DoAction(self.inst, LootContainerFood, "Look For Container Food", nil, ACTION_TIMEOUT_TIME),
                DoAction(self.inst, StealCharacterFood, "Look For Character Food", nil, STEAL_CHASE_TIMEOUT_TIME),
            }, UPDATE_RATE)
        ),

        WhileNode( function() return TheWorld.state.iswinter
                                or (TheWorld.state.isnight
                                and (TheWorld.state.iscavenight or not self.inst:IsInLight())) end, "It's Night Or Winter",
            DoAction(self.inst, GoHomeAction, "Sleep At Home", true, ACTION_TIMEOUT_TIME)),

        WhileNode(function() return HasEnoughItems(self.inst) and not self.inst.components.timer:TimerExists("dump_loot_at_home") end,
            "Has Enough Items",
            DoAction(self.inst, GoHomeAction, "Stash Items At Home", nil, ACTION_TIMEOUT_TIME)
        ),

        WhileNode(DoesntHaveEnoughItems_Redirect, "Not Enough Items",
            PriorityNode({
                DoAction(self.inst, FindGroundItemAction, "Look For Ground Edibles", nil, ACTION_TIMEOUT_TIME),
                DoAction(self.inst, LootContainerFood, "Look For Container Food", nil, ACTION_TIMEOUT_TIME),
                DoAction(self.inst, StealCharacterFood, "Look For Character Food", nil, STEAL_CHASE_TIMEOUT_TIME),

                -- TODO @stevenm don't want to FindEntity twice w/ 2 GetNearbyFishTarget calls
                WhileNode(function() return GetNearbyFishTarget(self.inst) ~= nil end, "Try Fishing",
                    ActionNode(function() TryToFish(self.inst) end)
                ),

                DoAction(self.inst, TryToPickPickables, "Harvest Kelp", nil, ACTION_TIMEOUT_TIME),

                Wander(self.inst, GetHomeLocation_Redirect, self.max_wander_dist)
            }, UPDATE_RATE)
        ),
        Wander(self.inst, GetHomeLocation_Redirect, self.max_wander_dist)
    }, UPDATE_RATE)

    self.bt = BT(self.inst, root)
end

function OtterBrain:OnStop()
    self.inst:RemoveEventCallback("onreachdestination", on_reach_destination)
end

return OtterBrain