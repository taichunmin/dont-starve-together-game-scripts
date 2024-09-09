local function oncheckbadfood(self)
    if self.healthvalue < 0 or (self.sanityvalue ~= nil and self.sanityvalue < 0) then
        self.inst:AddTag("badfood")
    else
        self.inst:RemoveTag("badfood")
    end
end

local function onfoodtype(self, new_foodtype, old_foodtype)
    if old_foodtype ~= nil then
        self.inst:RemoveTag("edible_"..old_foodtype)
    end
    if new_foodtype ~= nil then
		assert(self.foodtype ~= self.secondaryfoodtype, "Edible component: The main and secondary food types cannot be set to the same value.")
        self.inst:AddTag("edible_"..new_foodtype)
    end
end

local Edible = Class(function(self, inst)
    self.inst = inst
    self.healthvalue = 10
    self.hungervalue = 10
    self.sanityvalue = 0
    self.foodtype = FOODTYPE.GENERIC
    self.secondaryfoodtype = nil
    self.oneaten = nil
    self.degrades_with_spoilage = true
    self.gethealthfn = nil
    self.getsanityfn = nil

    self.temperaturedelta = 0
    self.temperatureduration = 0

    --chill is a percentage [0, 1] of .temperatureduration
    --don't change this from 0 unless .temperaturedelta > 0
    self.chill = 0
    --self.nochill = false

    self.stale_hunger = TUNING.STALE_FOOD_HUNGER
    self.stale_health = TUNING.STALE_FOOD_HEALTH

    self.spoiled_hunger = TUNING.SPOILED_FOOD_HUNGER
    self.spoiled_health = TUNING.SPOILED_FOOD_HEALTH

    self.spice = nil
end,
nil,
{
    healthvalue = oncheckbadfood,
    sanityvalue = oncheckbadfood,
    foodtype = onfoodtype,
    secondaryfoodtype = onfoodtype,
})

function Edible:OnRemoveFromEntity()
    self.inst:RemoveTag("badfood")
    if self.foodtype ~= nil then
        self.inst:RemoveTag("edible_"..self.foodtype)
    end
    if self.secondaryfoodtype ~= nil then
        self.inst:RemoveTag("edible_"..self.secondaryfoodtype)
    end

    self.inst:RemoveTag("edible_"..FOODTYPE.BERRY)
end

--Deprecated
function Edible:GetWoodiness(eater) return 0 end
--

function Edible:GetSanity(eater)
    local sanityvalue = self.getsanityfn ~= nil and self.getsanityfn(self.inst, eater) or self.sanityvalue
    local ignore_spoilage = not self.degrades_with_spoilage or sanityvalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            if sanityvalue > 0 then
                return 0
            end
        elseif self.inst.components.perishable:IsSpoiled() then
            return -TUNING.SANITY_SMALL
        end
    end

    local multiplier = 1
    if self.spice and TUNING.SPICE_MULTIPLIERS[self.spice] and TUNING.SPICE_MULTIPLIERS[self.spice].SANITY then
        multiplier = multiplier + TUNING.SPICE_MULTIPLIERS[self.spice].SANITY
    end

    return sanityvalue * multiplier
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

    if eater ~= nil and eater.components.foodaffinity ~= nil then
        local affinity_bonus = eater.components.foodaffinity:GetAffinity(self.inst)
        if affinity_bonus ~= nil then
            multiplier = multiplier * affinity_bonus
        end
    end

    return multiplier * self.hungervalue
end

function Edible:GetHealth(eater)
    local multiplier = 1
    local healthvalue = self.gethealthfn ~= nil and self.gethealthfn(self.inst, eater) or self.healthvalue
    local spice_source = self.spice

    local ignore_spoilage = not self.degrades_with_spoilage or healthvalue < 0 or (eater ~= nil and eater.components.eater ~= nil and eater.components.eater.ignoresspoilage)

    if not ignore_spoilage and self.inst.components.perishable ~= nil then
        if self.inst.components.perishable:IsStale() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.stale_health or self.stale_health
        elseif self.inst.components.perishable:IsSpoiled() then
            multiplier = eater ~= nil and eater.components.eater ~= nil and eater.components.eater.spoiled_health or self.spoiled_health
            spice_source = nil
        end
    end

    if spice_source and TUNING.SPICE_MULTIPLIERS[spice_source] and TUNING.SPICE_MULTIPLIERS[spice_source].HEALTH then
        multiplier = multiplier + TUNING.SPICE_MULTIPLIERS[spice_source].HEALTH
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

function Edible:SetGetSanityFn(fn)
    self.getsanityfn = fn
end

function Edible:OnEaten(eater)
    if self.oneaten ~= nil then
        self.oneaten(self.inst, eater)
    end

    local delta_multiplier = 1
    local duration_multiplier = 1

    if self.spice and TUNING.SPICE_MULTIPLIERS[self.spice] then
        if TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDELTA then
            delta_multiplier = delta_multiplier + TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDELTA
        end

        if TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDURATION then
            duration_multiplier = duration_multiplier + TUNING.SPICE_MULTIPLIERS[self.spice].TEMPERATUREDURATION
        end
    end

    -- Food is an implicit heater/cooler if it has temperature
    if self.temperaturedelta ~= 0 and
        self.temperatureduration ~= 0 and
        self.chill < 1 and
        eater ~= nil and
        eater.components.temperature ~= nil then
        eater.components.temperature:SetTemperatureInBelly(self.temperaturedelta * (1 - self.chill) * delta_multiplier, self.temperatureduration * duration_multiplier)
    end

    self.inst:PushEvent("oneaten", { eater = eater })
    if self.inst.eatensound ~= nil and eater.SoundEmitter ~= nil then
        eater.SoundEmitter:PlaySound(self.inst.eatensound)
    end
end

function Edible:AddChill(delta)
    if self.temperaturedelta > 0 and not self.nochill then
        self.chill = math.clamp(self.chill + delta / self.temperatureduration, 0, 1)
    end
end

function Edible:DiluteChill(item, count)
    if self.temperaturedelta > 0 and not self.nochill and self.inst.components.stackable ~= nil and item.components.edible ~= nil then
        local stacksize = self.inst.components.stackable.stacksize
        self.chill = (stacksize * self.chill + count * item.components.edible.chill) / (stacksize + count)
    end
end

function Edible:OnSave()
    return self.chill > 0 and { chill = self.chill } or nil
end

function Edible:OnLoad(data)
    if data.chill ~= nil and self.temperaturedelta > 0 and not self.nochill then
        self.chill = math.clamp(data.chill, 0, 1)
    end
end

return Edible
