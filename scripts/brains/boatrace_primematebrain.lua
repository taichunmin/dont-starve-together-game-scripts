require "behaviours/doaction"
require "behaviours/follow"
require "behaviours/wander"
local BrainCommon = require("brains/braincommon")

local BoatRace_PrimemateBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- Buoy Return Fire Behaviour
local function is_buoy(item)
    return item.prefab == "boatrace_seastack_throwable_deploykit"
        or item.prefab == "boatrace_seastack_monkey_throwable_deploykit"
end
local function TryBuoyToss(inst)
    local inventory = inst.components.inventory
    local buoy_in_inventory = inventory:FindItem(is_buoy)
    if buoy_in_inventory then
        if inst.components.timer:TimerExists("try_throw_buoy") then
            return nil
        end

        local ix, iy, iz = inst.Transform:GetWorldPosition()
        local buoy_toss_dist = TUNING.BOATRACE_THROWABLE_MAX_DISTANCE + 3 * (TUNING.DRAGON_BOAT_RADIUS)
        local nearest_player = FindClosestPlayerInRange(ix, iy, iz, buoy_toss_dist, true)
        if nearest_player then
            local my_position = inst:GetPosition()
            local me_to_player = (nearest_player:GetPosition() - my_position):GetNormalized()
            local toss_position = my_position + (me_to_player * TUNING.BOATRACE_THROWABLE_MAX_DISTANCE * 0.95)
            inst._last_row_position = nil
            inst.components.timer:StartTimer("try_throw_buoy", 5)
            return BufferedAction(inst, nil, ACTIONS.TOSS, buoy_in_inventory, toss_position)
        end
    else
        local boat = (inst.components.crewmember and inst.components.crewmember.boat)
            or inst:GetCurrentPlatform()
        if not boat then return nil end

        local entities_on_boat = (boat.components.walkableplatform
            and boat.components.walkableplatform:GetEntitiesOnPlatform())
            or nil
        if not entities_on_boat then return nil end

        for entity_on_boat in pairs(entities_on_boat) do
            -- persists == false is a cheeky test to filter out kits that have been thrown,
            -- just in case.
            if is_buoy(entity_on_boat) and entity_on_boat.persists then
                inst._last_row_position = nil
                return BufferedAction(inst, entity_on_boat, ACTIONS.PICKUP)
            end
        end
    end

    return nil
end


-- Leak Patching
local function is_boatpatch(item)
    return (item.components.boatpatch ~= nil)
end

local function FixBoat(inst)
    if inst.components.timer:TimerExists("patch_boat_cooldown") then
        return nil
    end

    local inventory = inst.components.inventory
    local boatpatch = inventory:FindItem(is_boatpatch)
    if not boatpatch then
        for _ = 1, 3 do
            boatpatch = SpawnPrefab("treegrowthsolution")
            inventory:GiveItem(boatpatch)
        end
    end

    local leak = nil
    local crewmember_boat = (inst.components.crewmember ~= nil and inst.components.crewmember.boat) or nil
    if crewmember_boat then
        local entities_on_boat = (crewmember_boat.components.walkableplatform
            and crewmember_boat.components.walkableplatform:GetEntitiesOnPlatform())
            or nil

        if entities_on_boat then
            local potential_leaks = {}
            for entity_on_boat in pairs(entities_on_boat) do
                if entity_on_boat.components.boatleak then
                    potential_leaks[entity_on_boat] = entity_on_boat.components.boatleak
                end
            end

            for potential_leak, boatleak in pairs(potential_leaks) do
                if boatleak.has_leaks and boatleak:IsFinishedSpawning() then
                    leak = potential_leak
                    break
                end
            end
        end
    end

    if leak then
        inst._last_row_position = nil
        return BufferedAction(inst, leak, ACTIONS.REPAIR_LEAK, boatpatch)
    end
end

-- Fire Prevention
local function is_waterballoon(item)
    return (item.components.wateryprotection ~= nil)
        and (item.components.complexprojectile ~= nil)
end

local BOATFIRE_ONEOF_TAGS = {"fire", "smolder"}
local function PutOutBoatFire(inst)
    if inst.components.timer:TimerExists("waterballoon_throw_cooldown") then
        return nil
    end

    local inventory = inst.components.inventory
    local waterballoon = inventory:FindItem(is_waterballoon)
    if not waterballoon then
        for _ = 1, 3 do
            waterballoon = SpawnPrefab("waterballoon")
            inventory:GiveItem(waterballoon)
        end
    end

    local fire = nil
    local crewmember_boat = (inst.components.crewmember ~= nil and inst.components.crewmember.boat) or nil
    if crewmember_boat then
        local bx, by, bz = crewmember_boat.Transform:GetWorldPosition()
        local radius = (crewmember_boat.components.walkableplatform and crewmember_boat.components.walkableplatform.platform_radius)
            or TUNING.DRAGON_BOAT_RADIUS
        local entities_on_boat = TheSim:FindEntities(bx, by, bz, radius, nil, nil, BOATFIRE_ONEOF_TAGS)

        if entities_on_boat then
            local fire_fxlevel = -1
            local burnable
            for _, entity_on_boat in pairs(entities_on_boat) do
                burnable = entity_on_boat.components.burnable
                if burnable and (burnable:IsBurning() or burnable:IsSmoldering())
                        and burnable.fxlevel > fire_fxlevel then
                    fire_fxlevel = burnable.fxlevel
                    fire = entity_on_boat
                end
            end
        end
    end

    if fire then
        inst._last_row_position = nil
        inst.components.timer:StartTimer("waterballoon_throw_cooldown", 5)
        return BufferedAction(inst, fire, ACTIONS.TOSS, waterballoon)
    end
end

-- Boat Rowing
local function RowBoat(inst)
    if inst.components.timer:TimerExists("rowcooldown") then
        return nil
    end

    local crewmember = inst.components.crewmember
    if not crewmember or not crewmember:Shouldrow() then
        return nil
    end

    local row_position = inst._last_row_position
    local boat = inst:GetCurrentPlatform()
    if boat and boat ~= crewmember.boat then boat = nil end

    if boat then
        if not row_position then
            local radius = boat.components.walkableplatform.platform_radius - 0.35
            row_position = boat:GetPosition()

            local offset = FindWalkableOffset(
                row_position,
                TWOPI*math.random(),
                radius,
                nil, false, false, nil, false, true
            )
            if offset then row_position = row_position + offset end
        end

        if row_position then
            inst._last_row_position = row_position

            -- If our row position is too close to our current position, don't try to move there
            -- through the buffered action.
            -- NOTE: ACTIONS.ROW.fn will crash if NOT using a crewmember component to row with
            -- (regular rowing needs a position to calculate a row force vector with)
            if distsq(row_position, inst:GetPosition()) < 1 then
                row_position = nil
            end
            local bufferedaction = BufferedAction(inst, nil, ACTIONS.ROW, nil, row_position)
            if bufferedaction then
                inst._on_row_success = inst._on_row_success or function()
                    local cooldown_with_extra_variance = GetRandomWithVariance(inst._row_cooldown, 3 * FRAMES)
                    inst.components.timer:StartTimer("rowcooldown", cooldown_with_extra_variance)
                end
                bufferedaction:AddSuccessAction(inst._on_row_success)
                return bufferedaction
            end
        end
    end

    return nil
end

local function GetBoat(inst)
    return inst:GetCurrentPlatform()
end

local function FindWanderPoint(inst)
    local boat = inst:GetCurrentPlatform()
    return (boat ~= nil and boat:GetPosition()) or inst.components.knownlocations:GetLocation("home")
end

local MAX_WANDER_DISTANCE = 20
local function FindMaximumWanderDistance(inst)
    local boat = inst:GetCurrentPlatform()
    return (boat and boat.components.walkableplatform and boat.components.walkableplatform.platform_radius - 1)
        or MAX_WANDER_DISTANCE
end

local PRIORITY_UPDATE_RATE = 0.25
local WANDER_DATA = {
    minwalktime     = 0.2,
    randwalktime    = 0.2,
    minwaittime     = 1,
    randwaittime    = 5,
}
function BoatRace_PrimemateBrain:OnStart()
    self.inst._row_cooldown = math.random() * 12 * FRAMES
    local root = PriorityNode(
    {
        FailIfSuccessDecorator(
            ConditionWaitNode(function() return not self.inst.sg:HasStateTag("cheering") end,
                "Block While Cheering")
        ),
        -----------------------------------------------------------------------------------------

        DoAction(self.inst, TryBuoyToss, "toss buoy"),
        DoAction(self.inst, FixBoat, "patch boat"),
        DoAction(self.inst, PutOutBoatFire, "put out fire"),
        DoAction(self.inst, RowBoat, "rowing", nil, 1.0),
        Follow(self.inst, GetBoat, 0, 1, 1.75),
        Wander(self.inst, FindWanderPoint, FindMaximumWanderDistance, WANDER_DATA),
    }, PRIORITY_UPDATE_RATE)

    self.bt = BT(self.inst, root)
end

return BoatRace_PrimemateBrain