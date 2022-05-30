local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"

local MAX_RECIPES = 6
local cooking = require("cooking")

local CookbookData = Class(function(self)
	self.preparedfoods = {}

	self.newfoods = {}
	self.filters = {}
	--self.save_enabled = nil
end)

function CookbookData:GetKnownPreparedFoods()
	return self.preparedfoods
end

function CookbookData:Save(force_save)
	if force_save or (self.save_enabled and self.dirty) then
		local str = json.encode({preparedfoods = self.preparedfoods, filters = self.filters})
		TheSim:SetPersistentString("cookbook", str, false)
		self.dirty = false
	end
end

function CookbookData:Load()
	self.preparedfoods = {}
	TheSim:GetPersistentString("cookbook", function(load_success, data)
		if load_success and data ~= nil then
			local status, recipe_book = pcall( function() return json.decode(data) end )
		    if status and recipe_book then
				self.preparedfoods = recipe_book.preparedfoods or {}
				self.filters = recipe_book.filters or {}
			else
				print("Faild to load the cookbook!", status, recipe_book)
			end
		end
	end)
end

local function DecodeCookbookEntry(value)
	local data = {recipes = {}}
	local recipes = string.split(value, "|")
	for i = 1, #recipes-1 do
		table.insert(data.recipes, string.split(recipes[i], ","))
	end
	data.has_eaten = recipes[#recipes] == "true"
	return data
end

local function EncodeCookbookEntry(entry)
	local str = ""
	if entry.recipes ~= nil then
		for i = 1, math.min(MAX_RECIPES, #entry.recipes) do
			local r = entry.recipes[i]
			str = str .. table.concat(r, ",") .. "|"
		end
	end
	str = str .. (entry.has_eaten and "true" or "false")
	return str
end

function CookbookData:ApplyOnlineProfileData()
	if not self.synced and not (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) and TheInventory:HasDownloadedInventory() then
		self.preparedfoods = self.preparedfoods or {}
		for k, v in pairs(TheInventory:GetLocalCookBook()) do
			self.preparedfoods[k] = DecodeCookbookEntry(v)
		end
		self.synced = true
	end
	return self.synced
end

function CookbookData:IsNewFood(product)
	return self.newfoods[product] == true
end

function CookbookData:ClearNewFlags()
	self.newfoods = {}
end

function CookbookData:ClearFilters()
	self.filters = {}
	self.dirty = true
end

function CookbookData:SetFilter(category, value)
	if self.filters[category] ~= value then
		self.filters[category] = value
		self.dirty = true
	end
end

function CookbookData:GetFilter(category)
	return self.filters[category]
end

function CookbookData:IsUnlocked(product)
	return self.preparedfoods[product]
end

local function UnlockPreparedFood(self, product)
	if self.preparedfoods[product] == nil then
		self.preparedfoods[product] = {}
	end
	return self.preparedfoods[product]
end

function CookbookData:LearnFoodStats(product)
	local updated = false
	local preparedfood = UnlockPreparedFood(self, product)
	if not preparedfood.has_eaten then
		preparedfood.has_eaten = true
		self.newfoods[product] = true
		updated = true
	end

	if updated and self.save_enabled then
		if not cooking.IsModCookerFood(product) and not TheNet:IsDedicated() then
			TheInventory:SetCookBookValue(product, EncodeCookbookEntry(preparedfood))
		end
		self:Save(true)
	end

	return updated
end

local function IsKnownRecipe(known_recipes, ingredients)
	for ri, known_recipe in ipairs(known_recipes) do
		if #ingredients == #known_recipe then
			local known = true
			for i, ingredient in ipairs(ingredients) do
				if ingredients[i] ~= known_recipe[i] then
					known = false
					break
				end
			end
			if known then
				return ri
			end
		end
	end
end

function CookbookData:AddRecipe(product, ingredients)
	if product == nil or ingredients == nil then
		print("Invalid cookbook recipe:", product, unpack(ingredients or {"(empty)"}))
		return
	end

	ingredients = self:RemoveCookedFromName(ingredients)
	table.sort(ingredients)

	local updated = false

	local preparedfood = UnlockPreparedFood(self, product)
	if preparedfood.recipes == nil then
		preparedfood.recipes = {ingredients}

		self.newfoods[product] = true
		updated = true
	else
		local recipes = preparedfood.recipes
		local known_index = IsKnownRecipe(recipes, ingredients)
		if known_index ~= nil then
			if known_index > 2 then
				table.remove(recipes, known_index)
				table.insert(recipes, 1, ingredients)
				updated = true
			end
		else
			if #recipes >= MAX_RECIPES then
				table.remove(recipes, #recipes)
			end
			table.insert(recipes, 1, ingredients)
			self.newfoods[product] = true
			updated = true
		end
	end

	if updated and self.save_enabled then
		if not cooking.IsModCookerFood(product) and not TheNet:IsDedicated() then
			TheInventory:SetCookBookValue(product, EncodeCookbookEntry(preparedfood))
		end
		self:Save(true)
	end

	return updated
end

function CookbookData:RemoveCookedFromName(ingredients)
	local ret = {}
		for i, v in ipairs(ingredients) do
			local str = v
			str = string.gsub(str, "_cooked_", "")
			str = string.gsub(str, "cooked_", "")
			str = string.gsub(str, "quagmire_cooked", "quagmire_")
			str = string.gsub(str, "_cooked", "")
			str = string.gsub(str, "cooked", "")
			table.insert(ret, str)
		end
	return ret
end

return CookbookData
