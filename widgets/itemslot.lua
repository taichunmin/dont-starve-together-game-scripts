local Widget = require("widgets/widget")

local ItemSlot = Class(Widget, function(self, atlas, bgim, owner)
    Widget._ctor(self, "ItemSlot")
    self.owner = owner
    self.bgimage = self:AddChild(Image(atlas, bgim))
    self.tile = nil    

	self.highlight_scale = 1.3
	self.base_scale = 1

end)

function ItemSlot:Highlight()
	if not self.big then
		self:ScaleTo(self.base_scale, self.highlight_scale, .125)
		self.big = true	
	end
end

function ItemSlot:DeHighlight()
    if self.big then    
        self:ScaleTo(self.highlight_scale, self.base_scale, .25)
        self.big = false
    end
end

function ItemSlot:OnGainFocus()
	self:Highlight()

end

function ItemSlot:OnLoseFocus()
	self:DeHighlight()
end

function ItemSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

return ItemSlot