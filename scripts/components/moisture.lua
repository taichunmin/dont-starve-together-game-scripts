local easing = require("easing")
local SourceModifierList = require("util/sourcemodifierlist")

local function onmaxmoisture(self, maxmoisture)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified:SetValue("maxmoisture", maxmoisture)
    end
end

local function onmoisture(self, moisture)
    if self.inst.player_classified ~= nil then
       self.inst.player_classified:SetValue("moisture", moisture)
    end
end

local function onratescale(self, ratescale)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.moistureratescale:set(ratescale)
    end
end

local function onwet(self, wet)
    self.inst.replica.moisture:SetIsWet(wet)
end

local Moisture = Class(function(self, inst)
    self.inst = inst

    self.maxmoisture = 100
    self.moisture = 0
    self.numSegs = 5
    self.baseDryingRate = 0

    self.maxDryingRate = 0.1
    self.minDryingRate = 0

    self.maxPlayerTempDrying = 5
    self.optimalPlayerTempDrying = 2
    self.minPlayerTempDrying = 0

    self.maxMoistureRate = .75
    self.minMoistureRate = 0

    self.inherentWaterproofness = 0 -- DEPRECATED, USE THE SourceModifierList BELOW
    self.waterproofnessmodifiers = SourceModifierList(inst, 0, SourceModifierList.additive)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)

    --self.waterproofinventory = false --DEPRECATED, USE forcedrysources BELOW
	--self.forcedrysources = nil
	self._onremoveforcedrysource = function(src)
		self.forcedrysources[src] = nil
		if next(self.forcedrysources) == nil then
			self.forcedrysources = nil
			inst:StartUpdatingComponent(self)
		end
	end

    self.optimalDryingTemp = 50

    self.rate = 0 --rate at which moisture is trying to change
    self.ratescale = RATE_SCALE.NEUTRAL --based on actual delta, limited by min/max bounds
    self.wet = false

    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    maxmoisture = onmaxmoisture,
    moisture = onmoisture,
    ratescale = onratescale,
    wet = onwet,
})

function Moisture:ForceDry(force, source)
	source = source or self.inst
    if force then
		if self.forcedrysources == nil then
            self.rate = 0
            self.ratescale = RATE_SCALE.NEUTRAL
            self:SetMoistureLevel(0)
            self.inst:StopUpdatingComponent(self)
			self.forcedrysources = { [source] = true }
		elseif not self.forcedrysources[source] then
			self.forcedrysources[source] = true
		else
			return
        end
		if source ~= self.inst then
			self.inst:ListenForEvent("onremove", self._onremoveforcedrysource, source)
		end
	elseif self.forcedrysources ~= nil and self.forcedrysources[source] then
		if source ~= self.inst then
			self.inst:RemoveEventCallback("onremove", self._onremoveforcedrysource, source)
		end
		self._onremoveforcedrysource(source)
    end
end

function Moisture:GetDebugString()
    local str = string.format("moisture: %2.2f", self:GetMoisture())
    local sleepingbagdryingrate = self:GetSleepingBagDryingRate()
    if sleepingbagdryingrate ~= nil then
        str = str..string.format(" rate: %2.2f (sleepingbag)", -sleepingbagdryingrate)
    else
        local moisturerate = self:GetMoistureRate()
        local dryingrate = self:GetDryingRate(moisturerate)
        local equippedmoisturerate = self:GetEquippedMoistureRate(dryingrate)
        local rate = moisturerate + equippedmoisturerate - dryingrate
        str = str..string.format(" rate: %s%2.2f (precip: %s%2.2f equip: %s%2.2f drying: %s%2.2f)",
            rate > 0 and "+" or "", rate,
            moisturerate > 0 and "+" or "", moisturerate,
            equippedmoisturerate > 0 and "+" or "", equippedmoisturerate,
            dryingrate < 0 and "+" or (dryingrate > 0 and "-") or "", math.abs(dryingrate))
    end
	return self:IsForceDry() and (str.." FORCED DRY") or str
end

function Moisture:AnnounceMoisture(oldSegs, newSegs)
    if self.inst.components.talker then
        if oldSegs < 1 and newSegs >= 1 then
            self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_DAMP"))
        elseif oldSegs < 2 and newSegs >= 2 then
            self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_WET"))
        elseif oldSegs < 3 and newSegs >= 3 then
            self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_WETTER"))
        elseif oldSegs < 4 and newSegs >= 4 then
            self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_SOAKED"))
        end
    end
end

function Moisture:DoDelta(num, no_announce)
	if self:IsForceDry() then
        return
    end

    local oldLevel = self.moisture
    local oldSegs = self:GetSegs()
    self.moisture = math.clamp(self.moisture + num, 0, self.maxmoisture)
    local newSegs = self:GetSegs()
    local delta = self.moisture - oldLevel
    self.wet = newSegs >= 2
	if not no_announce then
	    self:AnnounceMoisture(oldSegs, newSegs)
	end
    self.inst:PushEvent("moisturedelta", { old = oldLevel, new = self.moisture })
end

function Moisture:SetMoistureLevel(num)
	if self:IsForceDry() then
        return
    end

    self.moisture = math.clamp(num, 0, self.maxmoisture)
    self.wet = self:GetSegs() >= 2
    self.inst:PushEvent("moisturedelta", { old = self.moisture, new = self.moisture })
end

function Moisture:IsWet()
    return self.wet
end

function Moisture:GetMaxMoisture()
    return self.maxmoisture
end

function Moisture:GetMoisture()
    return self.moisture
end

function Moisture:GetMoisturePercent()
    return self.moisture / self.maxmoisture
end

function Moisture:GetWaterproofInventory()
	return self.waterproofinventory or self:IsForceDry()
end

function Moisture:IsForceDry()
	return self.forcedrysources ~= nil
end

function Moisture:SetWaterproofInventory(waterproof)
	--DEPRECATED use ForceDry instead
    self.waterproofinventory = waterproof
end

function Moisture:SetPercent(per)
    local current = self.moisture
    local max = self.maxmoisture
    local target = self.maxmoisture * per

    local delta = target - current
    self:DoDelta(delta)
end

function Moisture:SetInherentWaterproofness(waterproofness)
    self.inherentWaterproofness = waterproofness
end

function Moisture:GetSegs()
    local num = self.moisture / self.maxmoisture * self.numSegs
    local full = math.max(0, math.ceil(num - 1))

    --(num): real number of drops (aka. segs)
    --(full): whole number of full drops for UI
    --(num - full): alpha value of the currently filling drop
    return full, num - full
end

-- NOTES(JBK): More of an internal function to get a raw number elsewhere.
function Moisture:_GetMoistureRateAssumingRain()
	if self.inst.components.rainimmunity ~= nil then
		return 0
	end

    local waterproofmult =
        (   self.inst.components.sheltered ~= nil and
            self.inst.components.sheltered.sheltered and
            self.inst.components.sheltered.waterproofness or 0
        ) +
        (   self.inst.components.inventory ~= nil and
            self.inst.components.inventory:GetWaterproofness() or 0
        ) +
        (   self.inherentWaterproofness or 0
        ) +
        (
            self.waterproofnessmodifiers:Get() or 0
        )
    if waterproofmult >= 1 then
        return 0
    end

    local rate = easing.inSine(TheWorld.state.precipitationrate, self.minMoistureRate, self.maxMoistureRate, 1)
    return rate * (1 - waterproofmult)
end

-- DiogoW: Used by events that add moisture: waves, row fail, etc.
function Moisture:GetWaterproofness()
    local waterproofness =
        (   self.inst.components.inventory ~= nil and
            self.inst.components.inventory:GetWaterproofness() or 0
        ) +
        (   self.inherentWaterproofness or 0
        ) +
        (
            self.waterproofnessmodifiers:Get() or 0
        )
    
    return math.clamp(waterproofness, 0, 1)
end

function Moisture:GetMoistureRate()
    if not TheWorld.state.israining then
        return 0
    end

    return self:_GetMoistureRateAssumingRain()
end

function Moisture:GetEquippedMoistureRate(dryingrate)
    if self.inst.components.inventory == nil then
        return 0
    end

    local rate, max = self.inst.components.inventory:GetEquippedMoistureRate()

    -- If rate and max are nonzero (i.e. wearing a moisturizing equipment) and the drying rate is less than
    -- the moisture rate of the equipment AND we're at max moisture for the equipment, set the two rates equal.
    -- This will prevent the arrow flickering as well as hold the moisture steady at max level
    if rate ~= 0 and max ~= 0 and self.moisture >= max then
        rate = math.min(dryingrate or self:GetDryingRate(), rate)
    end

    return math.abs(rate) > .01 and rate or 0
end

function Moisture:GetDryingRate(moisturerate)
    -- Don't dry if it's raining
    if (moisturerate or self:GetMoistureRate()) > 0 then
        return 0
    end

    local heaterPower = self.inst.components.temperature ~= nil and math.clamp(self.inst.components.temperature.externalheaterpower, 0, 1) or 0
    local playerTempDrying = self:GetSegs() < 3 and self.optimalPlayerTempDrying or self.maxPlayerTempDrying

    local rate = self.baseDryingRate
        + easing.linear(heaterPower, self.minPlayerTempDrying, playerTempDrying, 1)
        + easing.linear(GetLocalTemperature(self.inst), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp)
        + easing.inExpo(self:GetMoisture(), 0, 1, self.maxmoisture)

    return math.clamp(rate, 0, self.maxDryingRate + self.maxPlayerTempDrying)
end

function Moisture:GetSleepingBagDryingRate()
    local rate = self.inst.sleepingbag ~= nil and self.inst.sleepingbag.components.sleepingbag ~= nil and self.inst.sleepingbag.components.sleepingbag.dryingrate or nil
    return rate ~= nil and math.max(0, rate) or nil
end

function Moisture:GetRate()
    return self.rate
end

function Moisture:GetRateScale()
    return self.ratescale
end

function Moisture:AddRateBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function Moisture:RemoveRateBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function Moisture:GetRateBonus()
    return self.externalbonuses:Get()
end

function Moisture:OnUpdate(dt)
	if self:IsForceDry() then
        --can still get here even if we're not in the update list
        --i.e. LongUpdate or OnUpdate called explicitly
        return
    end

    local sleepingbagdryingrate = self:GetSleepingBagDryingRate()
    if sleepingbagdryingrate ~= nil then
        self.rate = -sleepingbagdryingrate
    else
        local moisturerate = self:GetMoistureRate()
        local dryingrate = self:GetDryingRate(moisturerate)
        local equippedmoisturerate = self:GetEquippedMoistureRate(dryingrate)
        local externalbonuses = self:GetRateBonus()

        self.rate = moisturerate + equippedmoisturerate - dryingrate + externalbonuses
    end

    self.ratescale =
        (self.rate > .3 and RATE_SCALE.INCREASE_HIGH) or
        (self.rate > .15 and RATE_SCALE.INCREASE_MED) or
        (self.rate > .001 and RATE_SCALE.INCREASE_LOW) or
        (self.rate < -3 and RATE_SCALE.DECREASE_HIGH) or
        (self.rate < -1.5 and RATE_SCALE.DECREASE_MED) or
        (self.rate < -.001 and RATE_SCALE.DECREASE_LOW) or
        RATE_SCALE.NEUTRAL

    self:DoDelta(self.rate * dt)
end

function Moisture:LongUpdate(dt)
    self:OnUpdate(dt)
end

function Moisture:OnSave()
    return
    {
        moisture = self.moisture,
    }
end

function Moisture:OnLoad(data)
    if data ~= nil and data.moisture ~= nil then
        self.moisture = data.moisture
    end
end

function Moisture:TransferComponent(newinst)
    local newcomponent = newinst.components.moisture

    newcomponent:SetPercent(self:GetMoisturePercent())
end

return Moisture
