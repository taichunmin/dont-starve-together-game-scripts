local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"


local BirdInteractScreen = Class(Screen, function(self, buttons)
    Screen._ctor(self, "BirdInteractScreen")


    --darken everything behind the dialog
    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0,0,0,0.75)
    self.black:SetHelpTextMessage("")

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(TEMPLATES.CurlyWindow(250, 286, STRINGS.UI.TRADESCREEN.BIRDS, nil, nil, STRINGS.UI.TRADESCREEN.BIRDS_TITLE_SUB))
    self.bg.body:SetVAlign(ANCHOR_TOP)
    self.bg.body:SetSize(20)

    --create the menu itself
    local button_w = 250
    local button_h = 53
    self.menu = self.proot:AddChild(Menu(buttons, -button_h, false, "carny_xlong", nil, 23))
    self.menu:SetPosition(0, 103, 0)
    for i,v in pairs(self.menu.items) do
        v:SetScale(.9)
    end

    self.default_focus = self.menu
end)


function BirdInteractScreen:OnControl(control, down)
    if BirdInteractScreen._base.OnControl(self,control, down) then
        return true
    elseif not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen()
        return true
    end
end

function BirdInteractScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.TRADESCREEN.BACK)

    return table.concat(t, "  ")
end

return BirdInteractScreen
