--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------
local easing = require("easing")

--------------------------------------------------------------------------
--[[ Deerherdspawner class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "DeerHerdspawner should not exist on client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

local HERD_SPAWN_DIST = 35
local HERD_SPAWN_RADIUS = 4

local HERD_SPAWN_SIZE = 5
local HERD_SPAWN_SIZE_VARIANCE = 1
local HERD_OVERPOPULATION_SIZE = HERD_SPAWN_SIZE + HERD_SPAWN_SIZE_VARIANCE + 1

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------
local _spawners = {}

local _activedeer = {}

local _timetospawn = nil
local _prevherdsummonday = -200 --initialize the timer to a very negative number so it triggers in first autumn, even if its the starting season
local _timetomigrate = nil

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function RemoveDeer(deer)
    _activedeer[deer] = nil
    self.inst:RemoveEventCallback("onremove", RemoveDeer, deer)
    self.inst:RemoveEventCallback("death", RemoveDeer, deer)
end

local function AddDeer(deer)
    _activedeer[deer] = true

    self.inst:ListenForEvent("onremove", RemoveDeer, deer)
    self.inst:ListenForEvent("death", RemoveDeer, deer)
end

local function OnRemoveSpawner(spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            table.remove(_spawners, i)
            return
        end
    end
end

local function OnRegisterDeerSpawningGround(inst, spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            return
        end
    end

    table.insert(_spawners, spawner)
    inst:ListenForEvent("onremove", OnRemoveSpawner, spawner)
end

--------------------------------------------------------------------------
--[[ Register events ]]
--------------------------------------------------------------------------

inst:ListenForEvent("ms_registerdeerspawningground", OnRegisterDeerSpawningGround)

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
local function FindExistingHerd()
    local numexistingdeer = 0
    local existingherd = false
    for k, v in pairs(_activedeer) do
        numexistingdeer = numexistingdeer + 1
        existingherd = existingherd or v
    end

    local spawnpt = nil
    if existingherd then
        spawnpt = TheWorld.components.deerherding.herdlocation

        local notnearplayers = function(pt)
            local x, y, z = pt:Get()
            return not IsAnyPlayerInRange(x, y, z, 35)
        end

        -- if there are no players near the existing herd, then spawn among them
        -- otherwise, look for a location around the heard that is offscreen. They should spawn close enough to run up to the herd and join it.
        if not notnearplayers(spawnpt) then
            local result_offset = FindWalkableOffset(spawnpt, math.random() * TWOPI, HERD_SPAWN_DIST, 8, true, false, notnearplayers) -- try avoiding walls
            if result_offset == nil then
                result_offset = FindWalkableOffset(spawnpt, math.random() * TWOPI, HERD_SPAWN_DIST, 8, true, true, notnearplayers) -- ok don't try to avoid walls, but at least avoid water
            end
            if result_offset ~= nil then
                spawnpt = spawnpt + result_offset
            end
        end
    end

    return numexistingdeer, spawnpt
end

local function FindHerdSpawningGroundPt()
    _spawners = shuffleArray(_spawners)
    for i, v in ipairs(_spawners) do
        if not v:IsNearPlayer(HERD_SPAWN_DIST) then
            return v:GetPosition()
        end
    end

    return _spawners[1] and _spawners[1]:GetPosition() or nil
end

local function SummonHerd()
    local existingsize, spawnpt = FindExistingHerd()
    if existingsize >= HERD_OVERPOPULATION_SIZE then
        return
    end

    if spawnpt == nil then
        spawnpt = FindHerdSpawningGroundPt()
    end

    if spawnpt ~= nil then
        local herd_target_size = GetRandomWithVariance(HERD_SPAWN_SIZE, HERD_SPAWN_SIZE_VARIANCE)
        local num_spawned = 0
        local i = 0
        while num_spawned < herd_target_size and i < herd_target_size + 7 do
            i = i + 1
            local offset = FindWalkableOffset(spawnpt, math.random() * TWOPI, HERD_SPAWN_RADIUS, 10, true, true)
            if offset ~= nil then
                local deerpos = spawnpt + offset
                self:SpawnDeer(deerpos, spawnpt)
                num_spawned = num_spawned + 1
            end
        end

        if num_spawned > 0 then
            inst.components.deerherding:Init(spawnpt, self)
        else
            spawnpt = nil -- flag to try again later
        end
    end

    -- retry later
    if spawnpt == nil and TheWorld.state.isautumn and TheWorld.state.remainingdaysinseason * 2 > TheWorld.state.autumnlength then
        _timetospawn = (1 + math.random()) * TUNING.TOTAL_DAY_TIME
    end
end

local function QueueSummonHerd()
    if TheWorld.state.isautumn and TheWorld.state.cycles - _prevherdsummonday > TheWorld.state.autumnlength then
        _prevherdsummonday = TheWorld.state.cycles

        local spawndelay = TheWorld.state.autumnlength * TUNING.TOTAL_DAY_TIME * (TheWorld.state.cycles <= 0 and 0.5 or 0.2)
        local spawnrandom = .33 * spawndelay

        _timetospawn = GetRandomWithVariance(spawndelay, spawnrandom)
        --print ("Deer Herd in " .. tostring(_timetospawn/TUNING.TOTAL_DAY_TIME) .. " days.", spawndelay/TUNING.TOTAL_DAY_TIME, spawnrandom/TUNING.TOTAL_DAY_TIME)
        self.inst:StartUpdatingComponent(self)
    end
end

local function QueueHerdMigration()
    if TheWorld.state.iswinter and next(_activedeer) ~= nil then
        local spawndelay = 0.75 * TheWorld.state.autumnlength * TUNING.TOTAL_DAY_TIME
        local spawnrandom = 0.1 * TheWorld.state.autumnlength * TUNING.TOTAL_DAY_TIME

        _timetomigrate = GetRandomWithVariance(spawndelay, spawnrandom)
        self.inst:StartUpdatingComponent(self)

        -- Trigger antler growing
        for k, _ in pairs(_activedeer) do
            if k:IsValid() then
                k:PushEvent("queuegrowantler")
            end
        end
    end
end

local function MigrateHerd()
    for k, _ in pairs(_activedeer) do
        if k:IsValid() then
            k:PushEvent("deerherdmigration")
        end
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetDeer()
    return _activedeer
end

function self:SpawnDeer(pos, center)
    local deer = SpawnPrefab("deer")
    if deer then
        deer.Transform:SetPosition(pos:Get())
        deer.Transform:SetRotation(math.random(360)-1)
        deer.components.knownlocations:RememberLocation("herdoffset", pos - center)
        AddDeer(deer)
    end
end

function self:OnUpdate(dt)
    if _timetospawn ~= nil then
        _timetospawn = _timetospawn - dt
        if _timetospawn <= 0 then
            _timetospawn = nil
            SummonHerd()
        end
    elseif _timetomigrate ~= nil then
        if next(_activedeer) == nil then
            _timetomigrate = nil
        else
            _timetomigrate = _timetomigrate - dt
            if _timetomigrate <= 0 then
                _timetomigrate = nil
                MigrateHerd()
            end
        end
    else
        self.inst:StopUpdatingComponent(self)
    end
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data =
    {
        _timetospawn = _timetospawn,
        _prevherdsummonday = _prevherdsummonday,
        _timetomigrate = _timetomigrate,
    }

    for k, v in pairs(_activedeer) do
        if k:IsValid() then
            if data._activedeer == nil then
                data._activedeer = { k.GUID }
            else
                table.insert(data._activedeer, k.GUID)
            end
        end
    end

    return data, data._activedeer
end

function self:OnLoad(data)
    if data ~= nil then
        _prevherdsummonday = data._prevherdsummonday or 0
        if data._lastherdsummonday ~= nil then
            _prevherdsummonday = data._lastherdsummonday -- retrofitting
        end
        _timetospawn = data._timetospawn
        _timetomigrate = data._timetomigrate
    end
end

function self:LoadPostPass(newents, data)
    if data ~= nil and data._activedeer ~= nil then
        for k, v in pairs(data._activedeer) do
            local deer = newents[v]
            if deer ~= nil then
                 AddDeer(deer.entity)
            end
        end
    end

    if _timetospawn ~= nil or _timetomigrate ~= nil then
        self.inst:StartUpdatingComponent(self)
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s = ""
    if _timetomigrate ~= nil then
        s = s .. string.format("Migration in %.2f (%.2f days). Deer remaining = %s", _timetomigrate, _timetomigrate/TUNING.TOTAL_DAY_TIME, tostring(GetTableSize(_activedeer)))
    elseif next(_activedeer) ~= nil then
        s = s .. "The deer are hear. Total Dear = " .. tostring(GetTableSize(_activedeer))
    elseif _timetospawn ~= nil then
        s = s .. string.format("Summoning in %.2f (%.2f days)", _timetospawn, _timetospawn/TUNING.TOTAL_DAY_TIME)
    else
        s = s .. "Dormant: Waiting for autumn."
    end
    return s
end

-- TheWorld.components.deerherdspawner:DebugSummonHerd()
function self:DebugSummonHerd(time)
    _timetospawn = time or 1
    _prevherdsummonday = TheWorld.state.cycles
    self.inst:StartUpdatingComponent(self)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self:WatchWorldState("isautumn", QueueSummonHerd)
self:WatchWorldState("iswinter", QueueHerdMigration)

function self:OnPostInit()
    if _prevherdsummonday < 0 and TheWorld.state.cycles == 0 and TheWorld.state.iswinter then
        _prevherdsummonday = TheWorld.state.cycles
        SummonHerd()
        QueueHerdMigration()
    else
        QueueSummonHerd()
    end
end

end)
