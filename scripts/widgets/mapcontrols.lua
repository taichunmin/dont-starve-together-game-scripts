local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local PauseScreen = require "screens/redux/pausescreen"

local function OnToggleMap()
    ThePlayer.HUD.controls:ToggleMap()
end

local function OnPause()
    if not IsPaused() then
        TheFrontEnd:PushScreen(PauseScreen())
    end
end

local function OnRotLeft()
    ThePlayer.components.playercontroller:RotLeft()
end

local function OnRotRight()
    ThePlayer.components.playercontroller:RotRight()
end

local MAPSCALE = .5

--base class for imagebuttons and animbuttons.
local MapControls = Class(Widget, function(self)
    Widget._ctor(self, "Map Controls")

    self.minimapBtn = self:AddChild(ImageButton(HUD_ATLAS, "map_button.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.minimapBtn:SetScale(MAPSCALE, MAPSCALE, MAPSCALE)
    self.minimapBtn:SetOnClick(OnToggleMap)

    self.pauseBtn = self:AddChild(ImageButton(HUD_ATLAS, "pause.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.pauseBtn:SetScale(.33, .33, .33)
    self.pauseBtn:SetPosition(0, -50, 0)
    self.pauseBtn:SetOnClick(OnPause)

    self.rotleft = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.rotleft:SetPosition(-40, -40, 0)
    self.rotleft:SetScale(-.7, .7, .7)
    self.rotleft:SetOnClick(OnRotLeft)

    self.rotright = self:AddChild(ImageButton(HUD_ATLAS, "turnarrow_icon.tex", nil, nil, nil, nil, {1,1}, {0,0}))
    self.rotright:SetPosition(40, -40, 0)
    self.rotright:SetScale(.7, .7, .7)
    self.rotright:SetOnClick(OnRotRight)

    self:RefreshTooltips()
end)

function MapControls:RefreshTooltips()
    local controller_id = TheInput:GetControllerID()
    self.minimapBtn:SetTooltip((self.map_tooltip or STRINGS.UI.HUD.MAP).."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_MAP))..")")
    self.pauseBtn:SetTooltip(STRINGS.UI.HUD.PAUSE.."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL))..")")
    self.rotleft:SetTooltip(STRINGS.UI.HUD.ROTLEFT.."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT))..")")
    self.rotright:SetTooltip(STRINGS.UI.HUD.ROTRIGHT.."("..tostring(TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT))..")")
end

function MapControls:Show()
    self._base.Show(self)
    self:RefreshTooltips()
end

function MapControls:ShowMapButton()
    self.minimapBtn:Show()
    self.pauseBtn:SetPosition(0, -50, 0)
end

function MapControls:HideMapButton()
    self.minimapBtn:Hide()
    self.pauseBtn:SetPosition(0, -40, 0)
end

return MapControls
