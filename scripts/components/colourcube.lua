--------------------------------------------------------------------------
--[[ ColourCube ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"

local INSANITY_COLOURCUBES =
{
    day = "images/colour_cubes/insane_day_cc.tex",
    dusk = "images/colour_cubes/insane_dusk_cc.tex",
    night = "images/colour_cubes/insane_night_cc.tex",
    full_moon = "images/colour_cubes/insane_night_cc.tex",
}

local LUNACY_COLOURCUBES =
{
	regular = "images/colour_cubes/lunacy_regular_cc.tex",
    full_moon = "images/colour_cubes/purple_moon_cc.tex",
    moon_storm = "images/colour_cubes/moonstorm_cc.tex",
}

local SEASON_COLOURCUBES =
{
    autumn =
    {
        day = "images/colour_cubes/day05_cc.tex",
        dusk = "images/colour_cubes/dusk03_cc.tex",
        night = "images/colour_cubes/night03_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex"
    },
    winter =
    {
        day = "images/colour_cubes/snow_cc.tex",
        dusk = "images/colour_cubes/snowdusk_cc.tex",
        night = "images/colour_cubes/night04_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex"
    },
    spring =
    {
        day = "images/colour_cubes/spring_day_cc.tex",
        dusk = "images/colour_cubes/spring_dusk_cc.tex",
        night = "images/colour_cubes/spring_dusk_cc.tex",--"images/colour_cubes/spring_night_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex"
    },
    summer =
    {
        day = "images/colour_cubes/summer_day_cc.tex",
        dusk = "images/colour_cubes/summer_dusk_cc.tex",
        night = "images/colour_cubes/summer_night_cc.tex",
        full_moon = "images/colour_cubes/purple_moon_cc.tex"
    },
}

local CAVE_COLOURCUBES =
{
    night = "images/colour_cubes/caves_default.tex",
}

local PHASE_BLEND_TIMES =
{
    day = 4,
    dusk = 6,
    night = 8,
    full_moon = 8,
}

local SEASON_BLEND_TIME = 10
local DEFAULT_BLEND_TIME = .25

local FISHEYE_INTENSITY_MAX = 0.01
local FISHEYE_INTENSITY_RATE = 1 / 0.4 -- 1 / (X seconds to max rate)
local FISHEYE_SPEED_MAX = 0


--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _iscave = inst:HasTag("cave")
local _phase = _iscave and "night" or "day"
local _fullmoonphase = nil
local _season = "autumn"
local _alter_awake = false
local _in_moonstorm = false
local _in_raindome = false
local _ambientcctable = _iscave and CAVE_COLOURCUBES or SEASON_COLOURCUBES.autumn
local _insanitycctable = INSANITY_COLOURCUBES
local _lunacycctable = LUNACY_COLOURCUBES
local _ambientcc = { _ambientcctable[_phase], _ambientcctable[_phase] }
local _insanitycc = { _insanitycctable[_phase], _insanitycctable[_phase] }
local _lunacycc = {_lunacycctable["regular"], _lunacycctable["regular"]}
local _overridecc = nil
local _overridecctable = nil
local _overridephase = nil
local _remainingblendtime = 0
local _totalblendtime = 0
local _fxtime = 0
local _fxspeed = 0
local _fisheyetime = 0
local _fisheyespeed = 0
local _fisheyeintensity = 0
local _distortion_modifier = Profile:GetDistortionModifier()
local _lunacyintensity = 0
local _lunacyspeed = 0
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use
local _colourmodifier = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function ShouldSkipBlend()
    return _activatedplayer == nil or TheFrontEnd:GetFadeLevel() >= 1
end

local function GetCCPhase()
    return (_overridephase and _overridephase.fn and _overridephase.fn())
        or (_iscave and "night")
        or (_phase == "night" and _fullmoonphase or _phase)
end

local function GetInsanityPhase()
    return (_iscave and "night")
        or (_phase == "night" and _fullmoonphase or _phase)
end

local function GetLunacyPhase()
	return _phase == "night" and _fullmoonphase
			or _in_moonstorm and "moon_storm"
			or "regular"
end

local function Blend(time)
    local ambientcctarget = _ambientcctable[GetCCPhase()] or IDENTITY_COLOURCUBE
    local insanitycctarget = _insanitycctable[GetInsanityPhase()] or IDENTITY_COLOURCUBE
    local lunacycctarget = _lunacycctable[GetLunacyPhase()] or IDENTITY_COLOURCUBE

    if _overridecc ~= nil then
        _ambientcc[2] = ambientcctarget
        _insanitycc[2] = insanitycctarget
        _lunacycc[2] = lunacycctarget
        return
    end

    local newtarget = _ambientcc[2] ~= ambientcctarget or _insanitycc[2] ~= insanitycctarget or _lunacycc[2] ~= lunacycctarget

    if _remainingblendtime <= 0 then
        --No blends in progress, so we can start a new blend
        if newtarget then
            _ambientcc[1] = _ambientcc[2]
            _ambientcc[2] = ambientcctarget
            _insanitycc[1] = _insanitycc[2]
            _insanitycc[2] = insanitycctarget
            _lunacycc[1] = _lunacycc[2]
            _lunacycc[2] = lunacycctarget
            _remainingblendtime = time
            _totalblendtime = time
            PostProcessor:SetColourCubeData(0, _ambientcc[1], _ambientcc[2])
            PostProcessor:SetColourCubeData(1, _insanitycc[1], _insanitycc[2])
            PostProcessor:SetColourCubeData(2, _lunacycc[1], _lunacycc[2])
            PostProcessor:SetColourCubeLerp(0, 0)
        end
    elseif newtarget then
        --Skip any blend in progress and restart new blend
        if _remainingblendtime < _totalblendtime then
            _ambientcc[1] = _ambientcc[2]
            _insanitycc[1] = _insanitycc[2]
            _lunacycc[1] = _lunacycc[2]
            PostProcessor:SetColourCubeLerp(0, 0)
        end
        _ambientcc[2] = ambientcctarget
        _insanitycc[2] = insanitycctarget
        _lunacycc[2] = lunacycctarget
        _remainingblendtime = time
        _totalblendtime = time
        PostProcessor:SetColourCubeData(0, _ambientcc[1], _ambientcc[2])
        PostProcessor:SetColourCubeData(1, _insanitycc[1], _insanitycc[2])
        PostProcessor:SetColourCubeData(2, _lunacycc[1], _lunacycc[2])
    elseif _remainingblendtime >= _totalblendtime and time < _totalblendtime then
        --Same target, but hasn't ticked yet, so switch to the faster time
        _remainingblendtime = time
        _totalblendtime = time
    end

    if _remainingblendtime > 0 and ShouldSkipBlend() then
        _remainingblendtime = 0
        PostProcessor:SetColourCubeLerp(0, 1)
    end
end

local function UpdateAmbientCCTable(blendtime)
    _ambientcctable = _overridecctable or (_iscave and CAVE_COLOURCUBES or SEASON_COLOURCUBES[_season]) or SEASON_COLOURCUBES.autumn
    Blend(blendtime)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnOverridePhaseEvent(inst)
    -- just naively force an update when an override event happens
    UpdateAmbientCCTable(_overridephase and _overridephase.blendtime or DEFAULT_BLEND_TIME)
end

local sanity_cc_idx = 1
local lunacy_cc_idx = 2

local function SetLunacyIntensityParams(lunacy_distortion, sanity_distortion)
    --when lunacy intensity is transitioning, do a merge of the 2 states, based on lunacy intensity.
    local neg_lunacyintensity = 1 - _lunacyintensity
    local distortion_factor = math.clamp((1 * _lunacyintensity) + ((1 - sanity_distortion) * neg_lunacyintensity) - _fisheyeintensity, 0, 1)
    PostProcessor:SetColourCubeLerp(sanity_cc_idx, sanity_distortion * neg_lunacyintensity)
    PostProcessor:SetColourCubeLerp(lunacy_cc_idx, lunacy_distortion * _lunacyintensity)
    PostProcessor:SetDistortionFactor(distortion_factor)
    PostProcessor:SetOverlayBlend(lunacy_distortion * _lunacyintensity)
    PostProcessor:SetLunacyEnabled(_lunacyintensity > 0)
end
local function SetOnlyLunacyIntensityParams(lunacy_distortion)
    local distortion_factor = math.clamp(1 - _fisheyeintensity, 0, 1)
    PostProcessor:SetColourCubeLerp(sanity_cc_idx, 0)
    PostProcessor:SetColourCubeLerp(lunacy_cc_idx, lunacy_distortion)
    PostProcessor:SetDistortionFactor(distortion_factor)
    PostProcessor:SetOverlayBlend(lunacy_distortion)
    PostProcessor:SetLunacyEnabled(true)
end
local function SetOnlyInsanityIntensityParams(sanity_distortion)
    local distortion_factor = math.clamp(1 - sanity_distortion * _distortion_modifier - _fisheyeintensity, 0, 1)
    PostProcessor:SetColourCubeLerp(sanity_cc_idx, sanity_distortion)
    PostProcessor:SetColourCubeLerp(lunacy_cc_idx, 0)
    PostProcessor:SetDistortionFactor(distortion_factor)
    PostProcessor:SetOverlayBlend(0)
    PostProcessor:SetLunacyEnabled(false)
end

local function OnSanityDelta(player, data)
    local is_lunacy = player.replica.sanity:IsLunacyMode()
	local sanity_percent = player.replica.sanity:GetPercent()
    local lunacy_percent = 1 - sanity_percent

	local lunacy_distortion = 1 - easing.outQuad(lunacy_percent, 0, 1, 1)
	local sanity_distortion = 1 - easing.outQuad(sanity_percent, 0, 1, 1)
	if player ~= nil and player:HasTag("dappereffects") then
		lunacy_distortion = lunacy_distortion * lunacy_distortion
		sanity_distortion = sanity_distortion * sanity_distortion
	end

    if is_lunacy then
        _lunacyspeed = easing.outQuad(1 - lunacy_percent, 0.4, 1.6, 1)
    else
        _lunacyspeed = easing.outQuad(1 - sanity_percent, -0.4, -1.6, 1)
    end

    if _lunacyintensity > 0 and _lunacyintensity < 1 then
        SetLunacyIntensityParams(lunacy_distortion, sanity_distortion)
    elseif is_lunacy and _lunacyintensity == 1 then
        SetOnlyLunacyIntensityParams(lunacy_distortion)
    elseif not is_lunacy and _lunacyintensity == 0 then
        SetOnlyInsanityIntensityParams(sanity_distortion)
    end

	_fxspeed = easing.outQuad(1 - sanity_percent, 0, .2, 1) * _distortion_modifier
end

local function OnOverrideCCTable(player, cctable)
    _overridecctable = cctable
    UpdateAmbientCCTable(DEFAULT_BLEND_TIME)
end

local function OnOverrideCCPhaseFn(player, fn)
    local blendtime = nil
    if _overridephase ~= nil then
        if _overridephase.blendtime ~= nil then
            blendtime = _overridephase.blendtime
        end
        for i,event in ipairs(_overridephase.events) do
            inst:RemoveEventCallback(event, OnOverridePhaseEvent)
        end
    end
    _overridephase = fn
    if _overridephase ~= nil then
        if _overridephase.blendtime ~= nil then
            -- We take the shorter blendtime when transitioning between overrides
            -- This makes the molehat always transition snappily
            blendtime = blendtime ~= nil and math.min(blendtime, _overridephase.blendtime) or _overridephase.blendtime
        end
        for i,event in ipairs(_overridephase.events) do
            inst:ListenForEvent(event, OnOverridePhaseEvent)
        end
    end
    UpdateAmbientCCTable(blendtime or DEFAULT_BLEND_TIME)
end

local function OnStormLevelChanged(inst, data)
    local in_moonstorm = data.stormtype == STORM_TYPES.MOONSTORM
	if _in_moonstorm ~= in_moonstorm then
		_in_moonstorm = in_moonstorm

		local blendtime = PHASE_BLEND_TIMES[GetCCPhase()]
		if blendtime ~= nil then
			Blend(blendtime)
		end
    end
end

local function OnEnterRainDome(inst, data)
    _in_raindome = true
end

local function OnExitRainDome(inst, data)
    _in_raindome = false
end

local function OnPlayerActivated(inst, player)
    if _activatedplayer == player then
        return
    elseif _activatedplayer ~= nil and _activatedplayer.entity:IsValid() then
        inst:RemoveEventCallback("sanitydelta", OnSanityDelta, _activatedplayer)
        inst:RemoveEventCallback("ccoverrides", OnOverrideCCTable, player)
        inst:RemoveEventCallback("ccphasefn", OnOverrideCCPhaseFn, player)
		inst:RemoveEventCallback("stormlevel", OnStormLevelChanged, player)
        inst:RemoveEventCallback("enterraindome", OnEnterRainDome, player)
        inst:RemoveEventCallback("exitraindome", OnExitRainDome, player)
    end
    _activatedplayer = player
    inst:ListenForEvent("sanitydelta", OnSanityDelta, player)
    inst:ListenForEvent("ccoverrides", OnOverrideCCTable, player)
    inst:ListenForEvent("ccphasefn", OnOverrideCCPhaseFn, player)
	inst:ListenForEvent("stormlevel", OnStormLevelChanged, player)
    inst:ListenForEvent("enterraindome", OnEnterRainDome, player)
    inst:ListenForEvent("exitraindome", OnExitRainDome, player)
    if player.replica.sanity ~= nil then
        OnSanityDelta(player, { newpercent = player.replica.sanity:GetPercent(), sanitymode = player.replica.sanity:GetSanityMode() })
    end
    OnOverrideCCTable(player, player.components.playervision ~= nil and player.components.playervision:GetCCTable() or nil)
    OnOverrideCCPhaseFn(player, player.components.playervision ~= nil and player.components.playervision:GetCCPhaseFn() or nil)
end

local function OnPlayerDeactivated(inst, player)
    inst:RemoveEventCallback("sanitydelta", OnSanityDelta, player)
    inst:RemoveEventCallback("ccoverrides", OnOverrideCCTable, player)
    inst:RemoveEventCallback("ccphasefn", OnOverrideCCPhaseFn, player)
	inst:RemoveEventCallback("stormlevel", OnStormLevelChanged, player)
    inst:RemoveEventCallback("enterraindome", OnEnterRainDome, player)
    inst:RemoveEventCallback("exitraindome", OnExitRainDome, player)
    OnExitRainDome()
    OnSanityDelta(player, { newpercent = 1, sanitymode = SANITY_MODE_INSANITY })
    OnOverrideCCTable(player, nil)
    if player == _activatedplayer then
        _activatedplayer = nil
    end
end

local function OnPhaseChanged(inst, phase)
    if _phase ~= phase then
        _phase = phase

        local blendtime = PHASE_BLEND_TIMES[GetCCPhase()]
        if blendtime ~= nil then
            Blend(blendtime)
        end
    end
end

local function OnMoonPhaseChanged2(inst, data)
    local moonphase = data.moonphase == "full" and "full_moon" or nil
    if _fullmoonphase ~= moonphase then
        _fullmoonphase = moonphase

        local blendtime = PHASE_BLEND_TIMES[GetCCPhase()]
        if blendtime ~= nil then
            Blend(blendtime)
        end
    end
end

local function OnMoonPhaseStyleChanged(inst, data)
    local alter_awake = data.style == "alter_active"
	if _alter_awake ~= alter_awake then
		_alter_awake = alter_awake

		if _fullmoonphase  then
			local blendtime = PHASE_BLEND_TIMES[GetCCPhase()]
			if blendtime ~= nil then
				Blend(blendtime)
			end
		end
    end
end

local OnSeasonTick = not _iscave and function(inst, data)
    _season = data.season
    UpdateAmbientCCTable(SEASON_BLEND_TIME)
end or nil

local function OnOverrideColourCube(inst, cc)
    if _overridecc ~= cc then
        _overridecc = cc

        if cc ~= nil then
            PostProcessor:SetColourCubeData(0, cc, cc)
            PostProcessor:SetColourCubeData(1, cc, cc)
            PostProcessor:SetColourCubeLerp(0, 1)
            PostProcessor:SetColourCubeLerp(1, 0)
        else
            PostProcessor:SetColourCubeData(0, _ambientcc[2], _ambientcc[2])
            PostProcessor:SetColourCubeData(1, _insanitycc[2], _insanitycc[2])
            PostProcessor:SetColourCubeData(2, _lunacycc[2], _lunacycc[2])
        end
    end
end

local function OnOverrideColourModifier(inst, mod)
    if _colourmodifier ~= mod then
        _colourmodifier = mod
        PostProcessor:SetColourModifier(mod or 1)
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Channel 0: ambient colour cube
--Channel 1: insanity colour cube
--Channel 2: lunacy colour cube
PostProcessor:SetColourCubeData(0, _ambientcc[1], _ambientcc[2])
PostProcessor:SetColourCubeData(1, _insanitycc[1], _insanitycc[2])
PostProcessor:SetColourCubeData(2, _lunacycc[1], _lunacycc[2])
PostProcessor:SetColourCubeLerp(0, 1)
PostProcessor:SetColourCubeLerp(1, 0)
PostProcessor:SetDistortionRadii(0.5, 0.685)

--Register events
inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
inst:ListenForEvent("phasechanged", OnPhaseChanged)
inst:ListenForEvent("moonphasechanged2", OnMoonPhaseChanged2)
inst:ListenForEvent("moonphasestylechanged", OnMoonPhaseStyleChanged)

if not _iscave then
    inst:ListenForEvent("seasontick", OnSeasonTick)
end
inst:ListenForEvent("overridecolourcube", OnOverrideColourCube)
inst:ListenForEvent("overridecolourmodifier", OnOverrideColourModifier)

inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    local needstoupdatepostprocessor = false
    if _overridecc == nil then
        if _remainingblendtime > dt and not ShouldSkipBlend() then
            _remainingblendtime = _remainingblendtime - dt
            PostProcessor:SetColourCubeLerp(0, 1 - _remainingblendtime / _totalblendtime)
        elseif _remainingblendtime > 0 then
            _remainingblendtime = 0
            PostProcessor:SetColourCubeLerp(0, 1)
        end
    end

    _fxtime = _fxtime + dt * _fxspeed
    _fisheyetime = _fisheyetime + dt * _fisheyespeed
    PostProcessor:SetDistortionEffectTime(_fxtime)
    PostProcessor:SetDistortionFishEyeTime(_fisheyetime)

    local new_fisheyeintensity = math.clamp(_fisheyeintensity + (_in_raindome and FISHEYE_INTENSITY_RATE or -FISHEYE_INTENSITY_RATE) * dt, 0, 1)
    if new_fisheyeintensity ~= _fisheyeintensity then
        _fisheyeintensity = new_fisheyeintensity
        PostProcessor:SetDistortionFishEyeIntensity(-_fisheyeintensity * FISHEYE_INTENSITY_MAX) -- NOTES(JBK): Negative intensity for the shader math.
        _fisheyespeed = _fisheyeintensity * FISHEYE_SPEED_MAX
        needstoupdatepostprocessor = true
    end

    local new_lunacyintensity = math.clamp(_lunacyintensity + dt * _lunacyspeed, 0, 1)
    if new_lunacyintensity ~= _lunacyintensity then
        _lunacyintensity = new_lunacyintensity
		local sanity_percent = ThePlayer and ThePlayer.replica.sanity:GetPercent() or 1
        local lunacy_percent = 1 - sanity_percent

        local lunacy_distortion = 1 - easing.outQuad(lunacy_percent, 0, 1, 1)
        local sanity_distortion = 1 - easing.outQuad(sanity_percent, 0, 1, 1)
        if ThePlayer and ThePlayer:HasTag("dappereffects") then
            lunacy_distortion = lunacy_distortion * lunacy_distortion
            sanity_distortion = sanity_distortion * sanity_distortion
        end
        SetLunacyIntensityParams(lunacy_distortion, sanity_distortion)
        needstoupdatepostprocessor = false
        PostProcessor:SetLunacyIntensity(_lunacyintensity)
    end

    if needstoupdatepostprocessor and ThePlayer and ThePlayer.replica.sanity ~= nil then
        OnSanityDelta(ThePlayer, { newpercent = ThePlayer.replica.sanity:GetPercent(), sanitymode = ThePlayer.replica.sanity:GetSanityMode() })
    end
end

function self:LongUpdate(dt)
    self:OnUpdate(_remainingblendtime)
end

function self:SetDistortionModifier(modifier)
    _distortion_modifier = modifier
    if _activatedplayer and _activatedplayer.replica.sanity then
        OnSanityDelta(_activatedplayer, { newpercent = _activatedplayer.replica.sanity:GetPercent(), sanitymode = _activatedplayer.replica.sanity:GetSanityMode() })
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("override: %s overridefn: %s blendtime: %.2f\n\tambient: %s -> %s\n\tsanity: %s -> %s\n\tlunacy: %s -> %s",
        _overridecc ~= nil and "true" or "false",
        _overridephase ~= nil and "true" or "false",
        _remainingblendtime,
        _ambientcc[1], _ambientcc[2],
        _insanitycc[1], _insanitycc[2],
		_lunacycc[1], _lunacycc[2]
    )
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
