local AchievementsPanel = require "widgets/redux/achievementspanel"
local QuagmireBookWidget = require "widgets/redux/quagmire_book"
local LavaarenaBookWidget = require "widgets/redux/lavaarena_book"

local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/redux/templates"
local Text = require "widgets/text"


local AchievementsPopup = Class(Screen, function(self, prev_screen, festival_key, season)
	Screen._ctor(self, "AchievementsPopup")
    self.prev_screen = prev_screen
    self.festival_key = festival_key
    self.season = season

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

    local level_str = subfmt(STRINGS.UI.PLAYERSUMMARYSCREEN.LEVEL_ACHIEVED_FMT, {
                event_title = STRINGS.UI.FESTIVALEVENTSCREEN.TITLE[string.upper(self.festival_key)]
            })
    self.level_text = self.root:AddChild(Text(HEADERFONT, 28, level_str, UICOLOURS.HIGHLIGHT_GOLD))
    local w,h  = self.level_text:GetRegionSize()

    self.badge = self.root:AddChild(TEMPLATES.FestivalNumberBadge(self.festival_key))

    local festival_rank = wxputils.GetLevel(self.festival_key, self.season)
    self.badge:SetRank(festival_rank)
    self.badge.num:SetSize(30)
    self.badge:SetPosition(w/2 + 15, 300)


    if self.festival_key == FESTIVAL_EVENTS.LAVAARENA then
		if self.season == 2 then
    		self.achievements = self.root:AddChild(LavaarenaBookWidget(nil, nil, self.season))
			self.achievements:SetPosition(0, -40)

			self.level_text:SetPosition(-15, 310)
			self.badge:SetPosition(w/2 + 15, 310)

			self.achievements.focus_forward = self.achievements.panel.parent_default_focus
		else
			self.achievements = self.root:AddChild(AchievementsPanel(self.festival_key, self.season))
			self.achievements:SetPosition(0, -30)

			self.level_text:SetPosition(-15, 270)
			self.badge:SetPosition(w/2 + 15, 270)
		end
    elseif self.festival_key == FESTIVAL_EVENTS.QUAGMIRE then
    	self.achievements = self.root:AddChild(QuagmireBookWidget(nil, nil, self.season))
		self.achievements:SetPosition(0, -40)

        self.level_text:SetPosition(-15, 310)
        self.badge:SetPosition(w/2 + 15, 310)

        PostProcessor:SetColourCubeData(0, "images/colour_cubes/quagmire_cc.tex", "images/colour_cubes/quagmire_cc.tex")
        PostProcessor:SetColourCubeData(1, "images/colour_cubes/quagmire_cc.tex", "images/colour_cubes/quagmire_cc.tex")
        PostProcessor:SetColourCubeLerp(0, 1)
        PostProcessor:SetColourCubeLerp(1, 0)

        self.achievements.focus_forward = self.achievements.panel.parent_default_focus
    else
        print("Warning!!! New self.festival_key discovered", self.festival_key)
    end
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
