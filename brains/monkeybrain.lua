require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandattack"
require "behaviours/leash"

local MIN_FOLLOW_DIST = 5
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 10

local RUN_AWAY_DIST = 7
local STOP_RUN_AWAY_DIST = 15

local SEE_FOOD_DIST = 10

local MAX_WANDER_DIST = 20

local MAX_CHASE_TIME = 60
local MAX_CHASE_DIST = 40

local TIME_BETWEEN_EATING = 30

local LEASH_RETURN_DIST = 15
local LEASH_MAX_DIST = 20

local NO_LOOTING_TAGS = { "INLIMBO", "catchable", "fire", "irreplaceable", "heavy", "outofreach", "spider" }
local NO_PICKUP_TAGS = deepcopy(NO_LOOTING_TAGS)
table.insert(NO_PICKUP_TAGS, "_container")

local PICKUP_ONEOF_TAGS = { "_inventoryitem", "pickable", "readyforharvest" }

local MonkeyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function ShouldRunFn(inst, hunter)
    if inst.components.combat.target then
        return hunter:HasTag("player")
    end
end

local function GetPoop(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end

    local target = FindEntity(inst,
        SEE_FOOD_DIST,
        function(item)
            return item.prefab == "poop"
                and not item:IsNear(inst.components.combat.target, RUN_AWAY_DIST)
                and item:IsOnValidGround()
        end,
        nil,
        NO_PICKUP_TAGS
    )

    return target ~= nil and BufferedAction(inst, target, ACTIONS.PICKUP) or nil
end

local ValidFoodsToPick =
{
    "berries",
    "cave_banana",
    "carrot",
    "red_cap",
    "blue_cap",
    "green_cap",
}

local function ItemIsInList(item, list)
    for k, v in pairs(list) do
        if v == item or k == item then
            return true
        end
    end
end

local function SetCurious(inst)
    inst._curioustask = nil
    inst.curious = true
end

local function EatFoodAction(inst)
    if inst.sg:HasStateTag("busy") or
        (inst.components.eater:TimeSinceLastEating() ~= nil and inst.components.eater:TimeSinceLastEating() < TIME_BETWEEN_EATING) or
        (inst.components.inventory ~= nil and inst.components.inventory:IsFull()) or
        math.random() < .75 then
        return
    elseif inst.components.inventory ~= nil and inst.components.eater ~= nil then
        local target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        if target ~= nil then
            return BufferedAction(inst, target, ACTIONS.EAT)
        end
    end

    --Get the stuff around you and store it in ents
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, SEE_FOOD_DIST,
        nil,
        NO_PICKUP_TAGS,
        PICKUP_ONEOF_TAGS)

    --If you're not wearing a hat, look for a hat to wear!
    if inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) == nil then
        for i, item in ipairs(ents) do
            if item.components.equippable ~= nil and
                item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
                item.components.inventoryitem ~= nil and
                item.components.inventoryitem.canbepickedup and
                item:IsOnValidGround() then
                return BufferedAction(inst, item, ACTIONS.PICKUP)
            end
        end
    end

    --Look for food on the ground, pick it up
    for i, item in ipairs(ents) do
        if item:GetTimeAlive() > 8 and
            item.components.inventoryitem ~= nil and
            item.components.inventoryitem.canbepickedup and
            inst.components.eater:CanEat(item) and
            item:IsOnValidGround() then
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end

    --Look for harvestable items, pick them.
    for i, item in ipairs(ents) do
        if item.components.pickable ~= nil and
            item.components.pickable.caninteractwith and
            item.components.pickable:CanBePicked() and
            (item.prefab == "worm" or ItemIsInList(item.components.pickable.product, ValidFoodsToPick)) then
            return BufferedAction(inst, item, ACTIONS.PICK)
        end
    end

    --Look for crops items, harvest them.
    for i, item in ipairs(ents) do
        if item.components.crop ~= nil and
            item.components.crop:IsReadyForHarvest() then
            return BufferedAction(inst, item, ACTIONS.HARVEST)
        end
    end

    if not inst.curious or inst.components.combat:HasTarget() then
        return
    end

    ---At the very end, look for a random item to pick up and do that.
    for i, item in ipairs(ents) do
        if item.components.inventoryitem ~= nil and
            item.components.inventoryitem.canbepickedup and
            item:IsOnValidGround() then
            inst.curious = false
            if inst._curioustask ~= nil then
                inst._curioustask:Cancel()
            end
            inst._curioustask = inst:DoTaskInTime(10, SetCurious)
            return BufferedAction(inst, item, ACTIONS.PICKUP)
        end
    end
end

local function OnLootingCooldown(inst)
    inst._canlootcheststask = nil
    inst.canlootchests = true
end

local ANNOY_ONEOF_TAGS = { "_inventoryitem", "_container" }
local ANNOY_ALT_MUST_TAG = { "_inventoryitem" }
local function AnnoyLeader(inst)
    if inst.sg:HasStateTag("busy") then
        return
    end
    local lootchests = inst.canlootchests ~= false --nil defaults to true
    local px, py, pz = inst.harassplayer.Transform:GetWorldPosition()
    local mx, my, mz = inst.Transform:GetWorldPosition()
    local ents =
        lootchests and
        TheSim:FindEntities(mx, 0, mz, 30, nil, NO_LOOTING_TAGS, ANNOY_ONEOF_TAGS) or
        TheSim:FindEntities(mx, 0, mz, 30, ANNOY_ALT_MUST_TAG, NO_PICKUP_TAGS)

    --Can we hassle the player by taking items from stuff he has killed or worked?
    for i, v in ipairs(ents) do
        if v.components.inventoryitem ~= nil and
            v.components.inventoryitem.canbepickedup and
            v.components.container == nil and
            v:GetTimeAlive() < 5 then
            return BufferedAction(inst, v, ACTIONS.PICKUP)
        end
    end

    --Can we hassle our leader by taking the items he wants?
    local ba = inst.harassplayer:GetBufferedAction()
    if ba ~= nil and ba.action.id == "PICKUP" then
        --The player wants to pick something up. Am I closer than the player?
        local tar = ba.target
        if tar ~= nil and
            tar:IsValid() and
            tar.components.inventoryitem ~= nil and not tar.components.inventoryitem:IsHeld() and
            tar.components.container == nil and
            not (tar:HasTag("irreplaceable") or tar:HasTag("heavy") or tar:HasTag("outofreach")) and
            not (tar.components.burnable ~= nil and tar.components.burnable:IsBurning()) and
            not (tar.components.projectile ~= nil and tar.components.projectile.cancatch and tar.components.projectile.target ~= nil) then
            --I'm closer to the item than the player! Lets go get it!
            local tx, ty, tz = tar.Transform:GetWorldPosition()
            return distsq(px, pz, tx, tz) > distsq(mx, mz, tx, tz)
                and BufferedAction(inst, tar, ACTIONS.PICKUP)
                or nil
        end
    end

    --Can we hassle our leader by toying with his chests? (or bags?)
    --NOTE: stealing throws the item onto the ground, so we do not
    --      need to filter items as strictly as the pickup action.
    if lootchests then
        local items = {}
        for i, v in ipairs(ents) do
            if v.components.container ~= nil and
                v.components.container.canbeopened and
                not v.components.container:IsOpen() and
                v:GetDistanceSqToPoint(px, 0, pz) < 225--[[15 * 15]] then
                for k = 1, v.components.container.numslots do
                    local item = v.components.container.slots[k]
                    if item ~= nil then
                        table.insert(items, item)
                    end
                end
            end
        end

        if #items > 0 then
            inst.canlootchests = false
            if inst._canlootcheststask ~= nil then
                inst._canlootcheststask:Cancel()
            end
            inst._canlootcheststask = inst:DoTaskInTime(math.random(15, 30), OnLootingCooldown)
            local item = items[math.random(#items)]
            local act = BufferedAction(inst, item, ACTIONS.STEAL)
            act.validfn = function()
                local owner = item.components.inventoryitem ~= nil and item.components.inventoryitem.owner or nil
                return owner ~= nil
                    and not (owner.components.inventoryitem ~= nil and owner.components.inventoryitem:IsHeld())
                    and not (owner.components.burnable ~= nil and owner.components.burnable:IsBurning())
                    and owner.components.container ~= nil
                    and owner.components.container.canbeopened
                    and not owner.components.container:IsOpen()
            end
            return act
        end
    end
end

local function GetFaceTargetFn(inst)
    return inst.components.combat.target
end

local function KeepFaceTargetFn(inst, target)
    return target == inst.components.combat.target
end

local function GoHome(inst)
    local homeseeker = inst.components.homeseeker
    if homeseeker and homeseeker.home and homeseeker.home:IsValid()
        and (not homeseeker.home.components.burnable or not homeseeker.home.components.burnable:IsBurning()) then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function EquipWeapon(inst, weapon)
    if not weapon.components.equippable:IsEquipped() then
        inst.components.inventory:Equip(weapon)
    end
end

function MonkeyBrain:OnStart()

    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.hauntable and self.inst.components.hauntable.panic end, "PanicHaunted", Panic(self.inst)),
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        --Monkeys go home when quakes start.
        EventNode(self.inst, "gohome",
            DoAction(self.inst, GoHome)),

        --In combat (with the player)... Should only ever use poop throwing.
        RunAway(self.inst, "character", RUN_AWAY_DIST, STOP_RUN_AWAY_DIST, function(hunter) return ShouldRunFn(self.inst, hunter) end),
        WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat.target:HasTag("player") and self.inst.HasAmmo(self.inst) end, "Attack Player",
            SequenceNode({
                ActionNode(function() EquipWeapon(self.inst, self.inst.weaponitems.thrower) end, "Equip thrower"),
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
            })),
        --Pick up poop to throw
        WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat.target:HasTag("player") and not self.inst.HasAmmo(self.inst) end, "Pick Up Poop",
            DoAction(self.inst, GetPoop)),
        --Eat/ pick/ harvest foods.
        WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat.target:HasTag("player") or self.inst.components.combat.target == nil end, "Should Eat",
            DoAction(self.inst, EatFoodAction)),
        --Priority must be lower than poop pick up or it will never happen.
        WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat.target:HasTag("player") and not self.inst.HasAmmo(self.inst) end, "Leash to Player",
        PriorityNode{
            Leash(self.inst, function() if self.inst.components.combat.target then return self.inst.components.combat.target:GetPosition() end end, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
        }),


        --In combat with everything else
        WhileNode(function() return self.inst.components.combat.target ~= nil and not self.inst.components.combat.target:HasTag("player") end, "Attack NPC", --For everything else
            SequenceNode({
                ActionNode(function() EquipWeapon(self.inst, self.inst.weaponitems.hitter) end, "Equip hitter"),
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST),
            })),


        --Following
        WhileNode(function() return self.inst.harassplayer end, "Annoy Leader",
            DoAction(self.inst, AnnoyLeader)),
        Follow(self.inst, function() return self.inst.harassplayer end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        --Doing nothing
        WhileNode(function() return self.inst.harassplayer  end, "Wander Around Leader",
            Wander(self.inst, function() if self.inst.harassplayer  then return self.inst.harassplayer:GetPosition() end end, MAX_FOLLOW_DIST)),
        WhileNode(function() return not self.inst.harassplayer and not self.inst.components.combat.target end,
        "Wander Around Home", Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST))
    }, .25)
    self.bt = BT(self.inst, root)
end

return MonkeyBrain
