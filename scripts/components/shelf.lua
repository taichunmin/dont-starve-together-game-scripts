local function ontakeshelfitem(self)
    if self.cantakeitem and self.itemonshelf ~= nil then
        self.inst:AddTag("takeshelfitem")
    else
        self.inst:RemoveTag("takeshelfitem")
    end
end

local Shelf = Class(function(self, inst)
    self.inst = inst
    self.cantakeitemfn = nil
    self.itemonshelf = nil
    self.onitemtakenfn = nil
    self.cantakeitem = false
end,
nil,
{
    cantakeitem = ontakeshelfitem,
    itemonshelf = ontakeshelfitem,
})

function Shelf:OnRemoveFromEntity()
    self.inst:RemoveTag("takeshelfitem")
end

function Shelf:SetOnShelfItem(fn)
    self.onshelfitemfn = fn
end

function Shelf:SetOnTakeItem(fn)
    self.ontakeitemfn = fn
end

function Shelf:PutItemOnShelf(item)
    self.itemonshelf = item

    if self.onshelfitemfn ~= nil then
        self.onshelfitemfn(self.inst, item)
    end
end

function Shelf:TakeItem(taker)
    if self.cantakeitem and self.itemonshelf ~= nil then

        if self.takeitemtstfn and not self.takeitemtstfn(self.inst,taker, self.itemonshelf) then
            return
        end

        if self.ontakeitemfn ~= nil then
            self.ontakeitemfn(self.inst, taker, self.itemonshelf)
        end

        if taker ~= nil and taker.components.inventory ~= nil then
            if self.inst.components.inventory ~= nil then
                self.inst.components.inventory:RemoveItem(self.itemonshelf)
            end
            self.itemonshelf.prevslot = nil
            self.itemonshelf.prevcontainer = nil
            taker.components.inventory:GiveItem(self.itemonshelf, nil, self.inst:GetPosition())
            self.itemonshelf = nil
        else
            self.inst.components.inventory:DropItem(self.itemonshelf)
			self.itemonshelf = nil
        end
    end
end

function Shelf:GetDebugString()
    if self.itemonshelf == nil then
        return ""
    end

    local canbetakenstr = (self.cantakeitem and "Can" or "Cannot").." be taken"
    return self.itemonshelf.prefab..": "..canbetakenstr
end

return Shelf
