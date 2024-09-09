local Cooldown = Class(function(self, inst)
    self.inst = inst
    self.charged = false
    self.cooldown_duration = nil
    self.startchargingfn = nil
    self.onchargedfn = nil
    self.task = nil
end)

function Cooldown:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function donecharging(inst, self)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end

    self.charged = true
    self.cooldown_deadline = nil

    if self.onchargedfn ~= nil then
        self.onchargedfn(inst)
    end
end

function Cooldown:StartCharging(time)
    time = time or self.cooldown_duration
    self.charged = false
    self.cooldown_deadline = GetTime() + time

    if self.task ~= nil then
        self.task:Cancel()
    end
    self.task = self.inst:DoTaskInTime(time, donecharging, self)

    if self.startchargingfn ~= nil then
        self.startchargingfn(self.inst)
    end
end

function Cooldown:FinishCharging()
    if self.cooldown_deadline ~= nil then
        donecharging(self.inst, self)
    end
end

function Cooldown:GetTimeToCharged()
    return self.cooldown_deadline ~= nil and self.cooldown_deadline - GetTime() or 0
end

function Cooldown:IsCharged()
    return self.charged
end

function Cooldown:IsCharging()
    return not self.charged and self.cooldown_deadline ~= nil
end

function Cooldown:OnSave()
    return {
        charged = self.charged or nil,
        time_to_charge = self.cooldown_deadline ~= nil and math.max(0, self.cooldown_deadline - GetTime()) or nil,
    }
end

function Cooldown:GetDebugString()
    return self.charged and "CHARGED!" or string.format("%2.2f", self:GetTimeToCharged())
end

function Cooldown:LongUpdate(dt)
    if self.cooldown_deadline ~= nil then
        self.cooldown_deadline = self.cooldown_deadline - dt
        local t = GetTime()
        if self.cooldown_deadline < t then
            donecharging(self.inst, self)
        else
            self:StartCharging(self.cooldown_deadline - t)
        end
    end
end

function Cooldown:OnLoad(data)
    if data.charged then
        donecharging(self.inst, self)
    elseif data.time_to_charge ~= nil then
        self:StartCharging(data.time_to_charge)
    end
end

return Cooldown
