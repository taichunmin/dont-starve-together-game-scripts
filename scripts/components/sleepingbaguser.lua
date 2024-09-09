local SleepingBagUser = Class(function(self, inst)
    self.inst = inst
    self.healthsleep = true
    self.dryingrate = nil
    self.sleeper = nil
    self.onsleep = nil
    self.onwake = nil

    self.hunger_bonus_mult = 1
    self.health_bonus_mult = 1
    self.sanity_bonus_mult = 1

    -- self.cansleepfn
end)

function SleepingBagUser:SetHungerBonusMult(bonus)
    self.hunger_bonus_mult = bonus
end

function SleepingBagUser:SetHealthBonusMult(bonus)
    self.health_bonus_mult = bonus
end

function SleepingBagUser:SetSanityBonusMult(bonus)
    self.sanity_bonus_mult = bonus
end

function SleepingBagUser:SetCanSleepFn(cansleepfn)
    self.cansleepfn = cansleepfn
end

local function WakeUpTest(inst, phase)
    local bed = inst.components.sleepingbaguser.bed

    if bed ~= nil and phase ~= bed.components.sleepingbag:GetSleepPhase() then
        bed.components.sleepingbag:DoWakeUp()
    end
end

function SleepingBagUser:DoSleep(bed)
    self.bed = bed

    -- check if we're in an invalid period (i.e. daytime). if so: wakeup
    self.inst:WatchWorldState("phase", WakeUpTest)

    if self.sleeptask ~= nil then
        self.sleeptask:Cancel()
    end

    self.sleeptask = self.inst:DoPeriodicTask(self.bed.components.sleepingbag.tick_period, function() self:SleepTick() end)
end

function SleepingBagUser:DoWakeUp(nostatechange)
    if self.sleeptask ~= nil then
        self.sleeptask:Cancel()
        self.sleeptask = nil
    end

    self.inst:StopWatchingWorldState("phase", WakeUpTest)

    if not nostatechange then
        if self.inst.sg:HasStateTag("bedroll") then
            self.inst.sg.statemem.iswaking = true
        end
        local goodsleeperequipped = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD):HasTag("good_sleep_aid")
        self.inst.sg:GoToState("wakeup",{goodsleep=goodsleeperequipped})
    end
end

function SleepingBagUser:ShouldSleep()
    if self.cansleepfn ~= nil then
        local success, reason = self.cansleepfn(self.inst)
        return success, reason
    else
        return true
    end
end

function SleepingBagUser:SleepTick()

    local goodsleeperequipped = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) and self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD):HasTag("good_sleep_aid")

    local hunger_tick = self.bed.components.sleepingbag.hunger_tick * self.hunger_bonus_mult
    local health_tick = self.bed.components.sleepingbag.health_tick * self.health_bonus_mult
    local sanity_tick = self.bed.components.sleepingbag.sanity_tick * self.sanity_bonus_mult * (goodsleeperequipped and TUNING.GOODSLEEP_SANITY or 1)

    local isstarving = false
    if self.inst.components.hunger ~= nil then
        self.inst.components.hunger:DoDelta(hunger_tick, true, true)
        isstarving = self.inst.components.hunger:IsStarving()
    end

    if self.inst.components.sanity ~= nil and self.inst.components.sanity:GetPercentWithPenalty() < 1 then
        self.inst.components.sanity:DoDelta(sanity_tick, true)
    end

    if not isstarving and self.bed.components.sleepingbag.healthsleep and self.inst.components.health ~= nil then
        self.inst.components.health:DoDelta(health_tick, true, self.bed.prefab, true)
    end

    if self.bed.components.sleepingbag.temperaturetickfn ~= nil then
        self.bed.components.sleepingbag.temperaturetickfn(self.bed, self.inst)
    end

    if isstarving then
        self.bed.components.sleepingbag:DoWakeUp()
    end
end

return SleepingBagUser