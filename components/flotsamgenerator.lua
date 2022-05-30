--------------------------------------------------------------------------
--[[ Flotsam generator class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Flotsam generator should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local SourceModifierList = require("util/sourcemodifierlist")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local flotsam_prefabs =
{
    driftwood_log = 1,
    boatfragment03 = 0.3,
    boatfragment04 = 0.3,
    boatfragment05 = 0.3,
    cutgrass = 1,
    twigs = 1,
	oceanfishableflotsam_water = 1,
}

local guaranteed_presets =
{
    messagebottle = { prefabs = { "messagebottle" }, rate = 1 * TUNING.TOTAL_DAY_TIME, variance = 1 * TUNING.TOTAL_DAY_TIME },
}

local GUARANTEED_FLOTSAM_REATTEMPT_DELAY = TUNING.TOTAL_DAY_TIME / 8

local RANGE = 40 -- distance from player to spawn the flotsam.  should be 5 more than wanted
local SHORTRANGE = 5 -- radius that must be clear for flotsam to appear

local LIFESPAN = {	base = TUNING.TOTAL_DAY_TIME *3,
					varriance = TUNING.TOTAL_DAY_TIME }

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
local _minspawndelay = TUNING.FLOTSAM_SPAWN_DELAY.min
local _maxspawndelay = TUNING.FLOTSAM_SPAWN_DELAY.max
local _updating = false
local _flotsam = {}
local _maxflotsam = TUNING.FLOTSAM_SPAWN_MAX
local _timescale = 1
local _flotsam = {}

local _guaranteed_spawn_tasks = {}
--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local SPAWNPOINT_1_ONEOF_TAGS = {"player", "flotsam"}
local SPAWNPOINT_2_ONEOF_TAGS = {"INLIMBO", "fx"}
local function GetSpawnPoint(pt,platform)
    if TheWorld.has_ocean then
        local function TestSpawnPoint(offset)
            local spawnpoint_x, spawnpoint_y, spawnpoint_z = (pt + offset):Get()
            local tile = _map:GetTileAtPoint(spawnpoint_x, spawnpoint_y, spawnpoint_z)
            local allow_water = true
            return IsOceanTile(tile) and
                   tile ~= GROUND.OCEAN_COASTAL_SHORE and
                   #TheSim:FindEntities(spawnpoint_x, spawnpoint_y, spawnpoint_z, RANGE-SHORTRANGE, nil, nil, SPAWNPOINT_1_ONEOF_TAGS) <= 0 and
                   #TheSim:FindEntities(spawnpoint_x, spawnpoint_y, spawnpoint_z, SHORTRANGE, nil, SPAWNPOINT_2_ONEOF_TAGS) <= 0
        end

        local theta = math.random() * 2 * PI

        if platform and platform.components.boatphysics then
            local vel_x, vel_z = platform.components.boatphysics.velocity_x, platform.components.boatphysics.velocity_z

			if vel_x ~= 0 or vel_z ~= 0 then
				local vel = platform.components.boatphysics:GetVelocity()

				local lower = 0.1
				local upper = 1.5

				local vel_remapped = (math.min(upper, math.max(lower, vel)) - lower) / upper
				vel_remapped = 1 - vel_remapped

                local offset = math.random() * vel_remapped * PI * (math.random() > .5 and 1 or -1)
                theta = VecUtil_GetAngleInRads(vel_x, -vel_z) + offset
			end
        end

        local radius = RANGE
        local resultoffset = FindValidPositionByFan(theta, radius, 12, TestSpawnPoint)

        if resultoffset ~= nil then
            return pt + resultoffset
        end
    end
end

local function SpawnFlotsamForPlayer(player, reschedule, override_prefab, override_notrealflotsam)
    local flotsam = nil

    local pt = player:GetPosition()
    if player:GetCurrentPlatform() then
        local spawnpoint = GetSpawnPoint(pt, player:GetCurrentPlatform())
        if spawnpoint ~= nil then
            flotsam = self:SpawnFlotsam(spawnpoint, override_prefab, override_notrealflotsam)
        end
    end
    if reschedule ~= nil then
        _scheduledtasks[player] = nil
        reschedule(player)
    end

    return flotsam
end

local function ScheduleSpawn(player, initialspawn)
    if _scheduledtasks[player] == nil  then
        local mindelay = _minspawndelay
        local maxdelay = _maxspawndelay
        local lowerbound = initialspawn and 0 or mindelay
        local upperbound = initialspawn and (maxdelay - mindelay) or maxdelay
        _scheduledtasks[player] = player:DoTaskInTime(GetRandomMinMax(lowerbound, upperbound) * _timescale, SpawnFlotsamForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function CancelGuaranteedSpawn(player)
    if _guaranteed_spawn_tasks[player] ~= nil then
        for preset, task in pairs(_guaranteed_spawn_tasks[player]) do
            task:Cancel()
        end
        _guaranteed_spawn_tasks[player] = nil
    end
end

local function StartGuaranteedSpawn(player)
    _guaranteed_spawn_tasks[player] = {}

    for k, v in pairs(guaranteed_presets) do
        TheWorld.components.flotsamgenerator:ScheduleGuaranteedSpawn(player, guaranteed_presets[k])
    end
end

local function ToggleUpdate(force)
    if _maxflotsam > 0 then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleSpawn(v, true)
                StartGuaranteedSpawn(v)
            end
        elseif force then
            for i, v in ipairs(_activeplayers) do
                CancelSpawn(v)
                ScheduleSpawn(v, true)

                CancelGuaranteedSpawn(v)
                StartGuaranteedSpawn(v)
            end
        end
    elseif _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelSpawn(v)
            CancelGuaranteedSpawn(v)
        end
    end
end

local function PickFlotsam(spawnpoint)
    local item = weighted_random_choice(flotsam_prefabs)
    return item
end

local function AutoRemoveTarget(inst, target)
    if _flotsam[target] ~= nil and target:IsAsleep() then
        target:Remove()
    end
end

local function rememberflotsam(inst)
    _flotsam[inst] = true
end
local function forgetflotsam(inst)
    if _flotsam[inst] then
        _flotsam[inst] = nil
    end
end

local function OnTimerDone(inst, data)
    if data.name == "flotsamgenerator_sink" then
        forgetflotsam(inst)

		if inst.overrideflotsamsinkfn ~= nil then
			inst:overrideflotsamsinkfn()
		else
			SpawnPrefab("splash_sink").Transform:SetPosition(inst.Transform:GetWorldPosition())
			inst:Remove()
		end
    end
end
local function clearflotsamtimer(inst)
    inst:RemoveTag("flotsam")
    inst.components.timer:StopTimer("flotsamgenerator_sink")
    forgetflotsam(inst)
end
--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTargetSleep(target)
    inst:DoTaskInTime(0, AutoRemoveTarget, target)
end

local function SpawnGuaranteedFlotsam(player, preset)
    if TheWorld.components.flotsamgenerator ~= nil then
        local flotsam = SpawnFlotsamForPlayer(player, nil, preset.prefabs[math.random(#preset.prefabs)], true)
        TheWorld.components.flotsamgenerator:ScheduleGuaranteedSpawn(player, preset, flotsam == nil and GUARANTEED_FLOTSAM_REATTEMPT_DELAY or nil)
    else
        _guaranteed_spawn_tasks[player][preset] = nil
    end
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

    StartGuaranteedSpawn(player)
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelSpawn(player)
            table.remove(_activeplayers, i)
            return
        end
    end

    CancelGuaranteedSpawn(player)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Public getters and setters ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------
function self:SetSpawnTimes(delay)
    print "DEPRECATED: SetSpawnTimes() in birdspawner.lua, use birdattractor.spawnmodifier instead"
    _minspawndelay = delay.min
    _maxspawndelay = delay.max
end

function self:ToggleUpdate()
    ToggleUpdate(true)
end

function self:setinsttoflotsam(inst, time, notag)
    if not time then
        time = LIFESPAN.base + (math.random()*LIFESPAN.varriance)
    end
    if inst.components.timer == nil then
        inst:AddComponent("timer")
    end
    if not notag then
        inst:AddTag("flotsam")
    end
    inst.components.timer:StartTimer("flotsamgenerator_sink", time)

    inst:ListenForEvent("timerdone", OnTimerDone)
    inst:ListenForEvent("onpickup", clearflotsamtimer)
    inst:ListenForEvent("onremove", clearflotsamtimer)

    rememberflotsam(inst)
end

function self:SpawnFlotsam(spawnpoint,prefab,notrealflotsam)
    -- notrealflotsam means the prefab won't get the flotsam tag, so it won't block other flotsam from spawning.
    if not prefab then
        prefab = PickFlotsam(spawnpoint)
    end

    if prefab == nil then
        return
    end

    local flotsam = SpawnPrefab(prefab)
    if math.random() < .5 then
        flotsam.Transform:SetRotation(180)
    end

    flotsam.Physics:Teleport(spawnpoint:Get())

    self:setinsttoflotsam(flotsam, nil, notrealflotsam)

    return flotsam
end

function self.StartTrackingFn(target)
    if _flotsam[target] == nil then
        _flotsam[target] = target.persists == true
        target.persists = false
        inst:ListenForEvent("entitysleep", OnTargetSleep, target)
    end
end

function self:StartTracking(target)
    self.StartTrackingFn(target)
end

function self.StopTrackingFn(target)
    local restore = _flotsam[target]
    if restore ~= nil then
        target.persists = restore
        _flotsam[target] = nil
        inst:RemoveEventCallback("entitysleep", OnTargetSleep, target)
    end
end

function self:StopTracking(target)
    self.StopTrackingFn(target)
end

function self:ScheduleGuaranteedSpawn(player, preset, override_time)
    _guaranteed_spawn_tasks[player][preset] = player:DoTaskInTime(override_time or (preset.rate + preset.variance * math.random()), SpawnGuaranteedFlotsam, preset)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data =
    {
        maxflotsam = _maxflotsam,
        minspawndelay = _minspawndelay,
        maxspawndelay = _maxspawndelay,
    }
    local ents = {}
    data.flotsam = {}
    data.time = {}
    data.flotsamtag = {}

    for k,v in pairs(_flotsam) do
        if k ~= nil then
            table.insert(data.flotsam, k.GUID)
            table.insert(ents, k.GUID)
            table.insert(data.time, k.components.timer:GetTimeLeft("flotsamgenerator_sink") )
            table.insert(data.flotsamtag, k:HasTag("flotsam"))
        end
    end

    return data,ents
end

function self:OnLoad(data)
    _maxflotsam = data.maxflotsam or TUNING.FLOTSAM_SPAWN_MAX
    _minspawndelay = data.minspawndelay or TUNING.FLOTSAM_SPAWN_DELAY.min
    _maxspawndelay = data.maxspawndelay or TUNING.FLOTSAM_SPAWN_DELAY.max

    ToggleUpdate(true)
end

function self:LoadPostPass(newents, savedata)
    if savedata and savedata.flotsam then
        for k,v in pairs(savedata.flotsam) do
            if newents[v] ~= nil then
                local notag = true
                if savedata.flotsamtag and savedata.flotsamtag[k] then
                    notag = nil
                end
                self:setinsttoflotsam(newents[v].entity, savedata.time[k], notag)
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local numflotsam = 0
    for k, v in pairs(_flotsam) do
        numflotsam = numflotsam + 1
    end
    return string.format("flotsam:%d/%d", numflotsam, _maxflotsam)
end

end)
