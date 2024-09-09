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
local _boats = {}
local _boattargets = {}
--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function StopTrackingBoat(ent, boatguid)
    if _boats[boatguid] ~= nil then
        table.removearrayvalue(_boats[boatguid], ent)
        if #_boats[boatguid] <= 0 then
            _boats[boatguid] = nil
        end
    end
end

local function StartTrackingBoat(ent, boatguid)
    if _boats[boatguid] == nil then
        _boats[boatguid] = { ent }
    else
        table.insert(_boats[boatguid], ent)
    end
    inst:ListenForEvent("onremove", function() StopTrackingBoat(ent, boatguid) end, ent)
end

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

local TESTFORTINKER_CAN_TAGS = {"boat_repaired_patch", "structure"}
local function testfortinkerthings(boat)

    local x,y,z = boat.Transform:GetWorldPosition()
    local items = TheSim:FindEntities(x, y, z, boat.components.hull:GetRadius(),nil,nil, TESTFORTINKER_CAN_TAGS)

    for i=#items,1,-1 do
        local ent = items[i]
        local keep = false
        if ent:HasTag("boat_repaired_patch") or
            ent.components.mast or
            ent.components.anchor or
            (ent.components.fueled and ent.components.fueled.canbespecialextinguished) then
            keep = true
        end
        if not keep then
            table.remove(items,i)
        end
    end

    return #items > 0
end

local NEARFIRE_MUST_TAGS = { "fire" }
local NEARFIRE_CANT_TAGS = { "_equippable" }

local function SpawnHand(player, params)

    if #params.ents > 0 or player.components.age:GetAge() < INITIAL_SPAWN_THRESHOLD then
        --Already spawned, or player is too young, try again next time
        Reschedule(player, params)
        return
    end
    local sanity = player.replica.sanity:IsInsanityMode() and player.replica.sanity:GetPercent() or 1
    if sanity > 0.75 then
        --Sanity too high, retry with delay
        Retry(player, params)
        return
    end

    if player:GetCurrentPlatform() and testfortinkerthings(player:GetCurrentPlatform()) then

        local boat = player:GetCurrentPlatform()
        if _boats[boat.GUID] ~= nil then
            -- boat has a jones already
            Reschedule(player, params)
            return
        end
        local ent = inst:spawnwaveyjones(boat)
        table.insert(params.ents, ent)
        player:ListenForEvent("onremove", function(ent) table.removearrayvalue(params.ents, ent) end, ent)
        StartTrackingBoat(ent, boat.GUID)
    else
        -- this is for land and fire.
        local fire = FindEntity(player, 60, nil, NEARFIRE_MUST_TAGS, NEARFIRE_CANT_TAGS, _fueltags)
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
	    local radius = fire.components.burnable:GetLargestLightRadius() or 8
	    local x, y, z = fire.Transform:GetWorldPosition()
	    for i = 1, count * 2 do
	        local angle = math.random() * TWOPI
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

inst.checkwaveyjonestarget = function(inst,target)
    if _boattargets[target.GUID] ~= nil then
        return true
    end
end

inst.reservewaveyjonestarget = function(inst,target)
    _boattargets[target.GUID] = true
end

inst.removewaveyjonestarget = function(inst,target)
    if _boattargets[target.GUID] ~= nil then
        _boattargets[target.GUID] = nil
    end
end

inst.spawnwaveyjones = function(inst,boat)
    local jones_marker = SpawnPrefab("waveyjones_marker")
    local x,y,z = boat.Transform:GetWorldPosition()
    jones_marker.Transform:SetPosition(x,y,z)
    jones_marker.components.entitytracker:TrackEntity("boat", boat)
    return jones_marker
end


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