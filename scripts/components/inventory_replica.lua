local function OpenInventory(inst, self)
    self.opentask = nil
    inst.components.inventory:Open()
    if inst.components.revivablecorpse ~= nil and inst:HasTag("corpse") then
        inst.components.inventory:Hide()
    end
end

local Inventory = Class(function(self, inst)
    self.inst = inst

    self.opentask = nil

    if TheWorld.ismastersim then
        if inst:HasTag("player") then
            self.classified = SpawnPrefab("inventory_classified")
            self.classified.entity:SetParent(inst.entity)

            self.opentask = inst:DoStaticTaskInTime(0, OpenInventory, self)

            --Server intercepts messages and forwards to clients via classified net vars
            inst:ListenForEvent("newactiveitem", function(inst, data) self.classified:SetActiveItem(data.item) end)
            inst:ListenForEvent("itemget", function(inst, data) self.classified:SetSlotItem(data.slot, data.item, data.src_pos) end)
            inst:ListenForEvent("itemlose", function(inst, data) self.classified:SetSlotItem(data.slot) end)
            inst:ListenForEvent("equip", function(inst, data) self.classified:SetSlotEquip(data.eslot, data.item) end)
            inst:ListenForEvent("unequip", function(inst, data) self.classified:SetSlotEquip(data.eslot) end)
        end
    elseif self.classified == nil and inst.inventory_classified ~= nil then
        self.classified = inst.inventory_classified
        inst.inventory_classified.OnRemoveEntity = nil
        inst.inventory_classified = nil
        self:AttachClassified(self.classified)
    end
end)

--------------------------------------------------------------------------

function Inventory:OnRemoveEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            if self.opentask ~= nil then
                self.opentask:Cancel()
                self.opentask = nil
            end
            self.inst.components.inventory:Close(true)
            self.classified:Remove()
            self.classified = nil
        else
            self.classified._parent = nil
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

--------------------------------------------------------------------------
--Client triggers open/close based on receiving access to classified data
--------------------------------------------------------------------------

local function OnVisibleDirty(classified)
    local inst = classified._parent
    if inst ~= nil and inst.HUD ~= nil then
        if classified.visible:value() then
            inst.HUD.controls:ShowCraftingAndInventory()
        else
            inst.HUD.controls:HideCraftingAndInventory()
        end
    end
end

local function HeavyLiftingActionFilter(inst, action)
    return action.encumbered_valid == true
end

local function _OnHeavyLiftingDirty(inst, classified)
    if inst ~= nil and inst.components.playeractionpicker ~= nil then
        inst.components.playeractionpicker:PopActionFilter(HeavyLiftingActionFilter)
        if classified.heavylifting:value() then
            inst.components.playeractionpicker:PushActionFilter(HeavyLiftingActionFilter, 10)
        end
    end
end

local function OnHeavyLiftingDirty(classified)
    _OnHeavyLiftingDirty(classified._parent, classified)
end

function Inventory:AttachClassified(classified)
    self.classified = classified

    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)

    self.inst:ListenForEvent("visibledirty", OnVisibleDirty, classified)
    self.inst:ListenForEvent("heavyliftingdirty", OnHeavyLiftingDirty, classified)
    classified:DoStaticTaskInTime(0, OnVisibleDirty)

    --V2C: can re-open inventory with backpack equipped as Werebeaver->Woodie
    --     need to do it here instead of container_replica for correct timing
    if self.inst.HUD ~= nil then
        self.inst.HUD.controls.inv.rebuild_pending = true
        self.inst.HUD.controls.inv.rebuild_snapping = true
    end
end

function Inventory:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil

    if self.inst.HUD ~= nil then
        self.inst.HUD.controls:HideCraftingAndInventory()
        self.inst:PushEvent("newactiveitem", {})
        self.inst:PushEvent("inventoryclosed")
    end
end

--------------------------------------------------------------------------
--Server triggers open/close by setting classified data access
--------------------------------------------------------------------------

function Inventory:OnOpen()
    if self.classified ~= nil then
        self.classified.Network:SetClassifiedTarget(self.inst)
        self.classified.visible:set(true)
    end
end

function Inventory:OnClose()
    if self.opentask ~= nil then
        self.opentask:Cancel()
        self.opentask = nil
    end
    if self.classified ~= nil then
        self.classified.Network:SetClassifiedTarget(self.classified)
        self.classified.visible:set(false)
    end
end

function Inventory:OnShow()
    if self.classified ~= nil then
        self.classified.visible:set(true)
    end
end

function Inventory:OnHide()
    if self.classified ~= nil then
        self.classified.visible:set(false)
    end
end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

function Inventory:SetHeavyLifting(heavylifting)
    if self.classified ~= nil then
        self.classified.heavylifting:set(heavylifting)
        _OnHeavyLiftingDirty(self.inst, self.classified)
    end
end

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

function Inventory:GetNumSlots()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:GetNumSlots()
    else
        return GetMaxItemSlots(TheNet:GetServerGameMode())
    end
end

function Inventory:CanTakeItemInSlot(item, slot)
    return item ~= nil
        and item.replica.inventoryitem ~= nil
        and (self:IgnoresCanGoInContainer() or item.replica.inventoryitem:CanGoInContainer())
        and not (GetGameModeProperty("non_item_equips") and item.replica.equippable ~= nil)
end

function Inventory:AcceptsStacks()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:AcceptsStacks()
    else
        return true
    end
end

function Inventory:IgnoresCanGoInContainer()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:IgnoresCanGoInContainer()
    else
        return false
    end
end

function Inventory:EquipHasTag(tag)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:EquipHasTag(tag)
    elseif self.classified ~= nil then
        for k, v in pairs(self.classified:GetEquips()) do
            if v:HasTag(tag) then
                return true
            end
        end
    end
end

function Inventory:IsHeavyLifting()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:IsHeavyLifting()
    else
        return self.classified ~= nil and self.classified.heavylifting:value()
    end
end

function Inventory:IsVisible()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory.isvisible
    else
        return self.classified ~= nil and self.classified.visible:value()
    end
end

function Inventory:IsOpenedBy(guy)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:IsOpenedBy(guy)
    else
        return self.classified ~= nil and self.classified.visible:value() and guy == self.inst
    end
end

function Inventory:IsHolding(item, checkcontainer)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:IsHolding(item, checkcontainer)
    else
        return self.classified ~= nil and self.classified:IsHolding(item, checkcontainer)
    end
end

function Inventory:GetActiveItem()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:GetActiveItem()
    else
        return self.classified ~= nil and self.classified:GetActiveItem() or nil
    end
end

function Inventory:GetItemInSlot(slot)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:GetItemInSlot(slot)
    else
        return self.classified ~= nil and self.classified:GetItemInSlot(slot) or nil
    end
end

function Inventory:GetEquippedItem(eslot)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:GetEquippedItem(eslot)
    else
        return self.classified ~= nil and self.classified:GetEquippedItem(eslot) or nil
    end
end

function Inventory:GetItems()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory.itemslots
    else
        return self.classified ~= nil and self.classified:GetItems() or {}
    end
end

function Inventory:GetEquips()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory.equipslots
    else
        return self.classified ~= nil and self.classified:GetEquips() or {}
    end
end

--Returns table of container entities as keys (values are true)
function Inventory:GetOpenContainers()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory.opencontainers
    elseif self.inst.HUD ~= nil and self.inst.HUD.controls ~= nil then
        local containers = {}
        for k, v in pairs(self.inst.HUD.controls.containers) do
            if v ~= nil and v.inst.entity:IsVisible() and k:IsValid() then
                containers[k] = true
            end
        end
        --TheInput:ControllerAttached() or Profile:GetIntegratedBackpack()
        local overflow = self:GetOverflowContainer()
        if overflow and overflow.inst then
            containers[overflow.inst] = true
        end
        return containers
    end
end

--Returns backpack container component
function Inventory:GetOverflowContainer()
    if self.inst.components.inventory ~= nil then
        local container = self.inst.components.inventory:GetOverflowContainer()
        return container and container.inst.replica.container or nil
    else
        return self.classified ~= nil and self.classified:GetOverflowContainer() or nil
    end
end

function Inventory:IsFull()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:IsFull()
    else
        return self.classified ~= nil and self.classified:IsFull()
    end
end

function Inventory:Has(prefab, amount, checkallcontainers)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:Has(prefab, amount, checkallcontainers)
    elseif self.classified ~= nil then
        return self.classified:Has(prefab, amount, checkallcontainers)
    else
        return amount <= 0, 0
    end
end

function Inventory:HasItemWithTag(tag, amount)
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:HasItemWithTag(tag, amount)
    elseif self.classified ~= nil then
        return self.classified:HasItemWithTag(tag, amount)
    else
        return amount <= 0, 0
    end
end

--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

function Inventory:ReturnActiveItem()
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:ReturnActiveItem()
    elseif self.classified ~= nil then
        self.classified:ReturnActiveItem()
    end
end

function Inventory:PutOneOfActiveItemInSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:PutOneOfActiveItemInSlot(slot)
    elseif self.classified ~= nil then
        self.classified:PutOneOfActiveItemInSlot(slot)
    end
end

function Inventory:PutAllOfActiveItemInSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:PutAllOfActiveItemInSlot(slot)
    elseif self.classified ~= nil then
        self.classified:PutAllOfActiveItemInSlot(slot)
    end
end

function Inventory:TakeActiveItemFromHalfOfSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:TakeActiveItemFromHalfOfSlot(slot)
    elseif self.classified ~= nil then
        self.classified:TakeActiveItemFromHalfOfSlot(slot)
    end
end

function Inventory:TakeActiveItemFromAllOfSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:TakeActiveItemFromAllOfSlot(slot)
    elseif self.classified ~= nil then
        self.classified:TakeActiveItemFromAllOfSlot(slot)
    end
end

function Inventory:AddOneOfActiveItemToSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:AddOneOfActiveItemToSlot(slot)
    elseif self.classified ~= nil then
        self.classified:AddOneOfActiveItemToSlot(slot)
    end
end

function Inventory:AddAllOfActiveItemToSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:AddAllOfActiveItemToSlot(slot)
    elseif self.classified ~= nil then
        self.classified:AddAllOfActiveItemToSlot(slot)
    end
end

function Inventory:SwapActiveItemWithSlot(slot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:SwapActiveItemWithSlot(slot)
    elseif self.classified ~= nil then
        self.classified:SwapActiveItemWithSlot(slot)
    end
end

function Inventory:UseItemFromInvTile(item)
    if item == nil or not item:IsValid() then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:UseItemFromInvTile(item)
    elseif self.classified ~= nil then
        self.classified:UseItemFromInvTile(item)
    end
end

function Inventory:ControllerUseItemOnItemFromInvTile(item, active_item)
    if item == nil or active_item == nil or not (item:IsValid() and active_item:IsValid()) then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:ControllerUseItemOnItemFromInvTile(item, active_item)
    elseif self.classified ~= nil then
        self.classified:ControllerUseItemOnItemFromInvTile(item, active_item)
    end
end

function Inventory:ControllerUseItemOnSelfFromInvTile(item)
    if item == nil or not item:IsValid() then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:ControllerUseItemOnSelfFromInvTile(item)
    elseif self.classified ~= nil then
        self.classified:ControllerUseItemOnSelfFromInvTile(item)
    end
end

function Inventory:ControllerUseItemOnSceneFromInvTile(item)
    if item == nil or not item:IsValid() then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:ControllerUseItemOnSceneFromInvTile(item)
    elseif self.classified ~= nil then
        self.classified:ControllerUseItemOnSceneFromInvTile(item)
    end
end

function Inventory:InspectItemFromInvTile(item)
    if item == nil or not item:IsValid() then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:InspectItemFromInvTile(item)
    elseif self.classified ~= nil then
        self.classified:InspectItemFromInvTile(item)
    end
end

function Inventory:DropItemFromInvTile(item, single)
    if item == nil or not item:IsValid() then
        return
    elseif self.inst.components.inventory ~= nil then
        self.inst.components.inventory:DropItemFromInvTile(item, single)
    elseif self.classified ~= nil then
        self.classified:DropItemFromInvTile(item, single)
    end
end

function Inventory:CastSpellBookFromInv(item)
	if item == nil or not item:IsValid() then
		return
	elseif self.inst.components.inventory ~= nil then
		self.inst.components.inventory:CastSpellBookFromInv(item)
	elseif self.classified ~= nil then
		self.classified:CastSpellBookFromInv(item)
	end
end

function Inventory:EquipActiveItem()
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:EquipActiveItem()
    elseif self.classified ~= nil then
        self.classified:EquipActiveItem()
    end
end

function Inventory:EquipActionItem(item)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:EquipActionItem(item)
    elseif self.classified ~= nil then
        self.classified:EquipActionItem(item)
    end
end

function Inventory:SwapEquipWithActiveItem()
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:SwapEquipWithActiveItem()
    elseif self.classified ~= nil then
        self.classified:SwapEquipWithActiveItem()
    end
end

function Inventory:TakeActiveItemFromEquipSlot(eslot)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:TakeActiveItemFromEquipSlot(eslot)
    elseif self.classified ~= nil then
        self.classified:TakeActiveItemFromEquipSlot(eslot)
    end
end

function Inventory:MoveItemFromAllOfSlot(slot, container)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:MoveItemFromAllOfSlot(slot, container)
    elseif self.classified ~= nil then
        self.classified:MoveItemFromAllOfSlot(slot, container)
    end
end

function Inventory:MoveItemFromHalfOfSlot(slot, container)
    if self.inst.components.inventory ~= nil then
        self.inst.components.inventory:MoveItemFromHalfOfSlot(slot, container)
    elseif self.classified ~= nil then
        self.classified:MoveItemFromHalfOfSlot(slot, container)
    end
end

--------------------------------------------------------------------------

return Inventory
