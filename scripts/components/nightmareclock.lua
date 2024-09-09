--------------------------------------------------------------------------
--[[ Clock ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local PHASE_NAMES =
{
    "calm",
    "warn",
    "wild",
    "dawn",
}
local PHASES = table.invert(PHASE_NAMES)

local SOUNDS =
{
    calm = {
        sound = nil,
        param = 0,
    },
    warn = {
        sound = "dontstarve/cave/nightmare_warning",
        param = 1,
    },
    wild = {
        sound = "dontstarve/cave/nightmare_full",
        param = 2,
    },
    dawn = {
        sound = "dontstarve/cave/nightmare_end",
        param = 1,
    },
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _phasedirty = true
local _activatedplayer = nil

--Master simulation
local _lockedphase = nil

--Network
local _segs = {}
for i, v in ipairs(PHASE_NAMES) do
    _segs[i] = net_smallbyte(inst.GUID, "nightmareclock._segs."..v )
end
local _phase = net_tinybyte(inst.GUID, "nightmareclock._phase", "nightmarephasedirty")
local _totaltimeinphase = net_float(inst.GUID, "nightmareclock._totaltimeinphase")
local _remainingtimeinphase = net_float(inst.GUID, "nightmareclock._remainingtimeinphase")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetLocalAmbientPhase()
    return _activatedplayer.components.areaaware ~= nil
        and _activatedplayer.components.areaaware:CurrentlyInTag("Nightmare")
        and PHASE_NAMES[_phase:value()]
        or "calm"
end

local function UpdateAmbientSounds()
    if _activatedplayer == nil then
        return
    end

    local phase = GetLocalAmbientPhase()
    local param = SOUNDS[phase].param
    if param > 0 and not _world.SoundEmitter:PlayingSound("nightmare_loop") then
        _world.SoundEmitter:PlaySound("dontstarve/cave/nightmare", "nightmare_loop")
    elseif param == 0 and _world.SoundEmitter:PlayingSound("nightmare_loop") then
        _world.SoundEmitter:KillSound("nightmare_loop")
    end

    _world.SoundEmitter:SetParameter("nightmare_loop", "nightmare", param)
end

local function UpdateWorldSounds()
    if _activatedplayer == nil then
        return
    end

    local phase = GetLocalAmbientPhase()
    local sound = SOUNDS[phase].sound
    if sound ~= nil then
        _world.SoundEmitter:PlaySound(sound)
    end

    UpdateAmbientSounds()
end

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local function OnPlayerAreaChanged(player, area)
    UpdateAmbientSounds()
end

local function OnPlayerActivated(src, player)
    _activatedplayer = player

    _activatedplayer:ListenForEvent("changearea", OnPlayerAreaChanged)

    _phasedirty = true
end

local function OnPlayerDeactivated(src, player)
    if _activatedplayer == player then
        _activatedplayer:RemoveEventCallback("changearea", OnPlayerAreaChanged)
        _activatedplayer = nil
    end
end

local function SetDefaultLengths()
    for i, v in ipairs(_segs) do
        v:set(TUNING.NIGHTMARE_SEGS[string.upper(PHASE_NAMES[i])] or 0)
    end
end

local OnSetSegs = _ismastersim and function(src, lengths)
    local normremaining = _totaltimeinphase:value() > 0 and (_remainingtimeinphase:value() / _totaltimeinphase:value()) or 1

    if lengths then
        local totalsegs = 0
        for i, v in ipairs(_segs) do
            v:set(lengths[PHASE_NAMES[i]] or 0)
        end
    else
        SetDefaultLengths()
    end

    local resulttime = _segs[_phase:value()]:value() * TUNING.SEG_TIME + math.random() * TUNING.NIGHTMARE_SEG_VARIATION * TUNING.SEG_TIME
    _totaltimeinphase:set(resulttime)
    _remainingtimeinphase:set(normremaining * _totaltimeinphase:value())
end or nil

local OnSetPhase = _ismastersim and function(src, phase)
    if _lockedphase ~= nil then
        return
    end
    phase = PHASES[phase]
    if phase ~= nil then
        _phase:set(phase)
        local resulttime = _segs[_phase:value()]:value() * TUNING.SEG_TIME + math.random() * TUNING.NIGHTMARE_SEG_VARIATION * TUNING.SEG_TIME
        _totaltimeinphase:set(resulttime)
        _remainingtimeinphase:set(_totaltimeinphase:value())
    end
    self:LongUpdate(0)
end or nil

local OnNextPhase = _ismastersim and function()
    if _lockedphase ~= nil then
        return
    end
    _remainingtimeinphase:set(0)
    self:LongUpdate(0)
end or nil

local OnNextCycle = _ismastersim and function()
    if _lockedphase ~= nil then
        return
    end
    _phase:set(#PHASE_NAMES)
    _remainingtimeinphase:set(0)
    self:LongUpdate(0)
end or nil

local OnLockNightmarePhase = _ismastersim and function(src, phase)
    _lockedphase = PHASES[phase]
    if _lockedphase ~= nil then
        _phase:set(_lockedphase)
        local resulttime = _segs[_phase:value()]:value() * TUNING.SEG_TIME + math.random() * TUNING.NIGHTMARE_SEG_VARIATION * TUNING.SEG_TIME
        _totaltimeinphase:set(resulttime)
        _remainingtimeinphase:set(0)
    end
    self:LongUpdate(0)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
SetDefaultLengths()
_phase:set(PHASES.calm)
_totaltimeinphase:set(_segs[_phase:value()]:value() * TUNING.SEG_TIME)
_remainingtimeinphase:set(_totaltimeinphase:value())

--Register network variable sync events
inst:ListenForEvent("nightmarephasedirty", function() _phasedirty = true end)
inst:ListenForEvent("playeractivated", OnPlayerActivated, _world)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated, _world)

if _ismastersim then
    --Register master simulation events
    inst:ListenForEvent("ms_setnightmaresegs", OnSetSegs, _world)
    inst:ListenForEvent("ms_setnightmarephase", OnSetPhase, _world)
    inst:ListenForEvent("ms_nextnightmarephase", OnNextPhase, _world)
    inst:ListenForEvent("ms_nextnightmarecycle", OnNextCycle, _world)
    inst:ListenForEvent("ms_locknightmarephase", OnLockNightmarePhase, _world)
end

inst:StartUpdatingComponent(self)


--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    local remainingtimeinphase = _remainingtimeinphase:value() - dt

    if remainingtimeinphase > 0 then
        --Advance time in current phase
        --Server sync to client only when phase changes
        _remainingtimeinphase:set_local(remainingtimeinphase)
    elseif _ismastersim then
        --Advance to next phase
        _remainingtimeinphase:set_local(0)

        if _lockedphase == nil then
            while _remainingtimeinphase:value() <= 0 do
                _phase:set((_phase:value() % #PHASE_NAMES) + 1)
                local resulttime = _segs[_phase:value()]:value() * TUNING.SEG_TIME + math.random() * TUNING.NIGHTMARE_SEG_VARIATION * TUNING.SEG_TIME
                _totaltimeinphase:set(resulttime)
                _remainingtimeinphase:set(_totaltimeinphase:value())
            end

            if remainingtimeinphase < 0 then
                self:OnUpdate(-remainingtimeinphase)
                return
            end
        end
    else
        --Clients and secondary shards must wait at end of phase for a server sync
        _remainingtimeinphase:set_local(math.min(.001, _remainingtimeinphase:value()))
    end

    if _phasedirty then
        _world:PushEvent("nightmarephasechanged", PHASE_NAMES[_phase:value()])
        UpdateWorldSounds()
        _phasedirty = false
    end

    local elapsedtime = 0
    local normtimeinphase = 0
    for i, v in ipairs(_segs) do
        if _phase:value() == i then
            normtimeinphase = 1 - (_totaltimeinphase:value() > 0 and _remainingtimeinphase:value() / _totaltimeinphase:value() or 0)
            elapsedtime = elapsedtime + v:value() * normtimeinphase * TUNING.SEG_TIME
            break
        end
        elapsedtime = elapsedtime + v:value() * TUNING.SEG_TIME
    end
    _world:PushEvent("nightmareclocktick", { phase = PHASE_NAMES[_phase:value()], timeinphase = normtimeinphase, time = elapsedtime })
end

self.LongUpdate = self.OnUpdate

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
    local data =
    {
        lengths = {},
        phase = PHASE_NAMES[_phase:value()],
        totaltimeinphase = _totaltimeinphase:value(),
        remainingtimeinphase = _remainingtimeinphase:value(),
        lockedphase = _lockedphase ~= nil and PHASE_NAMES[_lockedphase] or nil,
    }

    for i, v in ipairs(_segs) do
        data.lengths[PHASE_NAMES[i]] = v:value()
    end

    return data
end end

if _ismastersim then function self:OnLoad(data)
    for i, v in ipairs(_segs) do
        v:set(data.lengths and data.lengths[PHASE_NAMES[i]] or 0)
    end

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

    _totaltimeinphase:set(data.totaltimeinphase or _segs[_phase:value()]:value() * TUNING.SEG_TIME)
    _remainingtimeinphase:set(math.min(data.remainingtimeinphase or _totaltimeinphase:value(), _totaltimeinphase:value()))
    _lockedphase = data.lockedphase ~= nil and PHASES[data.lockedphase] or nil
end end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("%s: %2.2f ", PHASE_NAMES[_phase:value()], _remainingtimeinphase:value())
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
