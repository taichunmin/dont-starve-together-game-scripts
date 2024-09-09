--------------------------------------------------------------------------
--[[ WorldState ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
assert(inst == TheWorld, "Invalid world")
self.inst = inst
self.data = {}

--Private
local _iscave = inst:HasTag("cave")
local _watchers = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SetVariable(var, val, togglename)
    if self.data[var] ~= val and val ~= nil then
        self.data[var] = val

        local watchers = _watchers[var]
        if watchers ~= nil then
            for k, v in pairs(watchers) do
                for i, fn in ipairs(v) do
                    fn[1](fn[2], val)
                end
            end
        end

        if togglename then
            watchers = _watchers[(val and "start" or "stop")..togglename]
            if watchers ~= nil then
                for k, v in pairs(watchers) do
                    for i, fn in ipairs(v) do
                        fn[1](fn[2])
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnClockTick(src, data)
    SetVariable("time", data.time)
    SetVariable("timeinphase", data.timeinphase)
end

local function OnCyclesChanged(src, cycles)
    SetVariable("cycles", cycles)
end

local function OnCavePhaseChanged(src, phase)
    SetVariable("cavephase", phase)
    SetVariable("iscaveday", phase == "day", "caveday")
    SetVariable("iscavedusk", phase == "dusk", "cavedusk")
    SetVariable("iscavenight", phase == "night", "cavenight")
    SetVariable("iscavefullmoon", phase == "night" and self.data.cavemoonphase == "full", "fullmoon")
    SetVariable("iscavenewmoon", phase == "night" and self.data.cavemoonphase == "new", "newmoon")
end

local function OnPhaseChanged(src, phase)
    SetVariable("phase", phase)
    SetVariable("isday", phase == "day", "day")
    SetVariable("isdusk", phase == "dusk", "dusk")
    SetVariable("isnight", phase == "night", "night")
    SetVariable("isfullmoon", phase == "night" and self.data.moonphase == "full", "fullmoon")
    SetVariable("isnewmoon", phase == "night" and self.data.moonphase == "new", "newmoon")
    OnCavePhaseChanged(src, phase)
end

local function OnCaveMoonPhaseChanged2(src, data)
    SetVariable("iscavewaxingmoon", data.waxing)
    SetVariable("cavemoonphase", data.moonphase)
    SetVariable("iscavefullmoon", self.data.iscavenight and data.moonphase == "full", "fullmoon")
    SetVariable("iscavenewmoon", self.data.iscavenight and data.moonphase == "new", "newmoon")
end

local function OnMoonPhaseChanged2(src, data)
    SetVariable("iswaxingmoon", data.waxing)
    SetVariable("moonphase", data.moonphase)
    SetVariable("isfullmoon", self.data.isnight and data.moonphase == "full", "fullmoon")
    SetVariable("isnewmoon", self.data.isnight and data.moonphase == "new", "newmoon")
    OnCaveMoonPhaseChanged2(src, data)
end

local function OnAlterAwake(src, data)
	if data ~= nil and data.stormtype == STORM_TYPES.MOONSTORM then
	    SetVariable("isalterawake", data.setting)
	end
end

local function OnNightmareClockTick(src, data)
    SetVariable("nightmaretime", data.time)
    SetVariable("nightmaretimeinphase", data.timeinphase)
end

local function OnNightmarePhaseChanged(src, phase)
    SetVariable("nightmarephase", phase)
    SetVariable("isnightmarecalm", phase == "calm", "nightmarecalm")
    SetVariable("isnightmarewarn", phase == "warn", "nightmarewarn")
    SetVariable("isnightmarewild", phase == "wild", "nightmarewild")
    SetVariable("isnightmaredawn", phase == "dawn", "nightmaredawn")
end

local function OnSeasonTick(src, data)
    SetVariable("season", data.season)
    SetVariable("isautumn", data.season == "autumn", "autumn")
    SetVariable("iswinter", data.season == "winter", "winter")
    SetVariable("isspring", data.season == "spring", "spring")
    SetVariable("issummer", data.season == "summer", "summer")
    SetVariable("elapseddaysinseason", data.elapseddaysinseason)
    SetVariable("remainingdaysinseason", data.remainingdaysinseason)
    SetVariable("seasonprogress", data.progress)
end

local function OnSeasonLengthsChanged(src, data)
	SetVariable("springlength", data.spring)
    SetVariable("summerlength", data.summer)
    SetVariable("autumnlength", data.autumn)
    SetVariable("winterlength", data.winter)
end

local function OnTemperatureTick(src, temperature)
    SetVariable("temperature", temperature)
end

local function OnWeatherTick(src, data)
    SetVariable("moisture", data.moisture)
    SetVariable("pop", data.pop)
    SetVariable("precipitationrate", data.precipitationrate)
    SetVariable("snowlevel", data.snowlevel)
    SetVariable("lunarhaillevel", data.lunarhaillevel)
    SetVariable("wetness", data.wetness)
end

local function OnMoistureCeilChanged(src, moistureceil)
    SetVariable("moistureceil", moistureceil)
end

local function OnPrecipitationChanged(src, preciptype)
    SetVariable("precipitation", preciptype)
    SetVariable("israining", preciptype == "rain", "rain")
    SetVariable("issnowing", preciptype == "snow", "snow")
    SetVariable("islunarhailing", preciptype == "lunarhail", "lunarhail")
    SetVariable("isacidraining", preciptype == "acidrain", "acidrain")
end

local function OnSnowCoveredChanged(src, show)
    if show then
        TheSim:ShowAnimOnEntitiesWithTag("SnowCovered", "snow")
    else
        TheSim:HideAnimOnEntitiesWithTag("SnowCovered", "snow")
    end
    SetVariable("issnowcovered", show)
end

local function OnWetChanged(src, wet)
    SetVariable("iswet", wet)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------
--[[
    World state variables are initialized to default values that can be
    used by entities if there are no world components controlling those
    variables.  e.g. If there is no season component on the world, then
    everything will run in autumn state.
--]]

--Clock
self.data.time = 0
self.data.timeinphase = 0
self.data.cycles = 0
self.data.phase = _iscave and "night" or "day"
self.data.isday = not _iscave
self.data.isdusk = false
self.data.isnight = _iscave
self.data.moonphase = "new"
self.data.iswaxingmoon = true
self.data.isfullmoon = false
self.data.isnewmoon = false
self.data.isalterawake = false

--Cave clock
self.data.cavephase = "day"
self.data.iscaveday = true
self.data.iscavedusk = false
self.data.iscavenight = false
self.data.iscavewaxingmoon = false
self.data.cavemoonphase = "new"
self.data.iscavefullmoon = false
self.data.iscavenewmoon = false

inst:ListenForEvent("clocktick", OnClockTick)
inst:ListenForEvent("cycleschanged", OnCyclesChanged)
inst:ListenForEvent("phasechanged", _iscave and OnCavePhaseChanged or OnPhaseChanged)
inst:ListenForEvent("moonphasechanged2", _iscave and OnCaveMoonPhaseChanged2 or OnMoonPhaseChanged2)

inst:ListenForEvent("ms_stormchanged", OnAlterAwake)

--Nightmareclock
self.data.nightmarephase = "none" -- note, this phase doesn't "exist", but if there is no nightmare clock, this is what you'll see.
self.data.nightmaretime = 0
self.data.nightmaretimeinphase = 0
self.data.isnightmarecalm = false
self.data.isnightmarewarn = false
self.data.isnightmarewild = false
self.data.isnightmaredawn = false

inst:ListenForEvent("nightmareclocktick", OnNightmareClockTick)
inst:ListenForEvent("nightmarephasechanged", OnNightmarePhaseChanged)

--Season
self.data.season = "autumn"
self.data.isspring = false
self.data.issummer = false
self.data.isautumn = true
self.data.iswinter = false
self.data.elapseddaysinseason = 0
self.data.seasonprogress = 0
self.data.remainingdaysinseason = math.ceil(TUNING.AUTUMN_LENGTH * .5)
self.data.autumnlength = TUNING.AUTUMN_LENGTH
self.data.winterlength = TUNING.WINTER_LENGTH
self.data.springlength = TUNING.SPRING_LENGTH
self.data.summerlength = TUNING.SUMMER_LENGTH

inst:ListenForEvent("seasontick", OnSeasonTick)
inst:ListenForEvent("seasonlengthschanged", OnSeasonLengthsChanged)

--Weather
self.data.temperature = TUNING.STARTING_TEMP
self.data.moisture = 0
self.data.moistureceil = 8 * TUNING.TOTAL_DAY_TIME
self.data.pop = 0
self.data.precipitationrate = 0
self.data.precipitation = "none"
self.data.israining = false
self.data.islunarhailing = false
self.data.isacidraining = false
self.data.issnowing = false
self.data.issnowcovered = false
self.data.snowlevel = 0
self.data.lunarhaillevel = 0
self.data.wetness = 0
self.data.iswet = false

inst:ListenForEvent("temperaturetick", OnTemperatureTick)
inst:ListenForEvent("weathertick", OnWeatherTick)
inst:ListenForEvent("moistureceilchanged", OnMoistureCeilChanged)
inst:ListenForEvent("precipitationchanged", OnPrecipitationChanged)
inst:ListenForEvent("snowcoveredchanged", OnSnowCoveredChanged)
inst:ListenForEvent("wetchanged", OnWetChanged)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetWorldAge()
	return 1 + self.data.cycles + self.data.time
end

function self:AddWatcher(var, inst, fn, target)
    local watchers = _watchers[var]
    if watchers == nil then
        watchers = {}
        _watchers[var] = watchers
    end

    local watcherfns = watchers[inst]
    if watcherfns == nil then
        watcherfns = {}
        watchers[inst] = watcherfns
    end

    table.insert(watcherfns, { fn, target })
end

function self:RemoveWatcher(var, inst, fn, target)
    local watchers = _watchers[var]
    if watchers ~= nil then
        local watcherfns = watchers[inst]
        if watcherfns ~= nil then
            if fn ~= nil then
                for i, v in ipairs(watcherfns) do
                    while fn == v[1] and (target == nil or target == v[2]) do
                        table.remove(watcherfns, i)
                        v = watcherfns[i]
                        if v == nil then
                            break
                        end
                    end
                end

                if next(watcherfns) == nil then
                    watchers[inst] = nil
                end
            else
                watchers[inst] = nil
            end
        end

        if next(watchers) == nil then
            _watchers[var] = nil
        end
    end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}
    for k, v in pairs(self.data) do
        data[k] = v
    end

    return data
end

function self:OnLoad(data)
    for k, v in pairs(data) do
        if self.data[k] ~= nil then
            self.data[k] = v
            print("setting ", k, v)
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:Dump()
    local keys = sortedKeys(self.data)
    local t = {}
    for i,key in ipairs(keys) do
        t[i] = string.format("\t%s\t%s", key, tostring(self.data[key]))
    end
    return table.concat(t, '\n')
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
