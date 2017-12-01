local function oncheckbadfood(self)
    if self.healthvalue < 0 or
        (self.sanityvalue ~= nil and self.sanityvalue < 0) or
        (self.woodiness ~= nil and self.woodiness < 0) then
        self.inst:AddTag("badfood")
    else
        self.inst:RemoveTag("badfood")
    end
end

local function onfoodtype(self, foodtype, old_foodtype)
    if old_foodtype ~= nil then
        self.inst:RemoveTag("edible_"..old_foodtype)
    end
    if foodtype ~= nil then
        self.inst:AddTag("edible_"..foodtype)
    end
end

local Edible = Class(function(self, inst)
    self.inst = inst
    self.healthvalue = 10
    self.hungervalue = 10
    self.sanityvalue = 0
    self.woodiness = nil
    self.foodtype = FOODTYPE.GENERIC
    self.oneaten = nil
    self.degrades_with_spoilage = true
    self.gethealthfn = nil

    self.temperaturedelta = 0
    self.temperatureduration = 0

    self.stale_hunger = TUNING.STALE_FOOD_HUNGER
    self.stale_health = TUNING.STALE_FOOD_HEALTH

    self.spoiled_hunger = TUNING.SPOILED_FOOD_HUNGER
    self.spoiled_health = TUNING.SPOILED_FOOD_HEALTH

    if inst.prefab == "berries" then
        --hack for smallbird; berries are actually part of veggie
        inst:AddTag("edible_"..FOODTYPE.BERRY)
    end
end,
nil,
{
    healthvalue = oncheckbadfood,
    sanityvalue = oncheckbadfood,
    woodiness = oncheckbadfood,
    foodtype = onfoodtype,
})

function Edible:OnRemoveFromEntity()
    self.inst:RemoveTag("badfood")
    if self.foodtype ~= nil then
        self.inst:RemoveTag("edible_"..self.foodtype)
    end
    self.inst:RemoveTag("edible_"..FOODTYPE.BERRY)
end

function Edible:GetWoodiness(eater)
    return self.woodiness or 0
end

function Edible:GetSanity(eater)
    local ignore_spoilage = not self.degrades_with_spoilage or self.sanityvalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            if self.sanityvalue > 0 then
                return 0
            end
        elseif self.inst.components.perishable:IsSpoiled() then
            return -TUNING.SANITY_SMALL
        end
    end

    return self.sanityvalue
end

function Edible:GetHunger(eater)
    local multiplier = 1
    local ignore_spoilage = not self.degrades_with_spoilage or self.hungervalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.stale_hunger or self.stale_hunger
        elseif self.inst.components.perishable:IsSpoiled() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.spoiled_hunger or self.spoiled_hunger
        end
    end

    return multiplier * self.hungervalue
end

function Edible:GetHealth(eater)
    local multiplier = 1
    local healthvalue = self.gethealthfn ~= nil and self.gethealthfn(self.inst, eater) or self.healthvalue

    local ignore_spoilage = not self.degrades_with_spoilage or healthvalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.stale_health or self.stale_health
        elseif self.inst.components.perishable:IsSpoiled() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.spoiled_health or self.spoiled_health
        end
    end
    return multiplier * healthvalue
end

function Edible:GetDebugString()
    return string.format("Food type: %s, health: %2.2f, hunger: %2.2f, sanity: %2.2f", self.foodtype, self.healthvalue, self.hungervalue, self.sanityvalue)
end

function Edible:SetOnEatenFn(fn)
    self.oneaten = fn
end

function Edible:SetGetHealthFn(fn)
    self.gethealthfn = fn
end

function Edible:OnEaten(eater)
    if self.oneaten ~= nil then
        self.oneaten(self.inst, eater)
    end

    -- Food is an implicit heater/cooler if it has temperature
    if self.temperaturedelta ~= 0 and self.temperatureduration ~= 0 and eater ~= nil and eater.components.temperature ~= nil then
        eater.components.temperature:SetTemperatureInBelly(self.temperaturedelta, self.temperatureduration)
    end

    self.inst:PushEvent("oneaten", { eater = eater })
end

return Edible
