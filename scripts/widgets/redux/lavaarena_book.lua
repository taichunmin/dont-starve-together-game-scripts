local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

local ProgressionWidget = require "widgets/redux/lavaarena_communityprogression_panel"
local CommunityHistoryPanel = require "widgets/redux/lavaarena_communityhistory_panel"
local QuestHistoryPanel = require "widgets/redux/lavaarena_questhistory_panel"

require("util")

-------------------------------------------------------------------------------------------------------
local LavaarenaBook = Class(Widget, function(self, main_menu_widget, secondary_left_menu, season)
    Widget._ctor(self, "LavaarenaBook")

	self.main_menu_widget = main_menu_widget
	self.secondary_left_menu = secondary_left_menu
	self.season = season

    self.root = self:AddChild(Widget("LavaarenaBook_root"))
	self:DoInit()
end)

function LavaarenaBook:GetTabButtonData()
	local tabs = {}
	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		tabs = {
			{x = -280, text = STRINGS.UI.LAVAARENA_SUMMARY_PANEL.TAB_TITLE, build_panel_fn = function() return ProgressionWidget(FESTIVAL_EVENTS.LAVAARENA, self.season) end},
			{x = 0, text = STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.TAB_TITLE, build_panel_fn = function() return CommunityHistoryPanel() end},
			{x = 280, text = STRINGS.UI.LAVAARENA_QUESTS_HISTORY_PANEL.TAB_TITLE, build_panel_fn = function() return QuestHistoryPanel(FESTIVAL_EVENTS.LAVAARENA, self.season) end},
		}
	else
		tabs =  {
			{x = -150, text = STRINGS.UI.LAVAARENA_COMMUNITY_UNLOCKS.TAB_TITLE, build_panel_fn = function() return CommunityHistoryPanel() end},
			{x = 150, text = STRINGS.UI.LAVAARENA_QUESTS_HISTORY_PANEL.TAB_TITLE, build_panel_fn = function() return QuestHistoryPanel(FESTIVAL_EVENTS.LAVAARENA, self.season) end},
		}
	end
	return tabs
end

function LavaarenaBook:_MakeTab(data, index)
	local base_scale = .65

	local tab = ImageButton("images/lavaarena_unlocks.xml", "tab_inactive.tex", nil, nil, nil, "tab_active.tex")
	--tab:SetPosition(-260 + 240*(i-1), 285)
	tab:SetFocusScale(base_scale, base_scale)
	tab:SetNormalScale(base_scale, base_scale)
	tab:SetText(data.text)
	tab:SetTextSize(22)
	tab:SetFont(HEADERFONT)
	tab:SetTextColour(UICOLOURS.GOLD)
	tab:SetTextFocusColour(UICOLOURS.GOLD)
	tab:SetTextSelectedColour(UICOLOURS.GOLD)
	tab.text:SetPosition(0, 10)
	tab.clickoffset = Vector3(0,-5,0)
	tab:SetOnClick(function()
	    self.last_selected:Unselect()
	    self.last_selected = tab
		tab:Select()
		tab:MoveToFront()
		if self.panel ~= nil then
			self.panel:Kill()
		end
		self.panel = self.root:AddChild(tab.build_panel_fn())
		self:_DoFocusHookups()

		if not TheFrontEnd.tracking_mouse then
			if self.panel.parent_default_focus ~= nil then
				self.panel.parent_default_focus:SetFocus()
			elseif self.main_menu_widget ~= nil and TheWorld == nil then
				self.main_menu_widget:SetFocus()
			end
		end
	end)
	tab._tabindex = index - 1
	tab.build_panel_fn = data.build_panel_fn

	return tab
end

function LavaarenaBook:BuildTabs(button_data)
	self.tabs = {}
	for i, v in ipairs(self:GetTabButtonData()) do
		table.insert(self.tabs, self.tab_root:AddChild(self:_MakeTab(v, i)))
		self.tabs[#self.tabs]:SetPosition(v.x, 250)
	end
end

function LavaarenaBook:DoInit()
	self.tab_root = self.root:AddChild(Widget("tab_root"))

	self.backdrop = self.root:AddChild(Image("images/lavaarena_unlocks.xml", "unlock_bg.tex"))
    self.backdrop:ScaleToSize(900, 550)
	self.backdrop:SetClickable(false)

	self:BuildTabs(self:GetTabButtonData())

	-----
	self.last_selected = self.tabs[1]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.panel = self.root:AddChild(self.tabs[1].build_panel_fn())

	self:_DoFocusHookups()
end

function LavaarenaBook:_DoFocusHookups()
	if self.panel.parent_default_focus ~= nil then
		self.focus_forward = self.panel.parent_default_focus
		if self.main_menu_widget ~= nil then
			self.panel.parent_default_focus:SetFocusChangeDir(MOVE_LEFT, self.main_menu_widget)
			self.main_menu_widget:SetFocusChangeDir(MOVE_RIGHT, self.panel.parent_default_focus)
		end
		if self.secondary_left_menu ~= nil then
			self.secondary_left_menu:SetFocusChangeDir(MOVE_RIGHT, self.panel.parent_default_focus)
		end
	else
		self.focus_forward = self.panel
		if self.main_menu_widget ~= nil then
			self.main_menu_widget:SetFocusChangeDir(MOVE_RIGHT, nil)
		end
		if self.secondary_left_menu ~= nil then
			self.secondary_left_menu:SetFocusChangeDir(MOVE_RIGHT, nil)
		end
	end

end

function LavaarenaBook:OnControlTabs(control, down)
	if control == CONTROL_MENU_L2 then
		local tab = self.tabs[((self.last_selected._tabindex - 1) % #self.tabs) + 1]
		if not down then
			tab.onclick()
			return true
		end
	elseif control == CONTROL_MENU_R2 then
		local tab = self.tabs[((self.last_selected._tabindex + 1) % #self.tabs) + 1]
		if not down then
			tab.onclick()
			return true
		end
	end

end

function LavaarenaBook:OnUpdate(dt)
	if self.panel ~= nil and self.panel.OnUpdate ~= nil then
		self.panel:OnUpdate(dt)
	end
end

function LavaarenaBook:OnControl(control, down)
    if LavaarenaBook._base.OnControl(self, control, down) then return true end

	return self:OnControlTabs(control, down)
end

function LavaarenaBook:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    return table.concat(t, "  ")
end


return LavaarenaBook
