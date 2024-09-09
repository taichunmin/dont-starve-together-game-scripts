local function DoSpawn(inst, self)
    self:DoSpawn()
end

local function _isnumber(n)
    return type(n) == "number"
end

local MISSING_SPAWN_POS_RETRY_TIME = 15
local GENERAL_RETRY_TIME_PERCENT = 0.25

----------------------------------------------------------------------------------------

local PeriodicSpawner = Class(function(self, inst)
    self.inst = inst

    self.basetime = 40
    self.randtime = 60
    self.prefab = nil

    self.range = nil
    self.density = nil
    self.spacing = nil

    self.onspawn = nil
    self.spawntest = nil

    self.spawnoffscreen = false
end)

----------------------------------------------------------------------------------------

function PeriodicSpawner:SetPrefab(prefab)
    assert(type(prefab) == "function" or Prefabs[prefab] ~= nil)

    self.prefab = prefab
end

function PeriodicSpawner:SetRandomTimes(basetime, variance, no_reset)
    assert(_isnumber(basetime) and _isnumber(variance))

    self.basetime = basetime
    self.randtime = variance

    if self.task ~= nil and not no_reset then
        self:Start()
    end
end

function PeriodicSpawner:SetDensityInRange(range, density)
    assert(_isnumber(range) and _isnumber(density))

    self.range = range
    self.density = density
end

function PeriodicSpawner:SetMinimumSpacing(spacing)
    assert(_isnumber(spacing))

    self.spacing = spacing
end

function PeriodicSpawner:SetOnlySpawnOffscreen(offscreen)
    self.spawnoffscreen = offscreen
end

function PeriodicSpawner:SetOnSpawnFn(fn)
    self.onspawn = fn
end

function PeriodicSpawner:SetSpawnTestFn(fn)
    self.spawntest = fn
end

function PeriodicSpawner:SetGetSpawnPointFn(fn)
    self.getspawnpointfn = fn
end

function PeriodicSpawner:SetIgnoreFlotsamGenerator(ignores)
    self.ignoreflotsamgenerator = ignores
end

----------------------------------------------------------------------------------------

function PeriodicSpawner:Start(timeoverride)
    local time = timeoverride or (self.basetime + math.random()*self.randtime)

    self:Stop()

    self.target_time = GetTime() + time
    self.task = self.inst:DoTaskInTime(time, DoSpawn, self)
end

function PeriodicSpawner:SafeStart(timeoverride)
    if self.target_time == nil then
        self:Start(timeoverride)
    end
end

function PeriodicSpawner:Stop()
    self.target_time = nil

    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

----------------------------------------------------------------------------------------

local PERIODICSPAWNER_CANTTAGS = { "INLIMBO" }

function PeriodicSpawner:TrySpawn(prefab)
    prefab = FunctionOrValue(prefab or self.prefab, self.inst)

    if not (prefab and self.inst:IsValid()) or
        (self.spawnoffscreen and not self.inst:IsAsleep()) or
        (self.spawntest ~= nil and not self.spawntest(self.inst))
    then
        return false, self.basetime * GENERAL_RETRY_TIME_PERCENT
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()

    local spawnpos = Vector3(x, y, z)

    if self.getspawnpointfn ~= nil then
        spawnpos = self.getspawnpointfn(self.inst)

        if not spawnpos then
            return false, MISSING_SPAWN_POS_RETRY_TIME
        end
    end

    if self.range ~= nil or self.spacing ~= nil then
        local density = self.density or 0

        if density <= 0 then
            return false
        end

        local ents = TheSim:FindEntities(x, y, z, self.range or self.spacing, nil, PERIODICSPAWNER_CANTTAGS)
        local count = 0

        for _, nearby_ent in ipairs(ents) do
            if nearby_ent.prefab == prefab then
                --can't spawn if anything within "spacing"
                --optimized to skip distance checks when we already
                --know that FindEntities radius is within "spacing"
                if not self.range or (
                    self.spacing ~= nil and (
                        self.spacing >= self.range or
                        nearby_ent:GetDistanceSqToPoint(spawnpos.x, 0, spawnpos.z) < self.spacing * self.spacing
                    )
                ) then
                    return false
                end

                count = count + 1

                if count >= density then
                    return false
                end
            end
        end
    end

    local ent

    --V2C: using TheWorld.Map:GetPlatformAtPoint(x, z) instead of self.inst:GetCurrentPlatform()
    --     because the spawner may not detect platforms.
    --     e.g. Glommer is flying, and does not detect platforms, but spawns glommerfuel.

    local spawn_x, spawn_y, spawn_z = spawnpos:Get()
    if not self.ignoreflotsamgenerator and TheWorld.components.flotsamgenerator ~= nil and
        not TheWorld.Map:IsVisualGroundAtPoint(spawn_x, spawn_y, spawn_z) and
        not TheWorld.Map:GetPlatformAtPoint(spawn_x, spawn_z)
    then
        ent = TheWorld.components.flotsamgenerator:SpawnFlotsam(spawnpos, prefab, true)
    else
        ent = SpawnPrefab(prefab)

        if ent ~= nil then
            ent.Transform:SetPosition(spawn_x, spawn_y, spawn_z)
        end
    end

    if self.onspawn ~= nil then
        self.onspawn(self.inst, ent)
    end

    return true
end

function PeriodicSpawner:DoSpawn()
    local _, timeoverride = self:TrySpawn()

    self:Start(timeoverride)
end

----------------------------------------------------------------------------------------

function PeriodicSpawner:LongUpdate(dt)
    if self.target_time == nil then
        return
    end

    local new_time = self.target_time - GetTime() - dt

    if new_time <= 0 then
        self:DoSpawn()
    else
        self:Start(new_time)
    end
end

----------------------------------------------------------------------------------------

function PeriodicSpawner:OnSave()
    local time = GetTime()

    if self.target_time ~= nil and self.target_time > time then
        return { time = math.floor(self.target_time - time) }
    end
end

function PeriodicSpawner:OnLoad(data)
    if data ~= nil and data.time ~= nil then
        self:Start(data.time)
    end
end

----------------------------------------------------------------------------------------

PeriodicSpawner.ForceNextSpawn = PeriodicSpawner.DoSpawn
PeriodicSpawner.OnRemoveFromEntity = PeriodicSpawner.Stop

----------------------------------------------------------------------------------------

function PeriodicSpawner:GetDebugString()
    return string.format(
        "Next Spawn: %s prefab: %s",
        self.target_time and string.format("%.1f", self.target_time - GetTime()) or "never",
        tostring(self.prefab)
    )
end

----------------------------------------------------------------------------------------

return PeriodicSpawner
