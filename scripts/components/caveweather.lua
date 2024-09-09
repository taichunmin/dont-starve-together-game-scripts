--------------------------------------------------------------------------
--[[ Weather class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NOISE_SYNC_PERIOD = 30

--------------------------------------------------------------------------
--[[ Precipitation constants ]]
--------------------------------------------------------------------------

local PRECIP_MODE_NAMES =
{
    "dynamic",
    "always",
    "never",
}
local PRECIP_MODES = table.invert(PRECIP_MODE_NAMES)

local PRECIP_TYPE_NAMES =
{
    "none",
    "rain",
    "acidrain",
}
local PRECIP_TYPES = table.invert(PRECIP_TYPE_NAMES)

local PRECIP_RATE_SCALE = 10
local MIN_PRECIP_RATE = .1
local MOISTURE_RATES = {
    MIN = {
        autumn = .25,
        winter = .25,
        spring = 3,
        summer = .1,
    },
    MAX = {
        autumn = 1.0,
        winter = 1.0,
        spring = 3.75,
        summer = .5,
    }
}
local MOISTURE_SYNC_PERIOD = 100

local MOISTURE_CEIL_MULTIPLIERS =
{
    autumn = 8,
    winter = 3,
    spring = 5.5,
    summer = 13,
}

local MOISTURE_FLOOR_MULTIPLIERS =
{
    autumn = 1,
    winter = 1,
    spring = 0.25,
    summer = 1.5,
}


local GROUND_OVERLAYS =
{
    puddles =
    {
        texture = "levels/textures/mud.tex",
        colour =
        {
            { 11 / 255, 15 / 255, 23 / 255, .3 },
            { 11 / 255, 15 / 255, 23 / 255, .2 },
            { 11 / 255, 15 / 255, 23 / 255, .12 },
        },
    },
}

local PEAK_PRECIPITATION_RANGES =
{
    autumn = { min = .10, max = .66 },
    winter = { min = .10, max = .80 },
    spring = { min = .50, max = 1.00 },
    summer = { min = 1.0, max = 1.0 },
}

--------------------------------------------------------------------------
--[[ Wetness constants ]]
--------------------------------------------------------------------------

local DRY_THRESHOLD = TUNING.MOISTURE_DRY_THRESHOLD
local WET_THRESHOLD = TUNING.MOISTURE_WET_THRESHOLD
local MIN_WETNESS = 0
local MAX_WETNESS = TUNING.MAX_WETNESS
local MIN_WETNESS_RATE = 0
local MAX_WETNESS_RATE = .75
local MIN_DRYING_RATE = 0
local MAX_DRYING_RATE = .3
local OPTIMAL_DRYING_TEMPERATURE = 70
local WETNESS_SYNC_PERIOD = 10

--------------------------------------------------------------------------
--[[ Lighting (not LightNING) constants ]]
--------------------------------------------------------------------------

local SEASON_DYNRANGE_DAY = {
    autumn = .4,
    winter = .05,
    spring = .4,
    summer = .7,
}

local SEASON_DYNRANGE_NIGHT = {
    autumn = .25,
    winter = 0,
    spring = .25,
    summer = .5,
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _map = _world.Map
local _ismastersim = _world.ismastersim
local _activatedplayer = nil

--Temperature cache
local _temperature = TUNING.STARTING_TEMP

--Precipiation
local _rainsound = false
local _treerainsound = nil
local _umbrellarainsound = false
local _barriersound = false
local _seasonprogress = 0
local _groundoverlay = nil

--Dedicated server does not need to spawn the local fx
local _hasfx = not TheNet:IsDedicated()
local _rainfx = _hasfx and SpawnPrefab("caverain") or nil
local _acidrainfx = _hasfx and SpawnPrefab("caveacidrain") or nil
local _acidrainfx_allowsfx = true

--Light
local _daylight = true
local _season = "autumn"

--Master simulation
local _moisturerateval
local _moisturerateoffset
local _moistureratemultiplier
local _moistureceilmultiplier
local _moisturefloormultiplier

--Network
local _noisetime = net_float(inst.GUID, "weather._noisetime")
local _moisture = net_float(inst.GUID, "weather._moisture")
local _moisturerate = net_float(inst.GUID, "weather._moisturerate")
local _moistureceil = net_float(inst.GUID, "weather._moistureceil", "moistureceildirty")
local _moisturefloor = net_float(inst.GUID, "weather._moisturefloor")
local _precipmode = net_tinybyte(inst.GUID, "weather._precipmode")
local _preciptype = net_tinybyte(inst.GUID, "weather._preciptype", "preciptypedirty")
local _peakprecipitationrate = net_float(inst.GUID, "weather._peakprecipitationrate")
local _wetness = net_float(inst.GUID, "weather._wetness")
local _wet = net_bool(inst.GUID, "weather._wet", "wetdirty")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function StartAmbientRainSound(intensity)
    if not _rainsound then
        _rainsound = true
        _world.SoundEmitter:PlaySound("dontstarve/AMB/caves/rain", "rain")
    end
    _world.SoundEmitter:SetParameter("rain", "intensity", intensity)
end

local function StopAmbientRainSound()
    if _rainsound then
        _rainsound = false
        _world.SoundEmitter:KillSound("rain")
    end
end

--V2C: hack to loop the tree rain sound without having to change the sound data :O
local function DoTreeRainSound(inst, soundemitter)
    --Intentionally (lazy) not caring if we kill a sound that isn't still playing.
    --Log spams should also be disabled for that.
    soundemitter:KillSound("treerainsound")
    soundemitter:PlaySound("dontstarve_DLC001/common/rain_on_tree", "treerainsound")
end

local function StartTreeRainSound()
    if _treerainsound == nil then
        _treerainsound = inst:DoPeriodicTask(19, DoTreeRainSound, 0, TheFocalPoint.SoundEmitter)
    end
end

local function StopTreeRainSound()
    if _treerainsound ~= nil then
        _treerainsound:Cancel()
        _treerainsound = nil
        TheFocalPoint.SoundEmitter:KillSound("treerainsound")
    end
end

local function StartUmbrellaRainSound()
    if not _umbrellarainsound then
        _umbrellarainsound = true
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/cave/cave_rain_on_umbrella", "umbrellarainsound")
    end
end

local function StopUmbrellaRainSound()
    if _umbrellarainsound then
        _umbrellarainsound = false
        TheFocalPoint.SoundEmitter:KillSound("umbrellarainsound")
    end
end

local function StartBarrierSound()
	if not _barriersound then
		_barriersound = true
		TheFocalPoint.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_amb", "barriersound")
	end
end

local function StopBarrierSound()
	if _barriersound then
		_barriersound = false
		TheFocalPoint.SoundEmitter:KillSound("barriersound")
	end
end

local function SetGroundOverlay(overlay, level)
    if _groundoverlay ~= overlay then
        _groundoverlay = overlay
        _map:SetOverlayTexture(overlay.texture)
        _map:SetOverlayColor0(unpack(overlay.colour[1]))
        _map:SetOverlayColor1(unpack(overlay.colour[2]))
        _map:SetOverlayColor2(unpack(overlay.colour[3]))
    end
    _map:SetOverlayLerp(level)
end

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

local CalculateMoistureRate = _ismastersim and function()
    return _moisturerateval * _moistureratemultiplier + _moisturerateoffset
end or nil

local RandomizeMoistureCeil = _ismastersim and function()
    return (1 + math.random()) * TUNING.TOTAL_DAY_TIME * _moistureceilmultiplier
end or nil

local RandomizeMoistureFloor = _ismastersim and function(season)
    return (.25 + math.random() * .5) * _moisture:value() * _moisturefloormultiplier
end or nil

local RandomizePeakPrecipitationRate = _ismastersim and function(season)
    local range = PEAK_PRECIPITATION_RANGES[season]
    return range.min + math.random() * (range.max-range.min)
end or nil

local function CalculatePrecipitationRate()
    if _precipmode:value() == PRECIP_MODES.always then
        return .1 + perlin(0, _noisetime:value() * .1, 0) * .9
    elseif _preciptype:value() ~= PRECIP_TYPES.none and _precipmode:value() ~= PRECIP_MODES.never then
        local p = math.max(0, math.min(1, (_moisture:value() - _moisturefloor:value()) / (_moistureceil:value() - _moisturefloor:value())))
        local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)
        return math.min(rate, _peakprecipitationrate:value())
    end
    return 0
end

local StartPrecipitation = _ismastersim and function(temperature)
    _moisture:set(_moistureceil:value())
    _moisturefloor:set(RandomizeMoistureFloor(_season))
    _peakprecipitationrate:set(RandomizePeakPrecipitationRate(_season))
    local riftspawner = _world.components.riftspawner
    if TUNING.ACIDRAIN_ENALBED and riftspawner and riftspawner:IsShadowPortalActive() then
        _preciptype:set(PRECIP_TYPES.acidrain)
    else
        _preciptype:set(PRECIP_TYPES.rain)
    end
end or nil

local StopPrecipitation = _ismastersim and function()
    _moisture:set(_moisturefloor:value())
    _moistureceil:set(RandomizeMoistureCeil())
    _preciptype:set(PRECIP_TYPES.none)
end or nil

local function CalculatePOP()
    return (_preciptype:value() ~= PRECIP_TYPES.none and 1)
        or ((_moistureceil:value() <= 0 or _moisture:value() <= _moisturefloor:value()) and 0)
        or (_moisture:value() < _moistureceil:value() and (_moisture:value() - _moisturefloor:value()) / (_moistureceil:value() - _moisturefloor:value()))
        or 1
end

local function CalculateWetnessRate(temperature, preciprate)
    return --Positive wetness rate when it's raining
        (_preciptype:value() == PRECIP_TYPES.rain and easing.inSine(preciprate, MIN_WETNESS_RATE, MAX_WETNESS_RATE, 1))
        --Negative drying rate when it's not raining
        or -math.clamp(easing.linear(temperature, MIN_DRYING_RATE, MAX_DRYING_RATE, OPTIMAL_DRYING_TEMPERATURE)
                    + easing.inExpo(_wetness:value(), 0, 1, MAX_WETNESS),
                    .01, 1)
end

local function PushWeather()
    local data =
    {
        moisture = _moisture:value(),
        pop = CalculatePOP(),
        precipitationrate = CalculatePrecipitationRate(),
        snowlevel = 0,
        wetness = _wetness:value(),
        light = 1,
    }
    _world:PushEvent("weathertick", data)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonTick(src, data)
    _season = data.season
    _seasonprogress = data.progress

    if _ismastersim then
        local p = 1 - math.sin(PI * data.progress)
        _moisturerateval = MOISTURE_RATES.MIN[_season] + p * (MOISTURE_RATES.MAX[_season] - MOISTURE_RATES.MIN[_season])
        _moisturerateoffset = 0

        _moisturerate:set(CalculateMoistureRate())
        _moistureceilmultiplier = MOISTURE_CEIL_MULTIPLIERS[_season] or MOISTURE_CEIL_MULTIPLIERS.autumn
        _moisturefloormultiplier = MOISTURE_FLOOR_MULTIPLIERS[_season] or MOISTURE_FLOOR_MULTIPLIERS.autumn
    end
end

local function OnTemperatureTick(src, temperature)
    _temperature = temperature
end

local function OnPhaseChanged(src, phase)
    _daylight = phase == "day"
end

local function OnChangeArea_fx(inst, area)
    if area == nil or area.tags == nil then
        _acidrainfx_allowsfx = false
    else
        _acidrainfx_allowsfx = _map:CanAreaTagsHaveAcidRain(area.tags)
    end
end

local function OnPlayerActivated(src, player)
    _activatedplayer = player
    if _hasfx then
        _rainfx.entity:SetParent(player.entity)
        _acidrainfx.entity:SetParent(player.entity)
        self:OnPostInit()
        player:ListenForEvent("changearea", OnChangeArea_fx)
    end
end

local function OnPlayerDeactivated(src, player)
    if _activatedplayer == player then
        _activatedplayer = nil
    end
    if _hasfx then
        _rainfx.entity:SetParent(nil)
        _acidrainfx.entity:SetParent(nil)
        player:RemoveEventCallback("changearea", OnChangeArea_fx)
    end
end
if _ismastersim then
    local function OnChangeArea_logic(inst, area)
        local acidlevel = inst.components.acidlevel
        if acidlevel then
            if area == nil or area.tags == nil then
                acidlevel:SetIgnoreAcidRainTicks(false)
            else
                acidlevel:SetIgnoreAcidRainTicks(not _map:CanAreaTagsHaveAcidRain(area.tags))
            end
        end
    end
    local function OnPlayerJoined(world, player)
        local areaaware = player.components.areaaware
        if areaaware then
            player:ListenForEvent("changearea", OnChangeArea_logic)
            OnChangeArea_logic(player, areaaware:GetCurrentArea())
        end
    end
    local function OnPlayerLeft(world, player)
        player:RemoveEventCallback("changearea", OnChangeArea_logic)
    end
    _world:ListenForEvent("ms_playerjoined", OnPlayerJoined)
    _world:ListenForEvent("ms_playerleft", OnPlayerLeft)
end

local OnForcePrecipitation = _ismastersim and function(src, enable)
    _moisture:set(enable ~= false and _moistureceil:value() or _moisturefloor:value())
end or nil

local OnSetPrecipitationMode = _ismastersim and function(src, mode)
    _precipmode:set(PRECIP_MODES[mode] or _precipmode:value())
end or nil

local OnSetMoistureScale = _ismastersim and function(src, data)
    _moistureratemultiplier = data or _moistureratemultiplier
    _moisturerate:set(CalculateMoistureRate())
end or nil

local OnDeltaMoisture = _ismastersim and function(src, delta)
    _moisture:set(math.min(math.max(_moisture:value() + delta, _moisturefloor:value()), _moistureceil:value()))
end or nil

local OnDeltaMoistureCeil = _ismastersim and function(src, delta)
    _moistureceil:set(math.max(_moistureceil:value() + delta, _moisturefloor:value()))
end or nil

local OnDeltaWetness = _ismastersim and function(src, delta)
    _wetness:set(math.clamp(_wetness:value() + delta, MIN_WETNESS, MAX_WETNESS))
end or nil

local OnSimUnpaused = _ismastersim and function()
    --Force resync values that client may have simulated locally
    ForceResync(_noisetime)
    ForceResync(_moisture)
    ForceResync(_wetness)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_noisetime:set(0)
_moisture:set(0)
_moisturerate:set(0)
_moistureceil:set(0)
_moisturefloor:set(0)
_precipmode:set(PRECIP_MODES.dynamic)
_preciptype:set(PRECIP_TYPES.none)
_peakprecipitationrate:set(1)
_wetness:set(0)
_wet:set(false)

--Dedicated server does not need to spawn the local fx
if _hasfx then
    --Initialize rain particles
    _rainfx.particles_per_tick = 0
    _rainfx.splashes_per_tick = 0
    _acidrainfx.particles_per_tick = 0
    _acidrainfx.splashes_per_tick = 0
end

--Register network variable sync events
inst:ListenForEvent("moistureceildirty", function()
    _world:PushEvent("moistureceilchanged", _moistureceil:value())
end)
inst:ListenForEvent("preciptypedirty", function()
    _world:PushEvent("precipitationchanged", PRECIP_TYPE_NAMES[_preciptype:value()])
end)
inst:ListenForEvent("wetdirty", function()
    _world:PushEvent("wetchanged", _wet:value())
end)

--Register events
inst:ListenForEvent("seasontick", OnSeasonTick, _world)
inst:ListenForEvent("temperaturetick", OnTemperatureTick, _world)
inst:ListenForEvent("phasechanged", OnPhaseChanged, _world)
inst:ListenForEvent("playeractivated", OnPlayerActivated, _world)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, _world)

if _ismastersim then
    --Initialize master simulation variables
    _moisturerateval = 1
    _moisturerateoffset = 0
    _moistureratemultiplier = 1
    _moistureceilmultiplier = 1
    _moisturefloormultiplier = 1

    _moisturerate:set(CalculateMoistureRate())
    _moistureceil:set(RandomizeMoistureCeil())

    --Register master simulation events
    inst:ListenForEvent("ms_forceprecipitation", OnForcePrecipitation, _world)
    inst:ListenForEvent("ms_setprecipitationmode", OnSetPrecipitationMode, _world)
    inst:ListenForEvent("ms_setmoisturescale", OnSetMoistureScale, _world)
    inst:ListenForEvent("ms_deltamoisture", OnDeltaMoisture, _world)
    inst:ListenForEvent("ms_deltamoistureceil", OnDeltaMoistureCeil, _world)
    inst:ListenForEvent("ms_deltawetness", OnDeltaWetness, _world)
    inst:ListenForEvent("ms_simunpaused", OnSimUnpaused, _world)
end

PushWeather()
inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

if _hasfx then function self:OnPostInit()
    if _preciptype:value() == PRECIP_TYPES.rain then
        _rainfx:PostInit()
    elseif _preciptype:value() == PRECIP_TYPES.acidrain then
        _acidrainfx:PostInit()
    end
end end

--------------------------------------------------------------------------
--[[ Deinitialization ]]
--------------------------------------------------------------------------

if _hasfx then function self:OnRemoveEntity()
    if _rainfx.entity:IsValid() then
        _rainfx:Remove()
    end
    if _acidrainfx.entity:IsValid() then
        _acidrainfx:Remove()
    end
end end

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

    local preciprate = CalculatePrecipitationRate()

    --Update moisture and toggle precipitation
    if _precipmode:value() == PRECIP_MODES.always then
        if _ismastersim and _preciptype:value() == PRECIP_TYPES.none then
            StartPrecipitation(_temperature)
        end
    elseif _precipmode:value() == PRECIP_MODES.never then
        if _ismastersim and _preciptype:value() ~= PRECIP_TYPES.none then
            StopPrecipitation()
        end
    elseif _preciptype:value() ~= PRECIP_TYPES.none then
        --Dissipate moisture
        local moisture = math.max(_moisture:value() - preciprate * dt * PRECIP_RATE_SCALE, 0)
        if moisture <= _moisturefloor:value() then
            if _ismastersim then
                StopPrecipitation()
            else
                _moisture:set_local(math.min(_moisturefloor:value() + .001, _moisture:value()))
            end
        else
            SetWithPeriodicSync(_moisture, moisture, MOISTURE_SYNC_PERIOD, _ismastersim)
        end
    elseif _moistureceil:value() > 0 then
        --Accumulate moisture
        local moisture = _moisture:value() + _moisturerate:value() * dt
        if moisture >= _moistureceil:value() then
            if _ismastersim then
                StartPrecipitation(_temperature)
            else
                _moisture:set_local(math.max(_moistureceil:value() - .001, _moisture:value()))
            end
        else
            SetWithPeriodicSync(_moisture, moisture, MOISTURE_SYNC_PERIOD, _ismastersim)
        end
    end

    --Update wetness
    local wetrate = CalculateWetnessRate(_temperature, preciprate)
    SetWithPeriodicSync(_wetness, math.clamp(_wetness:value() + wetrate * dt, MIN_WETNESS, MAX_WETNESS), WETNESS_SYNC_PERIOD, _ismastersim)
    if _ismastersim then
        if _wet:value() then
            if _wetness:value() < DRY_THRESHOLD then
                _wet:set(false)
            end
        elseif _wetness:value() > WET_THRESHOLD then
            _wet:set(true)
        end
    end

    --Update precipitation effects
    if _preciptype:value() == PRECIP_TYPES.none then
        StopAmbientRainSound()
        StopTreeRainSound()
        StopUmbrellaRainSound()
		if _activatedplayer ~= nil and _activatedplayer.components.raindomewatcher ~= nil and _activatedplayer.components.raindomewatcher:IsUnderRainDome() then
			StartBarrierSound()
		else
			StopBarrierSound()
		end
        if _hasfx then
            _rainfx.particles_per_tick = 0
            _rainfx.splashes_per_tick = 0
            _acidrainfx.particles_per_tick = 0
            _acidrainfx.splashes_per_tick = 0
        end
    elseif _preciptype:value() == PRECIP_TYPES.rain or _preciptype:value() == PRECIP_TYPES.acidrain then
        local preciprate_sound = preciprate
        if _activatedplayer == nil then
            StopTreeRainSound()
            StopUmbrellaRainSound()
			StopBarrierSound()
		elseif _activatedplayer.components.raindomewatcher ~= nil and _activatedplayer.components.raindomewatcher:IsUnderRainDome() then
			StopTreeRainSound()
			StopUmbrellaRainSound()
			StartBarrierSound()
			preciprate_sound = math.min(.1, preciprate_sound * .5)
        elseif _activatedplayer.replica.sheltered ~= nil and _activatedplayer.replica.sheltered:IsSheltered() then
            if _acidrainfx_allowsfx then
                StartTreeRainSound()
            else
                StopTreeRainSound()
            end
            StopUmbrellaRainSound()
			StopBarrierSound()
			preciprate_sound = preciprate_sound - .4
        else
            StopTreeRainSound()
			StopBarrierSound()
            if _acidrainfx_allowsfx and _activatedplayer.replica.inventory:EquipHasTag("umbrella") then
                preciprate_sound = preciprate_sound - .4
                StartUmbrellaRainSound()
            else
                StopUmbrellaRainSound()
            end
        end
		if _acidrainfx_allowsfx and preciprate_sound > 0 then
			StartAmbientRainSound(preciprate_sound)
		else
			StopAmbientRainSound()
		end
        if _hasfx then
            if _preciptype:value() == PRECIP_TYPES.rain then
                _rainfx.particles_per_tick = 5 * preciprate
                _rainfx.splashes_per_tick = 2 * preciprate
                _acidrainfx.particles_per_tick = 0
                _acidrainfx.splashes_per_tick = 0
            else
                _rainfx.particles_per_tick = 0
                _rainfx.splashes_per_tick = 0
                _acidrainfx.particles_per_tick = 5 * preciprate
                _acidrainfx.splashes_per_tick = 2 * preciprate
            end
        end
    end

    SetGroundOverlay(GROUND_OVERLAYS.puddles, _wetness:value() * 3 / 100)

    PushWeather()
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    return
    {
        temperature = _temperature,
        daylight = _daylight or nil,
        season = _season,
        noisetime = _noisetime:value(),
        moisturerateval = _moisturerateval,
        moisturerateoffset = _moisturerateoffset,
        moistureratemultiplier = _moistureratemultiplier,
        moisturerate = _moisturerate:value(),
        moisture = _moisture:value(),
        moisturefloor = _moisturefloor:value(),
        moistureceilmultiplier = _moistureceilmultiplier,
        moisturefloormultiplier = _moisturefloormultiplier,
        moistureceil = _moistureceil:value(),
        precipmode = PRECIP_MODE_NAMES[_precipmode:value()],
        preciptype = PRECIP_TYPE_NAMES[_preciptype:value()],
        peakprecipitationrate = _peakprecipitationrate:value(),
        wetness = _wetness:value(),
        wet = _wet:value() or nil,
    }
end end

if _ismastersim then function self:OnLoad(data)
    _temperature = data.temperature or TUNING.STARTING_TEMP
    _daylight = data.daylight == true
    _season = data.season or "autumn"
    _noisetime:set(data.noisetime or 0)
    _moisturerateval = data.moisturerateval or 1
    _moisturerateoffset = data.moisturerateoffset or 0
    _moistureratemultiplier = data.moistureratemultiplier or 1
    _moisturerate:set(data.moisturerate or CalculateMoistureRate())
    _moisture:set(data.moisture or 0)
    _moisturefloor:set(data.moisturefloor or 0)
    _moistureceilmultiplier = data.moistureceilmultiplier or 1
    _moisturefloormultiplier = data.moisturefloormultiplier or 1
    _moistureceil:set(data.moistureceil or RandomizeMoistureCeil())
    _precipmode:set(PRECIP_MODES[data.precipmode] or PRECIP_MODES.dynamic)
    _preciptype:set(PRECIP_TYPES[data.preciptype] or PRECIP_TYPES.none)
    _peakprecipitationrate:set(data.peakprecipitationrate or 1)
    _wetness:set(data.wetness or 0)
    _wet:set(data.wet == true)

    PushWeather()
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local preciprate = CalculatePrecipitationRate()
    local wetrate = CalculateWetnessRate(_temperature, preciprate)
    local str =
    {
        string.format("temperature:%2.2f",_temperature),
        string.format("moisture:%2.2f(%2.2f/%2.2f) + %2.2f", _moisture:value(), _moisturefloor:value(), _moistureceil:value(), _moisturerate:value()),
        string.format("preciprate:(%2.2f of %2.2f)", preciprate, _peakprecipitationrate:value()),
        string.format("wetness:%2.2f(%s%2.2f)%s", _wetness:value(), wetrate > 0 and "+" or "", wetrate, _wet:value() and " WET" or ""),
    }

    return table.concat(str, ", ")
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)

