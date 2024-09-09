local Screen = require "widgets/screen"
local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local CookbookWidget = require "widgets/redux/cookbookwidget"
local TEMPLATES = require "widgets/redux/templates"

local CookbookPopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "CookbookPopupScreen")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    black:SetHelpTextMessage("")

	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)

	self.book = root:AddChild(CookbookWidget(owner))

	self.default_focus = self.book

    SetAutopaused(true)
end)

function CookbookPopupScreen:OnDestroy()
    SetAutopaused(false)

    POPUPS.COOKBOOK:Close(self.owner)

	TheCookbook:ClearNewFlags()
	TheCookbook:Save() -- for saving filter settings

	CookbookPopupScreen._base.OnDestroy(self)
end

function CookbookPopupScreen:OnBecomeInactive()
    CookbookPopupScreen._base.OnBecomeInactive(self)
end

function CookbookPopupScreen:OnBecomeActive()
    CookbookPopupScreen._base.OnBecomeActive(self)
end

function CookbookPopupScreen:OnControl(control, down)
    if CookbookPopupScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MENU_BACK or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

	return false
end

function CookbookPopupScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return CookbookPopupScreen
