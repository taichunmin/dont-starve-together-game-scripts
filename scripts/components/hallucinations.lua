--------------------------------------------------------------------------
--[[ Hallucinations class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local HALLUCINATION_TYPES =
{
    creepyeyes =
    {
        interval = 5,
        variance = 2.5,
        initial_variance = 20,
        nightonly = true,
    },

    shadowwatcher =
    {
        interval = 30,
        variance = 15,
        initial_variance = 10,
        nightonly = true,
    },

    shadowskittish =
    {
        interval = 10,
        variance = 5,
        initial_variance = 20,
        nightonly = false,
    },
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _player = nil
local _hallucinations = {}
local _fueltags = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function RestartHallucination(hallucination)
    hallucination.task = inst:DoTaskInTime(hallucination.params.initial_variance * math.random(), hallucination.params.spawnfn, hallucination)
end

local function RepeatHallucination(hallucination, delay)
    hallucination.task = inst:DoTaskInTime(delay or (hallucination.params.interval + hallucination.params.variance * math.random()), hallucination.params.spawnfn, hallucination)
end

local function StopTracking(ent)
    local hallucination = _hallucinations[ent.prefab]
    if hallucination ~= nil and hallucination.count > 0 then
        hallucination.count = hallucination.count - 1
    end
end

local function StartTracking(hallucination, ent)
    hallucination.count = hallucination.count + 1
    inst:ListenForEvent("onremove", StopTracking, ent)
end

HALLUCINATION_TYPES.creepyeyes.spawnfn = function(inst, hallucination)
    local sanity = _player.replica.sanity:IsInsanityMode() and _player.replica.sanity:GetPercent() or 1
    if sanity > .6 then
        --Sanity too high, restart
        RestartHallucination(hallucination)
        return
    end
    local maxcount = math.max(2, math.min(6, math.floor((1 - sanity) * 5) * 2 - 2))
    if hallucination.count < maxcount then
        local radius = 5 + math.random() * 10
        local theta = math.random() * TWOPI
        local x, y, z = _player.Transform:GetWorldPosition()
        local x1 = x + radius * math.cos(theta)
        local z1 = z - radius * math.sin(theta)
        local light = TheSim:GetLightAtPoint(x1, 0, z1)
        if light <= .05 then
            local ent = SpawnPrefab(hallucination.name)
            ent.Transform:SetPosition(x1, 0, z1)
            StartTracking(hallucination, ent)
            RepeatHallucination(hallucination)
        else
            --Spawn point too bright, retry next frame
            RepeatHallucination(hallucination, 0)
        end
    else
        --Too many, retry with short delay
        RepeatHallucination(hallucination, 1)
    end
end

local NEARFIRE_MUST_TAGS = { "fire" }
local NEARFIRE_CANT_TAGS = { "_equippable" }

HALLUCINATION_TYPES.shadowwatcher.spawnfn = function(inst, hallucination)
    local sanity = _player.replica.sanity:IsInsanityMode() and _player.replica.sanity:GetPercent() or 1
    if sanity > .5 then
        --Sanity too high, restart
        RestartHallucination(hallucination)
        return
    end
    local maxcount = sanity > .3 and 1 or 2
    if hallucination.count < maxcount then
        local fire = FindEntity(_player, 60, nil, NEARFIRE_MUST_TAGS, NEARFIRE_CANT_TAGS, _fueltags)
        if fire ~= nil then
            local angle = math.random() * 360
            local x, y, z = fire.Transform:GetWorldPosition()
            local result_offset = FindValidPositionByFan(angle, 27, 12, function(offset)
                return TheSim:GetLightAtPoint(x + offset.x, 0, z + offset.z) <= TUNING.DARK_SPAWNCUTOFF
            end)
            if result_offset ~= nil then
                local ent = SpawnPrefab(hallucination.name)
                ent.Transform:SetPosition(x + result_offset.x, 0, z + result_offset.z)
                ent:FacePoint(Point(x, 0, z))
                StartTracking(hallucination, ent)
                RepeatHallucination(hallucination)
                return
            end
        end
    end

    --Try again in a bit
    RepeatHallucination(hallucination, 1 + math.random() * 2)
end

HALLUCINATION_TYPES.shadowskittish.spawnfn = function(inst, hallucination)
    local sanity = _player.replica.sanity:IsInsanityMode() and _player.replica.sanity:GetPercent() or 1
    if sanity > .8 then
        --Sanity too high, restart
        RestartHallucination(hallucination)
        return
    end
    local maxcount = math.max(4, math.min(8, math.floor((1 - sanity) * 5) * 2))
    if hallucination.count < maxcount then
        local theta = math.random() * TWOPI
        local x, y, z = _player.Transform:GetWorldPosition()
        local x1 = x + 15 * math.cos(theta)
        local z1 = z - 15 * math.sin(theta)
        local ent = SpawnPrefab(hallucination.name)
        ent.Transform:SetPosition(x1, 0, z1)
        StartTracking(hallucination, ent)
        RepeatHallucination(hallucination)
    else
        --Too many, retry with short delay
        RepeatHallucination(hallucination, 1)
    end
end

local function Start(nightonly)
    for k, v in pairs(_hallucinations) do
        if (nightonly == nil or v.params.nightonly == nightonly) and v.task == nil then
            RestartHallucination(v)
        end
    end
end

local function Stop(nightonly)
    for k, v in pairs(_hallucinations) do
        if (nightonly == nil or v.params.nightonly == nightonly) and v.task ~= nil then
            v.task:Cancel()
            v.task = nil
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnIsNight()
    if inst.state.isnight and not (inst.state.isfullmoon or CanEntitySeeInDark(_player)) then
        Start(true)
    else
        Stop(true)
    end
end

local function OnPlayerActivated(inst, player)
    if _player ~= player then
        if _player == nil then
            inst:WatchWorldState("isnight", OnIsNight)
            inst:WatchWorldState("isfullmoon", OnIsNight)
            Start(false)
        else
            inst:RemoveEventCallback("nightvision", OnIsNight, _player)
        end
        inst:ListenForEvent("nightvision", OnIsNight, player)
        _player = player
        OnIsNight(inst)
    end
end

local function OnPlayerDeactivated(inst, player)
    if _player == player then
        _player = nil
        inst:RemoveEventCallback("nightvision", OnIsNight, player)
        inst:StopWatchingWorldState("isnight", OnIsNight)
        inst:StopWatchingWorldState("isfullmoon", OnIsNight)
        Stop()
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for k, v in pairs(HALLUCINATION_TYPES) do
    _hallucinations[k] = { name = k, params = v, count = 0 }
end

for k, v in pairs(FUELTYPE) do
    if v ~= FUELTYPE.USAGE then --Not a real fuel
        table.insert(_fueltags, v.."_fueled")
    end
end

--Register events
inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = nil
    for k, v in pairs(_hallucinations) do
        str = string.format("%s %d %s", str ~= nil and (str..", ") or "", v.count, k)
    end
    return str
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
