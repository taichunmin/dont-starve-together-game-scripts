local ItemSlot = require "widgets/itemslot"

local EquipSlot = Class(ItemSlot, function(self, equipslot, atlas, bgim, owner)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.equipslot = equipslot
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(owner, data)
        if data.item ~= nil and
            data.item.replica.equippable ~= nil and
            equipslot == data.item.replica.equippable:EquipSlot() and
            not data.item.replica.equippable:IsRestricted(owner) then
            self:LockHighlight()
        else
            self:UnlockHighlight()
        end
    end, owner)

	self:SetOnTileChangedFn(function(self, tile)
		if tile ~= nil then
			tile:SetIsEquip(true)
		end
	end)
end)

function EquipSlot:Click()
    self:OnControl(CONTROL_ACCEPT, true)
end

function EquipSlot:OnControl(control, down)
	if self.tile ~= nil then
		self.tile:UpdateTooltip()
	end

    if down then
        local inventory = self.owner.replica.inventory
        if control == CONTROL_ACCEPT then
            local active_item = inventory:GetActiveItem()
            if active_item ~= nil then
                if active_item.replica.equippable ~= nil and
                    self.equipslot == active_item.replica.equippable:EquipSlot() and
                    not active_item.replica.equippable:IsRestricted(self.owner) then
                    if self.tile ~= nil and self.tile.item ~= nil then
                        if self.tile.item.replica.equippable == nil or not self.tile.item.replica.equippable:ShouldPreventUnequipping() then
                            inventory:SwapEquipWithActiveItem()
                        end
                    else
                        inventory:EquipActiveItem()
                    end
                end
            elseif self.tile ~= nil and self.tile.item ~= nil and self.owner.replica.inventory:GetNumSlots() > 0 then
                if self.tile.item.replica.equippable == nil or not self.tile.item.replica.equippable:ShouldPreventUnequipping() then
                    inventory:TakeActiveItemFromEquipSlot(self.equipslot)
                end
            end
            return true
        elseif control == CONTROL_SECONDARY and
            self.tile ~= nil and
            self.tile.item ~= nil then
                if TheInput:IsControlPressed(CONTROL_FORCE_TRADE) then
                    if self.tile.item.replica.equippable == nil or not self.tile.item.replica.equippable:ShouldPreventUnequipping() then
                        inventory:DropItemFromInvTile(self.tile.item, TheInput:IsControlPressed(CONTROL_FORCE_STACK))
                    end
                else
                    inventory:UseItemFromInvTile(self.tile.item)
                end
            return true
        end
    end
end

return EquipSlot