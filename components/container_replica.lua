local containers = require("containers")

local Container = Class(function(self, inst)
    self.inst = inst

    self._cannotbeopened = net_bool(inst.GUID, "container._cannotbeopened")
    self._isopen = false
    self._numslots = 0
    self.acceptsstacks = true
    self.usespecificslotsforitems = false
    self.issidewidget = false
    self.type = nil
    self.widget = nil
    self.itemtestfn = nil
    self.priorityfn = nil
    self.opentask = nil
    self.openers = {}
    self.opener = nil

    if TheWorld.ismastersim then
        self.classified = SpawnPrefab("container_classified")
        self.classified.entity:SetParent(inst.entity)
        self.classified.Network:SetClassifiedTarget(self.inst)

        --Server intercepts messages and forwards to clients via classified net vars
        self._onitemget = function(inst, data)
            self.classified:SetSlotItem(data.slot, data.item, data.src_pos)
            if inst.components.inventoryitem ~= nil and
                inst.components.inventoryitem.owner ~= nil and
                inst.components.inventoryitem.owner.HUD ~= nil then
                inst.components.inventoryitem.owner:PushEvent("refreshcrafting")
            end
        end
        self._onitemlose = function(inst, data)
            self.classified:SetSlotItem(data.slot)
            if inst.components.inventoryitem ~= nil and
                inst.components.inventoryitem.owner ~= nil and
                inst.components.inventoryitem.owner.HUD ~= nil then
                inst.components.inventoryitem.owner:PushEvent("refreshcrafting")
            end
        end
        inst:ListenForEvent("itemget", self._onitemget)
        inst:ListenForEvent("itemlose", self._onitemlose)
    else
        containers.widgetsetup(self)

        if self.classified == nil and inst.container_classified ~= nil then
            self.classified = inst.container_classified
            inst.container_classified.OnRemoveEntity = nil
            inst.container_classified = nil
            self:AttachClassified(self.classified)
        end
        if self.opener == nil and inst.container_opener ~= nil then
            self.opener = self.inst.container_opener
            inst.container_opener.OnRemoveEntity = nil
            inst.container_opener = nil
            self:AttachOpener(self.opener)
        end
    end
end)

local function SetOpener(self, opener)
    self.classified.Network:SetClassifiedTarget(opener or self.inst)
    if self.inst.components.container ~= nil then
        for k, v in pairs(self.inst.components.container.slots) do
            v.replica.inventoryitem:SetOwner(self.inst)
        end
    else
        --Shouldn't be reachable.
        assert(false)
    end
end

--------------------------------------------------------------------------

function Container:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified:Remove()
            self.classified = nil
            self.inst:RemoveEventCallback("itemget", self._onitemget)
            self.inst:RemoveEventCallback("itemlose", self._onitemlose)
            if self._onputininventory ~= nil then
                self.inst:RemoveEventCallback("onputininventory", self._onputininventory)
                self.inst:RemoveEventCallback("ondropped", self._ondropped)
                self._onputininventory = nil
                self._ondropped = nil
                self._owner = nil
            end
        else
            self.classified._parent = nil
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
    if self.opener and not TheWorld.ismastersim then
        self.opener._parent = nil
        self.inst:RemoveEventCallback("onremove", self.ondetachopener, self.opener)
        self:DetachOpener()
    elseif TheWorld.ismastersim then
        for player, opener in pairs(self.openers) do
            opener:Remove()
            self.openers[player] = nil
        end
    end
end

Container.OnRemoveEntity = Container.OnRemoveFromEntity

--------------------------------------------------------------------------
--Client triggers open/close based on receiving access to classified data
--------------------------------------------------------------------------

local function OnRefreshCrafting(inst)
    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        ThePlayer:PushEvent("refreshcrafting")
    end
end

local function OpenContainer(inst, self, snap)
    self.opentask = nil

    --V2C: don't animate to and from the backpack position
    --     when re-opening inventory as Werebeaver->Woodie
    local inv = snap and ThePlayer ~= nil and ThePlayer.HUD ~= nil and ThePlayer.HUD.controls.inv or nil
    snap = inv ~= nil and not inv.rebuild_pending

    self:Open(ThePlayer)
    OnRefreshCrafting(inst)

    if snap and inv.rebuild_pending then
        inv.rebuild_snapping = true
    end
end

function Container:AttachClassified(classified)
    self.classified = classified

    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)

    classified:InitializeSlots(self:GetNumSlots())
end

function Container:DetachClassified()
    self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
    self.classified = nil
    self.ondetachclassified = nil
end

function Container:AttachOpener(opener)
    self.opener = opener

    self.ondetachopener = function() self:DetachOpener() end
    self.inst:ListenForEvent("onremove", self.ondetachopener, opener)

    local inv = self.issidewidget and ThePlayer ~= nil and ThePlayer.HUD ~= nil and ThePlayer.HUD.controls.inv or nil
    self.opentask = self.inst:DoTaskInTime(0, OpenContainer, self, inv ~= nil and (not inv.shown or inv.rebuild_snapping))

    self.inst:ListenForEvent("itemget", OnRefreshCrafting)
    self.inst:ListenForEvent("itemlose", OnRefreshCrafting)
end

function Container:DetachOpener()
    self.inst:RemoveEventCallback("onremove", self.ondetachopener, self.opener)
    self.opener = nil
    self.ondetachopener = nil
    self.inst:RemoveEventCallback("itemget", OnRefreshCrafting)
    self.inst:RemoveEventCallback("itemlose", OnRefreshCrafting)
    OnRefreshCrafting(self.inst)
    self:Close()
end

function Container:AddOpener(opener)
    local opencount = self.inst.components.container.opencount
    if opencount == 1 then
        --standard logic.
        SetOpener(self, opener)
    elseif opencount > 1 then
        self.classified.Network:SetClassifiedTarget(nil)
        if self.inst.components.container ~= nil then
            for k, v in pairs(self.inst.components.container.slots) do
                v.replica.inventoryitem:SetOwner(self.inst)
            end
        end
    end
    self.openers[opener] = self.inst:SpawnChild("container_opener")
    self.openers[opener].Network:SetClassifiedTarget(opener)
end

function Container:RemoveOpener(opener)
    local opencount = self.inst.components.container.opencount
    if opencount == 0 then
        SetOpener(self, nil)
    elseif opencount == 1 then
        SetOpener(self, table.getkeys(self.inst.components.container.openlist)[1])
    elseif opencount > 1 then
        self.classified.Network:SetClassifiedTarget(nil)
        if self.inst.components.container ~= nil then
            for k, v in pairs(self.inst.components.container.slots) do
                v.replica.inventoryitem:SetOwner(self.inst)
            end
        end
    end
    if self.openers[opener] then
        self.openers[opener]:Remove()
        self.openers[opener] = nil
    end
end

--------------------------------------------------------------------------
--Server initialization requires param since prefab property is not set yet
--------------------------------------------------------------------------

function Container:WidgetSetup(prefab, data)
    containers.widgetsetup(self, prefab, data)
    if self.classified ~= nil then
        self.classified:InitializeSlots(self:GetNumSlots())
    end

    if self._onputininventory == nil then
        self._owner = nil
        self._ondropped = function(inst)
            if self._owner ~= nil then
                local owner = self._owner
                self._owner = nil
                if owner.HUD ~= nil then
                    owner:PushEvent("refreshcrafting")
                end
            end
        end
        self._onputininventory = function(inst, owner)
            self._ondropped(inst)
            self._owner = owner
            if owner ~= nil and owner.HUD ~= nil then
                owner:PushEvent("refreshcrafting")
            end
        end
        self.inst:ListenForEvent("onputininventory", self._onputininventory)
        self.inst:ListenForEvent("ondropped", self._ondropped)
    end
end

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

function Container:GetWidget()
    return self.widget
end

function Container:SetNumSlots(numslots)
    self._numslots = numslots
end

function Container:GetNumSlots()
    return self._numslots
end

function Container:SetCanBeOpened(canbeopened)
    self._cannotbeopened:set(not canbeopened)
end

function Container:CanBeOpened()
    return not self._cannotbeopened:value()
end

function Container:CanTakeItemInSlot(item, slot)
    return item ~= nil
        and item.replica.inventoryitem ~= nil
        and item.replica.inventoryitem:CanGoInContainer()
        and not item.replica.inventoryitem:CanOnlyGoInPocket()
        and not (GetGameModeProperty("non_item_equips") and item.replica.equippable ~= nil)
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
        and item.replica.inventoryitem ~= nil
        and item.replica.inventoryitem:CanGoInContainer()
        and not item.replica.inventoryitem:CanOnlyGoInPocket()
        and not (GetGameModeProperty("non_item_equips") and item.replica.equippable ~= nil)
        and (self:priorityfn(item))
end

function Container:AcceptsStacks()
    return self.acceptsstacks
end

function Container:IsSideWidget()
    return self.issidewidget
end

Container.SetOpener = function() end --depreciated, kept in case a mod calls this function.

function Container:IsOpenedBy(guy)
    if self.inst.components.container ~= nil then
        return self.inst.components.container:IsOpenedBy(guy)
    else
        return self.opener ~= nil and self._isopen and self.classified ~= nil and guy ~= nil and guy == ThePlayer
    end
end

function Container:IsHolding(item, checkcontainer)
    if self.inst.components.container ~= nil then
        return self.inst.components.container:IsHolding(item, checkcontainer)
    else
        return self.opener ~= nil and self.classified ~= nil and self.classified:IsHolding(item, checkcontainer)
    end
end

function Container:GetItemInSlot(slot)
    if self.inst.components.container ~= nil then
        return self.inst.components.container:GetItemInSlot(slot)
    else
        return self.opener ~= nil and self.classified ~= nil and self.classified:GetItemInSlot(slot) or nil
    end
end

function Container:GetItems()
    if self.inst.components.container ~= nil then
        return self.inst.components.container.slots
    else
        return self.opener ~= nil and self.classified ~= nil and self.classified:GetItems() or {}
    end
end

function Container:IsEmpty()
    if self.inst.components.container ~= nil then
        return self.inst.components.container:IsEmpty()
    else
        return self.opener ~= nil and self.classified ~= nil and self.classified:IsEmpty()
    end
end

function Container:IsFull()
    if self.inst.components.container ~= nil then
        return self.inst.components.container:IsFull()
    else
        return self.opener ~= nil and self.classified ~= nil and self.classified:IsFull()
    end
end

function Container:Has(prefab, amount)
    if self.inst.components.container ~= nil then
        return self.inst.components.container:Has(prefab, amount)
    elseif self.classified ~= nil and self.opener ~= nil then
        return self.classified:Has(prefab, amount)
    else
        return amount <= 0, 0
    end
end

function Container:HasItemWithTag(tag, amount)
    if self.inst.components.container ~= nil then
        return self.inst.components.container:HasTag(tag, amount)
    elseif self.classified ~= nil and self.opener ~= nil then
        return self.classified:HasItemWithTag(tag, amount)
    else
        return amount <= 0, 0
    end
end

function Container:Open(doer)
    if self.inst.components.container ~= nil then
        if self.opentask ~= nil then
            self.opentask:Cancel()
            self.opentask = nil
        end
        self.inst.components.container:Open(doer)
    elseif self.classified ~= nil and
        self.opentask == nil and
        doer ~= nil and
        doer == ThePlayer then
        if doer.HUD == nil then
            self._isopen = false
        elseif not self._isopen then
            doer.HUD:OpenContainer(self.inst, self:IsSideWidget())
            if self:IsSideWidget() then
                TheFocalPoint.SoundEmitter:PlaySound(self.inst.open_skin_sound or "dontstarve/wilson/backpack_open")
            end
            self._isopen = true
        end
    end
end

function Container:Close()
    if self.opentask ~= nil then
        self.opentask:Cancel()
        self.opentask = nil
    end
    if self.inst.components.container ~= nil then
        self.inst.components.container:Close()
    elseif self._isopen then
        if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
            ThePlayer.HUD:CloseContainer(self.inst, self:IsSideWidget())
            if self:IsSideWidget() then
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close")
            end
        end
        self._isopen = false
    end
end

function Container:IsBusy()
    return self.inst.components.container == nil and ((self.classified == nil or self.opener == nil) or self.classified:IsBusy())
end

--------------------------------------------------------------------------
--InvSlot click action handlers
--------------------------------------------------------------------------

--only the "client" should be calling these functions, even in cases where the client turns out to be the server, so using ThePlayer as opener should probably work out.

function Container:PutOneOfActiveItemInSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:PutOneOfActiveItemInSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:PutOneOfActiveItemInSlot(slot)
    end
end

function Container:PutAllOfActiveItemInSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:PutAllOfActiveItemInSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:PutAllOfActiveItemInSlot(slot)
    end
end

function Container:TakeActiveItemFromHalfOfSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:TakeActiveItemFromHalfOfSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:TakeActiveItemFromHalfOfSlot(slot)
    end
end

function Container:TakeActiveItemFromAllOfSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:TakeActiveItemFromAllOfSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:TakeActiveItemFromAllOfSlot(slot)
    end
end

function Container:AddOneOfActiveItemToSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:AddOneOfActiveItemToSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:AddOneOfActiveItemToSlot(slot)
    end
end

function Container:AddAllOfActiveItemToSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:AddAllOfActiveItemToSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:AddAllOfActiveItemToSlot(slot)
    end
end

function Container:SwapActiveItemWithSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:SwapActiveItemWithSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:SwapActiveItemWithSlot(slot)
    end
end

function Container:SwapOneOfActiveItemWithSlot(slot)
    if self.inst.components.container ~= nil then
        self.inst.components.container:SwapOneOfActiveItemWithSlot(slot, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:SwapOneOfActiveItemWithSlot(slot)
    end
end

function Container:MoveItemFromAllOfSlot(slot, container)
    if self.inst.components.container ~= nil then
        self.inst.components.container:MoveItemFromAllOfSlot(slot, container, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:MoveItemFromAllOfSlot(slot, container)
    end
end

function Container:MoveItemFromHalfOfSlot(slot, container)
    if self.inst.components.container ~= nil then
        self.inst.components.container:MoveItemFromHalfOfSlot(slot, container, ThePlayer)
    elseif self.classified ~= nil then
        self.classified:MoveItemFromHalfOfSlot(slot, container)
    end
end

--------------------------------------------------------------------------

return Container