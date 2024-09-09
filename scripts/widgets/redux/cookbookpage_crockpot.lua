local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

require("util")

local FILTER_ALL = "ALL"

local cooking = require("cooking")

local function MakeDetailsLine(details_root, x, y, scale, image_override)
	local value_title_line = details_root:AddChild(Image("images/quagmire_recipebook.xml", image_override or "quagmire_recipe_line.tex"))
	value_title_line:SetScale(scale, scale)
	value_title_line:SetPosition(x, y)
end

-------------------------------------------------------------------------------------------------------
local CookbookPageCrockPot = Class(Widget, function(self, parent_screen, category)
    Widget._ctor(self, "CookbookPageCrockPot")

    self.parent_screen = parent_screen
	self.category = category or "cookbook"

	self:CreateRecipeBook()
	--
	--if TheWorld ~= nil then
	--	self.inst:ListenForEvent("quagmire_refreshrecipbookwidget", function() self:OnRecipeBookUpdated() end, TheWorld)
	--end
	--
	self:_DoFocusHookups()

	return self
end)

function CookbookPageCrockPot:_DoFocusHookups()
	if self.spinners then
		for i, v in ipairs(self.spinners) do
			v:ClearFocusDirs()

			if i > 1 then
				v:SetFocusChangeDir(MOVE_UP, self.spinners[i-1])
			end
			if i < #self.spinners then
				v:SetFocusChangeDir(MOVE_DOWN, self.spinners[i+1])
			end
		end

		local reset_default_focus = self.parent_default_focus ~= nil and self.parent_screen ~= nil and self.parent_screen.default_focus == self.parent_default_focus

		if self.recipe_grid.items ~= nil and #self.recipe_grid.items > 0 then
			self.spinners[#self.spinners]:SetFocusChangeDir(MOVE_DOWN, self.recipe_grid)
			self.recipe_grid:SetFocusChangeDir(MOVE_UP, self.spinners[#self.spinners])

			self.parent_default_focus = self.recipe_grid
			self.focus_forward = self.recipe_grid
		else
			self.parent_default_focus = self.spinners[1]
			self.focus_forward = self.spinners[1]
		end
	end
end


function CookbookPageCrockPot:CreateRecipeBook()
	local panel_root = self
	-----------
	self.gridroot = panel_root:AddChild(Widget("grid_root"))
    self.gridroot:SetPosition(-180, -35)

    self.recipe_grid = self.gridroot:AddChild( self:BuildRecipeBook() )
    self.recipe_grid:SetPosition(-15, 0)
	local grid_w, grid_h = self.recipe_grid:GetScrollRegionSize()

	local boarder_scale = 0.75
	local grid_boarder = self.gridroot:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, boarder_scale)
    grid_boarder:SetPosition(-3, grid_h/2 + 1)
	grid_boarder = self.gridroot:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_line.tex"))
	grid_boarder:SetScale(boarder_scale, -boarder_scale)
    grid_boarder:SetPosition(-3, -grid_h/2)

	-----------
	local details_decor_root = panel_root:AddChild(Widget("details_root"))
	details_decor_root:SetPosition(grid_w/2 + 30, 0)

	local details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_block.tex"))
    details_decor:ScaleToSize(360, 500)
	details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
    details_decor:ScaleToSize(100, 100)
	details_decor:SetPosition(-120, -190)
	details_decor = details_decor_root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_corner_decoration.tex"))
    details_decor:ScaleToSize(-100, 100)
	details_decor:SetPosition(120, -190)


	self.details_root = panel_root:AddChild(Widget("details_root"))
	self.details_root:SetPosition(details_decor_root:GetPosition())
	self.details_root.panel_width = 350
	self.details_root.panel_height = 500

	-----------
	self.spinner_root = self.gridroot:AddChild(self:BuildSpinners())
	self.spinner_root:SetPosition(0, grid_h/2 + 5)

	-----------
	local dis_x = -310
	local dis_y = 238
	dis_y = dis_y - 18/2
    local completed = panel_root:AddChild(Text(HEADERFONT, 18, STRINGS.UI.COOKBOOK.DISCOVERED_RECIPES, UICOLOURS.BROWN_DARK))
	completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(dis_x, dis_y)
	dis_y = dis_y - 18/2
	MakeDetailsLine(panel_root, dis_x, dis_y-4, .5, "quagmire_recipe_line_short.tex")
	dis_y = dis_y - 10
	dis_y = dis_y - 18/2
    completed = panel_root:AddChild(Text(HEADERFONT, 18, subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num=self.num_recipes_discovered, max=#self.all_recipes}), UICOLOURS.BROWN_DARK))
	completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(dis_x, dis_y)
	dis_y = dis_y - 18/2

	self.details_root:AddChild(self:PopulateRecipeDetailPanel(self.all_recipes[ (TheCookbook.selected ~= nil and TheCookbook.selected[self.category] or 1) ]))

	self:ApplyFilters()
	self.recipe_grid:RefreshView()
end

local ingredient_icon_remap = {}
ingredient_icon_remap.onion = "quagmire_onion"
ingredient_icon_remap.tomato = "quagmire_tomato"
ingredient_icon_remap.acorn = "acorn_cooked"
ingredient_icon_remap.trunk = "trunk_cooked"

local ingredient_name_remap = {}
ingredient_name_remap.acorn = "acorn_cooked"
ingredient_name_remap.trunk = "trunk_cooked"

function CookbookPageCrockPot:_SetupRecipeIngredientDetails(recipes, parent, y)
	local ingredient_size = 30
	local x_spacing = 2

	local inv_backing_root = parent:AddChild(Widget("inv_backing_root"))
	local inv_item_root = parent:AddChild(Widget("inv_item_root"))
	local index = 1

	if #recipes <= 3 then
		for b = 1, #recipes do
			local items = recipes[index]
			local x = -((#items + 1)*ingredient_size + (#items-1)*x_spacing) / 2
			for i = 1, #items do
				local backing = inv_backing_root:AddChild(Image("images/quagmire_recipebook.xml", "ingredient_slot.tex"))
				backing:ScaleToSize(ingredient_size, ingredient_size)
				backing:SetPosition(x + (i)*ingredient_size + (i-1)*x_spacing, y - ingredient_size/2 - (b-1)*(ingredient_size+5))

				local img_name = (ingredient_icon_remap[items[i]] or items[i])..".tex"
				local img_atlas = GetInventoryItemAtlas(img_name, true)
				local img = inv_item_root:AddChild(Image(img_atlas or "images/quagmire_recipebook.xml", img_atlas ~= nil and img_name or "cookbook_missing.tex"))

				img:ScaleToSize(ingredient_size, ingredient_size)
				img:SetPosition(backing:GetPosition())
				img:SetHoverText(STRINGS.NAMES[string.upper(ingredient_name_remap[items[i]] or items[i])] or subfmt(STRINGS.UI.COOKBOOK.UNKNOWN_INGREDIENT_NAME, {ingredient = items[i]}))
			end
			index = index + 1
		end
	else
		local width = ((4)*ingredient_size + (4-1)*x_spacing)
		local column_spacing_offset = 5
		for b = 1, #recipes do
			local items = recipes[index]
			local x = (b%2 == 1) and (-width - ingredient_size + column_spacing_offset) or -column_spacing_offset
			for i = 1, #items do
				local backing = inv_backing_root:AddChild(Image("images/quagmire_recipebook.xml", "ingredient_slot.tex"))
				backing:ScaleToSize(ingredient_size, ingredient_size)
				backing:SetPosition(x + (i)*ingredient_size + (i-1)*x_spacing, y - ingredient_size/2 - math.floor((b-1)/2)*(ingredient_size+5))

				local img_name = (ingredient_icon_remap[items[i]] or items[i])..".tex"
				local img_atlas = GetInventoryItemAtlas(img_name, true)
				local img = inv_item_root:AddChild(Image(img_atlas or "images/quagmire_recipebook.xml", img_atlas ~= nil and img_name or "cookbook_missing.tex"))
				img:ScaleToSize(ingredient_size, ingredient_size)
				img:SetPosition(backing:GetPosition())
				img:SetHoverText(STRINGS.NAMES[string.upper(ingredient_name_remap[items[i]] or items[i])] or subfmt(STRINGS.UI.COOKBOOK.UNKNOWN_INGREDIENT_NAME, {ingredient = items[i]}))
			end
			index = index + 1
		end
	end
end

function CookbookPageCrockPot:_GetSpoilString(perishtime)
	return perishtime == nil and STRINGS.UI.COOKBOOK.PERISH_NEVER
			or perishtime <= TUNING.PERISH_SUPERFAST and STRINGS.UI.COOKBOOK.PERISH_VERY_QUICKLY
			or perishtime <= TUNING.PERISH_FAST and STRINGS.UI.COOKBOOK.PERISH_QUICKLY
			or perishtime <= TUNING.PERISH_MED and STRINGS.UI.COOKBOOK.PERISH_AVERAGE
			or perishtime <= TUNING.PERISH_SLOW and STRINGS.UI.COOKBOOK.PERISH_SLOWLY
			or STRINGS.UI.COOKBOOK.PERISH_VERY_SLOWLY
end

function CookbookPageCrockPot:_GetCookingTimeString(cooktime)
	return cooktime == nil and STRINGS.UI.COOKBOOK.COOKINGTIME_UNKNOWN
			or cooktime < 1.0 and STRINGS.UI.COOKBOOK.COOKINGTIME_SHORT
			or cooktime < 2.0 and STRINGS.UI.COOKBOOK.COOKINGTIME_AVERAGE
			or cooktime < 2.5 and STRINGS.UI.COOKBOOK.COOKINGTIME_LONG
			or STRINGS.UI.COOKBOOK.COOKINGTIME_VERY_LONG
end

function CookbookPageCrockPot:_GetSideEffectString(recipe_def)
	return  recipe_def.oneat_desc
			or (recipe_def.temperature ~= nil and recipe_def.temperature > 0) and STRINGS.UI.COOKBOOK.FOOD_EFFECTS_HOT_FOOD
			or (recipe_def.temperature ~= nil and recipe_def.temperature < 0) and STRINGS.UI.COOKBOOK.FOOD_EFFECTS_COLD_FOOD
			or STRINGS.UI.COOKBOOK.FOOD_EFFECTS_NONE
end

function CookbookPageCrockPot:PopulateRecipeDetailPanel(data)
	local top = self.details_root.panel_height/2
	local left = -self.details_root.panel_width / 2

	if data.recipe_def.custom_cookbook_details_fn ~= nil then
		-- Modders can define this on a preparedfoods definition table if they use this if they want to have their own custom display.
		return data.recipe_def.custom_cookbook_details_fn(data, self, top, left)
	end

	local details_root = Widget("details_root")

	local y = top - 11

	local image_size = 110

	local name_font_size = 34
	local title_font_size = 18 --22
	local body_font_size = 16 --18
	local value_title_font_size = 18
	local value_body_font_size = 16

	y = y - name_font_size/2
	local title = details_root:AddChild(Text(HEADERFONT, name_font_size, data.unlocked and data.name or STRINGS.UI.RECIPE_BOOK.UNKNOWN_RECIPE, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, y)
	y = y - name_font_size/2 - 4
	MakeDetailsLine(details_root, 0, y-10, -.55, "quagmire_recipe_line_break.tex")
	y = y - 30

	if not data.unlocked then
		local msg = details_root:AddChild(Text(HEADERFONT, body_font_size, "", UICOLOURS.BROWN_DARK))
		msg:SetMultilineTruncatedString(STRINGS.UI.COOKBOOK.LOCKED_RECIPE[self.category] or STRINGS.UI.COOKBOOK.LOCKED_RECIPE.COOKPOT, 20, 300)
		local _, msg_h = msg:GetRegionSize()
		y = y - msg_h/2
		msg:SetPosition(0, y)
		y = y - body_font_size/2 - 4

	else
		local icon_size = image_size - 20

		local frame = details_root:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_known.tex"))
		frame:ScaleToSize(image_size, image_size)
		y = y - image_size/2
		frame:SetPosition(left + image_size/2 + 30, y)
		y = y - image_size/2

		local portrait_root = details_root:AddChild(Widget("portrait_root"))
		portrait_root:SetPosition(frame:GetPosition())

		local food_img = portrait_root:AddChild(Image(data.food_atlas, not data.unlocked and "cookbook_unknown.tex" or data.food_tex))
		food_img:ScaleToSize(icon_size, icon_size)

		local details_x = 60
		if data.has_eaten then
			local details_y = y + 85
			local status_scale = 0.7

			local health = data.recipe_def.health ~= nil and math.floor(10*data.recipe_def.health)/10 or nil
			self.health_status = details_root:AddChild(TEMPLATES.MakeUIStatusBadge((health ~= nil and health >= 0) and "health" or "health_bad"))
			self.health_status:SetPosition(details_x-60, details_y)
			self.health_status.status_value:SetString(health or STRINGS.UI.COOKBOOK.STAT_UNKNOWN)
			self.health_status:SetScale(status_scale)

			local hunger = data.recipe_def.hunger ~= nil and math.floor(10*data.recipe_def.hunger)/10 or nil
			self.hunger_status = details_root:AddChild(TEMPLATES.MakeUIStatusBadge((hunger ~= nil and hunger >= 0) and "hunger" or "hunger_bad"))
			self.hunger_status:SetPosition(details_x, details_y)
			self.hunger_status.status_value:SetString(hunger or STRINGS.UI.COOKBOOK.STAT_UNKNOWN)
			self.hunger_status:SetScale(status_scale)

			local sanity = data.recipe_def.sanity ~= nil and math.floor(10*data.recipe_def.sanity)/10 or nil
			self.sanity_status = details_root:AddChild(TEMPLATES.MakeUIStatusBadge((sanity ~= nil and sanity >= 0) and "sanity" or "sanity_bad"))
			self.sanity_status:SetPosition(details_x+60, details_y)
			self.sanity_status.status_value:SetString(sanity or STRINGS.UI.COOKBOOK.STAT_UNKNOWN)
			self.sanity_status:SetScale(status_scale)

			details_y = details_y - 42

			-- Side Effects
			local effects_str = self:_GetSideEffectString(data.recipe_def)
			if effects_str then
				details_y = details_y - value_title_font_size/2
				title = details_root:AddChild(Text(HEADERFONT, value_title_font_size, STRINGS.UI.COOKBOOK.FOOD_EFFECTS_TITLE, UICOLOURS.BROWN_DARK))
				title:SetPosition(details_x, details_y)
				details_y = details_y - value_title_font_size/2
				MakeDetailsLine(details_root, details_x, details_y - 2, .5, "quagmire_recipe_line_short.tex")
				details_y = details_y - 8
				details_y = details_y - value_body_font_size/2
				local effects = details_root:AddChild(Text(HEADERFONT, value_body_font_size, "", UICOLOURS.BROWN_DARK))
				effects:SetMultilineTruncatedString(effects_str, 1, 190, nil, "...")
				effects:SetPosition(details_x, details_y)
				details_y = details_y - value_body_font_size/2 - 4
			end
		else
			local msg = details_root:AddChild(Text(HEADERFONT, body_font_size, "", UICOLOURS.BROWN_DARK))
			msg:SetMultilineTruncatedString(STRINGS.UI.COOKBOOK.LOCKED_STATS, 5, 180)
			local details_y = frame:GetPosition().y
			msg:SetPosition(details_x, details_y)
		end

		y = y - 12

		local row_start_y = y
		local column_offset_x = 80

		-- Food Type
		y = y - title_font_size/2
		title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.FOOD_TYPE_TITLE, UICOLOURS.BROWN_DARK))
		title:SetPosition(-column_offset_x, y)
		y = y - title_font_size/2
		MakeDetailsLine(details_root, -column_offset_x, y - 2, .5, "quagmire_recipe_line_veryshort.tex")
		y = y - 8
		y = y - body_font_size/2
		local str = STRINGS.UI.FOOD_TYPES[data.recipe_def.foodtype or FOODTYPE.GENERIC]  or STRINGS.UI.COOKBOOK.FOOD_TYPE_UNKNOWN
		local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, UICOLOURS.BROWN_DARK))
		tags:SetPosition(-column_offset_x, y)
		y = y - body_font_size/2 - 4

		y = row_start_y

		-- Perish Rate
		y = y - title_font_size/2
		title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.PERISH_RATE_TITLE, UICOLOURS.BROWN_DARK))
		title:SetPosition(column_offset_x, y)
		y = y - title_font_size/2
		MakeDetailsLine(details_root, column_offset_x, y - 2, .5, "quagmire_recipe_line_veryshort.tex")
		y = y - 8
		y = y - body_font_size/2
		local str = self:_GetSpoilString(data.recipe_def.perishtime)
		local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, UICOLOURS.BROWN_DARK))
		tags:SetPosition(column_offset_x, y)
		y = y - body_font_size/2 - 4

		y = y - 10

		if data.recipes ~= nil and #data.recipes > 0 then
			-- Cooking Time
			y = y - title_font_size/2
			title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.COOKINGTIME_TITLE, UICOLOURS.BROWN_DARK))
			title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 8
			y = y - body_font_size/2 - 4
			local str = self:_GetCookingTimeString(data.recipes ~= nil and data.recipe_def.cooktime or nil)
			local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, UICOLOURS.BROWN_DARK))
			tags:SetPosition(0, y)
			y = y - body_font_size/2 - 4

			y = y - 10

			-- INGREDIENTS
			y = y - title_font_size/2
			title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_RECIPES, UICOLOURS.BROWN_DARK))
			title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10

			self:_SetupRecipeIngredientDetails(data.recipes, details_root, y)
		else
			y = y - title_font_size/2
			title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.COOKBOOK.NO_RECIPES_TITLE, UICOLOURS.BROWN_DARK))
			title:SetPosition(0, y)
			y = y - title_font_size/2
			MakeDetailsLine(details_root, 0, y - 2, .49)
			y = y - 10

			y = y - body_font_size/2

			local body = details_root:AddChild(Text(HEADERFONT, body_font_size, "", UICOLOURS.BROWN_DARK))
			body:SetMultilineTruncatedString(STRINGS.UI.COOKBOOK.NO_RECIPES_DESC, 20, 300)
			local _, msg_h = body:GetRegionSize()
			y = y - msg_h/2
			body:SetPosition(0, y)
		end
	end

	return details_root
end

function CookbookPageCrockPot:BuildRecipeBook()
    local base_size = 128
    local cell_size = 73
    local row_w = cell_size
    local row_h = cell_size;
    local reward_width = 80
    local row_spacing = 5

	local food_size = cell_size + 20
	local icon_size = 20 / (cell_size/base_size)

    local function ScrollWidgetsCtor(context, index)
        local w = Widget("recipe-cell-".. index)

		----------------
		w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "cookbook_unknown.tex", "cookbook_unknown_selected.tex"))
		w.cell_root:SetFocusScale(cell_size/base_size + .05, cell_size/base_size + .05)
		w.cell_root:SetNormalScale(cell_size/base_size, cell_size/base_size)

		w.focus_forward = w.cell_root

        w.cell_root.ongainfocusfn = function() self.recipe_grid:OnWidgetFocus(w) end

		----------------
		w.recipie_root = w.cell_root.image:AddChild(Widget("recipe_root"))

        w.food_img = w.recipie_root:AddChild(Image("images/global.xml", "square.tex")) -- this will be replaced with the food icon

		w.partiallyknown_icon = w.recipie_root:AddChild(Image("images/quagmire_recipebook.xml", "cookbook_unknown_icon.tex"))
		w.partiallyknown_icon:ScaleToSize(icon_size, icon_size)
        w.partiallyknown_icon:SetPosition(-base_size/2 + 22, base_size/2 - 25)

		w.isnew_anim = w.recipie_root:AddChild(UIAnim())
        w.isnew_anim:GetAnimState():SetBank("cookbook_newrecipe")
        w.isnew_anim:GetAnimState():SetBuild("cookbook_newrecipe")
        w.isnew_anim:GetAnimState():PlayAnimation("anim", true)
        w.isnew_anim:GetAnimState():SetTime(math.random() * w.isnew_anim:GetAnimState():GetCurrentAnimationLength())
		w.isnew_anim:SetPosition(base_size/2 - 22, base_size/2 - 25)

		w.cell_root:SetOnClick(function()
			self.details_root:KillAllChildren()
			self.details_root:AddChild(self:PopulateRecipeDetailPanel(w.data))

			if TheCookbook.newfoods ~= nil then
				TheCookbook.newfoods[w.data.prefab] = nil
				w.isnew_anim:Hide()
			end

			if TheCookbook.selected == nil then
				TheCookbook.selected = {}
			end
			TheCookbook.selected[self.category] = w.data.index

		end)

		----------------
		return w

    end

    local function ScrollWidgetSetData(context, widget, data, index)
		widget.data = data
		if data ~= nil then
			widget.cell_root:Show()

			if data.unlocked then
				widget.recipie_root:Show()
				widget.cell_root:SetTextures("images/quagmire_recipebook.xml", "cookbook_known.tex", "cookbook_known_selected.tex")

				widget.food_img:SetTexture(data.food_atlas, not data.unlocked and "cookbook_unknown.tex" or data.food_tex)
				widget.food_img:ScaleToSize(food_size, food_size)

				if data.recipes == nil or not data.has_eaten then
					widget.partiallyknown_icon:Show()
				else
					widget.partiallyknown_icon:Hide()
				end

				if TheCookbook:IsNewFood(data.prefab) then
					widget.isnew_anim:Show()
				else
					widget.isnew_anim:Hide()
				end
			else
				widget.recipie_root:Hide()
				widget.cell_root:SetTextures("images/quagmire_recipebook.xml", "cookbook_unknown.tex", "cookbook_unknown_selected.tex")
			end
			widget:Enable()
		else
			widget:Disable()
			widget.cell_root:Hide()
		end
    end

    self.all_recipes = {}
	self.filtered_recipes = {}
	self.num_recipes_discovered = 0
	self.num_foods_eaten = 0

	local known_recipe_list = TheCookbook.preparedfoods or {}

	local cookbook_recipes = cooking.cookbook_recipes[self.category]
	for prefab, recipe_def in pairs(cookbook_recipes) do
		--print("recipe: ", self.category, recipe_def.cookbook_category, prefab)
		local data = {
			prefab = prefab,
			name = STRINGS.NAMES[string.upper(prefab)] or subfmt(STRINGS.UI.COOKBOOK.UNKNOWN_FOOD_NAME, {food = prefab or "SDF"}),
			recipe_def = recipe_def,
			defaultsortkey = hash(prefab),
			food_atlas = "images/quagmire_recipebook.xml",
			food_tex = "cookbook_unknown.tex",
		}

		local known_data = known_recipe_list[prefab]
		if known_data ~= nil then
			data.unlocked = true
			data.has_eaten = known_data.has_eaten
			data.recipes = (known_data.recipes ~= nil and next(known_data.recipes) ~= nil) and known_data.recipes or nil

			local img_name = recipe_def.cookbook_tex or (prefab..".tex")
			local atlas = recipe_def.cookbook_atlas or GetInventoryItemAtlas(img_name, true)
			if atlas ~= nil then
				data.food_atlas = atlas
				data.food_tex = img_name
			else
				data.food_tex = "cookbook_missing.tex"
			end

			if data.has_eaten then
				self.num_foods_eaten = self.num_foods_eaten + 1
			end
			if data.recipes ~= nil then
				self.num_recipes_discovered = self.num_recipes_discovered + 1
			end
		end

		table.insert(self.all_recipes, data)
	end

	table.sort(self.all_recipes, function(a, b) return self:_sortfn_default(a, b) end)
	for i, data in ipairs(self.all_recipes) do
		data.index = i
	end

    local grid = TEMPLATES.ScrollingGrid(
        {},
        {
            context = {},
            widget_width  = row_w+row_spacing,
            widget_height = row_h+row_spacing,
			force_peek    = true,
            num_visible_rows = 5,
            num_columns      = 5,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetSetData,
            scrollbar_offset = 20,
            scrollbar_height_offset = -60
        })

	grid.up_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid.up_button:SetScale(0.5)

	grid.down_button:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_arrow_hover.tex")
    grid.down_button:SetScale(-0.5)

	grid.scroll_bar_line:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_bar.tex")
	grid.scroll_bar_line:SetScale(.8)

	grid.position_marker:SetTextures("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
	grid.position_marker.image:SetTexture("images/quagmire_recipebook.xml", "quagmire_recipe_scroll_handle.tex")
    grid.position_marker:SetScale(.6)

    return grid
end

function CookbookPageCrockPot:_sortfn_default(a, b)
	return a.recipe_def.priority > b.recipe_def.priority or (a.recipe_def.priority == b.recipe_def.priority and a.defaultsortkey > b.defaultsortkey)
end

function CookbookPageCrockPot:_sortfn_sideeffects(a, b)
	local a_score = not a.unlocked and 0
				or not a.has_eaten and 1
				or (a.recipe_def.oneat_desc == nil and a.recipe_def.temperature == nil) and 2
				or 3

	local b_score = not b.unlocked and 0
				or not b.has_eaten and 1
				or (b.recipe_def.oneat_desc == nil and b.recipe_def.temperature == nil) and 2
				or 3

	if a_score == 3 and b_score == 3 then
		local a_effect = self:_GetSideEffectString(a.recipe_def)
		local b_effect = self:_GetSideEffectString(b.recipe_def)

		return a_effect < b_effect or (a_effect == b_effect and a.name < b.name)
	end

	return a_score > b_score or (a_score == b_score and a.name < b.name)
end

function CookbookPageCrockPot:ApplySort()
	local sortby = TheCookbook:GetFilter("sort")
	table.sort(self.filtered_recipes,
			sortby == "alphabetical"	and function(a, b) return a.unlocked and not b.unlocked or (a.unlocked and b.unlocked and a.name < b.name) end
		or	sortby == "health"			and function(a, b) return (a.unlocked and not b.unlocked) or (a.has_eaten and not b.has_eaten) or (a.has_eaten and ((a.recipe_def.health > b.recipe_def.health) or (a.recipe_def.health == b.recipe_def.health and a.name < b.name))) end
		or	sortby == "hunger"			and function(a, b) return (a.unlocked and not b.unlocked) or (a.has_eaten and not b.has_eaten) or (a.has_eaten and ((a.recipe_def.hunger > b.recipe_def.hunger) or (a.recipe_def.hunger == b.recipe_def.hunger and a.name < b.name))) end
		or	sortby == "sanity"			and function(a, b) return (a.unlocked and not b.unlocked) or (a.has_eaten and not b.has_eaten) or (a.has_eaten and ((a.recipe_def.sanity > b.recipe_def.sanity) or (a.recipe_def.sanity == b.recipe_def.sanity and a.name < b.name))) end
		or	sortby == "sideeffects"		and function(a, b) return self:_sortfn_sideeffects(a, b) end
		or									function(a, b) return self:_sortfn_default(a, b) end
	)

    self.recipe_grid:SetItemsData(self.filtered_recipes)
	self:_DoFocusHookups()
end

function CookbookPageCrockPot:ApplyFilters()
	local filterby = TheCookbook:GetFilter("filter")

	self.filtered_recipes = {}

	for i, item in ipairs(self.all_recipes) do
		local foodtype = item.recipe_def.foodtype or FOODTYPE.GENERIC
		if (filterby == FILTER_ALL)
			or (filterby == FOODTYPE.MEAT		and foodtype == FOODTYPE.MEAT)
			or (filterby == FOODTYPE.VEGGIE		and foodtype == FOODTYPE.VEGGIE)
			or (filterby == "OTHER"				and foodtype ~= FOODTYPE.MEAT and foodtype ~= FOODTYPE.VEGGIE)
			or (filterby == "SIDEEFFECTS"		and (item.recipe_def.oneat_desc ~= nil or item.recipe_def.temperature ~= nil))
			or (filterby == "INCOMPLETE"		and (item.recipes == nil or not item.has_eaten))
			then

			table.insert(self.filtered_recipes, item)
		end
	end

	self:ApplySort()
end

function CookbookPageCrockPot:BuildSpinners()
	local root = Widget("spinner_root")

	local top = 50
	local left = 0 -- -width/2 + 5

	local sort_options = {
		{text = STRINGS.UI.COOKBOOK.SORT_DEFAULT,		data = "default"},
		{text = STRINGS.UI.COOKBOOK.SORT_ALPHABETICAL,	data = "alphabetical"},
		{text = STRINGS.UI.COOKBOOK.SORT_HEALTH,		data = "health"},
		{text = STRINGS.UI.COOKBOOK.SORT_HUNGER,		data = "hunger"},
		{text = STRINGS.UI.COOKBOOK.SORT_SANITY,		data = "sanity"},
		{text = STRINGS.UI.COOKBOOK.SORT_SIDE_EFFECTS,	data = "sideeffects"},
	}
	local function on_sort_fn( data )
		TheCookbook:SetFilter("sort", data)
		self:ApplySort()
	end

	local filter_options = {
		{text = STRINGS.UI.COOKBOOK.FILTER_ALL,			data = FILTER_ALL},
		{text = STRINGS.UI.COOKBOOK.FILTER_MEAT,		data = FOODTYPE.MEAT},
		{text = STRINGS.UI.COOKBOOK.FILTER_VEGGIE,		data = FOODTYPE.VEGGIE},
		{text = STRINGS.UI.COOKBOOK.FILTER_OTHER,		data = "OTHER"},
		{text = STRINGS.UI.COOKBOOK.FILTER_SIDE_EFFECTS,data = "SIDEEFFECTS"},
		{text = STRINGS.UI.COOKBOOK.FILTER_INCOMPLETE  ,data = "INCOMPLETE"},
	}
	local function on_filter_fn( data )
		TheCookbook:SetFilter("filter", data)
		self:ApplyFilters()
	end

	local width_label = 150
	local width_spinner = 150
	local height = 25

	local function MakeSpinner(labeltext, spinnerdata, onchanged_fn, initial_data)
		local spacing = 5
		local font = HEADERFONT
		local font_size = 18

		local total_width = width_label + width_spinner + spacing
		local wdg = Widget("labelspinner")
		wdg.label = wdg:AddChild( Text(font, font_size, labeltext) )
		wdg.label:SetPosition( (-total_width/2)+(width_label/2), 0 )
		wdg.label:SetRegionSize( width_label, height )
		wdg.label:SetHAlign( ANCHOR_RIGHT )
		wdg.label:SetColour(UICOLOURS.BROWN_DARK)

		local lean = true
		wdg.spinner = wdg:AddChild(Spinner(spinnerdata, width_spinner, height, {font = font, size = font_size}, nil, "images/quagmire_recipebook.xml", nil, lean))
		wdg.spinner:SetTextColour(UICOLOURS.BROWN_DARK)
		wdg.spinner:SetOnChangedFn(onchanged_fn)
		wdg.spinner:SetPosition((total_width/2)-(width_spinner/2), 0)
		wdg.spinner:SetSelected(initial_data)

		return wdg
	end

	TheCookbook:SetFilter("sort", TheCookbook:GetFilter("sort") or "default")
	TheCookbook:SetFilter("filter", TheCookbook:GetFilter("filter") or FILTER_ALL)


	local items = {}
	table.insert(items, MakeSpinner(STRINGS.UI.COOKBOOK.SORT_SPINNERLABEL, sort_options, on_sort_fn, TheCookbook:GetFilter("sort")))
	table.insert(items, MakeSpinner(STRINGS.UI.COOKBOOK.FILTER_SPINNERLABEL, filter_options, on_filter_fn, TheCookbook:GetFilter("filter")))

	self.spinners = {}
	for i, v in ipairs(items) do
		local w = root:AddChild(v)
		w:SetPosition(50, (#items - i + 1)*(height + 3))
		table.insert(self.spinners, w.spinner)
	end


	return root
end

return CookbookPageCrockPot
