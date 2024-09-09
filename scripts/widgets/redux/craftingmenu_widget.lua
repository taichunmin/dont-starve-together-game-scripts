local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Grid = require "widgets/grid"
local Spinner = require "widgets/spinner"
local UIAnim = require "widgets/uianim"

local TEMPLATES = require "widgets/redux/templates"

local IngredientUI = require "widgets/ingredientui"
local CraftingMenuDetails = require "widgets/redux/craftingmenu_details"

require("util")

-- ref: craftslot.lua, craftslots.lua, crafting.lua, recipetile.lua, recipepopup.lua
local SortTypes = require("crafting_sorting")

local SEARCH_BOX_HEIGHT = 40

-------------------------------------------------------------------------------------------------------
local CraftingMenuWidget = Class(Widget, function(self, owner, crafting_hud, height)
    Widget._ctor(self, "CraftingMenuWidget")

	self.owner = owner
	self.crafting_hud = crafting_hud

	self.sort_class = SortTypes.DefaultSort(self)
    self.sort_modes = {
        {str = STRINGS.UI.CRAFTING_MENU.SORTING.DEFAULT, atlas = "images/button_icons2.xml", img = "sort_default.tex", class = self.sort_class},
		{str = STRINGS.UI.CRAFTING_MENU.SORTING.CRAFTABLE, atlas = "images/button_icons.xml", img = "sort_rarity.tex", class = SortTypes.CraftableSort(self, self.sort_class)},
		{str = STRINGS.UI.CRAFTING_MENU.SORTING.FAVORITE, atlas = "images/button_icons2.xml", img = "sort_favorite.tex", class = SortTypes.FavoriteSort(self, self.sort_class)},
        {str = STRINGS.UI.CRAFTING_MENU.SORTING.NAME, atlas = "images/button_icons.xml", img = "sort_name.tex", class = SortTypes.AlphaSort(self)},
    }
	self.sort_mode = 1

    self.root = self:AddChild(Widget("root"))

	self.current_filter_name = nil
	self.filtered_recipes = {}
	self.filter_buttons = {}

	self.last_recipe_state = {}

	self.last_search_text = ""
	self.search_text = ""
	self.last_searched_recipes = {}
	self.searched_recipes = {}
	self.search_delay = 0
	self.current_recipe_search = nil

	self.frame = self.root:AddChild(self:MakeFrame(500, height))

	if self:UpdateFilterButtons() then
		self:ApplyFilters()
	end

	self.focus_forward = self.filter_panel.filter_grid
end)

function CraftingMenuWidget:Initialize()
	self:UpdateFilterButtons()

	self:SelectFilter(CRAFTING_FILTERS.TOOLS.name, true)
	local data = self.filtered_recipes[1]
	self:PopulateRecipeDetailPanel(data, data ~= nil and Profile:GetLastUsedSkinForItem(data.recipe.name) or nil)

	self:Refresh() 
end

function CraftingMenuWidget:StartSearching(clear_text)
	if clear_text then
		self:SetSearchText("")
		self.search_box.textbox:SetString("")
	end
	self.search_box.textbox:SetEditing(true)
end

function CraftingMenuWidget:OnControl(control, down)
	if self.crafting_hud:IsCraftingOpen() then
		if self.details_root.skins_spinner ~= nil and not self.details_root.skins_spinner.focus then
			if self.details_root.skins_spinner:OnControl(control, down) then return true end
		end
		if self.recipe_grid ~= nil and not self.recipe_grid.focus then
			if self.recipe_grid:OnControl(control, down) then return true end
		end
	end

    if CraftingMenuWidget._base.OnControl(self, control, down) then return true end

	return false
end

local function GetClosestWidget(list, active_widget, dir_x, dir_y)
    local closest = nil
    local closest_score = nil

	if active_widget ~= nil then
		local x, y = active_widget.inst.UITransform:GetWorldPosition()
		for k,v in pairs(list) do
			if v ~= active_widget and v:IsVisible() and v:IsEnabled() and (v.IsFullyInView == nil or v:IsFullyInView()) then
				local vx, vy = v.inst.UITransform:GetWorldPosition()
				local local_dir_x, local_dir_y = vx-x, vy-y
				if VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y) > 0 then
					local score = local_dir_x * local_dir_x + local_dir_y * local_dir_y
					if not closest or score < closest_score then
						closest = v
						closest_score = score
					end
				end
			end
		end
	end

    return closest, closest_score
end

function CraftingMenuWidget:DoFocusHookups()
	local is_left = self.crafting_hud.is_left_aligned

	self.filter_panel.filter_grid:SetFocusChangeDir(MOVE_UP,								function(w) return GetClosestWidget(self.top_row_widgets, w:GetFocusChild(), 0, 1) end)
	self.filter_panel.filter_grid:SetFocusChangeDir(MOVE_DOWN,								function(w) return GetClosestWidget(self.recipe_grid.widgets_to_update, w:GetFocusChild(), 0, -1) end)
	self.filter_panel.filter_grid:SetFocusChangeDir(is_left and MOVE_RIGHT or MOVE_LEFT,	function(w) return GetClosestWidget(self.crafting_hud.pinbar.pin_slots, w:GetFocusChild(), is_left and 1 or -1, 0) or self.crafting_hud.pinbar:GetFirstButton() end)

	self.recipe_grid:SetFocusChangeDir(MOVE_UP,								function(w) return GetClosestWidget(self.filter_buttons, w.widgets_to_update[w.focused_widget_index], 0, 1) or self.filter_panel.filter_grid end)
	self.recipe_grid:SetFocusChangeDir(is_left and MOVE_RIGHT or MOVE_LEFT,	function(w) return GetClosestWidget(self.crafting_hud.pinbar.pin_slots, w.widgets_to_update[w.focused_widget_index], is_left and 1 or -1, 0) or self.crafting_hud.pinbar:GetFirstButton() end)

	self.crafting_hud.pinbar:SetFocusChangeDir(is_left and MOVE_LEFT or MOVE_RIGHT, function(w)
		if self.crafting_hud:IsCraftingOpen() then
			local grid_widget, grid_closest = GetClosestWidget(self.recipe_grid.widgets_to_update, w.root:GetFocusChild(), is_left and -1 or 1, 0)
			local filter_widget, filter_closest = GetClosestWidget(self.filter_buttons, w.root:GetFocusChild(), is_left and -1 or 1, 0)
			if grid_widget ~= nil and filter_widget ~= nil then
				return grid_closest < filter_closest and grid_widget or filter_widget
			end
			return grid_widget or filter_widget or nil 
		end
	end)

	local top_row_focus_down = function(w) return GetClosestWidget(self.filter_buttons, w, 0, -1) end
	local top_row_focus_left = function(w) return GetClosestWidget(self.top_row_widgets, w, -1, 0) end
	local top_row_focus_right = function(w) return GetClosestWidget(self.top_row_widgets, w, 1, 0) end
	for _, trw in ipairs(self.top_row_widgets) do
		trw:SetFocusChangeDir(MOVE_DOWN, top_row_focus_down)
		trw:SetFocusChangeDir(MOVE_LEFT, top_row_focus_left)
		trw:SetFocusChangeDir(MOVE_RIGHT, top_row_focus_right)
	end
end

function CraftingMenuWidget:PopulateRecipeDetailPanel(recipe, skin_name)
	self.details_root:PopulateRecipeDetailPanel(recipe, skin_name)
end

local function search_exact_match(search, str)
    str = str:gsub(" ", "")

    --Simple find in strings for multi word search
	return string.find( str, search, 1, true ) ~= nil
end

local function text_filter(recipe, search_str)
    if search_str == "" then
        return true
    end

	local name_upper = string.upper(recipe.name)

	local product = recipe.product
	local product_upper = string.upper(product)

	local name = STRINGS.NAMES[name_upper] or STRINGS.NAMES[product_upper]
	local desc = STRINGS.RECIPE_DESC[name_upper] or STRINGS.RECIPE_DESC[product_upper]

    return search_exact_match(search_str, string.lower(product))
        or (name and search_exact_match(search_str, string.lower(name)))
        or (desc and search_exact_match(search_str, string.lower(desc)))
end

local function IsRecipeValidForFilter(self, recipename, filter_recipes)
	if filter_recipes then
		return filter_recipes[recipename] ~= nil
	end
	return self:IsRecipeValidForSearch(recipename)
end

local function IsRecipeValidForStation(self, recipe, station, current_filter)
    if current_filter ~= "CRAFTING_STATION" then
        return true -- Only care about CRAFTING_STATION filter tab for this function.
    end

    if recipe == nil or station == nil then
        return true -- NOTES(JBK): This is here to not change old filtering before this function was added.
    end

    if recipe.station_tag == nil then
        return true
    end

    return station:HasTag(recipe.station_tag)
end

function CraftingMenuWidget:ApplyFilters()
	self.filtered_recipes = {}

    local builder = self.owner ~= nil and self.owner.replica.builder or nil
    local station = builder and builder:GetCurrentPrototyper() or nil

	local current_filter = self.current_filter_name
	local filter_recipes = (current_filter ~= nil and CRAFTING_FILTERS[current_filter] ~= nil) and FunctionOrValue(CRAFTING_FILTERS[current_filter].default_sort_values) or nil

	local show_hidden = current_filter == CRAFTING_FILTERS.EVERYTHING.name

	for i, recipe_name in metaipairs(self.sort_class) do
		local data = self.crafting_hud.valid_recipes[recipe_name]
		if data and (show_hidden or data.meta.build_state ~= "hide") and IsRecipeValidForFilter(self, recipe_name, filter_recipes) and IsRecipeValidForStation(self, data.recipe, station, current_filter) then
			table.insert(self.filtered_recipes, data)
		end
	end

	if self.crafting_hud:IsCraftingOpen() then
		self:UpdateRecipeGrid(self.focus and not TheFrontEnd.tracking_mouse)
		--self.recipe_grid:ResetScroll()
		--self.recipe_grid:SetItemsData(self.filtered_recipes)
	else
		self.recipe_grid.dirty = true
	end
end

function CraftingMenuWidget:UpdateEventButtonLayout()
	local is_event_layout = self.event_layout
	self.event_layout = self.special_event_filter.num_can_build ~= nil and self.special_event_filter.num_can_build > 0 or self.special_event_filter.has_unlocked or false

	if is_event_layout ~= self.event_layout then
		if self.event_layout then
			self.special_event_filter:Show()
			self.special_event_filter:SetHoverText(GetActiveSpecialEventCount() == 1 and STRINGS.UI.SPECIAL_EVENT_NAMES[string.upper(GetFirstActiveSpecialEvent())] or STRINGS.UI.SPECIAL_EVENT_NAMES.MULTIPLE_EVENTS)

			local pt = self.crafting_station_filter:GetPosition()
			self.crafting_station_filter:SetPosition(self.grid_left + self.grid_button_space + (self.event_layout and self.grid_button_space or 0), pt.y)

			self.search_box.textbox_root.textbox_bg:ScaleToSize(self.grid_button_space * 5, SEARCH_BOX_HEIGHT)
			self.search_box.textbox_root.textbox:SetRegionSize(self.grid_button_space * 5 - 30, SEARCH_BOX_HEIGHT)
		else
			self.special_event_filter:Hide()

			local pt = self.crafting_station_filter:GetPosition()
			self.crafting_station_filter:SetPosition(self.grid_left + self.grid_button_space, pt.y)

			self.search_box.textbox_root.textbox_bg:ScaleToSize(self.grid_button_space * 6.5, SEARCH_BOX_HEIGHT)
			self.search_box.textbox_root.textbox:SetRegionSize(self.grid_button_space * 6.5 - 30, SEARCH_BOX_HEIGHT)
		end
	end
end

function CraftingMenuWidget:UpdateFilterButtons()
	local builder = self.owner ~= nil and self.owner.replica.builder or nil
	if builder ~= nil then
		if builder:IsFreeBuildMode() then
			self.crafting_station_filter:SetHoverText(STRINGS.UI.CRAFTING_FILTERS.CRAFTING_STATION)
			self.crafting_station_filter:Show()
		else
			local prototyper = builder:GetCurrentPrototyper()
			local crafting_station_def = prototyper ~= nil and PROTOTYPER_DEFS[prototyper.prefab] or nil
			if crafting_station_def ~= nil and crafting_station_def.is_crafting_station then
				self.crafting_station_filter:SetHoverText(crafting_station_def.filter_text)
				self.crafting_station_filter.filter_img:SetTexture(crafting_station_def.icon_atlas, crafting_station_def.icon_image)
				self.crafting_station_filter.filter_img:ScaleToSize(54, 54)
				self.crafting_station_filter:Show()
			else			
				self.crafting_station_filter:Hide()
			end
		end
	end

	if #CRAFTING_FILTERS.MODS.recipes == 0 then
		if self.mods_filter:IsVisible() then
			self.mods_filter:Hide()
		end
	else
		if not self.mods_filter:IsVisible() then
			self.mods_filter:Show()
		end
	end

	local atlas = resolvefilepath(CRAFTING_ATLAS)

	local can_prototype = false
	local new_recipe_available = false

	for name, button in pairs(self.filter_buttons) do
		if button.filter_def.recipes ~= nil then 
			local has_buffered = false
			local has_prototypeable = false
			local has_unlocked = false
			local num_can_build = 0
			for _, recipe_name in pairs(FunctionOrValue(button.filter_def.recipes)) do
				local data = self.crafting_hud.valid_recipes[recipe_name]
				if data ~= nil then
					if data.meta.can_build then
						num_can_build = num_can_build + 1
						if data.meta.build_state == "prototype" then
							has_prototypeable = true
							can_prototype = true
						elseif data.meta.build_state == "buffered" then
							has_buffered = true
						end
					elseif data.meta.build_state == "no_ingredients" then
						has_unlocked = true
					end
				end
			end

			button.bg:SetTexture(atlas, has_buffered and "filterslot_bg_buffered.tex" or num_can_build > 0 and "filterslot_bg_highlight.tex" or "filterslot_bg.tex")
			if has_prototypeable then
				button.prototype_icon:Show()
			else
				button.prototype_icon:Hide()
			end

			if button.num_can_build == nil or num_can_build > button.num_can_build then
				new_recipe_available = true
			end
			button.num_can_build = num_can_build
			button.has_unlocked = has_unlocked
		end
	end

	if self.crafting_hud.pinbar ~= nil and self.crafting_hud.pinbar.open_menu_button ~= nil then
		self.crafting_hud.pinbar.open_menu_button:SetCraftingState(can_prototype, new_recipe_available)
	end

	self:UpdateEventButtonLayout()

	local rebuild_details_list = false
	for recipe_name, data in pairs(self.crafting_hud.valid_recipes) do
		local last_state = self.last_recipe_state[recipe_name] or "hide"
		local new_state = data.meta.build_state
		if not rebuild_details_list and ((last_state == "hide" and new_state ~= "hide") or (last_state ~= "hide" and new_state == "hide")) then
			rebuild_details_list = true
		end
		self.last_recipe_state[recipe_name] = new_state
	end

	return rebuild_details_list
end

function CraftingMenuWidget:Refresh(tech_tree_changed)
	local rebuild_details_list = self:UpdateFilterButtons()
	if self.sort_class.Refresh == nil or not self.sort_class:Refresh() then
		if rebuild_details_list then
			self:ApplyFilters()
		else
			self.recipe_grid:RefreshView()
		end
		if self.crafting_hud:IsCraftingOpen() and tech_tree_changed then
			self:OnCraftingMenuOpen(true)
		end
	end
	self.details_root:Refresh()
end

function CraftingMenuWidget:RefreshControllers(controller_mode)
	self.details_root:RefreshControllers(controller_mode)

    if controller_mode then
		self.recipe_grid:OverrideControllerButtons(CONTROL_INVENTORY_EXAMINE, CONTROL_INVENTORY_DROP, true)
    else
		self.recipe_grid:ClearOverrideControllerButtons()
	end
end

function CraftingMenuWidget:RefreshCraftingHelpText(controller_id)
	if self.recipe_grid.focus then
		local hint_text = TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_1).." "..STRINGS.UI.CRAFTING_MENU.PIN

		local recipe_name = self.details_root.data ~= nil and self.details_root.data.recipe.name or nil
		if recipe_name then
			hint_text = hint_text .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2).." "..(TheCraftingMenuProfile:IsFavorite(recipe_name) and STRINGS.UI.CRAFTING_MENU.FAVORITE_REMOVE or STRINGS.UI.CRAFTING_MENU.FAVORITE_ADD)
		end
		return hint_text
	elseif self.filter_panel.focus then
		return TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT).." "..STRINGS.UI.HUD.SELECT
	end
	return ""
end

function CraftingMenuWidget:OnUpdate(dt)
	self.search_delay = self.search_delay - dt
	if self.search_delay > 0 then
		return
	end

	self.current_recipe_search = next(AllRecipes, self.current_recipe_search)
	local processed_recipe_count = 0
	while self.current_recipe_search and processed_recipe_count < 30 do
		if self.searched_recipes[self.current_recipe_search] == nil then
			self:ValidateRecipeForSearch(self.current_recipe_search)
			processed_recipe_count = processed_recipe_count + 1
		end

		self.current_recipe_search = next(AllRecipes, self.current_recipe_search)
	end

	if self.current_recipe_search == nil then
		self:StopUpdating()
	end
end

function CraftingMenuWidget:UpdateRecipeGrid(set_focus)
	local prev_focus_data = self.details_root.data
	local prev_focus_skin = self.details_root.skins_spinner ~= nil and self.details_root.skins_spinner:GetItem() or nil

	if #self.filtered_recipes == 0 then
		self.no_recipes_msg:Show()
	else
		self.no_recipes_msg:Hide()
	end

	self.recipe_grid:ResetScroll()
	self.recipe_grid:SetItemsData(self.filtered_recipes)
	self.recipe_grid.dirty = false

	--print("UpdateRecipeGrid", prev_focus_data ~= nil and prev_focus_data.recipe.name or "<none>", prev_focus_skin, self.recipe_grid:FindDataIndex(prev_focus_data))

	if prev_focus_data then
		local grid_index = self.recipe_grid:FindDataIndex(prev_focus_data)

		if grid_index ~= nil then
			self.recipe_grid:ScrollToDataIndex(grid_index)
			if set_focus then
				self.recipe_grid:ForceItemFocus(grid_index)
				if prev_focus_skin ~= nil then
					self.details_root.skins_spinner:SelectSkin(prev_focus_skin)
				end
			end
		else
			if set_focus and #self.recipe_grid.items > 0 then
				if not TheFrontEnd.tracking_mouse then
					self.recipe_grid:ForceItemFocus(1)
				end
			end
		end
	else
		self.details_root:PopulateRecipeDetailPanel(nil, nil)
	end
end

function CraftingMenuWidget:OnCraftingMenuOpen(set_focus)
	local filter = nil
	local recipe_data = nil
	local skin_name = nil

	local builder = self.owner ~= nil and self.owner.replica.builder or nil
	local prototyper = builder ~= nil and builder:GetCurrentPrototyper() or nil
	local at_crafting_station = prototyper ~= nil and PROTOTYPER_DEFS[prototyper.prefab] ~= nil and PROTOTYPER_DEFS[prototyper.prefab].is_crafting_station
	if at_crafting_station then
		if self.current_filter_name ~= CRAFTING_FILTERS.CRAFTING_STATION.name then
			if self.pre_station_selection == nil then
				self.pre_station_selection = 
				{
					filter = self.details_root.from_filter_name, --self.current_filter_name,
					data = self.details_root.data,
					skin_name = self.details_root.skins_spinner ~= nil and self.details_root.skins_spinner:GetItem() or nil,
				}
			--print(" caching self.pre_station_selection", self.pre_station_selection.filter, self.pre_station_selection.data ~= nil and self.pre_station_selection.data.recipe.name, self.pre_station_selection.skin_name)
			end

			filter = CRAFTING_FILTERS.CRAFTING_STATION.name
			--recipe_data = nil
			--skin_name = nil
		else
			filter = CRAFTING_FILTERS.CRAFTING_STATION.name
			recipe_data = self.details_root.data
			skin_name = self.details_root.skins_spinner ~= nil and self.details_root.skins_spinner:GetItem() or nil
		end
	else
		if self.pre_station_selection ~= nil then
			if self.details_root.from_filter_name ~= CRAFTING_FILTERS.CRAFTING_STATION.name then
				filter = self.details_root.from_filter_name
				recipe_data = self.details_root.data
				skin_name = self.details_root.skins_spinner ~= nil and self.details_root.skins_spinner:GetItem() or nil
			else
				filter = self.pre_station_selection.filter
				recipe_data = self.pre_station_selection.data
				skin_name = self.pre_station_selection.skin_name
			end
				--print(" using self.pre_station_selection", filter, recipe_data ~= nil and recipe_data.recipe.name, skin_name)
			self.pre_station_selection = nil
		elseif not self.crafting_hud:IsCraftingOpen() then
			if TheInput:ControllerAttached() then
				filter = self.details_root.from_filter_name -- nil
			else
				filter = nil
			end
			recipe_data = self.details_root.data
			skin_name = self.details_root.skins_spinner ~= nil and self.details_root.skins_spinner:GetItem() or nil
		end
	end

	--print("OnCraftingMenuOpen", self.recipe_grid.dirty, set_focus, filter, recipe_data ~= nil and recipe_data.recipe.name or nil, skin_name)

	if filter ~= nil then
		self:SelectFilter(filter, filter ~= CRAFTING_FILTERS.EVERYTHING.name)
	end
	if self.recipe_grid.dirty then
		self:UpdateRecipeGrid(false)
	end
	if set_focus then
		if recipe_data or at_crafting_station then
			local grid_index = self.recipe_grid:FindDataIndex(recipe_data)
			if grid_index ~= nil then
				self.recipe_grid:ScrollToDataIndex(grid_index)
				if not TheFrontEnd.tracking_mouse then
					self.recipe_grid:ForceItemFocus(grid_index)
				end
				self:PopulateRecipeDetailPanel(recipe_data, skin_name or Profile:GetLastUsedSkinForItem(recipe_data.recipe.name) or nil)
			else
				if #self.recipe_grid.items > 0 then
					if not TheFrontEnd.tracking_mouse then
						self.recipe_grid:ForceItemFocus(1)
					end
					if at_crafting_station then
						local data = self.filtered_recipes[1]
						self:PopulateRecipeDetailPanel(data, data ~= nil and Profile:GetLastUsedSkinForItem(data.recipe.name) or nil)
					elseif not TheInput:ControllerAttached() then
						self:PopulateRecipeDetailPanel(recipe_data, skin_name or Profile:GetLastUsedSkinForItem(recipe_data.recipe.name) or nil)
					end
				else
					if not TheInput:ControllerAttached() then
						self.filter_buttons[self.current_filter_name]:SetFocus()
						self.details_root:PopulateRecipeDetailPanel(nil, nil)
					end
				end
			end
		end
	end
end

function CraftingMenuWidget:MakeFrame(width, height)
	local w = Widget("crafting_menu_frame")

	local atlas = resolvefilepath(CRAFTING_ATLAS)

	self.filter_panel = w:AddChild(self:MakeFilterPanel(width))
	local filters_height = self.filter_panel.panel_height --147

	height = height + math.max(filters_height - 147, 0)

	local fill = w:AddChild(Image(atlas, "backing.tex"))
	fill:ScaleToSize(width + 10, height + 18)
	fill:SetTint(1, 1, 1, 0.5)

	local left = w:AddChild(Image(atlas, "side.tex"))
	left:SetPosition(-width/2 - 8, 1)
	left:ScaleToSize(-26, -(height - 20))

	local right = w:AddChild(Image(atlas, "side.tex"))
	right:SetPosition(width/2 + 8, 1)
	right:ScaleToSize(26, height - 20)
	right:SetClickable(false)

	local top = w:AddChild(Image(atlas, "top.tex"))
	top:SetPosition(0, height/2 + 10)
	top:ScaleToSize(534, 38)

	local bottom = w:AddChild(Image(atlas, "bottom.tex"))
	bottom:SetPosition(0, -height/2 - 8)
	bottom:ScaleToSize(534, 38)
	bottom:SetClickable(false)

	----------------
	self.filter_panel:SetPosition(0, height/2 - 20)
	self.filter_panel:MoveToFront()

	self.recipe_grid = w:AddChild(self:MakeRecipeList(width, height - filters_height))
	local grid_w, grid_h = self.recipe_grid:GetScrollRegionSize() -- 231
	self.recipe_grid:SetPosition(-2, height/2 - filters_height - grid_h/2)
	
	self.no_recipes_msg = w:AddChild(Text(UIFONT, 30, STRINGS.UI.CRAFTING_MENU.NO_ITEMS, UICOLOURS.GOLD_UNIMPORTANT))
	self.no_recipes_msg:SetPosition(-2, height/2 - filters_height - grid_h/2)
	self.no_recipes_msg:Hide()

	----------------

	self.itemlist_split = w:AddChild(Image(atlas, "horizontal_bar.tex"))
	self.itemlist_split:SetPosition(0, height/2 - filters_height)
	self.itemlist_split:ScaleToSize(502, 15)

	self.itemlist_split2 = w:AddChild(Image(atlas, "horizontal_bar.tex"))
	self.itemlist_split2:SetPosition(0, height/2 - filters_height - grid_h - 2)
	self.itemlist_split2:ScaleToSize(502, 15)

	----------------

	self.details_root = w:AddChild(CraftingMenuDetails(self.owner, self, width - 20 * 2, height - 20 * 2))
	self.details_root:SetPosition(0, height/2 - filters_height - grid_h - 10)

	self.nav_hint = w:AddChild(Text(BODYTEXTFONT, 26))
	self.nav_hint:SetPosition(0, - height/2 - 30)

	----------------

	self.recipe_grid:MoveToBack()

	fill:MoveToBack()
	return w
end

function CraftingMenuWidget:ValidateRecipeForSearch(name)
	if self.search_text == "" then
		self.searched_recipes[name] = true
		return
	end

	local is_narrower_search = self.search_text:len() > self.last_search_text:len()
	local is_appended_string = (is_narrower_search and search_exact_match(self.last_search_text, self.search_text)) or
		(not is_narrower_search and search_exact_match(self.search_text, self.last_search_text)) or nil

	if not is_appended_string or self.last_searched_recipes[name] == nil or is_narrower_search == self.last_searched_recipes[name] then
		self.searched_recipes[name] = text_filter(AllRecipes[name], self.search_text)
	else
		self.searched_recipes[name] = self.last_searched_recipes[name]
	end
end

function CraftingMenuWidget:IsRecipeValidForSearch(name)
	if self.searched_recipes[name] == nil then
		self:ValidateRecipeForSearch(name)
	end

	return self.searched_recipes[name]
end

function CraftingMenuWidget:SetSearchText(search_text)
	search_text = TrimString(string.lower(search_text)):gsub(" ", "")

	if search_text == self.last_search_text then
		return
	end

	self.last_search_text = self.search_text
	self.search_text = search_text

	self.last_searched_recipes = self.searched_recipes
	self.searched_recipes = {}

	self:StartUpdating()
	self.search_delay = 1
	self.current_recipe_search = nil
end

function CraftingMenuWidget:MakeSearchBox(box_width, box_height)
    local searchbox = Widget("search")
	searchbox:SetHoverText(STRINGS.UI.CRAFTING_MENU.SEARCH, {offset_y = 30, attach_to_parent = self })

    searchbox.textbox_root = searchbox:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, box_width, box_height))
    searchbox.textbox = searchbox.textbox_root.textbox
    searchbox.textbox:SetTextLengthLimit(200)
    searchbox.textbox:SetForceEdit(true)
    searchbox.textbox:EnableWordWrap(false)
    searchbox.textbox:EnableScrollEditWindow(true)
    searchbox.textbox:SetHelpTextEdit("")
    searchbox.textbox:SetHelpTextApply(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH)
    searchbox.textbox:SetTextPrompt(STRINGS.UI.SERVERCREATIONSCREEN.SEARCH, UICOLOURS.GREY)
    searchbox.textbox.prompt:SetHAlign(ANCHOR_MIDDLE)
    searchbox.textbox.OnTextInputted = function()
		self:SetSearchText(self.search_box.textbox:GetString())

		self:SelectFilter(nil, false)
    end

     -- If searchbox ends up focused, highlight the textbox so we can tell something is focused.
    searchbox:SetOnGainFocus( function() searchbox.textbox:OnGainFocus() end )
    searchbox:SetOnLoseFocus( function() searchbox.textbox:OnLoseFocus() end )

    searchbox.focus_forward = searchbox.textbox

    return searchbox
end

function CraftingMenuWidget:SelectFilter(name, clear_search_text)
	--print("SelectFilter", name, clear_search_text, self.current_filter_name)

	if name ~= CRAFTING_FILTERS.CRAFTING_STATION.name then
		--self.pre_station_selection = nil
	end

	if clear_search_text then
		self:SetSearchText("")
		self.search_box.textbox:SetString("")
	end

	if name == nil or CRAFTING_FILTERS[name] == nil or self.filter_buttons[name] == nil then
		name = "EVERYTHING"
	end

	if name == self.current_filter_name and clear_search_text then
		return
	end

	if self.current_filter_name ~= nil and self.filter_buttons[self.current_filter_name] ~= nil then
		self.filter_buttons[self.current_filter_name].button:Unselect()
	end

	self.filter_buttons[name].button:Select()

	local filter_changed = self.current_filter_name ~= name
	if filter_changed then
		self.current_filter_name = name

		if self.sort_class.OnSelectFilter then
			self.sort_class:OnSelectFilter()
		end
	end

	if filter_changed or not clear_search_text then
		self:ApplyFilters()
	end
end

function CraftingMenuWidget:MakeFilterButton(filter_def, button_size)
	local atlas = resolvefilepath(CRAFTING_ATLAS)

	local w = Widget("filter_"..filter_def.name)
	w:SetScale(button_size/64)

	local button = w:AddChild(ImageButton(atlas, "filterslot_frame.tex", "filterslot_frame_highlight.tex", nil, nil, "filterslot_frame_select.tex"))
	w.button = button
	button:SetOnClick(function()
		self:SelectFilter(filter_def.name, true)
	end)
	button:SetOnSelect(function()
		self.search_box.textbox.prompt:SetString(w.hovertext.string)
	end)
	w:SetHoverText(STRINGS.UI.CRAFTING_FILTERS[filter_def.name], {offset_y = 30, attach_to_parent = self })

	w.focus_forward = button

	----------------
	local filter_atlas = FunctionOrValue(filter_def.atlas, self.owner, filter_def)
	local filter_image = FunctionOrValue(filter_def.image, self.owner, filter_def)

	local filter_img = button:AddChild(Image(filter_atlas, filter_image))
	--filter_img:SetTint(0, 0, 0, 1)
	if filter_def.image_size ~= nil then
		filter_img:ScaleToSize(filter_def.image_size, filter_def.image_size)
	else
		filter_img:ScaleToSize(54, 54)
	end
	filter_img:MoveToBack()
	w.filter_img = filter_img

	w.filter_def = filter_def

	w.bg = button:AddChild(Image(atlas, "filterslot_bg.tex"))
	w.bg:MoveToBack()

	w.prototype_icon = button:AddChild(Image(atlas, "filterslot_prototype.tex")) 
	w.prototype_icon:Hide()

	return w
end

function CraftingMenuWidget:AddSorter()
    local btn = TEMPLATES.IconButton(self.sort_modes[1].atlas, self.sort_modes[1].img)
    btn:SetScale(0.7)
    btn.SetSortType = function(w, sort_mode)
		if sort_mode == nil or self.sort_modes[sort_mode] == nil then
			sort_mode = 1
		end

        w:SetHoverText( subfmt(STRINGS.UI.CRAFTING_MENU.SORT_MODE_FMT, { mode = self.sort_modes[sort_mode].str}) )
        w.icon:SetTexture(self.sort_modes[sort_mode].atlas, self.sort_modes[sort_mode].img )

		self.sort_class = self.sort_modes[sort_mode].class
		self.sort_mode = sort_mode

		if self.sort_class.OnSelected then
			self.sort_class:OnSelected()
		end
    end
    local function onclick()
        local sort_mode = self.sort_mode + 1
        if self.sort_modes[sort_mode] == nil then
            sort_mode = 1
        end

        btn:SetSortType(sort_mode)
		self:ApplyFilters()
		TheCraftingMenuProfile:SetSortMode(sort_mode)
    end
    btn:SetOnClick(onclick)

	btn:SetHoverText( subfmt(STRINGS.UI.CRAFTING_MENU.SORT_MODE_FMT, { mode = self.sort_modes[1].str}), {offset_y = 30, attach_to_parent = self})

	btn:SetSortType(TheCraftingMenuProfile:GetSortMode())

    return btn
end

function CraftingMenuWidget:MakeFilterPanel(width)
	width = width - 40
	local button_size = 38
	local grid_button_space = button_size + 5
	local grid_buttons_wide = math.floor(width/(button_size + 1))
	local grid_left = -grid_button_space * grid_buttons_wide/2 + grid_button_space/2

	self.grid_button_space = grid_button_space
	self.grid_left = grid_left

    local w = Widget("FilterPanel")

	self.top_row_widgets = {}

	local y = -2

	-- favorites filter button
	local favorites_filter = w:AddChild(self:MakeFilterButton(CRAFTING_FILTERS.FAVORITES, button_size))
	favorites_filter:SetPosition(grid_left, y)
	self.filter_buttons[CRAFTING_FILTERS.FAVORITES.name] = favorites_filter
	self.favorites_filter = favorites_filter
	table.insert(self.top_row_widgets, favorites_filter)

	self.event_layout = IsAnySpecialEventActive()

	-- special_event_filter
	local special_event_filter = w:AddChild(self:MakeFilterButton(CRAFTING_FILTERS.SPECIAL_EVENT, button_size))
	special_event_filter:SetPosition(grid_left + grid_button_space, y)
	self.filter_buttons[CRAFTING_FILTERS.SPECIAL_EVENT.name] = special_event_filter
	special_event_filter:Hide()
	self.special_event_filter = special_event_filter
	table.insert(self.top_row_widgets, special_event_filter)

	-- favorites filter button
	local filter_station = w:AddChild(self:MakeFilterButton(CRAFTING_FILTERS.CRAFTING_STATION, button_size))
	filter_station:SetPosition(grid_left + grid_button_space, y)
	self.filter_buttons[CRAFTING_FILTERS.CRAFTING_STATION.name] = filter_station
	self.crafting_station_filter = filter_station
	table.insert(self.top_row_widgets, filter_station)

	-- search bar
    self.search_box = w:AddChild(self:MakeSearchBox(grid_button_space * 6.5, SEARCH_BOX_HEIGHT))
	self.search_box:SetPosition(0, y)
	table.insert(self.top_row_widgets, self.search_box)

	-- modded items filter button
	local filter_mods = w:AddChild(self:MakeFilterButton(CRAFTING_FILTERS.MODS, button_size))
	filter_mods:SetPosition(grid_left + grid_button_space * 9, y)
	self.filter_buttons[CRAFTING_FILTERS.MODS.name] = filter_mods
	self.mods_filter = filter_mods
	table.insert(self.top_row_widgets, filter_mods)

	-- sort button
	self.sort_button = w:AddChild(self:AddSorter())
	self.sort_button:SetPosition(grid_left + grid_button_space * 10, y)
	table.insert(self.top_row_widgets, self.sort_button)

	y = y - button_size / 2

	self:UpdateEventButtonLayout()

	-- Divider
	y = y - 5
	local line_height = 4
	local line = w:AddChild(Image("images/ui.xml", "line_horizontal_white.tex"))
	line:SetPosition(0, y - line_height/2)
    line:SetTint(unpack(BROWN))
	line:ScaleToSize(width, line_height)
	line:MoveToBack()
	y = y - line_height

	-- grid
	y = y - 8 - 17
	local filter_grid = w:AddChild(Grid())
    filter_grid:SetLooping(false, false)

	local widgets = {}
	for i, filter_def in ipairs(CRAFTING_FILTER_DEFS) do
		if not filter_def.custom_pos and (filter_def ~= CRAFTING_FILTERS.MODS or #filter_def.recipes > 0) then
			local w = self:MakeFilterButton(filter_def, button_size)
			self.filter_buttons[filter_def.name] = w
			table.insert(widgets, w)
		end
	end
	filter_grid:FillGrid(grid_buttons_wide, grid_button_space, grid_button_space, widgets)
	filter_grid:SetPosition(grid_left, y)

	y = y - grid_button_space * filter_grid.num_rows - 6

	w.filter_grid = filter_grid
	w.focus_forward = filter_grid

	w:SetOnGainFocus(function()
		if TheInput:ControllerAttached() then
			self:PopulateRecipeDetailPanel(nil, nil)
		end
	end)

	w.panel_height = math.abs(y)

	return w
end

function CraftingMenuWidget:MakeRecipeList(width, height)
    local cell_size = 60
    local row_w = cell_size
    local row_h = cell_size
    local row_spacing = 6
	local item_size = 94
	local atlas = resolvefilepath(CRAFTING_ATLAS)

    local function ScrollWidgetsCtor(context, index)
        local w = Widget("recipe-cell-".. index)

		w:SetScale(0.475)

		----------------
		w.cell_root = w:AddChild(ImageButton(atlas, "slot_frame.tex", "slot_frame_highlight.tex"))

		w.focus_forward = w.cell_root
        w.cell_root.ongainfocusfn = function() 
			self.recipe_grid:OnWidgetFocus(w)
			w.cell_root.recipe_held = false
			w.cell_root.last_recipe_click = nil

			if TheInput:ControllerAttached() then
				self.details_root:PopulateRecipeDetailPanel(w.data, w.data ~= nil and Profile:GetLastUsedSkinForItem(w.data.recipe.name) or nil)
			end
		end
		w.cell_root:SetWhileDown(function()
			if w.cell_root.recipe_held then
				DoRecipeClick(self.owner, w.data.recipe, self.details_root.skins_spinner:GetItem())
			end
		end)
		w.cell_root:SetOnDown(function()
			if w.cell_root.last_recipe_click and (GetTime() - w.cell_root.last_recipe_click) < 1 then
				w.cell_root.recipe_held = true
				w.cell_root.last_recipe_click = nil
			end
		end)
		w.cell_root:SetOnClick(function()
			local is_current = w.data == self.details_root.data
			if is_current then -- clicking the item when it is already selected will trigger a build
				local already_buffered = self.owner.replica.builder:IsBuildBuffered(w.data.recipe.name)
				if not w.cell_root.recipe_held or already_buffered then
					local stay_open, error_msg = DoRecipeClick(self.owner, w.data.recipe, self.details_root.skins_spinner:GetItem())
					if not stay_open then
						self.owner:PushEvent("refreshcrafting")  -- this is only really neede for free crafting

						if already_buffered or Profile:GetCraftingMenuBufferedBuildAutoClose() then
							self.owner.HUD:CloseCrafting()
							return
						end
					end
					if error_msg and not TheNet:IsServerPaused() then
						SendRPCToServer(RPC.CannotBuild, error_msg)
					end

					if stay_open and not already_buffered then
						w.cell_root.last_recipe_click = GetTime()
					end
				end
			else
				self.details_root:PopulateRecipeDetailPanel(w.data, Profile:GetLastUsedSkinForItem(w.data.recipe.name))
				w.cell_root.last_recipe_click = GetTime()
			end

			w.cell_root.recipe_held = false
		end)
		w.cell_root.OnControl = function(_self, control, down)
			if ImageButton.OnControl(_self, control, down) then return true end

			if not _self.focus then
				return false
			end

			if down and not _self.down then
				if control == CONTROL_MENU_MISC_1 then
					if self.crafting_hud.pinbar ~= nil then
						local slot = self.crafting_hud.pinbar:FindFirstUnpinnedSlot()
						if slot ~= nil then
							slot:SetFocus()
							slot.craft_button:OnControl(control, down)
							return true
						else
							slot = self.crafting_hud.pinbar:GetFirstButton()
							if slot ~= nil then
								TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
								slot:SetFocus()
								return true
							end
						end
					end
				elseif control == CONTROL_MENU_MISC_2 then
					local fav_button = self.details_root.fav_button
					if fav_button ~= nil and fav_button.onclick ~= nil then
						TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
						fav_button.onclick()
						return true
					end
				end
			end
		end

		----------------
		w.bg = w.cell_root:AddChild(Image(atlas, "slot_bg.tex"))
        w.item_img = w.bg:AddChild(Image("images/global.xml", "square.tex"))
        w.fg = w.bg:AddChild(Image("images/global.xml", "square.tex"))
		w.bg:MoveToBack()

		return w
    end

    local function ScrollWidgetSetData(context, widget, data, index)
		if data ~= nil and data.recipe ~= nil and data.meta ~= nil then
			if widget.data ~= nil then
				if widget.data.recipe ~= data.recipe then
					widget.cell_root.recipe_held = false
					widget.cell_root.last_recipe_click = nil
				end
			end

			local recipe = data.recipe
			local meta = data.meta

			widget.cell_root:Show()

			local image = recipe.imagefn ~= nil and recipe.imagefn() or recipe.image
			widget.item_img:SetTexture(recipe:GetAtlas(), image, image ~= recipe.image and recipe.image or nil)
			widget.item_img:ScaleToSize(item_size, item_size)

			local tint = 1

			if meta.build_state == "buffered" then
				widget.bg:SetTexture(atlas, "slot_bg_buffered.tex")
				widget.fg:Hide()
			elseif meta.build_state == "prototype" and meta.can_build then
				widget.bg:SetTexture(atlas, "slot_bg_prototype.tex")
				widget.fg:SetTexture(atlas, "slot_fg_prototype.tex")
				widget.fg:Show()
			elseif meta.can_build then
				widget.bg:SetTexture(atlas, "slot_bg.tex")
				widget.fg:Hide()
			elseif meta.build_state == "hint" then
				widget.bg:SetTexture(atlas, "slot_bg_missing_mats.tex")
				tint = .7
				widget.fg:SetTexture(atlas, "slot_fg_lock.tex")
                widget.fg:Show()
			elseif meta.build_state == "no_ingredients" or meta.build_state == "prototype" then
				widget.bg:SetTexture(atlas, "slot_bg_missing_mats.tex")
				tint = .7
                widget.fg:Hide()
			else
				widget.bg:SetTexture(atlas, "slot_bg_missing_mats.tex")
				tint = .7
				widget.fg:SetTexture(atlas, "slot_fg_lock.tex")
                widget.fg:Show()
			end

			widget.item_img:SetTint(tint, tint, tint, 1)

			if recipe.fxover ~= nil then
				if widget.fxover == nil then
					widget.fxover = widget.item_img:AddChild(UIAnim())
					widget.fxover:SetClickable(false)
					widget.fxover:SetScale(.25)
					widget.fxover:GetAnimState():AnimateWhilePaused(false)
				end
				widget.fxover:GetAnimState():SetBank(recipe.fxover.bank)
				widget.fxover:GetAnimState():SetBuild(recipe.fxover.build)
				widget.fxover:GetAnimState():PlayAnimation(recipe.fxover.anim, true)
				widget.fxover:GetAnimState():SetMultColour(tint, tint, tint, 1)
			elseif widget.fxover ~= nil then
				widget.fxover:Kill()
				widget.fxover = nil
			end

			widget:Enable()
		else
			widget:Disable()
			widget.cell_root:Hide()
		end

		widget.data = data
    end


	local grid = TEMPLATES.ScrollingGrid(
        {},
        {
            context = {},
            widget_width  = row_w+row_spacing,
            widget_height = row_h+row_spacing,
			peek_percent     = 0.5,
            num_visible_rows = 3,
            num_columns      = 7,
            item_ctor_fn = ScrollWidgetsCtor,
            apply_fn     = ScrollWidgetSetData,
            scrollbar_offset = 7,
            scrollbar_height_offset = -50
        })

	grid.up_button:SetTextures(atlas, "scrollbar_arrow_up.tex", "scrollbar_arrow_up_hl.tex")
    grid.up_button:SetScale(0.4)

	grid.down_button:SetTextures(atlas, "scrollbar_arrow_down.tex", "scrollbar_arrow_down_hl.tex")
    grid.down_button:SetScale(0.4)

	grid.scroll_bar_line:SetTexture(atlas, "scrollbar_bar.tex")
    grid.scroll_bar_line:ScaleToSize(11, grid.scrollbar_height - 15)

	grid.position_marker:SetTextures(atlas, "scrollbar_handle.tex")
	grid.position_marker.image:SetTexture(atlas, "scrollbar_handle.tex")
    grid.position_marker:SetScale(.3)

	grid.custom_focus_check = function() return self.focus end

	return grid
end

function CraftingMenuWidget:OnFavoriteChanged(recipe_name, is_favorite_recipe)
	if self.sort_class.OnFavoriteChanged then
		self.sort_class:OnFavoriteChanged(recipe_name, is_favorite_recipe)
	end
end

return CraftingMenuWidget