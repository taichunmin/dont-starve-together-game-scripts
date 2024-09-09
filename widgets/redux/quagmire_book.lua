local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

local RecipeBookWidget = require "widgets/redux/quagmire_recipebook"
local AchievementsPanel = require "widgets/redux/achievementspanel"

require("util")

-------------------------------------------------------------------------------------------------------
local QuagmireBook = Class(Widget, function(self, parent, secondary_left_menu, season)
    Widget._ctor(self, "QuagmireBook")

    self.root = self:AddChild(Widget("root"))

	local tab_root = self.root:AddChild(Widget("tab_root"))

	local backdrop = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    backdrop:ScaleToSize(900, 550)

	local achievement_overrides = {}
	achievement_overrides.offset_y = -5
	achievement_overrides.divider_atlas = "images/quagmire_recipebook.xml"
	achievement_overrides.divider_tex = "quagmire_recipe_line_break2.tex"
	achievement_overrides.divider_h = 12
	achievement_overrides.quagmire_gridframe = true
	achievement_overrides.no_title = true
	achievement_overrides.primary_font_colour = UICOLOURS.BROWN_DARK
	achievement_overrides.scrollbar_offset = -8

	local base_size = .7

	local button_data = {
		{text = STRINGS.UI.RECIPE_BOOK.TITLE, build_panel_fn = function() return RecipeBookWidget(parent, season) end },
		{text = STRINGS.UI.ACHIEVEMENTS.SCREENTITLE, build_panel_fn = function() return AchievementsPanel(FESTIVAL_EVENTS.QUAGMIRE, season, achievement_overrides) end}
	}

	local function MakeTab(data, index)
		local tab = ImageButton("images/quagmire_recipebook.xml", "quagmire_recipe_tab_inactive.tex", nil, nil, nil, "quagmire_recipe_tab_active.tex")
		--tab:SetPosition(-260 + 240*(i-1), 285)
		tab:SetFocusScale(base_size, base_size)
		tab:SetNormalScale(base_size, base_size)
		tab:SetText(data.text)
		tab:SetTextSize(22)
		tab:SetFont(HEADERFONT)
		tab:SetTextColour(UICOLOURS.GOLD)
		tab:SetTextFocusColour(UICOLOURS.GOLD)
		tab:SetTextSelectedColour(UICOLOURS.GOLD)
		tab.text:SetPosition(0, -2)
		tab.clickoffset = Vector3(0,5,0)
		tab:SetOnClick(function()
	        self.last_selected:Unselect()
	        self.last_selected = tab
			tab:Select()
			tab:MoveToFront()
			if self.panel ~= nil then
				self.panel:Kill()
			end
			self.panel = self.root:AddChild(data.build_panel_fn())
			if parent ~= nil then
				if TheWorld ~= nil then
					parent.default_focus = self.panel.parent_default_focus
				else
					self:_DoFocusHookups(parent, secondary_left_menu)
				end
			end
			self.panel.parent_default_focus:SetFocus()
		end)
		tab._tabindex = index - 1

		return tab
	end

	self.tabs = {}

	table.insert(self.tabs, tab_root:AddChild(MakeTab(button_data[1], 1)))
	self.tabs[#self.tabs]:SetPosition(-260, 285)
	table.insert(self.tabs, tab_root:AddChild(MakeTab(button_data[2], 2)))
	self.tabs[#self.tabs]:SetPosition(-260 + 240, 285)

	-----
	self.last_selected = self.tabs[1]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.panel = self.root:AddChild(RecipeBookWidget(parent, season))
	if TheWorld ~= nil then
		parent.default_focus = self.panel.parent_default_focus
	else
        if parent ~= nil then
		    self:_DoFocusHookups(parent, secondary_left_menu)
        end
	end
end)

function QuagmireBook:_DoFocusHookups(menu, secondary_left_menu)
	menu:ClearFocusDirs()
	menu:SetFocusChangeDir(MOVE_RIGHT, self.panel.parent_default_focus)
	self.panel.parent_default_focus:SetFocusChangeDir(MOVE_LEFT, menu)

	if secondary_left_menu ~= nil then
		secondary_left_menu:ClearFocusDirs()

		menu:SetFocusChangeDir(MOVE_UP, secondary_left_menu)
		secondary_left_menu:SetFocusChangeDir(MOVE_DOWN, menu)
		secondary_left_menu:SetFocusChangeDir(MOVE_RIGHT, self.panel.parent_default_focus)
	end

	for i, v in ipairs(self.tabs) do
		v:ClearFocusDirs()
		v:SetFocusChangeDir(MOVE_LEFT, self.panel.parent_default_focus)
		v:SetFocusChangeDir(MOVE_RIGHT, self.panel.parent_default_focus)
		v:SetFocusChangeDir(MOVE_UP, self.panel.parent_default_focus)
		v:SetFocusChangeDir(MOVE_DOWN, self.panel.parent_default_focus)
	end

	if self.panel.spinners ~= nil then
		for i, v in ipairs(self.panel.spinners) do
			v:SetFocusChangeDir(MOVE_LEFT, menu)
		end
	end
end

function QuagmireBook:OnControlTabs(control, down)
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


function QuagmireBook:OnControl(control, down)
    if QuagmireBook._base.OnControl(self, control, down) then return true end

	return self:OnControlTabs(control, down)
end

function QuagmireBook:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    return table.concat(t, "  ")
end


return QuagmireBook
