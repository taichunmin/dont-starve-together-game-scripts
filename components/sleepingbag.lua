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
end,
nil,
{
    healthsleep = onhealthsleep,
    sleeper = onsleeper,
})

function SleepingBag:DoSleep(doer)
    if self.sleeper == nil and doer.sleepingbag == nil then
        self.sleeper = doer
        doer.sleepingbag = self.inst
        if self.onsleep ~= nil then
            self.onsleep(self.inst, doer)
        end
    end
end

function SleepingBag:DoWakeUp(nostatechange)
    local sleeper = self.sleeper
    if sleeper ~= nil and sleeper.sleepingbag == self.inst then
        sleeper.sleepingbag = nil
        self.sleeper = nil
        if self.onwake ~= nil then
            self.onwake(self.inst, sleeper, nostatechange)
        end
    end
end

SleepingBag.OnRemoveFromEntity = SleepingBag.DoWakeUp
SleepingBag.OnRemoveEntity = SleepingBag.OnRemoveFromEntity

return SleepingBag