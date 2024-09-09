local Screen = require "widgets/screen"
local MapWidget = require("widgets/mapwidget")
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local QuagmireBookWidget = require "widgets/redux/quagmire_book"
local TEMPLATES = require "widgets/redux/templates"
local MapControls = require "widgets/mapcontrols"

local QuagmireRecipeBookScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "MapScreen") -- this must be map screen because its hi-jacking the minimap flow and control logic

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

	self.book = root:AddChild(QuagmireBookWidget( owner, nil, GetFestivalEventSeasons(FESTIVAL_EVENTS.QUAGMIRE)))

    if not TheInput:ControllerAttached() then
		self.bottomright_root = self:AddChild(Widget("br_root"))
		self.bottomright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
		self.bottomright_root:SetHAnchor(ANCHOR_RIGHT)
		self.bottomright_root:SetVAnchor(ANCHOR_BOTTOM)
		self.bottomright_root:SetMaxPropUpscale(MAX_HUD_SCALE)

		self.bottomright_root = self.bottomright_root:AddChild(Widget("br_scale_root"))
		self.bottomright_root:SetScale(TheFrontEnd:GetHUDScale())
		self.bottomright_root.inst:ListenForEvent("refreshhudsize", function(hud, scale) self.bottomright_root:SetScale(scale) end, owner.HUD.inst)

        self.mapcontrols = self.bottomright_root:AddChild(MapControls())
        self.mapcontrols:SetPosition(-60,70,0)
		self.mapcontrols.minimapBtn:SetTextures("images/quagmire_hud.xml", "map_button.tex")

        self.mapcontrols.pauseBtn:Hide()
        self.mapcontrols.rotleft:Hide()
        self.mapcontrols.rotright:Hide()
    end
end)

function QuagmireRecipeBookScreen:OnBecomeInactive()
    QuagmireRecipeBookScreen._base.OnBecomeInactive(self)

--    if TheWorld.minimap.MiniMap:IsVisible() then
--        TheWorld.minimap.MiniMap:ToggleVisibility()
--    end
end

function QuagmireRecipeBookScreen:OnBecomeActive()
    QuagmireRecipeBookScreen._base.OnBecomeActive(self)

--    if not TheWorld.minimap.MiniMap:IsVisible() then
--        TheWorld.minimap.MiniMap:ToggleVisibility()
--    end
end

function QuagmireRecipeBookScreen:OnControl(control, down)
    if QuagmireRecipeBookScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MENU_BACK or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

    if not (down and self.shown) then
        return false
    end
--[[
    if control == CONTROL_ROTATE_LEFT and ThePlayer and ThePlayer.components.playercontroller then
        ThePlayer.components.playercontroller:RotLeft()
    elseif control == CONTROL_ROTATE_RIGHT and ThePlayer and ThePlayer.components.playercontroller then
        ThePlayer.components.playercontroller:RotRight()
    elseif control == CONTROL_MAP_ZOOM_IN then
        self.minimap:OnZoomIn()
        self.repeat_time = .025
    elseif control == CONTROL_MAP_ZOOM_OUT then
        self.minimap:OnZoomOut()
        self.repeat_time = .025
    else
        return false
    end
    return true
]]
	return false
end

function QuagmireRecipeBookScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, "  ")
end

return QuagmireRecipeBookScreen
