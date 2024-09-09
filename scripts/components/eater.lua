local function clearcaneat(self, caneat)
    for i, v in ipairs(caneat) do
        self.inst:RemoveTag((type(v) == "table" and v.name or v).."_eater")
    end
end

local function oncaneat(self, caneat, old_caneat)
    if old_caneat ~= nil then
        clearcaneat(self, old_caneat)
    end
    if caneat ~= nil then
        for i, v in ipairs(caneat) do
            self.inst:AddTag((type(v) == "table" and v.name or v).."_eater")
        end
    end
end

local Eater = Class(function(self, inst)
    self.inst = inst
    self.eater = false
    self.strongstomach = false
    self.preferseating = { FOODGROUP.OMNI }
    --self.perferseatingtags = nil
    self.caneat = { FOODGROUP.OMNI }
    self.oneatfn = nil
    self.lasteattime = nil
    self.ignoresspoilage = false
    self.eatwholestack = false
--[[
    --can be overridden by prefabs
    self.stale_hunger = nil
    self.stale_health = nil
    self.spoiled_hunger = nil
    self.spoiled_health = nil
]]
    self.healthabsorption = 1
    self.hungerabsorption = 1
    self.sanityabsorption = 1

    --set to false to disable cached tags
    --self.cacheedibletags = nil
end,
nil,
{
    caneat = oncaneat,
})

function Eater:OnRemoveFromEntity()
    clearcaneat(self, self.caneat)
end

function Eater:SetDiet(caneat, preferseating)
    self.caneat = caneat
    self.preferseating = preferseating or caneat
end

function Eater:SetAbsorptionModifiers(health, hunger, sanity)
    self.healthabsorption = health
    self.hungerabsorption = hunger
    self.sanityabsorption = sanity
end

function Eater:TimeSinceLastEating()
    return self.lasteattime ~= nil and GetTime() - self.lasteattime or nil
end

function Eater:HasBeen(time)
    return self.lasteattime == nil or self:TimeSinceLastEating() >= time
end

function Eater:OnSave()
    return self.lasteattime ~= nil
        and {
                time_since_eat = self:TimeSinceLastEating(),
            }
        or nil
end

function Eater:OnLoad(data)
    if data.time_since_eat then
        self.lasteattime = GetTime() - data.time_since_eat
    end
end

function Eater:SetCanEatHorrible()
    table.insert(self.preferseating, FOODTYPE.HORRIBLE)
    table.insert(self.caneat, FOODTYPE.HORRIBLE)
    self.inst:AddTag(FOODTYPE.HORRIBLE.."_eater")
end

function Eater:SetCanEatGears()
    table.insert(self.preferseating, FOODTYPE.GEARS)
    table.insert(self.caneat, FOODTYPE.GEARS)
    self.inst:AddTag(FOODTYPE.GEARS.."_eater")
end

function Eater:SetCanEatNitre(can_eat)
    local tag = FOODTYPE.NITRE .. "_eater"
    local hastag = self.inst:HasTag(tag)
    if can_eat then
        if not hastag then
            table.insert(self.preferseating, FOODTYPE.NITRE)
            table.insert(self.caneat, FOODTYPE.NITRE)
            self.inst:AddTag(tag)
        end
    else
        if hastag then
            table.removearrayvalue(self.preferseating, FOODTYPE.NITRE)
            table.removearrayvalue(self.caneat, FOODTYPE.NITRE)
            self.inst:RemoveTag(tag)
        end
    end
end

function Eater:SetCanEatRaw()
    table.insert(self.preferseating, FOODTYPE.RAW)
    table.insert(self.caneat, FOODTYPE.RAW)
    self.inst:AddTag(FOODTYPE.RAW.."_eater")
end

function Eater:SetPrefersEatingTag(tag)
    if self.preferseatingtags == nil then
        self.preferseatingtags = { tag }
    else
        table.insert(self.preferseatingtags, tag)
    end
end

function Eater:SetStrongStomach(is_strong)
    if is_strong then
        self.inst:AddTag("strongstomach")
        self.strongstomach = true
    else
        if self.inst:HasTag("strongstomach") then
            self.inst:RemoveTag("strongstomach")
        end

        self.strongstomach = false
    end
end

function Eater:SetCanEatRawMeat(can_eat)
    if can_eat then
        self.inst:AddTag("eatsrawmeat")
        self.eatsrawmeat = true
    else
        if self.inst:HasTag("eatsrawmeat") then
            self.inst:RemoveTag("eatsrawmeat")
        end

        self.eatsrawmeat = false
    end
end

function Eater:SetIgnoresSpoilage(ignores)
    if ignores then
        self.inst:AddTag("ignoresspoilage")
        self.ignoresspoilage = true
    else
        if self.inst:HasTag("ignoresspoilage") then
            self.inst:RemoveTag("ignoresspoilage")
        end

        self.ignoresspoilage = false
    end
end

function Eater:SetRefusesSpoiledFood(refuses)
    if refuses then
        self.inst:AddTag("nospoiledfood")
        self.nospoiledfood = true
    else
        if self.inst:HasTag("nospoiledfood") then
            self.inst:RemoveTag("nospoiledfood")
        end
        
        self.nospoiledfood = false
    end
end

function Eater:SetOnEatFn(fn)
    self.oneatfn = fn
end

function Eater:DoFoodEffects(food)
    return not ((self.strongstomach and food:HasTag("monstermeat")) or
                (self.eatsrawmeat and food:HasTag("rawmeat")) or 
                (self.inst.components.foodaffinity and self.inst.components.foodaffinity:HasPrefabAffinity(food)))
end

function Eater:GetEdibleTags()
    if self.cacheedibletags then
        return self.cacheedibletags
    end

    local tags = {}
    for i, v in ipairs(self.caneat) do
        if type(v) == "table" then
            for i2, v2 in ipairs(v.types) do
                table.insert(tags, "edible_"..v2)
            end
        else
            table.insert(tags, "edible_"..v)
        end
    end

    if self.cacheedibletags ~= false then
        self.cacheedibletags = tags
    end
    return tags
end

function Eater:Eat(food, feeder)
    feeder = feeder or self.inst
    -- This used to be CanEat. The reason for two checks is to that special diet characters (e.g.
    -- wigfrid) can TRY to eat all foods (they get the actions for it) but upon actually put it in
    -- their mouth, they bail and "spit it out" so to speak.
    if self:PrefersToEat(food) then
        local stack_mult = self.eatwholestack and food.components.stackable ~= nil and food.components.stackable:StackSize() or 1
        local base_mult = self.inst.components.foodmemory ~= nil and self.inst.components.foodmemory:GetFoodMultiplier(food.prefab) or 1

		local health_delta = 0
		local hunger_delta = 0
		local sanity_delta = 0

        if self.inst.components.health ~= nil and
            (food.components.edible.healthvalue >= 0 or self:DoFoodEffects(food)) then
            health_delta = food.components.edible:GetHealth(self.inst) * base_mult * self.healthabsorption

            --local delta = food.components.edible:GetHealth(self.inst) * base_mult 
			--delta = delta * FunctionOrValue(self.healthabsorption, self.inst, delta, food, feeder)
            --if delta ~= 0 then
            --    self.inst.components.health:DoDelta(delta * stack_mult, nil, food.prefab)
            --end

        end

        if self.inst.components.hunger ~= nil then
            hunger_delta = food.components.edible:GetHunger(self.inst) * base_mult * self.hungerabsorption

            --local delta = food.components.edible:GetHunger(self.inst) * base_mult
			--delta = delta * FunctionOrValue(self.hungerabsorption, self.inst, delta, food, feeder)
            --if delta ~= 0 then
            --    self.inst.components.hunger:DoDelta(delta * stack_mult)
            --end
        end

        if self.inst.components.sanity ~= nil and
            (food.components.edible.sanityvalue >= 0 or self:DoFoodEffects(food)) then
            sanity_delta = food.components.edible:GetSanity(self.inst) * base_mult * self.sanityabsorption

            --local delta = food.components.edible:GetSanity(self.inst) * base_mult
			--delta = delta * FunctionOrValue(self.sanityabsorption, self.inst, delta, food, feeder)
            --if delta ~= 0 then
            --    self.inst.components.sanity:DoDelta(delta * stack_mult)
            --end
        end

		if self.custom_stats_mod_fn ~= nil then
			health_delta, hunger_delta, sanity_delta = self.custom_stats_mod_fn(self.inst, health_delta, hunger_delta, sanity_delta, food, feeder)
		end

        if health_delta ~= 0 then
            self.inst.components.health:DoDelta(health_delta * stack_mult, nil, food.prefab)
        end
        if hunger_delta ~= 0 then
            self.inst.components.hunger:DoDelta(hunger_delta * stack_mult)
        end
        if sanity_delta ~= 0 then
            self.inst.components.sanity:DoDelta(sanity_delta * stack_mult)
        end

        if feeder ~= self.inst and self.inst.components.inventoryitem ~= nil then
            local owner = self.inst.components.inventoryitem:GetGrandOwner()
            if owner ~= nil and (owner == feeder or (owner.components.container ~= nil and owner.components.container:IsOpenedBy(feeder))) then
                feeder:PushEvent("feedincontainer")
            end
        end

        self.inst:PushEvent("oneat", { food = food, feeder = feeder })
        if self.oneatfn ~= nil then
            self.oneatfn(self.inst, food, feeder)
        end

        if food.components.edible ~= nil then
            food.components.edible:OnEaten(self.inst)
        end

        if food:IsValid() then --might get removed in OnEaten...
            if not self.eatwholestack and food.components.stackable ~= nil then
                food.components.stackable:Get():Remove()
            else
                food:Remove()
            end
        end

        self.lasteattime = GetTime()

        if self.inst.components.foodmemory ~= nil and not food:HasTag("potion") then
            self.inst.components.foodmemory:RememberFood(food.prefab)
        end

        return true
    end
end

function Eater:TestFood(food, testvalues)
    if food ~= nil and food.components.edible ~= nil then
        for i, v in ipairs(testvalues) do
            if type(v) == "table" then
                for i2, v2 in ipairs(v.types) do
                    if food:HasTag("edible_"..v2) then
                        return true
                    end
                end
            elseif food:HasTag("edible_"..v) then
                return true
            end
        end
    end
end

function Eater:PrefersToEat(food)
    if food.prefab == "winter_food4" and self.inst:HasTag("player") then
        --V2C: fruitcake hack. see how long this code stays untouched - _-"
        return false
    elseif self.nospoiledfood and (food.components.perishable and food.components.perishable:IsSpoiled()) then
        return false
    elseif self.preferseatingtags ~= nil then
        --V2C: now it has the warly hack for only eating prepared foods ;-D
        local preferred = false
        for i, v in ipairs(self.preferseatingtags) do
            if food:HasTag(v) then
                preferred = true
                break
            end
        end
        if not preferred then
            return false
        end
    end
    return self:TestFood(food, self.preferseating)
end

function Eater:CanEat(food)
    return self:TestFood(food, self.caneat)
end

return Eater
