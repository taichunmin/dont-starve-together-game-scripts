-- Don't use this on new screens! Use PopupDialogScreen with big longness
-- instead.
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TEMPLATES = require "widgets/templates"


local BigPopupDialogScreen = Class(Screen, function(self, title, text, buttons, timeout)
	Screen._ctor(self, "BigPopupDialogScreen")

	--darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)

	self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

	--throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(130, 150, 1, 1, 68, -40))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(.92, .68)
    self.bg.fill:SetPosition(8, 12)

	--title
    self.title = self.proot:AddChild(Text(BUTTONFONT, 50))
    self.title:SetPosition(0, 135, 0)
    self.title:SetString(title)
    self.title:SetColour(0,0,0,1)

	--text
    if JapaneseOnPS4() then
       self.text = self.proot:AddChild(Text(NEWFONT, 28))
    else
       self.text = self.proot:AddChild(Text(NEWFONT, 30))
    end

    self.text:SetPosition(0, 5, 0)
    self.text:SetString(text)
    self.text:EnableWordWrap(true)
    if JapaneseOnPS4() then
        self.text:SetRegionSize(500, 300)
    else
        self.text:SetRegionSize(500, 200)
    end
    self.text:SetColour(0,0,0,1)

	--create the menu itself
	local button_w = 200
	local space_between = 20
	local spacing = button_w + space_between


    local spacing = 200

	self.menu = self.proot:AddChild(Menu(buttons, spacing, true))
	self.menu:SetPosition(-(spacing*(#buttons-1))/2, -140, 0)
	self.buttons = buttons
	self.default_focus = self.menu
end)



function BigPopupDialogScreen:OnUpdate( dt )
	if self.timeout then
		self.timeout.timeout = self.timeout.timeout - dt
		if self.timeout.timeout <= 0 then
			self.timeout.cb()
		end
	end
	return true
end

function BigPopupDialogScreen:OnControl(control, down)
    if BigPopupDialogScreen._base.OnControl(self,control, down) then
        return true
    end
end

return BigPopupDialogScreen
