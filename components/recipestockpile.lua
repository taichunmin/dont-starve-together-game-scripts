
local function onitemcrafted(inst, data)
	inst.components.recipestockpile:OnItemCrafted(data.recipe.name)
end

local RecipeStockpile = Class(function(self, inst)
    self.inst = inst
    self.stock = {} -- recipe, max, restocktime, onrestockfn, onemptyfn -- num, timer

	self.inst:ListenForEvent("builditem", onitemcrafted)
end)

function RecipeStockpile:OnRemoveFromEntity(data)
    self.inst:RemoveEventCallback("builditem", onitemcrafted)
end

local function OnRestock(inst, self, recipe)
	local stock = self.stock[recipe] or nil
	if stock ~= nil then
		stock.num = math.min(stock.num + 1, stock.max)
		if stock.num ~= stock.max then
			stock.timer = self.inst:DoTaskInTime(stock.restocktime, OnRestock, self, recipe)
		else
			stock.timer = nil
		end
		if stock.onrestockfn ~= nil then
			stock.onrestockfn(self.inst, recipe, stock.num, stock.max)
		end
	end
end

function RecipeStockpile:SetupItem(data, start_restock_timer)
	if self.stock[data.recipe] == nil then
		self.stock[data.recipe] = {}
		self.stock[data.recipe] = deepcopy(data)
		self.stock[data.recipe].num = self.stock[data.recipe].num or self.stock[data.recipe].max

		if self.stock[data.recipe].num > 0 then
			if data.onrestockfn ~= nil then
				data.onrestockfn(self.inst, data.recipe, self.stock[data.recipe].num, self.stock[data.recipe].max)
			end
		else
			if data.onemptyfn ~= nil then
				data.onemptyfn(self.inst, data.recipe)
			end
		end

		if start_restock_timer and self.stock[data.recipe].restocktime ~= nil and self.stock[data.recipe].num < self.stock[data.recipe].max then
			self.stock[data.recipe].timer = self.inst:DoTaskInTime(self.stock[data.recipe].restocktime, OnRestock, self, data.recipe)
		end
	end
end

function RecipeStockpile:RemoveAllStock(allow_restock)
	for k, stock in pairs(self.stock) do
		if stock.num > 0 then
			stock.num = 0
			if stock.timer ~= nil then
				stock.timer:Cancel()
				stock.timer = nil
			end
			if allow_restock and time.restocktime ~= nil then
				stock.timer = self.inst:DoTaskInTime(stock.restocktime, OnRestock, self, recipe)
			end
			if stock.onemptyfn ~= nil then
				stock.onemptyfn(self.inst, stock.recipe)
			end
		end
	end
end

function RecipeStockpile:RemoveStock(recipe, allow_restock)
	local stock = self.stock[recipe]
	if stock ~= nil and stock.num > 0 then
		--print (recipe, stock.num, stock.timer, stock.restocktime, stock.onemptyfn)
		stock.num = 0
		if stock.timer ~= nil then
			stock.timer:Cancel()
			stock.timer = nil
		end
		if allow_restock and time.restocktime ~= nil then
			stock.timer = self.inst:DoTaskInTime(stock.restocktime, OnRestock, self, recipe)
		end
		if stock.onemptyfn ~= nil then
			stock.onemptyfn(self.inst, stock.recipe)
		end
	end
end

function RecipeStockpile:FullyRestockItem(recipe)
	local stock = self.stock[recipe]
	if stock ~= nil then
		stock.num = stock.max
		if stock.timer ~= nil then
			stock.timer:Cancel()
			stock.timer = nil
		end
		if stock.onrestockfn ~= nil then
			stock.onrestockfn(self.inst, recipe, stock.num, stock.max)
		end
	end
end

function RecipeStockpile:HasAnyStock()
	for k, v in pairs(self.stock) do
		if v.num > 0 then
			return true
		end
	end
	return false
end

function RecipeStockpile:OnItemCrafted(recipe)
	local stock = self.stock[recipe] or nil
	if stock ~= nil and stock.num > 0 then
		stock.num = stock.num - 1
		if stock.restocktime ~= nil and stock.timer == nil then
			stock.timer = self.inst:DoTaskInTime(stock.restocktime, OnRestock, self, recipe)
		end
		if stock.num == 0 and stock.onemptyfn ~= nil then
			stock.onemptyfn(self.inst, recipe)
		end
	end
end

function RecipeStockpile:OnSave()
	local data = {}
	for k, v in pairs(self.stock) do
		data[v.recipe] = {
			num = v.num,
			timer = v.timer ~= nil and GetTaskRemaining(v.timer) or nil,
		}
	end
    return data
end

function RecipeStockpile:OnLoad(data)
	for k, v in pairs(data) do
		if self.stock[k] ~= nil then
			self.stock[k].num = v.num
			if self.stock[k].timer ~= nil then
				self.stock[k].timer:Cancel()
				self.stock[k].timer = nil
			end
			if v.timer ~= nil then
				self.stock[k].timer = self.inst:DoTaskInTime(v.timer, OnRestock, self, k)
			end
		end
	end
end

function RecipeStockpile:GetDebugString()
	local str = ""
	for k, v in pairs(self.stock) do
		str = str .. "\n\t" .. v.recipe .. ": " .. v.num .. "/" ..v.max
		if v.timer ~= nil then
			str = str .. " (" .. GetTaskRemaining(v.timer) .. ")"
		end
	end

	return str
end


return RecipeStockpile