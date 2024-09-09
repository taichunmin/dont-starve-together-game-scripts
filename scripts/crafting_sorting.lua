require("metaclass")

local DefaultSort = MetaClass(function(self, widget)
	self.widget = widget

	for k, v in pairs(CRAFTING_FILTERS) do
		self[k] = {
			sorted = FunctionOrValue(shallowcopy(v.recipes)) or {},
			unsorted = {},
		}
		local default_sort_values = FunctionOrValue(v.default_sort_values)
		for k1 in pairs(AllRecipes) do
			if not default_sort_values or not default_sort_values[k1] then
				self[k].unsorted[k1] = true
			end
		end
	end

	self.unsorted = {}
	for k in pairs(AllRecipes) do
		self.unsorted[k] = true
	end
end)

function DefaultSort:BuildFavoriteTable()
    self.FAVORITES.sorted = FunctionOrValue(shallowcopy(CRAFTING_FILTERS.FAVORITES.recipes)) or {}
    self.FAVORITES.unsorted = {}
    local default_sort_values = FunctionOrValue(CRAFTING_FILTERS.FAVORITES.default_sort_values)
    for k in pairs(AllRecipes) do
        if not default_sort_values or not default_sort_values[k] then
            self.FAVORITES.unsorted[k] = true
        end
    end

    self.fullupdate = true
end

function DefaultSort:OnFavoriteChanged(recipe_name, is_favorite_recipe)
	self:BuildFavoriteTable()
end

function DefaultSort:Refresh()
	if self.fullupdate then
        self.fullupdate = nil
		self.widget:ApplyFilters()
		return true
	end

	return false
end

function DefaultSort:OnSelected()
    self:BuildFavoriteTable()
end

function DefaultSort:GetSorted()
	if self.widget.current_filter_name then
		local filter = self[self.widget.current_filter_name]
		return filter.sorted
	else
		return {}
	end
end

function DefaultSort:GetUnsorted()
	if self.widget.current_filter_name then
		local filter = self[self.widget.current_filter_name]
		return filter.unsorted
	else
		return self.unsorted
	end
end

function DefaultSort:__ipairs()
    --see https://www.lua.org/pil/9.3.html
    --using a coroutine to maintain a state inside the function
    --this iterates over first t.normal, and then t.dl
    local index = 0
    return coroutine.wrap(function()
		if self.widget.current_filter_name then
			local filter = self[self.widget.current_filter_name]
			for i, v in ipairs(filter.sorted) do
				index = index + 1
                coroutine.yield(index, v)
			end
			for k in pairs(filter.unsorted) do
				index = index + 1
				coroutine.yield(index, k)
			end
		else
			for k in pairs(self.unsorted) do
				index = index + 1
				coroutine.yield(index, k)
			end
		end
    end)
end

local CraftableSort = MetaClass(function(self, widget, defaultsort)
	self.widget = widget
	self.defaultsort = defaultsort

	self.buffered = {}
	self.craftable = {}
	self.uncraftable = {}
	self.recipelookup = {}

	self:ClearSortTables()

	for k, v in pairs(AllRecipes) do
		self.recipelookup[k] = self.uncraftable
		self.uncraftable[k] = true
	end
end)

function CraftableSort:ClearSortTables()
	if self.last_filter ~= self.widget.current_filter_name then
		self.buffered_sorted = nil
		self.buffered_unsorted = nil
		self.craftable_sorted = nil
		self.craftable_unsorted = nil
		self.uncraftable_sorted = nil
		self.uncraftable_unsorted = nil
	end
	self.last_filter = self.widget.current_filter_name
end

function CraftableSort:BuildCraftableTable()
	local build_state_sorting =
	{
		buffered = self.buffered,
		freecrafting = self.craftable,
		has_ingredients = self.craftable,
		prototype = self.craftable,
	}

	local buffered_changed = false
	local craftable_changed = false
	local uncraftable_changed = false

	for recipe_name, data in pairs(self.widget.crafting_hud.valid_recipes) do
		local old_table = self.recipelookup[recipe_name]
		local new_table = build_state_sorting[data.meta.build_state] or self.uncraftable
		if old_table ~= new_table then
			self.recipelookup[recipe_name] = new_table
			old_table[recipe_name] = nil
			new_table[recipe_name] = true

			if not buffered_changed and (old_table == self.buffered or new_table == self.buffered) then
				buffered_changed = true
			end
			if not craftable_changed and (old_table == self.craftable or new_table == self.craftable) then
				craftable_changed = true
			end
			if not uncraftable_changed and (old_table == self.uncraftable or new_table == self.uncraftable) then
				uncraftable_changed = true
			end
		end
	end

	if buffered_changed then
		self.buffered_sorted = nil
		self.buffered_unsorted = nil
	end
	if craftable_changed then
		self.craftable_sorted = nil
		self.craftable_unsorted = nil
	end
	if uncraftable_changed then
		self.uncraftable_sorted = nil
		self.uncraftable_unsorted = nil
	end

	return buffered_changed or craftable_changed or uncraftable_changed
end

function CraftableSort:OnFavoriteChanged(recipe_name, is_favorite_recipe)
	self.defaultsort:OnFavoriteChanged(recipe_name, is_favorite_recipe)
end

function CraftableSort:Refresh()
	local changed = self:BuildCraftableTable()
	local defaultsort = self.defaultsort:Refresh()

	if changed and not defaultsort then
		self.widget:ApplyFilters()
		return true
	end

	return defaultsort or false
end

function CraftableSort:OnSelected()
	self.defaultsort:Refresh()
	self:ClearSortTables()
	self:BuildCraftableTable()
end

function CraftableSort:OnSelectFilter()
	self:ClearSortTables()
end

function CraftableSort:FillSortedTable(recipes, validator, output)
	for i, v in ipairs(recipes) do
		if validator[v] then
			table.insert(output, v)
		end
	end
end

function CraftableSort:FillUnsortedTable(recipes, validator, output)
	for k in pairs(recipes) do
		if validator[k] then
			table.insert(output, k)
		end
	end
end

function CraftableSort:__ipairs()
	local sorted = self.defaultsort:GetSorted()
	local unsorted = self.defaultsort:GetUnsorted()

    local index = 0
    return coroutine.wrap(function()
		--buffered
		if not self.buffered_sorted then
			self.buffered_sorted = {}
			self:FillSortedTable(sorted, self.buffered, self.buffered_sorted)
		end
		for i, v in ipairs(self.buffered_sorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
		if not self.buffered_unsorted then
			self.buffered_unsorted = {}
			self:FillUnsortedTable(unsorted, self.buffered, self.buffered_unsorted)
		end
		for i, v in ipairs(self.buffered_unsorted) do
			index = index + 1
			coroutine.yield(index, v)
		end

		--craftable
		if not self.craftable_sorted then
			self.craftable_sorted = {}
			self:FillSortedTable(sorted, self.craftable, self.craftable_sorted)
		end
		for i, v in ipairs(self.craftable_sorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
		if not self.craftable_unsorted then
			self.craftable_unsorted = {}
			self:FillUnsortedTable(unsorted, self.craftable, self.craftable_unsorted)
		end
		for i, v in ipairs(self.craftable_unsorted) do
			index = index + 1
			coroutine.yield(index, v)
		end

		--uncraftable
		if not self.uncraftable_sorted then
			self.uncraftable_sorted = {}
			self:FillSortedTable(sorted, self.uncraftable, self.uncraftable_sorted)
		end
		for i, v in ipairs(self.uncraftable_sorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
		if not self.uncraftable_unsorted then
			self.uncraftable_unsorted = {}
			self:FillUnsortedTable(unsorted, self.uncraftable, self.uncraftable_unsorted)
		end
		for i, v in ipairs(self.uncraftable_unsorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
    end)
end

local FavoriteSort = MetaClass(function(self, widget, defaultsort)
	self.widget = widget
	self.defaultsort = defaultsort

    self.favorite = {}
    self.nonfavorite = {}

    self:ClearSortTables()

    for k, v in pairs(AllRecipes) do
        if TheCraftingMenuProfile:IsFavorite(k) then
            self.favorite[k] = true
        else
            self.nonfavorite[k] = true
        end
    end
end)

function FavoriteSort:ClearSortTables()
    if self.last_filter ~= self.widget.current_filter_name then
        self.favorite_sorted = nil
        self.favorite_unsorted = nil
        self.nonfavorite_sorted = nil
        self.nonfavorite_unsorted = nil
    end
    self.last_filter = self.widget.current_filter_name
end

function FavoriteSort:BuildFavoriteTable()
    local favorites_changed = false

    for recipe_name in pairs(AllRecipes) do
        if TheCraftingMenuProfile:IsFavorite(recipe_name) then
            if not self.favorite[recipe_name] then
                self.favorite[recipe_name] = true
                self.nonfavorite[recipe_name] = nil
                favorites_changed = true
            end
        else
            if not self.nonfavorite[recipe_name] then
                self.nonfavorite[recipe_name] = true
                self.favorite[recipe_name] = nil
                favorites_changed = true
            end
        end
    end

    if favorites_changed then
        self.favorites_sorted = nil
        self.favorites_unsorted = nil
        self.nonfavorites_sorted = nil
        self.nonfavorites_unsorted = nil
    end
end

function FavoriteSort:OnFavoriteChanged(recipe_name, is_favorite_recipe)
	self.defaultsort:OnFavoriteChanged(recipe_name, is_favorite_recipe)

	local unsorted = self.defaultsort:GetUnsorted()

    if is_favorite_recipe then
        self.nonfavorite[recipe_name] = nil
        self.favorite[recipe_name] = true

        if not unsorted[recipe_name] then
            if self.nonfavorite_sorted then
                table.removearrayvalue(self.nonfavorite_sorted, recipe_name)
            end
            self.favorite_sorted = nil
        else
            if self.nonfavorite_unsorted then
                table.removearrayvalue(self.nonfavorite_unsorted, recipe_name)
            end
            self.favorite_unsorted = nil
        end
    else
        self.favorite[recipe_name] = nil
        self.nonfavorite[recipe_name] = true

        if not unsorted[recipe_name] then
            if self.favorite_sorted then
                table.removearrayvalue(self.favorite_sorted, recipe_name)
            end
            self.nonfavorite_sorted = nil
        else
            if self.favorite_unsorted then
                table.removearrayvalue(self.favorite_unsorted, recipe_name)
            end
            self.nonfavorite_unsorted = nil
        end
    end

    self.defaultsort.fullupdate = true
end

function FavoriteSort:Refresh()
	if self.defaultsort.fullupdate then
		self.favorite_sorted = nil
		self.favorite_unsorted = nil
		self.nonfavorite_sorted = nil
		self.nonfavorite_unsorted = nil
	end

	return self.defaultsort:Refresh()
end

function FavoriteSort:OnSelected()
	self.defaultsort:OnSelected()

    self:ClearSortTables()
    self:BuildFavoriteTable()
end

function FavoriteSort:OnSelectFilter()
    self:ClearSortTables()
end

function FavoriteSort:FillSortedTable(recipes, validator, output)
    for i, v in ipairs(recipes) do
        if validator[v] then
            table.insert(output, v)
        end
    end
end

function FavoriteSort:FillUnsortedTable(recipes, validator, output)
    for k in pairs(recipes) do
        if validator[k] then
            table.insert(output, k)
        end
    end
end

function FavoriteSort:__ipairs()
	local sorted = self.defaultsort:GetSorted()
	local unsorted = self.defaultsort:GetUnsorted()

    local index = 0
    return coroutine.wrap(function()
		--favorite
		if not self.favorite_sorted then
			self.favorite_sorted = {}
			self:FillSortedTable(sorted, self.favorite, self.favorite_sorted)
		end
		for i, v in ipairs(self.favorite_sorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
		if not self.favorite_unsorted then
			self.favorite_unsorted = {}
			self:FillUnsortedTable(unsorted, self.favorite, self.favorite_unsorted)
		end
		for i, v in ipairs(self.favorite_unsorted) do
			index = index + 1
			coroutine.yield(index, v)
		end

		--nonfavorite
		if not self.nonfavorite_sorted then
			self.nonfavorite_sorted = {}
			self:FillSortedTable(sorted, self.nonfavorite, self.nonfavorite_sorted)
		end
		for i, v in ipairs(self.nonfavorite_sorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
		if not self.nonfavorite_unsorted then
			self.nonfavorite_unsorted = {}
			self:FillUnsortedTable(unsorted, self.nonfavorite, self.nonfavorite_unsorted)
		end
		for i, v in ipairs(self.nonfavorite_unsorted) do
			index = index + 1
			coroutine.yield(index, v)
		end
    end)
end

local AlphaSort = MetaClass(function(self, widget)
	self.widget = widget

	local function sort_alpha(a, b)
		local recipe_a = AllRecipes[a]
		local recipe_b = AllRecipes[b]
		local a_name = STRINGS.NAMES[string.upper(a)] or STRINGS.NAMES[string.upper(recipe_a.product)] or ""
		local b_name = STRINGS.NAMES[string.upper(b)] or STRINGS.NAMES[string.upper(recipe_b.product)] or ""
		return a_name < b_name
	end

	self.alpha_sorted = {}
	for k, v in pairs(AllRecipes) do
		table.insert(self.alpha_sorted, k)
	end
	table.sort(self.alpha_sorted, sort_alpha)
end)

function AlphaSort:__ipairs()
	return ipairs(self.alpha_sorted)
end

return {
    DefaultSort = DefaultSort,
    CraftableSort = CraftableSort,
    FavoriteSort = FavoriteSort,
    AlphaSort = AlphaSort,
}