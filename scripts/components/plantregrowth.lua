require "regrowthutil"

local UPDATE_PERIOD = 31 -- less likely to update on the same frame as others

local UpdateBuckets = nil
local UpdateTask = nil
local CurrentBucket = nil

local LastTime = 0
local InternalTimes = {}

local BASE_RADIUS = 8

local moon_tree_mult =
{
    new = 0,
    quarter = 0.5,
    half = 1.0,
    threequarter = 1.5,
    full = 2.0,
}

local TimeMultipliers = {
    ["evergreen"] = function()
        return TUNING.EVERGREEN_REGROWTH_TIME_MULT * ((TheWorld.state.issummer and 2) or (TheWorld.state.iswinter and 0) or 1)
    end,
    ["evergreen_sparse"] = function()
        return TUNING.EVERGREEN_REGROWTH_TIME_MULT
    end,
    ["twiggytree"] = function()
        return TUNING.TWIGGYTREE_REGROWTH_TIME_MULT
    end,
    ["deciduoustree"] = function()
        return TUNING.DECIDIOUS_REGROWTH_TIME_MULT * ((not TheWorld.state.isspring and 0) or 1)
    end,
    ["mushtree_tall"] = function()
        return TUNING.MUSHTREE_REGROWTH_TIME_MULT * ((not TheWorld.state.iswinter and 0) or 1)
    end,
    ["mushtree_medium"] = function()
        return TUNING.MUSHTREE_REGROWTH_TIME_MULT * ((not TheWorld.state.issummer and 0) or 1)
    end,
    ["mushtree_small"] = function()
        return TUNING.MUSHTREE_REGROWTH_TIME_MULT * ((not TheWorld.state.isspring and 0) or 1)
    end,
    ["moon_tree"] = function()
        return TUNING.MOONTREE_REGROWTH_TIME_MULT * (moon_tree_mult[TheWorld.state.moonphase] or 0)
    end,
    ["mushtree_moon"] = function()
        return TUNING.MOONMUSHTREE_REGROWTH_TIME_MULT * ((not TheWorld.state.iswinter and 0) or 1)
    end,
    ["palmconetree"] = function()
        return TUNING.PALMCONETREE_REGROWTH_TIME_MULT * ((TheWorld.state.iswinter and 0) or 1)
    end,
}

local function DoUpdate()
    local dt = GetTime() - LastTime
    LastTime = GetTime()
    for k,v in pairs(InternalTimes) do
        local timemult = TimeMultipliers[k]()
        InternalTimes[k] = InternalTimes[k] + dt * timemult * TUNING.REGROWTH_TIME_MULTIPLIER
    end

    CurrentBucket = CurrentBucket < #UpdateBuckets and CurrentBucket + 1 or 1
    for i, v in ipairs(UpdateBuckets[CurrentBucket]) do
        v:TrySpawnNearby()
    end
end

local function RegisterUpdate(self)
    if InternalTimes[self.inst.prefab] == nil then
        InternalTimes[self.inst.prefab] = 0
    end

    if UpdateBuckets == nil then
        assert(UpdateTask == nil)
        UpdateTask = TheWorld:DoPeriodicTask(UPDATE_PERIOD, DoUpdate)
        self._bucket = { self }
        UpdateBuckets = { self._bucket }
        CurrentBucket = 1
        LastTime = GetTime()
        return
    end

    for i, v in ipairs(UpdateBuckets) do
        if #v < 50 then
            self._bucket = v
            table.insert(v, self)
            return
        end
    end
    self._bucket = { self }
    table.insert(UpdateBuckets, 1, self._bucket)
    CurrentBucket = CurrentBucket + 1
end

local function UnregisterUpdate(self)
    if self._bucket == nil then
        --Guard against bad code out there that is removing an entity multiple times
        return
    end
    for i, v in ipairs(self._bucket) do
        if v == self then
            table.remove(self._bucket, i)
            if #self._bucket <= 0 then
                for i2, v2 in ipairs(UpdateBuckets) do
                    if v2 == self._bucket then
                        table.remove(UpdateBuckets, i2)
                        if #UpdateBuckets <= 0 then
                            UpdateTask:Cancel()
                            UpdateTask = nil
                            UpdateBuckets = nil
                            CurrentBucket = nil
                        elseif CurrentBucket > i2 then
                            CurrentBucket = CurrentBucket - 1
                        elseif CurrentBucket > #UpdateBuckets then
                            CurrentBucket = 1
                        end
                        break
                    end
                end
            end
            self._bucket = nil
            return
        end
    end
end

local PlantRegrowth = Class(function(self, inst)
    self.inst = inst

    self.regrowthrate = nil
    self.product = nil
    self.searchtag = nil

    self.nextregrowth = 0

    self.area = nil -- defer this until we try regrowing, to spread out the cost
end)

PlantRegrowth.TimeMultipliers = TimeMultipliers

function PlantRegrowth:ResetGrowthTime()
    self.nextregrowth = InternalTimes[self.inst.prefab] + GetRandomWithVariance(self.regrowthrate, self.regrowthrate * 0.2)
end

function PlantRegrowth:SetRegrowthRate(rate)
    self.regrowthrate = rate
    RegisterUpdate(self)
    if self.nextregrowth <= InternalTimes[self.inst.prefab] then
        self:ResetGrowthTime()
    end
end

function PlantRegrowth:SetProduct(product)
    self.product = product
end

function PlantRegrowth:SetSearchTag(tag)
    self.searchtag = tag
end

function PlantRegrowth:OnRemoveFromEntity()
    UnregisterUpdate(self)
end

function PlantRegrowth:OnRemoveEntity()
    UnregisterUpdate(self)
end

local SPAWN_BLOCKER_TAGS = { "structure", "wall" }
local function GetSpawnPoint(from_pt, radius, prefab)
    local map = TheWorld.Map
    if map == nil then
        return
    end
    local theta = math.random() * TWOPI
    radius = math.random(radius/2, radius)
    local steps = 10
    local step_decrement = (TWOPI/steps)
    for _ = 1, steps do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local try_pos = from_pt + offset
        if map:CanPlantAtPoint(try_pos:Get())
            and map:CanPlacePrefabFilteredAtPoint(try_pos.x, try_pos.y, try_pos.z, prefab)
            and not (RoadManager ~= nil and RoadManager:IsOnRoad(try_pos.x, 0, try_pos.z))
            and #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 3) <= 0
			and #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, BASE_RADIUS, nil, nil, SPAWN_BLOCKER_TAGS) <= 0 then
            return try_pos
        end
        theta = theta - step_decrement
    end
    return nil
end

function PlantRegrowth:TrySpawnNearby()
    if self.nextregrowth > InternalTimes[self.inst.prefab] then
        -- Only regrow every so often
        return
    end

    -- reset the timer even on a failed try
    self:ResetGrowthTime()

    local x, y, z = self.inst.Transform:GetWorldPosition()

    if self.fiveradius == nil then
        -- deferred set up of our respawn characteristics
        self.fiveradius = GetFiveRadius(x, z, self.inst.prefab)

        if self.fiveradius == nil then
            UnregisterUpdate(self)
            return
        end
    end

    local spawnpoint = GetSpawnPoint(Point(x,y,z), self.fiveradius, self.product or self.inst.prefab)
    if spawnpoint ~= nil then
        local targetradius = GetFiveRadius(spawnpoint.x, spawnpoint.z, self.inst.prefab)
        if targetradius then
            local ents = TheSim:FindEntities(spawnpoint.x, spawnpoint.y, spawnpoint.z, targetradius, { self.searchtag or self.inst.prefab })
            if #ents < 5 then
                local offspring = SpawnPrefab(self.product or self.inst.prefab)
                offspring.Transform:SetPosition(spawnpoint:Get())
                --c_teleport(spawnpoint.x, spawnpoint.y, spawnpoint.z)
                --TheCamera:Snap()
            end
        end
    end
end

function PlantRegrowth:OnSave()
    local data =
    {
        regrowthtime =  self.nextregrowth - InternalTimes[self.inst.prefab]
    }
    return next(data) ~= nil and data or nil
end

function PlantRegrowth:OnLoad(data)
    if data ~= nil then
        self.nextregrowth = InternalTimes[self.inst.prefab] + data.regrowthtime
    end
end

function PlantRegrowth:GetDebugString()
    if not self.fiveradius then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        self.fiveradius = GetFiveRadius(x, z, self.inst.prefab)
    end
    if self.fiveradius then
        return string.format("fiveradius: %2.2f regrowth time: %2.2f", self.fiveradius, self.nextregrowth - InternalTimes[self.inst.prefab])
    else
        return string.format("NO GROWTH HERE")
    end

end

return PlantRegrowth
