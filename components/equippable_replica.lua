local EquipSlot = require("equipslotutil")

local Equippable = Class(function(self, inst)
    self.inst = inst

    self._equipslot =
        EquipSlot.Count() <= 7 and
        net_tinybyte(inst.GUID, "equippable._equipslot") or
        net_smallbyte(inst.GUID, "equippable._equipslot")
end)

function Equippable:SetEquipSlot(eslot)
    self._equipslot:set(EquipSlot.ToID(eslot))
end

function Equippable:EquipSlot()
    return EquipSlot.FromID(self._equipslot:value())
end

function Equippable:IsEquipped()
    if self.inst.components.equippable ~= nil then
        return self.inst.components.equippable:IsEquipped()
    else
        return self.inst.replica.inventoryitem ~= nil and
            self.inst.replica.inventoryitem:IsHeld() and
            ThePlayer.replica.inventory:GetEquippedItem(self:EquipSlot()) == self.inst
    end
end

function Equippable:IsRestricted(target)
    --return true if restricted (can't equip)
    if self.inst.components.equippable ~= nil then
        return self.inst.components.equippable:IsRestricted(target)
    end
    local restrictedtag = self.inst.replica.inventoryitem ~= nil and self.inst.replica.inventoryitem:GetEquipRestrictedTag() or nil
    return restrictedtag ~= nil and not target:HasTag(restrictedtag)
end

return Equippable
