local WorldSettingsTimer = Class(function(self, inst)
    self.inst = inst
    self.timers = {}
    self.saved_timers = {}
end)

function WorldSettingsTimer:AddTimer(name, maxtime, enabled, callback, externallongupdate)
    if self:TimerExists(name) then
        return
    end

    self.timers[name] = {
        maxtime = maxtime,
        enabled = enabled,
        callback = callback,
        externallongupdate = externallongupdate
    }

    local saved = self.saved_timers[name]
    if saved then
        self:StartTimer(name, saved.timeleft * maxtime, saved.paused, saved.initial_time, saved.blocklongupdate)
        self.saved_timers[name] = nil
    end
end

function WorldSettingsTimer:TimerEnabled(name)
    return self:TimerExists(name) and self.timers[name].enabled
end

function WorldSettingsTimer:GetMaxTime(name)
    return self:TimerExists(name) and self.timers[name].maxtime
end

function WorldSettingsTimer:OnRemoveFromEntity()
    for k, v in pairs(self.timers) do
        if v.timer ~= nil then
            v.timer:Cancel()
        end
    end
end

function WorldSettingsTimer:TimerExists(name)
    return self.timers[name] ~= nil
end

function WorldSettingsTimer:ActiveTimerExists(name)
    return self.timers[name] and self.timers[name].timeleft ~= nil
end

local function OnTimerDone(inst, self, name)
    self:StopTimer(name)
    if self.timers[name].callback then
        self.timers[name].callback(self.inst)
    else
        inst:PushEvent("timerdone", { name = name })
    end
end

function WorldSettingsTimer:StartTimer(name, time, paused, initialtime_override, blocklongupdate)
    if not self:TimerExists(name) then
        print("You must first AddTimer before you can start a timer", name)
        return
    elseif self:ActiveTimerExists(name) then
        print("A timer with the name ", name, " already exists on ", self.inst, "!")
        return
    end

    self.timers[name].timeleft = time
    self.timers[name].end_time = GetTime() + time
    self.timers[name].initial_time = initialtime_override or time
    self.timers[name].paused = paused
    self.timers[name].blocklongupdate = blocklongupdate

    if not self:IsPaused(name) then
        self.timers[name].timer = self.inst:DoTaskInTime(time, OnTimerDone, self, name)
    end
end

function WorldSettingsTimer:StopTimer(name)
    if not self:ActiveTimerExists(name) then
        return
    end

    self.timers[name].timeleft = nil
    self.timers[name].end_time = nil
    self.timers[name].initial_time = nil
    self.timers[name].paused = nil

    if self.timers[name].timer then
        self.timers[name].timer:Cancel()
        self.timers[name].timer = nil
    end
end

function WorldSettingsTimer:IsPaused(name)
    return self:TimerExists(name) and (not self:TimerEnabled(name) or self.timers[name].paused)
end

function WorldSettingsTimer:PauseTimer(name, blocklongupdate)
    if not self:ActiveTimerExists(name) then
        return
    end

    self:GetTimeLeft(name)

    self.timers[name].paused = true
    self.timers[name].blocklongupdate = blocklongupdate
    if self.timers[name].timer then
        self.timers[name].timer:Cancel()
        self.timers[name].timer = nil
    end
end

function WorldSettingsTimer:ResumeTimer(name)
    if not self:ActiveTimerExists(name) or not self.timers[name].paused then
        return
    end
    self.timers[name].paused = false
    self.timers[name].blocklongupdate = nil

    if self:TimerEnabled(name) then
        self.timers[name].timer = self.inst:DoTaskInTime(self.timers[name].timeleft, OnTimerDone, self, name)
        self.timers[name].end_time = GetTime() + self.timers[name].timeleft
    end

    return true
end

function WorldSettingsTimer:GetTimeLeft(name)
    if not self:ActiveTimerExists(name) then
        return
    elseif not self:IsPaused(name) then
        self.timers[name].timeleft = self.timers[name].end_time - GetTime()
    end
    return self.timers[name].timeleft
end

function WorldSettingsTimer:SetTimeLeft(name, time)
    if not self:ActiveTimerExists(name) or not self:TimerEnabled(name) then
        return
    elseif self:IsPaused(name) then
        self.timers[name].timeleft = math.max(0, time)
    else
        self:PauseTimer(name)
        self.timers[name].timeleft = math.max(0, time)
        self:ResumeTimer(name)
    end
end

function WorldSettingsTimer:SetMaxTime(name, time)
    if not self:ActiveTimerExists(name) or not self:TimerEnabled(name) then
        return
    elseif self:IsPaused(name) then
        self.timers[name].timeleft = math.max(0, time) / self.timers[name].maxtime * self.timers[name].timeleft
        self.timers[name].maxtime  = math.max(0, time)
    else
        self:PauseTimer(name)
        self.timers[name].timeleft = math.max(0, time) / self.timers[name].maxtime * self.timers[name].timeleft
        self.timers[name].maxtime  = math.max(0, time)
        self:ResumeTimer(name)
    end
end

function WorldSettingsTimer:GetTimeElapsed(name)
    return self:ActiveTimerExists(name)
        and (self.timers[name].initial_time or 0) - self:GetTimeLeft(name)
        or nil
end

function WorldSettingsTimer:OnSave()
    local data = {}
    for k, v in pairs(self.timers) do
        if self:ActiveTimerExists(k) then
            data[k] =
            {
                timeleft = self:GetTimeLeft(k) / v.maxtime,
                paused = v.paused,
                blocklongupdate = v.blocklongupdate,
                initial_time = v.initial_time,
            }
        end
    end
    return {timers = data}
end

function WorldSettingsTimer:OnLoad(data)
    if data.timers ~= nil then
        for name, v in pairs(data.timers) do
            if self:TimerExists(name) then
                self:StopTimer(name)
                self:StartTimer(name, v.timeleft * self:GetMaxTime(name), v.paused, v.initial_time, v.blocklongupdate)
            else
                self.saved_timers[name] = v
            end
        end
    end
end

function WorldSettingsTimer:LongUpdate(dt)
    for k, v in pairs(self.timers) do
        if self:ActiveTimerExists(k) and not v.externallongupdate and not v.paused and not v.blocklongupdate then
            self:SetTimeLeft(k, self:GetTimeLeft(k) - dt)
        end
    end
end

function WorldSettingsTimer:GetDebugString()
    local str = ""
    for k, v in pairs(self.timers) do
        str = str..string.format(
            "\n    --%s: maxtime: %.2f enabled: %s",
            k,
            self:GetMaxTime(k) or 0,
            tostring(self:TimerEnabled(k) == true)
        )
        if v.timeleft ~= nil then
            str = str..string.format(
                " timeleft: %.2f paused: %s",
                self:GetTimeLeft(k) or 0,
                tostring(self:IsPaused(k) == true)
            )
        end
    end
    return str
end

return WorldSettingsTimer
