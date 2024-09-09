local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local TEMPLATES = require "widgets/redux/templates"

local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS
local SORTED_FERTILIZERS = require("prefabs/fertilizer_nutrient_defs").SORTED_FERTILIZERS

local FertilizersPage = Class(Widget, function(self, parent_widget, ismodded)
    Widget._ctor(self, "FertilizersPage")

    self.parent_widget = parent_widget
    self.ismodded = ismodded

	self.root = self:AddChild(Widget("root"))

	self.fertilizer_grid = self.root:AddChild(self:BuildFertlizerScrollGrid())
	self.fertilizer_grid:SetPosition(-15, 0)

	local fertilizer_grid_data = {}
	for i, v in ipairs(SORTED_FERTILIZERS) do
		local def = FERTILIZER_DEFS[v]
		--not operator used as a cast to boolean.
		if def and ((not self.ismodded) == (not def.modded)) then
			table.insert(fertilizer_grid_data, {fertilizer = v, def = def})
		end
	end

	self.fertilizer_grid:SetItemsData(fertilizer_grid_data)

    self.parent_default_focus = self.fertilizer_grid
end)

function FertilizersPage:BuildFertlizerScrollGrid()
    local row_w = 160
    local row_h = 230
	local row_spacing = 2

	local item_size = 48
	local nutrient_size = 24

	local width_label = 100
	local height = 25

	local font = HEADERFONT
	local font_size = 15

	local function ScrollWidgetsCtor(context, index)
		local w = Widget("fertilizer-cell-".. index)
		w.cell_root = w:AddChild(Image("images/plantregistry.xml", "plant_entry.tex"))

		w.focus_forward = w.cell_root

		w.cell_root.ongainfocusfn = function()
			self.fertilizer_grid:OnWidgetFocus(w)
		end

		w.fertilizer_seperator = w.cell_root:AddChild(Image("images/plantregistry.xml", "plant_entry_seperator.tex"))
		w.fertilizer_seperator:SetPosition(0, 75)

		local _OnGainFocus = w.cell_root.OnGainFocus
		function w.cell_root.OnGainFocus()
			_OnGainFocus(w.cell_root)
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover", nil, ClickMouseoverSoundReduction())
			w.fertilizer_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			w.cell_root:SetTexture("images/plantregistry.xml", "plant_entry_focus.tex")
			w.fertilizer_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_focus.tex")
		end
		local _OnLoseFocus = w.cell_root.OnLoseFocus
		function w.cell_root.OnLoseFocus()
			_OnLoseFocus(w.cell_root)
			if w.data and ThePlantRegistry:KnowsFertilizer(w.data.fertilizer) then
				w.cell_root:SetTexture("images/plantregistry.xml", "plant_entry_active.tex")
				w.fertilizer_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator_active.tex")
				w.fertilizer_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
			else
				w.cell_root:SetTexture("images/plantregistry.xml", "plant_entry.tex")
				w.fertilizer_seperator:SetTexture("images/plantregistry.xml", "plant_entry_seperator.tex")
				w.fertilizer_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			end
		end

		w.fertilizer_label = w.cell_root:AddChild(Text(font, font_size))
		w.fertilizer_label:SetPosition(0, 93)
		--w.fertilizer_label:SetRegionSize( width_label, height )
		w.fertilizer_label:SetHAlign( ANCHOR_MIDDLE )
		w.fertilizer_label:SetVAlign( ANCHOR_MIDDLE )

		w.fertilizer_icon = w.cell_root:AddChild(Image("images/plantregistry.xml", "missing.tex"))
		w.fertilizer_icon:ScaleToSize(item_size, item_size)
		w.fertilizer_icon:SetPosition(0, 75 - 5 - (item_size / 2))

		w.nutrient_icons = {}
		for i = 1, 3 do

			local nutrient_icon = w.cell_root:AddChild(Image("images/plantregistry.xml", "nutrient_"..i..".tex"))
			nutrient_icon:ScaleToSize(nutrient_size, nutrient_size)
			nutrient_icon:SetPosition(-1 - nutrient_size / 2, -5 - ((nutrient_size+18)*(i-1)))

			local arrow_icon = w.cell_root:AddChild(Image("images/plantregistry.xml", "nutrient_neutral.tex"))
			arrow_icon:ScaleToSize(nutrient_size, nutrient_size)
			arrow_icon:SetPosition(1 + nutrient_size / 2, -5 - ((nutrient_size+18)*(i-1)))

			w.nutrient_icons[i] = {arrow_icon = arrow_icon, nutrient_icon = nutrient_icon}
		end

		w.fertilizer_locked = w.cell_root:AddChild(Image("images/plantregistry.xml", "locked.tex"))
		w.fertilizer_locked:SetScale(0.5, 0.5)
		w.fertilizer_locked:SetPosition(0, -15)

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

			local fertilizer_label_str = ThePlantRegistry:KnowsFertilizer(data.fertilizer) and
				STRINGS.NAMES[data.def.name] or
				STRINGS.UI.PLANTREGISTRY.MYSTERY_FERTILIZER
			widget.fertilizer_label:SetMultilineTruncatedString(fertilizer_label_str, 2, width_label)

			if fertilizer_label_str == STRINGS.UI.PLANTREGISTRY.MYSTERY_FERTILIZER then
				widget.fertilizer_label:SetColour(PLANTREGISTRYUICOLOURS.LOCKEDBROWN)
			else
				widget.fertilizer_label:SetColour(PLANTREGISTRYUICOLOURS.UNLOCKEDBROWN)
			end

			if ThePlantRegistry:KnowsFertilizer(data.fertilizer) then
				widget.cell_root:SetTexture("images/plantregistry.xml", "plant_entry_active.tex")
				local atlas = data.def.atlas or GetInventoryItemAtlas(data.def.inventoryimage)
				widget.fertilizer_icon:SetTexture(atlas, data.def.inventoryimage)
				widget.fertilizer_icon:ScaleToSize(item_size, item_size)
				widget.fertilizer_icon:Show()
				for i, d in ipairs(widget.nutrient_icons) do
					local nutrient_count = data.def.nutrients[i]

					local imagename
					if nutrient_count == 0 then
						imagename = "nutrient_neutral.tex"
					else
						local nutrients_modifier_num = math.min(4, math.ceil(nutrient_count / 8) ) --(nutrient_count < 4 and 1) or (nutrient_count >= 8 and 4) or 2
						imagename = "nutrient_up_"..nutrients_modifier_num..".tex"
					end
					d.arrow_icon:SetTexture("images/plantregistry.xml", imagename)

					d.nutrient_icon:Show()
					d.arrow_icon:Show()
				end
				widget.fertilizer_locked:Hide()
			else
				widget.cell_root:SetTexture("images/plantregistry.xml", "plant_entry.tex")
				widget.fertilizer_icon:Hide()
				for i, d in ipairs(widget.nutrient_icons) do
					d.nutrient_icon:Hide()
					d.arrow_icon:Hide()
				end
				widget.fertilizer_locked:Show()
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

return FertilizersPage