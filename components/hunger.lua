
local SourceModifierList = require("util/sourcemodifierlist")

local function onmax(self, max)
    self.inst.replica.hunger:SetMax(max)
end

local function oncurrent(self, current)
    self.inst.replica.hunger:SetCurrent(current)
end

local function OnTaskTick(inst, self, period)
    self:DoDec(period)
end

local Hunger = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = self.max

    self.hungerrate = 1
    self.hurtrate = 1
    self.overridestarvefn = nil

    self.burning = true
    --100% burn rate. Currently used only by belt of hunger, will have to change unequip if use in something else
    self.burnrate = 1 -- DEPRECATED, please use burnratemodifiers instead
    self.burnratemodifiers = SourceModifierList(self.inst)

    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, period)
end,
nil,
{
    max = onmax,
    current = oncurrent,
})

function Hunger:OnSave()
    return self.current ~= self.max and { hunger = self.current } or nil
end

function Hunger:OnLoad(data)
    if data.hunger ~= nil and self.current ~= data.hunger then
        self.current = data.hunger
        self:DoDelta(0)
    end
end

function Hunger:SetOverrideStarveFn(fn)
    self.overridestarvefn = fn
end

function Hunger:LongUpdate(dt)
    self:DoDec(dt, true)
end

function Hunger:Pause()
    self.burning = false
end

function Hunger:Resume()
    self.burning = true
end

function Hunger:IsPaused()
    return self.burning
end

function Hunger:GetDebugString()
    return string.format("%2.2f / %2.2f, rate: (%2.2f * %2.2f)", self.current, self.max, self.hungerrate, self.burnrate*self.burnratemodifiers:Get())
end

function Hunger:SetMax(amount)
    self.max = amount
    self.current = amount
end

function Hunger:IsStarving()
    return self.current <= 0
end

function Hunger:DoDelta(delta, overtime, ignore_invincible)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    if not ignore_invincible and self.inst.components.health and self.inst.components.health:IsInvincible() or self.inst.is_teleporting then
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)

    self.inst:PushEvent("hungerdelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime, delta = self.current-old })

    if old > 0 then
        if self.current <= 0 then
            self.inst:PushEvent("startstarving")
            ProfileStatsSet("started_starving", true)
        end
    elseif self.current > 0 then
        self.inst:PushEvent("stopstarving")
        ProfileStatsSet("stopped_starving", true)
    end
end

function Hunger:GetPercent()
    return self.current / self.max
end

function Hunger:SetPercent(p, overtime)
    local old = self.current
    self.current  = p * self.max
    self.inst:PushEvent("hungerdelta", { oldpercent = old / self.max, newpercent = p, overtime = overtime })

    if old > 0 then
        if self.current <= 0 then
            self.inst:PushEvent("startstarving")
            ProfileStatsSet("started_starving", true)
        end
    elseif self.current > 0 then
        self.inst:PushEvent("stopstarving")
        ProfileStatsSet("stopped_starving", true)
    end
end

function Hunger:DoDec(dt, ignore_damage)
    local old = self.current

    if self.burning then
        if self.current > 0 then
            self:DoDelta(-self.hungerrate * dt * self.burnrate * self.burnratemodifiers:Get(), true)
        elseif not ignore_damage then
            if self.overridestarvefn ~= nil then
                self.overridestarvefn(self.inst, dt)
            else
                self.inst.components.health:DoDelta(-self.hurtrate * dt, true, "hunger") --  ich haber hunger
            end
        end
    end
end

function Hunger:SetKillRate(rate)
    self.hurtrate = rate
end

function Hunger:SetRate(rate)
    self.hungerrate = rate
end

return Hunger
