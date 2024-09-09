local CraftingStation = Class(function(self, inst)
    self.inst = inst
    self.items = {}
    self.recipes = {}
    --self.nosave = false
end)

function CraftingStation:LearnItem(itemname, recipetouse)
    if not table.contains(self.items, itemname) then
        table.insert(self.items, itemname)
        table.insert(self.recipes, recipetouse)
    end
end

function CraftingStation:KnowsItem(itemname)
    return table.contains(self.items, itemname)
end

function CraftingStation:GetItems()
    return self.items
end

function CraftingStation:GetRecipes()
    return self.recipes
end

function CraftingStation:ForgetItem(itemname)
    for i, v in ipairs(self.items) do
        if v == itemname then
            table.remove(self.items, i)
            table.remove(self.recipes, i)
            break
        end
    end
end

function CraftingStation:ForgetAllItems()
    self.items = {}
    self.recipes = {}
end

function CraftingStation:OnSave()
    return not self.nosave and {
        items = self.items,
        recipes = self.recipes,
    } or nil
end

function CraftingStation:OnLoad(data)
    if not self.nosave then
        self.items = data.items or {}
        self.recipes = data.recipes or {}

        if #self.items ~= #self.recipes then
            self:ForgetAllItems()
        end
    end
end

return CraftingStation
