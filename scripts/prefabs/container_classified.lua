local containers = require("containers")
local TIMEOUT = 2

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

local function InitializeSlots(inst, numslots)
    --Can't re-initialize slots after RegisterNetListeners
    assert(inst._slottasks == nil)

    local curslots = #inst._items
    if numslots > curslots then
        for i = curslots + 1, numslots do
            table.insert(inst._items, table.remove(inst._itemspool, 1))
        end
    elseif numslots < curslots then
        for i = curslots, numslots + 1, -1 do
            table.insert(inst._itemspool, 1, table.remove(inst._items))
        end
    end
end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

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

--------------------------------------------------------------------------
--Client interface
--------------------------------------------------------------------------

local function ProxyItem(item, context)
	if item then
		local proxy_item = EntityScriptProxy(item)
		proxy_item:SetProxyProperty("stackable_preview_context", context)

		--See if we need to transfer preview stacksize over
		if item.stackable_preview_context and item.stackable_preview_context ~= context then
			local stackable = item.replica.stackable
			if stackable then
				stackable:SetPreviewStackSize(stackable:StackSize(), context, TIMEOUT)
			end
		end
		return proxy_item
	end
end

local function OnRemoveEntity(inst)
    if inst._parent ~= nil then
        inst._parent.container_classified = nil
    end
end

local function OnEntityReplicated(inst)
    inst._parent = inst.entity:GetParent()
    if inst._parent == nil then
        print("Unable to initialize classified data for container")
	elseif not inst._parent:TryAttachClassifiedToReplicaComponent(inst, "container") then
        inst._parent.container_classified = inst
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
end

local function GetItemInSlot(inst, slot)
    if inst._itemspreview ~= nil then
        return inst._itemspreview[slot]
    end
    return inst._items[slot] ~= nil and inst._items[slot]:value() or nil
end

local function GetProxyItems(inst)
	local items = {}
	for i, v in ipairs(inst._items) do
		items[i] = ProxyItem(v:value(), inst)
	end
	return items
end

local function GetItems(inst)
    if inst._itemspreview ~= nil then
        return inst._itemspreview
    end
    local items = {}
    for i, v in ipairs(inst._items) do
        items[i] = v:value()
    end
    return items
end

local function IsEmpty(inst)
    if inst._itemspreview ~= nil then
		for i = 1, #inst._items do
            if inst._itemspreview[i] ~= nil then
                return false
            end
        end
    else
        for i, v in ipairs(inst._items) do
            if v:value() ~= nil then
                return false
            end
        end
    end
    return true
end

local function IsFull(inst)
    if inst._itemspreview ~= nil then
		for i = 1, #inst._items do
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
	local stackable = item.replica.stackable
	return stackable and stackable:StackSize() or 1
end

local function Has(inst, prefab, amount, iscrafting)
    local count = 0
    if inst._itemspreview ~= nil then
		for i = 1, #inst._items do
            local item = inst._itemspreview[i]
			if item ~= nil and item.prefab == prefab and not (iscrafting and item:HasTag("nocrafting")) then
                count = count + Count(item)
            end
        end
    else
        for i, v in ipairs(inst._items) do
            local item = v:value()
			if item ~= nil and item.prefab == prefab and not (iscrafting and item:HasTag("nocrafting")) then
                count = count + Count(item)
            end
        end
    end
    return count >= amount, count
end

local function HasItemWithTag(inst, tag, amount)
    local count = 0
    if inst._itemspreview ~= nil then
		for i = 1, #inst._items do
            local item = inst._itemspreview[i]
            if item ~= nil and item:HasTag(tag) then
                count = count + Count(item)
            end
        end
    else
        for i, v in ipairs(inst._items) do
            local item = v:value()
            if item ~= nil and item:HasTag(tag) then
                count = count + Count(item)
            end
        end
    end
    return count >= amount, count
end

--------------------------------------------------------------------------
--Client sync event handlers that translate and dispatch local UI messages
--------------------------------------------------------------------------

local function RefreshCrafting(inst)
    local player = ThePlayer
    if player ~= nil then
        player:PushEvent("refreshcrafting")
    end
end

local function RefreshItemStackSize(item)
	local stackable = item and item.replica.stackable or nil
	if stackable then
		stackable:ClearPreviewStackSize()
	end
end

local function Refresh(inst)
    inst._refreshtask = nil
    inst._busy = false
    inst._itemspreview = nil
    if inst._parent ~= nil then
		for i, v in ipairs(inst._items) do
			RefreshItemStackSize(v:value())
		end
        inst._parent:PushEvent("refresh")
        RefreshCrafting(inst)
    end
end

local function QueueRefresh(inst, delay)
    if inst._refreshtask == nil then
        inst._refreshtask = inst:DoStaticTaskInTime(delay, Refresh)
        inst._busy = true
		if delay > 0 then
			RefreshCrafting(inst)
		end
    end
	if delay == 0 then
		local player = ThePlayer
		if player then
			--cancel now, since next static tick will push "refreshcrafting" again
			--this will keep inventory, open containers, and crafting refreshes in sync
			player:PushEvent("cancelrefreshcrafting")
		end
	end
end

local function CancelRefresh(inst)
    if inst._refreshtask ~= nil then
        inst._refreshtask:Cancel()
        inst._refreshtask = nil
    end
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
            if (data.src_pos ~= nil or
                inst._itemspreview == nil or
                inst._itemspreview[slot] == nil or
                inst._itemspreview[slot].prefab ~= item.prefab) and
                inst._parent.replica.inventoryitem ~= nil and
                inst._parent.replica.inventoryitem:IsHeldBy(ThePlayer) then
                ThePlayer:PushEvent("gotnewitem", data)
            end
            inst._parent:PushEvent("itemget", data)
        else
            inst._parent:PushEvent("itemlose", { slot = slot })
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
    if (data.src_pos ~= nil or not IsBusy(inst)) and
        inst._parent ~= nil and
        inst._parent.replica.inventoryitem ~= nil and
        inst._parent.replica.inventoryitem:IsHeldBy(ThePlayer) then
        for i, v in ipairs(inst._items) do
            if item == v:value() then
                data.item = item
                data.slot = i
                ThePlayer:PushEvent("gotnewitem", data)
                break
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

    for i, v in ipairs(inst._items) do
        inst:ListenForEvent("items["..tostring(i).."]dirty", function()
            QueueSlotTask(inst, v, inst:DoStaticTaskInTime(0, OnItemsDirty, i, v))
            CancelRefresh(inst)
        end)
    end

    inst:ListenForEvent("stackitemdirty", function(world, item)
        if IsHolding(inst, item) then
            QueueSlotTask(inst, item, inst:DoStaticTaskInTime(0, OnStackItemDirty, item))
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

local function PushItemGet(inst, data, ignoresound)
    if data ~= nil then
        if inst._parent ~= nil then
            if not ignoresound and
                inst._parent.replica.inventoryitem ~= nil and
                inst._parent.replica.inventoryitem:IsHeldBy(ThePlayer) then
                ThePlayer:PushEvent("gotnewitem", data)
            end
            inst._parent:PushEvent("itemget", data)
        end
        if inst._itemspreview == nil then
			inst._itemspreview = GetProxyItems(inst)
        end
		inst._itemspreview[data.slot] = ProxyItem(data.item, inst)
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushItemLose(inst, data)
    if data ~= nil then
        if inst._parent ~= nil then
            inst._parent:PushEvent("itemlose", data)
        end
        if inst._itemspreview == nil then
			inst._itemspreview = GetProxyItems(inst)
        end
        inst._itemspreview[data.slot] = nil
        QueueRefresh(inst, TIMEOUT)
    end
end

local function PushStackSize(inst, inventory, item, stacksize, animatestacksize, activestacksize, animateactivestacksize, selfonly, sounddata)
	local stackable = item and item.replica.stackable or nil
	if stackable then
        if sounddata ~= nil then
            local player = ThePlayer
            local inventory = player ~= nil and player.replica.inventory ~= nil and player.replica.inventory.classified or nil
            local overflow = inventory ~= nil and inventory:GetOverflowContainer() or nil
            if overflow ~= nil and overflow.classified == inst then
                ThePlayer:PushEvent("gotnewitem", sounddata)
            end
        end
		local oldstacksize = stackable:StackSize()
		if stacksize or (activestacksize and selfonly) then
			stackable:SetPreviewStackSize(stacksize or activestacksize, inst, TIMEOUT)
		end
		if inventory and activestacksize and not selfonly then
			inventory:UseActiveItemProxy()
			stackable:SetPreviewStackSize(activestacksize, "activeitem", TIMEOUT)
		end

        item:PushEvent("stacksizepreview",
        {
            stacksize = stacksize,
            animatestacksize = animatestacksize,
            activestacksize = activestacksize,
            animateactivestacksize = animateactivestacksize,
            activecontainer = selfonly and inst._parent or nil,
        })
        if (stacksize ~= nil and stacksize ~= oldstacksize) or
            (activestacksize ~= nil and activestacksize ~= oldstacksize) then
            if inst._itemspreview == nil then
                for i, v in ipairs(inst._items) do
                    if v:value() == item then
						inst._itemspreview = GetProxyItems(inst)
                        break
                    end
                end
            end
            QueueRefresh(inst, TIMEOUT)
            if inventory ~= nil then
                inventory:QueueRefresh(TIMEOUT)
            end
        end
    end
end

--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

local function QueryActiveItem()
    local player = ThePlayer
    local inventory = player ~= nil and player.replica.inventory ~= nil and player.replica.inventory.classified or nil
    return inventory, inventory ~= nil and inventory:GetActiveItem() or nil, inventory == nil or inventory:IsBusy()
end

local function ReturnActiveItemToSlot(inst, slot)
    --inventory_classified:ReturnActiveItem will call PushNewActiveItem and SendRPCToServer
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local item = inst:GetItemInSlot(slot)
            if item == nil then
                local giveitem = SlotItem(active_item, slot)
                PushItemGet(inst, giveitem, true)
            elseif item.replica.stackable ~= nil and item.prefab == active_item.prefab and item:StackableSkinHack(active_item) then
                local stacksize = item.replica.stackable:StackSize() + active_item.replica.stackable:StackSize()
                local maxsize = item.replica.stackable:MaxSize()
                PushStackSize(inst, nil, item, math.min(stacksize, maxsize), true)
            end
        end
    end
end

local function PutOneOfActiveItemInSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local giveitem = SlotItem(active_item, slot)
            PushItemGet(inst, giveitem, true)
            PushStackSize(inst, inventory, active_item, 1, false, active_item.replica.stackable:StackSize() - 1, true)
            SendRPCToServer(RPC.PutOneOfActiveItemInSlot, slot, inst._parent)
        end
    end
end

local function PutAllOfActiveItemInSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local giveitem = SlotItem(active_item, slot)
            inventory:PushNewActiveItem()
            PushItemGet(inst, giveitem, true)
            SendRPCToServer(RPC.PutAllOfActiveItemInSlot, slot, inst._parent)
        end
    end
end

local function TakeActiveItemFromHalfOfSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and inventory ~= nil and active_item == nil then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil then
                local takeitem = SlotItem(item, slot)
                inventory:PushNewActiveItem(takeitem, inst, slot)
				local stackable = item.replica.stackable
				local stacksize = stackable:StackSize()
				local fullstacksize = math.min(stacksize, stackable:OriginalMaxSize()) --in case of overstacked when infinitestacksize is enabled
				local halfstacksize = math.floor(fullstacksize / 2)
                PushStackSize(inst, inventory, item, stacksize - halfstacksize, true, halfstacksize, false)
                SendRPCToServer(RPC.TakeActiveItemFromHalfOfSlot, slot, inst._parent)
            end
        end
    end
end

local function TakeActiveItemFromAllOfSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and inventory ~= nil and active_item == nil then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil then
                local takeitem = SlotItem(item, slot)
				local stackable = item.replica.stackable
				if stackable and stackable:IsOverStacked() then
					inventory:PushNewActiveItem(takeitem, inst, slot)
					local stacksize = stackable:StackSize()
					local fullstacksize = stackable:OriginalMaxSize()
					PushStackSize(inst, inventory, item, stacksize - fullstacksize, true, fullstacksize, false)
				else
					PushItemLose(inst, takeitem)
					inventory:PushNewActiveItem(takeitem, inst, slot)
				end
                SendRPCToServer(RPC.TakeActiveItemFromAllOfSlot, slot, inst._parent)
            end
        end
    end
end

local function AddOneOfActiveItemToSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil and item.prefab == active_item.prefab and item:StackableSkinHack(active_item) then
                PushStackSize(inst, nil, item, item.replica.stackable:StackSize() + 1, true)
                PushStackSize(inst, inventory, active_item, nil, nil, active_item.replica.stackable:StackSize() - 1, true)
                SendRPCToServer(RPC.AddOneOfActiveItemToSlot, slot, inst._parent)
            end
        end
    end
end

local function AddAllOfActiveItemToSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil and item.prefab == active_item.prefab and item:StackableSkinHack(active_item) then
                local stacksize = item.replica.stackable:StackSize() + active_item.replica.stackable:StackSize()
                local maxsize = item.replica.stackable:MaxSize()
                if stacksize <= maxsize then
                    inventory:PushNewActiveItem()
                    PushStackSize(inst, nil, item, stacksize, true)
                else
                    PushStackSize(inst, nil, item, maxsize, true)
                    PushStackSize(inst, inventory, active_item, stacksize - maxsize, false)
                end
                SendRPCToServer(RPC.AddAllOfActiveItemToSlot, slot, inst._parent)
            end
        end
    end
end

local function SwapActiveItemWithSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local item = inst:GetItemInSlot(slot)
			if item and not (item.replica.stackable and item.replica.stackable:IsOverStacked()) then
                local takeitem = SlotItem(item, slot)
                local giveitem = SlotItem(active_item, slot)
                PushItemLose(inst, takeitem)
                inventory:PushNewActiveItem(takeitem, inst, slot)
                PushItemGet(inst, giveitem)
                SendRPCToServer(RPC.SwapActiveItemWithSlot, slot, inst._parent)
            end
        end
    end
end

local function SwapOneOfActiveItemWithSlot(inst, slot)
    if not IsBusy(inst) then
        local inventory, active_item, busy = QueryActiveItem()
        if not busy and active_item ~= nil then
            local item = inst:GetItemInSlot(slot)
			if item and not (item.replica.stackable and item.replica.stackable:IsOverStacked()) then
                local takeitem = SlotItem(item, slot)
				local giveitem = SlotItem(active_item, slot)
                PushItemLose(inst, takeitem)
				PushItemGet(inst, giveitem, true)
				PushStackSize(inst, inventory, active_item, 1, false, active_item.replica.stackable:StackSize() - 1, true)
                inventory:ReceiveItem(takeitem)
                SendRPCToServer(RPC.SwapOneOfActiveItemWithSlot, slot, inst._parent)
            end
        end
    end
end

local function MoveItemFromAllOfSlot(inst, slot, container)
    if not IsBusy(inst) then
        local container_classified = container ~= nil and container.replica.inventory ~= nil and container.replica.inventory.classified or (container.replica.container ~= nil and container.replica.container.classified or nil)
        if container_classified ~= nil and not container_classified:IsBusy() then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil then
                if container_classified.ignoreoverflow ~= nil and container_classified:GetOverflowContainer() == (inst._parent and inst._parent.replica.container) then
                    container_classified.ignoreoverflow = true
                end

				local count = nil --nil for wholestack
				if not (container_classified.infinitestacksize and container_classified.infinitestacksize:value()) then
					local stackable = item.replica.stackable
					if stackable and stackable:IsOverStacked() then
						count = stackable:OriginalMaxSize()
					end
				end

                local remainder = nil
                local player = ThePlayer
                if player ~= nil and player.components.constructionbuilderuidata ~= nil and player.components.constructionbuilderuidata:GetContainer() == container then
                    local targetslot = player.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
                    if targetslot ~= nil then
						remainder = container_classified:ReceiveItem(item, count, targetslot)
                    end
                else
					remainder = container_classified:ReceiveItem(item, count)
                end

                if container_classified.ignoreoverflow then
                    container_classified.ignoreoverflow = false
                end

                if remainder ~= nil then
                    if remainder > 0 then
						PushStackSize(inst, nil, item, nil, nil, remainder, true, true)
                    else
                        local takeitem = SlotItem(item, slot)
                        PushItemLose(inst, takeitem)
                    end
                    SendRPCToServer(RPC.MoveItemFromAllOfSlot, slot, inst._parent, container.replica.container ~= nil and container or nil)
                end
            end
        end
    end
end

local function MoveItemFromHalfOfSlot(inst, slot, container)
    if not IsBusy(inst) then
        local container_classified = container ~= nil and container.replica.inventory ~= nil and container.replica.inventory.classified or (container.replica.container ~= nil and container.replica.container.classified or nil)
        if container_classified ~= nil and not container_classified:IsBusy() then
            local item = inst:GetItemInSlot(slot)
            if item ~= nil then
                if container_classified.ignoreoverflow ~= nil and container_classified:GetOverflowContainer() == (inst._parent and inst._parent.replica.container) then
                    container_classified.ignoreoverflow = true
                end

				local stackable = item.replica.stackable
				local fullstacksize =
					not (container_classified.infinitestacksize and container_classified.infinitestacksize:value()) and
					stackable:IsOverStacked() and
					stackable:OriginalMaxSize() or
					stackable:StackSize()

                local remainder = nil
                local player = ThePlayer
                if player ~= nil and player.components.constructionbuilderuidata ~= nil and player.components.constructionbuilderuidata:GetContainer() == container then
                    local targetslot = player.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab)
                    if targetslot ~= nil then
						remainder = container_classified:ReceiveItem(item, math.floor(fullstacksize / 2), targetslot)
                    end
                else
					remainder = container_classified:ReceiveItem(item, math.floor(fullstacksize / 2))
                end

                if container_classified.ignoreoverflow then
                    container_classified.ignoreoverflow = false
                end

                if remainder ~= nil then
                    if remainder > 0 then
                        PushStackSize(inst, nil, item, nil, nil, remainder, true, true)
                    else
                        local takeitem = SlotItem(item, slot)
                        PushItemLose(inst, takeitem)
                    end
                    SendRPCToServer(RPC.MoveItemFromHalfOfSlot, slot, inst._parent, container.replica.container ~= nil and container or nil)
                end
            end
        end
    end
end

local function ReceiveItem(inst, item, count, forceslot)
    if not IsBusy(inst) and (forceslot == nil or (forceslot >= 1 and forceslot <= #inst._items)) then
        local isstackable = item.replica.stackable ~= nil
        local originalstacksize = isstackable and item.replica.stackable:StackSize() or 1
        local container = inst._parent.replica.container
        if forceslot == nil and container ~= nil then
            forceslot = container:GetSpecificSlotForItem(item)
        end
        if not isstackable or container == nil or not container:AcceptsStacks() then
            for i = forceslot or 1, forceslot or #inst._items do
                if inst._items[i]:value() == nil then
                    local giveitem = SlotItem(item, i)
                    PushItemGet(inst, giveitem)
                    if originalstacksize > 1 then
                        PushStackSize(inst, nil, item, nil, nil, 1, false, true)
                        return originalstacksize - 1
                    else
                        return 0
                    end
                end
            end
        else
            local originalcount = count and math.min(count, originalstacksize) or originalstacksize
            count = originalcount
            local emptyslot = nil
            for i = forceslot or 1, forceslot or #inst._items do
                local slotitem = inst._items[i]:value()
                if slotitem == nil then
                    if emptyslot == nil then
                        emptyslot = i
                    end
                elseif slotitem.prefab == item.prefab and item:StackableSkinHack(slotitem) and
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
                    PushStackSize(inst, nil, slotitem, stacksize, true, nil, nil, nil, SlotItem(slotitem, i))
                    if count <= 0 then
                        break
                    end
                end
            end
            if count > 0 and emptyslot ~= nil then
                local giveitem = SlotItem(item, emptyslot)
                PushItemGet(inst, giveitem)
                if count ~= originalstacksize then
                    PushStackSize(inst, nil, item, nil, nil, count, false, true)
                end
                count = 0
            end
            if count ~= originalcount then
                return originalstacksize - (originalcount - count)
            end
        end
    end
end

local function ConsumeByName(inst, prefab, amount)
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
                PushStackSize(inst, nil, item, stacksize - amount, true)
                return
            end
        end
    end
end

local function TakeActionItem(inst, item, slot)
    if not IsBusy(inst) and inst:GetItemInSlot(slot) == item then
        local takeitem = SlotItem(item, slot)
        PushItemLose(inst, takeitem)
    end
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
    inst._itemspreview = nil

    --Network variables
	inst.infinitestacksize = net_bool(inst.GUID, "container.infinitestacksize")
    inst._items = {}
    inst._itemspool = {}
    inst._slottasks = nil

    for i = 1, containers.MAXITEMSLOTS do
        table.insert(inst._itemspool, net_entity(inst.GUID, "container._items["..tostring(i).."]", "items["..tostring(i).."]dirty"))
    end

    inst.entity:SetPristine()

    --Common interface
    inst.InitializeSlots = InitializeSlots

    if not TheWorld.ismastersim then
        --Client interface
        inst.OnEntityReplicated = OnEntityReplicated
        inst.IsHolding = IsHolding
        inst.GetItemInSlot = GetItemInSlot
        inst.GetItems = GetItems
        inst.IsEmpty = IsEmpty
        inst.IsFull = IsFull
        inst.Has = Has
        inst.HasItemWithTag = HasItemWithTag
        inst.ReturnActiveItemToSlot = ReturnActiveItemToSlot
        inst.PutOneOfActiveItemInSlot = PutOneOfActiveItemInSlot
        inst.PutAllOfActiveItemInSlot = PutAllOfActiveItemInSlot
        inst.TakeActiveItemFromHalfOfSlot = TakeActiveItemFromHalfOfSlot
        inst.TakeActiveItemFromAllOfSlot = TakeActiveItemFromAllOfSlot
        inst.AddOneOfActiveItemToSlot = AddOneOfActiveItemToSlot
        inst.AddAllOfActiveItemToSlot = AddAllOfActiveItemToSlot
        inst.SwapActiveItemWithSlot = SwapActiveItemWithSlot
		inst.SwapOneOfActiveItemWithSlot = SwapOneOfActiveItemWithSlot
        inst.MoveItemFromAllOfSlot = MoveItemFromAllOfSlot
        inst.MoveItemFromHalfOfSlot = MoveItemFromHalfOfSlot

        --Exposed for inventory
        inst.ReceiveItem = ReceiveItem
        inst.ConsumeByName = ConsumeByName
        inst.TakeActionItem = TakeActionItem
        inst.IsBusy = IsBusy

        --Delay net listeners until after initial values are deserialized
        inst:DoStaticTaskInTime(0, RegisterNetListeners)
        return inst
    end

    --Server interface
    inst.SetSlotItem = SetSlotItem

    inst.persists = false

    return inst
end

return Prefab("container_classified", fn)