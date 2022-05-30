local CHAIN_RADIUS = 8
local MIN_CHAIN_TIME = .6
local MAX_CHAIN_TIME = 1.8

local Petrifiable = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("petrifiable")

    self.onPetrifiedFn = nil
    self.petrified = false
    self._petrifytask = nil
    self._waketask = nil

    TheWorld:PushEvent("ms_registerpetrifiable", inst)
end)

local function DoChainPetrify(inst, self, DoPetrify, OnEntityWake)
    if self._waketask ~= nil then
        self._waketask:Cancel()
        self._waketask = nil
        inst:RemoveEventCallback("entitywake", OnEntityWake)
    elseif self._petrifytask ~= nil
        and GetTaskRemaining(self._petrifytask) > MAX_CHAIN_TIME then
        self._petrifytask:Cancel()
    else
        return
    end
    self._petrifytask = inst:DoTaskInTime(GetRandomMinMax(MIN_CHAIN_TIME, MAX_CHAIN_TIME), DoPetrify, self, OnEntityWake)
end

local function CanChainPetrify(guy)
    return guy.components.petrifiable ~= nil
        and (guy.components.petrifiable._waketask ~= nil or
            guy.components.petrifiable._petrifytask ~= nil)
end

local PETRIFY_NO_TAGS = { "INLIMBO" }
local function DoPetrify(inst, self, OnEntityWake)
    self._petrifytask = nil

    local ent = FindEntity(inst, CHAIN_RADIUS, CanChainPetrify, nil, PETRIFY_NO_TAGS)
    if ent ~= nil then
        DoChainPetrify(ent, ent.components.petrifiable, DoPetrify, OnEntityWake)
    end

    if self.onPetrifiedFn ~= nil then
        self.onPetrifiedFn(inst)
    end
end

local function DoWake(inst, self, OnEntityWake)
    self._waketask = nil
    inst:RemoveEventCallback("entitywake", OnEntityWake)
    OnEntityWake(inst)
end

local function OnEntityWake(inst)
    local self = inst.components.petrifiable
    if self._waketask ~= nil then
        self._waketask:Cancel()
        self._waketask = nil
    end
    if self._petrifytask == nil then
        self._petrifytask = inst:DoTaskInTime(math.random() * TUNING.SEG_TIME, DoPetrify, self, OnEntityWake)
    end
end

function Petrifiable:OnRemoveFromEntity()
    if self._petrifytask ~= nil then
        self._petrifytask:Cancel()
        self._petrifytask = nil
    end
    if self._waketask ~= nil then
        self._waketask:Cancel()
        self._waketask = nil
        self.inst:RemoveEventCallback("entitywake", OnEntityWake)
    end
    if not self.petrified then
        TheWorld:PushEvent("ms_unregisterpetrifiable", self.inst)
        self.inst:RemoveTag("petrifiable")
    end
end

function Petrifiable:IsPetrified()
    return self.petrified
end

function Petrifiable:SetPetrifiedFn(fn)
    self.onPetrifiedFn = fn
end

function Petrifiable:Petrify(immediate)
    if not self.petrified then
        self:OnRemoveFromEntity()

        self.petrified = true

        --immediate is true by default (i.e. nil)
        if immediate ~= false then
            DoPetrify(self.inst, self)
        elseif self.inst:IsAsleep() then
            self.inst:ListenForEvent("entitywake", OnEntityWake)
            self._waketask = self.inst:DoTaskInTime((2 + math.random()) * TUNING.TOTAL_DAY_TIME, DoWake, self, OnEntityWake)
        else
            self._petrifytask = self.inst:DoTaskInTime(math.random() * TUNING.SEG_TIME, DoPetrify, self, OnEntityWake)
        end
    end
end

function Petrifiable:OnSave()
    return self.petrified and { remainingtime = self._waketask ~= nil and GetTaskRemaining(self._waketask) or 0 } or nil
end

function Petrifiable:OnLoad(data)
    if data ~= nil and data.remainingtime ~= nil then
        self:Petrify(false)
        if data.remainingtime > 0 then
            if self._waketask ~= nil then
                self._waketask:Cancel()
                self._waketask = self.inst:DoTaskInTime(data.remainingtime, DoWake, self, OnEntityWake)
            end
        else
            DoChainPetrify(self.inst, self, DoPetrify, OnEntityWake)
        end
    end
end

function Petrifiable:GetDebugString()
    return string.format(
        "petrified: %s, waketime: %.2f, petrifytime: %.2f",
        tostring(self.petrified),
        self._waketask ~= nil and GetTaskRemaining(self._waketask) or 0,
        self._petrifytask ~= nil and GetTaskRemaining(self._petrifytask) or 0
    )
end

return Petrifiable
