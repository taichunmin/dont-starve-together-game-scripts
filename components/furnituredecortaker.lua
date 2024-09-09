local function onenabled(self, enabled)
    if enabled then
        self.inst:AddTag("furnituredecortaker")
    else
        self.inst:RemoveTag("furnituredecortaker")
    end
end

local function ondecoritem(self, decoritem)
    if decoritem then
        self.inst:AddTag("hasfurnituredecoritem")
    else
        self.inst:RemoveTag("hasfurnituredecoritem")
    end
end

local FurnitureDecorTaker = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.decor_item = nil

    --self.abletoaccepttest = nil
    --self.ondecorgiven = nil
    --self.ondecortaken = nil

    self._on_decor_item_removed = function()
        if self.ondecortaken then
            self.ondecortaken(self.inst, nil)
        end
        self.decor_item = nil
        self.enabled = true
    end
    self._on_decor_item_picked_up = function()
        if self.decor_item then
            self.inst:RemoveEventCallback("onremove", self._on_decor_item_removed, self.decor_item)
            self.inst:RemoveEventCallback("onpickup", self._on_decor_item_picked_up, self.decor_item)
        end
        if self.ondecortaken then
            self.ondecortaken(self.inst, self.decor_item)
        end
        self.decor_item = nil
        self.enabled = true
    end
end,
nil,
{
    enabled = onenabled,
    decor_item = ondecoritem,
})

function FurnitureDecorTaker:OnRemoveFromEntity()
    self.inst:RemoveTag("furnituredecortaker")
end

function FurnitureDecorTaker:SetEnabled(enabled)
    if self.enabled ~= enabled then
        self.enabled = enabled
    end
end

function FurnitureDecorTaker:AbleToAcceptDecor(item, giver)
    if not item or not self.enabled then
        return false
    elseif self.abletoaccepttest then
        return self.abletoaccepttest(self.inst, item, giver)
    else
        return true
    end
end

function FurnitureDecorTaker:AcceptDecor(item, giver)
    local stackable = item.components.stackable
	if stackable and stackable:IsStack() then
        item = stackable:Get()
    else
        item.components.inventoryitem:RemoveFromOwner(true)
    end

    if self.ondecorgiven then
        self.ondecorgiven(self.inst, item, giver)
    end

    self.decor_item = item
    self.enabled = false

    self.inst:ListenForEvent("onremove", self._on_decor_item_removed, item)
    self.inst:ListenForEvent("onpickup", self._on_decor_item_picked_up, item)

    local item_furnituredecor = item.components.furnituredecor
    if item_furnituredecor then
        item_furnituredecor:PutOnFurniture(self.inst)
    end

    return true
end

function FurnitureDecorTaker:TakeItem()
    local decor_item = self.decor_item
    if decor_item then
        self.decor_item = nil
        self.enabled = true
        self.inst:RemoveEventCallback("onremove", self._on_decor_item_removed, decor_item)
        self.inst:RemoveEventCallback("onpickup", self._on_decor_item_picked_up, decor_item)

        if self.ondecortaken then
            self.ondecortaken(self.inst, decor_item)
        end
    end

    return decor_item
end

-- Save/Load
function FurnitureDecorTaker:OnSave()
    if not self.decor_item then
        return
    end

    local item_guid = self.decor_item.GUID
    return {item_guid = item_guid}, {item_guid}
end

function FurnitureDecorTaker:LoadPostPass(ents, data)
    if data and data.item_guid then
        local decor_item_data = ents[data.item_guid]
        if decor_item_data then
            self:AcceptDecor(decor_item_data.entity)
        end
    end
end

-- Debug
function FurnitureDecorTaker:GetDebugString()
    return "Can Take: "..((self.enabled and "True") or "False")
end

return FurnitureDecorTaker