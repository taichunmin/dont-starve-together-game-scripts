local function onattacked(inst, data)
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:WakeUp()
    end
end

local function onnewcombattarget(inst, data)
    if data.target ~= nil and inst.components.sleeper ~= nil then
        inst.components.sleeper:StartTesting()
    end
end

local Sleeper = Class(function(self, inst)
    self.inst = inst
    inst:AddTag("sleeper")
    self.isasleep = false
    self.testperiod = 4
    self.lasttransitiontime = GetTime()
    self.lasttesttime = GetTime()
    self.sleeptestfn = DefaultSleepTest
    self.waketestfn = DefaultWakeTest
    self:StartTesting()
    self.resistance = 1
    self.sleepiness = 0
    self.wearofftime = 10
    self.hibernate = false
    self.watchlight = false

    --these are for diminishing returns (mainly bosses), so nil for default
    --self.diminishingreturns = false
    --self.extraresist = 0
    --self.diminishingtask = nil

    self.inst:ListenForEvent("onignite", onattacked)
    self.inst:ListenForEvent("firedamage", onattacked)
    self.inst:ListenForEvent("attacked", onattacked)
    self.inst:ListenForEvent("newcombattarget", onnewcombattarget)
end)

function Sleeper:OnRemoveFromEntity()
    self.inst:RemoveTag("sleeper")
    if self.testtask ~= nil then
        self.testtask:Cancel()
    end
    if self.wearofftask ~= nil then
        self.wearofftask:Cancel()
    end
    if self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
    end
    self.inst:RemoveEventCallback("onignite", onattacked)
    self.inst:RemoveEventCallback("firedamage", onattacked)
    self.inst:RemoveEventCallback("attacked", onattacked)
    self.inst:RemoveEventCallback("newcombattarget", onnewcombattarget)
end

function Sleeper:SetDefaultTests()
    self.sleeptestfn = DefaultSleepTest
    self.waketestfn = DefaultWakeTest
end

function Sleeper:StopTesting()
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
    end
end

--cavedwellers perceive "cavephase" instead of "phase"
--  i.e. cavephase is aware of the clock phase even when the
--       sky can't be seen when underground, whereas regular
--       phase is perceived as always night when underground

function StandardSleepChecks(inst)
    return not (inst.components.homeseeker ~= nil and
            inst.components.homeseeker.home ~= nil and
                inst.components.homeseeker.home:IsValid() and
                inst:IsNear(inst.components.homeseeker.home, 40))
        and not (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        and not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        and not (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        and not (inst.components.teamattacker ~= nil and inst.components.teamattacker.inteam)
        and not inst.sg:HasStateTag("busy")
end

function StandardWakeChecks(inst)
    return (inst.components.combat ~= nil and inst.components.combat.target ~= nil)
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
        or (inst.components.freezable ~= nil and inst.components.freezable:IsFrozen())
        or (inst.components.teamattacker ~= nil and inst.components.teamattacker.inteam)
        or (inst.components.health ~= nil and inst.components.health.takingfiredamage)
end

function DefaultSleepTest(inst)
    local watchlight = inst.LightWatcher ~= nil or (inst.components.sleeper and inst.components.sleeper.watchlight)
    return StandardSleepChecks(inst)
            -- sleep in the overworld at night
        and (not TheWorld:HasTag("cave") and TheWorld.state.isnight
            -- in caves, sleep at night if we have a lightwatcher and are in the dark
            or (TheWorld:HasTag("cave") and TheWorld.state.iscavenight and (not watchlight or not inst:IsInLight())))
end

function DefaultWakeTest(inst)
    local watchlight = inst.LightWatcher ~= nil or (inst.components.sleeper and inst.components.sleeper.watchlight)

    return StandardWakeChecks(inst)
        -- wake when it's not night
        or (not TheWorld:HasTag("cave") and not TheWorld.state.isnight)
        -- in caves, wake if it's not night and we've got a light shining on us
        or (TheWorld:HasTag("cave") and not TheWorld.state.iscavenight and (not watchlight or inst:IsInLight()))
end

function NocturnalSleepTest(inst)
    --not near home
    --nocturnal sleeps in day
    return StandardSleepChecks(inst)
        and TheWorld.state[(inst:HasTag("cavedweller") and "iscaveday" or "isday")]
end

function NocturnalWakeTest(inst)
    --nocturnal wakes once it's not day
    --cavedwellers perceive "cavephase" instead of "phase"
    return StandardWakeChecks(inst)
        or not TheWorld.state[inst:HasTag("cavedweller") and "iscaveday" or "isday"]
end

function Sleeper:SetNocturnal(b)
    if b then
        self.sleeptestfn = NocturnalSleepTest
        self.waketestfn = NocturnalWakeTest
    else
        self.sleeptestfn = DefaultSleepTest
        self.waketestfn = DefaultWakeTest
    end
end

local function ShouldSleep(inst)
    local sleeper = inst.components.sleeper
    if sleeper == nil then
        return
    end
    sleeper.lasttesttime = GetTime()
    if sleeper.sleeptestfn ~= nil and sleeper.sleeptestfn(inst) then
        sleeper:GoToSleep()
    end
end

local function ShouldWakeUp(inst)
    local sleeper = inst.components.sleeper
    if sleeper == nil then
        return
    elseif sleeper.hibernate then
        sleeper:StopTesting()
    else
        sleeper.lasttesttime = GetTime()
        if sleeper.waketestfn ~= nil and sleeper.waketestfn(inst) then
            sleeper:WakeUp()
        end
    end
end

local function WearOff(inst)
    local sleeper = inst.components.sleeper
    if sleeper == nil then
        return
    elseif sleeper.sleepiness > 1 then
        sleeper.sleepiness = sleeper.sleepiness - 1
    elseif sleeper.sleepiness > 0 then
        sleeper.sleepiness = 0
        if sleeper.wearofftask ~= nil then
            sleeper.wearofftask:Cancel()
            sleeper.wearofftask = nil
        end
    end
end

-----------------------------------------------------------------------------------------------------

function Sleeper:SetWakeTest(fn, time)
    self.waketestfn = fn
    self:StartTesting(time)
end

function Sleeper:SetSleepTest(fn)
    self.sleeptestfn = fn
    self:StartTesting()
end

function Sleeper:OnEntitySleep()
    self:StopTesting()
end

function Sleeper:OnEntityWake()
    self:StartTesting()
end

function Sleeper:SetResistance(resist)
    self.resistance = resist
end

function Sleeper:StartTesting(time)
    if self.isasleep then
        self:SetTest(ShouldWakeUp, time)
    else
        self:SetTest(ShouldSleep)
    end
end

function Sleeper:IsAsleep()
    return self.isasleep
end

function Sleeper:IsHibernating()
    return self.hibernate
end

--- Deep sleep means the sleeper was drugged, and shouldn't wake up to chase targets
function Sleeper:IsInDeepSleep()
    return self:IsAsleep() and self.sleepiness > 0
end

function Sleeper:GetTimeAwake()
    return self.isasleep and 0 or GetTime() - self.lasttransitiontime
end

function Sleeper:GetTimeAsleep()
    return self.isasleep and GetTime() - self.lasttransitiontime or 0
end

function Sleeper:GetDebugString()
    return string.format("%s for %2.2f / %2.2f Sleepy: %d/%d -- Multiplier: %2.2f (Decay: %2.2f)",
            self.isasleep and "SLEEPING" or "AWAKE",
            self.isasleep and self:GetTimeAsleep() or self:GetTimeAwake(),
            self.lasttesttime + self.testtime - GetTime(),
            self.sleepiness,
            self.resistance,
            self:GetSleepTimeMultiplier(),
            self.diminishingtask ~= nil and GetTaskRemaining(self.diminishingtask) or 0)
end

--V2C: not passing self because we also don't cancel this task on removal
local function OnGoToSleep(inst, sleeptime)
    if inst.components.sleeper ~= nil then
        inst.components.sleeper:GoToSleep(sleeptime)
    end
end

function Sleeper:AddSleepiness(sleepiness, sleeptime)
    self.sleepiness = self.sleepiness + sleepiness
    if self.isasleep or self.sleepiness > self.resistance then
        self:GoToSleep(sleeptime)
    elseif self.sleepiness == self.resistance then
        self.inst:DoTaskInTime(self.resistance, OnGoToSleep, sleeptime)
    elseif self.wearofftask == nil then
        self.wearofftask = self.inst:DoPeriodicTask(self.wearofftime, WearOff)
    end
end

local function DecayExtraResist(inst, self)
    self:SetExtraResist(self.extraresist - .1)
end

function Sleeper:SetExtraResist(resist)
    self.extraresist = math.clamp(resist, 0, self.wearofftime)
    if self.extraresist > 0 then
        if self.diminishingtask == nil then
            self.diminishingtask = self.inst:DoPeriodicTask(30, DecayExtraResist, nil, self)
        end
    elseif self.diminishingtask ~= nil then
        self.diminishingtask:Cancel()
        self.diminishingtask = nil
    end
end

function Sleeper:GetSleepTimeMultiplier()
    return self.extraresist ~= nil and math.max(.2, 1 - self.extraresist * .1) or 1
end

function Sleeper:GoToSleep(sleeptime)
    if self.inst.entity:IsVisible() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        local wasasleep = self.isasleep
        self.lasttransitiontime = GetTime()
        self.isasleep = true
        if self.wearofftask ~= nil then
            self.wearofftask:Cancel()
            self.wearofftask = nil
        end

        if self.inst.brain ~= nil then
            self.inst.brain:Stop()
        end

        if self.inst.components.combat ~= nil then
            self.inst.components.combat:SetTarget(nil)
        end

        if self.inst.components.locomotor ~= nil and not (self.inst.sg ~= nil and self.inst.sg:HasStateTag("nosleep")) then
            self.inst.components.locomotor:Stop()
        end

        if not wasasleep then
            self.inst:PushEvent("gotosleep")
            if self.diminishingreturns then
                self:SetExtraResist((self.extraresist or 0) + 1)
            end
        end

        self:SetWakeTest(self.waketestfn, sleeptime ~= nil and sleeptime * self:GetSleepTimeMultiplier() or sleeptime)
    end
end

function Sleeper:SetTest(fn, time)
    if self.testtask ~= nil then
        self.testtask:Cancel()
        self.testtask = nil
    end

    if fn ~= nil then
        --some randomness on testing times
        self.testtime = math.max(0, self.testperiod + math.random() - .5)
        self.testtask = self.inst:DoPeriodicTask(self.testtime, fn, time)
    end
end

function Sleeper:WakeUp()
    self.hibernate = false
    if self.isasleep and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self.lasttransitiontime = GetTime()
        self.isasleep = false
        self.sleepiness = 0

        if self.inst.brain ~= nil then
            self.inst.brain:Start()
        end

        self.inst:PushEvent("onwakeup")
        self:SetSleepTest(self.sleeptestfn)
    end
end

function Sleeper:OnSave()
    return self.extraresist ~= nil
        and self.extraresist > 0
        and { extraresist = math.floor(self.extraresist * 10) * .1 }
        or nil
end

function Sleeper:OnLoad(data)
    if data.extraresist ~= nil then
        self:SetExtraResist(data.extraresist)
    end
end

return Sleeper
