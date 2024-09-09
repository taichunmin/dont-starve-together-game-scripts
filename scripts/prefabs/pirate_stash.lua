local assets =
{
    Asset("ANIM", "anim/x_marks_spot.zip"),
    Asset("MINIMAP_IMAGE", "pirate_stash"),
}

----------------------------------------------------------------------------------------------------------------------------

local MAX_LOOTFLING_DELAY = 0.8

local BLUEPRINT_PREFAB = "blueprint"

local IMPORTANT_BLUEPRINTS =
{
    pirate_flag_pole = true,
    polly_rogershat  = true,
}

----------------------------------------------------------------------------------------------------------------------------

local function FlingLootInSlot(inst, slot)
    local loot = inst.components.inventory:GetItemInSlot(slot)

    if loot ~= nil then
        loot = inst.components.inventory:DropItem(loot, true)

        if loot ~= nil and loot:IsValid() then
            Launch(loot, loot, 2)
        end
    end

    -- This way, if saved while we're flinging will just resume as a diggable.
    -- Stash again, with the remaining loot.

    if inst.queued > 1 then
        inst.queued = inst.queued - 1
    else
        inst.components.inventory:DropEverything() -- Just in case.
        inst:Remove()
    end
end

local function QueueFlingInSlot(inst, slot)
    inst.queued = (inst.queued or 0) + 1
    inst:DoTaskInTime(MAX_LOOTFLING_DELAY * math.random(), inst.FlingLootInSlot, slot)
end

----------------------------------------------------------------------------------------------------------------------------

local function OnDigged(inst)
    if inst.flinging then
        return
    end

    inst.flinging = true
    inst:Hide()

    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    for slot in pairs(inst.components.inventory.itemslots) do
        inst:QueueFlingInSlot(slot)
    end
end

----------------------------------------------------------------------------------------------------------------------------

local function HasCopyOf(inst, item)
    for _, other in pairs(inst.components.inventory.itemslots) do
        if other ~= item and other.prefab == BLUEPRINT_PREFAB and other.recipetouse == item.recipetouse then
            return true
        end
    end

    return false
end

local function IsItemTreasure(inst, item)
    return item.prefab == BLUEPRINT_PREFAB and IMPORTANT_BLUEPRINTS[item.recipetouse] and not inst:HasCopyOf(item)
end

local function StashLoot(inst, item)
    if item == nil or not item:IsValid() then
        return
    end

    inst.components.inventory:GiveItem(item)

    local activeitem = inst.components.inventory:GetActiveItem()

    -- Theat activeitem as leftover.
    if activeitem ~= nil then
        inst.components.inventory.HandleLeftoversFn(inst, activeitem)
        inst.components.inventory:SetActiveItem(nil)
    end
end

local function OnInventoryFull(inst, leftovers)
    if leftovers == nil then
        return
    end

    local first = inst.nextslot

    repeat
        local olditem = inst.components.inventory:GetItemInSlot(inst.nextslot)

        if olditem ~= nil and not (olditem:HasTag("irreplaceable") or inst:IsItemTreasure(olditem)) then
            olditem:Remove()
            olditem = nil
        end

        if olditem == nil then
            inst.components.inventory:GiveItem(leftovers, inst.nextslot)

            return
        else
            inst.nextslot = inst.nextslot < inst.components.inventory.maxslots and inst.nextslot + 1 or 1
        end

    until inst.nextslot == first

    -- No open slot.
    if not leftovers:HasTag("irreplaceable") then
        leftovers:Remove()

    elseif leftovers.components.inventoryitem ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        leftovers.components.inventoryitem:DoDropPhysics(x, 0, z, true)

    elseif leftovers.Physics ~= nil then
        Launch(item, item, 1)

    else
        local x, y, z = inst.Transform:GetWorldPosition()

        leftovers.Transform:SetPosition(x, 0, z)
    end
end

----------------------------------------------------------------------------------------------------------------------------

local function OnGotItem(inst, data)
    if inst.flinging and data.slot ~= nil then
        inst:QueueFlingInSlot(data.slot)
    end

    inst.nextslot = inst.nextslot < inst.components.inventory.maxslots and inst.nextslot + 1 or 1
end

local function OnRemoved(inst)
    if TheWorld.components.piratespawner ~= nil then
        TheWorld.components.piratespawner:ClearCurrentStash()
    end
end

----------------------------------------------------------------------------------------------------------------------------

local function OnSave(inst, data)
    data.nextslot = inst.nextslot > 1 and inst.nextslot or nil
end

local function OnLoad(inst, data)
    if data ~= nil and data.nextslot ~= nil then
        inst.nextslot = math.min(data.nextslot, TUNING.PIRATE_STASH_INV_SIZE)
    end
end

----------------------------------------------------------------------------------------------------------------------------

local scrapbook_adddeps = {
    "palmcone_scale",
    "cave_banana",
    "treegrowthsolution",
    "goldnugget",
    "meat_dried",
    "bananajuice",
    "goldenshovel",
    "shovel",
    "bananajuice",
    "blueprint",
}

----------------------------------------------------------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("pirate_stash.png")

    inst.AnimState:SetBank("x_marks_spot")
    inst.AnimState:SetBuild("x_marks_spot")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")
    inst:AddTag("buried")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_adddeps = scrapbook_adddeps

    inst.nextslot = 1

    inst.StashLoot = StashLoot
    inst.HasCopyOf = HasCopyOf
    inst.IsItemTreasure = IsItemTreasure
    inst.QueueFlingInSlot = QueueFlingInSlot
    inst.FlingLootInSlot = FlingLootInSlot
    inst.OnGotItem = OnGotItem

    inst:AddComponent("inspectable")

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = TUNING.PIRATE_STASH_INV_SIZE
    inst.components.inventory.HandleLeftoversFn = OnInventoryFull

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(OnDigged)

    inst:ListenForEvent("itemget", inst.OnGotItem)

    inst.OnRemoveEntity = OnRemoved

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("pirate_stash", fn, assets)
