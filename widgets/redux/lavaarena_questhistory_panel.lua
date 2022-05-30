-- Yup, this is almost the same as PortraitBackgroundExplorerPanel.
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local TEMPLATES = require "widgets/redux/templates"

require("dlcsupport")
require("misc_items")
require("util")


local LavaarenaQuestHistoryPanel = Class(Widget, function(self, festival_key, season)
    Widget._ctor(self, "LavaarenaQuestHistoryPanel")

	local quest_details = self:GetCompletedQuests(festival_key, season)

    self.achievements_root = self:AddChild(Widget("achievements_root"))
	self.achievements_root:SetPosition(0, -45)

	local backing = self.achievements_root:AddChild(Image("images/lavaarena_unlocks2.xml", "box7.tex"))
    backing:SetScale(.72, .7)
    backing:SetPosition(0, 30)

	self.grid = self.achievements_root:AddChild( self:_BuildAchievementsExplorer(festival_key, season, quest_details.completed_quests) )
	self.grid:SetPosition(-10,0)

	local line_break = self.grid:AddChild(Image("images/ui.xml", "line_horizontal_4.tex"))
	line_break:SetPosition(10, 160)
	line_break:SetScale(1.22, 0.8)
	line_break:SetTint(107/255, 84/255, 58/255, 0.5)

	line_break = self.grid:AddChild(Image("images/ui.xml", "line_horizontal_4.tex"))
	line_break:SetPosition(10, -159)
	line_break:SetScale(1.22, 0.8)
	line_break:SetTint(107/255, 84/255, 58/255, 0.5)

    self.focus_forward = self.grid
    self.default_focus = self.grid

	local stats = self.achievements_root:AddChild(self:_BuildStatsPanel(quest_details))
	stats:SetPosition(0, 200)

	self.parent_default_focus = self.grid.scroll_bar:IsVisible() and self.grid or nil
end)

function LavaarenaQuestHistoryPanel:GetCompletedQuests(festival_key, season)
	local unlocked_quests = EventAchievements:GetAllUnlockedAchievements(festival_key, season)

	local details = {}
	details.num_daily_wins = 0
	details.num_daily_matches = 0
	details.completed_quests = {}

	for _, q in ipairs(unlocked_quests) do
		local quest_info = EventAchievements:ParseFullQuestName(q)
		if quest_info.quest_id == "laq_dailywin" then
			details.num_daily_wins = details.num_daily_wins + 1
		elseif quest_info.quest_id == "laq_dailymatch" then
			details.num_daily_matches = details.num_daily_matches + 1
		else
	        table.insert(details.completed_quests, quest_info)
		end
	end

	table.sort(details.completed_quests, function(a, b) return (a.version > b.version) or (a.version == b.version and a.day > b.day) end)

	return details
end

function LavaarenaQuestHistoryPanel:_BuildStatsPanel(quest_details)
	local w = Widget("stats_panel")

	local title = w:AddChild(Text(HEADERFONT, 22, subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.COMPLETED_QUESTS_FMT, {num = tostring(GetTableSize(quest_details.completed_quests))}), UICOLOURS.BROWN_DARK))
	title:SetPosition(0, -15)

	local x = 279

    local icon = w:AddChild(Image("images/lavaarena_quests.xml", quest_details.num_daily_wins == 0 and "laq_dailywin_locked.tex" or "laq_dailywin.tex"))
    icon:SetScale(.35)
    icon:SetPosition(x, 35)
	title = w:AddChild(Text(HEADERFONT, 18, subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DAILY_WINS_FMT, {num = tostring(quest_details.num_daily_wins)}), UICOLOURS.BROWN_DARK))
	title:SetPosition(x, 0)

    icon = w:AddChild(Image("images/lavaarena_quests.xml", quest_details.num_daily_matches == 0 and "laq_dailymatch_locked.tex" or "laq_dailymatch.tex"))
    icon:SetScale(.35)
    icon:SetPosition(-x, 35)
	title = w:AddChild(Text(HEADERFONT, 18, subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DAILY_MATCHES_FMT, {num = tostring(quest_details.num_daily_matches)}), UICOLOURS.BROWN_DARK))
	title:SetPosition(-x, 0)

	return w
end

function LavaarenaQuestHistoryPanel:_BuildAchievementsExplorer(festival_key, season, completed_quests)

	local row_w = 425

    local row_h = 70;
    local row_spacing = 5;
	local num_quests = GetTableSize(completed_quests)

	local function ScrollWidgetsCtor(context, index)
		local w = Widget("quest-cell")
		w:SetScale(0.64)

		w.root = w:AddChild(Widget("root"))

		local left = - row_w/2

		w.quest_icon = w.root:AddChild(Image("images/lavaarena_quests.xml", "achievement_personal.tex"))
		w.quest_icon:SetScale(.7)
		w.quest_icon:SetPosition(left, 0)

		left = left + 60

		w.title = w.root:AddChild(Text(HEADERFONT, 30, "", UICOLOURS.BROWN_DARK))
		w.title:SetRegionSize(row_w, 50)
		w.title:SetPosition(left + row_w/2, 35)

		local details_w = row_w - 50

		w.quest_type = w.root:AddChild(Text(CHATFONT, 23, "", UICOLOURS.BROWN_MEDIUM))
		w.quest_type:EnableWordWrap(true)
		w.quest_type:SetRegionSize(details_w, 80)
		w.quest_type:SetHAlign(ANCHOR_LEFT)
		w.quest_type:SetVAlign(ANCHOR_TOP)
		w.quest_type:SetPosition(left + details_w/2, 8 - 28)

		left = left + details_w + 25

		w.xp_value = w.root:AddChild(Text(HEADERFONT, 30, "", UICOLOURS.BROWN_DARK))
		w.xp_value:SetPosition(left, 2)

		w.xp_label = w.root:AddChild(Text(HEADERFONT, 18, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.XP_LABEL, UICOLOURS.BROWN_DARK))
		w.xp_label:SetPosition(left, -17)

		left = left + 75

		w.line1 = w.root:AddChild(Image("images/ui.xml", "line_vertical_2.tex"))
		w.line1:SetScale(.5, .25)
		w.line1:SetPosition(left, -52)
		w.line1:SetTint(107/255, 84/255, 58/255, 0.5)
		w.line1:Hide()
		w.line2 = w.root:AddChild(Image("images/ui.xml", "line_horizontal_4.tex"))
		w.line2:SetScale(.75, .75)
		w.line2:SetPosition(left, -52)
		w.line2:SetTint(107/255, 84/255, 58/255, 0.5)
		w.line2:Hide()

		w.root:Hide()
		return w
	end

	local function ScrollWidgetApply(context, w, quest_info, index)
		if quest_info ~= nil then
			w:Show()
			w.root:Show()

			w.quest_icon:SetTexture("images/lavaarena_quests.xml", quest_info.quest_id .. ".tex")
			--w.quest_icon:SetScale(.8)

			w.title:SetString(STRINGS.UI.ACHIEVEMENTS[string.upper(festival_key)].ACHIEVEMENT[quest_info.quest_id].TITLE)

			local achievement_data = EventAchievements:FindAchievementData(festival_key, season, quest_info.quest_id)
			local is_team = achievement_data ~= nil and achievement_data.team
			local quest_xp = achievement_data ~= nil and achievement_data.wxp

			local quest_type_desc = (quest_info.character ~= nil and subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_CHARACTER_FMT, {character = STRINGS.NAMES[string.upper(quest_info.character)], quest_type = STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS[is_team and "QUEST_TYPE_TEAM" or "QUEST_TYPE_PERSONAL"]}))
									or (is_team and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_TEAM)
									or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_PERSONAL

			w.quest_type:SetString(quest_type_desc .. "\n" .. STRINGS.UI.ACHIEVEMENTS[string.upper(festival_key)].ACHIEVEMENT[quest_info.quest_id].DESC, UICOLOURS.BROWN_DARK)
			w.xp_value:SetString(tostring(quest_xp))

			if index % 2 == 1 and index <= (num_quests-2) then
				w.line1:Show()
				w.line2:Show()
			else
				w.line1:Hide()
				w.line2:Hide()
			end
		else
			w:Hide()
			w.root:Hide()
		end
	end

    local grid = TEMPLATES.ScrollingGrid(
        completed_quests,
        {
            context = {},
            widget_width  = row_w * 0.9,
            widget_height = row_h+row_spacing,
            num_visible_rows = 4,
            num_columns      = 2,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetApply,
            scrollbar_offset = 0,
            scrollbar_height_offset = -60,
			scroll_per_click = 0.5,
        })

    return grid

end

return LavaarenaQuestHistoryPanel
