local BanTab = require "widgets/redux/bantab"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"

local BansPopup = Class(Screen, function(self)
	Screen._ctor(self, "BansPopup")

	self:DoInit()

	self.default_focus = self.bans
end)

function BansPopup:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BackgroundTint(0.9))

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:_Close()
                end
            ))
    end

    self.bans = self.root:AddChild(BanTab())
end

function BansPopup:OnControl(control, down)
    if BansPopup._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:_Close()
        return true
    end
end

function BansPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)

    return table.concat(t, "  ")
end

function BansPopup:_Close()
    TheFrontEnd:PopScreen()
end

return BansPopup
