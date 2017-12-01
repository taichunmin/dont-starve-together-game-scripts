--------------------------------------------------------------------------
--[[ ToadstoolSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ToadstoolSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local INITIAL_SPAWN_TIME = 10

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _spawners = {}
local _respawntask = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetSpawnedToadstool()
    for i, v in ipairs(_spawners) do
        if v:HasToadstool() then
            return v
        end
    end
end

local function TriggerRandomSpawner()
    if #_spawners <= 0 then
        return
    end

    local spawner = _spawners[math.random(#_spawners)]
    if spawner ~= nil then
        spawner:PushEvent("ms_spawntoadstool")
    end
end

local function StopRespawnTimer()
    if _respawntask ~= nil then
        _respawntask:Cancel()
        _respawntask = nil
    end
end

local function OnRespawnTimer()
    _respawntask = nil
    if GetSpawnedToadstool() == nil then
        TriggerRandomSpawner()
    end
end

local function StartRespawnTimer(t)
    StopRespawnTimer()
    _respawntask = inst:DoTaskInTime(t or TUNING.TOADSTOOL_RESPAWN_TIME, OnRespawnTimer)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnToadstoolStateChanged()
    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    elseif _respawntask == nil then
        StartRespawnTimer()
    end
end

local function OnToadstoolKilled()
    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    else --force restart
        StartRespawnTimer()
    end
end

local function OnRemoveSpawner(spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            table.remove(_spawners, i)

            if GetSpawnedToadstool() ~= nil then
                StopRespawnTimer()
            elseif _respawntask == nil and #_spawners > 0 then
                StartRespawnTimer(INITIAL_SPAWN_TIME)
            end
            return
        end
    end
end

local function OnRegisterToadstoolSpawner(inst, spawner)
    for i, v in ipairs(_spawners) do
        if v == spawner then
            return
        end
    end

    table.insert(_spawners, spawner)
    inst:ListenForEvent("toadstoolstatechanged", OnToadstoolStateChanged, spawner)
    inst:ListenForEvent("toadstoolkilled", OnToadstoolKilled, spawner)
    inst:ListenForEvent("onremove", OnRemoveSpawner, spawner)

    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    elseif _respawntask == nil then
        StartRespawnTimer(INITIAL_SPAWN_TIME)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables

--Register events
inst:ListenForEvent("ms_registertoadstoolspawner", OnRegisterToadstoolSpawner)

StartRespawnTimer(INITIAL_SPAWN_TIME)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    elseif _respawntask == nil then
        StartRespawnTimer()
    end
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:LongUpdate(dt)
    if _respawntask ~= nil then
        local t = GetTaskRemaining(_respawntask)
        if t > dt then
            StartRespawnTimer(t - dt)
        else
            StopRespawnTimer()
            OnRespawnTimer()
        end
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:IsEmittingGas()
    --return GetSpawnedToadstool() ~= nil
    --this "should" be the same result, except much faster
    --could differ when a spawnpoint is forcefully removed
    return _respawntask == nil
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return _respawntask ~= nil
        and {
            timetorespawn = math.ceil(GetTaskRemaining(_respawntask)),
        }
        or nil
end

function self:OnLoad(data)
    if data.timetorespawn ~= nil then
        StartRespawnTimer(data.timetorespawn)
    else
        StopRespawnTimer()
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format(
        "Active Toadstool: %s  Cooldown: %.2f",
        tostring(GetSpawnedToadstool() or "--"),
        _respawntask ~= nil and GetTaskRemaining(_respawntask) or 0
    )
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
