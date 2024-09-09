local function onitem(self, item)
    if item ~= nil then
        self.inst:AddTag("inventoryitemholder_take")
        self.inst:RemoveTag("inventoryitemholder_give")
    else
        self.inst:AddTag("inventoryitemholder_give")
        self.inst:RemoveTag("inventoryitemholder_take")
    end
end

---------------------------------------------------------------------------------------------------------------

-- Hold an item that can be taken at any time.
-- Does NOT support perishable items at the moment.
-- The item drops when the structure finishes burning.

local InventoryItemHolder = Class(function(self, inst)
    self.inst = inst

    self.item = nil

    self.allowed_tags = nil

    self.onitemgivenfn = nil
    self.onitemtakenfn = nil
end,
nil,
{
    item = onitem,
})

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:SetAllowedTags(tags)
    self.allowed_tags = tags
end

function InventoryItemHolder:SetOnItemGivenFn(fn)
    self.onitemgivenfn = fn
end

function InventoryItemHolder:SetOnItemTakenFn(fn)
    self.onitemtakenfn = fn
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:IsHolding()
    return self.item ~= nil
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:CanGive(item, giver)
    return
            not self:IsHolding() and
            item.components.inventoryitem ~= nil and
            (
                self.allowed_tags == nil or item:HasOneOfTags(self.allowed_tags)
            )
end

function InventoryItemHolder:CanTake(taker)
    return self.item ~= nil and self.item:IsValid()
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:GiveItem(item, giver)
    if not self:CanGive(item, giver) then
        return false
    end

    self.item = item.components.inventoryitem:RemoveFromOwner(false) or item

    if self.item ~= nil and self.item:IsValid() then
        self.inst:AddChild(self.item)
        self.item:RemoveFromScene()
        self.item.Transform:SetPosition(0, 0, 0)
        self.item.components.inventoryitem:HibernateLivingItem()
        self.item:AddTag("outofreach")

        if self.onitemgivenfn ~= nil then
            self.onitemgivenfn(self.inst, self.item, giver)
        end
    else
        self.item = nil
    end

    return true
end

function InventoryItemHolder:TakeItem(taker)
    if not self:CanTake(taker) then
        return false
    end

    local pos = self.inst:GetPosition()

    self.inst:RemoveChild(self.item)

    self.item.components.inventoryitem:InheritWorldWetnessAtTarget(self.inst)

    self.item:RemoveTag("outofreach")

    if taker ~= nil and taker:IsValid() and taker.components.inventory ~= nil then
        taker.components.inventory:GiveItem(self.item, nil, pos)
    else
        self.item.Transform:SetPosition(pos:Get())
        self.item.components.inventoryitem:OnDropped(true)
    end

    self.item = nil

    if self.onitemtakenfn ~= nil then
        self.onitemtakenfn(self.inst, self.item, taker)
    end

    return true
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:OnSave()
    local data = {}
    local references = nil

    if self.item ~= nil and self.item:IsValid() and self.item.persists then
        data.item, references = self.item:GetSaveRecord()
    end

    return next(data) ~= nil and data or nil, references
end

function InventoryItemHolder:OnLoad(data, newents)
    if data.item ~= nil then
        local item = SpawnSaveRecord(data.item, newents)

        if item ~= nil then
            self:GiveItem(item, self.inst)
        end
    end
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:OnRemoveFromEntity()
    self:TakeItem()

    self.inst:RemoveTag("inventoryitemholder_give")
    self.inst:RemoveTag("inventoryitemholder_take")
end

---------------------------------------------------------------------------------------------------------------

function InventoryItemHolder:GetDebugString()
    return string.format(
        "Item:  %s   |   Allowed Tags:   %s",
        tostring(self.item),
        self.allowed_tags ~= nil and table.concat(self.allowed_tags, ", ") or "NO RESTRICTIONS"
    )
end

---------------------------------------------------------------------------------------------------------------

return InventoryItemHolder
