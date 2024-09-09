local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

local easing = require("easing")
require("util")

-------------------------------------------------------------------------------------------------------
local CommunityProgress = Class(Widget, function(self, festival_key, season)
    Widget._ctor(self, "CommunityProgress")

	self.festival_key = festival_key
	self.season = season

	self.root = self:AddChild(Widget("root"))

	self:ShowSyncing()

	self.inst:ListenForEvent("community_clientdata_updated", function() self:OnRecievedData() end, TheGlobalInstance)
	if TheWorld ~= nil then
		if not Lavaarena_CommunityProgression:IsQueryActive() then
			self:OnRecievedData()
		end
	else
		Lavaarena_CommunityProgression:RequestAllData(false)
	end

	self:_DoFocusHookups()

	return self
end)

function CommunityProgress:ShowSyncing()
	self.root:KillAllChildren()

	local title = self.root:AddChild(Text(HEADERFONT, 20, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.SYNCING_DATA, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, 0)
end

function CommunityProgress:OnRecievedData()
	self.root:KillAllChildren()

	local line_break = self.root:AddChild(Image("images/lavaarena_unlocks.xml", "divider.tex"))
	line_break:SetPosition(0, 35)
	line_break:SetScale(.68)

	local query_successful = Lavaarena_CommunityProgression:GetProgressionQuerySuccessful()
	if query_successful then
		self.status_root = self.root:AddChild(self:BuildProgressionPanel(1056, 30))
		self.status_root:SetPosition(0, 100)
		self.status_root:SetScale(.66)
	else
		local failed_msg = self.root:AddChild(Text(HEADERFONT, 22, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.PROGRESSION_QUERY_FAILURE, UICOLOURS.BROWN_DARK))
		failed_msg:SetPosition(0, 130)
	end

	local quest_query_successful = Lavaarena_CommunityProgression:GetQuestQuerySuccessful(TheNet:GetUserID())
	if quest_query_successful then
		self.details_root = self.root:AddChild(self:BuildQuestPanel(Lavaarena_CommunityProgression:GetCurrentQuestData(TheNet:GetUserID())))
		self.details_root:SetScale(.66)
	else
		local failed_msg = self.root:AddChild(Text(HEADERFONT, 22, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_QUERY_FAILURE, UICOLOURS.BROWN_DARK))
		failed_msg:SetPosition(0, -100)
	end

	Lavaarena_CommunityProgression:Save()
end

local function Reveal_ItemWidget(w, item, is_new)
	if w.lockicon ~= nil then
		w.lockicon:Kill()
	end

	if is_new then
		-- add *new* effects
	end

	local icon = w:AddChild(Image(item.atlas, item.icon))
	if item.style == "item" then
		icon:SetScale(0.85)
	end
end

local function AddItemWidget(self, root, item, offset)
	local x = (-self.fill_width/2) + (self.fill_width * offset)

	local w = root:AddChild(Widget("ceature_widget"))
	w:SetPosition(x, 72 + ((item ~= nil and item.style) == "boss" and 6 or 0))

	if item.style == "item" then
		w.notch = w:AddChild(Image("images/lavaarena_unlocks.xml", "item_notch.tex"))
		w.notch:SetScale(1.1)
		w.notch:SetPosition(0, -50)
	end

	w.RevealIcon = Reveal_ItemWidget

	w._offset = offset

	if item.id == nil or Lavaarena_CommunityProgression:IsLocked(item.id) or Lavaarena_CommunityProgression:IsNewUnlock(item.id) then
		w.lockicon = w:AddChild(Image("images/lavaarena_unlocks.xml", "locked_"..item.style..".tex"))
		w.lockicon:SetScale(1)
	else
		w:RevealIcon(item, false)
	end

	return w
end

function CommunityProgress:BuildProgressionPanel(bar_width, bar_height)
	local status_root = Widget("status_root")

	local backing = status_root:AddChild(Image("images/lavaarena_unlocks.xml", "box1.tex"))
    backing:SetScale(1, 1.12)
    backing:SetPosition(0, 50)

	local fmt_str = Lavaarena_CommunityProgression:IsEverythingUnlocked() and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.EVERYTHING_UNLOCKED or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DESCRIPTION
	local title_str = subfmt(fmt_str, {boss=STRINGS.NAMES[string.upper(Lavaarena_CommunityProgression:GetProgressionKeyBoss())]})
	local title = status_root:AddChild(Text(HEADERFONT, 24, title_str, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, -48)

	status_root.bar = status_root:AddChild(Widget("LargeScissorProgressBar"))

	self.progressbar = status_root.bar
	self.fill_width = bar_width

    local frame = status_root.bar:AddChild(Image("images/lavaarena_unlocks.xml", "progressbar_frame.tex"))
    frame:SetPosition(0, 0)

    status_root.bar.fill = status_root.bar:AddChild(Image("images/global_redux.xml", "progressbar_wxplarge_fill.tex"))
	status_root.bar.fill:SetSize(self.fill_width, bar_height)

	local width, hieght = status_root.bar.fill:GetSize()

	status_root.bar.SetBarFill = function(self, progress)
	    self.fill:SetScissor(-width*.5,-hieght*.5, math.max(0, width * progress), math.max(0, hieght))
	end

	self.icons = {}
	self.items = {}
	local item_styles = Lavaarena_CommunityProgression:GetUnlockOrderStyles()
	local num_defs = Lavaarena_CommunityProgression:GetNumTotalUnlocks()
	local unlockorder = Lavaarena_CommunityProgression:GetUnlockOrder()
	for i = 1, num_defs do
		if i <= #unlockorder then
			table.insert(self.items, unlockorder[i])
			table.insert(self.icons, AddItemWidget(self, status_root, Lavaarena_CommunityProgression:GetUnlockData(unlockorder[i]), (i-1)/(num_defs-1)))
		else
			table.insert(self.items, 0)
			table.insert(self.icons, AddItemWidget(self, status_root, item_styles[i], (i-1)/(num_defs-1)))
		end
	end

	local cur_progress = Lavaarena_CommunityProgression:GetProgression()
	local prev_progress = Lavaarena_CommunityProgression:GetLastSeenProgression()

	if cur_progress.percent > prev_progress.percent then
		self:AnimateBarFill(prev_progress, cur_progress)
	else
		self.progressbar:SetBarFill(cur_progress.percent)
	end

	return status_root
end

function CommunityProgress:AnimateBarFill(from, to)
	self.is_animating = {}

	self.is_animating.to = to.percent
	self.is_animating.from = from.percent
	self.is_animating.prev_val = from.percent

	self.is_animating.dist = (self.is_animating.to) - (self.is_animating.from)
	self.is_animating.duration = math.min(self.is_animating.dist * 40, 2)
	self.is_animating.timer = 0

	self.is_animating.next_unlock = from.level + 1

	self:OnUpdate(0)
end

function CommunityProgress:OnUpdate(dt)
	if not self.is_animating then
		return
	end

	self.is_animating.timer = math.min(self.is_animating.timer + dt, self.is_animating.duration)
	--local val = easing.outCubic( self.is_animating.timer, self.is_animating.from, self.is_animating.dist, self.is_animating.duration)
	local val = (self.is_animating.timer / self.is_animating.duration) * self.is_animating.dist + self.is_animating.from

	if val > self.is_animating.to then
		val = self.is_animating.to
	end

	local next_unlock_item = Lavaarena_CommunityProgression:GetUnlockData(self.items[self.is_animating.next_unlock])
	local next_icon = self.icons[self.is_animating.next_unlock]
	if next_unlock_item ~= nil then
		if val >= next_icon._offset and self.is_animating.prev_val < next_icon._offset then
			if not Lavaarena_CommunityProgression:IsLocked(next_unlock_item.id) then
				next_icon:RevealIcon(next_unlock_item, true)
				self.is_animating.next_unlock = self.is_animating.next_unlock + 1
			else
				self.is_animating.to = val
			end
		end
	end

	self.progressbar:SetBarFill(val)

	if val == self.is_animating.to then
		self.is_animating = nil
	else
		self.is_animating.prev_val = val
	end

end

local function MakeDailyEntry(quest_info, festival_key, season)
    local w = Widget("daily-cell")

	local quest_icon = (EventAchievements:IsAchievementUnlocked(festival_key, season, EventAchievements:BuildFullQuestName(quest_info.quest, quest_info.character)) and (quest_info.quest .. ".tex"))
						or (quest_info.quest.."_locked.tex")

    local icon = w:AddChild(Image("images/lavaarena_quests.xml", quest_icon))
    icon:SetScale(.45)
    icon:SetPosition(0, 34)

	local title = w:AddChild(Text(HEADERFONT, 28, STRINGS.UI.LAVAARENA_SUMMARY_PANEL[string.upper(quest_info.quest)], UICOLOURS.BROWN_DARK))
	title:SetPosition(-35, -12)

	local quest_xp = EventAchievements:GetActiveAchievementsIdList()[quest_info.quest].wxp

	local xp_region_w = 100

	local xp_value = w:AddChild(Text(HEADERFONT, 24, tostring(quest_xp), UICOLOURS.BROWN_DARK))
	xp_value:SetPosition(110, -5)
	xp_value = w:AddChild(Text(HEADERFONT, 18, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.XP_LABEL, UICOLOURS.BROWN_DARK))
	xp_value:SetPosition(110, -22)

	return w
end

local function MakeQuestEntry(quest_info, row_w, festival_key, season)
    local w = Widget("quest-cell")

	local quest_icon = (EventAchievements:IsAchievementUnlocked(festival_key, season, EventAchievements:BuildFullQuestName(quest_info.quest, quest_info.character)) and (quest_info.quest .. ".tex"))
						or (quest_info.character ~= nil and "achievement_"..quest_info.character..".tex")
						or (EventAchievements:GetActiveAchievementsIdList()[quest_info.quest].team and "achievement_group.tex")
						or "achievement_personal.tex"

	local left = 0

    local icon = w:AddChild(Image("images/lavaarena_quests.xml", quest_icon))
    icon:SetScale(.8)

	left = left + 64

	local title = w:AddChild(Text(HEADERFONT, 30, STRINGS.UI.ACHIEVEMENTS[string.upper(festival_key)].ACHIEVEMENT[quest_info.quest].TITLE, UICOLOURS.BROWN_DARK))
    title:SetRegionSize(row_w, 50)
    title:SetPosition(left + row_w/2, 35)

	local is_team = EventAchievements:GetActiveAchievementsIdList()[quest_info.quest].team
	local quest_xp = EventAchievements:GetActiveAchievementsIdList()[quest_info.quest].wxp

	local quest_type_desc = (quest_info.character ~= nil and subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_CHARACTER_FMT, {character = STRINGS.NAMES[string.upper(quest_info.character)], quest_type = STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS[is_team and "QUEST_TYPE_TEAM" or "QUEST_TYPE_PERSONAL"]}))
							or (is_team and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_TEAM)
							or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_TYPE_PERSONAL

	local details_w = row_w - 50

	local quest_type = w:AddChild(Text(CHATFONT, 23, quest_type_desc .. "\n" .. STRINGS.UI.ACHIEVEMENTS[string.upper(festival_key)].ACHIEVEMENT[quest_info.quest].DESC, UICOLOURS.BROWN_MEDIUM))
	quest_type:EnableWordWrap(true)
    quest_type:SetRegionSize(details_w, 80)
    quest_type:SetHAlign(ANCHOR_LEFT)
    quest_type:SetVAlign(ANCHOR_TOP)
    quest_type:SetPosition(left + details_w/2, 8 - 28)

	local xp_value = w:AddChild(Text(HEADERFONT, 30, tostring(quest_xp), UICOLOURS.BROWN_DARK))
	xp_value:SetPosition(left + row_w - 10, 2)
	xp_value = w:AddChild(Text(HEADERFONT, 18, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.XP_LABEL, UICOLOURS.BROWN_DARK))
	xp_value:SetPosition(left + row_w - 10, -17)

	return w
end

function CommunityProgress:BuildQuestPanel(active_quests)
    local w = Widget("quest_root")
	w:SetPosition(0, -100)

    local backing = w:AddChild(Image("images/lavaarena_unlocks.xml", "box6.tex"))
    backing:SetScale(1.1, .75)
	backing:SetPosition(0, -10)

    local line = w:AddChild(Image("images/ui.xml", "line_vertical_2.tex"))
    line:SetScale(.5, .33)
	line:SetPosition(0, -52)
	line:SetTint(107/255, 84/255, 58/255, 0.5)
    line = w:AddChild(Image("images/ui.xml", "line_horizontal_4.tex"))
    line:SetScale(.75, .75)
	line:SetPosition(0, -52)
	line:SetTint(107/255, 84/255, 58/255, 0.5)

	local title = w:AddChild(Text(HEADERFONT, 36, STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.AVAILABLE_QUESTS, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, 100)

	local cur_time = os.time()
	local exp_date = os.difftime(active_quests.daily_expiry, cur_time)
	local hours = math.floor(exp_date / (60*60))
	local minutes = math.min(math.ceil((exp_date % (60*60)) / 60), 59)
	local time_str = (exp_date > 0 and (hours > 0 or minutes > 3)) and subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DAILY_RESET, {hours = hours, minutes = minutes})
					or (TheWorld ~= nil and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DAILY_RESET_SOON_INGAME)
					or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.DAILY_RESET_SOON
	local time = w:AddChild(Text(CHATFONT, 22, time_str, UICOLOURS.BROWN_DARK))
	time:SetPosition(-300, -195)

	exp_date = os.difftime(active_quests.quest_expiry, cur_time)
	hours = math.floor(exp_date / (60*60))
	minutes = math.min(math.ceil((exp_date % (60*60)) / 60), 59)
	time_str = (exp_date > 0 and (hours > 0 or minutes > 3)) and subfmt(STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_RESET, {hours = hours, minutes = minutes})
				or (TheWorld ~= nil and STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_RESET_SOON_INGAME)
				or STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.QUEST_RESET_SOON
	time = w:AddChild(Text(CHATFONT, 22, time_str, UICOLOURS.BROWN_DARK))
	time:SetPosition(300, -195)


	local daily = w:AddChild(MakeDailyEntry(active_quests.daily_match, self.festival_key, self.season))
	daily:SetPosition(-425, 125)
	daily = w:AddChild(MakeDailyEntry(active_quests.daily_win, self.festival_key, self.season))
	daily:SetPosition(425, 125)

	local row_w = 425
	local left, top = -310 - row_w / 2, 5
	local right, bottom = 275 - row_w / 2, -110

	local quest = w:AddChild(MakeQuestEntry(active_quests.basic, row_w, self.festival_key, self.season))
	quest:SetPosition(left, top)
	quest = w:AddChild(MakeQuestEntry(active_quests.challenge, row_w, self.festival_key, self.season))
	quest:SetPosition(right, top)
	quest = w:AddChild(MakeQuestEntry(active_quests.special1, row_w, self.festival_key, self.season))
	quest:SetPosition(left, bottom)
	quest = w:AddChild(MakeQuestEntry(active_quests.special2, row_w, self.festival_key, self.season))
	quest:SetPosition(right, bottom)

	return w
end

function CommunityProgress:_DoFocusHookups()

--	self.parent_default_focus = self
end

return CommunityProgress
