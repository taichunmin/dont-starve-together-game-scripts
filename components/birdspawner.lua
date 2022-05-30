--------------------------------------------------------------------------
--[[ BirdSpawner class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "BirdSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--Note: in winter, 'robin' is replaced with 'robin_winter' automatically
local BIRD_TYPES =
{
    --[GROUND.IMPASSABLE] = { "" },
    --[GROUND.ROAD] = { "crow" },
    [GROUND.ROCKY] = { "crow" },
    [GROUND.DIRT] = { "crow" },
    [GROUND.SAVANNA] = { "robin", "crow" },
    [GROUND.GRASS] = { "robin" },
    [GROUND.FOREST] = { "robin", "crow" },
    [GROUND.MARSH] = { "crow" },

    [GROUND.OCEAN_COASTAL] = {"puffin"},
    [GROUND.OCEAN_COASTAL_SHORE] = {"puffin"},
    [GROUND.OCEAN_SWELL] = {"puffin"},
    [GROUND.OCEAN_ROUGH] = {"puffin"},
    [GROUND.OCEAN_BRINEPOOL] = {"puffin"},
    [GROUND.OCEAN_BRINEPOOL_SHORE] = {"puffin"},
    [GROUND.OCEAN_HAZARDOUS] = {"puffin"},
    [GROUND.OCEAN_WATERLOG] = {},
}

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
local _groundcreep = TheWorld.GroundCreep
local _updating = false
local _birds = {}
local _maxbirds = TUNING.BIRD_SPAWN_MAX
local _minspawndelay = TUNING.BIRD_SPAWN_DELAY.min
local _maxspawndelay = TUNING.BIRD_SPAWN_DELAY.max
local _timescale = 1

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function CalcValue(player, basevalue, modifier)
	local ret = basevalue
	local attractor = player and player.components.birdattractor
	if attractor then
		ret = ret + attractor.spawnmodifier:CalculateModifierFromKey(modifier)
	end
	return ret
end

local BIRD_MUST_TAGS = { "bird" }
local function SpawnBirdForPlayer(player, reschedule)
    local pt = player:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 64, BIRD_MUST_TAGS)
    if #ents < CalcValue(player, _maxbirds, "maxbirds") then
        local spawnpoint = self:GetSpawnPoint(pt)
        if spawnpoint ~= nil then
            self:SpawnBird(spawnpoint)
        end
    end
    _scheduledtasks[player] = nil
    reschedule(player)
end

local function ScheduleSpawn(player, initialspawn)
    if _scheduledtasks[player] == nil then
		local mindelay = CalcValue(player, _minspawndelay, "mindelay")
		local maxdelay = CalcValue(player, _maxspawndelay, "maxdelay")
        local lowerbound = initialspawn and 0 or mindelay
        local upperbound = initialspawn and (maxdelay - mindelay) or maxdelay
        _scheduledtasks[player] = player:DoTaskInTime(GetRandomMinMax(lowerbound, upperbound) * _timescale, SpawnBirdForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function ToggleUpdate(force)
    if not _worldstate.isnight and _maxbirds > 0 then
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

local SCARECROW_TAGS = { "scarecrow" }
local CARNIVAL_EVENT_ONEOF_TAGS = { "carnivaldecor", "carnivaldecor_ranker" }
local function PickBird(spawnpoint)
    local bird = "crow"
	if TheNet:GetServerGameMode() == "quagmire" then
		bird = "quagmire_pigeon"
	else
	    local tile = _map:GetTileAtPoint(spawnpoint:Get())
		if BIRD_TYPES[tile] ~= nil then
			bird = GetRandomItem(BIRD_TYPES[tile])
		end

		if IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) and bird ~= "crow" and IsLandTile(tile) then
			local x, y, z = spawnpoint:Get()
			if TheSim:CountEntities(x, y, z, TUNING.BIRD_CANARY_LURE_DISTANCE, nil, nil, CARNIVAL_EVENT_ONEOF_TAGS) > 0 then
				bird = "crow"
			end
		elseif bird == "crow" then
			local x, y, z = spawnpoint:Get()
			if TheSim:CountEntities(x, y, z, TUNING.BIRD_CANARY_LURE_DISTANCE, SCARECROW_TAGS) > 0 then
				bird = "canary"
			end
		end
	end

    return _worldstate.iswinter and bird == "robin" and "robin_winter" or bird
end

local SCARYTOPREY_TAGS = { "scarytoprey" }
local function IsDangerNearby(x, y, z)
    local ents = TheSim:FindEntities(x, y, z, 8, SCARYTOPREY_TAGS)
    return next(ents) ~= nil
end

local function AutoRemoveTarget(inst, target)
    if _birds[target] ~= nil and target:IsAsleep() then
        target:Remove()
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTargetSleep(target)
    inst:DoTaskInTime(0, AutoRemoveTarget, target)
end

local function OnIsRaining(inst, israining)
    _timescale = israining and TUNING.BIRD_RAIN_FACTOR or 1
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

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:WatchWorldState("israining", OnIsRaining)
inst:WatchWorldState("isnight", function() ToggleUpdate() end)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    OnIsRaining(inst, _worldstate.israining)
    ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetSpawnTimes()
    --depreciated
end

function self:SetMaxBirds()
    --depreciated
end

function self:ToggleUpdate()
    ToggleUpdate(true)
end

function self:SpawnModeNever()
    --depreciated
end

function self:SpawnModeLight()
    --depreciated
end

function self:SpawnModeMed()
    --depreciated
end

function self:SpawnModeHeavy()
    --depreciated
end

local BIRDBLOCKER_TAGS = {"birdblocker"}
function self:GetSpawnPoint(pt)
    --We have to use custom test function because birds can't land on creep
    local function TestSpawnPoint(offset)
        local spawnpoint_x, spawnpoint_y, spawnpoint_z = (pt + offset):Get()
        local allow_water = true
        local moonstorm = false
        if TheWorld.net.components.moonstorms and next(TheWorld.net.components.moonstorms:GetMoonstormNodes()) then
            local node_index = TheWorld.Map:GetNodeIdAtPoint(spawnpoint_x, 0, spawnpoint_z)
            local nodes = TheWorld.net.components.moonstorms._moonstorm_nodes:value()
            for i, node in pairs(nodes) do
                if node == node_index then
                    moonstorm = true
                    break
                end
            end
        end

        return _map:IsPassableAtPoint(spawnpoint_x, spawnpoint_y, spawnpoint_z, allow_water) and
               _map:GetTileAtPoint(spawnpoint_x, spawnpoint_y, spawnpoint_z) ~= GROUND.OCEAN_COASTAL_SHORE and
               not _groundcreep:OnCreep(spawnpoint_x, spawnpoint_y, spawnpoint_z) and
               #(TheSim:FindEntities(spawnpoint_x, 0, spawnpoint_z, 4, BIRDBLOCKER_TAGS)) == 0 and
               not moonstorm
    end

    local theta = math.random() * 2 * PI
    local radius = 6 + math.random() * 6
    local resultoffset = FindValidPositionByFan(theta, radius, 12, TestSpawnPoint)

    if resultoffset ~= nil then
        return pt + resultoffset
    end
end

function self:SpawnBird(spawnpoint, ignorebait)
    local prefab = PickBird(spawnpoint)
    if prefab == nil then
        return
    end

    local bird = SpawnPrefab(prefab)
    if math.random() < .5 then
        bird.Transform:SetRotation(180)
    end
    if bird:HasTag("bird") then
        spawnpoint.y = 15
    end

    --see if there's bait nearby that we might spawn into
    if bird.components.eater and not ignorebait then
        local bait = TheSim:FindEntities(spawnpoint.x, 0, spawnpoint.z, 15)
        for k, v in pairs(bait) do
            local x, y, z = v.Transform:GetWorldPosition()
            if bird.components.eater:CanEat(v) and not v:IsInLimbo() and
                v.components.bait and
                not (v.components.inventoryitem and v.components.inventoryitem:IsHeld()) and
                not IsDangerNearby(x, y, z) and
                (bird.components.floater ~= nil or _map:IsPassableAtPoint(x, y, z)) then
                spawnpoint.x, spawnpoint.z = x, z
                bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
                break
            elseif v.components.trap and
                v.components.trap.isset and
                (not v.components.trap.targettag or bird:HasTag(v.components.trap.targettag)) and
                not v.components.trap.issprung and
                math.random() < TUNING.BIRD_TRAP_CHANCE and
                not IsDangerNearby(x, y, z) then
                spawnpoint.x, spawnpoint.z = x, z
                break
            end
        end
    end

    bird.Physics:Teleport(spawnpoint:Get())

    return bird
end

function self.StartTrackingFn(target)
    if _birds[target] == nil then
        _birds[target] = target.persists == true
        target.persists = false
        inst:ListenForEvent("entitysleep", OnTargetSleep, target)
    end
end

function self:StartTracking(target)
    self.StartTrackingFn(target)
end

function self.StopTrackingFn(target)
    local restore = _birds[target]
    if restore ~= nil then
        target.persists = restore
        _birds[target] = nil
        inst:RemoveEventCallback("entitysleep", OnTargetSleep, target)
    end
end

function self:StopTracking(target)
    self.StopTrackingFn(target)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local numbirds = 0
    for k, v in pairs(_birds) do
        numbirds = numbirds + 1
    end
    return string.format("birds:%d/%d", numbirds, _maxbirds)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
