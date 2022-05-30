local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local PlantRegistryWidget = require "widgets/redux/plantregistrywidget"

local PlantRegistryPopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "PlantRegistryPopupScreen")

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

	self.plantregistry = root:AddChild(PlantRegistryWidget(owner))

	self.default_focus = self.plantregistry

    SetAutopaused(true)
end)

function PlantRegistryPopupScreen:OnDestroy()
    SetAutopaused(false)

    POPUPS.PLANTREGISTRY:Close(self.owner)

	PlantRegistryPopupScreen._base.OnDestroy(self)
end

function PlantRegistryPopupScreen:OnBecomeInactive()
    PlantRegistryPopupScreen._base.OnBecomeInactive(self)
end

function PlantRegistryPopupScreen:OnBecomeActive()
    PlantRegistryPopupScreen._base.OnBecomeActive(self)
end

function PlantRegistryPopupScreen:OnControl(control, down)
    if PlantRegistryPopupScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

	return false
end

function PlantRegistryPopupScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return PlantRegistryPopupScreen
