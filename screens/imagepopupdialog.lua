local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/templates"
local PopupDialogScreen = require "screens/popupdialog"

local ImagePopupDialogScreen = Class(PopupDialogScreen, function(self, title, widgets, widget_width, spacing, text, buttons, scale_bg, spacing_override)
	PopupDialogScreen._ctor(self, title, text, buttons, scale_bg, spacing_override)

    -- redo the bg
    self.proot:RemoveChild(self.bg)
    self.proot:RemoveChild(self.bg.fill)
    self.bg:Kill()
    self.bg.fill:Kill()

    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(200, 200, 1, 1, 68, -40))
    self.bg.fill = self.proot:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tiny.tex"))
    self.bg.fill:SetScale(1, .8)
    self.bg.fill:SetPosition(8, 12)

    self.bg.fill:MoveToBack()
    self.bg:MoveToBack()

    self.title:SetPosition(0, 98, 0)
    self.text:SetPosition(5, 25, 0)

    local pos = self.menu:GetPosition()
    self.menu:SetPosition(pos.x, pos.y - 20, pos.z)
    self.menu.reverse = true

    local widget_container = self.proot:AddChild(Widget("container"))

    local width = (widget_width + spacing) * #widgets + spacing

    --print("Got ", widget_width or "nil", spacing or "nil", width or "nil", #widgets or "nil")


    for i=1, #widgets do
        local widg = widget_container:AddChild(widgets[i])
        widg:SetPosition(spacing + ((i-1)*widget_width), 0)
        --print("Position is ", spacing + ((i-1)*widget_width))
    end


    widget_container:SetPosition(-.5*(#widgets) * widget_width + .5*widget_width, -40)

    --print("Width is ", width, -.5*width)

end)

return ImagePopupDialogScreen