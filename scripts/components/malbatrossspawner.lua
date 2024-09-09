
--------------------------------------------------------------------------
--[[ Malbatross spawner class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "Malbatross spawner should not exist on the client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

local MALBATROSS_SPAWN_DIST = 10
local MALBATROSS_PLAYER_SPAWN_DISTSQ = TUNING.MALBATROSS_NOTICEPLAYER_DISTSQ
local MALBATROSS_TIMERNAME = "malbatross_timetospawn"

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _fishshoals = {}
local _firstspawn = true
local _spawnpending = false
local _shuffled_shoals_for_spawning = nil
local _activemalbatross = nil

local _worldsettingstimer = TheWorld.components.worldsettingstimer

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SummonMalbatross(target_shoal, the_malbatross)
    assert(target_shoal ~= nil)

    the_malbatross = the_malbatross or
            TheSim:FindFirstEntityWithTag("malbatross") or
            SpawnPrefab("malbatross")

    _firstspawn = false

    local shoal_position = target_shoal:GetPosition()
    local spawn_offset = FindSwimmableOffset(shoal_position, math.random() * TWOPI, MALBATROSS_SPAWN_DIST, 12, true, false, nil, true)
    local spawn_position = (spawn_offset and shoal_position + spawn_offset) or shoal_position

    if the_malbatross ~= nil then
        the_malbatross.Physics:Teleport(spawn_position:Get())
        the_malbatross.components.knownlocations:RememberLocation("home", shoal_position)
        the_malbatross.components.entitytracker:TrackEntity("feedingshoal", target_shoal)

        the_malbatross.sg:GoToState("arrive")

        return the_malbatross
    else
        return nil
    end
end

local function TryBeginningMalbatrossSpawns()
    if next(_fishshoals) ~= nil then
        if not _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) and not _spawnpending then
            _worldsettingstimer:StartTimer(MALBATROSS_TIMERNAME, (_firstspawn and 0) or GetRandomWithVariance(TUNING.MALBATROSS_SPAWNDELAY_BASE, TUNING.MALBATROSS_SPAWNDELAY_RANDOM))
        end

        _shuffled_shoals_for_spawning = _shuffled_shoals_for_spawning or shuffledKeys(_fishshoals)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnFishShoalRemoved(fish_shoal)
    _fishshoals[fish_shoal] = nil
    if _shuffled_shoals_for_spawning then
        -- If a shoal got removed while we're waiting for a player to approach a shoal to spawn,
        -- just regenerate our shuffled list. Basically equivalently random.
        _shuffled_shoals_for_spawning = shuffledKeys(_fishshoals)
    end
end

local function OnFishShoalAdded(source, fish_shoal)
    if not _fishshoals[fish_shoal] then
        _fishshoals[fish_shoal] = true
        self.inst:ListenForEvent("onremove", OnFishShoalRemoved, fish_shoal)
        if not _activemalbatross then
            TryBeginningMalbatrossSpawns()
        end
    end
end

local function OnMalbatrossKilledOrRemoved(source, the_malbatross)
    _activemalbatross = nil
    _spawnpending = false
    TryBeginningMalbatrossSpawns()
end

local function OnShoalFishHooked(source, fish_shoal)
    if _activemalbatross == nil and fish_shoal ~= nil and (not _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) or _worldsettingstimer:GetTimeLeft(MALBATROSS_TIMERNAME) < 10)
            and math.random() < TUNING.MALBATROSS_HOOKEDFISH_SUMMONCHANCE then

        _shuffled_shoals_for_spawning = {fish_shoal}
    end
end

local function OnMalbatrossTimerDone()
    _spawnpending = true
    inst:StartUpdatingComponent(self)
end

_worldsettingstimer:AddTimer(MALBATROSS_TIMERNAME, TUNING.MALBATROSS_SPAWNDELAY_BASE + TUNING.MALBATROSS_SPAWNDELAY_RANDOM, TUNING.SPAWN_MALBATROSS, OnMalbatrossTimerDone)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    if _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) then
        self.inst:StopUpdatingComponent(self)
    elseif _shuffled_shoals_for_spawning and #_shuffled_shoals_for_spawning > 0 then
        local max_shoals_to_test = math.ceil(#_shuffled_shoals_for_spawning * TUNING.MALBATROSS_SHOAL_PERCENTAGE_TO_TEST)

        for i, shoal in ipairs(_shuffled_shoals_for_spawning) do
            local sx, sy, sz = shoal.Transform:GetWorldPosition()
            if FindClosestPlayerInRangeSq(sx, sy, sz, MALBATROSS_PLAYER_SPAWN_DISTSQ, true) then
                _activemalbatross = SummonMalbatross(shoal)

                _shuffled_shoals_for_spawning = nil
                _worldsettingstimer:StopTimer(MALBATROSS_TIMERNAME)
                self.inst:StopUpdatingComponent(self)
                return
            end

            if i == max_shoals_to_test then
                break
            end
        end
    end
end

function self:Relocate(target_malbatross)
    if next(_fishshoals) ~= nil then
        _shuffled_shoals_for_spawning = shuffledKeys(_fishshoals)
        if _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) then
            _worldsettingstimer:SetTimeLeft(MALBATROSS_TIMERNAME, 0)
        else
            _worldsettingstimer:StartTimer(MALBATROSS_TIMERNAME, 0)
        end

        if target_malbatross then
            -- If a target was passed in, swap our current shoal to the end of the shuffled list,
            -- so it won't be picked (unless somebody modifies the spawn percentage!).
            local feedingshoal = target_malbatross.components.entitytracker:GetEntity("feedingshoal")
            local n_shoal_keys = #_shuffled_shoals_for_spawning
            for i, shoal in ipairs(_shuffled_shoals_for_spawning) do
                if i ~= n_shoal_keys and shoal == feedingshoal then
                    _shuffled_shoals_for_spawning[i], _shuffled_shoals_for_spawning[n_shoal_keys] = _shuffled_shoals_for_spawning[n_shoal_keys], shoal
                    break
                end
            end

            -- Remove the one that was passed in, and let its OnRemove listener call TryBeginningMalbatrossSpawns
            target_malbatross:Remove()
        else
            TryBeginningMalbatrossSpawns()
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {
        _firstspawn = _firstspawn,
        _timerfinished = not _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) or nil
    }

    if _activemalbatross ~= nil then
        data.activeguid = _activemalbatross.GUID

        local ents = {}
        table.insert(ents, _activemalbatross.GUID)
        return data, ents
    else
        return data
    end
end

function self:OnLoad(data)
    if data._time_until_spawn then
        _worldsettingstimer:StartTimer(MALBATROSS_TIMERNAME, math.min(data._time_until_spawn, TUNING.MALBATROSS_SPAWNDELAY_BASE + TUNING.MALBATROSS_SPAWNDELAY_RANDOM))
    elseif data._timerfinished then
        _worldsettingstimer:StopTimer(MALBATROSS_TIMERNAME)
        OnMalbatrossTimerDone()
    end
    _firstspawn = data._firstspawn
end

function self:LoadPostPass(newents, data)
    if data.activeguid ~= nil and newents[data.activeguid] ~= nil then
        _activemalbatross = newents[data.activeguid].entity
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local s = nil
    local time_until_spawn = _worldsettingstimer:GetTimeLeft(MALBATROSS_TIMERNAME)
    local trying_to_spawn = self.inst.updatecomponents[self] ~= nil
    if trying_to_spawn and _shuffled_shoals_for_spawning then
        s = "Spawning: "..tostring(_spawnpending)..", shoals_for_spawning: "..tostring(#_shuffled_shoals_for_spawning)
    elseif not time_until_spawn then
        s = "DORMANT <no time>"
    elseif time_until_spawn > 0 then
        s = string.format("Malbatross is coming in %2.2f", time_until_spawn)
    else
        s = string.format("Trying to spawn: %2.2f", time_until_spawn)
    end

    -- append any more debug info here.
    local num_shoals = 0
    for shoal, _ in pairs(_fishshoals) do
        num_shoals = num_shoals + 1
    end
    s = s .. " || Number of tracked shoals: " .. num_shoals

    return s
end

function self:Summon(_slow_debug_target_entity)
    if _fishshoals and next(_fishshoals) ~= nil then
        if _slow_debug_target_entity == nil then
            _shuffled_shoals_for_spawning = shuffledKeys(_fishshoals)
        else
            -- This isn't particularly efficient (we're recalculating the distancesq in each sort test),
            -- but this route should NOT be the intended spawn method, and is for debug/test/fun spawning instead.
            _shuffled_shoals_for_spawning = {}
            for shoal, _ in pairs(_fishshoals) do
                table.insert(_shuffled_shoals_for_spawning, shoal)
            end
            table.sort(_shuffled_shoals_for_spawning, function(sa, sb)
                return sa:GetDistanceSqToInst(_slow_debug_target_entity) < sb:GetDistanceSqToInst(_slow_debug_target_entity)
            end)
        end

        if _worldsettingstimer:ActiveTimerExists(MALBATROSS_TIMERNAME) then
            _worldsettingstimer:SetTimeLeft(MALBATROSS_TIMERNAME, 5)
        else
            _worldsettingstimer:StartTimer(MALBATROSS_TIMERNAME, 5)
        end
        self.inst:StartUpdatingComponent(self)
    end
end


--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

self.inst:ListenForEvent("ms_registerfishshoal", OnFishShoalAdded, TheWorld)
self.inst:ListenForEvent("ms_unregisterfishshoal", OnFishShoalRemoved, TheWorld)
self.inst:ListenForEvent("ms_shoalfishhooked", OnShoalFishHooked, TheWorld)
self.inst:ListenForEvent("malbatrossremoved", OnMalbatrossKilledOrRemoved, TheWorld)
self.inst:ListenForEvent("malbatrosskilled", OnMalbatrossKilledOrRemoved, TheWorld)

end)
