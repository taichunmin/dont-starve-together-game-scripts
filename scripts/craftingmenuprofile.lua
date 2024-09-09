local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"

local cooking = require("cooking")

local CraftingMenuProfile = Class(function(self)
	self.favorites = {}
	self.favorites_ordered = {}

	self.pinned_pages = {{}} -- !WARNING! this array may have holes in it, never use ipairs on this
	self.pinned_page = 1
	self.pinned_recipes = self.pinned_pages[1] -- Note: This is a reference to self.pinned_pages[]. !WARNING! this array may have holes in it, never use ipairs on this

	self:MakeDefaultPinnedRecipes()

	self.sort_mode = nil

	--self.new_recipes = {}

	self.save_enabled = true
end)

function CraftingMenuProfile:Save(force_save)
	if force_save or (self.save_enabled and self.dirty) then
		local data = 
		{
			version = 1, 
			favorites = self.favorites,
			sort_mode = self.sort_mode,
			pinned_page = self.pinned_page,
		}

		-- becaue our json encode/decoder doesn't support arrays with holes :(
		data.pinned_pages = {}
		for k, v in pairs(self.pinned_pages) do
			data.pinned_pages[tostring(k)] = {}
			for kk, vv in pairs(v) do
				data.pinned_pages[tostring(k)][tostring(kk)] = vv
			end
		end

		TheSim:SetPersistentString("craftingmenuprofile", json.encode(data), false)
		self.dirty = false
	end
end

function CraftingMenuProfile:Load()
	TheSim:GetPersistentString("craftingmenuprofile", function(load_success, data)
		if load_success and data ~= nil then
			local status, data = pcall( function() return json.decode(data) end )
		    if status and data then
				self.favorites = data.favorites or {}
				self.favorites_ordered = table.invert(self.favorites)

				if data.sort_mode ~= nil then
					self.sort_mode = tonumber(data.sort_mode)
				end

				self.pinned_page = data.pinned_page or 1

				if data.pinned_pages ~= nil then
					self.pinned_pages = {}
					for k, v in pairs(data.pinned_pages) do
						self.pinned_pages[tonumber(k)] = {}
						for kk, vv in pairs(v) do
							self.pinned_pages[tonumber(k)][tonumber(kk)] = vv
						end
					end
				end
				self.pinned_recipes = self.pinned_pages[self.pinned_page]
			else
				print("Faild to load the crafting menue profile!", status, data)
			end
		end
	end)
end

function CraftingMenuProfile:SetSortMode(mode)
	if self.sort_mode ~= mode then
		self.sort_mode = tonumber(mode)
		self.dirty = true
	end
end

function CraftingMenuProfile:GetSortMode()
	return self.sort_mode
end

function CraftingMenuProfile:GetFavorites()
	return self.favorites
end

function CraftingMenuProfile:GetFavoritesOrder()
	return self.favorites_ordered
end

function CraftingMenuProfile:IsFavorite(recipe_name)
	return self.favorites_ordered[recipe_name] ~= nil
end

function CraftingMenuProfile:AddFavorite(recipe_name)
	if not type(recipe_name) == "string" then
		print("[CraftingMenuProfile] Error: only strings can be added to recipe favorites.")
		return
	end

	if not self.favorites_ordered[recipe_name] then
		table.insert(self.favorites, recipe_name)
		self.favorites_ordered[recipe_name] = #self.favorites
		self.dirty = true
	end
end

function CraftingMenuProfile:RemoveFavorite(recipe_name)
	local cur_size = #self.favorites
	table.removearrayvalue(self.favorites, recipe_name)
	if cur_size ~= #self.favorites then
		self.favorites_ordered = table.invert(self.favorites)
		self.dirty = true
	end
end

-- Pinned Recipes

function CraftingMenuProfile:SetPinnedRecipe(slot, recipe_name, skin_name)
	if recipe_name == nil then
		self.pinned_recipes[slot] = nil
	elseif self.pinned_recipes[slot] ~= nil then
		self.pinned_recipes[slot].recipe_name = recipe_name
		self.pinned_recipes[slot].skin_name = skin_name
	else
		self.pinned_recipes[slot] = {recipe_name = recipe_name, skin_name = skin_name}
	end

	self.dirty = true
end

function CraftingMenuProfile:GetPinnedRecipes()
	return self.pinned_recipes
end

function CraftingMenuProfile:GetCurrentPage()
	return self.pinned_page
end

function CraftingMenuProfile:SetCurrentPage(page_num)
	self.pinned_page = page_num
	if self.pinned_pages[page_num] == nil then
		self.pinned_pages[page_num] = {}
	end
	self.pinned_recipes = self.pinned_pages[page_num]
	self.dirty = true
end

function CraftingMenuProfile:NextPage()
	local next_page = self.pinned_page + 1
	self:SetCurrentPage(next_page <= Profile:GetCraftingNumPinnedPages() and next_page or 1)
end

function CraftingMenuProfile:PrevPage()
	local prev_page = self.pinned_page - 1
	self:SetCurrentPage(prev_page >= 1 and prev_page or Profile:GetCraftingNumPinnedPages())
end

function CraftingMenuProfile:MakeDefaultPinnedRecipes()
	self.pinned_pages = {{}, {}}
	for _, v in ipairs(TUNING.DEFAULT_PINNED_RECIPES) do
		table.insert(self.pinned_pages[1], {recipe_name = v})
	end
	for _, v in ipairs(TUNING.DEFAULT_PINNED_RECIPES_2) do
		table.insert(self.pinned_pages[2], {recipe_name = v})
	end

	self.pinned_recipes = self.pinned_pages[1]
	self.pinned_page = 1
end

-- deprecated
function CraftingMenuProfile:DeserializeLocalClientSessionData(data)
end

-- deprecated
function CraftingMenuProfile:SerializeLocalClientSessionData()
	return {pinned_recipes = {}}
end

return CraftingMenuProfile
