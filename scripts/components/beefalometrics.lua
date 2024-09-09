
local Stats = require("stats")

local function PushEvent(id, beefalo, player, values)
    values = values or {}
    values.beefalo_id = beefalo.components.uniqueid.id
    Stats.PushMetricsEvent(id, player, values)
end

local function OnDomesticationDelta(inst, data)
    local self = inst.components.beefalometrics
    if data.old == 0 and data.new > 0 then
        PushEvent("beefalo.domestication.start", inst, self:GetLastDomesticator())
    end
end

local function OnEat(inst, data)
    local self = inst.components.beefalometrics
    if data.feeder ~= nil then
        -- note: this relies on the "oneat" event being called before the oneatfn callback, and beefalo using the callback
        self:SetLastDomesticator(data.feeder)
    end

    PushEvent("beefalo.domestication.feed", inst, data.feeder, {
        domesticated = inst.components.domesticatable:IsDomesticated(),
        domestication_level = inst.components.domesticatable:GetDomestication(),
        tendency = inst.tendency,
        food_hunger_value = data.food.components.edible.hungervalue,
    })
end

local function OnBrushed(inst, data)
    local self = inst.components.beefalometrics
    if data.doer ~= nil then
        -- note: this relies on the "onbrushed" event being called before the onbrushfn callback, and beefalo using the callback
        self:SetLastDomesticator(data.doer)
    end

    PushEvent("beefalo.domestication.brushed", inst, data.feeder, {
        domesticated = inst.components.domesticatable:IsDomesticated() == true,
        domestication_level = inst.components.domesticatable:GetDomestication(),
        tendency = inst.tendency,
        num_loot = data.numprizes,
    })
end

local function OnDomesticated(inst, data)
    local self = inst.components.beefalometrics
    PushEvent("beefalo.domestication.domesticated", inst, self:GetLastDomesticator(), {
        tendency = inst.tendency,
        tendency_rider = data.tendencies[TENDENCY.RIDER],
        tendency_pudgy = data.tendencies[TENDENCY.PUDGY],
        tendency_ornery = data.tendencies[TENDENCY.ORNERY],
    })
end

local function OnFeral(inst)
    local self = inst.components.beefalometrics
    PushEvent("beefalo.domestication.feral", inst, self:GetLastDomesticator(), {
        domesticated = inst.components.domesticatable:IsDomesticated(),
        tendency = inst.tendency,
    })
end

local function OnDeath(inst, data)
    if inst.components.domesticatable:GetDomestication() <= 0 then
        -- Only care about the deaths of domestic beefalo
        return
    end

    local self = inst.components.beefalometrics
    local rider = inst.components.rideable:GetRider()
    PushEvent("beefalo.domestication.death", inst, rider, {
        domesticated = inst.components.domesticatable:IsDomesticated(),
        domestication_level = inst.components.domesticatable:GetDomestication(),
        tendency = inst.tendency,
        cause = data.cause,
        afflicter = data.afflicter ~= nil and data.afflicter.userid ~= nil and data.afflicter.userid:len() > 0 and data.afflicter.userid or nil
    })
end

local function OnRiderChanged(inst, data)
    local self = inst.components.beefalometrics

    if data.newrider ~= nil then
        self.ridestarttime = GetTime()
    elseif data.newrider == nil then
        PushEvent("beefalo.domestication.ride", inst, data.oldrider, {
            domesticated = inst.components.domesticatable:IsDomesticated(),
            domestication_level = inst.components.domesticatable:GetDomestication(),
            tendency = inst.tendency,
            ride_length = GetTime() - self.ridestarttime
        })
    end
end

local function OnAttacked(inst, data)
    local self = inst.components.beefalometrics

    if inst.components.rideable:IsBeingRidden() then
        PushEvent("beefalo.domestication.mountedattacked", inst, inst.components.rideable:GetRider(), {
            domesticated = inst.components.domesticatable:IsDomesticated(),
            domestication_level = inst.components.domesticatable:GetDomestication(),
            tendency = inst.tendency,
            attacker = data.attacker and data.attacker.prefab,
        })
    end
end

local function OnRiderDoAttack(inst, data)
    local self = inst.components.beefalometrics

    if inst.components.rideable:IsBeingRidden() then
        PushEvent("beefalo.domestication.mountedattack", inst, inst.components.rideable:GetRider(), {
            domesticated = inst.components.domesticatable:IsDomesticated(),
            domestication_level = inst.components.domesticatable:GetDomestication(),
            tendency = inst.tendency,
            target = data.target and data.target.prefab,
        })
    end
end

local BeefaloMetrics = Class(function(self, inst)
    self.inst = inst

    self.lastdomesticator = nil

    self.inst:ListenForEvent("domesticationdelta", OnDomesticationDelta)
    self.inst:ListenForEvent("oneat", OnEat)
    self.inst:ListenForEvent("brushed", OnBrushed)
    self.inst:ListenForEvent("domesticated", OnDomesticated)
    self.inst:ListenForEvent("goneferal", OnFeral)
    self.inst:ListenForEvent("death", OnDeath)
    self.inst:ListenForEvent("riderchanged", OnRiderChanged)
    self.inst:ListenForEvent("attacked", OnAttacked)
    self.inst:ListenForEvent("riderdoattackother", OnRiderDoAttack)
end)

function BeefaloMetrics:SetLastDomesticator(player)
    self.lastdomesticator_id = nil
    self.lastdomesticator = player
end

function BeefaloMetrics:GetLastDomesticator()
    if self.lastdomesticator ~= nil then
        return self.lastdomesticator
    elseif self.lastdomesticator_id ~= nil then
        local player = UserToPlayer(self.lastdomesticator_id)
        if player ~= nil then
            self:SetLastDomesticator(player)
            return player
        else
            return self.lastdomesticator_id
        end
    end

    return nil -- This will invalidate the metric, but I think that's the most correct behaviour for now.
end

function BeefaloMetrics:OnSave()
    if self.lastdomesticator ~= nil then
        return {lastdomesticator_id = self.lastdomesticator.userid}
    elseif self.lastdomesticator_id ~= nil then
        return {lastdomesticator_id = self.lastdomesticator_id}
    end
    return nil
end

function BeefaloMetrics:OnLoad(data)
    if data.lastdomesticator_id ~= nil then
        self.lastdomesticator_id = data.lastdomesticator_id
    end
end

return BeefaloMetrics
