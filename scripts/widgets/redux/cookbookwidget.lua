local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

local CrockpotPage = require "widgets/redux/cookbookpage_crockpot"

local cooking = require("cooking")


require("util")

-------------------------------------------------------------------------------------------------------
local CookbookWidget = Class(Widget, function(self, parent)
    Widget._ctor(self, "CookbookWidget")

    self.root = self:AddChild(Widget("root"))

	local tab_root = self.root:AddChild(Widget("tab_root"))

	local backdrop = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    backdrop:ScaleToSize(900, 550)

	if not TheCookbook:ApplyOnlineProfileData() then
		local msg = not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and STRINGS.UI.COOKBOOK.ONLINE_DATA_USER_OFFLINE or STRINGS.UI.COOKBOOK.ONLINE_DATA_DOWNLOAD_FAILED
		self.sync_status = self.root:AddChild(Text(HEADERFONT, 18, msg, UICOLOURS.BROWN_DARK))
		self.sync_status:SetPosition(0, -258)
	end

	local base_size = .7

	local button_data = {
		{text = STRINGS.UI.COOKBOOK.TAB_TITLE_COOKPOT, build_panel_fn = function() return CrockpotPage(parent, "cookpot") end},
		{text = STRINGS.UI.COOKBOOK.TAB_TITLE_PORTABLECOOKPOT, build_panel_fn = function() return CrockpotPage(parent, "portablecookpot") end},
	}
	if cooking.HasModCookerFood() then
		table.insert(button_data, {text = STRINGS.UI.COOKBOOK.TAB_TITLE_MOD_RECIPES, build_panel_fn = function() return CrockpotPage(parent, "mod") end})
	end

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
			self.focus_forward = self.panel.parent_default_focus

		    if TheInput:ControllerAttached() then
				self.panel.parent_default_focus:SetFocus()
			end

			TheCookbook:SetFilter("tab", index)
		end)
		tab._tabindex = index - 1

		return tab
	end

	self.tabs = {}
	for i = 1, #button_data do
		table.insert(self.tabs, tab_root:AddChild(MakeTab(button_data[i], i)))
		self.tabs[#self.tabs]:MoveToBack()
	end
	self:_PositionTabs(self.tabs, 200, 285)

	-----
	local starting_tab = TheCookbook:GetFilter("tab")
	if self.tabs[starting_tab] == nil then
		starting_tab = 1
	end
	self.last_selected = self.tabs[starting_tab]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.panel = self.root:AddChild(button_data[starting_tab].build_panel_fn())

	self.focus_forward = self.panel.parent_default_focus
end)

function CookbookWidget:_PositionTabs(tabs, w, y)
	local offset = #self.tabs / 2
	for i = 1, #self.tabs do
		local x = (i - offset - 0.5) * w
		tabs[i]:SetPosition(x, y)
	end
end

function CookbookWidget:OnControlTabs(control, down)
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

function CookbookWidget:OnControl(control, down)
    if CookbookWidget._base.OnControl(self, control, down) then return true end

	return self:OnControlTabs(control, down)
end

function CookbookWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    return table.concat(t, "  ")
end


return CookbookWidget
