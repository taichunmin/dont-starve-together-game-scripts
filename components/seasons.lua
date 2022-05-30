--------------------------------------------------------------------------
--[[ Seasons class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local SEASON_NAMES =
{
    "autumn",
    "winter",
    "spring",
    "summer",
}
local SEASONS = table.invert(SEASON_NAMES)

local MODE_NAMES =
{
    "cycle",
    "endless",
    "always",
}
local MODES = table.invert(MODE_NAMES)

local NUM_CLOCK_SEGS = 16
local DEFAULT_CLOCK_SEGS =
{
    autumn = { day = 8, dusk = 6, night = 2 },
    winter = { day = 5, dusk = 5, night = 6 },
    spring = { day = 5, dusk = 8, night = 3 },
    summer = { day = 11, dusk = 1, night = 4 },
}

local ENDLESS_PRE_DAYS = 10
local ENDLESS_RAMP_DAYS = 10
local ENDLESS_DAYS = 10000

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _ismastershard = _world.ismastershard

--Master simulation
local _mode
local _premode
local _segs
local _segmod
local _israndom = {}

--Network
local _season = net_tinybyte(inst.GUID, "seasons._season", "seasondirty")
local _totaldaysinseason = net_byte(inst.GUID, "seasons._totaldaysinseason", "seasondirty")
local _elapseddaysinseason = net_ushortint(inst.GUID, "seasons._elapseddaysinseason", "seasondirty")
local _remainingdaysinseason = net_byte(inst.GUID, "seasons._remainingdaysinseason", "seasondirty")
local _endlessdaysinseason = net_bool(inst.GUID, "seasons._endlessdaysinseason", "seasondirty")
local _lengths = {}
for i, v in ipairs(SEASON_NAMES) do
    _lengths[i] = net_byte(inst.GUID, "seasons._lengths."..v, "lengthsdirty")
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local GetPrevSeason = _ismastersim and function()
    if _premode or _mode == MODES.always then
        return _season:value()
    end

    local season = _season:value()
    while true do
        season = season > 1 and season - 1 or #SEASON_NAMES
        if _lengths[season]:value() > 0 or season == _season:value() then
            return season
        end
    end

    return season
end or nil

local GetNextSeason = _ismastersim and function()
    if not _premode and (_mode == MODES.endless or _mode == MODES.always) then
        return _season:value()
    end

    local season = _season:value()
    while true do
        season = (season % #SEASON_NAMES) + 1
        if _lengths[season]:value() > 0 or season == _season:value() then
            return season
        end
    end

    return season
end or nil

local GetModifiedSegs = _ismastersim and function(segs, mod)
	local importance = {"day", "dusk", "night"}
	table.sort(importance, function(a,b) return mod[a] < mod[b] end)

	local retsegs = {}
	for k,v in pairs(segs) do
		retsegs[k] = math.ceil(math.clamp(v * mod[k], 0, 16))
	end

	local total = retsegs.day + retsegs.dusk + retsegs.night
	while total ~= 16 do
		for i=1, #importance do
			if total >= 16 and retsegs[importance[i]] > 1 then
				retsegs[importance[i]] = retsegs[importance[i]] - 1
			elseif total < 16 and retsegs[importance[i]] > 0 then
				retsegs[importance[i]] = retsegs[importance[i]] + 1
			end
			total = retsegs.day + retsegs.dusk + retsegs.night
			if total == 16 then
			    break
			end
		end
    end

	return retsegs
end or nil

local PushSeasonClockSegs = _ismastersim and function()
    if not _ismastershard then
        return -- mastershard pushes its seg data to the clock, which pushes it to the secondary shards
    end

    local p = 1 - (_totaldaysinseason:value() > 0 and _remainingdaysinseason:value() / _totaldaysinseason:value() or 0)
    local toseason = p < .5 and GetPrevSeason() or GetNextSeason()
    local tosegs = _segs[toseason]
    local segs = tosegs

    if _season:value() ~= toseason then
        local fromsegs = _segs[_season:value()]
        p = .5 - math.sin(PI * p) * .5
        segs =
        {
            day = math.floor(easing.linear(p, fromsegs.day, tosegs.day - fromsegs.day, 1) + .5),
            night = math.floor(easing.linear(p, fromsegs.night, tosegs.night - fromsegs.night, 1) + .5),
        }
        segs.dusk = NUM_CLOCK_SEGS - segs.day - segs.night
    end

	segs = GetModifiedSegs(segs, _segmod)

    _world:PushEvent("ms_setclocksegs", segs)
end or nil

local UpdateSeasonMode = _ismastersim and function(modified_season)

	local numactiveseasons = 0
	local allowedseason = nil
	for i,length in ipairs(_lengths) do
		if length:value() > 0 then
			numactiveseasons = numactiveseasons + 1
			allowedseason = i
		end
	end

	if numactiveseasons == 1 then
		if allowedseason == _season:value() then
			_mode = MODES.always
		else
			_mode = MODES.endless
		end
	else
		_mode = MODES.cycle
	end

    if _mode == MODES.endless then
		_premode = true
		_totaldaysinseason:set(ENDLESS_PRE_DAYS * 2)
		_remainingdaysinseason:set(ENDLESS_PRE_DAYS)
		_endlessdaysinseason:set(false)
    elseif _mode == MODES.always then
		_premode = false
        _totaldaysinseason:set(2)
        _remainingdaysinseason:set(1)
        _endlessdaysinseason:set(true)
    elseif modified_season == nil or modified_season == _season:value() then
		if _lengths[_season:value()]:value() == 0 then
			-- We can have a cycle that doesn't include the starting season (a "cycle pre" if you will)
			_premode = true
			_totaldaysinseason:set(ENDLESS_PRE_DAYS * 2)
			_remainingdaysinseason:set(ENDLESS_PRE_DAYS)
			_endlessdaysinseason:set(false)
		else
			if _season:value() == SEASONS.summer or _season:value() == SEASONS.winter then
				_totaldaysinseason:set(_lengths[_season:value()]:value())
				_remainingdaysinseason:set(math.ceil(_totaldaysinseason:value()))
			 else
				-- For spring and autumn, we artificially start "in the middle" for temperature, precip, etc. to prevent weird starts
				_totaldaysinseason:set(_lengths[_season:value()]:value() * 2)
				_remainingdaysinseason:set(_lengths[_season:value()]:value())
			end
			_premode = false
			_endlessdaysinseason:set(false)
		end

    end

end or nil

local PushMasterSeasonData = _ismastershard and function()
    local data =
    {
        season = _season:value(),
        totaldaysinseason = _totaldaysinseason:value(),
        remainingdaysinseason = _remainingdaysinseason:value(),
        elapseddaysinseason = _elapseddaysinseason:value(),
        endlessdaysinseason = _endlessdaysinseason:value(),
        lengths = {}
    }
    for i,v in ipairs(_lengths) do
        data.lengths[i] = v:value()
    end
    _world:PushEvent("master_seasonsupdate", data)
end or nil

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnSeasonDirty()
    local data = {
        season = SEASON_NAMES[_season:value()],
        progress = 1 - (_totaldaysinseason:value() > 0 and _remainingdaysinseason:value() / _totaldaysinseason:value() or 0),
        elapseddaysinseason = _elapseddaysinseason:value(),
        remainingdaysinseason = _endlessdaysinseason:value() and ENDLESS_DAYS or _remainingdaysinseason:value(),
    }
    _world:PushEvent("seasontick", data)

    if _ismastershard then
        PushMasterSeasonData()
    end
end

local function OnLengthsDirty()
    local data = {}
    for i, v in ipairs(_lengths) do
        data[SEASON_NAMES[i]] = v:value()
    end
    _world:PushEvent("seasonlengthschanged", data)

    if _ismastershard then
        PushMasterSeasonData()
    end
end

local OnAdvanceSeason = _ismastersim and function()
    _elapseddaysinseason:set(_elapseddaysinseason:value() + 1)

    if _mode == MODES.cycle then
        if _remainingdaysinseason:value() > 1 then
            --Progress current season
            _remainingdaysinseason:set(_remainingdaysinseason:value() - 1)
        else
            --Advance to next season
            _season:set(GetNextSeason())
            _totaldaysinseason:set(_lengths[_season:value()]:value())
            _elapseddaysinseason:set(0)
            _remainingdaysinseason:set(_totaldaysinseason:value())
			_premode = false
        end
    elseif _mode == MODES.endless then
        if _premode then
            if _remainingdaysinseason:value() > 1 then
                --Progress pre endless season
                _remainingdaysinseason:set(_remainingdaysinseason:value() - 1)
            else
                --Advance to endless season
                _season:set(GetNextSeason())
                _totaldaysinseason:set(ENDLESS_RAMP_DAYS * 2)
                _elapseddaysinseason:set(0)
                _remainingdaysinseason:set(_totaldaysinseason:value())
                _endlessdaysinseason:set(true)
                _premode = false
            end
        elseif _remainingdaysinseason:value() > ENDLESS_RAMP_DAYS then
            --Progress to peak of endless season
            _remainingdaysinseason:set(math.max(_remainingdaysinseason:value() - 1, ENDLESS_RAMP_DAYS))
        end
    else
		-- we always need to refersh the clock incase something else changed the segs
		--return
    end

    PushSeasonClockSegs()
end or nil

local OnRetreatSeason = _ismastersim and function()
    if _elapseddaysinseason:value() > 0 then
        _elapseddaysinseason:set(_elapseddaysinseason:value() - 1)
    end

    if _mode == MODES.cycle then
        if _remainingdaysinseason:value() < _totaldaysinseason:value() then
            --Regress current season
            _remainingdaysinseason:set(_remainingdaysinseason:value() + 1)
        else
            --Retreat to previous season
            _season:set(GetPrevSeason())
            _totaldaysinseason:set(_lengths[_season:value()]:value())
            _elapseddaysinseason:set(math.max(_totaldaysinseason:value() - 1, 0))
            _remainingdaysinseason:set(1)
        end
    elseif _mode == MODES.endless then
        if not _premode then
            if _remainingdaysinseason:value() < _totaldaysinseason:value() then
                --Regress endless season
                _remainingdaysinseason:set(_remainingdaysinseason:value() + 1)
            else
                --Retreat to pre endless season
                _season:set(GetPrevSeason())
                _totaldaysinseason:set(ENDLESS_PRE_DAYS * 2)
                _elapseddaysinseason:set(math.max(ENDLESS_PRE_DAYS - 1, 0))
                _remainingdaysinseason:set(1)
                _endlessdaysinseason:set(false)
                _premode = true
            end
        elseif _remainingdaysinseason:value() < ENDLESS_PRE_DAYS then
            --Regress to peak of pre endless season
            _remainingdaysinseason:set(_remainingdaysinseason:value() + 1)
        end
    else
        return
    end

    PushSeasonClockSegs()
end or nil

local OnSetSeason = _ismastersim and function(src, season)
    assert(_ismastersim, "Invalid permissions")

    season = SEASONS[season]
    if season == nil then
        return
    end

    if _season:value() ~= season then
        _season:set(season)
        _elapseddaysinseason:set(0)
    end

	UpdateSeasonMode()

    PushSeasonClockSegs()
end or nil

local OnSetSeasonClockSegs = _ismastershard and function(src, segs)
    local default = nil
    for k, v in pairs(segs) do
        default = v
        break
    end

    if default == nil then
        if segs ~= DEFAULT_CLOCK_SEGS then
            OnSetSeasonClockSegs(DEFAULT_CLOCK_SEGS)
        end
        return
    end

    for i, v in ipairs(SEASON_NAMES) do
        _segs[i] = segs[v] or default
    end

    PushSeasonClockSegs()
end or nil

local OnSetSeasonLength = _ismastersim and function(src, data)
	local season = SEASONS[data.season]
    local length = data.length

    if data.random == true and _israndom[data.season] == true then
        return
    end
    _israndom[data.season] = data.random == true

    assert(season, "Tried setting the length of an invalid season.")
    if _lengths[season]:value() == length then return end --no change
	_lengths[season]:set(length or 0)

	local p
    if _season:value() == season then
        p = 1
        if _totaldaysinseason:value() > 0 then
            p = _remainingdaysinseason:value() / _totaldaysinseason:value()
        end
    end

	UpdateSeasonMode(season)

    if _season:value() == season and _mode ~= MODES.endless and _mode ~= MODES.always then
        _remainingdaysinseason:set(math.ceil(_totaldaysinseason:value() * p))

        PushSeasonClockSegs()
    end
end or nil

local OnSetSeasonSegModifier = _ismastershard and function(src, mod)
	_segmod = mod
	PushSeasonClockSegs()
end or nil

local OnSeasonsUpdate = _ismastersim and not _ismastershard and function(srd, data)
    for i,v in ipairs(_lengths) do
        v:set(data.lengths[i])
    end
    _season:set(data.season)
    _totaldaysinseason:set(data.totaldaysinseason)
    _remainingdaysinseason:set(data.remainingdaysinseason)
    _elapseddaysinseason:set(data.elapseddaysinseason)
    _endlessdaysinseason:set(data.endlessdaysinseason)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_season:set(SEASONS.autumn)
_totaldaysinseason:set(TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT * 2)
_remainingdaysinseason:set(TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT)
_elapseddaysinseason:set(0)
_endlessdaysinseason:set(false)
for i, v in ipairs(_lengths) do
    v:set(TUNING[string.upper(SEASON_NAMES[i]).."_LENGTH"] or 0)
end

--Register network variable sync events
inst:ListenForEvent("seasondirty", OnSeasonDirty)
inst:ListenForEvent("lengthsdirty", OnLengthsDirty)

if _ismastersim then
    _mode = MODES.cycle
    _premode = false
    _segs = {}

    for i, v in ipairs(SEASON_NAMES) do
        _segs[i] = DEFAULT_CLOCK_SEGS[v]
    end

	_segmod = {day = 1, dusk = 1, night = 1}

    PushSeasonClockSegs()

    --Register master simulation events
    inst:ListenForEvent("ms_cyclecomplete", OnAdvanceSeason, _world)
    inst:ListenForEvent("ms_advanceseason", OnAdvanceSeason, _world)
    inst:ListenForEvent("ms_retreatseason", OnRetreatSeason, _world)
    inst:ListenForEvent("ms_setseason", OnSetSeason, _world)
    inst:ListenForEvent("ms_setseasonlength", OnSetSeasonLength, _world)
    inst:ListenForEvent("ms_setseasonclocksegs", OnSetSeasonClockSegs, _world)
    inst:ListenForEvent("ms_setseasonsegmodifier", OnSetSeasonSegModifier, _world)
    if not _ismastershard then
        --Register secondary shard events
        inst:ListenForEvent("secondary_seasonsupdate", OnSeasonsUpdate, _world)
    end
end


--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    local data =
    {
        mode = MODE_NAMES[_mode],
        premode = _premode,
        israndom = _israndom,
        segs = {},
        season = SEASON_NAMES[_season:value()],
        totaldaysinseason = _totaldaysinseason:value(),
        elapseddaysinseason = _elapseddaysinseason:value(),
        remainingdaysinseason = _remainingdaysinseason:value(),
        lengths = {},
    }

    for i, v in ipairs(SEASON_NAMES) do
        data.segs[v] = {}
        for k, v1 in pairs(_segs[i]) do
            data.segs[v][k] = v1
        end
        data.lengths[v] = _lengths[i]:value()
    end

    return data
end end

if _ismastersim then function self:OnLoad(data)
    for i, v in ipairs(SEASON_NAMES) do
        local segs = {}
        local totalsegs = 0

        for k, v1 in pairs(_segs[i]) do
            segs[k] = data.segs and data.segs[v] and data.segs[v][k] or 0
            totalsegs = totalsegs + segs[k]
        end

        if totalsegs == NUM_CLOCK_SEGS then
            _segs[i] = segs
        else
            _segs[i] = DEFAULT_CLOCK_SEGS[v]
        end

        _lengths[i]:set(data.lengths and data.lengths[v] or TUNING[string.upper(v).."_LENGTH"] or 0)

        _israndom[v] = data.israndom and data.israndom[v] == true
    end

    _premode = data.premode == true
    _mode = MODES[data.mode] or MODES.cycle
    _season:set(SEASONS[data.season] or SEASONS.autumn)
    _totaldaysinseason:set(data.totaldaysinseason or _lengths[_season:value()]:value())
    _elapseddaysinseason:set(data.elapseddaysinseason or 0)
    _remainingdaysinseason:set(math.min(data.remainingdaysinseason or _totaldaysinseason:value(), _totaldaysinseason:value()))
    _endlessdaysinseason:set(not _premode and _mode ~= MODES.cycle)

    PushSeasonClockSegs()
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("%s %d -> %d days (%.0f %%) %s %s", SEASON_NAMES[_season:value()], _elapseddaysinseason:value(), _endlessdaysinseason:value() and ENDLESS_DAYS or _remainingdaysinseason:value(), 100-100*(_remainingdaysinseason:value() / _totaldaysinseason:value()), MODE_NAMES[_mode] or "", _premode and "(PRE)" or "")
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
