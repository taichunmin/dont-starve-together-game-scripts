local Timer = Class(function(self, inst)
    self.inst = inst
    self.timers = {}
end)

function Timer:OnRemoveFromEntity()
    for k, v in pairs(self.timers) do
        if v.timer ~= nil then
            v.timer:Cancel()
        end
    end
end

function Timer:GetDebugString()
    local str = ""
    for k, v in pairs(self.timers) do
        str = str..string.format(
            "\n    --%s: timeleft: %.2f paused: %s",
            k,
            self:GetTimeLeft(k) or 0,
            tostring(self:IsPaused(k) == true)
        )
    end
    return str
end

function Timer:TimerExists(name)
    return self.timers[name] ~= nil
end

local function OnTimerDone(inst, self, name)
    self:StopTimer(name)
    inst:PushEvent("timerdone", { name = name })
end

function Timer:StartTimer(name, time, paused, initialtime_override)
    if self:TimerExists(name) then
        print("A timer with the name ", name, " already exists on ", self.inst, "!")
        return
    end

    self.timers[name] =
    {
        timer = self.inst:DoTaskInTime(time, OnTimerDone, self, name),
        timeleft = time,
        end_time = GetTime() + time,
        initial_time = initialtime_override or time,
        paused = false,
    }

    if paused then
        self:PauseTimer(name)
    end
end

function Timer:StopTimer(name)
    if not self:TimerExists(name) then
        return
    end

    if self.timers[name].timer ~= nil then
        self.timers[name].timer:Cancel()
        self.timers[name].timer = nil
    end
    self.timers[name] = nil
end

function Timer:IsPaused(name)
    return self:TimerExists(name) and self.timers[name].paused
end

function Timer:PauseTimer(name)
    if not self:TimerExists(name) or self:IsPaused(name) then
        return
    end

    self:GetTimeLeft(name)

    self.timers[name].paused = true
    self.timers[name].timer:Cancel()
    self.timers[name].timer = nil
end

function Timer:ResumeTimer(name)
    if not self:IsPaused(name) then
        return
    end

    self.timers[name].paused = false
    self.timers[name].timer = self.inst:DoTaskInTime(self.timers[name].timeleft, OnTimerDone, self, name)
    self.timers[name].end_time = GetTime() + self.timers[name].timeleft
	return true
end

function Timer:GetTimeLeft(name)
    if not self:TimerExists(name) then
        return
    elseif not self:IsPaused(name) then
        self.timers[name].timeleft = self.timers[name].end_time - GetTime()
    end
    return self.timers[name].timeleft
end

function Timer:SetTimeLeft(name, time)
    if not self:TimerExists(name) then
        return
    elseif self:IsPaused(name) then
        self.timers[name].timeleft = math.max(0, time)
    else
        self:PauseTimer(name)
        self.timers[name].timeleft = math.max(0, time)
        self:ResumeTimer(name)
    end
end

function Timer:GetTimeElapsed(name)
    return self:TimerExists(name)
        and (self.timers[name].initial_time or 0) - self:GetTimeLeft(name)
        or nil
end

function Timer:OnSave()
    local data = {}
    for k, v in pairs(self.timers) do
        data[k] =
        {
            timeleft = self:GetTimeLeft(k),
            paused = v.paused,
            initial_time = v.initial_time,
        }
    end
    return next(data) ~= nil and { timers = data } or nil
end

function Timer:OnLoad(data)
    if data.timers ~= nil then
        for k, v in pairs(data.timers) do
            self:StopTimer(k)
            self:StartTimer(k, v.timeleft, v.paused, v.initial_time)
        end
    end
end

function Timer:LongUpdate(dt)
    for k, v in pairs(self.timers) do
        self:SetTimeLeft(k, self:GetTimeLeft(k) - dt)
    end
end

return Timer
