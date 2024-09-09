--------------------------------------------------------------------------
--[[ LurePlantSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "LurePlantSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MIN_OFFSET = 80
local MAX_OFFSET = 200
local MAX_WEIGHT = 3
local MAX_TRAIL = 32
local TRAIL_TICK_TIME = 40
local VALID_TILES = table.invert(
{
    WORLD_TILES.DIRT,
    WORLD_TILES.SAVANNA,
    WORLD_TILES.GRASS,
    WORLD_TILES.FOREST,
    WORLD_TILES.MARSH,
    WORLD_TILES.CAVE,
    WORLD_TILES.FUNGUS,
    WORLD_TILES.SINKHOLE,
    WORLD_TILES.MUD,
})

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _scheduledspawntasks = {}
local _scheduledtrailtasks = {}
local _worldstate = TheWorld.state
local _map = TheWorld.Map
local _updating = false
local _spawninterval = TUNING.LUREPLANT_SPAWNINTERVAL
local _spawnintervalvariance = TUNING.LUREPLANT_SPAWNINTERVALVARIANCE

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function LogPlayerLocation(playerinst, playerdata)
    if #playerdata.trail >= MAX_TRAIL then
        table.remove(playerdata.trail, 1)
    end

    local pos = Vector3(playerinst.Transform:GetWorldPosition())
    for i, v in ipairs(playerdata.trail) do
        if pos:DistSq(v[1]) < 1600 and VALID_TILES[_map:GetTileAtPoint(pos:Get())] ~= nil then
            --You're close to an old point. Just make that point more likely to be a spawn location.
            v[2] = math.min(v[2] + 0.2, MAX_WEIGHT)
            return
        end
    end

    --If you got past the for loop then this is a new point. Add it to the list!
    table.insert(playerdata.trail, { pos, 0.01 })
end

local function ScheduleTrailLog(playerdata, offset)
    if _scheduledtrailtasks[playerdata] == nil then
        _scheduledtrailtasks[playerdata] = playerdata.player:DoPeriodicTask(TRAIL_TICK_TIME, LogPlayerLocation, offset, playerdata)
    end
end

local function CancelTrailLog(playerdata)
    if _scheduledtrailtasks[playerdata] ~= nil then
        _scheduledtrailtasks[playerdata]:Cancel()
        _scheduledtrailtasks[playerdata] = nil
    end
end

local function IsValidSpawnPoint(pt)
    return VALID_TILES[_map:GetTileAtPoint(pt:Get())]
        and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1) <= 0 --small radius, no tag exclusions
        and _map:IsDeployPointClear(pt, nil, 1)     --generic deploy point test
end

local function FindSpawnLocationInTrail(trail)
    local weight = 0
    for i, v in ipairs(trail) do
        weight = weight + v[2]
    end

    local rnd = math.random() * weight
    for i, v in ipairs(trail) do
        rnd = rnd - v[2]
        if rnd <= 0 then
            while not IsValidSpawnPoint(v[1]) do
                table.remove(trail, i)
                v = trail[i]

                if v == nil then
                    return
                end
            end

            table.remove(trail, i)
            return v[1]
        end
    end
end

local function FindSpawnLocation(x, y, z)
    local theta = math.random() * TWOPI
    local radius = math.random(MIN_OFFSET, MAX_OFFSET)
    local steps = 40
    local step_decrement = TWOPI/steps
    local validpos = {}

    for _ = 1, steps do
        local pt = Vector3(x + radius * math.cos(theta), y, z - radius * math.sin(theta))
        if IsValidSpawnPoint(pt) then
            table.insert(validpos, pt)
        end
        theta = theta - step_decrement
    end

    return #validpos > 0 and validpos[math.random(#validpos)] or nil
end

local function SpawnLurePlantForPlayer(playerinst, playerdata, reschedule)
    if not _worldstate.iswinter then

        local chance = 1/#_activeplayers
        local should_spawn = math.random() < chance
        local loc = FindSpawnLocationInTrail(playerdata.trail) or FindSpawnLocation(playerinst.Transform:GetWorldPosition())
        if loc ~= nil and should_spawn then
            local plant = SpawnPrefab("lureplant")
            plant.Physics:Teleport(loc:Get())
            plant.sg:GoToState("spawn")
        end
    end
    _scheduledspawntasks[playerdata] = nil
    reschedule(playerdata)
end

local function RandomizeSpawnTime()
    return _spawninterval + math.random(-_spawnintervalvariance, _spawnintervalvariance)
end

local function ScheduleSpawnTask(playerdata)
    if _scheduledspawntasks[playerdata] == nil then
        _scheduledspawntasks[playerdata] = playerdata.player:DoTaskInTime(RandomizeSpawnTime(), SpawnLurePlantForPlayer, playerdata, ScheduleSpawnTask)
    end
end

local function CancelSpawnTask(playerdata)
    if _scheduledspawntasks[playerdata] ~= nil then
        _scheduledspawntasks[playerdata]:Cancel()
        _scheduledspawntasks[playerdata] = nil
    end
end

local function StartUpdating(force)
    if not TheWorld.state.isspring then
        return
    end

    if _spawninterval > 0 then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleTrailLog(v, i)
                ScheduleSpawnTask(v)
            end
        elseif force then
            for i, v in ipairs(_activeplayers) do
                CancelTrailLog(v)
                CancelSpawnTask(v)
                ScheduleTrailLog(v, i)
                ScheduleSpawnTask(v)
            end
        end
    end
end

local function StopUpdating()
    if _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelTrailLog(v)
            CancelSpawnTask(v)
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v.player == player then
            return
        end
    end
    local playerdata = { player = player, trail = {} }
    table.insert(_activeplayers, playerdata)
    if _updating then
        ScheduleTrailLog(playerdata)
        ScheduleSpawnTask(playerdata)
    end
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v.player == player then
            CancelTrailLog(v)
            CancelSpawnTask(v)
            table.remove(_activeplayers, i)
            return
        end
    end
end

local OnSeasonTick = function(inst, data)
    if data.season == "spring" then
        StartUpdating()
    else
        StopUpdating()
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, { player = v, trail = {} })
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

inst:ListenForEvent("seasontick", OnSeasonTick, TheWorld)

StartUpdating(true)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SpawnModeNever()
    --depreciated
end

function self:SpawnModeHeavy()
    --depreciated
end

function self:SpawnModeNormal()
    --depreciated
end

function self:SpawnModeMed()
    --depreciated
end

function self:SpawnModeLight()
    --depreciated
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("spawn interval:%2.2f, variance:%2.2f", _spawninterval, _spawnintervalvariance)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)