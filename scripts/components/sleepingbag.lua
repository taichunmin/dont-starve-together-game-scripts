local function onhealthsleep(self, healthsleep)
    if self.sleeper ~= nil and self.sleeper.player_classified ~= nil then
        self.sleeper.player_classified.issleephealing:set(healthsleep)
    end
end

local function onsleeper(self, sleeper, old_sleeper)
    if old_sleeper ~= nil and old_sleeper.player_classified ~= nil then
        old_sleeper.player_classified.issleephealing:set(false)
    end
    if sleeper == nil then
        self.inst:RemoveTag("hassleeper")
    else
        self.inst:AddTag("hassleeper")
        if sleeper.player_classified ~= nil then
            sleeper.player_classified.issleephealing:set(self.healthsleep)
        end
    end
end

local SleepingBag = Class(function(self, inst)
    self.inst = inst
    self.healthsleep = true
    self.dryingrate = nil
    self.sleeper = nil
    self.onsleep = nil
    self.onwake = nil

    self.tick_period = TUNING.SLEEP_TICK_PERIOD

    self.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    self.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
    self.sanity_tick = TUNING.SLEEP_SANITY_PER_TICK

    self.sleep_temp_min = nil
    self.sleep_temp_max = nil

	self.ambient_temp = nil
    self.temperaturetickfn = nil

    self.sleep_phase = "night"
end,
nil,
{
    healthsleep = onhealthsleep,
    sleeper = onsleeper,
})

function SleepingBag:SetSleepPhase(phase)
    self.sleep_phase = phase
end

function SleepingBag:GetSleepPhase()
    return self.sleep_phase
end

function SleepingBag:SetTemperatureTickFn(fn)
    self.temperaturetickfn = fn
end

function SleepingBag:DoSleep(doer)
    if self.sleeper == nil and doer.sleepingbag == nil then

        self.sleeper = doer
        self.sleeper.sleepingbag = self.inst
        self.sleeper.components.sleepingbaguser:DoSleep(self.inst)

        if self.onsleep ~= nil then
            self.onsleep(self.inst, doer)
        end
    end
end

function SleepingBag:DoWakeUp(nostatechange)
    local sleeper = self.sleeper
    if sleeper ~= nil and sleeper.sleepingbag == self.inst then

        sleeper.sleepingbag = nil
        sleeper.components.sleepingbaguser:DoWakeUp(nostatechange)
        self.sleeper = nil

        if self.onwake ~= nil then
            self.onwake(self.inst, sleeper, nostatechange)
        end
    end
end

function SleepingBag:InUse()
    return self.sleeper ~= nil
end

SleepingBag.OnRemoveFromEntity = SleepingBag.DoWakeUp
SleepingBag.OnRemoveEntity = SleepingBag.OnRemoveFromEntity

return SleepingBag