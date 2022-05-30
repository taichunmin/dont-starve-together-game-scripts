local Button = require "widgets/button"
local Image = require "widgets/image"

-- Clickable text. You should probably use ImageButton or just Button instead.
local TextButton = Class(Button, function(self, name)
	Button._ctor(self, name or "TEXTBUTTON")

    self.image = self:AddChild(Image("images/ui.xml", "blank.tex"))
    self:SetFont(DEFAULTFONT)
    self:SetTextSize(30)

    self:SetTextColour({0.9,0.8,0.6,1})
    self:SetTextFocusColour({1,1,1,1})
end)


function TextButton:GetSize()
    return self.image:GetSize()
end

function TextButton:SetText(msg)
    TextButton._base.SetText(self, msg)

    -- This is the only reason to use TextButton: it automatically sizes a
    -- clickable transparent image to the size of your text.
	self.image:SetSize(self.text:GetRegionSize())
end

-- Deprecated. Use SetTextColour instead.
function TextButton:SetColour(r,g,b,a)
	self:SetTextColour(r,g,b,a)
end

-- Deprecated. Use SetTextFocusColour instead.
function TextButton:SetOverColour(r,g,b,a)
    self:SetTextFocusColour(r,g,b,a)
end

return TextButton
