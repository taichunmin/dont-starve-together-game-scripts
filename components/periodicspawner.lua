local function DoSpawn(inst, self)
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    self.target_time = nil
    self:TrySpawn()
    self:Start()
end

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

function PeriodicSpawner:SetPrefab(prefab)
    self.prefab = prefab
end

function PeriodicSpawner:SetRandomTimes(basetime, variance, no_reset)
    self.basetime = basetime
    self.randtime = variance
    if self.task and not no_reset then
        self:Stop()
        self:Start()
    end
end

function PeriodicSpawner:SetDensityInRange(range, density)
    self.range = range
    self.density = density
end

function PeriodicSpawner:SetMinimumSpacing(spacing)
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

local PERIODICSPAWNER_CANTTAGS = { "INLIMBO" }
function PeriodicSpawner:TrySpawn(prefab)
    prefab = prefab or self.prefab

    if type(prefab) == "function" then
        prefab = prefab(self.inst)
    end

    if not (prefab and self.inst:IsValid()) or
        (self.spawnoffscreen and not self.inst:IsAsleep()) or
        (self.spawntest ~= nil and not self.spawntest(self.inst)) then
        return false
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()

    if self.range ~= nil or self.spacing ~= nil then
        local density = self.density or 0
        if density <= 0 then
            return false
        end

        local ents = TheSim:FindEntities(x, y, z, self.range or self.spacing, nil, PERIODICSPAWNER_CANTTAGS)
        local count = 0
        for i, v in ipairs(ents) do
            if v.prefab == prefab then
                --can't spawn if anything within "spacing"
                --optimized to skip distance checks when we already
                --know that FindEntities radius is within "spacing"
                if self.range == nil or (
                    self.spacing ~= nil and (
                        self.spacing >= self.range or
                        v:GetDistanceSqToPoint(x, y, z) < self.spacing * self.spacing
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
    local inst = nil
    if not self.inst:GetCurrentPlatform() and not TheWorld.Map:IsVisualGroundAtPoint(x,y,z) and TheWorld.components.flotsamgenerator then
        inst = TheWorld.components.flotsamgenerator:SpawnFlotsam(Vector3(x,y,z),prefab,true)
    else
        inst = SpawnPrefab(prefab)
        inst.Transform:SetPosition(x, y, z)
    end
    if self.onspawn ~= nil then
        self.onspawn(self.inst, inst)
    end
    return true
end

function PeriodicSpawner:Start()
    local t = self.basetime + math.random()*self.randtime
    self.target_time = GetTime() + t
    self.task = self.inst:DoTaskInTime(t, DoSpawn, self)
end

function PeriodicSpawner:Stop()
    self.target_time = nil
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function PeriodicSpawner:ForceNextSpawn()
    DoSpawn(self.inst, self)
end

--[[
function PeriodicSpawner:OnEntitySleep()
    self:Stop()
end

function PeriodicSpawner:OnEntityWake()
    self:Start()
end
--]]

function PeriodicSpawner:LongUpdate(dt)
    if self.target_time then
        if self.task then
            self.task:Cancel()
            self.task = nil
        end
        local time_to_wait = self.target_time - GetTime() - dt

        if time_to_wait <= 0 then
            DoSpawn(self.inst, self)
        else
            self.target_time = GetTime() + time_to_wait
            self.task = self.inst:DoTaskInTime(time_to_wait, DoSpawn, self)
        end
    end
end

PeriodicSpawner.OnRemoveFromEntity = PeriodicSpawner.Stop

function PeriodicSpawner:GetDebugString()
    return string.format("Next Spawn: %s prefab: %s", self.target_time and string.format("%.1f", self.target_time - GetTime()) or "never", tostring(self.prefab))
end

return PeriodicSpawner
