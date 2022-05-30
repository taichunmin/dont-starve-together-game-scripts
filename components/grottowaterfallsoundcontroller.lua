--------------------------------------------------------------------------
--[[ Grotto Waterfall Sound Controller class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local EMITTER_MAXDSQ = 1600
local LARGE_PHYSICS_RADIUS_SQ = TUNING.GROTTO_POOL_BIG_RADIUS * TUNING.GROTTO_POOL_BIG_RADIUS
local SMALL_PHYSICS_RADIUS_SQ = TUNING.GROTTO_POOL_SMALL_RADIUS * TUNING.GROTTO_POOL_SMALL_RADIUS

local NUM_EMITTERS = 3

local LARGE_VOLUME = 1
local SMALL_VOLUME = 0.80
local MIN_FADE_VOLUME = 0.05
local HALF_FADE_TIME = 0.20

local WATERFALL_LOOP_SOUNDNAME = "grotto/common/waterfall_LP"
local SOUND_EVENT_NAME = "grotto_waterfall"

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _player = ThePlayer
local _process_task = nil
local _largepools = {}
local _smallpools = {}
local _soundemitters = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function pool_sortfn(pool1, pool2)
    return pool1[2] < pool2[2]
end

-- Generate a list of every pool (both big and small), sorted by dsq to ThePlayer.
-- Output array entries are {pool instance, dsq to player, is large}
local function get_pools_close_to_player_dsqsorted()
    local px, py, pz = _player.Transform:GetWorldPosition()

    local pools_with_dist = {}
    for pool, _ in pairs(_largepools) do
        local dsq_to_pool = pool:GetDistanceSqToPoint(px, py, pz) - LARGE_PHYSICS_RADIUS_SQ
        if dsq_to_pool < EMITTER_MAXDSQ then
            table.insert(pools_with_dist, {pool, dsq_to_pool, true})
        end
    end
    for pool, _ in pairs(_smallpools) do
        local dsq_to_pool = pool:GetDistanceSqToPoint(px, py, pz) - SMALL_PHYSICS_RADIUS_SQ
        if dsq_to_pool < EMITTER_MAXDSQ then
            table.insert(pools_with_dist, {pool, dsq_to_pool, false})
        end
    end

    table.sort(pools_with_dist, pool_sortfn)

    return pools_with_dist
end

-- Try to match our NUM_EMITTERS closest pools, to emitters already playing sounds on them.
-- Any that are unmatched go into a subtable at ["unclaimed"] (nil if unnecessary)
local function generate_emitter_pairs(pools_with_distances)
    local emitter_pairs = {}

    for i, pooldata in ipairs(pools_with_distances) do
        if i > NUM_EMITTERS then
            break
        end

        local paired = false
        for _, emitter in ipairs(_soundemitters) do
            if emitter._lastpooldata ~= nil and emitter._lastpooldata[1] == pooldata[1] then
                paired = true
                emitter_pairs[emitter] = pooldata
                break
            end
        end

        if not paired then
            if emitter_pairs["unclaimed"] == nil then
                emitter_pairs["unclaimed"] = {}
            end
            table.insert(emitter_pairs["unclaimed"], pooldata)
        end
    end

    return emitter_pairs
end

local function is_valid_data(data)
    return data ~= nil and data[1] ~= nil and data[1]:IsValid()
end

local function FadeUpdate(val, e)
    e.SoundEmitter:SetVolume(SOUND_EVENT_NAME, val)
    e._volume = val
end

local function FadeFinished(e, val2)
    if is_valid_data(e._lastpooldata) then
        e.Transform:SetPosition(e._lastpooldata[1].Transform:GetWorldPosition())
        e.components.fader:Fade(MIN_FADE_VOLUME, (e._lastpooldata[3] and LARGE_VOLUME) or SMALL_VOLUME, HALF_FADE_TIME, FadeUpdate)
    end
end

local function ProcessPlayer()
    if _player == nil or not _player:IsValid() then
        _player = ThePlayer
    end
    if _player == nil or not _player:IsValid() then
        return
    end

    local pools_with_distances = get_pools_close_to_player_dsqsorted()

    local emitter_pairs = generate_emitter_pairs(pools_with_distances)

    for _, emitter in ipairs(_soundemitters) do
        if emitter_pairs[emitter] == nil then
            local new_pool_data = (emitter_pairs["unclaimed"] ~= nil and table.remove(emitter_pairs["unclaimed"])) or nil

            if new_pool_data == nil then
                emitter.SoundEmitter:KillAllSounds()
                emitter._lastpooldata = nil
                emitter._volume = 0
            elseif not emitter.SoundEmitter:PlayingSound(SOUND_EVENT_NAME) or not is_valid_data(emitter._lastpooldata) then
                emitter.Transform:SetPosition(new_pool_data[1].Transform:GetWorldPosition())

                local volume = (new_pool_data[3] and LARGE_VOLUME) or SMALL_VOLUME
                emitter.SoundEmitter:PlaySound(WATERFALL_LOOP_SOUNDNAME, SOUND_EVENT_NAME, volume)
                emitter._volume = volume

                emitter._lastpooldata = new_pool_data
            else
                local old_volume = emitter._volume or (emitter._lastpooldata[3] and LARGE_VOLUME) or SMALL_VOLUME

                emitter._lastpooldata = new_pool_data

                emitter.components.fader:StopAll()
                emitter.components.fader:Fade(old_volume, MIN_FADE_VOLUME, HALF_FADE_TIME, FadeUpdate, FadeFinished)
            end
        end
    end
end

local function StopTrackingPool(pool)
    self.inst:RemoveEventCallback("onremove", StopTrackingPool, pool)

    if _smallpools[pool] ~= nil then
        _smallpools[pool] = nil
    elseif _largepools[pool] ~= nil then
        _largepools[pool] = nil
    end
end

local function TrackPool(inst, data)
    local pool = data.pool
    if pool ~= nil then
        if data.small and not _smallpools[pool] then
            _smallpools[pool] = true
        elseif not data.small and not _largepools[pool] then
            _largepools[pool] = true
        end

        self.inst:ListenForEvent("onremove", StopTrackingPool, pool)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("ms_registergrottopool", TrackPool)

--Initialize
local init_task = inst:DoTaskInTime(0, function(i)
    for _ = 1, NUM_EMITTERS do
        table.insert(_soundemitters, SpawnPrefab("grottopool_sfx"))
    end
end)
_process_task = inst:DoPeriodicTask(5*FRAMES, ProcessPlayer)

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local num_largepools = GetTableSize(_largepools)
    local num_smallpools = GetTableSize(_smallpools)

    local emitters_playing = 0
    for _, emitter in ipairs(_soundemitters) do
        if emitter.SoundEmitter:PlayingSound(SOUND_EVENT_NAME) then
            emitters_playing = emitters_playing + 1
        end
    end

    return string.format("Large Pool Count: %d || Small Pool Count: %d || Emitters Playing: %d",
        num_largepools, num_smallpools, emitters_playing)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
