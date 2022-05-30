local Widget = require "widgets/widget"
local CraftSlot = require "widgets/craftslot"


local CraftSlots = Class(Widget, function(self, num, owner)
    Widget._ctor(self, "CraftSlots")

    local CRAFTING_ATLAS = GetGameModeProperty("hud_atlas") or HUD_ATLAS

    self.owner = owner
    self.slots = {}
    for k = 1, num do
        local slot = CraftSlot(CRAFTING_ATLAS, "craft_slot.tex", owner)
        -- self.slots[k] = slot
        self:AddChild(slot)
        table.insert(self.slots, slot)
    end
end)

function CraftSlots:SetNumSlots(num)
    if num >= #self.slots then
        self:ShowAll()
        return
    end

    self:HideAll()

    for i = 1, num do
        local slot = self.slots[i]
        slot:Show()
    end
end

function CraftSlots:HideAll()
    for k,v in ipairs(self.slots) do
        v:Hide()
    end
end

function CraftSlots:ShowAll()
    for k,v in ipairs(self.slots) do
        v:Show()
    end
end

function CraftSlots:EnablePopups()
    for k,v in ipairs(self.slots) do
        v:EnablePopup()
    end
end

function CraftSlots:Refresh()
	for k,v in pairs(self.slots) do
		v:Refresh()
	end
end

function CraftSlots:Open(idx)
	if idx > 0 and idx <= #self.slots then
		self.slots[idx]:Open()
	end
end

function CraftSlots:LockOpen(idx)
	if idx > 0 and idx <= #self.slots then
		self.slots[idx]:LockOpen()
	end
end

function CraftSlots:Clear()
    for k,v in ipairs(self.slots) do
        v:Clear()
    end
end

function CraftSlots:CloseAll()
    for k,v in ipairs(self.slots) do
        v:Close()
    end
end

return CraftSlots