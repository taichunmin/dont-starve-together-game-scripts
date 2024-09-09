local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

--Copied from votedialog.lua
local CONTROLLER_OPEN_SCALE = .95
local BUTTON_SCALE = 1.2

local ControllerVoteScreen = Class(Screen, function(self, votedialog)
    Screen._ctor(self, "ControllerVoteScreen")

    self.votedialog = votedialog

    --darken everything behind the dialog
    self.blackoverlay = self:AddChild(Image("images/global.xml", "square.tex"))
    self.blackoverlay:SetVRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetHRegPoint(ANCHOR_MIDDLE)
    self.blackoverlay:SetVAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetHAnchor(ANCHOR_MIDDLE)
    self.blackoverlay:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.blackoverlay:SetTint(0, 0, 0, .5)

    --Basically recreate the position of the VoteDialog widget relative to the HUD controls
    self.root = self:AddChild(Widget("controllervoteroot"))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_RIGHT)
    self.root:SetVAnchor(ANCHOR_TOP)
    self.root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.scale_root = self.root:AddChild(Widget("controllervotescaleroot"))
    self.scale_root:SetScale(TheFrontEnd:GetHUDScale())

    self.dialogroot = self.scale_root:AddChild(Widget("controllervotedialogroot"))
    self.dialogroot:SetPosition(votedialog:GetPosition())

    --Borrow the widget from votedialog
    self.dialogroot:AddChild(votedialog.root)

    self.prompt = Text(TALKINGFONT, 28)
    self.prompt:SetScale(1 / (CONTROLLER_OPEN_SCALE * BUTTON_SCALE))
    self.prompt:SetPosition(-2, 4.5, 0)
    self.prompt:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_ACCEPT))

    self.selection = nil

    for i, v in ipairs(votedialog.buttons) do
        v:SetOnGainFocus(function(enabled)
            v:AddChild(self.prompt)
            self.prompt:Show()
            self.selection = i
        end)
        v:SetOnLoseFocus(function(enabled)
            if self.selection == i then
                self.selection = nil
                v:RemoveChild(self.prompt)
                self.prompt:Hide()
            end
        end)
    end

    self.inst:ListenForEvent("refreshhudsize", function(hud, scale) self.scale_root:SetScale(scale) end, votedialog.owner.HUD.inst)
    self.inst:ListenForEvent("hidevotedialog", function() self:Close() end, TheWorld)
end)

function ControllerVoteScreen:OnBecomeInactive()
    self._base.OnBecomeInactive(self)
    if self.prompt ~= nil then
        self:Close()
    end
end

function ControllerVoteScreen:Close()
    --Return the widget to votedialog
    for i, v in ipairs(self.votedialog.buttons) do
        v:SetOnGainFocus(nil)
        v:SetOnLoseFocus(nil)
    end
    self.prompt:Kill()
    self.prompt = nil
    self:ClearFocus()
    self.votedialog:AddChild(self.votedialog.root)
    self.votedialog:OnCloseControllerVoteScreen(self.selection)
    TheFrontEnd:PopScreen(self)
end

function ControllerVoteScreen:OnControl(control, down)
    if self._base.OnControl(self, control, down) then
        return true
    elseif not down and control == CONTROL_CANCEL then
        self:Close()
        return true
    end
end

return ControllerVoteScreen
