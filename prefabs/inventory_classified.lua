--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local EquipSlot = require("equipslotutil")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local TIMEOUT = 2

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

local function SetActiveItem(inst, item)
    inst._active:set(item)

    if item ~= nil and inst._active:value() == item then
        item.replica.inventoryitem:SerializeUsage()
    else
        inst._active:set(nil)
    end
end

local function SetSlotItem(inst, slot, item, src_pos)
    if inst._items[slot] ~= nil then
        inst._items[slot]:set(item)

        if item ~= nil and inst._items[slot]:value() == item then
            local inventoryitem = item.replica.inventoryitem
            inventoryitem:SerializeUsage()
            inventoryitem:SetPickupPos(src_pos)
        else
            inst._items[slot]:set(nil)
        end
    end
end

local function SetSlotEquip(inst, eslot, item)
    if inst._equips[eslot] ~= nil then
        inst._equips[eslot]:set(item)

        if item ~= nil and inst._equips[eslot]:value() == item then
            item.replica.inventoryitem:SerializeUsage()
        else
            inst._equips[eslot]:set(nil)
        end
    end
end

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------

local function OnRemoveEntity(inst)
    if inst._parent ~= nil then
        inst._parent.inventory_classified = nil
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for inventory")
    elseif inst._parent.replica.inventory ~= nil then
        inst._parent.replica.inventory:AttachClassified(inst)
    else
        inst._parent.inventory_classified = inst
        inst.OnRemoveEntity = OnRemoveEntity
    end
end

local function IsBusy(inst)
    return inst._busy or inst._parent == nil
end

local function CheckItem(item, target, checkcontainer)
    return target ~= nil
        and (item == target
            or (checkcontainer and
                target.replica.container ~= nil and
                target.replica.container:IsHolding(item, checkcontainer)))
end

local function IsHolding(inst, item, checkcontainer)
    if CheckItem(item, inst._activeitem, checkcontainer) or
        (item.replica.equippable ~= nil and
        CheckItem(item, inst:GetEquippedItem(item.replica.equippable:EquipSlot()), checkcontainer)) then
        return true
    end
    if inst._itemspreview ~= nil then
        for k, v in pairs(inst._itemspreview) do
            if CheckItem(item, v, checkcontainer) then
                return true
            end
        end
    else
        for i, v in ipairs(inst._items) do
            if CheckItem(item, v:value(), checkcontainer) then
                return true
            end
        end
    end
    if inst._equipspreview ~= nil then
        for k, v in pairs(inst._equipspreview) do
            if CheckItem(item, v, checkcontainer) then
                return true
            end
        end
    else
        for k, v in pairs(inst._equips) do
            if CheckItem(item, v:value(), checkcontainer) then
                return true
            end
        end
    end
end

local function GetActiveItem(inst)
    return inst._activeitem
end

local function GetItemInSlot(inst, slot)
    if inst._itemspreview ~= nil then
        return inst._itemspreview[slot]
    end
    return inst._items[slot] ~= nil and inst._items[slot]:value() or nil
end

local function GetEquippedItem(inst, eslot)
    if inst._equipspreview ~= nil then
        return inst._equipspreview[eslot]
    end
    return inst._equips[eslot] ~= nil and inst._equips[eslot]:value() or nil
end

local function GetItems(inst)
    if inst._itemspreview ~= nil then
        return inst._itemspreview
    end
    local items = {}
    for i, v in ipairs(inst._items) do
        local item = v:value()
        if item ~= inst._activeitem then
            items[i] = item
        end
    end
    return items
end

local function GetEquips(inst)
    if inst._equipspreview ~= nil then
        return inst._equipspreview
    end
    local equips = {}
    for k, v in pairs(inst._equips) do
        local item = v:value()
        if item ~= inst._activeitem then
            equips[k] = item
        end
    end
    return equips
end

local function GetOverflowContainer(inst)
    local item = GetEquippedItem(inst, EQUIPSLOTS.BODY)
    return item ~= nil and item.replica.container or nil
end

local function IsFull(inst)
    if inst._itemspreview ~= nil then
        for i, v in ipairs(inst._items) do
            if inst._itemspreview[i] == nil then
                return false
            end
        end
    else
        for i, v in ipairs(inst._items) do
            if v:value() == nil then
                return false
            end
        end
    end
    return true
end

local function Count(item)
    return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
end

local function Has(inst, prefab, amount)
    local count =
        inst._activeitem ~= nil and
        inst._activeitem.prefab == prefab and
        Count(inst._activeitem) or 0

    if inst._itemspreview ~= nil then
        for i, v in ipairs(inst._items) do
            local item = inst._itemspreview[i]
            if item ~= nil and item.prefab == prefab then
                count = count + Count(item)
            end
        end
    else
        for i, v in ipairs(inst._items) do
            local item = v:value()
            if item ~= nil and item ~= inst._activeitem and item.prefab == prefab then
                count = count + Count(item)
            end
        end
    end

    local overflow = GetOverflowContainer(inst)
    if overflow ~= nil then
        local overflowhas, overflowcount = overflow:Has(prefab, amount)
        count = count + overflowcount
    end

    return count >= amount, count
end

--------------------------------------------------------------------------
--Client sync event handlers that translate and dispatch local UI messages
--------------------------------------------------------------------------

local function Refresh(inst)
    inst._refreshtask = nil
    inst._busy = false
    inst._activeitem = inst._active:value()
    inst._returningitem = nil
    inst._itemspreview = nil
    inst._equipspreview = nil
    if inst._parent ~= nil then
        inst._parent:PushEvent("refreshinventory")
    end
end

local function QueueRefresh(inst, delay)
    if inst._refreshtask == nil then
        inst._refreshtask = inst:DoTaskInTime(delay, Refresh)
        inst._busy = true
    end
end

local function CancelRefresh(inst)
    if inst._refreshtask ~= nil then
        inst._refreshtask:Cancel()
        inst._refreshtask = nil
    end
end

local function OnActiveDirty(inst, netitem)
    inst._slottasks[netitem] = nil
    local item = netitem:value()
    if item ~= inst._activeitem then
        if inst._returncontainer ~= nil and
            (item == nil or
            inst._activeitem == nil or
            item.prefab ~= inst._activeitem.prefab or
            inst._activeitem.replica.stackable == nil or
            inst._returncontainer:GetItemInSlot(inst._returnslot) ~= inst._activeitem) then
            inst._returncontainer = nil
            inst._returnslot = nil
        end
        inst._activeitem = item
        if inst._parent ~= nil then
            inst._parent:PushEvent("newactiveitem", { item = item })
        end
    end
    QueueRefresh(inst, 0)
end

local function OnItemsDirty(inst, slot, netitem)
    inst._slottasks[netitem] = nil
    if inst._parent ~= nil then
        local item = netitem:value()
        if item ~= nil then
            local data =
            {
                item = item,
                slot = slot,
                src_pos = item.replica.inventoryitem ~= nil and item.replica.inventoryitem:GetPickupPos() or nil,
                ignore_stacksize_anim = true,
            }
            if item ~= inst._returningitem and
                (data.src_pos ~= nil or
                inst._itemspreview == nil or
                inst._itemspreview[slot] == nil or
                inst._itemspreview[slot].prefab ~= item.prefab) then
                inst._parent:PushEvent("gotnewitem", data)
            end
            inst._parent:PushEvent("itemget", data)
        else
            inst._parent:PushEvent("itemlose", { slot = slot })
        end
    end
    QueueRefresh(inst, 0)
end

local function OnEquipsDirty(inst, eslot, netitem)
    inst._slottasks[netitem] = nil
    if inst._parent ~= nil then
        local item = netitem:value()
        if item == nil then
            inst._parent:PushEvent("unequip", { item = item, eslot = eslot })
        elseif inst._equipspreview == nil or inst._equipspreview[eslot] ~= item then
            inst._parent:PushEvent("equip", { item = item, eslot = eslot })
        end
    end
    QueueRefresh(inst, 0)
end

local function OnStackItemDirty(inst, item)
    inst._slottasks[item] = nil
    if not item:IsValid() then
        QueueRefresh(inst, 0)
        return
    end
    local data =
    {
        stacksize = item.replica.stackable:StackSize(),
        src_pos = item.replica.inventoryitem:GetPickupPos(),
    }
    item:PushEvent("stacksizechange", data)
    if inst._parent ~= nil then
        --This is for the player's crafting HUD
        data.item = item
        inst._parent:PushEvent("stacksizechange", data)
        if data.src_pos ~= nil or not IsBusy(inst) then
            for i, v in ipairs(inst._items) do
                if item == v:value() then
                    data.slot = i
                    inst._parent:PushEvent("gotnewitem", data)
                    break
                end
            end
            if data.slot == nil then
                for k, v in pairs(inst._equips) do
                    if item == v:value() then
                        data.eslot = k
                        inst._parent:PushEvent("gotnewitem", data)
                        break
                    end
                end
            end
        end
    end
    QueueRefresh(inst, 0)
end

local function QueueSlotTask(inst, key, task)
    if inst._slottasks[key] ~= nil then
        inst._slottasks[key]:Cancel()
    end
    inst._slottasks[key] = task
end

local function RegisterNetListeners(inst)
    inst._slottasks = {}
    Refresh(inst)

    --Delay dirty handlers by one frame so that new items have time to replicate locally

    inst:ListenForEvent("activedirty", function()
        QueueSlotTask(inst, inst._active, inst:DoTaskInTime(0, OnActiveDirty, inst._active))
        CancelRefresh(inst)
    end)

    for i, v in ipairs(inst._items) do
        inst:ListenForEvent("items["..tostring(i).."]dirty", function()
            QueueSlotTask(inst, v, inst:DoTaskInTime(0, OnItemsDirty, i, v))
            CancelRefresh(inst)
        end)
    end

    for k, v in pairs(inst._equips) do
        inst:ListenForEvent("equips["..k.."]dirty", function()
            QueueSlotTask(inst, v, inst:DoTaskInTime(0, OnEquipsDirty, k, v))
            CancelRefresh(inst)
        end)
    end

    inst:ListenForEvent("stackitemdirty", function(world, item)
        if IsHolding(inst, item) then
            QueueSlotTask(inst, item, inst:DoTaskInTime(0, OnStackItemDirty, item))
            CancelRefresh(inst)
        end
    end, TheWorld)
end

--------------------------------------------------------------------------
--Client preview actions while waiting for RPC response from server
--------------------------------------------------------------------------

local function SlotItem(item, slot)
    return item ~= nil and slot ~= nil and { item = item, slot = slot } or nil
end

local function SlotEquip(item, eslot)
    return item ~= nil and eslot ~= nil and  { item = item, eslot = eslot } or nil
end

local function PushNewActiveItem(inst, data, returncontainer, returnslot)
    local item = data ~= nil and data.item or nil
    if item ~= inst._activeitem then
        inst._activeitem = item
        if inst._parent ~= nil then
            inst._parent:PushEvent("newactiveitem", data or {})
        end
        QueueRefresh(inst, TIMEOUT)
    end
    inst._returncontainer = returncontainer
    inst._returnslot = returnslot
end

local function PushItemGet(inst, data, ignoresound)
    if data ~= nil then
        if inst._itemspreview == nil then
            inst._itemspreview = inst:GetItems()
        end
        inst._itemspreview[data.slot] = data.item
        if inst._parent ~= nil then
            if not ignoresound then
                inst._parent:PushEvent("gotnewitem", data)
            end
            inst._parent:PushEvent("itemget", data)
        end
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushItemLose(inst, data)
    if data ~= nil then
        if inst._itemspreview == nil then
            inst._itemspreview = inst:GetItems()
        end
        inst._itemspreview[data.slot] = nil
        if inst._parent ~= nil then
            inst._parent:PushEvent("itemlose", data)
        end
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushEquip(inst, data)
    if data ~= nil then
        if inst._equipspreview == nil then
            inst._equipspreview = inst:GetEquips()
        end
        inst._equipspreview[data.eslot] = data.item
        if inst._parent ~= nil then
            inst._parent:PushEvent("equip", data)
        end
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushUnequip(inst, data)
    if data ~= nil then
        if inst._equipspreview == nil then
            inst._equipspreview = inst:GetEquips()
        end
        inst._equipspreview[data.eslot] = nil
        if inst._parent ~= nil then
            inst._parent:PushEvent("unequip", data)
        end
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushStackSize(inst, item, stacksize, animatestacksize, activestacksize, animateactivestacksize, selfonly, sounddata)
    if item ~= nil and item.replica.stackable ~= nil then
        local oldstacksize = item.replica.stackable:StackSize()
        local data =
        {
            stacksize = stacksize,
            animatestacksize = animatestacksize,
            activestacksize = activestacksize,
            animateactivestacksize = animateactivestacksize,
            activecontainer = selfonly and inst._parent or nil,
        }
        if (stacksize ~= nil and stacksize ~= oldstacksize) or
            (activestacksize ~= nil and activestacksize ~= oldstacksize) then
            if inst._itemspreview == nil then
                for i, v in ipairs(inst._items) do
                    if v:value() == item then
                        inst._itemspreview = inst:GetItems()
                        break
                    end
                end
            end
            if inst._equipspreview == nil then
                for k, v in pairs(inst._equips) do
                    if v:value() == item then
                        inst._equipspreview = inst:GetEquips()
                    end
                end
            end
            QueueRefresh(inst, TIMEOUT)
        end
        if sounddata ~= nil and inst._parent ~= nil then
            --This is for moving items between containers
            --Normally stack size previews have no sound
            inst._parent:PushEvent("gotnewitem", sounddata)
        end
        item:PushEvent("stacksizepreview", data)
    end
end

--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

local function ReturnActiveItem(inst)
    if inst._activeitem ~= nil then
        inst._returningitem = inst._activeitem
        if IsBusy(inst) then
            CancelRefresh(inst)
            QueueRefresh(inst, TIMEOUT)
        else
            if inst._returncontainer ~= nil then
                if inst._returncontainer:IsValid() and inst._activeitem:IsValid() then
                    inst._returncontainer:ReturnActiveItemToSlot(inst._returnslot)
                else
                    inst._returncontainer = nil
                    inst._returnslot = nil
                end
            end
            PushNewActiveItem(inst, nil, inst._returncontainer, inst._returnslot)
        end
    end
    --This is a cancelling action so we want to send it regardless of our busy state
    SendRPCToServer(RPC.ReturnActiveItem)
end

local function ReturnActiveItemToSlot(inst, slot)
    --inventory_classified:ReturnActiveItem will call PushNewActiveItem and SendRPCToServer
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local item = inst:GetItemInSlot(slot)
        if item == nil then
            local giveitem = SlotItem(inst._activeitem, slot)
            PushItemGet(inst, giveitem, true)
        elseif item.replica.stackable ~= nil and item.prefab == inst._activeitem.prefab and item.skinname == inst._activeitem.skinname then
            local stacksize = item.replica.stackable:StackSize() + inst._activeitem.replica.stackable:StackSize()
            local maxsize = item.replica.stackable:MaxSize()
            PushStackSize(inst, item, math.min(stacksize, maxsize), true)
        end
    end
end

local function PutOneOfActiveItemInSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local giveitem = SlotItem(inst._activeitem, slot)
        PushItemGet(inst, giveitem, true)
        PushStackSize(inst, inst._activeitem, 1, false, inst._activeitem.replica.stackable:StackSize() - 1, true)
        SendRPCToServer(RPC.PutOneOfActiveItemInSlot, slot)
    end
end

local function PutAllOfActiveItemInSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local giveitem = SlotItem(inst._activeitem, slot)
        PushNewActiveItem(inst)
        PushItemGet(inst, giveitem, true)
        SendRPCToServer(RPC.PutAllOfActiveItemInSlot, slot)
    end
end

local function TakeActiveItemFromHalfOfSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem == nil then
        local item = inst:GetItemInSlot(slot)
        if item ~= nil then
            local takeitem = SlotItem(item, slot)
            PushNewActiveItem(inst, takeitem, inst, slot)
            local stacksize = item.replica.stackable:StackSize()
            local halfstacksize = math.floor(stacksize / 2)
            PushStackSize(inst, item, stacksize - halfstacksize, true, halfstacksize, false)
            SendRPCToServer(RPC.TakeActiveItemFromHalfOfSlot, slot)
        end
    end
end

local function TakeActiveItemFromAllOfSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem == nil then
        local item = inst:GetItemInSlot(slot)
        if item ~= nil then
            local takeitem = SlotItem(item, slot)
            PushItemLose(inst, takeitem)
            PushNewActiveItem(inst, takeitem, inst, slot)
            SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, slot)
        end
    end
end

local function AddOneOfActiveItemToSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local item = inst:GetItemInSlot(slot)
        if item ~= nil and item.prefab == inst._activeitem.prefab and item.skinname == inst._activeitem.skinname then
            PushStackSize(inst, item, item.replica.stackable:StackSize() + 1, true)
            PushStackSize(inst, inst._activeitem, nil, nil, inst._activeitem.replica.stackable:StackSize() - 1, true)
            SendRPCToServer(RPC.AddOneOfActiveItemToSlot, slot)
        end
    end
end

local function AddAllOfActiveItemToSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local item = inst:GetItemInSlot(slot)
        if item ~= nil and item.prefab == inst._activeitem.prefab and item.skinname == inst._activeitem.skinname then
            local stacksize = item.replica.stackable:StackSize() + inst._activeitem.replica.stackable:StackSize()
            local maxsize = item.replica.stackable:MaxSize()
            if stacksize <= maxsize then
                PushNewActiveItem(inst)
                PushStackSize(inst, item, stacksize, true)
            else
                PushStackSize(inst, item, maxsize, true)
                PushStackSize(inst, inst._activeitem, stacksize - maxsize, false)
            end
            SendRPCToServer(RPC.AddAllOfActiveItemToSlot, slot)
        end
    end
end

local function SwapActiveItemWithSlot(inst, slot)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local item = inst:GetItemInSlot(slot)
        if item ~= nil then
            local takeitem = SlotItem(item, slot)
            local giveitem = SlotItem(inst._activeitem, slot)
            PushItemLose(inst, takeitem)
            PushNewActiveItem(inst, takeitem, inst, slot)
            PushItemGet(inst, giveitem)
            SendRPCToServer(RPC.SwapActiveItemWithSlot, slot)
        end
    end
end

local function UseItemFromInvTile(inst, item)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        not inst._parent:HasTag("busy") and
        not (inst._parent.sg ~= nil and
            inst._parent.sg:HasStateTag("busy")) and
        inst._parent.components.playeractionpicker ~= nil and
        inst._parent.components.playercontroller ~= nil then
        local actions = inst._activeitem ~= nil and
            inst._parent.components.playeractionpicker:GetUseItemActions(item, inst._activeitem, true) or
            inst._parent.components.playeractionpicker:GetInventoryActions(item)
        if #actions > 0 then
            if actions[1].action == ACTIONS.RUMMAGE then
                local overflow = GetOverflowContainer(inst)
                if overflow ~= nil and overflow.inst == item then
                    if overflow:IsOpenedBy(inst._parent) then
                        overflow:Close()
                    else
                        overflow:Open(inst._parent)
                    end
                    return
                end
            end
            inst._parent.components.playercontroller:RemoteUseItemFromInvTile(actions[1], item)
        end
    end
end

local function ControllerUseItemOnItemFromInvTile(inst, item, active_item)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        not inst._parent:HasTag("busy") and
        not (inst._parent.sg ~= nil and
            inst._parent.sg:HasStateTag("busy")) and
        inst._parent.components.playercontroller ~= nil then
        local act = inst._parent.components.playercontroller:GetItemUseAction(active_item, item)
        if act ~= nil then
            --V2C: Usability improvement for DST, we don't need to close
            --     the window for actions since it does not pause in DST
            --[[if inst._parent.HUD ~= nil then
                inst._parent.HUD.controls.inv:CloseControllerInventory()
            end]]
            if act.action == ACTIONS.RUMMAGE then
                local overflow = GetOverflowContainer(inst)
                if overflow ~= nil and overflow.inst == item then
                    if overflow:IsOpenedBy(inst._parent) then
                        overflow:Close()
                    else
                        overflow:Open(inst._parent)
                    end
                    return
                end
            end
            inst._parent.components.playercontroller:RemoteControllerUseItemOnItemFromInvTile(act, item, active_item)
        end
    end
end

local function ControllerUseItemOnSelfFromInvTile(inst, item)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        not inst._parent:HasTag("busy") and
        not (inst._parent.sg ~= nil and
            inst._parent.sg:HasStateTag("busy")) and
        inst._parent.components.playercontroller ~= nil then
        local act = nil
        if not (item.replica.equippable ~= nil and item.replica.equippable:IsEquipped()) then
            act = inst._parent.components.playercontroller:GetItemSelfAction(item)
        elseif #inst._items > 0 and not item:HasTag("heavy") then
            act = BufferedAction(inst._parent, nil, ACTIONS.UNEQUIP, item)
        end

        if act ~= nil then
            if act.action == ACTIONS.RUMMAGE then
                local overflow = GetOverflowContainer(inst)
                if overflow ~= nil and overflow.inst == item then
                    if overflow:IsOpenedBy(inst._parent) then
                        overflow:Close()
                    else
                        overflow:Open(inst._parent)
                    end
                    return
                end
            end
            inst._parent.components.playercontroller:RemoteControllerUseItemOnSelfFromInvTile(act, item)
        end
    end
end

local function ControllerUseItemOnSceneFromInvTile(inst, item)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        not inst._parent:HasTag("busy") and
        not (inst._parent.sg ~= nil and
            inst._parent.sg:HasStateTag("busy")) and
        inst._parent.components.playercontroller ~= nil then
        local act = nil
        if item.replica.equippable ~= nil and item.replica.equippable:IsEquipped() then
            act = inst._parent.components.playercontroller:GetItemSelfAction(item)
        elseif item.replica.inventoryitem ~= nil and not item.replica.inventoryitem:IsGrandOwner(inst._parent) then
            --V2C: This is now invalid as playercontroller will now send this
            --     case to the proper call to move items between controllers.
        else
            act = inst._parent.components.playercontroller:GetItemUseAction(item)
        end

        if act ~= nil and act.action ~= ACTIONS.UNEQUIP then
            if act.action == ACTIONS.RUMMAGE then
                local overflow = GetOverflowContainer(inst)
                if overflow ~= nil and overflow.inst == item then
                    if overflow:IsOpenedBy(inst._parent) then
                        overflow:Close()
                    else
                        overflow:Open(inst._parent)
                    end
                    return
                end
            end
            inst._parent.components.playercontroller:DoActionAutoEquip(act)
            inst._parent.components.playercontroller:RemoteControllerUseItemOnSceneFromInvTile(act, item)
        end
    end
end

local function InspectItemFromInvTile(inst, item)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        inst._parent.components.playercontroller ~= nil and
        item:HasTag("inspectable") then
        inst._parent.components.playercontroller:RemoteInspectItemFromInvTile(item)
    end
end

local function DropItemFromInvTile(inst, item, single)
    if not IsBusy(inst) and
        inst._parent ~= nil and
        not inst._parent:HasTag("busy") and
        not (inst._parent.sg ~= nil and
            inst._parent.sg:HasStateTag("busy")) and
        inst._parent.components.playercontroller ~= nil then
        inst._parent.components.playercontroller:RemoteDropItemFromInvTile(item, single)
    end
end

local function EquipActiveItem(inst)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local giveitem = SlotEquip(inst._activeitem, inst._activeitem.replica.equippable:EquipSlot())
        PushNewActiveItem(inst)
        PushEquip(inst, giveitem)
        SendRPCToServer(RPC.EquipActiveItem)
    end
end

local function EquipActionItem(inst, item)
    if not IsBusy(inst)
        and (inst._activeitem == item
            or (inst._parent ~= nil and
                inst._parent.components.playercontroller ~= nil and
                inst._parent.components.playercontroller:GetCursorInventoryObject() == item)) then
        local eslot = item.replica.equippable:EquipSlot()
        local takeequip = SlotEquip(inst:GetEquippedItem(eslot), eslot)
        local giveitem = SlotEquip(item, eslot)
        if takeequip ~= nil then
            PushUnequip(inst, takeequip)
        end
        if inst._activeitem ~= nil then
            PushNewActiveItem(inst)
        elseif inst._parent ~= nil and inst._parent.components.playercontroller ~= nil then
            local slot, container = inst._parent.components.playercontroller:GetCursorInventorySlotAndContainer()
            if slot ~= nil and container ~= nil then
                if container.classified == inst then
                    if inst:GetItemInSlot(slot) == item then
                        local takeitem = SlotItem(item, slot)
                        PushItemLose(inst, takeitem)
                    end
                elseif container.classified ~= nil then
                    container.classified:TakeActionItem(item, slot)
                end
            end
        end
        PushEquip(inst, giveitem)
        SendRPCToServer(RPC.EquipActionItem, inst._activeitem ~= item and item or nil)
    end
end

local function SwapEquipWithActiveItem(inst)
    if not IsBusy(inst) and inst._activeitem ~= nil then
        local eslot = inst._activeitem.replica.equippable:EquipSlot()
        local item = inst:GetEquippedItem(eslot)
        if item ~= nil then
            local takeequip = SlotEquip(item, eslot)
            local giveequip = SlotEquip(inst._activeitem, eslot)
            PushUnequip(inst, takeequip)
            PushNewActiveItem(inst,
                item.replica.inventoryitem ~= nil and
                item.replica.inventoryitem:CanGoInContainer() and
                takeequip or nil)
            PushEquip(inst, giveequip)
            SendRPCToServer(RPC.SwapEquipWithActiveItem)
        end
    end
end

local function TakeActiveItemFromEquipSlot(inst, eslot)
    if not IsBusy(inst) and inst._activeitem == nil then
        local item = inst:GetEquippedItem(eslot)
        if item ~= nil then
            if item.replica.inventoryitem ~= nil and item.replica.inventoryitem:CanGoInContainer() then
                local takeequip = SlotEquip(item, eslot)
                PushUnequip(inst, takeequip)
                PushNewActiveItem(inst, takeequip)
            else
                QueueRefresh(inst, TIMEOUT)
            end
            SendRPCToServer(RPC.TakeActiveItemFromEquipSlot, EquipSlot.ToID(eslot))
        end
    end
end

local function MoveItemFromAllOfSlot(inst, slot, container)
    if not IsBusy(inst) then
        local container_classified = container ~= nil and container.replica.container ~= nil and container.replica.container.classified or nil
        if container_classified ~= nil and not container_classified:IsBusy() then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil then
                local remainder = nil
                if inst._parent.components.constructionbuilderuidata ~= nil and inst._parent.components.constructionbuilderuidata:GetContainer() == container then
                    local targetslot = inst._parent.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
                    if targetslot ~= nil then
                        remainder = container_classified:ReceiveItem(item, nil, targetslot)
                    end
                else
                    remainder = container_classified:ReceiveItem(item)
                end
                if remainder ~= nil then
                    if remainder > 0 then
                        PushStackSize(inst, item, nil, nil, remainder, false, true)
                    else
                        local takeitem = SlotItem(item, slot)
                        PushItemLose(inst, takeitem)
                    end
                    SendRPCToServer(RPC.MoveInvItemFromAllOfSlot, slot, container)
                end
            end
        end
    end
end

local function MoveItemFromHalfOfSlot(inst, slot, container)
    if not IsBusy(inst) then
        local container_classified = container ~= nil and container.replica.container ~= nil and container.replica.container.classified or nil
        if container_classified ~= nil and not container_classified:IsBusy() then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil and item.replica.stackable ~= nil and item.replica.stackable:IsStack() then
                local remainder = nil
                if inst._parent.components.constructionbuilderuidata ~= nil and inst._parent.components.constructionbuilderuidata:GetContainer() == container then
                    local targetslot = inst._parent.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
                    if targetslot ~= nil then
                        remainder = container_classified:ReceiveItem(item, math.floor(item.replica.stackable:StackSize() / 2), targetslot)
                    end
                else
                    remainder = container_classified:ReceiveItem(item, math.floor(item.replica.stackable:StackSize() / 2))
                end
                if remainder ~= nil then
                    if remainder > 0 then
                        PushStackSize(inst, item, nil, nil, remainder, true, true)
                    else
                        local takeitem = SlotItem(item, slot)
                        PushItemLose(inst, takeitem)
                    end
                    SendRPCToServer(RPC.MoveInvItemFromHalfOfSlot, slot, container)
                end
            end
        end
    end
end

--V2C: forceslot should never be used for inventory_classified,
--     but it is there to match container_classified interface.
local function ReceiveItem(inst, item, count)--, forceslot)
    if IsBusy(inst) then
        return
    end
    local overflow = GetOverflowContainer(inst)
    overflow = overflow and overflow.classified or nil
    if overflow ~= nil and overflow:IsBusy() then
        return
    end
    local isstackable = item.replica.stackable ~= nil
    local originalstacksize = isstackable and item.replica.stackable:StackSize() or 1
    if not isstackable or inst._parent.replica.inventory == nil or not inst._parent.replica.inventory:AcceptsStacks() then
        for i, v in ipairs(inst._items) do
            if v:value() == nil then
                local giveitem = SlotItem(item, i)
                PushItemGet(inst, giveitem)
                if originalstacksize > 1 then
                    PushStackSize(inst, item, nil, nil, 1, false, true)
                    return originalstacksize - 1
                else
                    return 0
                end
            end
        end
        if overflow ~= nil then
            return overflow:ReceiveItem(item, count)
        end
    else
        local originalcount = count and math.min(count, originalstacksize) or originalstacksize
        count = originalcount
        if item.replica.equippable ~= nil then
            local eslot = item.replica.equippable:EquipSlot()
            local equip = inst:GetEquippedItem(eslot)
            if equip ~= nil and
                equip.prefab == item.prefab and equip.skinname == item.skinname and
                equip.replica.stackable ~= nil and
                not equip.replica.stackable:IsFull() then
                local stacksize = equip.replica.stackable:StackSize() + count
                local maxsize = equip.replica.stackable:MaxSize()
                if stacksize > maxsize then
                    count = math.max(stacksize - maxsize, 0)
                    stacksize = maxsize
                else
                    count = 0
                end
                PushStackSize(inst, equip, stacksize, true, nil, nil, nil, SlotEquip(equip, eslot))
            end
        end
        if count > 0 then
            local emptyslot = nil
            for i, v in ipairs(inst._items) do
                local slotitem = v:value()
                if slotitem == nil then
                    if emptyslot == nil then
                        emptyslot = i
                    end
                elseif slotitem.prefab == item.prefab and slotitem.skinname == item.skinname and
                    slotitem.replica.stackable ~= nil and
                    not slotitem.replica.stackable:IsFull() then
                    local stacksize = slotitem.replica.stackable:StackSize() + count
                    local maxsize = slotitem.replica.stackable:MaxSize()
                    if stacksize > maxsize then
                        count = math.max(stacksize - maxsize, 0)
                        stacksize = maxsize
                    else
                        count = 0
                    end
                    PushStackSize(inst, slotitem, stacksize, true, nil, nil, nil, SlotItem(slotitem, i))
                    if count <= 0 then
                        break
                    end
                end
            end
            if count > 0 then
                if emptyslot ~= nil then
                    local giveitem = SlotItem(item, emptyslot)
                    PushItemGet(inst, giveitem)
                    if count ~= originalstacksize then
                        PushStackSize(inst, item, nil, nil, count, false, true)
                    end
                    count = 0
                elseif overflow ~= nil then
                    local remainder = overflow:ReceiveItem(item, count)
                    if remainder ~= nil then
                        count = math.max(count - (originalstacksize - remainder), 0)
                    end
                end
            end
        end
        if count ~= originalcount then
            return originalstacksize - (originalcount - count)
        end
    end
end

local function ConsumeByName(inst, prefab, amount, overflow)
    if amount <= 0 then
        return
    end

    for i, v in ipairs(inst._items) do
        local item = v:value()
        if item ~= nil and item.prefab == prefab then
            local stacksize = item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
            if stacksize <= amount then
                local takeitem = SlotItem(item, i)
                PushItemLose(inst, takeitem)
                if amount <= stacksize then
                    return
                end
                amount = amount - stacksize
            else
                PushStackSize(inst, item, stacksize - amount, true)
                return
            end
        end
    end

    if inst._activeitem ~= nil and inst._activeitem.prefab == prefab then
        local stacksize = inst._activeitem.replica.stackable ~= nil and inst._activeitem.replica.stackable:StackSize() or 1
        if stacksize <= amount then
            PushNewActiveItem(inst)
            if amount <= stacksize then
                return
            end
            amount = amount - stacksize
        else
            PushStackSize(inst, inst._activeitem, stacksize - amount, true)
            return
        end
    end

    if overflow ~= nil then
        overflow:ConsumeByName(prefab, amount)
    end
end

local function RemoveIngredients(inst, recipe, ingredientmod)
    if IsBusy(inst) then
        return false
    end
    local overflow = GetOverflowContainer(inst)
    overflow = overflow and overflow.classified or nil
    if overflow ~= nil and overflow:IsBusy() then
        return false
    end
    for i, v in ipairs(recipe.ingredients) do
        local amt = math.max(1, RoundBiasedUp(v.amount * ingredientmod))
        ConsumeByName(inst, v.type, amt, overflow)
    end
    return true
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() --So we can follow parent's sleep state
    end
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    --Variables for tracking local preview state;
    --Whenever a server sync is received, all local dirty states are reverted
    inst._refreshtask = nil
    inst._busy = true
    inst._activeitem = nil
    inst._returningitem = nil
    inst._returncontainer = nil
    inst._returnslot = nil
    inst._itemspreview = nil
    inst._equipspreview = nil

    --Network variables
    inst.visible = net_bool(inst.GUID, "inventory.visible", "visibledirty")
    inst.heavylifting = net_bool(inst.GUID, "inventory.heavylifting", "heavyliftingdirty")

    inst._active = net_entity(inst.GUID, "inventory._active", "activedirty")
    inst._items = {}
    inst._equips = {}
    inst._slottasks = nil

    for i = 1, GetMaxItemSlots(TheNet:GetServerGameMode()) do
        table.insert(inst._items, net_entity(inst.GUID, "inventory._items["..tostring(i).."]", "items["..tostring(i).."]dirty"))
    end

    for k, v in pairs(EQUIPSLOTS) do
        inst._equips[v] = net_entity(inst.GUID, "inventory._equips["..v.."]", "equips["..v.."]dirty")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated
        inst.IsHolding = IsHolding
        inst.GetActiveItem = GetActiveItem
        inst.GetItemInSlot = GetItemInSlot
        inst.GetEquippedItem = GetEquippedItem
        inst.GetItems = GetItems
        inst.GetEquips = GetEquips
        inst.GetOverflowContainer = GetOverflowContainer
        inst.IsFull = IsFull
        inst.Has = Has
        inst.ReturnActiveItem = ReturnActiveItem
        inst.ReturnActiveItemToSlot = ReturnActiveItemToSlot
        inst.PutOneOfActiveItemInSlot = PutOneOfActiveItemInSlot
        inst.PutAllOfActiveItemInSlot = PutAllOfActiveItemInSlot
        inst.TakeActiveItemFromHalfOfSlot = TakeActiveItemFromHalfOfSlot
        inst.TakeActiveItemFromAllOfSlot = TakeActiveItemFromAllOfSlot
        inst.AddOneOfActiveItemToSlot = AddOneOfActiveItemToSlot
        inst.AddAllOfActiveItemToSlot = AddAllOfActiveItemToSlot
        inst.SwapActiveItemWithSlot = SwapActiveItemWithSlot
        inst.UseItemFromInvTile = UseItemFromInvTile
        inst.ControllerUseItemOnItemFromInvTile = ControllerUseItemOnItemFromInvTile
        inst.ControllerUseItemOnSelfFromInvTile = ControllerUseItemOnSelfFromInvTile
        inst.ControllerUseItemOnSceneFromInvTile = ControllerUseItemOnSceneFromInvTile
        inst.InspectItemFromInvTile = InspectItemFromInvTile
        inst.DropItemFromInvTile = DropItemFromInvTile
        inst.EquipActiveItem = EquipActiveItem
        inst.EquipActionItem = EquipActionItem
        inst.SwapEquipWithActiveItem = SwapEquipWithActiveItem
        inst.TakeActiveItemFromEquipSlot = TakeActiveItemFromEquipSlot
        inst.MoveItemFromAllOfSlot = MoveItemFromAllOfSlot
        inst.MoveItemFromHalfOfSlot = MoveItemFromHalfOfSlot

        --Exposed for container and builder
        inst.QueueRefresh = QueueRefresh
        inst.PushNewActiveItem = PushNewActiveItem
        inst.ReceiveItem = ReceiveItem
        inst.RemoveIngredients = RemoveIngredients
        inst.IsBusy = IsBusy

        --Delay net listeners until after initial values are deserialized
        inst:DoTaskInTime(0, RegisterNetListeners)
        return inst
    end

    --Server interface
    inst.SetActiveItem = SetActiveItem
    inst.SetSlotItem = SetSlotItem
    inst.SetSlotEquip = SetSlotEquip

    inst.persists = false

    return inst
end

return Prefab("inventory_classified", fn)