--------------------------------------------------------------------------
--[[ FrogRain class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "FrogRain should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _scheduledtasks = {}
local _worldstate = TheWorld.state
local _map = TheWorld.Map
local _frogs = {}
local _frogcap = 0
local _spawntime = TUNING.FROG_RAIN_DELAY
local _updating = false

local _chance = TUNING.FROG_RAIN_CHANCE
local _localfrogs = {
    min = TUNING.FROG_RAIN_LOCAL_MIN,
    max = TUNING.FROG_RAIN_LOCAL_MAX,
}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetSpawnPoint(pt)
    local function TestSpawnPoint(offset)
        local spawnpoint = pt + offset
        return _map:IsAboveGroundAtPoint(spawnpoint:Get())
    end

    local theta = math.random() * 2 * PI
    local radius = math.random() * TUNING.FROG_RAIN_SPAWN_RADIUS
    local resultoffset = FindValidPositionByFan(theta, radius, 12, TestSpawnPoint)

    if resultoffset ~= nil then
        return pt + resultoffset
    end
end

local function SpawnFrog(spawn_point)
    local frog = SpawnPrefab("frog")
    frog.persists = false
    if math.random() < .5 then
        frog.Transform:SetRotation(180)
    end
    frog.sg:GoToState("fall")
    frog.Physics:Teleport(spawn_point.x, 35, spawn_point.z)
    return frog
end

local FROGS_MUST_TAGS = { "frog" }
local function SpawnFrogForPlayer(player, reschedule)
    local pt = player:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.FROG_RAIN_MAX_RADIUS, FROGS_MUST_TAGS)
	if GetTableSize(_frogs) < TUNING.FROG_RAIN_MAX and #ents < _frogcap then
		local spawn_point = GetSpawnPoint(pt)
		if spawn_point ~= nil then
            -- print("Spawning a frog for player ",player)
			local frog = SpawnFrog(spawn_point)
			self:StartTracking(frog)
		end
	end
    _scheduledtasks[player] = nil
    reschedule(player)
end

local function ScheduleSpawn(player, initialspawn)
    if _scheduledtasks[player] == nil and _spawntime ~= nil then
        local lowerbound = _spawntime.min
        local upperbound = _spawntime.max
        _scheduledtasks[player] = player:DoTaskInTime(GetRandomMinMax(lowerbound, upperbound), SpawnFrogForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function ToggleUpdate(force)
    if _worldstate.isspring and -- frogs only come out in the spring!
        _worldstate.israining and
        _worldstate.precipitationrate > TUNING.FROG_RAIN_PRECIPITATION and
        _worldstate.moistureceil > TUNING.FROG_RAIN_MOISTURE then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleSpawn(v, true)
            end
        elseif force then
            for i, v in ipairs(_activeplayers) do
                CancelSpawn(v)
                ScheduleSpawn(v, true)
            end
        end
    elseif _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelSpawn(v)
        end
    end
end

local function AutoRemoveTarget(inst, target)
    if _frogs[target] ~= nil and target:IsAsleep() then
        target:Remove()
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnIsRaining(inst, israining)
    if israining and (math.random() < _chance) then -- only add fromgs to some rains
        _frogcap = math.random(_localfrogs.min, _localfrogs.max)
    else
        _frogcap = 0
    end
    ToggleUpdate()
end

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    if _updating then
        ScheduleSpawn(player, true)
    end
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelSpawn(player)
            table.remove(_activeplayers, i)
            return
        end
    end
end

local function OnTargetSleep(target)
    inst:DoTaskInTime(0, AutoRemoveTarget, target)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:WatchWorldState("israining", OnIsRaining)
inst:WatchWorldState("precipitationrate", ToggleUpdate)

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)


ToggleUpdate(true)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetSpawnTimes(times)
    _spawntime = times
    ToggleUpdate(true)
end

function self:SetMaxFrogs(max)
    _frogcap = max
end

function self.StartTrackingFn(target)
    _frogs[target] = target.persists == true
    target.persists = false
    inst:ListenForEvent("entitysleep", OnTargetSleep, target)
    inst:ListenForEvent("onremove", self.StopTrackingFn, target)
    inst:ListenForEvent("enterlimbo", self.StopTrackingFn, target)
    inst:ListenForEvent("exitlimbo", self.StartTrackingFn, target)
end

function self:StartTracking(target)
    self.StartTrackingFn(target)
end

function self.StopTrackingFn(target)
    local restore = _frogs[target]
    if restore ~= nil then
        target.persists = restore
        _frogs[target] = nil
        inst:RemoveEventCallback("entitysleep", OnTargetSleep, target)
    end
end

--V2C: FIXME: nobody calls this ever... c'mon...
function self:StopTracking(inst)
    _frogs[inst] = nil
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    return
    {
        frogcap = _frogcap,
    }
end

function self:OnLoad(data)
    _frogcap = data.frogcap or 0

    ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local frog_count = 0
    for k, v in pairs(_frogs) do
        frog_count = frog_count + 1
    end
    return string.format("Frograin: %d/%d, updating:%s min: %2.2f max:%2.2f", frog_count, _frogcap, tostring(_updating), _spawntime.min, _spawntime.max)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
