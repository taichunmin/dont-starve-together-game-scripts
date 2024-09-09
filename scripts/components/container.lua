local containers = require("containers")

local function oncanbeopened(self, canbeopened)
    self.inst.replica.container:SetCanBeOpened(canbeopened)
end

local function onskipopensnd(self, skipopensnd)
    self.inst.replica.container:SetSkipOpenSnd(skipopensnd)
end

local function onskipclosesnd(self, skipclosesnd)
    self.inst.replica.container:SetSkipCloseSnd(skipclosesnd)
end

local function OnOwnerDespawned(inst)
    local container = inst.components.container
    if container ~= nil then
        for i = 1, container.numslots do
            local item = container.slots[i]
            if item ~= nil then
                item:PushEvent("player_despawn")
            end
        end
    end
end

local Container = Class(function(self, inst)
    self.inst = inst
    self.slots = {}
    self.numslots = 0
    self.canbeopened = true
    self.skipopensnd = false
    self.skipclosesnd = false
    --self.skipautoclose = false
    self.acceptsstacks = true
	makereadonly(self, "infinitestacksize")
    self.usespecificslotsforitems = false
    self.issidewidget = false
    self.type = nil
    self.widget = nil
    self.itemtestfn = nil
    self.priorityfn = nil

    self.openlist = {}
    self.opencount = 0

	--self.droponopen = false

    inst:ListenForEvent("player_despawn", OnOwnerDespawned)

    --the current opener that has performed an action, can be nil or incorrect, verify before using this!!!
    --self.currentuser = nil


    --Hacky flags for altering behaviour when moving items between containers
    self.ignoresound = false
	self.ignoreoverstacked = false
end,
nil,
{
    canbeopened = oncanbeopened,
    skipopensnd = onskipopensnd,
    skipclosesnd = onskipclosesnd,
})

local widgetprops =
{
    "numslots",
    "acceptsstacks",
    "usespecificslotsforitems",
    "issidewidget",
    "type",
    "widget",
    "itemtestfn",
    "priorityfn",
    "openlimit"
}

function Container:WidgetSetup(prefab, data)
    for i, v in ipairs(widgetprops) do
        removesetter(self, v)
    end

    containers.widgetsetup(self, prefab, data)
    self.inst.replica.container:WidgetSetup(prefab, data)

    for i, v in ipairs(widgetprops) do
        makereadonly(self, v)
    end
end

function Container:GetWidget()
    return self.widget
end

function Container:NumItems()
    local num = 0
    for k,v in pairs(self.slots) do
        num = num + 1
    end

    return num
end

function Container:IsFull()
    local items = 0
    for k, v in pairs(self.slots) do
        items = items + 1
    end

    return items >= self.numslots
end

function Container:IsEmpty()
    return next(self.slots) == nil
end

function Container:SetNumSlots(numslots)
    assert(numslots >= self.numslots)
    self.numslots = numslots
end

function Container:DropItemBySlot(slot, drop_pos, keepoverstacked)
	local item = self:RemoveItemBySlot(slot, keepoverstacked)
    if item ~= nil then
        drop_pos = drop_pos or self.inst:GetPosition()

        item.Transform:SetPosition(drop_pos:Get())
        if item.components.inventoryitem ~= nil then
            item.components.inventoryitem:OnDropped(true)
        end
        item.prevcontainer = nil
        item.prevslot = nil
        self.inst:PushEvent("dropitem", { item = item })
    end
	return item
end

function Container:DropEverythingWithTag(tag, drop_pos, keepoverstacked)
    local containers = {}

    for i = 1, self.numslots do
        local item = self.slots[i]
        if item ~= nil then
            if item:HasTag(tag) then
				self:DropItemBySlot(i, drop_pos, keepoverstacked)
            elseif item.components.container ~= nil then
                table.insert(containers, item)
            end
        end
    end

    for i, v in ipairs(containers) do
		v.components.container:DropEverythingWithTag(tag, drop_pos, keepoverstacked)
    end
end

function Container:DropEverything(drop_pos, keepoverstacked)
    for i = 1, self.numslots do
		self:DropItemBySlot(i, drop_pos, keepoverstacked)
    end
end

function Container:DropEverythingUpToMaxStacks(maxstacks, drop_pos)
	local stacks = 0
	while next(self.slots) do
		for k, v in pairs(self.slots) do
			self:DropItemBySlot(k, drop_pos, true)
			stacks = stacks + 1
			if stacks >= maxstacks then
				return
			end
		end
	end
end

--V2C: this drops single, so no need to add "keepoverstacked"
function Container:DropItem(itemtodrop)
	--@V2C NOTE: not supported when using container_proxy because this
	--           will be the pocket dimension_container at (0, 0, 0)
	local x, y, z = self.inst.Transform:GetWorldPosition()
	self:DropItemAt(itemtodrop, x, y, z)
end

function Container:DropOverstackedExcess(item)
	local maxsize = item.components.stackable and item.components.stackable.originalmaxsize or nil
	if maxsize then
		local num = item.components.stackable:StackSize()
		if num > maxsize then
			local x, y, z = self.inst.Transform:GetWorldPosition()
			repeat
				local excess = item.components.stackable:Get(math.min(num - maxsize, maxsize))
				excess.Transform:SetPosition(x, y, z)
				if excess.components.inventoryitem then
					excess.components.inventoryitem:OnDropped(true)
				end
				num = item.components.stackable:StackSize()
			until num <= maxsize
		end
	end
end

--V2C: this drops single, so no need to add "keepoverstacked"
function Container:DropItemAt(itemtodrop, x, y, z)
	if Vector3.is_instance(x) then
		x, y, z = x:Get()
	end
    local item = self:RemoveItem(itemtodrop)
    if item then
		item.Transform:SetPosition(x, y, z)
        if item.components.inventoryitem then
            item.components.inventoryitem:OnDropped(true)
        end
        item.prevcontainer = nil
        item.prevslot = nil
        self.inst:PushEvent("dropitem", {item = item})
    end
end

function Container:CanTakeItemInSlot(item, slot)
    return item ~= nil
        and item.components.inventoryitem ~= nil
        and item.components.inventoryitem.cangoincontainer
        and not item.components.inventoryitem.canonlygoinpocket
        and (slot == nil or (slot >= 1 and slot <= self.numslots))
        and not (GetGameModeProperty("non_item_equips") and item.components.equippable ~= nil)
        and (self.itemtestfn == nil or self:itemtestfn(item, slot))
end

function Container:GetSpecificSlotForItem(item)
    if self.usespecificslotsforitems and self.itemtestfn ~= nil then
        for i = 1, self:GetNumSlots() do
            if self:itemtestfn(item, i) then
                return i
            end
        end
    end
end

function Container:ShouldPrioritizeContainer(item)
    if not self.priorityfn then
        return false
    end
    return item ~= nil
        and item.components.inventoryitem ~= nil
        and item.components.inventoryitem.cangoincontainer
        and not item.components.inventoryitem.canonlygoinpocket
        and not (GetGameModeProperty("non_item_equips") and item.components.equippable ~= nil)
        and (self:priorityfn(item))
end

function Container:AcceptsStacks()
    return self.acceptsstacks
end

function Container:IsSideWidget()
    return self.issidewidget
end

function Container:DestroyContents(onpredestroyitemcallbackfn)
    for k = 1, self.numslots do
        local item = self:RemoveItemBySlot(k)
        if item ~= nil then
            if onpredestroyitemcallbackfn ~= nil then
                onpredestroyitemcallbackfn(self.inst, item)
            end
            if item:IsValid() then
                item:Remove()
            end
        end
    end
end

function Container:DestroyContentsConditionally(filterfn, onpredestroyitemcallbackfn)
    if filterfn == nil then
        -- NOTES(JBK): Revert to unconditionally.
        self:DestroyContents(onpredestroyitemcallbackfn)
        return
    end

    for k = 1, self.numslots do
        local testitem = self.slots[k]
        if testitem and filterfn(self.inst, testitem) then
            local item = self:RemoveItemBySlot(k)
            if item ~= nil then
                if onpredestroyitemcallbackfn ~= nil then
                    onpredestroyitemcallbackfn(self.inst, item)
                end
                if item:IsValid() then
                    item:Remove()
                end
            end
        end
    end
end

-- Check how many of an item we can accept from its stack.
function Container:CanAcceptCount(item, maxcount)
    local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)

    if stacksize <= 0 then
        return 0
    end

    local acceptcount = 0

    --Check for empty space in the container.
    for k = 1, self.numslots do
        local v = self.slots[k]

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

    return acceptcount
end

function Container:GiveItem(item, slot, src_pos, drop_on_fail)
    if item == nil then
        return false
    elseif item.components.inventoryitem ~= nil and self:CanTakeItemInSlot(item, slot) then
        if slot == nil then
            slot = self:GetSpecificSlotForItem(item)
        end

        --try to burn off stacks if we're just dumping it in there
        if item.components.stackable ~= nil and self.acceptsstacks then
            --Added this for when we want to dump a stack back into a
            --specific spot (e.g. moving half a stack failed, so we
            --need to dump the leftovers back into the original stack)
            if slot ~= nil and slot <= self.numslots then
                local other_item = self.slots[slot]
                if other_item ~= nil and other_item.prefab == item.prefab and other_item.skinname == item.skinname and not other_item.components.stackable:IsFull() then
                    if self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                        self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = slot })
                    end

                    item = other_item.components.stackable:Put(item, src_pos)
                    if item == nil then
                        return true
                    end

                    slot = self:GetSpecificSlotForItem(item)
                end
            end

            if slot == nil then
                for k = 1, self.numslots do
                    local other_item = self.slots[k]
                    if other_item and other_item.prefab == item.prefab and other_item.skinname == item.skinname and not other_item.components.stackable:IsFull() then
                        if self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                            self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = k })
                        end

                        item = other_item.components.stackable:Put(item, src_pos)
                        if item == nil then
                            return true
                        end
                    end
                end
            end
        end

        local in_slot = nil
        if slot ~= nil and slot <= self.numslots and not self.slots[slot] then
            in_slot = slot
        elseif not self.usespecificslotsforitems and self.numslots > 0 then
            for i = 1, self.numslots do
                if not self.slots[i] then
                    in_slot = i
                    break
                end
            end
        end

        if in_slot then
            --weird case where we are trying to force a stack into a non-stacking container. this should probably have been handled earlier, but this is a failsafe
            if not self.acceptsstacks and item.components.stackable and item.components.stackable:StackSize() > 1 then
                item = item.components.stackable:Get()
                self.slots[in_slot] = item
                item.components.inventoryitem:OnPutInInventory(self.inst)
                self.inst:PushEvent("itemget", { slot = in_slot, item = item, src_pos = src_pos, })
                return false
            end

            self.slots[in_slot] = item
			if self.infinitestacksize and item.components.stackable then
				item.components.stackable:SetIgnoreMaxSize(true)
			end
            item.components.inventoryitem:OnPutInInventory(self.inst)
            self.inst:PushEvent("itemget", { slot = in_slot, item = item, src_pos = src_pos })

            if not self.ignoresound and self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = in_slot })
            end

            return true
        end
    end

    --default to true if nil
    if drop_on_fail ~= false then
        --@V2C NOTE: not supported when using container_proxy
		self:DropOverstackedExcess(item)
        item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        if item.components.inventoryitem ~= nil then
            item.components.inventoryitem:OnDropped(true)
        end
    end
    return false
end

function Container:RemoveItemBySlot(slot, keepoverstacked)
	local item = slot and self.slots[slot] or nil
	if item then
		return self:RemoveItem_Internal(item, slot, true, keepoverstacked)
	end
end

function Container:RemoveAllItems()
    local collected_items = {}
    for i = 1, self.numslots do
        local item = self:RemoveItemBySlot(i)
        table.insert(collected_items, item)
    end

    return collected_items
end

function Container:GetNumSlots()
    return self.numslots
end

function Container:GetItemInSlot(slot)
    if slot and self.slots[slot] then
        return self.slots[slot]
    end
end

function Container:GetItemSlot(item)
    for k,v in pairs(self.slots) do
        if item == v then
            return k
        end
    end
end

function Container:GetAllItems()
    local collected_items = {}
    for k,v in pairs(self.slots) do
        if v ~= nil then
            table.insert(collected_items, v)
        end
    end

    return collected_items
end

function Container:Open(doer)
    if doer ~= nil and self.openlist[doer] == nil then
        if not self.skipautoclose then
            self.inst:StartUpdatingComponent(self)
        end
        local inventory = doer.components.inventory
        if inventory ~= nil then
            for k, v in pairs(inventory.opencontainers) do
                if k.prefab == self.inst.prefab or k.components.container.type == self.type then
                    k.components.container:Close(doer)
                end
            end

            inventory.opencontainers[self.inst] = true
        end
        self.openlist[doer] = true
        self.opencount = self.opencount + 1
        self.inst.replica.container:AddOpener(doer)

        if doer.HUD ~= nil then
            doer.HUD:OpenContainer(self.inst, self:IsSideWidget())
            doer:PushEvent("refreshcrafting")
			if not self.inst.replica.container:ShouldSkipOpenSnd() then
                -- FIXME(JBK): The changes here need a way to tie the self.widget back to the entity to GetSkinBuild from for other containers like pillar and bundle wraps.
                -- Replicate to the other three spots in container and container_replica.
				local skinsound = self.inst.AnimState and SKIN_SOUND_FX[self.inst.AnimState:GetSkinBuild()] or nil
				TheFocalPoint.SoundEmitter:PlaySound(
					skinsound and skinsound.open_ui or
					(self.widget ~= nil and self.widget.opensound) or
					(self:IsSideWidget() and "dontstarve/wilson/backpack_open") or
					"dontstarve/HUD/Together_HUD/container_open"
				)
            end
        elseif self.widget ~= nil
            and self.widget.buttoninfo ~= nil
            and doer.components.playeractionpicker ~= nil then
            doer.components.playeractionpicker:RegisterContainer(self.inst)
        end

        self.inst:PushEvent("onopen", {doer = doer})

        if self.onopenfn ~= nil and self.opencount == 1 then
            self.onopenfn(self.inst, {doer = doer})
        end

        if self.onanyopenfn ~= nil then
            self.onanyopenfn(self.inst, {doer = doer})
        end
    end
end

Container.Close_Items_Internal = function(item, doer)
    if item.components.container ~= nil then
        item.components.container:Close(doer)
    end
end

function Container:Close(doer)
    self:ForEachItem(Container.Close_Items_Internal, doer)
    if doer == nil then
        for opener, _ in pairs(self.openlist) do
            self:Close(opener)
        end
        return
    end
    if doer ~= nil and self.openlist[doer] ~= nil then
        self.openlist[doer] = nil
        self.opencount = self.opencount - 1
        self.inst.replica.container:RemoveOpener(doer)

        if self.opencount == 0 then
            self.inst:StopUpdatingComponent(self)
        end

        if doer.HUD ~= nil then
            doer.HUD:CloseContainer(self.inst, self:IsSideWidget())
            doer:PushEvent("refreshcrafting")
            if not self.inst.replica.container:ShouldSkipCloseSnd() then
				local skinsound = self.inst.AnimState and SKIN_SOUND_FX[self.inst.AnimState:GetSkinBuild()] or nil
				TheFocalPoint.SoundEmitter:PlaySound(
					skinsound and skinsound.close_ui or
					(self.widget ~= nil and self.widget.closesound) or
					(self:IsSideWidget() and "dontstarve/wilson/backpack_close") or
					"dontstarve/HUD/Together_HUD/container_close"
				)
            end
        elseif doer.components.playeractionpicker ~= nil then
            doer.components.playeractionpicker:UnregisterContainer(self.inst)
        end

        if doer.components.inventory ~= nil then
            doer.components.inventory.opencontainers[self.inst] = nil
        end

        if self.onclosefn ~= nil and self.opencount == 0 then
            self.onclosefn(self.inst, doer)
        end

        if self.onanyclosefn ~= nil then
            self.onanyclosefn(self.inst, {doer = doer})
        end

        self.inst:PushEvent("onclose", {doer = doer})
    end
end

function Container:IsOpen()
    return self.opencount > 0
end

function Container:IsOpenedBy(guy)
    return self.openlist[guy]
end

function Container:IsOpenedByOthers(guy)
    return (self.opencount - (self.openlist[guy] and 1 or 0)) > 0
end

function Container:CanOpen()
    return self.openlimit == nil or self.opencount < self.openlimit
end

function Container:GetOpeners()
    local openers = {}
    for opener in pairs(self.openlist) do
        table.insert(openers, opener)
    end
    return openers
end

local function CheckItem(item, target, checkcontainer)
    return target ~= nil
        and (item == target
            or (checkcontainer and
                target.replica.container ~= nil and
                target.replica.container:IsHolding(item, checkcontainer)))
end

function Container:IsHolding(item, checkcontainer)
    for k, v in pairs(self.slots) do
        if CheckItem(item, v, checkcontainer) then
            return true
        end
    end
end

function Container:FindItem(fn)
    for k,v in pairs(self.slots) do
        if fn(v) then
            return v
        end
    end
end

function Container:FindItems(fn)
    local items = {}

    for k,v in pairs(self.slots) do
        if fn(v) then
            table.insert(items, v)
        end
    end

    return items
end

function Container:ForEachItem(fn, ...)
    for k,v in pairs(self.slots) do
        fn(v, ...)
    end
end

function Container:Has(item, amount, iscrafting)
    local num_found = 0
    for k,v in pairs(self.slots) do
		if v ~= nil and v.prefab == item and not (iscrafting and v:HasTag("nocrafting")) then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    return num_found >= amount, num_found
end

function Container:HasItemThatMatches(fn, amount)
	local num_found = 0
	for k, v in pairs(self.slots) do
		if fn(v) then
			num_found = num_found + (v.components.stackable and v.components.stackable:StackSize() or 1)
		end
	end
	return num_found >= amount, num_found
end

function Container:HasItemWithTag(tag, amount)
    local num_found = 0
    for k,v in pairs(self.slots) do
        if v and v:HasTag(tag) then
            if v.components.stackable ~= nil then
                num_found = num_found + v.components.stackable:StackSize()
            else
                num_found = num_found + 1
            end
        end
    end

    return num_found >= amount, num_found
end

function Container:GetItemsWithTag(tag)
    local items = {}
    for k,v in pairs(self.slots) do
        if v and v:HasTag(tag) then
            table.insert(items, v)
        end
    end

    return items
end

function Container:GetItemByName(item, amount)
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

    for k = 1,self.numslots do
        local v = self.slots[k]
        total_num_found = total_num_found + tryfind(v)

        if total_num_found >= amount then
            break
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

function Container:GetCraftingIngredient(item, amount, reverse_search_order)
    local items = {}
    for i = 1, self.numslots do
        local v = self.slots[i]
		if v ~= nil and v.prefab == item and not v:HasTag("nocrafting") then
            table.insert(items, {
                item = v,
				stacksize = v.components.stackable and v.components.stackable:StackSize() or 1,
                slot = reverse_search_order and (self.numslots - (i - 1)) or i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)

    local crafting_items = {}
    local total_num_found = 0
    for i, v in ipairs(items) do
        local stacksize = math.min(v.stacksize, amount - total_num_found)
        crafting_items[v.item] = stacksize
        total_num_found = total_num_found + stacksize
        if total_num_found >= amount then
            break
        end
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

function Container:ConsumeByName(item, amount)
    if amount <= 0 then
        return
    end

    for k, v in pairs(self.slots) do
        if v.prefab == item then
            amount = amount - tryconsume(self, v, amount)
            if amount <= 0 then
                return
            end
        end
    end
end

function Container:OnSave()
    local data = {items= {}}
    local references = {}
	local refs
    for k,v in pairs(self.slots) do
        if v:IsValid() and v.persists then --only save the valid items
            data.items[k], refs = v:GetSaveRecord()
            if refs then
                for k,v in pairs(refs) do
                    table.insert(references, v)
                end
            end
        end
    end
    return data, references
end

function Container:OnLoad(data, newents)
    if data.items then
        for k,v in pairs(data.items) do
            local inst = SpawnSaveRecord(v, newents)
            if inst then
                self:GiveItem(inst, k)
            end
        end
    end
end

--V2C: ***WARNING*** checkallcontainers not implemented here
--     parameter exists to keep interface same as inventory component
function Container:RemoveItem(item, wholestack, _checkallcontainers_, keepoverstacked)
	if item then
		local slot = self:GetItemSlot(item)
		if slot then
			return self:RemoveItem_Internal(item, slot, wholestack, keepoverstacked)
		end
		return item
	end
end

function Container:RemoveItem_Internal(item, slot, wholestack, keepoverstacked)
	--assert(item == self.slots[slot])

	local stackable = item.components.stackable
	if stackable and stackable:IsStack() then
		local num =
			(not wholestack and 1) or
			(keepoverstacked and stackable:IsOverStacked() and stackable.originalmaxsize) or
			nil
		if num then
			local dec = stackable:Get(num)
			dec.components.inventoryitem:OnRemoved()
			dec.prevslot = slot
			dec.prevcontainer = self
			return dec
		end
	end

	self.slots[slot] = nil
	if self.infinitestacksize and stackable then
		if not self.ignoreoverstacked then
			self:DropOverstackedExcess(item)
		end
		stackable:SetIgnoreMaxSize(false)
	end
	self.inst:PushEvent("itemlose", { slot = slot, prev_item = item })
	item.components.inventoryitem:OnRemoved()
	item.prevslot = slot
	item.prevcontainer = self

    return item
end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------

function Container:OnUpdate(dt)
    if self.opencount == 0 then
        self.inst:StopUpdatingComponent(self)
    else
        --attempt to close the chest for all players who have the chest opened who meet the requirements for closing it.
        for opener, _ in pairs(self.openlist) do
			if self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() == opener then
				--V2C: special case handling for players who can open "portablestorage" containers from inventory without dropping
				if self.inst:HasTag("portablestorage") and not (opener.sg and opener.sg:HasStateTag("keep_pocket_rummage")) then
					self:Close(opener)
					if opener.sg then
						opener.sg:HandleEvent("ms_closeportablestorage", { item = self.inst })
					end
				end
			elseif (opener.components.rider and opener.components.rider:IsRiding())
				or not (opener:IsValid() and opener:IsNear(self.inst, 3) and CanEntitySeeTarget(opener, self.inst))
			then
				self:Close(opener)
            end
        end
    end
end

Container.OnRemoveEntity = Container.Close
Container.OnRemoveFromEntity = Container.Close


--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

local function QueryActiveItem(self, opener)
    local inventory = opener ~= nil and opener.components.inventory or nil
    return inventory, inventory ~= nil and inventory:GetActiveItem() or nil
end

function Container:PutOneOfActiveItemInSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    if active_item ~= nil and
        self:GetItemInSlot(slot) == nil and
        self:CanTakeItemInSlot(active_item, slot) and
        active_item.components.stackable ~= nil and
        active_item.components.stackable:IsStack() then

        self.currentuser = opener

        self.ignoresound = true
        self:GiveItem(active_item.components.stackable:Get(1), slot)
        self.ignoresound = false

        self.currentuser = nil
    end
end

function Container:PutAllOfActiveItemInSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil then
        if item ~= nil then
            self:SwapActiveItemWithSlot(slot, opener)
        elseif self:CanTakeItemInSlot(active_item, slot) and
            (self:AcceptsStacks() or
            active_item.components.stackable == nil or
            not active_item.components.stackable:IsStack()) then

            self.currentuser = opener

            inventory:RemoveItem(active_item, true)
            self.ignoresound = true
            self:GiveItem(active_item, slot)
            self.ignoresound = false

            self.currentuser = nil
        end
    end
end

function Container:TakeActiveItemFromHalfOfSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and
        active_item == nil and
        inventory ~= nil and
        item.components.stackable ~= nil and
        item.components.stackable:IsStack() then

        self.currentuser = opener

		local fullstacksize = item.components.stackable:IsOverStacked() and item.components.stackable.originalmaxsize or item.components.stackable:StackSize()
		local halfstack = item.components.stackable:Get(math.floor(fullstacksize / 2))
        halfstack.prevslot = slot
        halfstack.prevcontainer = self
        inventory:GiveActiveItem(halfstack)

        self.currentuser = nil
    end
end

function Container:TakeActiveItemFromAllOfSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and
        active_item == nil and
        inventory ~= nil then

        self.currentuser = opener

		if item.components.stackable and item.components.stackable:IsOverStacked() then
			local fullstack = item.components.stackable:Get(item.components.stackable.originalmaxsize)
			fullstack.prevslot = slot
			fullstack.prevcontainer = self
			inventory:GiveActiveItem(fullstack)
		else
			self:RemoveItemBySlot(slot)
			inventory:GiveActiveItem(item)
		end

        self.currentuser = nil
    end
end

function Container:AddOneOfActiveItemToSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        item.prefab == active_item.prefab and item.skinname == active_item.skinname and
        item.components.stackable ~= nil and
        self:AcceptsStacks() and
        active_item.components.stackable ~= nil and
        active_item.components.stackable:IsStack() and
        not item.components.stackable:IsFull() then

        self.currentuser = opener

        item.components.stackable:Put(active_item.components.stackable:Get(1))

        self.currentuser = nil
    end
end

function Container:AddAllOfActiveItemToSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        item.prefab == active_item.prefab and item.skinname == active_item.skinname and
        item.components.stackable ~= nil and
        self:AcceptsStacks() then

        self.currentuser = opener

        local leftovers = item.components.stackable:Put(active_item)
        inventory:SetActiveItem(leftovers)

        self.currentuser = nil
    end
end

function Container:SwapActiveItemWithSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)
    if active_item ~= nil then
        if item == nil then
            self:PutAllOfActiveItemInSlot(slot, opener)
		elseif self:CanTakeItemInSlot(active_item, slot)
			and not (item.prefab == active_item.prefab and
					item.skinname == active_item.skinname and
					item.components.stackable and
					self:AcceptsStacks())
			and not (active_item.components.stackable and
					active_item.components.stackable:IsStack() and
					not self:AcceptsStacks())
			and not (item.components.stackable and
					item.components.stackable:IsOverStacked())
		then
            self.currentuser = opener

            inventory:RemoveItem(active_item, true)
            self:RemoveItemBySlot(slot)
            self:GiveItem(active_item, slot)
            inventory:GiveActiveItem(item)

            self.currentuser = nil
        end
    end
end

function Container:SwapOneOfActiveItemWithSlot(slot, opener)
    local inventory, active_item = QueryActiveItem(self, opener)
    local item = self:GetItemInSlot(slot)

    if active_item ~= nil and
        item ~= nil and
        self:CanTakeItemInSlot(active_item, slot) and
        not (item.prefab == active_item.prefab and item.skinname == active_item.skinname and item.components.stackable ~= nil) and
		(active_item.components.stackable and active_item.components.stackable:IsStack()) and
		not (item.components.stackable and item.components.stackable:IsOverStacked())
	then
        self.currentuser = opener

        active_item = inventory:RemoveItem(active_item, false)
        self:RemoveItemBySlot(slot)
        self:GiveItem(active_item, slot)
        inventory:GiveItem(item, nil, self.inst:GetPosition())

        self.currentuser = nil
    end
end

function Container:MoveItemFromAllOfSlot(slot, container, opener)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and container ~= nil then
        container = container.components.container or container.components.inventory
        if container ~= nil and container:IsOpenedBy(opener) then

            self.currentuser = opener
            container.currentuser = opener

            local targetslot =
                opener.components.constructionbuilderuidata ~= nil and
                opener.components.constructionbuilderuidata:GetContainer() == container.inst and
                opener.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab) or
                nil

            if container:CanTakeItemInSlot(item, targetslot) then
				local shouldignoresound = false
				if not (item.components.stackable and item.components.stackable:IsOverStacked()) then
					item = self:RemoveItemBySlot(slot)
				elseif container.infinitestacksize then
					--target container can accept overstacked items!
					self.ignoreoverstacked = true
					item = self:RemoveItemBySlot(slot)
					self.ignoreoverstacked = false
				else
					item = item.components.stackable:Get(item.components.stackable.originalmaxsize)
					shouldignoresound = true
				end
                item.prevcontainer = nil
                item.prevslot = nil

                --Hacks for altering normal inventory:GiveItem() behaviour
                if container.ignoreoverflow ~= nil and container:GetOverflowContainer() == self then
                    container.ignoreoverflow = true
                end
                if container.ignorefull ~= nil then
                    container.ignorefull = true
                end

                if not container:GiveItem(item, targetslot, nil, false) then
					self.ignoresound = shouldignoresound
                    self:GiveItem(item, slot, nil, true)
					self.ignoresound = false
                end

                --Hacks for altering normal inventory:GiveItem() behaviour
                if container.ignoreoverflow then
                    container.ignoreoverflow = false
                end
                if container.ignorefull then
                    container.ignorefull = false
                end
            end

            self.currentuser = nil
            container.currentuser = nil
        end
    end
end

function Container:MoveItemFromHalfOfSlot(slot, container, opener)
    local item = self:GetItemInSlot(slot)
    if item ~= nil and container ~= nil then
        container = container.components.container or container.components.inventory
        if container ~= nil and
            container:IsOpenedBy(opener) and
            item.components.stackable ~= nil and
            item.components.stackable:IsStack() then

            self.currentuser = opener
            container.currentuser = opener

            local targetslot =
                opener.components.constructionbuilderuidata ~= nil and
                opener.components.constructionbuilderuidata:GetContainer() == container.inst and
                opener.components.constructionbuilderuidata:GetSlotForIngredient(item.prefab) or
                nil

            if container:CanTakeItemInSlot(item, targetslot) then
				local fullstacksize = not container.infinitestacksize and item.components.stackable:IsOverStacked() and item.components.stackable.originalmaxsize or item.components.stackable:StackSize()
				local halfstack = item.components.stackable:Get(math.floor(fullstacksize / 2))
                halfstack.prevcontainer = nil
                halfstack.prevslot = nil

                --Hacks for altering normal inventory:GiveItem() behaviour
                if container.ignoreoverflow ~= nil and container:GetOverflowContainer() == self then
                    container.ignoreoverflow = true
                end
                if container.ignorefull ~= nil then
                    container.ignorefull = true
                end

                if not container:GiveItem(halfstack, targetslot) then
                    self.ignoresound = true
                    self:GiveItem(halfstack, slot, nil, true)
                    self.ignoresound = false
                end

                --Hacks for altering normal inventory:GiveItem() behaviour
                if container.ignoreoverflow then
                    container.ignoreoverflow = false
                end
                if container.ignorefull then
                    container.ignorefull = false
                end
            end

            self.currentuser = nil
            container.currentuser = nil
        end
    end
end

function Container:ReferenceAllItems()
    local items = {}
    for i=1,self.numslots do
        if self.slots[i] ~= nil then
            table.insert(items, self.slots[i])
        end
    end
    return items
end

function Container:EnableInfiniteStackSize(enable)
	local _ = rawget(self, "_") --see class.lua for property setters implementation
	if enable then
		if not _.infinitestacksize[1] then
			_.infinitestacksize[1] = true
			for i = 1, self.numslots do
				local item = self.slots[i]
				if item and item.components.stackable then
					item.components.stackable:SetIgnoreMaxSize(true)
				end
			end
			self.inst.replica.container:EnableInfiniteStackSize(true)
		end
	elseif _.infinitestacksize[1] then
		_.infinitestacksize[1] = nil
		local x, y, z = self.inst.Transform:GetWorldPosition()
		for i = 1, self.numslots do
			local item = self.slots[i]
			if item and item.components.stackable then
				self:DropOverstackedExcess(item)
				item.components.stackable:SetIgnoreMaxSize(false)
			end
			self.inst.replica.container:EnableInfiniteStackSize(false)
		end
	end
end

return Container
