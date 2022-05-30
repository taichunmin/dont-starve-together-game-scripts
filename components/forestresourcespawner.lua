--------------------------------------------------------------------------
--[[ ForestResourceSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ForestResourceSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MIN_PLAYER_DISTANCE = 240
local RENEW_RADIUS = 60

--each renewable set contains a list of prefab spawns and prefab matches.
--if there aren't any of the prefab matches in an area, it will spawn one
--of the prefabs in the spawns list randomly.
local RENEWABLES =
{
    {
        spawns = { "flint" },
        matches = { "flint" },
    },
    {
        spawns = { "sapling", "sapling", "twiggytree" },
        matches = { "sapling", "twigs", "twiggytree" },
    },
    {
        spawns = { "grass" },
        matches = { "grass", "depleted_grass", "cutgrass", "grassgekko" },
    },
    {
        spawns = { "berrybush", "berrybush", "berrybush_juicy" },
        matches = { "berrybush", "berrybush2", "berrybush_juicy" },
    },
}
--turn the matches tables into key,value pairs
for i, v in ipairs(RENEWABLES) do
    local temp = {}
    for i2, v2 in ipairs(v.matches) do
        temp[v2] = true
    end
    v.matches = temp
end

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _enabled = false
local _spawnpts = {}
local _task = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetRenewablePeriod()
    return TUNING.SEG_TIME + math.random() * TUNING.SEG_TIME
end

local function DoPrefabRenew(x, z, ents, renewable_set, max)
    --Check if this set's prefab matches were found already
    for i, v in ipairs(ents) do
        if renewable_set.matches[v.prefab] then
            return
        end
    end

    --Check if this set has a spawnable prefab
    if #renewable_set.spawns > 0 then
        --Spawn random up to max count
        for i = math.random(max), 1, -1 do
            local theta = math.random() * 2 * PI
            local radius = math.random() * RENEW_RADIUS
            local x1 = x + radius * math.cos(theta)
            local z1 = z - radius * math.sin(theta)
            if inst.Map:CanPlantAtPoint(x1, 0, z1) and
                not (RoadManager ~= nil and RoadManager:IsOnRoad(x1, 0, z1)) then
                local prefab = renewable_set.spawns[math.random(#renewable_set.spawns)]
                if inst.Map:CanPlacePrefabFilteredAtPoint(x1, 0, z1) then
                    SpawnPrefab(prefab).Transform:SetPosition(x1, 0, z1)
                end
            end
        end
    end
end

local RENEW_CANT_TAGS = { "INLIMBO" }
local RENEW_ONEOF_TAGS = { "renewable", "grassgekko" }
local function DoRenew()
    local targeti = math.min(math.floor(easing.inQuint(math.random(), 1, #_spawnpts, 1)), #_spawnpts)
    local target = _spawnpts[targeti]
    table.remove(_spawnpts, targeti)
    table.insert(_spawnpts, target)

    local x, y, z = target.Transform:GetWorldPosition()
    if not IsAnyPlayerInRange(x, y, z, MIN_PLAYER_DISTANCE) then
        local ents = TheSim:FindEntities(x, y, z, RENEW_RADIUS, nil, RENEW_CANT_TAGS, RENEW_ONEOF_TAGS)
        for i, v in ipairs(RENEWABLES) do
            DoPrefabRenew(x, z, ents, v, 3)
        end
    end

    _task = inst:DoTaskInTime(GetRenewablePeriod(), DoRenew)
end

local function Start()
    if _task == nil then
        _task = inst:DoTaskInTime(GetRenewablePeriod(), DoRenew)
    end
end

local function Stop()
    if _task ~= nil then
        _task:Cancel()
        _task = nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function UnregisterSpawnPoint(spawnpt)
    if spawnpt == nil then
        return
    end
    table.removearrayvalue(_spawnpts, spawnpt)
end

local function OnRegisterSpawnPoint(inst, spawnpt)
    if spawnpt == nil or
        table.contains(_spawnpts, spawnpt) then
        return
    end
    table.insert(_spawnpts, spawnpt)
    inst:ListenForEvent("onremove", UnregisterSpawnPoint, spawnpt)
end

local function OnEnableResourceRenewal(inst, enable)
    if _enabled ~= enable then
        _enabled = enable
        if enable then
            Start()
        else
            Stop()
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

inst:ListenForEvent("ms_registerspawnpoint", OnRegisterSpawnPoint)
inst:ListenForEvent("ms_enableresourcerenewal", OnEnableResourceRenewal)

if _enabled then
    Start()
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
