--------------------------------------------------------------------------
--[[ WorldTemperature class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NOISE_SYNC_PERIOD = 30

--------------------------------------------------------------------------
--[[ Temperature constants ]]
--------------------------------------------------------------------------

local TEMPERATURE_NOISE_SCALE = .025
local TEMPERATURE_NOISE_MAG = 8

local MIN_TEMPERATURE = -25
local MAX_TEMPERATURE = 95
local WINTER_CROSSOVER_TEMPERATURE = 5
local SUMMER_CROSSOVER_TEMPERATURE = 55

local PHASE_TEMPERATURES =
{
    day = 5,
    night = -6,
}

--------------------------------------------------------------------------
--[[ Lighting (not LightNING) constants ]]
--------------------------------------------------------------------------

local SUMMER_BLOOM_BASE = 0.15   -- base amount of bloom applied during the day
local SUMMER_BLOOM_TEMP_MODIFIER = 0.10 / TUNING.DAY_HEAT   -- amount that the daily temp. variation factors into the overall bloom
local SUMMER_BLOOM_PERIOD_MIN = 5 -- min length of the bloom fluctuation period
local SUMMER_BLOOM_PERIOD_MAX = 10 -- max length of the bloom fluctuation period

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _map = _world.Map
local _ismastersim = _world.ismastersim

--Temperature
local _seasontemperature
local _phasetemperature
local _globaltemperaturemult = 1
local _globaltemperaturelocus = 0

--Light
local _daylight = true
local _season = "autumn"

local _summerblooming = false
local _summerbloom_modifier = 0
local _summerbloom_current_time = 0
local _summerbloom_time_to_new_modifier = 0
local _summerbloom_ramp = 0
local _summerbloom_ramp_time = 5

--Network
local _noisetime = net_float(inst.GUID, "worldtemperature._noisetime")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SetWithPeriodicSync(netvar, val, period, ismastersim)
    if netvar:value() ~= val then
        local trunc = val > netvar:value() and "floor" or "ceil"
        local prevperiod = math[trunc](netvar:value() / period)
        local nextperiod = math[trunc](val / period)

        if prevperiod == nextperiod then
            --Client and server update independently within current period
            netvar:set_local(val)
        elseif ismastersim then
            --Server sync to client when period changes
            netvar:set(val)
        else
            --Client must wait at end of period for a server sync
            netvar:set_local(nextperiod * period)
        end
    elseif ismastersim then
        --Force sync when value stops changing
        netvar:set(val)
    end
end

local ForceResync = _ismastersim and function(netvar)
    netvar:set_local(netvar:value())
    netvar:set(netvar:value())
end or nil

local function CalculateSeasonTemperature(season, progress)
    return (season == "winter" and math.sin(PI * progress) * (MIN_TEMPERATURE - WINTER_CROSSOVER_TEMPERATURE) + WINTER_CROSSOVER_TEMPERATURE)
        or (season == "spring" and Lerp(WINTER_CROSSOVER_TEMPERATURE, SUMMER_CROSSOVER_TEMPERATURE, progress))
        or (season == "summer" and math.sin(PI * progress) * (MAX_TEMPERATURE - SUMMER_CROSSOVER_TEMPERATURE) + SUMMER_CROSSOVER_TEMPERATURE)
        or Lerp(SUMMER_CROSSOVER_TEMPERATURE, WINTER_CROSSOVER_TEMPERATURE, progress)
end

local function CalculatePhaseTemperature(phase, timeinphase)
    return PHASE_TEMPERATURES[phase] ~= nil and PHASE_TEMPERATURES[phase] * math.sin(timeinphase * PI) or 0
end

local function CalculateTemperature()
    local temperaturenoise = 2 * TEMPERATURE_NOISE_MAG * perlin(0, 0, _noisetime:value() * TEMPERATURE_NOISE_SCALE) - TEMPERATURE_NOISE_MAG
    return (((temperaturenoise + _seasontemperature + _phasetemperature) - _globaltemperaturelocus) * _globaltemperaturemult) + _globaltemperaturelocus
end

local function CalculateSummerBloom(dt)
    -- Update summer blooming
    if _daylight and _season == "summer" then
        _summerblooming = true
        _summerbloom_ramp = math.min(_summerbloom_ramp + dt / _summerbloom_ramp_time, 1)
    elseif _summerblooming then
        -- turn off the bloom out of summer
        _summerbloom_ramp = math.max(_summerbloom_ramp - dt / _summerbloom_ramp_time, 0)
        -- print("Killing off the summer bloom",_season,_daylight and "day" or "night",_summerbloom_ramp)
    else
        return
    end

    _summerbloom_current_time = _summerbloom_current_time + dt

    if _summerbloom_ramp <= 0 then
        _summerblooming = false
        _summerbloom_modifier = 0
        _summerbloom_time_to_new_modifier = 0
        _summerbloom_current_time = 0
        -- print("Turning off the summer bloom")
        return
    end

    if _summerbloom_time_to_new_modifier <= _summerbloom_current_time then
        -- start up the next throb
        local new_period = math.random(SUMMER_BLOOM_PERIOD_MIN, SUMMER_BLOOM_PERIOD_MAX)
        _summerbloom_modifier = 2 * PI / new_period
        _summerbloom_time_to_new_modifier = new_period
        _summerbloom_current_time = 0
        -- print("New Summer bloom phase",_summerbloom_time_to_new_modifier)
    end
    -- This is essentially a sine wave [sin(x - pi/2) = 1 - cos(x)] with amplitude 0 - 1, shifted to the left so that the magnitude is zero at time zero
    -- The result is multiplied to a combination of a base intensity value and a time-of-day temperature dependant value
    -- Finally we add this to the original intensity (1.0) so that we're always increasing the total intensity
    return 1 + _summerbloom_ramp * (1 - .5 * math.cos(_summerbloom_current_time * _summerbloom_modifier)) * (SUMMER_BLOOM_BASE + SUMMER_BLOOM_TEMP_MODIFIER * _phasetemperature)
end

local function UpdateSummerBloom(dt)
    local bloomval = CalculateSummerBloom(dt)
    _world:PushEvent("overridecolourmodifier", bloomval)
end

local function PushTemperature()
    local data = CalculateTemperature()
    _world:PushEvent("temperaturetick", data)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonTick(src, data)
    _seasontemperature = CalculateSeasonTemperature(data.season, data.progress)
    _season = data.season
    --_seasonprogress = data.progress
end

local function OnClockTick(src, data)
    _phasetemperature = CalculatePhaseTemperature(data.phase, data.timeinphase)
end

local function OnPhaseChanged(src, phase)
    _daylight = phase == "day"
end

local OnSimUnpaused = _ismastersim and function()
    --Force resync values that client may have simulated locally
    ForceResync(_noisetime)
end or nil

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetTemperatureMod(multiplier, locus)
    _globaltemperaturemult = multiplier
    _globaltemperaturelocus = locus
    PushTemperature()
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

_seasontemperature = CalculateSeasonTemperature(_season, .5)
_phasetemperature = CalculatePhaseTemperature(_daylight and "day" or "dusk", 0)

--Initialize network variables
_noisetime:set(0)

--Register events
inst:ListenForEvent("seasontick", OnSeasonTick, _world)
inst:ListenForEvent("clocktick", OnClockTick, _world)
inst:ListenForEvent("phasechanged", OnPhaseChanged, _world)

if _ismastersim then
    --Register master simulation events
    inst:ListenForEvent("ms_simunpaused", OnSimUnpaused, _world)
end

PushTemperature()
inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

--[[
    Client updates temperature, moisture, precipitation effects, and snow
    level on its own while server force syncs values periodically. Client
    cannot start, stop, or change precipitation on its own, and must wait
    for server syncs to trigger these events.
--]]
function self:OnUpdate(dt)
    --Update noise
    SetWithPeriodicSync(_noisetime, _noisetime:value() + dt, NOISE_SYNC_PERIOD, _ismastersim)

    UpdateSummerBloom(dt)

    PushTemperature()
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    return
    {
        daylight = _daylight or nil,
        season = _season,
        seasontemperature = _seasontemperature,
        phasetemperature = _phasetemperature,
        noisetime = _noisetime:value(),
    }
end end

if _ismastersim then function self:OnLoad(data)
    _daylight = data.daylight == true
    _season = data.season or "autumn"
    _seasontemperature = data.seasontemperature or CalculateSeasonTemperature(_season, .5)
    _phasetemperature = data.phasetemperature or CalculatePhaseTemperature(_daylight and "day" or "dusk", 0)
    _noisetime:set(data.noisetime or 0)

    PushTemperature()
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local temperature = CalculateTemperature()
    return string.format("%2.2fC mult: %.2f locus %.1f", temperature, _globaltemperaturemult, _globaltemperaturelocus)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
