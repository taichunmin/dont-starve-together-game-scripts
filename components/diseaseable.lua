local function ondiseased(self, diseased)
    if diseased then
        self.inst:AddTag("diseased")
    else
        self.inst:RemoveTag("diseased")
    end
end

local function OnWarningOver(inst, self)
    self._warningtask = nil
    self:Disease()
end

local function StartWarning(self, duration)
    self._warningtask = self.inst:DoTaskInTime(duration or GetRandomWithVariance(TUNING.DISEASE_WARNING_TIME, TUNING.DISEASE_WARNING_TIME_VARIANCE), OnWarningOver, self)
end

local DISEASEABLE_TAGS = { "diseaseable" }
local function OnDelayOver(inst, self, StartDelay)
    if math.random() >= TUNING.DISEASE_CHANCE then
        --Disease failed; schedule long retry
        StartDelay(self)
    elseif inst:IsAsleep() then
        --Offscreen; schedule short retry
        local delay = math.min(TUNING.TOTAL_DAY_TIME * 3, TUNING.DISEASE_DELAY_TIME)
        local variance = math.min(TUNING.TOTAL_DAY_TIME * 2, TUNING.DISEASE_DELAY_TIME_VARIANCE)
        StartDelay(self, GetRandomWithVariance(delay, variance))
    else
        --Disease success; start warning time
        self._delaytask = nil
        StartWarning(self)

        --Restart delays on stuff in range of spreading, so that this round
        --of disease can be stopped by quickly removing the diseased entity
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, TUNING.DISEASE_SPREAD_RADIUS, DISEASEABLE_TAGS)
        if #ents > 1 then --1 becaues it includes ourself
            local ents2 = TheSim:FindEntities(x, y, z, 2 * TUNING.DISEASE_SPREAD_RADIUS, DISEASEABLE_TAGS)
            if #ents2 > #ents then
                ents = ents2
                ents2 = TheSim:FindEntities(x, y, z, 3 * TUNING.DISEASE_SPREAD_RADIUS, DISEASEABLE_TAGS)
                if #ents2 > #ents then
                    ents = ents2
                end
            end
            for i, v in ipairs(ents) do
                if v.components.diseaseable._delaytask ~= nil then
                    v.components.diseaseable._delaytask:Cancel()
                    StartDelay(v.components.diseaseable)
                end
            end
        end
    end
end

local function StartDelay(self, delay)
    if TUNING.DISEASE_DELAY_TIME > 0 then
        self._delaytask = self.inst:DoTaskInTime(delay or GetRandomWithVariance(TUNING.DISEASE_DELAY_TIME, TUNING.DISEASE_DELAY_TIME_VARIANCE), OnDelayOver, self, StartDelay)
    end
end

local Diseaseable = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("diseaseable")

    self.onDiseasedFn = nil
    self.diseased = false
    self._lastfx = 0
    self._fxtask = nil
    self._spreadtask = nil
    --self._delaytask = nil
    self._warningtask = nil

    StartDelay(self)
end,
nil,
{
    diseased = ondiseased,
})

function Diseaseable:OnRemoveFromEntity()
    if self._fxtask ~= nil then
        self._fxtask:Cancel()
        self._fxtask = nil
    end
    if self._spreadtask ~= nil then
        self._spreadtask:Cancel()
        self._spreadtask = nil
    end
    if self._delaytask ~= nil then
        self._delaytask:Cancel()
        self._delaytask = nil
    end
    if self._warningtask ~= nil then
        self._warningtask:Cancel()
        self._warningtask = nil
    end
    self.inst:RemoveTag("diseased")
    self.inst:RemoveTag("diseaseable")
end

function Diseaseable:IsDiseased()
    return self.diseased
end

function Diseaseable:IsBecomingDiseased()
    return self._warningtask ~= nil
end

function Diseaseable:SetDiseasedFn(fn)
    self.onDiseasedFn = fn
end

local DISEASED_TAGS = { "diseased" }
local function DoFX(inst, self)
    local loops = 0
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, DISEASED_TAGS)
    local num = 1
    local time = GetTime()
    for i, v in ipairs(ents) do
        if v ~= inst and
            v.components.diseaseable ~= nil and
            v.components.diseaseable._lastfx < time then
            num = num + 1
        end
    end
    if math.random(num) == 1 then
        loops = math.random(3, 7) --limit to net_tinybyte!
        self._lastfx = GetTime() + (loops * 100 + 35) * FRAMES
        local fx = SpawnPrefab("diseaseflies")
        fx.entity:SetParent(inst.entity)
        fx:SetLoops(loops)
    end
    self._fxtask = inst:DoTaskInTime(loops * 100 * FRAMES + 5 + math.random() * 3, DoFX, self)
end

local function DoSpread(inst, self, ScheduleSpread)
    self._spreadtask = nil
    if inst:IsAsleep() then
        --Offscreen; schedule short retry
        ScheduleSpread(self)
    else
        self:Spread()
    end
end

local function ScheduleSpread(self, delay)
    self._spreadtask = self.inst:DoTaskInTime(delay or GetRandomWithVariance(TUNING.DISEASE_SPREAD_TIME, TUNING.DISEASE_SPREAD_TIME_VARIANCE), DoSpread, self, ScheduleSpread)
end

function Diseaseable:Disease()
    if not self.diseased then
        self:OnRemoveFromEntity()

        self.diseased = true
        ScheduleSpread(self)
        self._fxtask = self.inst:DoTaskInTime(math.random(), DoFX, self)

        if self.onDiseasedFn ~= nil then
            self.onDiseasedFn(self.inst)
        end
    end
end

local SPREAD_MUST_TAGS = { "diseaseable" }
function Diseaseable:Spread()
    if self.diseased then
        if self._spreadtask ~= nil then
            self._spreadtask:Cancel()
            self._spreadtask = nil
        end
        local ent = FindEntity(self.inst, TUNING.DISEASE_SPREAD_RADIUS, nil, SPREAD_MUST_TAGS)
        if ent ~= nil then
            ent.components.diseaseable:Disease()
            ScheduleSpread(self)
        end
    end
end

local RESTARTSPREAD_MUST_TAGS = { "diseased" }
function Diseaseable:RestartNearbySpread()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.DISEASE_SPREAD_RADIUS, RESTARTSPREAD_MUST_TAGS)
    for i, v in ipairs(ents) do
        if v.components.diseaseable._spreadtask ~= nil then
            v.components.diseaseable._spreadtask:Cancel()
        end
        ScheduleSpread(v.components.diseaseable)
    end
end

function Diseaseable:OnSave()
    return (self.diseased and { spreadtime = self._spreadtask ~= nil and GetTaskRemaining(self._spreadtask) or -1 })
        or (self._delaytask ~= nil and { delaytime = GetTaskRemaining(self._delaytask) })
        or (self._warningtask ~= nil and { warningtime = GetTaskRemaining(self._warningtask) })
        or nil
end

function Diseaseable:OnLoad(data)
    if data ~= nil then
        if data.spreadtime ~= nil then
            self:Disease()
            if self._spreadtask ~= nil then
                self._spreadtask:Cancel()
                self._spreadtask = nil
            end
            if data.spreadtime >= 0 then
                ScheduleSpread(self, data.spreadtime)
            end
        elseif data.delaytime ~= nil and data.delaytime >= 0 and self._delaytask ~= nil then
            self._delaytask:Cancel()
            StartDelay(self, data.delaytime)
        elseif data.warningtime ~= nil and data.warningtime >= 0 and not self.diseased then
            if self._delaytask ~= nil then
                self._delaytask:Cancel()
                self._delaytask = nil
            end
            if self._warningtask ~= nil then
                self._warningtask:Cancel()
            end
            StartWarning(self, data.warningtime)
        end
    end
end

function Diseaseable:GetDebugString()
    return string.format(
        "diseased: %s, spreadtime: %.2f, delaytime: %.2f, warningtime: %.2f",
        tostring(self.diseased),
        self._spreadtask ~= nil and GetTaskRemaining(self._spreadtask) or 0,
        self._delaytask ~= nil and GetTaskRemaining(self._delaytask) or 0,
        self._warningtask ~= nil and GetTaskRemaining(self._warningtask) or 0
    )
end

return Diseaseable
