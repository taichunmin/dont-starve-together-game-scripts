local AchievementsPanel = require "widgets/redux/achievementspanel"
local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"


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
    self.achievements:SetPosition(0, -30)

    local level_str = subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.LEVEL_ACHIEVED_FMT, {
                event_title = STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(self.festival_key)]
            })
    self.level_text = self.achievements:AddChild(Text(HEADERFONT, 28, level_str, UICOLOURS.HIGHLIGHT_GOLD))
    self.level_text:SetPosition(-15, 300)
    local w,h  = self.level_text:GetRegionSize()

    self.badge = self.achievements:AddChild(TEMPLATES.FestivalNumberBadge(self.festival_key))

    local festival_rank = wxputils.GetLevel(self.festival_key)
    self.badge:SetRank(festival_rank)
    self.badge.num:SetSize(30)
    self.badge:SetPosition(w/2 + 15, 300)
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
