local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"
local Spinner = require "widgets/spinner"

local PLANT_DEFS = require("prefabs/farm_plant_defs").PLANT_DEFS
local WEED_DEFS	 = require("prefabs/weed_defs").WEED_DEFS

local PlantsPage = Class(Widget, function(self, parent_widget, ismodded)
    Widget._ctor(self, "PlantsPage")

    self.parent_widget = parent_widget
    self.ismodded = ismodded

	self.root = self:AddChild(Widget("root"))

	self.plant_grid = self.root:AddChild(self:BuildPlantScrollGrid())
	self.plant_grid:SetPosition(-15, 0)

	local plant_grid_data = {}
	for i, def in ipairs({PLANT_DEFS, WEED_DEFS}) do
		for k, v in orderedPairs(def) do
			--not operator used as a cast to boolean.
			if v.plantregistryinfo and ((not self.ismodded) == (not v.modded)) then
				local beststage = ThePlantRegistry:GetLastSelectedCard(k)
				if not beststage then
					if v.plantregistrysummarywidget and ThePlantRegistry:GetPlantPercent(k, v.plantregistryinfo) >= 1 then
						beststage = "summary"
					else
						for stage in pairs(ThePlantRegistry:GetKnownPlantStages(k)) do
							if v.plantregistryinfo[stage] and (not beststage or stage + (v.plantregistryinfo[stage].stagepriority or 0) > beststage) then
								beststage = stage
							end
						end
					end
				end
				table.insert(plant_grid_data, {plant = k, plant_def = v, info = v.plantregistryinfo, currentstage = beststage or 1})
			end
		end
	end

	self.plant_grid:SetItemsData(plant_grid_data)

	self.parent_default_focus = self.plant_grid
end)

local textures = {
	arrow_left_normal = "arrow2_left.tex",
	arrow_left_over = "arrow2_left_over.tex",
	arrow_left_disabled = "arrow_left_disabled.tex",
	arrow_left_down = "arrow2_left_down.tex",
	arrow_right_normal = "arrow2_right.tex",
	arrow_right_over = "arrow2_right_over.tex",
	arrow_right_disabled = "arrow_right_disabled.tex",
	arrow_right_down = "arrow2_right_down.tex",
	bg_middle = "blank.tex",
	bg_middle_focus = "blank.tex",
	bg_middle_changing = "blank.tex",
	bg_end = "blank.tex",
	bg_end_focus = "blank.tex",
	bg_end_changing = "blank.tex",
	bg_modified = "option_highlight.tex",
}

function PlantsPage:BuildPlantScrollGrid()
    local row_w = 160
    local row_h = 230
	local row_spacing = 2

	local width_spinner = 135
	local width_label = 135
	local height = 25

	local font = HEADERFONT
	local font_size = 15

	local function ScrollWidgetsCtor(context, index)
		local w = Widget("plant-cell-".. index)
		w.cell_root = w:AddChild(ImageButton("images/plantregistry.xml", "plant_entry.tex", "plant_entry_focus.tex"))

		w.focus_forward = w.cell_root

		w.cell_root.ongainfocusfn = function()
			self.plant_grid:OnWidgetFocus(w)
		end

		w.plant_seperator = w.cell_root:AddChild(Image("images/plantregistry.xml", "plant_entry_seperator.tex"))
		w.plant_seperator:SetPosition(0, 88)

		w.plant_anim = w.cell_root:AddChild(UIAnim())
		w.plant_anim:SetPosition(0, -65)
		w.plant_anim:SetScale(0.3, 0.3)
		w.plant_anim:GetAnimState():OverrideSymbol("soil01", "farm_soil", "soil01")

		w.plant_label = w.cell_root:AddChild(Text(font, font_size))
		w.plant_label:SetPosition(0, 100)
		w.plant_label:SetRegionSize( width_label, height )
		w.plant_label:SetHAlign( ANCHOR_MIDDLE )

		local lean = true
		w.plant_spinner = w.cell_root:AddChild(Spinner({}, width_spinner, height, {font = font, size = font_size}, nil, "images/plantregistry.xml", textures, lean))

		w.plant_spinner:SetPosition(0, -95)
		w.plant_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)

		function w:SetPlantAndStage(plant, stage)
			if w.plant_summary then
				w.plant_summary:Kill()
				w.plant_summary = nil
			end

			local data = w.data
			if not data then return end
			data.currentstage = stage
			if data.currentstage == "summary" and data.plant_def.plantregistrysummarywidget and ThePlantRegistry:GetPlantPercent(data.plant, data.info) >= 1 then
				ThePlantRegistry:SetLastSelectedCard(plant, data.currentstage)
				w.plant_locked:Hide()
				w.plant_anim:Hide()
				local summarywidget = require(data.plant_def.plantregistrysummarywidget)
				w.plant_summary = w.cell_root:AddChild(summarywidget(w, data))
				return
			end

			if ThePlantRegistry:KnowsPlantStage(plant, data.currentstage) then
				ThePlantRegistry:SetLastSelectedCard(plant, data.currentstage)
				w.plant_locked:Hide()
				w.plant_anim:Show()

				local curinfo = data.info[data.currentstage]
				w.plant_anim:GetAnimState():SetBankAndPlayAnimation(curinfo.bank or data.plant_def.bank, curinfo.anim, curinfo.loop ~= false)
				return
			end

			w.plant_anim:Hide()
			w.plant_locked:Show()
		end

		w.plant_locked = w.cell_root:AddChild(Image("images/plantregistry.xml", "locked.tex"))
		w.plant_locked:SetScale(0.5, 0.5)

		local _OnControl = w.cell_root.OnControl
		w.cell_root.OnControl = function(_, control, down)
			if w.plant_spinner.focus or (control == CONTROL_PREVVALUE or control == CONTROL_NEXTVALUE) then if w.plant_spinner:IsVisible() then w.plant_spinner:OnControl(control, down) end return true end
			return _OnControl(_, control, down)
		end

		local _OnGainFocus = w.cell_root.OnGainFocus
		function w.cell_root.OnGainFocus()
			_OnGainFocus(w.cell_root)
			w.plant_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_focus.tex")
			w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			w.plant_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
		end
		local _OnLoseFocus = w.cell_root.OnLoseFocus
		function w.cell_root.OnLoseFocus()
			_OnLoseFocus(w.cell_root)
			if not w.data then return end
			if ThePlantRegistry:IsAnyPlantStageKnown(w.data.plant) then
				w.plant_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_active.tex")
			else
				w.plant_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator.tex")
			end
			if w.plant_label:GetString() == STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT then
				w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			else
				w.plant_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
			end
			w.plant_spinner:SetTextColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
		end

		function w.cell_root:GetHelpText()
			if not w.plant_spinner.focus and w.plant_spinner:IsVisible() then
				return w.plant_spinner:GetHelpText()
			end
		end

		w.cell_root:SetOnClick(function()
			if not w.data then return end
			local widgetpath
			if ThePlantRegistry:IsAnyPlantStageKnown(w.data.plant) then
				widgetpath = w.data and w.data.plant_def.plantregistrywidget or nil
			else
				widgetpath = w.data and w.data.plant_def.unknownwidget or "widgets/redux/unknownplantpage"
			end
			if widgetpath then
				self:OpenPageWidget(widgetpath, w.data, w)
			end
		end)

		return w
	end

	local function ScrollWidgetSetData(context, widget, data, index)
		if data == nil then
			widget.cell_root:Hide()
			return
		else
			widget.cell_root:Show()
		end
		if widget.data ~= data then
			widget.data = data
			widget.plant_anim:GetAnimState():SetBuild(data.plant_def.build)
			widget:SetPlantAndStage(data.plant, data.currentstage)

			local plant_label_str = ThePlantRegistry:KnowsPlantName(data.plant, data.info) and
				STRINGS.NAMES[string.upper(data.plant_def.prefab)] or
				STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT
			widget.plant_label:SetString(plant_label_str)

			if plant_label_str == STRINGS.UI.PLANTREGISTRY.MYSTERY_PLANT then
				widget.plant_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			else
				widget.plant_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
			end

			local spinner_options = {}
			for i, v in ipairs(data.info) do
				if not v.hidden or ThePlantRegistry:KnowsPlantStage(data.plant, i) then
					table.insert(spinner_options, {text = STRINGS.UI.PLANTREGISTRY.PLANT_GROWTH_STAGES[string.upper(v.text)], data = i})
				end
			end
			if data.plant_def.plantregistrysummarywidget and ThePlantRegistry:GetPlantPercent(data.plant, data.info) >= 1 then
				table.insert(spinner_options, {text = STRINGS.UI.PLANTREGISTRY.PLANT_GROWTH_STAGES.SUMMARY, data = "summary"})
			end

			if ThePlantRegistry:IsAnyPlantStageKnown(data.plant) then
				widget.cell_root:SetTextures("images/plantregistry.xml", "plant_entry_active.tex", "plant_entry_focus.tex")
				widget.plant_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_active.tex")
				widget.plant_locked:SetPosition(0, 0)
				widget.plant_spinner:SetOptions(spinner_options)
				widget.plant_spinner:SetOnChangedFn(function(spinner_data)
					widget:SetPlantAndStage(data.plant, spinner_data)
				end)
				widget.plant_spinner:SetSelected(data.currentstage)
				widget.plant_spinner:Show()
			else
				widget.cell_root:SetTextures("images/plantregistry.xml", "plant_entry.tex", "plant_entry_focus.tex")
				widget.plant_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator.tex")
				widget.plant_locked:SetPosition(0, -15)
				widget.plant_spinner:Hide()
			end
		end
    end

    local grid = TEMPLATES.ScrollingGrid(
        {},
        {
            context = {},
            widget_width  = row_w+row_spacing,
            widget_height = row_h+row_spacing,
			force_peek    = true,
            num_visible_rows = 2,
            num_columns      = 5,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetSetData,
            scrollbar_offset = 15,
			scrollbar_height_offset = -60,
			peek_percent = 30/(row_h+row_spacing),
			end_offset = math.abs(1 - 5/(row_h+row_spacing)),
		})

	grid.up_button:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_arrow.tex")
	grid.up_button:SetScale(0.5)

	grid.down_button:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_arrow.tex")
	grid.down_button:SetScale(-0.5)

	grid.scroll_bar_line:SetTexture("images/plantregistry.xml", "plantregistry_recipe_scroll_bar.tex")
	grid.scroll_bar_line:SetScale(.8)

	grid.position_marker:SetTextures("images/plantregistry.xml", "plantregistry_recipe_scroll_handle.tex")
	grid.position_marker.image:SetTexture("images/plantregistry.xml", "plantregistry_recipe_scroll_handle.tex")
	grid.position_marker:SetScale(.6)

    return grid
end

function PlantsPage:OpenPageWidget(plantregistrywidgetpath, data, currentwidget)
	self.currentwidget = currentwidget
	local plantregistrywidget = require(plantregistrywidgetpath)
	self.plantregistrywidget = self.root:AddChild(plantregistrywidget(self, data))
	self.plantregistrywidget:SetFocus(true)
	self.parent_default_focus = self.plantregistrywidget
	self.plant_grid:Hide()
	self.plantregistrywidget:SetFocus()
	if self.parent_widget then
		self.parent_widget.tab_root:Hide()
		if self.plantregistrywidget:HideBackdrop() then
			self.parent_widget.backdrop:Hide()
		end
	end
end

function PlantsPage:ClosePageWidget()
	if self.plantregistrywidget then
		self.root:RemoveChild(self.plantregistrywidget)
		self.plantregistrywidget:Kill()
		self.plantregistrywidget = nil
	end
	self.parent_default_focus = self.plant_grid
	self.plant_grid:Show()
	if self.parent_widget then
		self.parent_widget.tab_root:Show()
		self.parent_widget.backdrop:Show()
	end
	if self.currentwidget then
		self.currentwidget:SetFocus(true)
		self.currentwidget = nil
	else
		self.plant_grid:SetFocus(true)
	end
end

function PlantsPage:OnControl(control, down)
	if self.plantregistrywidget then
		self.plantregistrywidget:OnControl(control, down)
		return true
	end
	return PlantsPage._base.OnControl(self, control, down)
end

return PlantsPage
