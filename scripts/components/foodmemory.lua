local spicedfoods = require("spicedfoods")

local FoodMemory = Class(function(self, inst)
    self.inst = inst
    self.duration = TUNING.TOTAL_DAY_TIME
    self.foods = {}
    self.mults = nil
end)

function FoodMemory:OnRemoveFromEntity()
    for k, v in pairs(self.foods) do
        v.task:Cancel()
    end
end

function FoodMemory:SetDuration(duration)
    self.duration = duration
end

function FoodMemory:SetMultipliers(mults)
    self.mults = mults
end

local function OnForgetFood(inst, self, prefab)
    self.foods[prefab] = nil
end

function FoodMemory:GetBaseFood(prefab)
    return spicedfoods[prefab] ~= nil and spicedfoods[prefab].basename or prefab
end

function FoodMemory:RememberFood(prefab)
    prefab = self:GetBaseFood(prefab)
    local rec = self.foods[prefab]
    if rec ~= nil then
        rec.count = rec.count + 1
        rec.task:Cancel()
        rec.task = self.inst:DoTaskInTime(self.duration, OnForgetFood, self, prefab)
    else
        self.foods[prefab] =
        {
            count = 1,
            task = self.inst:DoTaskInTime(self.duration, OnForgetFood, self, prefab),
        }
    end
end

function FoodMemory:GetMemoryCount(prefab)
    local rec = self.foods[self:GetBaseFood(prefab)]
    return rec ~= nil and rec.count or 0
end

function FoodMemory:GetFoodMultiplier(prefab)
    local count = self:GetMemoryCount(prefab)
    return count > 0 and self.mults ~= nil and self.mults[math.min(#self.mults, count)] or 1
end

function FoodMemory:OnSave()
    if next(self.foods) ~= nil then
        local foods = {}
        for k, v in pairs(self.foods) do
            foods[k] = { count = v.count, t = GetTaskRemaining(v.task) }
        end
        return { foods = foods }
    end
end

function FoodMemory:OnLoad(data)--, ents)
    if data.foods ~= nil then
        for k, v in pairs(data.foods) do
            local rec = self.foods[k]
            if rec ~= nil then
                rec.count = v.count or 1
                rec.task:Cancel()
                rec.task = self.inst:DoTaskInTime(v.t or self.duration, OnForgetFood, self, k)
            else
                self.foods[k] =
                {
                    count = v.count or 1,
                    task = self.inst:DoTaskInTime(v.t or self.duration, OnForgetFood, self, k)
                }
            end
        end
    end
end

return FoodMemory
