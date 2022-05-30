local easing = require("easing")

local RETRY_INTERVAL = TUNING.SEG_TIME / 3
local RETRY_PERIOD = TUNING.TOTAL_DAY_TIME / 2
local NUM_RETRIES = math.floor(RETRY_PERIOD / RETRY_INTERVAL + .5)

local SHOWER_LEVELS =
{
    --level: 1
    {
        duration =
        {
            base = TUNING.METEOR_SHOWER_LVL1_DURATION_BASE,
            min_variance = TUNING.METEOR_SHOWER_LVL1_DURATIONVAR_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL1_DURATIONVAR_MAX,
        },
        rate =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL1_METEORSPERSEC_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL1_METEORSPERSEC_MAX,
        },
        max_medium =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL1_MEDMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL1_MEDMETEORS_MAX,
        },
        max_large =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL1_LRGMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL1_LRGMETEORS_MAX,
        },
        cooldown =
        {
            base = TUNING.METEOR_SHOWER_LVL1_BASETIME,
            min_variance = 0,
            max_variance = TUNING.METEOR_SHOWER_LVL1_VARTIME,
        },
    },

    --level: 2
    {
        duration =
        {
            base = TUNING.METEOR_SHOWER_LVL2_DURATION_BASE,
            min_variance = TUNING.METEOR_SHOWER_LVL2_DURATIONVAR_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL2_DURATIONVAR_MAX,
        },
        rate =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL2_METEORSPERSEC_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL2_METEORSPERSEC_MAX,
        },
        max_medium =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL2_MEDMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL2_MEDMETEORS_MAX,
        },
        max_large =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL2_LRGMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL2_LRGMETEORS_MAX,
        },
        cooldown =
        {
            base = TUNING.METEOR_SHOWER_LVL2_BASETIME,
            min_variance = 0,
            max_variance = TUNING.METEOR_SHOWER_LVL2_VARTIME,
        },
    },

    --level: 3
    {
        duration =
        {
            base = TUNING.METEOR_SHOWER_LVL3_DURATION_BASE,
            min_variance = TUNING.METEOR_SHOWER_LVL3_DURATIONVAR_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL3_DURATIONVAR_MAX,
        },
        rate =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL3_METEORSPERSEC_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL3_METEORSPERSEC_MAX,
        },
        max_medium =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL3_MEDMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL3_MEDMETEORS_MAX,
        },
        max_large =
        {
            base = 0,
            min_variance = TUNING.METEOR_SHOWER_LVL3_LRGMETEORS_MIN,
            max_variance = TUNING.METEOR_SHOWER_LVL3_LRGMETEORS_MAX,
        },
        cooldown =
        {
            base = TUNING.METEOR_SHOWER_LVL3_BASETIME,
            min_variance = 0,
            max_variance = TUNING.METEOR_SHOWER_LVL3_VARTIME,
        },
    },
}

local function MaxFloat(params)
    return params.base + params.max_variance
end

local function RandomizeInteger(params)
    return params.base + math.random(params.min_variance, params.max_variance)
end

local function RandomizeFloat(params)
    return params.base + params.min_variance + math.random() * (params.max_variance - params.min_variance)
end

local function RandomizeLevel()
    return math.random(#SHOWER_LEVELS)
end

local MeteorShower = Class(function(self,inst)
    self.inst = inst

    self.dt = nil
    self.spawn_mod = nil
    self.medium_remaining = nil
    self.large_remaining = nil
    self.retries_remaining = nil

    self.task = nil
    self.tasktotime = nil

    self.level = RandomizeLevel()
    self:StartCooldown()
end)

function MeteorShower:IsShowering()
    return self.dt ~= nil
end

function MeteorShower:IsCoolingDown()
    return self.task ~= nil and self.dt == nil
end

function MeteorShower:SpawnMeteor(mod)
    --Randomize spawn point
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local theta = math.random() * 2 * PI
    -- Do some easing fanciness to make it less clustered around the spawner prefab
    local radius = easing.outSine(math.random(), math.random() * 7, TUNING.METEOR_SHOWER_SPAWN_RADIUS, 1)

    local map = TheWorld.Map
    local fan_offset = FindValidPositionByFan(theta, radius, 30,
        function(offset)
            return map:IsPassableAtPoint(x + offset.x, y + offset.y, z + offset.z)
        end)

    if fan_offset ~= nil then
        local met = SpawnPrefab("shadowmeteor")
        met.Transform:SetPosition(x + fan_offset.x, y + fan_offset.y, z + fan_offset.z)

        if mod == nil then
            mod = 1
        end

        --Randomize size, but only spawn small meteors on the periphery
        local peripheral = radius > TUNING.METEOR_SHOWER_SPAWN_RADIUS - TUNING.METEOR_SHOWER_CLEANUP_BUFFER
        local rand = not peripheral and math.random() or 1
        local cost = math.floor(1 / mod + .5)
        if rand <= TUNING.METEOR_LARGE_CHANCE * mod and (self.large_remaining == nil or self.large_remaining >= cost) then
            met:SetSize("large", mod)
            if self.large_remaining ~= nil then
                self.large_remaining = self.large_remaining - cost
            end
        elseif rand <= TUNING.METEOR_MEDIUM_CHANCE * mod  and (self.medium_remaining == nil or self.medium_remaining >= cost) then
            met:SetSize("medium", mod)
            if self.medium_remaining ~= nil then
                self.medium_remaining = self.medium_remaining - cost
            end
        else
            met:SetSize("small", mod)
        end
        met:SetPeripheral(peripheral)
        return met
    end
end

local function OnUpdate(inst, self)
    if inst:IsNearPlayer(TUNING.METEOR_SHOWER_SPAWN_RADIUS + 30) then
        self.spawn_mod = nil
        self:SpawnMeteor()
    else
        self.spawn_mod = (self.spawn_mod or 1) - TUNING.METEOR_SHOWER_OFFSCREEN_MOD
        if self.spawn_mod <= 0 then
            self.spawn_mod = self.spawn_mod + 1
            self:SpawnMeteor(TUNING.METEOR_SHOWER_OFFSCREEN_MOD)
        end
    end

    if GetTime() >= self.tasktotime then
        self:StartCooldown()
    end
end

function MeteorShower:StartShower(level)
    self:StopShower()

    self.level = level or RandomizeLevel()

    local level_params = SHOWER_LEVELS[self.level]
    local duration = RandomizeFloat(level_params.duration)
    local rate = RandomizeInteger(level_params.rate)

    if duration > 0 and rate > 0 then
        self.dt = 1 / rate
        self.medium_remaining = RandomizeInteger(level_params.max_medium)
        self.large_remaining = RandomizeInteger(level_params.max_large)

        self.task = self.inst:DoPeriodicTask(self.dt, OnUpdate, nil, self)
        self.tasktotime = GetTime() + duration
    end
end

function MeteorShower:StopShower()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.tasktotime = nil
    self.dt = nil
    self.spawn_mod = nil
    self.medium_remaining = nil
    self.large_remaining = nil
    self.retries_remaining = nil
end

local function OnCooldown(inst, self)
    if inst:IsNearPlayer(TUNING.METEOR_SHOWER_SPAWN_RADIUS + 60) then
        self:StartShower()
    elseif self.retries_remaining > 0 then
        -- delay the start just in case a player walks by, so they can witness it
        self.retries_remaining = self.retries_remaining - 1
        self.tasktotime = GetTime() + RETRY_INTERVAL
    else
        -- just do it anyways.
        self:StartShower()
    end
end

function MeteorShower:StartCooldown()
    self:StopShower()

    local level_params = SHOWER_LEVELS[self.level]
    local cooldown = RandomizeFloat(level_params.cooldown)

    if cooldown > 0 then
        self.retries_remaining = NUM_RETRIES
        self.task = self.inst:DoPeriodicTask(RETRY_INTERVAL, OnCooldown, cooldown, self)
        self.tasktotime = GetTime() + cooldown
    end
end

function MeteorShower:OnSave()
    local level_params = SHOWER_LEVELS[self.level]
    local multiplier = self.dt and MaxFloat(level_params.duration) or MaxFloat(level_params.cooldown)
    return
    {
        level = self.level,
        remainingtime = multiplier ~= 0 and (self.tasktotime ~= nil and (self.tasktotime - GetTime()) / multiplier) or 0,
        interval = self.dt,
        mediumleft = self.medium_remaining,
        largeleft = self.large_remaining,
        retriesleft = self.retries_remaining,
        version = 2,
    }
end

function MeteorShower:OnLoad(data)
    if data ~= nil and data.level ~= nil then
        self:StopShower()
        self.level = math.clamp(data.level, 1, #SHOWER_LEVELS)
        if data.remainingtime ~= nil then
            local remaining_time
            if not data.version then
                --retrofit old savedata
                local level_params = SHOWER_LEVELS[self.level]
                local max = data.interval and MaxFloat(level_params.duration) or MaxFloat(level_params.cooldown)
                remaining_time = math.clamp(data.remainingtime, 0, max)
            elseif data.version == 2 then
                local level_params = SHOWER_LEVELS[self.level]
                local multiplier = data.interval and MaxFloat(level_params.duration) or MaxFloat(level_params.cooldown)
                remaining_time = math.max(0, (data.remainingtime * multiplier))
            end
            if data.interval ~= nil then
                self.dt = math.max(0, data.interval)
                self.medium_remaining = math.max(0, data.medium_remaining or 0)
                self.large_remaining = math.max(0, data.large_remaining or 0)
                self.task = self.inst:DoPeriodicTask(self.dt, OnUpdate, nil, self)
            else
                self.retries_remaining = math.max(0, data.retriesleft or NUM_RETRIES)
                self.task = self.inst:DoPeriodicTask(RETRY_INTERVAL, OnCooldown, remaining_time, self)
            end
            self.tasktotime = GetTime() + remaining_time
        end
    end
end

function MeteorShower:GetDebugString()
    return string.format("Level %d ", self.level)
        ..((self:IsShowering() and string.format("SHOWERING: %2.2f, interval: %2.2f (mod: %s), stock: (%d large, %d medium, unlimited small)", self.tasktotime - GetTime(), self.dt, self.spawn_mod ~= nil and string.format("%1.1f", TUNING.METEOR_SHOWER_OFFSCREEN_MOD) or "---", self.large_remaining, self.medium_remaining)) or
            (self:IsCoolingDown() and string.format("COOLDOWN: %2.2f, retry: %d/%d", self.tasktotime - GetTime(), NUM_RETRIES - self.retries_remaining, NUM_RETRIES)) or
            "STOPPED")
end

MeteorShower.OnRemoveFromEntity = MeteorShower.StopShower

return MeteorShower
