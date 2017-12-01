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

    if self.onshelfitemfn then
        self.onshelfitemfn(self.inst, item)
    end
end

function Shelf:TakeItem(taker)
    if self.cantakeitem and self.itemonshelf ~= nil then
        if self.ontakeitemfn ~= nil then
            self.ontakeitemfn(self.inst, taker, self.itemonshelf)
        end

        if taker.components.inventory ~= nil then
            self.inst.components.inventory:RemoveItem(self.itemonshelf)
            self.itemonshelf.prevslot = nil
            self.itemonshelf.prevcontainer = nil
            taker.components.inventory:GiveItem(self.itemonshelf, nil, self.inst:GetPosition())
            self.itemonshelf = nil
        else
            self.inst.components.inventory:DropItem(self.itemonshelf)
        end
    end
end

return Shelf