--------------------------------------------------------------------------
--[[ ToadstoolSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ToadstoolSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

local TOADSTOOL_TIMERNAME = "toadstool_respawntask"

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _worldsettingstimer = TheWorld.components.worldsettingstimer
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
    _worldsettingstimer:StopTimer(TOADSTOOL_TIMERNAME)
end

local function OnRespawnTimer()
    if GetSpawnedToadstool() == nil then
        TriggerRandomSpawner()
    end
end

local function StartRespawnTimer(t)
    StopRespawnTimer()
    _worldsettingstimer:StartTimer(TOADSTOOL_TIMERNAME, t or TUNING.TOADSTOOL_RESPAWN_TIME)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnToadstoolStateChanged()
    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    elseif not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME) then
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
            elseif not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME) and #_spawners > 0 then
                StartRespawnTimer(TUNING.TOADSTOOL_SPAWN_TIME)
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
    elseif not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME) then
        StartRespawnTimer(TUNING.TOADSTOOL_SPAWN_TIME)
    end
end

local function OnToadstoolTimerDone(inst, data)
    OnRespawnTimer()
end
_worldsettingstimer:AddTimer(TOADSTOOL_TIMERNAME, TUNING.TOADSTOOL_RESPAWN_TIME, TUNING.SPAWN_TOADSTOOL, OnToadstoolTimerDone)

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables

--Register events
inst:ListenForEvent("ms_registertoadstoolspawner", OnRegisterToadstoolSpawner, TheWorld)

StartRespawnTimer(TUNING.TOADSTOOL_SPAWN_TIME)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    if GetSpawnedToadstool() ~= nil then
        StopRespawnTimer()
    elseif not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME) then
        StartRespawnTimer()
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:IsEmittingGas()
    --return GetSpawnedToadstool() ~= nil
    --this "should" be the same result, except much faster
    --could differ when a spawnpoint is forcefully removed
    return not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return {toadstool_queued_spawn = not _worldsettingstimer:ActiveTimerExists(TOADSTOOL_TIMERNAME)}
end

function self:OnLoad(data)
    --retrofit old timer to new system
    if data.timetorespawn then
        StartRespawnTimer(math.min(data.timetorespawn, TUNING.TOADSTOOL_RESPAWN_TIME))
    elseif data.toadstool_queued_spawn ~= false then
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
        _worldsettingstimer:GetTimeLeft(TOADSTOOL_TIMERNAME) or 0
    )
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
