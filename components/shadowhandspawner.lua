--------------------------------------------------------------------------
--[[ ShadowHandSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shadow hand spawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local INTERVAL = TUNING.SEG_TIME * 4
local VARIANCE = TUNING.SEG_TIME * 8
local RETRY_INTERVAL = 5
local RETRY_VARIANCE = 5
local MAX_HANDS_PER_FIRE = 2
local INITIAL_SPAWN_THRESHOLD = TUNING.TOTAL_DAY_TIME * 4

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _map = TheWorld.Map
local _players = {}
local _fueltags = {}
local _fires = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function StopTracking(ent, fireguid)
    if _fires[fireguid] ~= nil then
        table.removearrayvalue(_fires[fireguid], ent)
        if #_fires[fireguid] <= 0 then
            _fires[fireguid] = nil
        end
    end
end

local function StartTracking(ent, fireguid)
    if _fires[fireguid] == nil then
        _fires[fireguid] = { ent }
    else
        table.insert(_fires[fireguid], ent)
    end
    inst:ListenForEvent("onremove", function() StopTracking(ent, fireguid) end, ent)
end

local Reschedule

local function Retry(player, params)
    Reschedule(player, params, RETRY_INTERVAL + RETRY_VARIANCE * math.random())
end

local function SpawnHand(player, params)
    if #params.ents > 0 or player.components.age:GetAge() < INITIAL_SPAWN_THRESHOLD then
        --Already spawned, or player is too young, try again next time
        Reschedule(player, params)
        return
    end
    local sanity = player.replica.sanity:IsInsanityMode() and player.replica.sanity:GetPercent() or 1
    if sanity > .75 then
        --Sanity too high, retry with delay
        Retry(player, params)
        return
    end
    local fire = FindEntity(player, 60, nil, { "fire" }, { "_equippable" }, _fueltags)
    if fire == nil then
        --No fire nearby, retry with delay
        Retry(player, params)
        return
    end
    local firehandcount = _fires[fire.GUID] ~= nil and #_fires[fire.GUID] or 0
    if firehandcount >= MAX_HANDS_PER_FIRE then
        --Max hands for this fire, try again next time
        Reschedule(player, params)
        return
    end
    local count = math.min(math.random(2), MAX_HANDS_PER_FIRE - firehandcount)
    local radius = fire.components.burnable:GetLargestLightRadius()
    local x, y, z = fire.Transform:GetWorldPosition()
    for i = 1, count * 2 do
        local angle = math.random() * 2 * PI
        local result_offset = FindValidPositionByFan(angle, radius, 12, function(offset)
            local x1 = x + offset.x
            local z1 = z + offset.z
            return TheSim:GetLightAtPoint(x1, 0, z1) <= TUNING.DARK_SPAWNCUTOFF
                and _map:IsPassableAtPoint(x1, 0, z1)
                and not _map:IsPointNearHole(Vector3(x1, 0, z1))
        end)
        if result_offset ~= nil then
            local ent = SpawnPrefab("shadowhand")
            ent.Transform:SetPosition(x + result_offset.x, 0, z + result_offset.z)
            ent:SetTargetFire(fire)
            table.insert(params.ents, ent)
            player:ListenForEvent("onremove", function(ent) table.removearrayvalue(params.ents, ent) end, ent)
            StartTracking(ent, fire.GUID)
            if #params.ents >= count then
                break
            end
        end
    end
    if #params.ents > 0 then
        Reschedule(player, params)
    else
        --Nothing spawned, retry with delay
        Retry(player, params)
    end
end

Reschedule = function(player, params, delay, time)
    params.time = time or GetTime()
    params.delay = delay or (INTERVAL + VARIANCE * math.random())
    params.task = player:DoTaskInTime(params.delay, SpawnHand, params)
end

local function Start(player, params, time)
    if params.task == nil then
        Reschedule(player, params, params.delay, time)
    end
end

local function Stop(player, params, time)
    if params.task ~= nil then
        params.task:Cancel()
        params.task = nil
        params.delay = time ~= nil and math.max(0, params.delay + params.time - time) or nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnIsNight(inst, isnight)
    local time = GetTime()
    if isnight then
        for k, v in pairs(_players) do
            Start(k, v, time)
        end
    else
        for k, v in pairs(_players) do
            Stop(k, v, time)
        end
    end
end

local function OnPlayerJoined(inst, player)
    if _players[player] ~= nil then
        return
    end
    if next(_players) == nil then
        inst:WatchWorldState("isnight", OnIsNight)
    end
    _players[player] = { ents = {} }
    if inst.state.isnight then
        Start(player, _players[player])
    end
end

local function OnPlayerLeft(inst, player)
    if _players[player] == nil then
        return
    end
    Stop(player, _players[player])
    _players[player] = nil
    if next(_players) == nil then
        inst:StopWatchingWorldState("isnight", OnIsNight)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for k, v in pairs(FUELTYPE) do
    if v ~= FUELTYPE.USAGE then --Not a real fuel
        table.insert(_fueltags, v.."_fueled")
    end
end

for i, v in ipairs(AllPlayers) do
    OnPlayerJoined(inst, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local count = 0
    for k, v in pairs(_players) do
        count = count + #v.ents
    end
    if count > 0 then
        return count == 1 and "1 shadowhand" or (tostring(count).." shadowhands")
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)