local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"

local TEMPLATES = require "widgets/redux/templates"

require("util")

local QUAGMIRE_NUM_FOOD_RECIPES = QUAGMIRE_NUM_FOOD_PREFABS + 1 -- +1 for syrup
local DISH_ATLAS = "images/quagmire_food_common_inv_images_hires.xml" --"images/quagmire_food_common_inv_images_hires.xml"

local FILTER_ANY = "any"

local function MakeDetailsLine(details_root, x, y, scale, image_override)
	local value_title_line = details_root:AddChild(Image("images/quagmire_recipebook.xml", image_override or "quagmire_recipe_line.tex"))
	value_title_line:SetScale(scale, scale)
	value_title_line:SetPosition(x, y)
end


-------------------------------------------------------------------------------------------------------
local QuagmireRecipeBook = Class(Widget, function(self, parent_screen, season)
    Widget._ctor(self, "QuagmireRecipeBook")

    self.parent_screen = parent_screen
	self:CreateRecipeBook()

	if TheWorld ~= nil then
		self.inst:ListenForEvent("quagmire_refreshrecipbookwidget", function() self:OnRecipeBookUpdated() end, TheWorld)
	end

	self:_DoFocusHookups()

	return self
end)

function QuagmireRecipeBook:_DoFocusHookups()
	if not self.spinners then return end
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
	else
		self.parent_default_focus = self.spinners[1]
	end

    if reset_default_focus then
        self.parent_screen.default_focus = self.parent_default_focus
    end
end


function QuagmireRecipeBook:CreateRecipeBook()
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
	self.filters_root = self.gridroot:AddChild(self:BuildFilterPanel())
	self.filters_root:SetPosition(0, grid_h/2 + 5)

	-----------
	local dis_x = -310
	local dis_y = 238
	local unlocked, total = self.num_recipes_discovered, 68
	dis_y = dis_y - 18/2
    local completed = panel_root:AddChild(Text(HEADERFONT, 18, STRINGS.UI.RECIPE_BOOK.DISCOVERED_RECIPES, UICOLOURS.BROWN_DARK))
	completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(dis_x, dis_y)
	dis_y = dis_y - 18/2
	MakeDetailsLine(panel_root, dis_x, dis_y-4, .3)
	dis_y = dis_y - 10
	dis_y = dis_y - 18/2
    completed = panel_root:AddChild(Text(HEADERFONT, 18, subfmt(STRINGS.UI.XPUTILS.XPPROGRESS, {num=unlocked, max=QUAGMIRE_NUM_FOOD_RECIPES}), UICOLOURS.BROWN_DARK))
	completed:SetHAlign(ANCHOR_RIGHT)
	completed:SetPosition(dis_x, dis_y)
	dis_y = dis_y - 18/2


	if TheRecipeBook.selected ~= nil then
		self.details_root:AddChild(self:CreateRecipeDetailPanel(self.all_recipes[TheRecipeBook.selected]))
	end
end


local station_icons =
{
	pot = {small = "pot_small.tex", large = "pot.tex", syrup = "pot_syrup.tex"},
	oven = {small = "casseroledish_small.tex", large = "casseroledish.tex"},
	grill = {small = "grill_small.tex", large = "grill.tex"},
}

local function SetupValueDetails(dish, coins, parent, center, y, size)
	y = y - size/2
	local text_w = 30
	local total_coin_size = size + text_w

	-- text, coin, ##, coin, ##, coin, ##, coin, ##
	local root = parent:AddChild(Widget("value_root"))
	local width = 0
	for i = 1, 4 do
		local coin_num = 5 - i
		local coin_value = coins["coin"..tostring(coin_num)]
		if coin_value ~= nil then
			local value = root:AddChild(Text(HEADERFONT, size, tostring(coin_value), UICOLOURS.BROWN_DARK))
			value:SetRegionSize(text_w, 28)
			value:SetHAlign(ANCHOR_RIGHT)
			value:SetPosition(width + text_w/2 , y)

			local img_name = "quagmire_coin"..tostring(coin_num)..".tex"
			local coin = root:AddChild(Image(GetInventoryItemAtlas(img_name), img_name))
			coin:ScaleToSize(size, size)
			coin:SetPosition(width + text_w + size/2, y+1)
			coin:SetEffect("shaders/ui_cc.ksh")

			width = width + total_coin_size
		end
	end
	y = y - size/2 - 4

	root:SetPosition(center - width/2 - size/2, 0)

	return y
end

local ingredient_icon_fallback = {}
ingredient_icon_fallback.quagmire_carrot = "carrot"
ingredient_icon_fallback.quagmire_foliage = "foliage"

local function RecipeListSortFn(a, b)
	if #a < #b then
		return true
	elseif #a == #b then
		for i = 1, #a do
			if a[i] < b[i] then
				return true
			elseif a[i] > b[i] then
				return false
			end
		end
	end
	return false
end

local function SetupRecipeIngredientDetails(recipe, parent, y)
	local ingredient_size = 30
	local x_spacing = 2

	local inv_backing_root = parent:AddChild(Widget("inv_backing_root"))
	local inv_item_root = parent:AddChild(Widget("inv_item_root"))
	local index = 1

	local recipes = deepcopy(recipe.recipes)
	table.sort(recipes, RecipeListSortFn)

	for b = 1, #recipes do
		local items = recipes[index]
		local x = -((#items + 1)*ingredient_size + (#items-1)*x_spacing) / 2
		for i = 1, #items do
			local backing = inv_backing_root:AddChild(Image("images/quagmire_recipebook.xml", "ingredient_slot.tex"))
			backing:ScaleToSize(ingredient_size, ingredient_size)
			backing:SetPosition(x + (i)*ingredient_size + (i-1)*x_spacing, y - ingredient_size/2 - (b-1)*(ingredient_size+8))

			local img_name = (ingredient_icon_fallback[items[i]] or items[i])..".tex"
			local img = inv_item_root:AddChild(Image(GetInventoryItemAtlas(img_name), img_name))
			img:ScaleToSize(ingredient_size, ingredient_size)
			img:SetPosition(backing:GetPosition())
			img:SetEffect("shaders/ui_cc.ksh")
		end
		index = index + 1
	end
end

function QuagmireRecipeBook:CreateRecipeDetailPanel(data)
	local details_root = Widget("details_root")

	local silver_dish = (data.silver ~= nil and TheRecipeBook.filters["value"] == FILTER_ANY) or (data.silver == TheRecipeBook.filters["value"])

	local dish_img = (data.recipe ~= nil and data.recipe.dish ~= nil) and (data.recipe.dish .. (silver_dish and "_silver" or "") .. ".tex") or nil
	--local dish_img = (data.recipe ~= nil and data.recipe.dish ~= nil) and (data.recipe.dish .. ".tex") or nil

	local top = self.details_root.panel_height/2
	local left = -self.details_root.panel_width / 2

	local y = top - 11

	local image_size = 120

	local name_font_size = 34
	local title_font_size = 22
	local value_title_font_size = 18
	local value_body_font_size = 16
	local body_font_size = 20

	y = y - name_font_size/2
	local title = details_root:AddChild(Text(HEADERFONT, name_font_size, STRINGS.NAMES[string.upper(data.name)] or STRINGS.UI.RECIPE_BOOK.UNKNOWN_RECIPE, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, y )
	y = y - name_font_size/2 - 4
	MakeDetailsLine(details_root, 0, y-10, -.55, "quagmire_recipe_line_break.tex")
	y = y - 15

	local value_y = y - 10

	local icon_sizes =
	{
		plate = image_size - 30,
		bowl = image_size - 22,
		none = image_size - 35,
	}
	local icon_size = data.recipe ~= nil and icon_sizes[data.recipe.dish or "none"] or image_size

    local frame = details_root:AddChild(Image("images/quagmire_recipebook.xml", "recipe_known.tex"))
	frame:ScaleToSize(image_size, image_size)
	y = y - image_size/2
	frame:SetPosition(left + image_size/2 + 5, y)
	y = y - image_size/2

	local portrait_root = details_root:AddChild(Widget("portrait_root"))
	portrait_root:SetPosition(frame:GetPosition())

    local icon = portrait_root:AddChild(Image(data.icon ~= nil and data.atlas or "images/quagmire_recipebook.xml", data.icon or "recipe_unknown.tex"))
	icon:ScaleToSize(icon_size, icon_size)
	icon:SetEffect("shaders/ui_cc.ksh")


	local number = portrait_root:AddChild(Text(NUMBERFONT, 25, data.id_str, UICOLOURS.GOLD_SELECTED))
	number:SetPosition(-image_size/2 + 20, image_size/2 - 20)

	if data.recipe == nil then
		number:SetColour(UICOLOURS.SLATE)
		return details_root
	end

	if dish_img ~= nil then
		icon:SetPosition(0, 5)

	    local dish = portrait_root:AddChild(Image(DISH_ATLAS, dish_img))
		dish:SetEffect("shaders/ui_cc.ksh")
		dish:SetPosition(icon:GetPosition())
		dish:ScaleToSize(icon_size, icon_size)
		dish:MoveToBack()
	end


	local sub_icon_size = 28

	if #data.recipe.station == 2 then
		local sub_icon = portrait_root:AddChild(Image("images/quagmire_recipebook.xml", station_icons[data.recipe.station[1]][data.recipe.size]))
		sub_icon:ScaleToSize(sub_icon_size, sub_icon_size)
		sub_icon:SetPosition(image_size/2 - 46, -image_size/2 + 23)

		sub_icon = portrait_root:AddChild(Image("images/quagmire_recipebook.xml", station_icons[data.recipe.station[2]][data.recipe.size]))
		sub_icon:ScaleToSize(sub_icon_size, sub_icon_size)
		sub_icon:SetPosition(image_size/2 - 21, -image_size/2 + 23)
	elseif #data.recipe.station == 1 then
		local sub_icon = portrait_root:AddChild(Image("images/quagmire_recipebook.xml", station_icons[data.recipe.station[1]][data.recipe.size]))
		sub_icon:ScaleToSize(sub_icon_size, sub_icon_size)
		sub_icon:SetPosition(image_size/2 - 21, -image_size/2 + 23)
	end

	if data.coin ~= nil or data.silver ~= nil then
		local sub_icon = portrait_root:AddChild(Image("images/quagmire_recipebook.xml", "coin"..(data.coin or "_unknown")..".tex"))
		sub_icon:ScaleToSize(sub_icon_size, sub_icon_size)
		sub_icon:SetPosition(-image_size/2 + 21, -image_size/2 + 23)
	end

	if data.silver ~= nil then
		local sub_icon = portrait_root:AddChild(Image("images/quagmire_recipebook.xml", "coin"..data.silver..".tex"))
		sub_icon:ScaleToSize(sub_icon_size, sub_icon_size)
		sub_icon:SetPosition(-image_size/2 + 46, -image_size/2 + 23)
	end


	local frame_top_left = frame:GetPosition()
	local value_x = 60
	local title = details_root:AddChild(Text(HEADERFONT, value_title_font_size, STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_TRIBUTE, UICOLOURS.BROWN_DARK))
	value_y = value_y - value_title_font_size/2
	title:SetPosition(value_x, value_y)
	value_y = value_y - value_title_font_size/2
	value_y = value_y - 3
	MakeDetailsLine(details_root, value_x, value_y, .35)
	value_y = value_y - 5

	if dish_img == nil then
		value_y = value_y - body_font_size/2
		local no_dish_value = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.NO_TRIBUTE_VALUE, UICOLOURS.BROWN_DARK))
		no_dish_value:SetPosition(value_x, value_y)
		value_y = value_y - body_font_size/2 - 4
	elseif data.coin ~= nil then
		value_y = SetupValueDetails(data.recipe.dish, data.recipe.base_value, details_root, value_x, value_y, body_font_size)
	else
		value_y = value_y - body_font_size/2
		local value_str = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.TRIBUTE_UNKNOWN, UICOLOURS.BROWN_DARK))
		value_str:SetPosition(value_x, value_y)
		value_y = value_y - body_font_size/2 - 4
	end

	value_y = value_y - 8

	local silver_tribute_str = subfmt(STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_TRIBUTE_SILVER, {dish = data.recipe.dish == "plate" and STRINGS.NAMES.QUAGMIRE_PLATE_SILVER or STRINGS.NAMES.QUAGMIRE_BOWL_SILVER})
								or STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_TRIBUTE_SILVER_UNKNOWN

	title = details_root:AddChild(Text(HEADERFONT, value_title_font_size, silver_tribute_str, UICOLOURS.BROWN_DARK))
	value_y = value_y - value_title_font_size/2
	title:SetPosition(value_x, value_y)
	value_y = value_y - value_title_font_size/2
	value_y = value_y - 3
	MakeDetailsLine(details_root, value_x, value_y, .35)
	value_y = value_y - 5

	if dish_img == nil then
		value_y = value_y - body_font_size/2
		local no_dish_value = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.NO_TRIBUTE_VALUE, UICOLOURS.BROWN_DARK))
		no_dish_value:SetPosition(value_x, value_y)
		value_y = value_y - body_font_size/2 - 4
	elseif data.silver ~= nil then
		value_y = SetupValueDetails(data.recipe.dish.."_silver", data.recipe.silver_value, details_root, value_x, value_y, body_font_size)
	else
		value_y = value_y - body_font_size/2
		local value_str = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.TRIBUTE_UNKNOWN, UICOLOURS.BROWN_DARK))
		value_str:SetPosition(value_x, value_y)
		value_y = value_y - body_font_size/2 - 4
	end

	y = y - 10

	-- CRAVINGS
	y = y - title_font_size/2
	local num_cravings = data.recipe.tags ~= nil and #data.recipe.tags or 0
	title = details_root:AddChild(Text(HEADERFONT, title_font_size, num_cravings > 1 and STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_CRAVINGS or STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_CRAVING, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, y)
	y = y - title_font_size/2
	MakeDetailsLine(details_root, 0, y - 2, .5)
	y = y - 8
	y = y - body_font_size/2
	if num_cravings > 0 then
		local str = STRINGS.UI.RECIPE_BOOK.CRAVINGS[string.upper(tostring(data.recipe.tags[1]))] or STRINGS.UI.RECIPE_BOOK.UNKNOWN_DATA
		for i = 2, num_cravings do
			str = str..", "..(STRINGS.UI.RECIPE_BOOK.CRAVINGS[string.upper(tostring(data.recipe.tags[i]))] or STRINGS.UI.RECIPE_BOOK.UNKNOWN_DATA)
		end
		local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, str, UICOLOURS.BROWN_DARK))
		tags:SetPosition(0, y)
	elseif data.recipe.size == "syrup" then
		local tags = details_root:AddChild(Text(HEADERFONT, body_font_size, STRINGS.UI.RECIPE_BOOK.NO_CRAVING, UICOLOURS.BROWN_DARK))
		tags:SetPosition(0, y)
	elseif num_cravings == 0 then
		local tags = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.TRIBUTE_UNKNOWN, UICOLOURS.BROWN_DARK))
		tags:SetPosition(0, y)
	end
	y = y - body_font_size/2 - 4


	y = y - 10

	-- COOK STATIONS
	y = y - title_font_size/2
	local num_stations = data.recipe.station ~= nil and #data.recipe.station or 0
	title = details_root:AddChild(Text(HEADERFONT, title_font_size, num_stations > 1 and STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_STATIONS or STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_STATION, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, y)
	y = y - title_font_size/2
	MakeDetailsLine(details_root, 0, y - 2, .5)
	y = y - 8
	y = y - body_font_size/2
	local stations = data.recipe.station -- data.recipe.all_stations
	if num_stations > 0 then
		local str = STRINGS.UI.RECIPE_BOOK.STATIONS[string.upper(data.recipe.station[1])] or STRINGS.UI.RECIPE_BOOK.UNKNOWN_DATA
		for i = 2, num_stations do
			str = str .. ", " .. (STRINGS.UI.RECIPE_BOOK.STATIONS[string.upper(data.recipe.station[i])] or STRINGS.UI.RECIPE_BOOK.UNKNOWN_DATA)
		end
		local body = details_root:AddChild(Text(HEADERFONT, body_font_size, str, UICOLOURS.BROWN_DARK))
		body:SetPosition(0, y)
	else
		local body = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.TRIBUTE_UNKNOWN, UICOLOURS.BROWN_DARK))
		body:SetPosition(0, y)
	end
	y = y - body_font_size/2 - 4


	y = y - 10

	-- INGREDIENTS
	y = y - title_font_size/2
	title = details_root:AddChild(Text(HEADERFONT, title_font_size, STRINGS.UI.RECIPE_BOOK.DETAILS_LABEL_RECIPES, UICOLOURS.BROWN_DARK))
	title:SetPosition(0, y)
	y = y - title_font_size/2 - 4
	MakeDetailsLine(details_root, 0, y - 2, .5)
	y = y - 10

	if data.recipe.recipes ~= nil and #data.recipe.recipes > 0 then
		SetupRecipeIngredientDetails(data.recipe, details_root, y)
	else
		y = y - value_body_font_size/2
		local body = details_root:AddChild(Text(HEADERFONT, value_body_font_size, STRINGS.UI.RECIPE_BOOK.TRIBUTE_UNKNOWN, UICOLOURS.BROWN_DARK))
		body:SetPosition(0, y)
	y = y - value_body_font_size/2
	end

	return details_root
end


function QuagmireRecipeBook:BuildRecipeBook()
    local base_size = 128
    local cell_size = 73
    local row_w = cell_size
    local row_h = cell_size;
    local reward_width = 80
    local row_spacing = 5

	local food_size = cell_size + 20
	local icon_size =
	{
		plate = food_size,
		bowl = food_size + 4,
		none = food_size - 12
	}
	local coin_size = 24 / (cell_size/base_size)

    local function ScrollWidgetsCtor(context, index)
        local w = Widget("recipe-cell-".. index)

		----------------
		w.cell_root = w:AddChild(ImageButton("images/quagmire_recipebook.xml", "recipe_known.tex", "recipe_known_selected.tex"))
		w.cell_root:SetFocusScale(cell_size/base_size + .05, cell_size/base_size + .05)
		w.cell_root:SetNormalScale(cell_size/base_size, cell_size/base_size)

		w.focus_forward = w.cell_root

        w.cell_root.ongainfocusfn = function() self.recipe_grid:OnWidgetFocus(w) end


        w.recipie_unknown = w.cell_root.image:AddChild(Image("images/quagmire_recipebook.xml", "recipe_unknown.tex"))
		w.recipie_unknown:ScaleToSize(base_size, base_size)

        w.id = w.cell_root.image:AddChild(Text(NUMBERFONT, 30, ""))
        w.id:SetPosition(-base_size/2 + 24, base_size/2 - 24)

		----------------
		w.recipie_root = w.cell_root.image:AddChild(Widget("recipe_root"))

        w.dish = w.recipie_root:AddChild(Image(DISH_ATLAS, "bowl.tex"))
        w.icon = w.recipie_root:AddChild(Image(DISH_ATLAS, "bowl.tex"))

		w.dish:SetEffect("shaders/ui_cc.ksh")
		w.icon:SetEffect("shaders/ui_cc.ksh")


		w.coin = w.recipie_root:AddChild(Image(GetInventoryItemAtlas("quagmire_coin1.tex"), "quagmire_coin1.tex"))
		w.coin:ScaleToSize(coin_size, coin_size)
        w.coin:SetPosition(-base_size/2 + 23, -base_size/2 + 25)

		w.silver = w.recipie_root:AddChild(Image(GetInventoryItemAtlas("quagmire_coin1.tex"), "quagmire_coin1.tex"))
		w.silver:ScaleToSize(coin_size, coin_size)
        w.silver:SetPosition(-base_size/2 + 50, -base_size/2 + 25)

		w.stations = {}
		w.stations[2] = w.recipie_root:AddChild(Image(GetInventoryItemAtlas("quagmire_pot_small.tex"), "quagmire_pot_small.tex"))
		w.stations[1] = w.recipie_root:AddChild(Image(GetInventoryItemAtlas("quagmire_pot_small.tex"), "quagmire_pot_small.tex"))

		w.stations[1]:ScaleToSize(coin_size + 3, coin_size + 3)
        w.stations[1]:SetPosition(base_size/2 - 25, -base_size/2 + 25)
		w.stations[2]:ScaleToSize(coin_size + 3, coin_size + 3)
        w.stations[2]:SetPosition(base_size/2 - 50, -base_size/2 + 25)

		w.cell_root:SetOnClick(function()
			self.details_root:KillAllChildren()
			self.details_root:AddChild(self:CreateRecipeDetailPanel(w.data))
			TheRecipeBook.selected = w.data.id
		end)

		----------------
		w.id:MoveToFront()
		return w

    end

    local function ScrollWidgetApply(context, widget, data, index)
		widget.data = data
		if data ~= nil then
			widget.cell_root:Show()
			widget.id:SetString(data.id_str)

			if data.recipe ~= nil then
				widget.recipie_root:Show()
				widget.recipie_unknown:Hide()

				widget.id:SetColour(UICOLOURS.GOLD_SELECTED)
				widget.icon:SetTexture(data.atlas, data.icon)

				if data.recipe.station[2] ~= nil then
					widget.stations[1]:SetTexture("images/quagmire_recipebook.xml", station_icons[data.recipe.station[2]][data.recipe.size])
					widget.stations[1]:Show()
					widget.stations[2]:SetTexture("images/quagmire_recipebook.xml", station_icons[data.recipe.station[1]][data.recipe.size])
					widget.stations[2]:Show()
				elseif data.recipe.station[1] ~= nil then
					widget.stations[1]:SetTexture("images/quagmire_recipebook.xml", station_icons[data.recipe.station[1]][data.recipe.size])
					widget.stations[1]:Show()
					widget.stations[2]:Hide()
				else
					widget.stations[1]:Hide()
					widget.stations[2]:Hide()
				end

				local scale_size = icon_size[data.recipe.dish or "none"]
				widget.dish:ScaleToSize(scale_size, scale_size)
				widget.icon:ScaleToSize(scale_size, scale_size)

				if data.recipe.dish then
					local silver_dish = (data.silver ~= nil and TheRecipeBook.filters["value"] == FILTER_ANY) or (data.silver == TheRecipeBook.filters["value"])

					widget.dish:SetTexture(DISH_ATLAS, data.recipe.dish .. (silver_dish and "_silver" or "") .. ".tex")
					widget.dish:Show()

					widget.coin:SetTexture("images/quagmire_recipebook.xml", "coin"..(data.coin or "_unknown")..".tex")
					widget.coin:Show()
				else
					widget.dish:Hide()
					widget.coin:Hide()
				end

				if data.silver ~= nil then
					widget.silver:Show()
					widget.silver:SetTexture("images/quagmire_recipebook.xml", "coin"..data.silver..".tex")
				else
					if data.coin == nil then
						widget.coin:Hide()
					end
					widget.silver:Hide()
				end

			else
				widget.recipie_root:Hide()
				widget.recipie_unknown:Show()
				widget.id:SetColour(UICOLOURS.SLATE)
			end
			widget:Enable()
		else
			widget:Disable()
			widget.cell_root:Hide()
		end
    end

    self.all_recipes = {}

	for i = 1, QUAGMIRE_NUM_FOOD_RECIPES do
        table.insert(self.all_recipes, {
            name="",
			id = i,
			id_str = string.format("%02i", i),
        })
	end

	local recipe_list = TheRecipeBook:GetValidRecipes()
	self.num_recipes_discovered = GetTableSize(recipe_list)
	for client_name, recipe in pairs(recipe_list) do
		local id = string.gsub(client_name, "quagmire_food_", "")
		id = tonumber(id)

		if id == nil then
			id = QUAGMIRE_NUM_FOOD_RECIPES
			self.all_recipes[id].id_str = STRINGS.UI.RECIPE_BOOK.SYRUP_RECIPE_ID
		end

		local is_image_loaded = true
        if QUAGMIRE_USE_KLUMP then
            is_image_loaded = IsKlumpLoaded("images/quagmire_food_inv_images_hires_"..client_name..".tex")
        end

		self.all_recipes[id].name = client_name
		self.all_recipes[id].recipe = recipe
		self.all_recipes[id].icon = client_name..".tex"
		if recipe.dish == nil then
			self.all_recipes[id].atlas = GetInventoryItemAtlas(self.all_recipes[id].icon)
		elseif not is_image_loaded then
			self.all_recipes[id].atlas = "images/quagmire_food_common_inv_images_hires.xml"
			self.all_recipes[id].icon = (recipe.station[1]=="pot" and "goop_" or "burnt_") .. recipe.dish .. ".tex"
		else
			self.all_recipes[id].atlas = "images/quagmire_food_inv_images_hires_"..client_name..".xml"
		end

		self.all_recipes[id].coin = recipe.base_value ~= nil and (recipe.base_value.coin4 ~= nil and 4 or recipe.base_value.coin3 ~= nil and 3 or recipe.base_value.coin2 ~= nil and 2 or 1) or nil
		self.all_recipes[id].silver = recipe.silver_value ~= nil and (recipe.silver_value.coin4 ~= nil and 4 or recipe.silver_value.coin3 ~= nil and 3 or recipe.silver_value.coin2 ~= nil and 2 or 1) or nil
	end

    local grid = TEMPLATES.ScrollingGrid(
        self.all_recipes,
        {
            context = {},
            widget_width  = row_w+row_spacing,
            widget_height = row_h+row_spacing,
            num_visible_rows = 5,
            num_columns      = 5,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetApply,
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

function QuagmireRecipeBook:OnRecipeBookUpdated()
	local scroll_pos = nil
	if self.recipe_grid ~= nil then
		scroll_pos = self.recipe_grid.current_scroll_pos
		self.recipe_grid:Kill()
	end
    self.recipe_grid = self.gridroot:AddChild( self:BuildRecipeBook() )
    self.recipe_grid:SetPosition(-15, 0)

	if scroll_pos ~= nil then
		self.recipe_grid:ScrollToScrollPos(scroll_pos)
	end

	self:ApplyFilters()

	if TheRecipeBook.selected ~= nil then
		self.details_root:KillAllChildren()
		self.details_root:AddChild(self:CreateRecipeDetailPanel(self.all_recipes[TheRecipeBook.selected]))
	end

end

function QuagmireRecipeBook:ApplyFilters()
	local visible_items = {}

	for i, item in ipairs(self.all_recipes) do
		local recipe = item.recipe or {}
		if (TheRecipeBook.filters["value"] == FILTER_ANY or item.coin == TheRecipeBook.filters["value"] or item.silver == TheRecipeBook.filters["value"]) and
			(TheRecipeBook.filters["station"] == FILTER_ANY or (recipe.station ~= nil and table.contains(recipe.station, TheRecipeBook.filters["station"]))) and
			(TheRecipeBook.filters["craving"] == FILTER_ANY or (recipe.tags ~= nil and table.contains(recipe.tags, TheRecipeBook.filters["craving"]))) then

			table.insert(visible_items, item)
		end
	end

    self.recipe_grid:SetItemsData(visible_items)

	self:_DoFocusHookups()
end

local CRAVINGS =
{
    "snack",
    "bread",
    "veggie",
    "soup",
    "fish",
    "meat",
    "cheese",
    "pasta",
    "sweet",
}
--table.sort(CRAVINGS)

function QuagmireRecipeBook:BuildFilterPanel()
	local root = Widget("filter_root")

	local top = 50
	local left = 0 -- -width/2 + 5

	local craving_options = {}
	table.insert(craving_options, {text = STRINGS.UI.RECIPE_BOOK.FILTER_ANY, data = FILTER_ANY})
	for i, v in ipairs(CRAVINGS) do
		table.insert(craving_options, {text = STRINGS.UI.RECIPE_BOOK.CRAVINGS[string.upper(v)], data = v})
	end
	local function on_craving_filter( data )
		TheRecipeBook.filters["craving"] = data
		self:ApplyFilters()
	end

	local value_options = {
		{text = STRINGS.UI.RECIPE_BOOK.FILTER_ANY, data = FILTER_ANY},
		{text = STRINGS.NAMES["QUAGMIRE_COIN1"], data = 1},
		{text = STRINGS.NAMES["QUAGMIRE_COIN2"], data = 2},
		{text = STRINGS.NAMES["QUAGMIRE_COIN3"], data = 3},
		{text = STRINGS.NAMES["QUAGMIRE_COIN4"], data = 4},
	}
	local function on_value_filter( data )
		TheRecipeBook.filters["value"] = data
		self:ApplyFilters()
	end

	local station_options = {
		{text = STRINGS.UI.RECIPE_BOOK.FILTER_ANY, data = FILTER_ANY},
		{text = STRINGS.UI.RECIPE_BOOK.STATIONS.POT, data = "pot"},
		{text = STRINGS.UI.RECIPE_BOOK.STATIONS.OVEN, data = "oven"},
		{text = STRINGS.UI.RECIPE_BOOK.STATIONS.GRILL, data = "grill"},
	}
	local function on_station_filter( data )
		TheRecipeBook.filters["station"] = data
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

	TheRecipeBook.filters["craving"] = TheRecipeBook.filters["craving"] or FILTER_ANY
	TheRecipeBook.filters["value"] = TheRecipeBook.filters["value"] or FILTER_ANY
	TheRecipeBook.filters["station"] = TheRecipeBook.filters["station"] or FILTER_ANY

	local items = {}
	table.insert(items, MakeSpinner(STRINGS.UI.RECIPE_BOOK.DETAILS_SPINNER_STATION, station_options, on_station_filter, TheRecipeBook.filters["station"]))
	table.insert(items, MakeSpinner(STRINGS.UI.RECIPE_BOOK.DETAILS_SPINNER_CRAVING, craving_options, on_craving_filter, TheRecipeBook.filters["craving"]))
	--table.insert(items, MakeSpinner(STRINGS.UI.RECIPE_BOOK.DETAILS_SPINNER_TRIBUTE, value_options, on_value_filter, TheRecipeBook.filters["value"]))

	self.spinners = {}
	for i, v in ipairs(items) do
		local w = root:AddChild(v)
		w:SetPosition(50, (#items - i + 1)*(height + 3))
		table.insert(self.spinners, w.spinner)
	end

	--grid:FillGrid(1, width_label + width_spinner, height + 3, items)

	self:ApplyFilters()

	return root
end

return QuagmireRecipeBook
