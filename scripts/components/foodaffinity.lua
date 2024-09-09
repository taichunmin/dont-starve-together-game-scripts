local spicedfoods = require("spicedfoods")

-- Gives characters a hugner bonus from eating a specific item or footype
local FoodAffinity = Class(function(self, inst)
    self.inst = inst
    self.tag_affinities = {}
    self.prefab_affinities = {}
    self.prefab_affinites = self.prefab_affinities -- Notes(JBK): Keep this typo around for mods.
    self.foodtype_affinities = {}
end)

function FoodAffinity:SortAffinitiesByBonus(affinities)
    table.sort(affinities, function(a,b) return a.hunger_bonus > b.hunger_bonus end)
end

function FoodAffinity:AddTagAffinity(tag, bonus)
    self.tag_affinities[tag] = bonus
end

function FoodAffinity:AddPrefabAffinity(prefab, bonus)
    self.prefab_affinities[prefab] = bonus
end

function FoodAffinity:AddFoodtypeAffinity(foodtype, bonus)
    self.foodtype_affinities[foodtype] = bonus
end

function FoodAffinity:RemoveTagAffinity(tag)
    self.tag_affinities[tag] = nil
end

function FoodAffinity:RemovePrefabAffinity(prefab)
    self.prefab_affinities[prefab] = nil
end

function FoodAffinity:RemoveFoodtypeAffinity(foodtype)
    self.foodtype_affinities[foodtype] = nil
end

function FoodAffinity:HasAffinity(food)
    if self:HasPrefabAffinity(food) then
        return true
    end

    if food.components.edible and self.foodtype_affinities[food.components.edible.foodtype] then
        return true
    end

    for tag,bonus in pairs(self.tag_affinities) do
        if food:HasTag(tag) then
            return true
        end
    end
end

function FoodAffinity:GetFoodBasePrefab(food)
    local prefab = food.prefab
    return spicedfoods[prefab] and spicedfoods[prefab].basename or prefab
end

function FoodAffinity:HasPrefabAffinity(food)
    if self.prefab_affinities[food.prefab] ~= nil then
        return true
    end
    local basefood = self:GetFoodBasePrefab(food)
    return self.prefab_affinities[basefood] ~= nil
end

function FoodAffinity:GetAffinity(food)
    local found_affinities = {}

    if self.prefab_affinities[food.prefab] ~= nil then
        table.insert(found_affinities, self.prefab_affinities[food.prefab])
    end

    local basefood = self:GetFoodBasePrefab(food)
    local prefabaffinity = self.prefab_affinities[basefood]
    if prefabaffinity ~= nil then
        table.insert(found_affinities, prefabaffinity)
    end

    if food.components.edible and self.foodtype_affinities[food.components.edible.foodtype] then
        table.insert(found_affinities, self.foodtype_affinities[food.components.edible.foodtype])
    end

    for tag,bonus in pairs(self.tag_affinities) do
        if food:HasTag(tag) then
            table.insert(found_affinities, bonus)
        end
    end

    if #found_affinities > 0 then
        if #found_affinities > 1 then
            -- Sort the found_affinities so we return the biggest bonus
            table.sort(found_affinities, function(a,b) return a > b end)
        end
        return found_affinities[1]
    end
end

return FoodAffinity