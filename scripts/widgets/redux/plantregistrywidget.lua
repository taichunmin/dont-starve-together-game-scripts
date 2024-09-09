local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local PlantsPage = require "widgets/redux/plantspage"
local FertilizersPage = require "widgets/redux/fertilizerspage"

require("util")

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS = require("prefabs/weed_defs").WEED_DEFS
local function HasModdedPlantsOrWeeds()
	for k, v in pairs(PLANT_DEFS) do
		 if v.modded then return true end
	end
	for k, v in pairs(WEED_DEFS) do
		if v.modded then return true end
	end
	return false
end

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS
local function HasModdedFertilizer()
	for k, v in pairs(FERTILIZER_DEFS) do
		 if v.modded then return true end
	end
	return false
end

-------------------------------------------------------------------------------------------------------
local PlantRegistryWidget = Class(Widget, function(self, parent)
    Widget._ctor(self, "PlantRegistryWidget")

    self.root = self:AddChild(Widget("root"))

	self.tab_root = self.root:AddChild(Widget("tab_root"))

	self.backdrop = self.root:AddChild(Image("images/plantregistry.xml", "backdrop.tex"))

	if not ThePlantRegistry:ApplyOnlineProfileData() then
		local msg = not TheInventory:HasSupportForOfflineSkins() and (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and STRINGS.UI.PLANTREGISTRY.ONLINE_DATA_USER_OFFLINE or STRINGS.UI.PLANTREGISTRY.ONLINE_DATA_DOWNLOAD_FAILED
		self.sync_status = self.root:AddChild(Text(HEADERFONT, 18, msg, UICOLOURS.GREY))
		self.sync_status:SetPosition(0, -285)
	end

	local base_size = .7

	local button_data = {
		{text = STRINGS.UI.PLANTREGISTRY.TAB_TITLE_PLANTS, build_panel_fn = function() return PlantsPage(self) end},
	}

	if HasModdedPlantsOrWeeds() then
		table.insert(button_data, {text = STRINGS.UI.PLANTREGISTRY.TAB_TITLE_MOD_PLANTS, build_panel_fn = function() return PlantsPage(self, true) end})
	end

	table.insert(button_data, {text = STRINGS.UI.PLANTREGISTRY.TAB_TITLE_FERTILIZERS, build_panel_fn = function() return FertilizersPage(self) end})

	if HasModdedFertilizer() then
		table.insert(button_data, {text = STRINGS.UI.PLANTREGISTRY.TAB_TITLE_MOD_FERTILIZERS, build_panel_fn = function() return FertilizersPage(self, true) end})
	end

	local function MakeTab(data, index)
        local tab = ImageButton("images/plantregistry.xml", "plant_tab_inactive.tex", nil, nil, nil, "plant_tab_active.tex")

		tab:SetFocusScale(base_size, base_size)
		tab:SetNormalScale(base_size, base_size)
		tab:SetText(data.text)
		tab:SetTextSize(22)
		tab:SetFont(HEADERFONT)
		tab:SetTextColour(UICOLOURS.GOLD)
		tab:SetTextFocusColour(UICOLOURS.GOLD)
		tab:SetTextSelectedColour(UICOLOURS.GOLD)
		tab.text:SetPosition(0, -4)
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

		    if TheInput:ControllerAttached() then
				self.panel.parent_default_focus:SetFocus()
			end

			ThePlantRegistry:SetFilter("tab", index)
		end)
		tab._tabindex = index - 1

		return tab
	end

	self.tabs = {}
	for i = 1, #button_data do
		table.insert(self.tabs, self.tab_root:AddChild(MakeTab(button_data[i], i)))
		self.tabs[#self.tabs]:MoveToBack()
	end
	self:_PositionTabs(self.tabs, 200, 285)

	-----
	local starting_tab = ThePlantRegistry:GetFilter("tab")
	if self.tabs[starting_tab] == nil then
		starting_tab = 1
	end
	self.last_selected = self.tabs[starting_tab]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.panel = self.root:AddChild(button_data[starting_tab].build_panel_fn())

	self.focus_forward = function() return self.panel.parent_default_focus end
end)

function PlantRegistryWidget:Kill()
	ThePlantRegistry:Save() -- for saving filter settings

	PlantRegistryWidget._base.Kill(self)
end

function PlantRegistryWidget:_PositionTabs(tabs, w, y)
	local offset = #self.tabs / 2
	for i = 1, #self.tabs do
		local x = (i - offset - 0.5) * w
		tabs[i]:SetPosition(x, y)
	end
end

function PlantRegistryWidget:OnControlTabs(control, down)
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

function PlantRegistryWidget:OnControl(control, down)
    if PlantRegistryWidget._base.OnControl(self, control, down) then return true end

	if #self.tabs > 1 then
		return self:OnControlTabs(control, down)
	end
end

function PlantRegistryWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if #self.tabs > 1 then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_L2).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_R2).. " " .. STRINGS.UI.HELP.CHANGE_TAB)
	end

    return table.concat(t, "  ")
end


return PlantRegistryWidget