local function onwithered(self, withered)
    if withered then
        self.inst:AddTag("withered")
    else
        self.inst:RemoveTag("withered")
    end
end

local function OnInit(inst, self)
    self:Start()
end

local Witherable = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("witherable")

    self.enabled = true
    self.withered = false
    self.wither_temp = math.random(TUNING.MIN_PLANT_WITHER_TEMP, TUNING.MAX_PLANT_WITHER_TEMP)
    self.rejuvenate_temp = math.random(TUNING.MIN_PLANT_REJUVENATE_TEMP, TUNING.MAX_PLANT_REJUVENATE_TEMP)
    self.delay_to_time = nil
    self.task_to_time = nil
    self.task = nil
    self.restore_cycles = nil
    self.is_watching_rain = nil
    self.protect_to_time = nil
    self.protect_task = nil

    inst:DoTaskInTime(0, OnInit, self)
end,
nil,
{
    withered = onwithered,
})

function Witherable:OnRemoveFromEntity()
    if self.protect_task ~= nil then
        self.protect_task:Cancel()
        self.protect_task = nil
    end
    self:Stop()
    self.inst:RemoveTag("witherable")
    self.inst:RemoveTag("withered")
end

--------------------------------------------------------------------------
-- Withering

local function DoCropWither(inst)
    if inst.components.crop == nil then
        return false
    end
    inst.components.crop:MakeWithered()
    return true
end

local function DoPickableWither(inst, self)
    local pickable = inst.components.pickable
    if pickable == nil then
        return false
    end
    self.restore_cycles = pickable.cycles_left
    if not pickable:IsBarren() then
        pickable:MakeBarren()
    end
    return true
end

local function WitherHandler(inst, self, force)
    self.task = nil
    self.task_to_time = nil

    if not (force or (TheWorld.state.temperature > self.wither_temp and not TheWorld.state.israining)) then
        --Reschedule
        self:Start()
    else
        self.withered = true
        if DoCropWither(inst) or DoPickableWither(inst, self) then
            self:DelayRejuvenate(TUNING.TOTAL_DAY_TIME)
        else
            print("Failed to wither "..tostring(inst))
        end
    end
end

local function ScheduleWitherTask(inst, self)
    local t = GetTime()
    local delay = self.task_to_time ~= nil and math.max(0, self.task_to_time - t) or math.random(30, 60)
    self.task_to_time = t + delay
    self.task = self.inst:DoTaskInTime(delay, WitherHandler, self)
end

--------------------------------------------------------------------------
-- Rejuvenating

local function DoPickableRejuvenate(inst, self)
    local pickable = inst.components.pickable
    if pickable == nil then
        return false
    end
    if self.restore_cycles ~= nil then
        pickable.cycles_left = math.max(pickable.cycles_left or 0, self.restore_cycles)
        self.restore_cycles = nil
    else
        pickable.cycles_left = nil
    end
    if not pickable:IsBarren() then
        pickable:MakeEmpty()
    end
    return true
end

local function RejuvenateHandler(inst, self, force)
    self.task = nil
    self.task_to_time = nil

    if not (force or TheWorld.state.temperature < self.rejuvenate_temp or TheWorld.state.israining) then
        --Reschedule
        self:Start()
    elseif DoPickableRejuvenate(inst, self) then
        self.withered = false
        self:DelayWither(15)
    else
        self.withered = false
        print("Failed to rejuvenate "..tostring(inst))
    end
end

local function ScheduleRejuvenateTask(inst, self)
    local t = GetTime()
    local delay = self.task_to_time ~= nil and math.max(0, self.task_to_time - t) or math.random(30, 60)
    self.task_to_time = t + delay
    self.task = self.inst:DoTaskInTime(delay, RejuvenateHandler, self)
end

--------------------------------------------------------------------------
-- Delay

local function OnStartRain(self)
    self.delay_to_time = nil
    self:Stop()
    self:Start()
end

local function DelayHandler(inst, self)
    self.task = nil
    self.delay_to_time = nil
    if self.is_watching_rain then
        self:StopWatchingWorldState("startrain", OnStartRain)
        self.is_watching_rain = nil
    end
    self:Start()
end

local function ScheduleDelayTask(inst, self)
    if self:CanRejuvenate() then
        self:WatchWorldState("startrain", OnStartRain)
        self.is_watching_rain = true
    end
    self.task = self.inst:DoTaskInTime(math.max(0, self.delay_to_time - GetTime()), DelayHandler, self)
end

--------------------------------------------------------------------------

function Witherable:Enable(enable)
    if self.enabled then
        if enable == false then
            self.enabled = false
            self:Stop()
        end
    elseif enable ~= false then
        self.enabled = true
        self:Start()
    end
end

function Witherable:IsWithered()
    return self.withered
end

function Witherable:IsProtected()
    return self.protect_task ~= nil
end

function Witherable:CanWither()
    return not self.withered
end

function Witherable:CanRejuvenate()
    return self.withered and self.inst.components.crop == nil
end

function Witherable:ForceWither()
    if self:CanWither() then
        self.delay_to_time = nil
        self.task_to_time = nil
        self:Stop()
        WitherHandler(self.inst, self, true)
    end
end

function Witherable:ForceRejuvenate()
    if self:CanRejuvenate() then
        self.delay_to_time = nil
        self.task_to_time = nil
        self:Stop()
        RejuvenateHandler(self.inst, self, true)
    end
end

function Witherable:DelayWither(delay)
    if self:CanWither() then
        local t = GetTime() + delay
        if self.delay_to_time == nil or self.delay_to_time < t then
            self.delay_to_time = t
            self.task_to_time = nil
            self:Stop()
        end
        self:Start()
    end
end

function Witherable:DelayRejuvenate(delay)
    if self:CanRejuvenate() then
        if not TheWorld.state.israining then
            local t = GetTime() + delay
            if self.delay_to_time == nil or self.delay_to_time < t then
                self.delay_to_time = t
                self.task_to_time = nil
                self:Stop()
            end
        end
        self:Start()
    end
end

local function OnEndProtect(inst, self)
    self.protect_task = nil
    self.protect_to_time = nil
end

function Witherable:Protect(duration)
    local t = GetTime() + duration
    if self.protect_to_time == nil or self.protect_to_time < t then
        self.protect_to_time = t
        if self.protect_task ~= nil then
            self.protect_task:Cancel()
        end
        self.protect_task = self.inst:DoTaskInTime(duration, OnEndProtect, self)
        self:ForceRejuvenate()
        self:DelayWither(duration)
    end
end

function Witherable:Start()
    if self.task == nil and self.enabled and not self.inst:IsAsleep() then
        if self.delay_to_time ~= nil then
            ScheduleDelayTask(self.inst, self)
        elseif self:CanWither() then
            ScheduleWitherTask(self.inst, self)
        elseif self:CanRejuvenate() then
            ScheduleRejuvenateTask(self.inst, self)
        end
    end
end

function Witherable:Stop()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
        if self.is_watching_rain then
            self:StopWatchingWorldState("startrain", OnStartRain)
            self.is_watching_rain = nil
        end
    end
end

Witherable.OnEntitySleep = Witherable.Stop
Witherable.OnEntityWake = Witherable.Start

function Witherable:OnSave()
    local data = {}
    if self.withered then
        data.withered = true
        data.restore_cycles = self.restore_cycles
    end
    local t = GetTime()
    if (self.delay_to_time or 0) > t then
        data.delay_time_remaining = self.delay_to_time - GetTime()
    elseif (self.task_to_time or 0) > t then
        data.task_time_remaining = self.task_to_time - GetTime()
    end
    if (self.protect_to_time or 0) > t then
        data.protect_time_remaining = self.protect_to_time - GetTime()
    end
    return next(data) ~= nil and data or nil
end

function Witherable:OnLoad(data)
    if data.withered then
        self.withered = true
        if self.inst.components.crop ~= nil then
            DoCropWither(self.inst)
        elseif self.inst.components.pickable ~= nil then
            self.restore_cycles = data.restore_cycles
        end
    end
    if data.delay_time_remaining ~= nil then
        self.delay_to_time = GetTime() + data.delay_time_remaining
    elseif data.task_time_remaining ~= nil then
        self.task_to_time = GetTime() + data.task_time_remaining
    end
    if data.protect_time_remaining ~= nil then
        self:Protect(data.protect_time_remaining)
    end
end

function Witherable:GetDebugString()
    local s = "withered: "..tostring(self.withered)
        .." wither temp: "..tostring(self.wither_temp)
        .." rejuve temp: "..tostring(self.rejuvenate_temp)

    if not self.enabled then
        s = s.." DISABLED"
    end

    if self:IsProtected() then
        s = s..string.format(" PROTECTED: %2.2f", self.protect_to_time - GetTime())
    end

    if self.task == nil then
        return s.." STOPPED"
    elseif self.delay_to_time ~= nil then
        return s..string.format(" DELAYING: %2.2f", self.delay_to_time - GetTime())
    elseif self:CanWither() then
        return s..string.format(" WITHERING: %2.2f", self.task_to_time - GetTime())
    elseif self:CanRejuvenate() then
        return s..string.format(" REJUVENATING: %2.2f", self.task_to_time - GetTime())
    end
    return s
end

return Witherable