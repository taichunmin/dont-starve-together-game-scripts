local EquipSlot = require("equipslotutil")

local function OnDeath(inst)
    if inst.components.inventory ~= nil then
        inst.components.inventory:DropEverything(true)
    end
end

local function OnOwnerDespawned(inst)
    if inst.components.inventory ~= nil then
        for slot, item in pairs(inst.components.inventory.itemslots) do
            item:PushEvent("player_despawn")
        end
        for slot, equip in pairs(inst.components.inventory.equipslots) do
            equip:PushEvent("player_despawn")
        end
        if inst.components.inventory.activeitem ~= nil then
            inst.components.inventory.activeitem:PushEvent("player_despawn")
        end
    end
end

local function onheavylifting(self, heavylifting)
    self.inst.replica.inventory:SetHeavyLifting(heavylifting)
end

local Inventory = Class(function(self, inst)
    self.inst = inst

    self.isopen = false
    self.isvisible = false

    --Hacky flags for altering behaviour when moving items between containers
    self.ignoreoverflow = false
    self.ignorefull = false
    self.silentfull = false
    self.ignoresound = false

    self.itemslots = {}
    self.maxslots = GetMaxItemSlots(TheNet:GetServerGameMode())

    self.equipslots = {}
    self.heavylifting = false

    self.activeitem = nil
    self.acceptsstacks = true
    self.ignorescangoincontainer = false
    self.opencontainers = {}

    self.dropondeath = true
    inst:ListenForEvent("death", OnDeath)

    self.isexternallyinsulated = SourceModifierList(inst, false, SourceModifierList.boolean)

	-- self.noheavylifting = false

    inst:ListenForEvent("player_despawn", OnOwnerDespawned)

    if inst.replica.inventory.classified ~= nil then
        makereadonly(self, "maxslots")
        makereadonly(self, "acceptsstacks")
        makereadonly(self, "ignorescangoincontainer")
    end
end,
nil,
{
    heavylifting = onheavylifting,
})

function Inventory:EnableDropOnDeath()
    if not self.dropondeath then
        self.dropondeath = true
        self.inst:ListenForEvent("death", OnDeath)
    end
end

function Inventory:DisableDropOnDeath()
    if self.dropondeath then
        self.dropondeath = false
        self.inst:RemoveEventCallback("death", OnDeath)
    end
end

Inventory.OnRemoveFromEntity = Inventory.DisableDropOnDeath

function Inventory:NumItems()
    local num = 0
    for k,v in pairs(self.itemslots) do
        num = num + 1
    end

    return num
end

--GuaranteeItems deprecated.
--Rethink logic for multiplayer if you want to resurrect it.

function Inventory:TransferInventory(receiver)
    if not receiver.components.inventory then return end

    local inv = receiver.components.inventory

    for k,v in pairs(self.itemslots) do
        inv:GiveItem(self:RemoveItemBySlot(k))
    end

    for k,v in pairs(self.equipslots) do
       inv:GiveItem(self:Unequip(k)) 
    end
end

function Inventory:OnSave()
    local data = {items= {}, equip = {}}

    local references = {}
    local refs = {}
    for k,v in pairs(self.itemslots) do
        if v.persists then
            data.items[k], refs = v:GetSaveRecord()
            if refs then
                for k,v in pairs(refs) do
                    table.insert(references, v)
                end
            end
        end
    end

    for k,v in pairs(self.equipslots) do
        if v.persists then
            data.equip[k], refs = v:GetSaveRecord()
            if refs then
                for k,v in pairs(refs) do
                    table.insert(references, v)
                end
            end
        end
    end

    if self.activeitem and self.activeitem.persists and not (self.activeitem.components.equippable and self.equipslots[self.activeitem.components.equippable.equipslot] == self.activeitem) then
        data.activeitem, refs = self.activeitem:GetSaveRecord()
        if refs then
            for k,v in pairs(refs) do
                table.insert(references, v)
            end
        end
    end

    return data, references
end

function Inventory:CanTakeItemInSlot(item, slot)
    return item ~= nil
        and item.components.inventoryitem ~= nil
        and (item.components.inventoryitem.cangoincontainer or self.ignorescangoincontainer)
        and (slot == nil or (slot >= 1 and slot <= self.maxslots))
        and not (GetGameModeProperty("non_item_equips") and item.components.equippable ~= nil)
end

function Inventory:AcceptsStacks()
    return self.acceptsstacks
end

function Inventory:IgnoresCanGoInContainer()
    return self.ignorescangoincontainer
end

local function CheckMigrationPets(inst, item)
    if inst.migrationpets ~= nil then
        if item.components.petleash ~= nil then
            for k, v in pairs(item.components.petleash:GetPets()) do
                table.insert(inst.migrationpets, v)
            end
        end

        if item.components.migrationpetowner ~= nil then
            local pet = item.components.migrationpetowner:GetPet()
            if pet ~= nil then
                table.insert(inst.migrationpets, pet)
            end
        end

        if item.components.container ~= nil then
            for k, v in pairs(item.components.container.slots) do
                if v ~= nil then
                    CheckMigrationPets(inst, v)
                end
            end
        end
    end
end

function Inventory:OnLoad(data, newents)
    self.isloading = true

    if data.items ~= nil then
        for k, v in pairs(data.items) do
            local item = SpawnSaveRecord(v, newents)
            if item ~= nil then
                CheckMigrationPets(self.inst, item)
                self:GiveItem(item, k)
            end
        end
    end

    if data.equip ~= nil then
        for k, v in pairs(data.equip) do
            local item = SpawnSaveRecord(v, newents)
            if item ~= nil then
                CheckMigrationPets(self.inst, item)
                self:Equip(item)
            end
        end
    end

    if data.activeitem ~= nil then
        local item = SpawnSaveRecord(data.activeitem, newents)
        if item ~= nil then
            CheckMigrationPets(self.inst, item)
            self:GiveItem(item)
        end
    end

    self.isloading = nil
end

function Inventory:DropActiveItem()
	local active_item = nil
    if self.activeitem ~= nil then
        active_item = self:DropItem(self.activeitem, true)
        self:SetActiveItem(nil)
    end
	return active_item
end

function Inventory:ReturnActiveActionItem(item)
    if item ~= nil and item == self.activeitem and self.inst.bufferedaction ~= nil then
        --Hacks for altering normal inventory:GiveItem() behaviour
        self.ignorefull = true
        self.ignoreoverflow = true

        if self:GiveItem(item) then
            self:SetActiveItem(nil)

            --Super hacks...
            if item == self.inst.bufferedaction.invobject then
                self.inst.bufferedaction.doerownsobject = item.components.inventoryitem:IsHeldBy(self.inst)
            end
            if item == self.inst.bufferedaction.target then
                self.inst.bufferedaction.initialtargetowner = item.components.inventoryitem.owner
            end
        end

        --Hacks for altering normal inventory:GiveItem() behaviour
        self.ignorefull = false
        self.ignoreoverflow = false
    end
end

function Inventory:IsWearingArmor()
    for k, v in pairs(self.equipslots) do
        if v.components.armor ~= nil then
            return true
        end
    end
end

function Inventory:ArmorHasTag(tag)
    for k, v in pairs(self.equipslots) do
        if v.components.armor ~= nil and v:HasTag(tag) then
            return true
        end
    end
end

function Inventory:EquipHasTag(tag)
    for k, v in pairs(self.equipslots) do
        if v:HasTag(tag) then
            return true
        end
    end
end

function Inventory:IsHeavyLifting()
    return self.heavylifting
end

function Inventory:ApplyDamage(damage, attacker, weapon)
    --check resistance and specialised armor
    local absorbers = {}
    for k, v in pairs(self.equipslots) do
        if v.components.resistance ~= nil and
            v.components.resistance:HasResistance(attacker, weapon) and
            v.components.resistance:ShouldResistDamage() then
            v.components.resistance:ResistDamage(damage)
            return 0
        elseif v.components.armor ~= nil then
            absorbers[v.components.armor] = v.components.armor:GetAbsorption(attacker, weapon)
        end
    end

    -- print("Incoming damage", damage)

    local absorbed_percent = 0
    local total_absorption = 0
    for armor, amt in pairs(absorbers) do
        -- print("\t", armor.inst, "absorbs", amt)
        absorbed_percent = math.max(amt, absorbed_percent)
        total_absorption = total_absorption + amt
    end

    local absorbed_damage = damage * absorbed_percent
    local leftover_damage = damage - absorbed_damage

    -- print("\tabsorbed%", absorbed_percent, "total_absorption", total_absorption, "absorbed_damage", absorbed_damage, "leftover_damage", leftover_damage)

    if total_absorption > 0 then
        ProfileStatsAdd("armor_absorb", absorbed_damage)

        for armor, amt in pairs(absorbers) do
            armor:TakeDamage(absorbed_damage * amt / total_absorption + armor:GetBonusDamage(attacker, weapon))
        end
    end

    return leftover_damage
end

function Inventory:GetActiveItem()
    return self.activeitem
end

function Inventory:IsItemEquipped(item)
    for k,v in pairs(self.equipslots) do
        if v == item then
            return k
        end
    end
end

function Inventory:SelectActiveItemFromEquipSlot(slot)
    if self.equipslots[slot] then
        local olditem = self.activeitem
        local newitem = self:Unequip(slot)
        self:GiveActiveItem(newitem)

        if olditem and not self:IsItemEquipped(olditem) then
            self:GiveItem(olditem)
        end
    end

    return self.activeitem
end

function Inventory:CombineActiveStackWithSlot(slot, stack_mod)
    local invitem = self.itemslots[slot] or self.equipslots[slot]
    if invitem == nil then
        return
    end

    local handitem = self.activeitem
    if handitem == nil or handitem.prefab ~= invitem.prefab or handitem.skinname ~= invitem.skinname or handitem.components.stackable == nil then
        return
    end

    if stack_mod and handitem.components.stackable:IsStack() then
        handitem.components.stackable:SetStackSize(handitem.components.stackable:StackSize() - 1)
        invitem.components.stackable:SetStackSize(invitem.components.stackable:StackSize() + 1)
    else
        local leftovers = invitem.components.stackable:Put(handitem)
        self:SetActiveItem(leftovers)
    end
end

function Inventory:SelectActiveItemFromSlot(slot)
    if self.itemslots[slot] == nil then
        return
    end

    local olditem = self.activeitem
    local newitem = self.itemslots[slot]
    self.itemslots[slot] = nil
    self.inst:PushEvent("itemlose", { slot = slot, prev_item = newitem })

    self:SetActiveItem(newitem)

    if olditem ~= nil then
        self:GiveItem(olditem, slot)
    end

    return self.activeitem
end

function Inventory:ReturnActiveItem(slot, stack_mod)
    if self.activeitem == nil then
        return
    end

    if stack_mod and self.activeitem.components.stackable ~= nil and self.activeitem.components.stackable:IsStack() then
        local item = self.activeitem.components.stackable:Get()
        if not self:GiveItem(item, slot) then
            self:DropItem(item)
        end
    else
        if not self:GiveItem(self.activeitem, slot) then
            self:DropItem(self.activeitem)
        end
        self:SetActiveItem(nil)
    end
end

function Inventory:GetNumSlots()
    return self.maxslots
end

function Inventory:GetItemSlot(item)
    for k,v in pairs(self.itemslots) do
        if item == v then
            return k
        end
    end
end

local function CheckItem(item, target, checkcontainer)
    return target ~= nil
        and (item == target
            or (checkcontainer and
                target.replica.container ~= nil and
                target.replica.container:IsHolding(item, checkcontainer)))
end

function Inventory:IsHolding(item, checkcontainer)
    if CheckItem(item, self.activeitem, checkcontainer) or
        (item.replica.equippable ~= nil and
        CheckItem(item, self:GetEquippedItem(item.replica.equippable:EquipSlot()), checkcontainer)) then
        return true
    end
    for k, v in pairs(self.itemslots) do
        if CheckItem(item, v, checkcontainer) then
            return true
        end
    end
end

function Inventory:FindItem(fn)
    for k,v in pairs(self.itemslots) do
        if fn(v) then
            return v
        end
    end

    if self.activeitem and fn(self.activeitem) then
        return self.activeitem
    end

    local overflow = self:GetOverflowContainer()
    return overflow ~= nil and overflow:FindItem(fn) or nil
end

function Inventory:FindItems(fn)
    local items = {}

    for k,v in pairs(self.itemslots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    for k,v in pairs(self.equipslots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    if self.activeitem and fn(self.activeitem) then
        table.insert(items, self.activeitem)
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        for k, v in pairs(overflow:FindItems(fn)) do
            table.insert(items, v)
        end
    end

    return items
end

function Inventory:ForEachItem(fn, ...)
    for k,v in pairs(self.itemslots) do
        fn(v, ...)
    end

    for k,v in pairs(self.equipslots) do
		fn(v, ...)
    end

    if self.activeitem then
		fn(self.activeitem, ...)
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        overflow:ForEachItem(fn, ...)
    end
end

function Inventory:RemoveItemBySlot(slot)
    if slot and self.itemslots[slot] then
        local item = self.itemslots[slot]
        self:RemoveItem(item, true)
        return item
    end
end

function Inventory:DropItem(item, wholestack, randomdir, pos)
    if item == nil or item.components.inventoryitem == nil then
        return
    end

    local dropped = item.components.inventoryitem:RemoveFromOwner(wholestack) or item

    if dropped ~= nil then
        if pos ~= nil then
            dropped.Transform:SetPosition(pos:Get())
        else
            dropped.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        end

        if dropped.components.inventoryitem ~= nil then
            dropped.components.inventoryitem:OnDropped(randomdir)
        end

        dropped.prevcontainer = nil
        dropped.prevslot = nil

        self.inst:PushEvent("dropitem", { item = dropped })
    end

    return dropped
end

function Inventory:IsInsulated() -- from electricity, not temperature
    for k,v in pairs(self.equipslots) do
        if v and v.components.equippable:IsInsulated() then
            return true
        end
    end

    return self.isexternallyinsulated:Get()
end

function Inventory:GetEquippedItem(eslot)
    return self.equipslots[eslot]
end

function Inventory:GetItemInSlot(slot)
    return self.itemslots[slot]
end

function Inventory:IsFull()
    for k = 1, self.maxslots do
        if not self.itemslots[k] then
            return false
        end
    end

    return true
end

--Returns the slot, and the container where the slot is (self.itemslots, self.equipslots or self:GetOverflowContainer())
function Inventory:GetNextAvailableSlot(item)
    local overflow = self:GetOverflowContainer()
    local prioritize_container = overflow and overflow:ShouldPrioritizeContainer(item)

    local prefabname = nil
    local prefabskinname = nil
    if item.components.stackable ~= nil then
        prefabname = item.prefab
        prefabskinname = item.skinname

        --check for stacks that aren't full
        for k, v in pairs(self.equipslots) do
            if v.prefab == prefabname and v.skinname == prefabskinname and v.components.equippable.equipstack and v.components.stackable and not v.components.stackable:IsFull() then
                return k, self.equipslots
            end
        end

        local inv_slot, inv_pref
        for k, v in pairs(self.itemslots) do
            if v.prefab == prefabname and v.skinname == prefabskinname and v.components.stackable and not v.components.stackable:IsFull() then
                if prioritize_container then
                    inv_slot, inv_pref = k, self.itemslots
                    break
                else
                    return k, self.itemslots
                end
            end
        end

        if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.canonlygoinpocket) then
            if overflow ~= nil then
                for k, v in pairs(overflow.slots) do
                    if v.prefab == prefabname and v.skinname == prefabskinname and v.components.stackable and not v.components.stackable:IsFull() then
                        return k, overflow
                    end
                end
            end
        end

        if prioritize_container and inv_slot and inv_pref then
            return inv_slot, inv_pref
        end
    end

    if prioritize_container then
        for k = 1, overflow:GetNumSlots() do
            if overflow:CanTakeItemInSlot(item, k) and not overflow.slots[k] then
                return k, overflow
            end
        end
    end

    --check for empty space in the container
    for k = 1, self.maxslots do
        if self:CanTakeItemInSlot(item, k) and not self.itemslots[k] then
            return k, self.itemslots
        end
    end
    return nil, self.itemslots
end

--Check how many of an item we can accept from its stack
function Inventory:CanAcceptCount(item, maxcount)
    local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
    if stacksize <= 0 then
        return 0
    end

    local acceptcount = 0

    --check for empty space in the container
    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v ~= nil then
            if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                acceptcount = acceptcount + v.components.stackable:RoomLeft()
                if acceptcount >= stacksize then
                    return stacksize
                end
            end
        elseif self:CanTakeItemInSlot(item, k) then
            if self.acceptsstacks or stacksize <= 1 then
                return stacksize
            end
            acceptcount = acceptcount + 1
            if acceptcount >= stacksize then
                return stacksize
            end
        end
    end

    if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.canonlygoinpocket) then
        --check for empty space in our backpack
        local overflow = self:GetOverflowContainer()
        if overflow ~= nil then
            for k = 1, overflow.numslots do
                local v = overflow.slots[k]
                if v ~= nil then
                    if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                        acceptcount = acceptcount + v.components.stackable:RoomLeft()
                        if acceptcount >= stacksize then
                            return stacksize
                        end
                    end
                elseif overflow:CanTakeItemInSlot(item, k) then
                    if overflow.acceptsstacks or stacksize <= 1 then
                        return stacksize
                    end
                    acceptcount = acceptcount + 1
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end
    end

    if item.components.stackable ~= nil then
        --check for equip stacks that aren't full
        for k, v in pairs(self.equipslots) do
            if v.prefab == item.prefab and v.skinname == item.skinname and v.components.equippable.equipstack and v.components.stackable ~= nil then
                acceptcount = acceptcount + v.components.stackable:RoomLeft()
                if acceptcount >= stacksize then
                    return stacksize
                end
            end
        end
    end

    return acceptcount
end

function Inventory:GiveActiveItem(inst)
    if inst ~= nil and inst:IsValid() then
        self:ReturnActiveItem()
        assert(inst.components.inventoryitem ~= nil, inst.entity:GetPrefabName().." in inventory is lacking inventoryitem component")
        if not inst.components.inventoryitem:OnPickup(self.inst) then
            inst.components.inventoryitem:OnPutInInventory(self.inst)

            self:SetActiveItem(inst)
            self.inst:PushEvent("itemget", { item = inst, slot = nil })

            if inst.components.equippable ~= nil then
                inst.components.equippable:ToPocket()
            end
        end
    end
end

function Inventory:GiveItem(inst, slot, src_pos)
    if inst.components.inventoryitem == nil or not inst:IsValid() then
        print("Warning: Can't give item because it's not an inventory item.")
        return
    end

    local eslot = self:IsItemEquipped(inst)

    if eslot then
       self:Unequip(eslot)
    end

    local new_item = inst ~= self.activeitem
    if new_item then
        for k, v in pairs(self.equipslots) do
            if v == inst then
                new_item = false
                break
            end
        end
    end

    if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner ~= self.inst then
        inst.components.inventoryitem:RemoveFromOwner(true)
    end

    local objectDestroyed = inst.components.inventoryitem:OnPickup(self.inst, src_pos)
    if objectDestroyed then
        return
    end

    local can_use_suggested_slot = false

    if not slot and inst.prevslot and not inst.prevcontainer then
        slot = inst.prevslot
    end

    if not slot and inst.prevslot and inst.prevcontainer then
        if inst.prevcontainer.inst:IsValid() and inst.prevcontainer:IsOpenedBy(self.inst) then
            local item = inst.prevcontainer:GetItemInSlot(inst.prevslot)
            if item == nil then
                if inst.prevcontainer:GiveItem(inst, inst.prevslot) then
                    return true
                end
            elseif item.prefab == inst.prefab and item.skinname == inst.skinname and
                item.components.stackable ~= nil and
                inst.prevcontainer:AcceptsStacks() and
                inst.prevcontainer:CanTakeItemInSlot(inst, inst.prevslot) and
                item.components.stackable:Put(inst) == nil then
                return true
            end
        end
        inst.prevcontainer = nil
        inst.prevslot = nil
        slot = nil
    end

    if slot then
        local olditem = self:GetItemInSlot(slot)
        can_use_suggested_slot = slot ~= nil and slot <= self.maxslots and ( olditem == nil or (olditem and olditem.components.stackable and olditem.prefab == inst.prefab and olditem.skinname == inst.skinname)) and self:CanTakeItemInSlot(inst,slot)
    end

    local overflow = self:GetOverflowContainer()
    local container = self.itemslots
    if not can_use_suggested_slot then
        slot, container = self:GetNextAvailableSlot(inst)
    end

    if slot then
        if new_item and not self.ignoresound then
            self.inst:PushEvent("gotnewitem", { item = inst, slot = slot })
        end

        local leftovers = nil
        if overflow ~= nil and container == overflow then
            local itemInSlot = overflow:GetItemInSlot(slot)
            if itemInSlot then
                leftovers = itemInSlot.components.stackable:Put(inst, src_pos)
            else
                overflow:GiveItem(inst, nil, src_pos)
                return true
            end
        elseif container == self.equipslots then
            if self.equipslots[slot] then
                leftovers = self.equipslots[slot].components.stackable:Put(inst, src_pos)
            end
        else
            if self.itemslots[slot] ~= nil then
                if self.itemslots[slot].components.stackable:IsFull() then
                    leftovers = inst
                    inst.prevcontainer = nil
                    inst.prevslot = nil
                else
                    leftovers = self.itemslots[slot].components.stackable:Put(inst, src_pos)
                end
            else
                self.itemslots[slot] = inst
                inst.components.inventoryitem:OnPutInInventory(self.inst)
                self.inst:PushEvent("itemget", { item = inst, slot = slot, src_pos = src_pos })
            end

            if inst.components.equippable then
                inst.components.equippable:ToPocket()
            end
        end

        if leftovers then
            if not self:GiveItem(leftovers) and self.ignorefull then
                --Hack: should only reach here when moving items between containers
                return false
            end
        end

        return slot
    elseif overflow ~= nil and overflow:GiveItem(inst, nil, src_pos, false) then
        return true
    end

    if self.ignorefull then
        return false
    end

    if not (self.isloading or self.silentfull) and self.maxslots > 0 then
        self.inst:PushEvent("inventoryfull", { item = inst })
    end

    --can't hold it!
    if self.activeitem == nil and
        self.maxslots > 0 and
        not inst.components.inventoryitem.canonlygoinpocket and
        not (self.inst.components.playercontroller ~= nil and
            self.inst.components.playercontroller.isclientcontrollerattached) then
        inst.components.inventoryitem:OnPutInInventory(self.inst)
        self:SetActiveItem(inst)
        return true
    elseif self.HandleLeftoversFn ~= nil then
		self.HandleLeftoversFn(self.inst, inst)
	else
        self:DropItem(inst, true, true)
    end
end

function Inventory:Unequip(equipslot, slip)
    local item = self.equipslots[equipslot]
    --print("Inventory:Unequip", item)
    if item ~= nil then
        if item.components.equippable ~= nil then
            item.components.equippable:Unequip(self.inst)
            local overflow = self:GetOverflowContainer()
            if overflow ~= nil and overflow.inst == item then
                self.inst:PushEvent("setoverflow", {})
            end
        end
        if equipslot == EQUIPSLOTS.BODY then
            self.heavylifting = false
        end
    end
    self.equipslots[equipslot] = nil
    self.inst:PushEvent("unequip", {item=item, eslot=equipslot, slip=slip})
    return item
end

function Inventory:SetActiveItem(item)
    if item and item.components.inventoryitem.cangoincontainer or item == nil then
        self.activeitem = item
        self.inst:PushEvent("newactiveitem", {item=item})

        if item and item.components.inventoryitem and item.components.inventoryitem.onactiveitemfn then
            item.components.inventoryitem.onactiveitemfn(item, self.inst)
        end
    else
        self:DropItem(item, true, true)
    end
end

function Inventory:Equip(item, old_to_active)
    if item == nil or item.components.equippable == nil or not item:IsValid() or item.components.equippable:IsRestricted(self.inst) or (self.noheavylifting and item:HasTag("heavy")) then
        return
    end

    -----
    item.prevslot = self:GetItemSlot(item)

    if item.prevslot == nil and
        item.components.inventoryitem.owner ~= nil and
        item.components.inventoryitem.owner.components.container ~= nil and
        item.components.inventoryitem.owner.components.inventoryitem ~= nil then
        item.prevcontainer = item.components.inventoryitem.owner.components.container
        item.prevslot = item.components.inventoryitem.owner.components.container:GetItemSlot(item)
    else
        item.prevcontainer = nil
    end
    -----
    --heavy lifting
    if item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
        local heavyitem = self:GetEquippedItem(EQUIPSLOTS.BODY)
        if heavyitem ~= nil and heavyitem:HasTag("heavy") then
            self:DropItem(heavyitem, true, true)
        end
    elseif item.components.equippable.equipslot == EQUIPSLOTS.BODY and item:HasTag("heavy") then
        local handitem = self:GetEquippedItem(EQUIPSLOTS.HANDS)
        if handitem ~= nil then
            if handitem.components.inventoryitem.cangoincontainer then
                self.silentfull = true
                self:GiveItem(handitem)
                self.silentfull = false
            else
                self:DropItem(handitem, true, true)
            end
        end
    end
    -----

    local leftovers = nil
    if item.components.inventoryitem == nil then
        item = self:RemoveItem(item, item.components.equippable.equipstack) or item
    elseif item.components.inventoryitem:IsHeld() then
        item = item.components.inventoryitem:RemoveFromOwner(item.components.equippable.equipstack) or item
    elseif item.components.stackable ~= nil and item.components.stackable:IsStack() and not item.components.equippable.equipstack then
        leftovers = item
        item = item.components.stackable:Get()
    end

    if item == self.activeitem then
        leftovers = self.activeitem
        self:SetActiveItem(nil)
    end

    local eslot = item.components.equippable.equipslot
    if self.equipslots[eslot] ~= item then
        local olditem = self.equipslots[eslot]
        if leftovers ~= nil then
            if old_to_active then
                self:GiveActiveItem(leftovers)
            else
                self.silentfull = true
                self:GiveItem(leftovers)
                self.silentfull = false
            end
        end
        if olditem ~= nil then
            self:Unequip(eslot)
            olditem.components.equippable:ToPocket()
            if olditem.components.inventoryitem ~= nil and not olditem.components.inventoryitem.cangoincontainer and not self.ignorescangoincontainer then
                olditem.components.inventoryitem:OnRemoved()
                self:DropItem(olditem)
            elseif old_to_active then
                self:GiveActiveItem(olditem)
            else
                self.silentfull = true
                self:GiveItem(olditem)
                self.silentfull = false
            end
        end

        item.components.inventoryitem:OnPutInInventory(self.inst)
        item.components.equippable:Equip(self.inst, not old_to_active and item.prevslot == nil)
        self.equipslots[eslot] = item

        if eslot == EQUIPSLOTS.BODY then
            if item.components.container ~= nil then
                self.inst:PushEvent("setoverflow", { overflow = item })
            end
            self.heavylifting = item:HasTag("heavy")
        end

        self.inst:PushEvent("equip", { item = item, eslot = eslot })
        if METRICS_ENABLED and item.prefab ~= nil then
            ProfileStatsAdd("equip_"..item.prefab)
        end
        return true
    end
end

function Inventory:RemoveItem(item, wholestack, checkallcontainers)
    if item == nil then
        return
    end

    local prevslot = item.components.inventoryitem and item.components.inventoryitem:GetSlotNum() or nil

    if not wholestack and item.components.stackable ~= nil and item.components.stackable:IsStack() then
        local dec = item.components.stackable:Get()
        dec.components.inventoryitem:OnRemoved()
        dec.prevslot = prevslot
        dec.prevcontainer = nil
        return dec
    end

    for k, v in pairs(self.itemslots) do
        if v == item then
            self.itemslots[k] = nil
            self.inst:PushEvent("itemlose", { slot = k, prev_item = item })
            item.components.inventoryitem:OnRemoved()
            item.prevslot = prevslot
            item.prevcontainer = nil
            return item
        end
    end

    if item == self.activeitem then
        self:SetActiveItem()
        self.inst:PushEvent("itemlose", { activeitem = true, prev_item = item })
        item.components.inventoryitem:OnRemoved()
        item.prevslot = prevslot
        item.prevcontainer = nil
        return item
    end

    for k, v in pairs(self.equipslots) do
        if v == item then
            self:Unequip(k)
            item.components.inventoryitem:OnRemoved()
            item.prevslot = prevslot
            item.prevcontainer = nil
            return item
        end
    end

    local overflow = self:GetOverflowContainer()
    local overflow_item = overflow and overflow:RemoveItem(item, wholestack)
    if overflow_item then
        return overflow_item
    end

    if checkallcontainers then
        local containers = self.opencontainers
        for container_inst in pairs(containers) do
            local container = container_inst.components.container or container_inst.components.inventory
            if container and container ~= overflow and not container.excludefromcrafting then
                local container_item = container:RemoveItem(item, wholestack)
                if container_item then
                    return container_item
                end
            end
        end
    end

    return item
end

function Inventory:GetOverflowContainer()
    if self.ignoreoverflow then
        return
    end
    local item = self:GetEquippedItem(EQUIPSLOTS.BODY)
    return (item ~= nil and item.components.container ~= nil and item.components.container.canbeopened)
        and item.components.container
        or nil
end

function Inventory:Has(item, amount, checkallcontainers) --Note(Peter): We don't care about v.skinname for inventory Has requests.
    local num_found = 0
    for k, v in pairs(self.itemslots) do
        if v and v.prefab == item then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if self.activeitem and self.activeitem.prefab == item then
        if self.activeitem.components.stackable ~= nil then
            num_found = num_found + self.activeitem.components.stackable:StackSize()
        else
            num_found = num_found + 1
        end
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        local overflow_enough, overflow_found = overflow:Has(item, amount)
        num_found = num_found + overflow_found
    end

    if checkallcontainers then
        local containers = self.opencontainers

        for container_inst in pairs(containers) do
            local container = container_inst.components.container or container_inst.components.inventory
            if container and container ~= overflow and not container.excludefromcrafting then
                local container_enough, container_found = container:Has(item, amount)
                num_found = num_found + container_found
            end
        end
    end

    return num_found >= amount, num_found
end

function Inventory:HasItemWithTag(tag, amount)
    local num_found = 0
    for k, v in pairs(self.itemslots) do
        if v and v:HasTag(tag) then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    if self.activeitem and self.activeitem:HasTag(tag) then
        if self.activeitem.components.stackable ~= nil then
            num_found = num_found + self.activeitem.components.stackable:StackSize()
        else
            num_found = num_found + 1
        end
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        local overflow_enough, overflow_found = overflow:HasItemWithTag(tag, amount)
        num_found = num_found + overflow_found
    end

    return num_found >= amount, num_found
end

function Inventory:GetItemByName(item, amount, checkallcontainers) --Note(Peter): We don't care about v.skinname for inventory GetItemByName requests.
    local total_num_found = 0
    local items = {}

    local function tryfind(v)
        local num_found = 0
        if v and v.prefab == item then
            local num_left_to_find = amount - total_num_found
            if v.components.stackable then
                if v.components.stackable.stacksize > num_left_to_find then
                    items[v] = num_left_to_find
                    num_found = amount
                else
                    items[v] = v.components.stackable.stacksize
                    num_found = num_found + v.components.stackable.stacksize
                end
            else
                items[v] = 1
                num_found = num_found + 1
            end
        end
        return num_found
    end

    for k = 1,self.maxslots do
        local v = self.itemslots[k]
        total_num_found = total_num_found + tryfind(v)
        if total_num_found >= amount then
            break
        end
    end

    if self.activeitem and self.activeitem.prefab == item and total_num_found < amount then
        total_num_found = total_num_found + tryfind(self.activeitem)
    end

    local overflow = self:GetOverflowContainer()
    if overflow and total_num_found < amount then
        local overflow_items = overflow:GetItemByName(item, (amount - total_num_found))
        for k,v in pairs(overflow_items) do
            items[k] = v
            total_num_found = total_num_found + v
        end
    end

    if checkallcontainers and total_num_found < amount then
        local containers = self.opencontainers

        for container_inst in pairs(containers) do
            local container = container_inst.components.container or container_inst.components.inventory
            if container and container ~= overflow and not container.excludefromcrafting then
                local container_items = container:GetItemByName(item, (amount - total_num_found))
                for k,v in pairs(container_items) do
                    items[k] = v
                    total_num_found = total_num_found + v
                end
            end
            if total_num_found >= amount then
                break
            end
        end
    end

    return items
end

local function crafting_priority_fn(a, b)
    if a.stacksize == b.stacksize then
        return a.slot < b.slot
    end
    return a.stacksize < b.stacksize --smaller stacks first
end

function Inventory:GetCraftingIngredient(item, amount)
    local overflow = self:GetOverflowContainer()
    local crafting_items = {}
    local total_num_found = 0

    for container_inst in pairs(self.opencontainers) do
        local container = container_inst.components.container or container_inst.components.inventory
        if container and container ~= overflow and not container.excludefromcrafting then
            for k, v in pairs(container:GetCraftingIngredient(item, amount - total_num_found, true)) do
                crafting_items[k] = v
                total_num_found = total_num_found + v
            end
        end
        if total_num_found >= amount then
            return crafting_items
        end
    end

    local items = {}
    for i = 1, self.maxslots do
        local v = self.itemslots[i]
        if v and v.prefab == item then
            table.insert(items, {
                item = v,
                stacksize = GetStackSize(v),
                slot = i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)
    for i, v in ipairs(items) do
        local stacksize = math.min(v.stacksize, amount - total_num_found)
        crafting_items[v.item] = stacksize
        total_num_found = total_num_found + stacksize
        if total_num_found >= amount then
            return crafting_items
        end
    end

    if overflow then
        for k,v in pairs(overflow:GetCraftingIngredient(item, amount - total_num_found)) do
            crafting_items[k] = v
            total_num_found = total_num_found + v
        end
        if total_num_found >= amount then
            return crafting_items
        end
    end

    if self.activeitem and self.activeitem.prefab == item then
        crafting_items[self.activeitem] = math.min(GetStackSize(self.activeitem), amount - total_num_found)
    end

    return crafting_items
end

local function tryconsume(self, v, amount)
    if v.components.stackable == nil then
        self:RemoveItem(v):Remove()
        return 1
    elseif v.components.stackable.stacksize > amount then
        v.components.stackable:SetStackSize(v.components.stackable.stacksize - amount)
        return amount
    else
        amount = v.components.stackable.stacksize
        self:RemoveItem(v, true):Remove()
        return amount
    end
    --shouldn't be possible?
    return 0
end

function Inventory:ConsumeByName(item, amount) --Note(Peter): We don't care about v.skinname for inventory ConsumeByName requests.
    if amount <= 0 then
        return
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v ~= nil and v.prefab == item then
            amount = amount - tryconsume(self, v, amount)
            if amount <= 0 then
                return
            end
        end
    end

    if self.activeitem ~= nil and self.activeitem.prefab == item then
        amount = amount - tryconsume(self, self.activeitem, amount)
        if amount <= 0 then
            return
        end
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        overflow:ConsumeByName(item, amount)
    end
end

function Inventory:DropEverythingWithTag(tag)
    local containers = {}

    if self.activeitem ~= nil then
        if self.activeitem:HasTag(tag) then
            self:DropItem(self.activeitem)
            self:SetActiveItem(nil)
        elseif self.activeitem.components.container ~= nil then
            table.insert(containers, self.activeitem)
        end
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v ~= nil then
            if v:HasTag(tag) then
                self:DropItem(v, true, true)
            elseif v.components.container ~= nil then
                table.insert(containers, v)
            end
        end
    end

    for k, v in pairs(self.equipslots) do
        if v:HasTag(tag) then
            self:DropItem(v, true, true)
        elseif v.components.container ~= nil then
            table.insert(containers, v)
        end
    end

    for i, v in ipairs(containers) do
        v.components.container:DropEverythingWithTag(tag)
    end
end

function Inventory:DropEverything(ondeath, keepequip)
    if self.activeitem ~= nil and not (ondeath and self.activeitem.components.inventoryitem.keepondeath) then
        self:DropItem(self.activeitem)
        self:SetActiveItem(nil)
    end

    for k = 1, self.maxslots do
        local v = self.itemslots[k]
        if v ~= nil and not (ondeath and v.components.inventoryitem.keepondeath) then
            self:DropItem(v, true, true)
        end
    end

    if not keepequip then
        for k, v in pairs(self.equipslots) do
            if not (ondeath and v.components.inventoryitem.keepondeath) then
                self:DropItem(v, true, true)
            end
        end
    end
end

function Inventory:DropEquipped(keepBackpack)
    for k, v in pairs(self.equipslots) do
        if not (keepBackpack and v:HasTag("backpack")) then
            self:DropItem(v, true, true)
        end
    end
end

function Inventory:BurnNonpotatableInContainer(container)
    for j = 1,container.numslots do
        if container.slots[j] and container.slots[j]:HasTag("nonpotatable") then
            local olditem = container:RemoveItem(container.slots[j], true)
            local itemash = SpawnPrefab("ash")
            itemash.components.named:SetName( olditem.name )
            container:GiveItem(itemash,j)
            olditem:Remove()
        end
    end
end

function Inventory:ReferenceAllItems()
    local items = {}
    for i=1,self.maxslots do
        if self.itemslots[i] ~= nil then
            table.insert(items, self.itemslots[i])
        end
    end
    for k,v in pairs(self.equipslots) do
        if v ~= nil then
            table.insert(items, v)
        end
    end
    local container = self:GetOverflowContainer()
    if container ~= nil then
        for i,item in ipairs(container:ReferenceAllItems()) do
            table.insert(items, item)
        end
    end
    return items
end

function Inventory:GetDebugString()
    local s = ""
    local count = 0
    for k, item in pairs(self.itemslots) do
        count = count + 1
        s = s..(count > 1 and ", " or ": ")..(item.prefab or "prefab")
        if item.components.stackable ~= nil and item.components.stackable:IsStack() then
            s = s.." x"..tostring(item.components.stackable:StackSize())
        end
    end

    return count..": "..s..string.format(" waterproofness:", self:GetWaterproofness())
end

function Inventory:IsOpenedBy(guy)
    return self.isopen and self.isvisible and guy == self.inst
end

function Inventory:Show()
    if not self.isopen then
        return
    end

    self.inst.replica.inventory:OnShow()

    if self.isvisible then
        return
    end

    if self.inst.HUD ~= nil then
        self.inst.HUD.controls:ShowCraftingAndInventory()
    end

    self.isvisible = true
end

function Inventory:Open()
    self.inst.replica.inventory:OnOpen()

    if self.isopen then
        return
    end

    if self.inst.HUD ~= nil then
        self.inst.HUD.controls:ShowCraftingAndInventory()
    end

    self.isopen = true
    self.isvisible = true

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        overflow:Open(self.inst)
        if self.inst.HUD ~= nil and self.inst.HUD.controls.inv.rebuild_pending then
            self.inst.HUD.controls.inv.rebuild_snapping = true
        end
    end
end

function Inventory:Hide()
    if not self.isopen then
        return
    end

    self.inst.replica.inventory:OnHide()

    if not self.isvisible then
        return
    end

    self:ReturnActiveItem()

    --Don't close backpack, its widget will be hidden instead
    local overflow = self:GetOverflowContainer()
    overflow = overflow ~= nil and overflow.inst or nil

    for k, v in pairs(self.opencontainers) do
        if k ~= overflow then
            k.components.container:Close()
        end
    end

    if self.inst.HUD ~= nil then
        self.inst.HUD.controls:HideCraftingAndInventory()
    end

    self.isvisible = false
end

function Inventory:Close(keepactiveitem)
    self.inst.replica.inventory:OnClose()

    if not self.isopen then
        return
    end

    if not keepactiveitem then
        self:ReturnActiveItem()
    end

    local overflow = self:GetOverflowContainer()
    if overflow ~= nil then
        overflow:Close()
    end

    for k, v in pairs(self.opencontainers) do
        k.components.container:Close()
    end

    if self.inst.HUD ~= nil then
        self.inst.HUD.controls:HideCraftingAndInventory()
    end

    self.isopen = false
    self.isvisible = false
end

--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

function Inventory:PutOneOfActiveItemInSlot(slot)
    local active_item = self:GetActiveItem()
    if active_item ~= nil and
        self:GetItemInSlot(slot) == nil and
        self:CanTakeItemInSlot(active_item, slot) and
        active_item.components.stackable ~= nil and
        active_item.components.stackable:StackSize() > 1 then

        self.ignoresound = true
        self:GiveItem(active_item.components.stackable:Get(1), slot)
        self.ignoresound = false
    end
end

function Inventory:PutAllOfActiveItemInSlot(slot)
    local active_item = self:GetActiveItem()
    if active_item ~= nil and
        self:GetItemInSlot(slot) == nil and
        self:CanTakeItemInSlot(active_item, slot) and
        (self:AcceptsStacks() or
        active_item.components.stackable == nil or
        active_item.components.stackable:StackSize() == 1) then

        self:RemoveItem(active_item, true)
        self.ignoresound = true
        self:GiveItem(active_item, slot)
        self.ignoresound = false
    end
end

function Inventory:TakeActiveItemFromHalfOfSlot(slot)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and
        self:GetActiveItem() == nil and
        item.components.stackable ~= nil and
        item.components.stackable:StackSize() > 1 then

        local halfstack = item.components.stackable:Get(math.floor(item.components.stackable:StackSize() / 2))
        halfstack.prevslot = slot
        halfstack.prevcontainer = nil
        self:GiveActiveItem(halfstack)
    end
end

function Inventory:TakeActiveItemFromAllOfSlot(slot)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and
        self:GetActiveItem() == nil then

        self:RemoveItemBySlot(slot)
        self:GiveActiveItem(item)
    end
end

function Inventory:AddOneOfActiveItemToSlot(slot)
    local active_item = self:GetActiveItem()
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        item.prefab == active_item.prefab and item.skinname == active_item.skinname and
        item.components.stackable ~= nil and
        self:AcceptsStacks() and
        active_item.components.stackable ~= nil and
        active_item.components.stackable:StackSize() > 1 and
        not item.components.stackable:IsFull() then

        item.components.stackable:Put(active_item.components.stackable:Get(1))
    end
end

function Inventory:AddAllOfActiveItemToSlot(slot)
    local active_item = self:GetActiveItem()
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        item.prefab == active_item.prefab and item.skinname == active_item.skinname and
        item.components.stackable ~= nil and
        self:AcceptsStacks() then

        local leftovers = item.components.stackable:Put(active_item)
        self:SetActiveItem(leftovers)
    end
end

function Inventory:SwapActiveItemWithSlot(slot)
    local active_item = self:GetActiveItem()
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        not (item.prefab == active_item.prefab and item.skinname == active_item.skinname and
            item.components.stackable ~= nil and
            self:AcceptsStacks()) and
        not (active_item.components.stackable ~= nil and
            active_item.components.stackable:StackSize() > 1 and
            not self:AcceptsStacks()) then

        self:RemoveItem(active_item, true)
        self:RemoveItemBySlot(slot)
        self:GiveActiveItem(item)
        self:GiveItem(active_item, slot)
    end
end

function Inventory:CanAccessItem(item)
    if not self.isvisible or item == nil or item.components.inventoryitem == nil then
        return false
    end
    local owner = item.components.inventoryitem.owner
    return owner == self.inst or (owner ~= nil and
            owner.components.container ~= nil and
            owner.components.container:IsOpenedBy(self.inst))
end

function Inventory:UseItemFromInvTile(item, actioncode, mod_name)
    if not self.inst.sg:HasStateTag("busy") and
        self:CanAccessItem(item) and
        self.inst.components.playeractionpicker ~= nil then
        local actions
        SetClientRequestedAction(actioncode, mod_name)
        if self:GetActiveItem() ~= nil then
            --use the active item on the inventory item
            actions = self.inst.components.playeractionpicker:GetUseItemActions(item, self:GetActiveItem(), true)
        else
            --just use the inventory item
            actions = self.inst.components.playeractionpicker:GetInventoryActions(item)
        end
        ClearClientRequestedAction()

        if #actions <= 0 then
            return
        elseif actioncode == nil or (actions[1].action.code == actioncode and actions[1].action.mod_name == mod_name) then
            self.inst.components.locomotor:PushAction(actions[1], true)
        --elseif mod_name ~= nil then
            --print("Remote use inventory item failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote use inventory item failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function Inventory:ControllerUseItemOnItemFromInvTile(item, active_item, actioncode, mod_name)
    if not self.inst.sg:HasStateTag("busy") and
        self:CanAccessItem(item) and
        self:CanAccessItem(active_item) and
        self.inst.components.playercontroller ~= nil then
        SetClientRequestedAction(actioncode, mod_name)
        local act = self.inst.components.playercontroller:GetItemUseAction(active_item, item)
        ClearClientRequestedAction()

        if act == nil then
            return
        elseif actioncode == nil or (act.action.code == actioncode and act.action.mod_name == mod_name) then
            --V2C: Usability improvement for DST, we don't need to close
            --     the window for actions since it does not pause in DST
            --[[if self.inst.HUD ~= nil then
                self.inst.HUD.controls.inv:CloseControllerInventory()
            end]]
            self.inst.components.locomotor:PushAction(act, true)
            return true
        --elseif mod_name ~= nil then
            --print("Remote controller use inventory item on item failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller use inventory item on item failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function Inventory:ControllerUseItemOnSelfFromInvTile(item, actioncode, mod_name)
    if not self.inst.sg:HasStateTag("busy") and
        self:CanAccessItem(item) and
        self.inst.components.playercontroller ~= nil then
        local act = nil

        SetClientRequestedAction(actioncode, mod_name)
        if not (item.components.equippable ~= nil and item.components.equippable:IsEquipped()) then
            act = self.inst.components.playercontroller:GetItemSelfAction(item)
        elseif self.maxslots > 0 and not (item:HasTag("heavy") or GetGameModeProperty("non_item_equips")) then
            act = BufferedAction(self.inst, nil, ACTIONS.UNEQUIP, item)
        end
        ClearClientRequestedAction()

        if act == nil then
            return
        elseif actioncode == nil or (act.action.code == actioncode and act.action.mod_name == mod_name) then
            self.inst.components.locomotor:PushAction(act, true)
        --elseif mod_name ~= nil then
            --print("Remote controller use inventory item on self failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller use inventory item on self failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function Inventory:ControllerUseItemOnSceneFromInvTile(item, target, actioncode, mod_name)
    if not self.inst.sg:HasStateTag("busy") and
        self:CanAccessItem(item) and
        self.inst.components.playercontroller ~= nil then
        local act = nil
        SetClientRequestedAction(actioncode, mod_name)
        if item.components.equippable ~= nil and item.components.equippable:IsEquipped() then
            act = self.inst.components.playercontroller:GetItemSelfAction(item)
            if actioncode ~= nil and
                target ~= nil and
                item.components.equippable.equipslot == EQUIPSLOTS.HANDS and
                not (act ~= nil and
                    act.action.code == actioncode and
                    act.action.mod_name == mod_name) then
                act = CanEntitySeeTarget(self.inst, target) and
                    self.inst.components.playercontroller:GetItemUseAction(item, target) or
                    nil
            end
        elseif item.components.inventoryitem:GetGrandOwner() ~= self.inst then
            --V2C: This is now invalid as playercontroller will now send this
            --     case to the proper call to move items between controllers.
        elseif actioncode == nil or target == nil or CanEntitySeeTarget(self.inst, target) then
            act = self.inst.components.playercontroller:GetItemUseAction(item, target)
        end
        ClearClientRequestedAction()

        if act == nil or act.action == ACTIONS.UNEQUIP then
            return
        elseif actioncode == nil then
            self.inst.components.playercontroller:DoActionAutoEquip(act)
            self.inst.components.locomotor:PushAction(act, true)
        elseif act.action.code == actioncode and act.action.mod_name == mod_name then
            self.inst.components.locomotor:PushAction(act, true)
        --elseif mod_name ~= nil then
            --print("Remote controller use inventory item on scene failed: "..tostring(ACTION_MOD_IDS[mod_name][actioncode]))
        --else
            --print("Remote controller use inventory item on scene failed: "..tostring(ACTION_IDS[actioncode]))
        end
    end
end

function Inventory:InspectItemFromInvTile(item)
    if self:CanAccessItem(item) and item.components.inspectable ~= nil then
        self.inst.components.locomotor:PushAction(BufferedAction(self.inst, nil, ACTIONS.LOOKAT, item), true)
    end
end

function Inventory:DropItemFromInvTile(item, single)
    if not self.inst.sg:HasStateTag("busy") and
        self:CanAccessItem(item) and
        self.inst.components.playercontroller ~= nil then
        local buffaction = BufferedAction(self.inst, nil, ACTIONS.DROP, item, self.inst.components.playercontroller:GetRemotePredictPosition() or self.inst:GetPosition())
        buffaction.options.wholestack = not (single and item.components.stackable ~= nil and item.components.stackable:IsStack())
        self.inst.components.locomotor:PushAction(buffaction, true)
    end
end

function Inventory:EquipActiveItem()
    local active_item = self:GetActiveItem()
    if active_item ~= nil and
        active_item.components.equippable ~= nil and
        self:GetEquippedItem(active_item.components.equippable.equipslot) == nil then

        self:Equip(active_item, true, active_item.components.equippable.equipslot)
    end
end

function Inventory:EquipActionItem(item)
    if item == nil then
        item = self:GetActiveItem()
    elseif item ~= nil
        and (item.components.inventoryitem == nil or
            item.components.inventoryitem:GetGrandOwner() ~= self.inst) then
        return
    end
    if item ~= nil and
        item.components.equippable ~= nil and
        item.components.equippable.equipslot == EQUIPSLOTS.HANDS then
        if not item.components.equippable:IsEquipped() then
            if item.components.stackable ~= nil and item.components.stackable.stacksize > 1 and not item.components.equippable.equipstack then
                local stack = item.components.stackable:Get(item.components.stackable.stacksize - 1)
                self:GiveItem(stack)
            end
            self:Equip(item)
        end
        if self:GetActiveItem() == item then
            self:SetActiveItem()
        end
    end
end

function Inventory:SwapEquipWithActiveItem()
    local active_item = self:GetActiveItem()
    if active_item ~= nil and
        active_item.components.equippable ~= nil and
        self:GetEquippedItem(active_item.components.equippable.equipslot) ~= nil then

        self:Equip(active_item, true, active_item.components.equippable.equipslot)
    end
end

function Inventory:TakeActiveItemFromEquipSlot(eslot)
    local item = self:GetEquippedItem(eslot)
    if item ~= nil and
        self:GetActiveItem() == nil then

        if self.maxslots > 0 then
            self:SelectActiveItemFromEquipSlot(eslot)
        else
            self:DropItem(self:Unequip(eslot), true, true)
        end
    end
end

function Inventory:TakeActiveItemFromEquipSlotID(eslotid)
    self:TakeActiveItemFromEquipSlot(EquipSlot.FromID(eslotid))
end

function Inventory:MoveItemFromAllOfSlot(slot, container)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and container ~= nil then
        container = container.components.container
        if container ~= nil and container:IsOpenedBy(self.inst) then

            container.currentuser = self.inst

            local targetslot =
                self.inst.components.constructionbuilderuidata ~= nil and
                self.inst.components.constructionbuilderuidata:GetContainer() == container.inst and
                self.inst.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab) or
                nil

            if container:CanTakeItemInSlot(item, targetslot) then
                item = self:RemoveItemBySlot(slot)
                item.prevcontainer = nil
                item.prevslot = nil
                if not container:GiveItem(item, targetslot, nil, false) then
                    self.ignoresound = true
                    self:GiveItem(item, slot)
                    self.ignoresound = false
                end
            end

            container.currentuser = nil
        end
    end
end

function Inventory:MoveItemFromHalfOfSlot(slot, container)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and container ~= nil then
        container = container.components.container
        if container ~= nil and
            container:IsOpenedBy(self.inst) and
            item.components.stackable ~= nil and
            item.components.stackable:IsStack() then

            container.currentuser = self.inst

            local targetslot =
                self.inst.components.constructionbuilderuidata ~= nil and
                self.inst.components.constructionbuilderuidata:GetContainer() == container.inst and
                self.inst.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab) or
                nil

            if container:CanTakeItemInSlot(item, targetslot) then
                local halfstack = item.components.stackable:Get(math.floor(item.components.stackable:StackSize() / 2))
                halfstack.prevcontainer = nil
                halfstack.prevslot = nil
                if not container:GiveItem(halfstack, targetslot) then
                    self.ignoresound = true
                    self:GiveItem(halfstack, slot)
                    self.ignoresound = false
                end
            end

            container.currentuser = nil
        end
    end
end

function Inventory:GetEquippedMoistureRate(slot)
    local moisture = 0
    local max = 0
    if slot then
        local item = self:GetItemInSlot(slot)
        if item and item.components.equippable then
            local data = item.components.equippable:GetEquippedMoisture()
            moisture = moisture + data.moisture
            max = max + data.max
        end
    else
        for k,v in pairs(self.equipslots) do
            if v and v.components.equippable then
                local data = v.components.equippable:GetEquippedMoisture()
                moisture = moisture + data.moisture
                max = max + data.max
            end
        end
    end
    return moisture, max
end

function Inventory:GetWaterproofness(slot)
    if self.inst.components.moisture ~= nil and self.inst.components.moisture:GetWaterproofInventory() then
        return 1
    end

    local waterproofness = 0

    if slot then
        local item = self:GetItemInSlot(slot)
        if item and item.components.waterproofer then
            waterproofness = waterproofness + item.components.waterproofer:GetEffectiveness()
        end
    else
        for k,v in pairs(self.equipslots) do
            if v and v.components.waterproofer then
                waterproofness = waterproofness + v.components.waterproofer:GetEffectiveness()
            end
        end
    end
    return waterproofness
end

function Inventory:IsWaterproof()
    return self:GetWaterproofness() >= 1
end

return Inventory
