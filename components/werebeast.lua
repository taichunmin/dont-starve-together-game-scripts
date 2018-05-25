local function DoTransform(inst, self, isfullmoon)
    self._task = nil
    if isfullmoon then
        self:SetWere(math.max(self.weretime, TUNING.TOTAL_DAY_TIME * (1 - TheWorld.state.time) + math.max(0, GetRandomWithVariance(1, 2))))
    else
        self:SetNormal()
    end
end

local function OnRevert(inst, self)
    if self:IsInWereState() and not inst.sg:HasStateTag("transform") then
        self:SetNormal()
    end
end

local function OnIsFullmoon(self, isfullmoon)
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
    if isfullmoon == self:IsInWereState() then
        if isfullmoon and self._reverttask ~= nil then
            local remaining = GetTaskRemaining(self._reverttask)
            local time = TUNING.TOTAL_DAY_TIME * (1 - TheWorld.state.time) + math.max(0, GetRandomWithVariance(1, 2))
            if time > remaining then
                self._reverttask:Cancel()
                self._reverttask = self.inst:DoTaskInTime(time, OnRevert, self)
            end
        end
    elseif not self.inst:IsInLimbo() then
        self._task = self.inst:DoTaskInTime(math.max(0, GetRandomWithVariance(1, 2)), DoTransform, self, isfullmoon)
    end
end

local function DoToggleWere(inst, self)
    self._task = nil
    OnIsFullmoon(self, TheWorld.state.isfullmoon)
end

local function OnExitLimbo(inst)
    local self = inst.components.werebeast
    if self._task ~= nil then
        self._task:Cancel()
    end
    self._task = inst:DoTaskInTime(.2, DoToggleWere, self)
end

local function OnEnterLimbo(inst)
    local self = inst.components.werebeast
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
end

local WereBeast = Class(function(self, inst)
    self.inst = inst

    self.onsetwerefn = nil
    self.onsetnormalfn = nil
    self.weretime = TUNING.SEG_TIME * 4
    self.triggerlimit = nil
    self.triggeramount = nil

    self._task = nil
    self._reverttask = nil

    self:WatchWorldState("isfullmoon", OnIsFullmoon)
    inst:ListenForEvent("exitlimbo", OnExitLimbo)
    inst:ListenForEvent("enterlimbo", OnEnterLimbo)
end)

function WereBeast:OnRemoveFromEntity()
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
    if self._reverttask ~= nil then
        self._reverttask:Cancel()
        self._reverttask = nil
    end
    self:StopWatchingWorldState("isfullmoon", OnIsFullmoon)
    self.inst:RemoveEventCallback("exitlimbo", OnExitLimbo)
    self.inst:RemoveEventCallback("enterlimbo", OnEnterLimbo)
end

function WereBeast:SetOnWereFn(fn)
    self.onsetwerefn = fn
end

function WereBeast:SetOnNormalFn(fn)
    self.onsetnormalfn = fn
end

function WereBeast:SetTriggerLimit(limit)
    self.triggerlimit = limit
    self:ResetTriggers()
end

function WereBeast:TriggerDelta(amount)
    if self.triggerlimit ~= nil then
        self.triggeramount = math.max(0, self.triggeramount + amount)
        if self.triggeramount >= self.triggerlimit then
            self:SetWere()
        end
    end
end

function WereBeast:ResetTriggers()
    self.triggeramount = self.triggerlimit ~= nil and 0 or nil
end

function WereBeast:SetWere(time)
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
    if self.onsetwerefn ~= nil then
        self.onsetwerefn(self.inst)
    end
    self.inst:PushEvent("transformwere")
    self:ResetTriggers()

    if self._reverttask ~= nil then
        self._reverttask:Cancel()
    end
    self._reverttask = self.inst:DoTaskInTime(time or self.weretime, OnRevert, self)
end

function WereBeast:SetNormal()
    if self._task ~= nil then
        self._task:Cancel()
        self._task = nil
    end
    if self.onsetnormalfn ~= nil then
        self.onsetnormalfn(self.inst)
    end
    self.inst:PushEvent("transformnormal")
    self:ResetTriggers()

    if self._reverttask ~= nil then
        self._reverttask:Cancel()
        self._reverttask = nil
    end
end

function WereBeast:IsInWereState()
    return self._reverttask ~= nil
end

function WereBeast:OnSave()
    if self._task ~= nil then
        return TheWorld.state.isfullmoon and { time = math.floor(self.weretime) } or nil
    elseif self._reverttask ~= nil then
        local remaining = math.floor(GetTaskRemaining(self._reverttask))
        return remaining > 0 and { time = remaining } or nil
    end
end

function WereBeast:OnLoad(data)
    if data ~= nil and data.time ~= nil then
        self:SetWere(math.max(0, data.time))
    end
end

function WereBeast:GetDebugString()
    return (self.triggerlimit ~= nil and string.format("triggers: %2.2f/%2.2f", self.triggeramount, self.triggerlimit) or "no triggers")
        ..(self._reverttask ~= nil and string.format(", were time: %2.2f", GetTaskRemaining(self._reverttask)) or "")
end

return WereBeast
