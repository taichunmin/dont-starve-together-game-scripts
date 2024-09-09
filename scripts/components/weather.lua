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
        "snow",
        "lunarhail",
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

    local SNOW_ACCUM_RATE = 1 / 300
    local SNOW_MELT_RATE = 1 / 20
    local MIN_SNOW_MELT_RATE = 1 / 120
    local SNOW_LEVEL_SYNC_PERIOD = .1

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

    local START_SNOW_THRESHOLDS =
    {
        autumn = -5,
        winter = 5,
        spring = -5,
        summer = -5,
    }

    local STOP_SNOW_THRESHOLDS =
    {
        autumn = 0,
        winter = 10,
        spring = 0,
        summer = 0,
    }

    local GROUND_OVERLAYS =
    {
        snow =
        {
            texture = "levels/textures/snow.tex",
            colour =
            {
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
                { 1, 1, 1, 1 },
            },
        },
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

    local POLLEN_PARTICLES = .5

    local SNOW_COVERED_THRESHOLD = .015

    local PEAK_PRECIPITATION_RANGES =
    {
        autumn = { min = .10, max = .66 },
        winter = { min = .10, max = .80 },
        spring = { min = .50, max = 1.00 },
        summer = { min = 1.0, max = 1.0 },
    }

    local LUNAR_HAIL_FLOOR = 0
    local LUNAR_HAIL_CEIL = 100

    local LUNAR_HAIL_EVENT_RATE = {
        COOLDOWN = LUNAR_HAIL_CEIL / TUNING.LUNARHAIL_EVENT_COOLDOWN,
        DURATION = LUNAR_HAIL_CEIL / TUNING.LUNARHAIL_EVENT_TIME,
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
    --[[ Lightning (not LightING) constants ]]
    --------------------------------------------------------------------------

    local LIGHTNING_MODE_NAMES =
    {
        "rain",
        "snow",
        "any",
        "always",
        "never",
    }
    local LIGHTNING_MODES = table.invert(LIGHTNING_MODE_NAMES)

    --------------------------------------------------------------------------
    --[[ Lighting (not LightNING) constants ]]
    --------------------------------------------------------------------------

    local SEASON_DYNRANGE_DAY = {
        autumn = .4,
        winter = .05,
        spring = .4,
        summer = .3,
    }

    local SEASON_DYNRANGE_NIGHT = { -- dusk and night
        autumn = .25,
        winter = 0,
        spring = .25,
        summer = .2,
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
	local _rainsound = nil
	local _treerainsound = nil
	local _umbrellarainsound = nil
    local _barriersound = false
    local _barriernorainsound = false
    local _seasonprogress = 0
    local _groundoverlay = nil

    --Dedicated server does not need to spawn the local fx
    local _hasfx = not TheNet:IsDedicated()
    local _rainfx = _hasfx and SpawnPrefab("rain") or nil
    local _snowfx = _hasfx and SpawnPrefab("snow") or nil
    local _pollenfx = _hasfx and SpawnPrefab("pollen") or nil
    local _lunarhailfx = _hasfx and SpawnPrefab("lunarhail") or nil

    --Light
    local _daylight = true
    local _season = "autumn"

    --Master simulation
    local _moisturerateval
    local _moisturerateoffset
    local _moistureratemultiplier
    local _moistureceilmultiplier
    local _moisturefloormultiplier
    local _startsnowthreshold
    local _stopsnowthreshold
    local _lightningmode
    local _minlightningdelay
    local _maxlightningdelay
    local _nextlightningtime
    local _lightningtargets
    local _lightningexcludetags

    --Network
    local _noisetime = net_float(inst.GUID, "weather._noisetime")
    local _moisture = net_float(inst.GUID, "weather._moisture")
    local _moisturerate = net_float(inst.GUID, "weather._moisturerate")
    local _moistureceil = net_float(inst.GUID, "weather._moistureceil", "moistureceildirty")
    local _moisturefloor = net_float(inst.GUID, "weather._moisturefloor")
    local _precipmode = net_tinybyte(inst.GUID, "weather._precipmode")
    local _preciptype = net_tinybyte(inst.GUID, "weather._preciptype", "preciptypedirty")
    local _peakprecipitationrate = net_float(inst.GUID, "weather._peakprecipitationrate")
    local _snowlevel = net_float(inst.GUID, "weather._snowlevel")
    local _lunarhaillevel = net_float(inst.GUID, "weather._lunarhaillevel")
    local _snowcovered = net_bool(inst.GUID, "weather._snowcovered", "snowcovereddirty")
    local _wetness = net_float(inst.GUID, "weather._wetness")
    local _wet = net_bool(inst.GUID, "weather._wet", "wetdirty")

    --------------------------------------------------------------------------
    --[[ Private member functions ]]
    --------------------------------------------------------------------------

    local function StartAmbientRainSound(intensity)
		local sound =
			_preciptype:value() == PRECIP_TYPES.lunarhail and
			"rifts3/lunarhail/lunar_rainAMB" or
			"dontstarve/AMB/rain"

		if _rainsound ~= sound then
			if _rainsound then
				_world.SoundEmitter:KillSound("rain")
			end
			_rainsound = sound
			_world.SoundEmitter:PlaySound(sound, "rain")
        end
        _world.SoundEmitter:SetParameter("rain", "intensity", intensity)
    end

    local function StopAmbientRainSound()
        if _rainsound then
			_rainsound = nil
            _world.SoundEmitter:KillSound("rain")
        end
    end

    local function StartTreeRainSound(intensity)
		local sound =
			_preciptype:value() == PRECIP_TYPES.lunarhail and
			"rifts3/lunarhail/lunarhail_on_tree" or
			"dontstarve_DLC001/common/rain_on_tree"

		if _treerainsound ~= sound then
			if _treerainsound then
				TheFocalPoint.SoundEmitter:KillSound("treerainsound")
			end
			_treerainsound = sound
			TheFocalPoint.SoundEmitter:PlaySound(sound, "treerainsound")
        end
        TheFocalPoint.SoundEmitter:SetParameter("treerainsound", "intensity", intensity)
    end

    local function StopTreeRainSound()
        if _treerainsound then
			_treerainsound = nil
            TheFocalPoint.SoundEmitter:KillSound("treerainsound")
        end
    end

    local function StartUmbrellaRainSound()
		local umbrella = _activatedplayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local sound =
			umbrella and umbrella:HasTag("metal") and
			(	_preciptype:value() == PRECIP_TYPES.lunarhail and
				"meta4/winona_teleumbrella/hail_on_teleumbrella" or
				"meta4/winona_teleumbrella/rain_on_teleumbrella"
			) or
			(	_preciptype:value() == PRECIP_TYPES.lunarhail and
				"rifts3/lunarhail/hail_on_umbrella" or
				"dontstarve/rain/rain_on_umbrella"
			)

		if _umbrellarainsound ~= sound then
			if _umbrellarainsound then
				TheFocalPoint.SoundEmitter:KillSound("umbrellarainsound")
			end
			_umbrellarainsound = sound
			TheFocalPoint.SoundEmitter:PlaySound(sound, "umbrellarainsound")
        end
    end

    local function StopUmbrellaRainSound()
        if _umbrellarainsound then
			_umbrellarainsound = nil
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
        elseif _preciptype:value() ~= PRECIP_TYPES.none and _preciptype:value() ~= PRECIP_TYPES.lunarhail and _precipmode:value() ~= PRECIP_MODES.never then
            local p = math.max(0, math.min(1, (_moisture:value() - _moisturefloor:value()) / (_moistureceil:value() - _moisturefloor:value())))
            local rate = MIN_PRECIP_RATE + (1 - MIN_PRECIP_RATE) * math.sin(p * PI)
            return math.min(rate, _peakprecipitationrate:value())
        end
        return 0
    end

    local function CalculateLunarHailRate()
        if _preciptype:value() == PRECIP_TYPES.lunarhail then
            local p = math.clamp(_lunarhaillevel:value() / LUNAR_HAIL_CEIL, 0, 1)
            return math.sin(p * PI)
        end
        return 0
    end

    local StartPrecipitation = _ismastersim and function(temperature)
        if _preciptype:value() == PRECIP_TYPES.lunarhail then return end

        _nextlightningtime = GetRandomMinMax(_minlightningdelay or 5, _maxlightningdelay or 15)
        _moisture:set(_moistureceil:value())
        _moisturefloor:set(RandomizeMoistureFloor(_season))
        _peakprecipitationrate:set(RandomizePeakPrecipitationRate(_season))
        _preciptype:set(temperature < _startsnowthreshold and PRECIP_TYPES.snow or PRECIP_TYPES.rain)
    end or nil

    local StopPrecipitation = _ismastersim and function()
        _moisture:set(_moisturefloor:value())
        _moistureceil:set(RandomizeMoistureCeil())

        if _preciptype:value() ~= PRECIP_TYPES.lunarhail then
            _preciptype:set(PRECIP_TYPES.none)
        end
    end or nil

    local StartLunarHail = _ismastersim and function()
        StopPrecipitation()
        _lunarhaillevel:set(LUNAR_HAIL_CEIL)
        _preciptype:set(PRECIP_TYPES.lunarhail)
    end or nil

    local StopLunarHail = _ismastersim and function()
        _lunarhaillevel:set(LUNAR_HAIL_FLOOR)
        _preciptype:set(PRECIP_TYPES.none)
    end or nil

    local function CalculatePOP()
        return (_preciptype:value() ~= PRECIP_TYPES.none and 1)
            or ((_moistureceil:value() <= 0 or _moisture:value() <= _moisturefloor:value()) and 0)
            or (_moisture:value() < _moistureceil:value() and (_moisture:value() - _moisturefloor:value()) / (_moistureceil:value() - _moisturefloor:value()))
            or 1
    end

    local function CalculateLight()
        if _preciptype:value() == PRECIP_TYPES.lunarhail then
            local dynrange = _daylight and SEASON_DYNRANGE_DAY[_season] or SEASON_DYNRANGE_NIGHT[_season]

            local p = 1 - CalculateLunarHailRate()
            p = easing.inQuad(p, 0, 1, 1)

            return p * dynrange + 1 - dynrange
        end

        if _precipmode:value() == PRECIP_MODES.never then
            return 1
        end
        local season = _season
        local snowlight = _preciptype:value() == PRECIP_TYPES.snow
        local dynrange = snowlight and (_daylight and SEASON_DYNRANGE_DAY["winter"] or SEASON_DYNRANGE_NIGHT["winter"])
                                    or (_daylight and SEASON_DYNRANGE_DAY[season] or SEASON_DYNRANGE_NIGHT[season])

        if _precipmode:value() == PRECIP_MODES.always then
            return 1 - dynrange
        end
        local p = 1 - math.min(math.max((_moisture:value() - _moisturefloor:value()) / (_moistureceil:value() - _moisturefloor:value()), 0), 1)
        if _preciptype:value() ~= PRECIP_TYPES.none then
            p = easing.inQuad(p, 0, 1, 1)
        end
        return p * dynrange + 1 - dynrange
    end

    local function CalculateWetnessRate(temperature, preciprate)
        return --Positive wetness rate when it's raining
            (_preciptype:value() == PRECIP_TYPES.rain and easing.inSine(preciprate, MIN_WETNESS_RATE, MAX_WETNESS_RATE, 1))
            --Negative drying rate when it's not raining
            or (temperature < 0 and _season == "winter" and -1)
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
            snowlevel = _snowlevel:value(),
            lunarhaillevel = _lunarhaillevel:value(),
            wetness = _wetness:value(),
            light = CalculateLight(),
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
            if data.season == "winter" and data.elapseddaysinseason == 2 then
                --We really want it to snow in early winter, so that we can get an initial ground cover
                _moisturerateval = 0
                _moisturerateoffset = 50
            else
                --It rains less in the middle of summer
                local p = 1 - math.sin(PI * data.progress)
                _moisturerateval = MOISTURE_RATES.MIN[_season] + p * (MOISTURE_RATES.MAX[_season] - MOISTURE_RATES.MIN[_season])
                _moisturerateoffset = 0
            end

            _moisturerate:set(CalculateMoistureRate())
            _moistureceilmultiplier = MOISTURE_CEIL_MULTIPLIERS[_season] or MOISTURE_CEIL_MULTIPLIERS.autumn
            _moisturefloormultiplier = MOISTURE_FLOOR_MULTIPLIERS[_season] or MOISTURE_FLOOR_MULTIPLIERS.autumn
            _startsnowthreshold = START_SNOW_THRESHOLDS[_season] or START_SNOW_THRESHOLDS.autumn
            _stopsnowthreshold = STOP_SNOW_THRESHOLDS[_season] or STOP_SNOW_THRESHOLDS.autumn
        end
    end

    local function OnTemperatureTick(src, temperature)
        _temperature = temperature
    end

    local function OnPhaseChanged(src, phase)
        _daylight = phase == "day"
    end

    local function OnPlayerActivated(src, player)
        _activatedplayer = player
        if _hasfx then
            _rainfx.entity:SetParent(player.entity)
            _snowfx.entity:SetParent(player.entity)
            _pollenfx.entity:SetParent(player.entity)
            _lunarhailfx.entity:SetParent(player.entity)
            self:OnPostInit()
        end
    end

    local function OnPlayerDeactivated(src, player)
        if _activatedplayer == player then
            _activatedplayer = nil
        end
        if _hasfx then
            _rainfx.entity:SetParent(nil)
            _snowfx.entity:SetParent(nil)
            _pollenfx.entity:SetParent(nil)
            _lunarhailfx.entity:SetParent(nil)
        end
    end

    local OnPlayerJoined = _ismastersim and function(src, player)
        for i, v in ipairs(_lightningtargets) do
            if v == player then
                return
            end
        end

        if player ~= nil then
            table.insert(_lightningtargets, player)
        end
    end or nil

    local OnPlayerLeft = _ismastersim and function(src, player)
        for i, v in ipairs(_lightningtargets) do
            if v == player then
                table.remove(_lightningtargets, i)
                return
            end
        end
    end or nil

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

    local OnSetSnowLevel = _ismastersim and function(src, level)
        _snowlevel:set(math.clamp(level or _snowlevel:value(), 0, 1))
    end or nil

    local OnDeltaWetness = _ismastersim and function(src, delta)
        _wetness:set(math.clamp(_wetness:value() + delta, MIN_WETNESS, MAX_WETNESS))
    end or nil

    local OnSetLightningMode = _ismastersim and function(src, mode)
        _lightningmode = LIGHTNING_MODES[mode] or _lightningmode
    end or nil

    local OnSetLightningDelay = _ismastersim and function(src, data)
        if _preciptype:value() ~= PRECIP_TYPES.none and data.min and data.max then
            _nextlightningtime = GetRandomMinMax(data.min, data.max)
        end
        _minlightningdelay = data.min
        _maxlightningdelay = data.max
    end or nil

    local LIGHTNINGSTRIKE_CANT_TAGS = { "playerghost", "INLIMBO" }
    local LIGHTNINGSTRIKE_ONEOF_TAGS = { "lightningrod", "lightningtarget", "lightningblocker" }
    local LIGHTNINGSTRIKE_SEARCH_RANGE = 40
    local OnSendLightningStrike = _ismastersim and function(src, pos)
        local closest_generic = nil
        local closest_rod = nil
        local closest_blocker = nil

        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, LIGHTNINGSTRIKE_SEARCH_RANGE, nil, LIGHTNINGSTRIKE_CANT_TAGS, LIGHTNINGSTRIKE_ONEOF_TAGS)
        local blockers = nil
        for _, v in pairs(ents) do
            -- Track any blockers we find, since we redirect the strike position later,
            -- and might redirect it into their block range.
            local is_blocker = v.components.lightningblocker ~= nil
            if is_blocker then
                if blockers == nil then
                    blockers = {v}
                else
                    table.insert(blockers, v)
                end
            end

            if closest_blocker == nil and is_blocker
                    and (v.components.lightningblocker.block_rsq + 0.0001) > v:GetDistanceSqToPoint(pos:Get()) then
                closest_blocker = v
            elseif closest_rod == nil and v:HasTag("lightningrod") then
                closest_rod = v
            elseif closest_generic == nil then
                if (v.components.health == nil or not v.components.health:IsInvincible())
                        and not is_blocker -- If we're out of range of the first branch, ignore blocker objects.
                        and (v.components.playerlightningtarget == nil or math.random() <= v.components.playerlightningtarget:GetHitChance()) then
                    closest_generic = v
                end
            end
        end

        local strike_position = pos
        local prefab_type = "lightning"

        if closest_blocker ~= nil then
            closest_blocker.components.lightningblocker:DoLightningStrike(strike_position)
            prefab_type = "thunder"
        elseif closest_rod ~= nil then
            strike_position = closest_rod:GetPosition()

            -- Check if we just redirected into a lightning blocker's range.
            if blockers ~= nil then
                for _, blocker in ipairs(blockers) do
                    if blocker:GetDistanceSqToPoint(strike_position:Get()) < (blocker.components.lightningblocker.block_rsq + 0.0001) then
                        prefab_type = "thunder"
                        blocker.components.lightningblocker:DoLightningStrike(strike_position)
                        break
                    end
                end
            end

            -- If we didn't get blocked, push the event that does all the fx and behaviour.
            if prefab_type == "lightning" then
                closest_rod:PushEvent("lightningstrike")
            end
        else
            if closest_generic ~= nil then
                strike_position = closest_generic:GetPosition()

                -- Check if we just redirected into a lightning blocker's range.
                if blockers ~= nil then
                    for _, blocker in ipairs(blockers) do
                        if blocker:GetDistanceSqToPoint(strike_position:Get()) < (blocker.components.lightningblocker.block_rsq + 0.0001) then
                            prefab_type = "thunder"
                            blocker.components.lightningblocker:DoLightningStrike(strike_position)
                            break
                        end
                    end
                end

                -- If we didn't redirect, strike the playerlightningtarget if there is one.
                if prefab_type == "lightning" then
                    if closest_generic.components.playerlightningtarget ~= nil then
                        closest_generic.components.playerlightningtarget:DoStrike()
                    end
                end
            end

            -- If we're doing lightning, light nearby unprotected objects on fire.
            if prefab_type == "lightning" then
                ents = TheSim:FindEntities(strike_position.x, strike_position.y, strike_position.z, 3, nil, _lightningexcludetags)
                for _, v in pairs(ents) do
                    if v.components.burnable ~= nil then
                        v.components.burnable:Ignite()
                    end
                end
            end
        end

        SpawnPrefab(prefab_type).Transform:SetPosition(strike_position:Get())
    end or nil

    local OnSimUnpaused = _ismastersim and function()
        --Force resync values that client may have simulated locally
        ForceResync(_noisetime)
        ForceResync(_moisture)
        ForceResync(_wetness)
        ForceResync(_snowlevel)
        ForceResync(_lunarhaillevel)
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
    _snowlevel:set(0)
    _lunarhaillevel:set(0)
    _wetness:set(0)
    _wet:set(false)

    --Dedicated server does not need to spawn the local fx
    if _hasfx then
        --Initialize rain particles
        _rainfx.particles_per_tick = 0
        _rainfx.splashes_per_tick = 0

        --Initialize snow particles
        _snowfx.particles_per_tick = 0

        --Initialize pollen
        _pollenfx.particles_per_tick = 0

        --Initialize lunar hail particles
        _lunarhailfx.particles_per_tick = 0
        _lunarhailfx.splashes_per_tick = 0
    end

    --Register network variable sync events
    inst:ListenForEvent("moistureceildirty", function() _world:PushEvent("moistureceilchanged", _moistureceil:value()) end)
    inst:ListenForEvent("preciptypedirty", function() _world:PushEvent("precipitationchanged", PRECIP_TYPE_NAMES[_preciptype:value()]) end)
    inst:ListenForEvent("snowcovereddirty", function() _world:PushEvent("snowcoveredchanged", _snowcovered:value()) end)
    inst:ListenForEvent("wetdirty", function() _world:PushEvent("wetchanged", _wet:value()) end)

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
        _startsnowthreshold = START_SNOW_THRESHOLDS.autumn
        _stopsnowthreshold = STOP_SNOW_THRESHOLDS.autumn
        _lightningmode = LIGHTNING_MODES.rain
        _minlightningdelay = nil
        _maxlightningdelay = nil
        _nextlightningtime = 5
        _lightningtargets = {}
        _lightningexcludetags = { "player", "INLIMBO", "lightningblocker" }

        for k, v in pairs(FUELTYPE) do
            if v ~= FUELTYPE.USAGE then --Not a real fuel
                table.insert(_lightningexcludetags, v.."_fueled")
            end
        end

        for i, v in ipairs(AllPlayers) do
            table.insert(_lightningtargets, v)
        end

        _moisturerate:set(CalculateMoistureRate())
        _moistureceil:set(RandomizeMoistureCeil())

        --Register master simulation events
        inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)
        inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)
        inst:ListenForEvent("ms_forceprecipitation", OnForcePrecipitation, _world)
        inst:ListenForEvent("ms_setprecipitationmode", OnSetPrecipitationMode, _world)
        inst:ListenForEvent("ms_setmoisturescale", OnSetMoistureScale, _world)
        inst:ListenForEvent("ms_deltamoisture", OnDeltaMoisture, _world)
        inst:ListenForEvent("ms_deltamoistureceil", OnDeltaMoistureCeil, _world)
        inst:ListenForEvent("ms_setsnowlevel", OnSetSnowLevel, _world)
        inst:ListenForEvent("ms_deltawetness", OnDeltaWetness, _world)
        inst:ListenForEvent("ms_setlightningmode", OnSetLightningMode, _world)
        inst:ListenForEvent("ms_setlightningdelay", OnSetLightningDelay, _world)
        inst:ListenForEvent("ms_sendlightningstrike", OnSendLightningStrike, _world)
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
        elseif _preciptype:value() == PRECIP_TYPES.snow then
            _snowfx:PostInit()
        elseif _preciptype:value() == PRECIP_TYPES.lunarhail then
            _lunarhailfx:PostInit()
        end

        if _season == "summer" then
            _pollenfx:PostInit()
        end
    end end

    --------------------------------------------------------------------------
    --[[ Deinitialization ]]
    --------------------------------------------------------------------------

    if _hasfx then function self:OnRemoveEntity()
        if _rainfx.entity:IsValid() then
            _rainfx:Remove()
        end
        if _snowfx.entity:IsValid() then
            _snowfx:Remove()
        end
        if _pollenfx.entity:IsValid() then
            _pollenfx:Remove()
        end
        if _lunarhailfx.entity:IsValid() then
            _lunarhailfx:Remove()
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
        local lunarhailrate = CalculateLunarHailRate()

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

        --Update _lunarhaillevel and toggle lunar hail
        if _world.components.riftspawner ~= nil and
            _world.components.riftspawner:IsLunarPortalActive() and
            _preciptype:value() ~= PRECIP_TYPES.lunarhail
        then
            -- Increave _lunarhaillevel
            local lunarhail = _lunarhaillevel:value() + LUNAR_HAIL_EVENT_RATE.COOLDOWN * dt
            if lunarhail >= LUNAR_HAIL_CEIL then
                if _ismastersim then
                    StartLunarHail()
                else
                    _lunarhaillevel:set_local(math.max(LUNAR_HAIL_CEIL - .001, _lunarhaillevel:value()))
                end
            else
                SetWithPeriodicSync(_lunarhaillevel, lunarhail, MOISTURE_SYNC_PERIOD, _ismastersim)
            end
        elseif _preciptype:value() == PRECIP_TYPES.lunarhail then
            -- Decrease _lunarhaillevel
            local lunarhail = math.max(_lunarhaillevel:value() - LUNAR_HAIL_EVENT_RATE.DURATION * dt, 0)
            if lunarhail <= LUNAR_HAIL_FLOOR then
                if _ismastersim then
                    StopLunarHail()
                else
                    _lunarhaillevel:set_local(math.min(LUNAR_HAIL_FLOOR + .001, _lunarhaillevel:value()))
                end
            else
                SetWithPeriodicSync(_lunarhaillevel, lunarhail, MOISTURE_SYNC_PERIOD, _ismastersim)
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

        local preciprate_sound = nil

        if _preciptype:value() == PRECIP_TYPES.rain then
            preciprate_sound = preciprate

        elseif _preciptype:value() == PRECIP_TYPES.lunarhail then
            preciprate_sound = lunarhailrate
        end

        if preciprate_sound ~= nil then
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
                StopUmbrellaRainSound()
                StopBarrierSound()
                StartTreeRainSound(preciprate_sound)
                preciprate_sound = preciprate_sound - .4
            else
                StopTreeRainSound()
                StopBarrierSound()
                if _activatedplayer.replica.inventory:EquipHasTag("umbrella") then
                    preciprate_sound = preciprate_sound - .4
                    StartUmbrellaRainSound()
                else
                    StopUmbrellaRainSound()
                end
            end
            if preciprate_sound > 0 then
                StartAmbientRainSound(preciprate_sound)
            else
                StopAmbientRainSound()
            end
        end

        --Update precipitation effects
        if _preciptype:value() == PRECIP_TYPES.rain then
            if _hasfx then
                _rainfx.particles_per_tick = 5 * preciprate
                _rainfx.splashes_per_tick = 2 * preciprate
                _snowfx.particles_per_tick = 0
                _lunarhailfx.particles_per_tick = 0
                _lunarhailfx.splashes_per_tick = 0
            end

        elseif _preciptype:value() == PRECIP_TYPES.lunarhail then
            if _hasfx then
                _lunarhailfx.particles_per_tick = 4 * lunarhailrate
				_lunarhailfx.splashes_per_tick = 2 * lunarhailrate

                _snowfx.particles_per_tick = 0
                _rainfx.particles_per_tick = 0
                _rainfx.splashes_per_tick = 0
            end

        else
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

                _lunarhailfx.particles_per_tick = 0
                _lunarhailfx.splashes_per_tick = 0

                if _preciptype:value() == PRECIP_TYPES.snow then
                    _snowfx.particles_per_tick = 20 * preciprate
                else
                    _snowfx.particles_per_tick = 0
                end
            end
        end

        --Update ground overlays
        local snowlevel = _snowlevel:value()
        if _preciptype:value() == PRECIP_TYPES.snow then
            --Accumulate snow
            snowlevel = math.min(snowlevel + preciprate * dt * SNOW_ACCUM_RATE, 1)
        elseif snowlevel > 0 and _temperature > 0 then
            --Melt snow
            local meltrate = MIN_SNOW_MELT_RATE + SNOW_MELT_RATE * math.min(_temperature / 20, 1)
            snowlevel = math.max(snowlevel - meltrate * dt, 0)
        end
        SetWithPeriodicSync(_snowlevel, snowlevel, SNOW_LEVEL_SYNC_PERIOD, _ismastersim)
        if _snowlevel:value() > 0 and (_temperature < 0 or _wetness:value() < 5) then
            SetGroundOverlay(GROUND_OVERLAYS.snow, _snowlevel:value() * 3) -- snowlevel goes from 0-1
        else
            SetGroundOverlay(GROUND_OVERLAYS.puddles, _wetness:value() * 3 / 100) -- wetness goes from 0-100
        end

        --Update pollen
        if _hasfx then
            if _season ~= "summer" or (ThePlayer ~= nil and _world.components.sandstorms ~= nil and _world.components.sandstorms:IsInSandstorm(ThePlayer)) then
                _pollenfx.particles_per_tick = 0
            elseif _seasonprogress < .2 then
                local ramp = _seasonprogress / .2
                _pollenfx.particles_per_tick = ramp * POLLEN_PARTICLES
            elseif _seasonprogress > .8 then
                local ramp = (1-_seasonprogress) / .2
                _pollenfx.particles_per_tick = ramp * POLLEN_PARTICLES
            else
                _pollenfx.particles_per_tick = POLLEN_PARTICLES
            end
        end

        if _ismastersim then
            --Update entity snow cover
            _snowcovered:set(_groundoverlay == GROUND_OVERLAYS.snow and _snowlevel:value() >= SNOW_COVERED_THRESHOLD)

            --Switch precipitation type based on temperature
            if _temperature < _startsnowthreshold and _preciptype:value() == PRECIP_TYPES.rain then
                _preciptype:set(PRECIP_TYPES.snow)
            elseif _temperature > _stopsnowthreshold and _preciptype:value() == PRECIP_TYPES.snow then
                _preciptype:set(PRECIP_TYPES.rain)
            end

            --Update lightning
            if _lightningmode == LIGHTNING_MODES.always or
                LIGHTNING_MODE_NAMES[_lightningmode] == PRECIP_TYPE_NAMES[_preciptype:value()] or
                (_lightningmode == LIGHTNING_MODES.any and _preciptype:value() ~= PRECIP_TYPES.none) then
                if _nextlightningtime > dt then
                    _nextlightningtime = _nextlightningtime - dt
                else
                    local min = _minlightningdelay or easing.linear(preciprate, 30, 10, 1)
                    local max = _maxlightningdelay or (min + easing.linear(preciprate, 30, 10, 1))
                    _nextlightningtime = GetRandomMinMax(min, max)
                    if (preciprate > .75 or _lightningmode == LIGHTNING_MODES.always) and next(_lightningtargets) ~= nil then
                        local targeti = math.min(math.floor(easing.inQuint(math.random(), 1, #_lightningtargets, 1)), #_lightningtargets)
                        local target = _lightningtargets[targeti]
                        table.remove(_lightningtargets, targeti)
                        table.insert(_lightningtargets, target)

                        local x, y, z = target.Transform:GetWorldPosition()
                        local radius = 2 + math.random() * 8
                        local theta = math.random() * TWOPI
                        local pos = Vector3(x + radius * math.cos(theta), y, z + radius * math.sin(theta))
                        _world:PushEvent("ms_sendlightningstrike", pos)
                    else
                        SpawnPrefab(preciprate > .5 and "thunder_close" or "thunder_far")
                    end
                end
            end
        end

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
            snowlevel = _snowlevel:value(),
            lunarhaillevel = _lunarhaillevel:value(),
            snowcovered = _snowcovered:value() or nil,
            startsnowthreshold = _startsnowthreshold,
            stopsnowthreshold = _stopsnowthreshold,
            lightningmode = LIGHTNING_MODE_NAMES[_lightningmode],
            minlightningdelay = _minlightningdelay,
            maxlightningdelay = _maxlightningdelay,
            nextlightningtime = _nextlightningtime,
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
        _snowlevel:set(data.snowlevel or 0)
        _lunarhaillevel:set(data.lunarhaillevel or 0)
        _snowcovered:set(data.snowcovered == true)
        _startsnowthreshold = data.startsnowthreshold or START_SNOW_THRESHOLDS.autumn
        _stopsnowthreshold = data.stopsnowthreshold or STOP_SNOW_THRESHOLDS.autumn
        _lightningmode = LIGHTNING_MODES[data.lightningmode] or LIGHTNING_MODES.rain
        _minlightningdelay = data.minlightningdelay
        _maxlightningdelay = data.maxlightningdelay
        _nextlightningtime = data.nextlightningtime or 5
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
            string.format("  temperature: %2.1f",_temperature),
            string.format("  moisture: %2.1f (%2.1f/%2.1f) + %2.1f", _moisture:value(), _moisturefloor:value(), _moistureceil:value(), _moisturerate:value()),
            string.format("  preciprate: (%2.1f of %2.1f)", preciprate, _peakprecipitationrate:value()),
            string.format("  snowlevel: %2.1f", _snowlevel:value()),
            string.format("  lunarhaillevel: %2.1f", _lunarhaillevel:value()),
            string.format("  wetness: %2.1f (%s %2.1f) %s", _wetness:value(), wetrate > 0 and "+" or "", wetrate, _wet:value() and " WET" or ""),
            string.format("  light: %2.5f", CalculateLight()),
        }

        if _ismastersim then
            table.insert(str, string.format("  lightning:%2.1f", _nextlightningtime))
        end

        return table.concat(str, "\n")
    end

    --------------------------------------------------------------------------
    --[[ End ]]
    --------------------------------------------------------------------------

    end)
