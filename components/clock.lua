--------------------------------------------------------------------------
--[[ Clock ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NUM_SEGS = 16

local PHASE_NAMES = --keep in sync with shard_clock.lua NUM_PHASES
{
    "day",
    "dusk",
    "night",
}
local PHASES = table.invert(PHASE_NAMES)

local MOON_PHASE_NAMES =
{
    "new",
    "quarter",
    "half",
    "threequarter",
    "full",
}
local MOON_PHASES = table.invert(MOON_PHASE_NAMES)
local MOON_PHASE_LENGTHS =
{
    [MOON_PHASES.new] =             1,
    [MOON_PHASES.quarter] =         3,
    [MOON_PHASES.half] =            3,
    [MOON_PHASES.threequarter] =    3,
    [MOON_PHASES.full] =            1,
}
local MOON_PHASE_CYCLE = {}
for i = 1, #MOON_PHASE_NAMES do
    for x = 1, MOON_PHASE_LENGTHS[i] do
        table.insert(MOON_PHASE_CYCLE, i)
    end
end
for i = #MOON_PHASE_NAMES - 1, 2, -1 do
    for x = 1, MOON_PHASE_LENGTHS[i] do
        table.insert(MOON_PHASE_CYCLE, i)
    end
end
MOON_PHASE_LENGTHS = nil

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _ismastershard = _world.ismastershard
local _segsdirty = true
local _cyclesdirty = true
local _phasedirty = true
local _moonphasedirty = true

--Network
local _segs = {}
for i, v in ipairs(PHASE_NAMES) do
    _segs[i] = net_smallbyte(inst.GUID, "clock._segs."..v, "segsdirty")
end
local _cycles = net_ushortint(inst.GUID, "clock._cycles", "cyclesdirty")
local _phase = net_tinybyte(inst.GUID, "clock._phase", "phasedirty")
local _moonphase = net_tinybyte(inst.GUID, "clock._moonphase", "moonphasedirty")
local _mooniswaxing = net_bool(inst.GUID, "clock._mooniswaxing", "moonphasedirty")
local _totaltimeinphase = net_float(inst.GUID, "clock._totaltimeinphase")
local _remainingtimeinphase = net_float(inst.GUID, "clock._remainingtimeinphase")

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------
function self:GetTimeUntilPhase(phase)
	local target_phase = nil
    for i, p in pairs(PHASE_NAMES) do
        if p == phase then
			target_phase = i
			break
		end
	end
	local cur_phase = _phase:value()
	if target_phase ~= nil and target_phase ~= cur_phase then
		local time = _remainingtimeinphase:value()
		
		cur_phase = (cur_phase % #PHASE_NAMES) + 1
		while (cur_phase ~= target_phase) do
			time = time + (_segs[cur_phase]:value() * TUNING.SEG_TIME)
			cur_phase = (cur_phase % #PHASE_NAMES) + 1
		end
		
		return time
	end

	return 0
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SetDefaultSegs()
    local totalsegs = 0
    for i, v in ipairs(_segs) do
        v:set(TUNING[string.upper(PHASE_NAMES[i]).."_SEGS_DEFAULT"] or 0)
        totalsegs = totalsegs + v:value()
    end

    if totalsegs ~= NUM_SEGS then
        for i, v in ipairs(_segs) do
            v:set(0)
        end
        _segs[PHASES.day]:set(NUM_SEGS)
    end
end

local function CalculateMoonPhase(cycles)
    --V2C: After waxing/waning changes, moon phase is
    --     now advanced at the beginning of each day.
    --[[
    -- don't advance the moon until nighttime
    if _phase:value() ~= PHASES.night and cycles > 0 then
        cycles = cycles - 1
    end]]

    local m = cycles % #MOON_PHASE_CYCLE
    local waxing = 2 * m < #MOON_PHASE_CYCLE
    return MOON_PHASE_CYCLE[m + 1], waxing
end

local ForceResync = _ismastersim and function(netvar)
    netvar:set_local(netvar:value())
    netvar:set(netvar:value())
end or nil

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local function OnPlayerActivated()
    _segsdirty = true
    _cyclesdirty = true
    _phasedirty = true
    _moonphasedirty = true
end

local OnSetClockSegs = _ismastersim and function(src, segs)
    local normremaining = _totaltimeinphase:value() > 0 and (_remainingtimeinphase:value() / _totaltimeinphase:value()) or 1

    if segs then
        local totalsegs = 0
        for i, v in ipairs(_segs) do
            v:set(segs[PHASE_NAMES[i]] or 0)
            totalsegs = totalsegs + v:value()
        end
        assert(totalsegs == NUM_SEGS, "Invalid number of time segs")
    else
        SetDefaultSegs()
    end

    _totaltimeinphase:set(_segs[_phase:value()]:value() * TUNING.SEG_TIME)
    _remainingtimeinphase:set(normremaining * _totaltimeinphase:value())
end or nil

local OnSetPhase = _ismastersim and function(src, phase)
    phase = PHASES[phase]
    if phase then
        _phase:set(phase)
        _totaltimeinphase:set(_segs[phase]:value() * TUNING.SEG_TIME)
        _remainingtimeinphase:set(_totaltimeinphase:value())
    end
    self:LongUpdate(0)
end or nil

local OnNextPhase = _ismastersim and function()
    _remainingtimeinphase:set(0)
    self:LongUpdate(0)
end or nil

local OnNextCycle = _ismastersim and function()
    _phase:set(#PHASE_NAMES)
    _remainingtimeinphase:set(0)
    self:LongUpdate(0)
end or nil

local OnSimUnpaused = _ismastersim and function()
    --Force resync values that client may have simulated locally
    ForceResync(_remainingtimeinphase)
end or nil

local OnClockUpdate = _ismastersim and not _ismastershard and function(src, data)
    for i, v in ipairs(_segs) do
        v:set(data.segs[i])
    end
    _cycles:set(data.cycles)
    _phase:set(data.phase)
    _moonphase:set(data.moonphase)
    _mooniswaxing:set(data.mooniswaxing)
    _totaltimeinphase:set(data.totaltimeinphase)
    _remainingtimeinphase:set(data.remainingtimeinphase)
    self:LongUpdate(0)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
SetDefaultSegs()
_cycles:set(0)
_phase:set(PHASES.day)
local moonphase, waxing = CalculateMoonPhase(_cycles:value())
_moonphase:set(moonphase)
_mooniswaxing:set(waxing)
_totaltimeinphase:set(_segs[_phase:value()]:value() * TUNING.SEG_TIME)
_remainingtimeinphase:set(_totaltimeinphase:value())

--Register network variable sync events
inst:ListenForEvent("segsdirty", function() _segsdirty = true end)
inst:ListenForEvent("cyclesdirty", function() _cyclesdirty = true end)
inst:ListenForEvent("phasedirty", function() _phasedirty = true end)
inst:ListenForEvent("moonphasedirty", function() _moonphasedirty = true end)
inst:ListenForEvent("playeractivated", OnPlayerActivated, _world)

if _ismastersim then
    --Register master simulation events
    inst:ListenForEvent("ms_setclocksegs", OnSetClockSegs, _world)
    inst:ListenForEvent("ms_setphase", OnSetPhase, _world)
    inst:ListenForEvent("ms_nextphase", OnNextPhase, _world)
    inst:ListenForEvent("ms_nextcycle", OnNextCycle, _world)
    inst:ListenForEvent("ms_simunpaused", OnSimUnpaused, _world)

    if not _ismastershard then
        --Register slave shard events
        inst:ListenForEvent("slave_clockupdate", OnClockUpdate, _world)
    end
end

inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

--[[
    Client updates time on its own, while server force syncs to correct it
    at the end of each segment.  Client cannot change segments on its own,
    and must wait for a server sync to change segments.
--]]
function self:OnUpdate(dt)
    local remainingtimeinphase = _remainingtimeinphase:value() - dt

    if remainingtimeinphase > 0 then
        --Advance time in current phase
        local numsegsinphase = _segs[_phase:value()]:value()
        local prevseg = numsegsinphase > 0 and math.ceil(_remainingtimeinphase:value() / _totaltimeinphase:value() * numsegsinphase) or 0
        local nextseg = numsegsinphase > 0 and math.ceil(remainingtimeinphase / _totaltimeinphase:value() * numsegsinphase) or 0

        if prevseg == nextseg then
            --Client and server tick independently within current segment
            _remainingtimeinphase:set_local(remainingtimeinphase)
        elseif _ismastersim then
            --Server sync to client when segment changes
            _remainingtimeinphase:set(remainingtimeinphase)
        else
            --Client must wait at end of segment for a server sync
            remainingtimeinphase = numsegsinphase > 0 and nextseg / numsegsinphase * _totaltimeinphase:value() or 0
            _remainingtimeinphase:set_local(math.min(remainingtimeinphase + .001, _remainingtimeinphase:value()))
        end
    elseif _ismastershard then
        --Advance to next phase
        _remainingtimeinphase:set_local(0)

        while _remainingtimeinphase:value() <= 0 do
            _phase:set((_phase:value() % #PHASE_NAMES) + 1)
            _totaltimeinphase:set(_segs[_phase:value()]:value() * TUNING.SEG_TIME)
            _remainingtimeinphase:set(_totaltimeinphase:value())

            if _phase:value() == 1 then
                --Advance to next cycle
                _cycles:set(_cycles:value() + 1)
                _world:PushEvent("ms_cyclecomplete", _cycles:value())
            --V2C: After waxing/waning changes, moon phase is
            --     now advanced at the beginning of each day.
            --[[
            end

            if _phase:value() == PHASES.night then
            ]]
                --Advance to next moon phase
                local moonphase, waxing = CalculateMoonPhase(_cycles:value())
                if moonphase ~= _moonphase:value() then
                    _moonphase:set(moonphase)
                end
                if waxing ~= _mooniswaxing:value() then
                    _mooniswaxing:set(waxing)
                end
            end
        end

        if remainingtimeinphase < 0 then
            self:OnUpdate(-remainingtimeinphase)
            return
        end
    else
        --Clients and slaves must wait at end of phase for a server sync
        _remainingtimeinphase:set_local(math.min(.001, _remainingtimeinphase:value()))
    end

    if _segsdirty then
        local data = {}
        for i, v in ipairs(_segs) do
            data[PHASE_NAMES[i]] = v:value()
        end
        _world:PushEvent("clocksegschanged", data)
        _segsdirty = false
    end

    if _cyclesdirty then
        _world:PushEvent("cycleschanged", _cycles:value())
        _cyclesdirty = false
    end

    if _phasedirty then
        _world:PushEvent("phasechanged", PHASE_NAMES[_phase:value()])
        _phasedirty = false
    end

    if _moonphasedirty then
        --"moonphasechanged" deprecated, still pushing for old mods
        _world:PushEvent("moonphasechanged", MOON_PHASE_NAMES[_moonphase:value()])
        _world:PushEvent("moonphasechanged2", { moonphase = MOON_PHASE_NAMES[_moonphase:value()], waxing = _mooniswaxing:value() })
        _moonphasedirty = false
    end

    local elapsedsegs = 0
    local normtimeinphase = 0
    for i, v in ipairs(_segs) do
        if _phase:value() == i then
            normtimeinphase = 1 - (_totaltimeinphase:value() > 0 and _remainingtimeinphase:value() / _totaltimeinphase:value() or 0)
            elapsedsegs = elapsedsegs + v:value() * normtimeinphase
            break
        end
        elapsedsegs = elapsedsegs + v:value()
    end
    _world:PushEvent("clocktick", { phase = PHASE_NAMES[_phase:value()], timeinphase = normtimeinphase, time = elapsedsegs / NUM_SEGS })

    if _ismastershard then
        local data =
        {
            segs = {},
            cycles = _cycles:value(),
            moonphase = _moonphase:value(),
            mooniswaxing = _mooniswaxing:value(),
            phase = _phase:value(),
            totaltimeinphase = _totaltimeinphase:value(),
            remainingtimeinphase = _remainingtimeinphase:value(),
        }
        for i, v in ipairs(_segs) do
            table.insert(data.segs, v:value())
        end
        _world:PushEvent("master_clockupdate", data)
    end
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    local data =
    {
        segs = {},
        cycles = _cycles:value(),
        phase = PHASE_NAMES[_phase:value()],
        moonphase2 = MOON_PHASE_NAMES[_moonphase:value()],
        moonwaxing = _mooniswaxing:value(),
        totaltimeinphase = _totaltimeinphase:value(),
        remainingtimeinphase = _remainingtimeinphase:value(),
    }

    for i, v in ipairs(_segs) do
        data.segs[PHASE_NAMES[i]] = v:value()
    end

    return data
end end

if _ismastersim then function self:OnLoad(data)
    local totalsegs = 0
    for i, v in ipairs(_segs) do
        v:set(data.segs and data.segs[PHASE_NAMES[i]] or 0)
        totalsegs = totalsegs + v:value()
    end

    if totalsegs ~= NUM_SEGS then
        SetDefaultSegs()
    end

    _cycles:set(data.cycles or 0)

    if PHASES[data.phase] then
        _phase:set(PHASES[data.phase])
    else
        for i, v in ipairs(_segs) do
            if v:value() > 0 then
                _phase:set(i)
                break
            end
        end
    end

    --moonphase deprecated, moonphase2 is paired with waxing
    local moonphase, waxing = data.moonphase2 ~= nil and MOON_PHASES[data.moonphase2] or nil, data.moonwaxing == true
    if moonphase == nil then
        moonphase, waxing = CalculateMoonPhase(_cycles:value())
    end
    _moonphase:set(moonphase)
    _mooniswaxing:set(waxing)
    _totaltimeinphase:set(data.totaltimeinphase or _segs[_phase:value()]:value() * TUNING.SEG_TIME)
    _remainingtimeinphase:set(math.min(data.remainingtimeinphase or _totaltimeinphase:value(), _totaltimeinphase:value()))
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:Dump()
       print("segs in day   ",  _segs[1]:value())
       print("segs in dusk  ",  _segs[2]:value())
       print("segs in night ",  _segs[3]:value())

       print("cycles ",  _cycles:value())
       print("phase ",  PHASE_NAMES[_phase:value()])
       print("moonphase2 ",  MOON_PHASE_NAMES[_moonphase:value()])
       print("moonwaxing ",  _mooniswaxing:value())
	   
       print("totaltimeinphase ",  _totaltimeinphase:value())
       print("remainingtimeinphase ",  _remainingtimeinphase:value())
       print("total segs phase ",  _totaltimeinphase:value()/TUNING.SEG_TIME)
       print("remaining segs inphase ",  _remainingtimeinphase:value()/TUNING.SEG_TIME)

	   local to_night =  _remainingtimeinphase:value() + (PHASE_NAMES[_phase:value()] == "day" and _segs[2]:value() or 0) * TUNING.SEG_TIME
	   print("Time Until Night:", to_night, to_night/TUNING.SEG_TIME)
end

function self:GetDebugString()
    return string.format("%d %s: %2.2f : %2.2f ", _cycles:value() + 1, PHASE_NAMES[_phase:value()], _remainingtimeinphase:value(), _segs[_phase:value()]:value())
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
