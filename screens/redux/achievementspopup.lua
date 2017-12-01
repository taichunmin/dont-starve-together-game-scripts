local AchievementsPanel = require "widgets/redux/achievementspanel"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"



local AchievementsPopup = Class(Screen, function(self, prev_screen, user_profile, festival_key)
	Screen._ctor(self, "AchievementsPopup")
    self.prev_screen = prev_screen
    self.user_profile = user_profile
    self.festival_key = festival_key

	self:DoInit()

	self.default_focus = self.achievements
end)

function AchievementsPopup:DoInit()
    self.root = self:AddChild(TEMPLATES.ScreenRoot())
    self.bg = self.root:AddChild(TEMPLATES.BackgroundTint())	

    if not TheInput:ControllerAttached() then
        self.back_button = self.root:AddChild(TEMPLATES.BackButton(
                function()
                    self:_Close()
                end
            ))
    end

    self.achievements = self.root:AddChild(AchievementsPanel(self.user_profile, self.festival_key))
    self.achievements:SetPosition(0, 30)
end

function AchievementsPopup:OnControl(control, down)
    if AchievementsPopup._base.OnControl(self, control, down) then return true end

    if not down and control == CONTROL_CANCEL then
        self:_Close()
        return true
    end
end

function AchievementsPopup:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.SERVERLISTINGSCREEN.BACK)

    return table.concat(t, "  ")
end

function AchievementsPopup:_Close()
    TheFrontEnd:PopScreen()
end

return AchievementsPopup
