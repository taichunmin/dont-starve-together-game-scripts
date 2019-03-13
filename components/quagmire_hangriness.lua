--------------------------------------------------------------------------
--[[ QuagmireHangriness class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_HANGRY = 6000
local SYNC_PERIOD = 10
local ACCEL_THRESHOLDS = {}
for i = 1, 15 do
    table.insert(ACCEL_THRESHOLDS, { threshold = 6000 - 25 * i, accel = .018 + .002 * i })
end
table.insert(ACCEL_THRESHOLDS, { threshold = 0, accel = .05 })

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _updating = false

--Master simulation
local _serverdata
local _syncdelay
local _rumbledelay

--Network
local _netvars =
{
    current = net_float(inst.GUID, "quagmire_hangriness._netvars.current"),
    speed = net_float(inst.GUID, "quagmire_hangriness._netvars.speed"),
    levelstart = net_float(inst.GUID, "quagmire_hangriness._netvars.levelstart", "levelstartdirty"),
    rumbled = net_bool(inst.GUID, "quagmire_hangriness._netvars.rumbled", "rumbleddirty"),
    matched = net_bool(inst.GUID, "quagmire_hangriness._netvars.matched", "matcheddirty"),
}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function TimeStr(s)
    --NOTE: this version ceils time since we're counting down
    s = math.ceil(s)
    local m = math.floor(s / 60)
    s = s - m * 60
    return tostring(m)..(s < 10 and ":0" or ":")..tostring(s)
end

local function CalcTime(v0, a, dx)
    return (math.sqrt(v0 * v0 + 2 * a * dx) - v0) / a
end

local function OnRumbled()
    _world:PushEvent("quagmirehangrinessrumbled", { major = _netvars.rumbled:value() })
    if _netvars.current:value() <= 0 and _netvars.levelstart:value() <= 0 and _netvars.speed:value() <= 0 then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/quagmire/creature/gnaw/rumble", nil, .6)
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/quagmire/creature/gnaw/eat")
    else
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/quagmire/creature/gnaw/rumble", nil, (_netvars.rumbled:value() and .15 or .1) + math.random() * .05)
    end
end

local function DoDelta(amount)
    local new = math.clamp(_netvars.current:value() + amount, 0, MAX_HANGRY)
    if _netvars.current:value() ~= new then
        _netvars.current:set_local(new)
        if _ismastersim and _serverdata.OnDoDelta(self, new, _updating) then
            _serverdata.DoRumble(_netvars, true)
            OnRumbled()
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnMatched()
    _world:PushEvent("quagmirehangrinessmatched", { matched = _netvars.matched:value() })
end

local OnCravingMatch = _ismastersim and function(src, data)
    _serverdata.OnCravingMatch(data, _netvars, DoDelta)
    if _updating then
        _netvars.current:set(_netvars.current:value())
        _netvars.levelstart:set(_netvars.current:value())
        _syncdelay = SYNC_PERIOD
    end
    if _rumbledelay ~= nil then
        _rumbledelay = _serverdata.GetRumbleDelay()
    end
    _netvars.matched:set_local(true)
    _netvars.matched:set(true)
    OnMatched()
end or nil

local OnCravingMismatch = _ismastersim and function(src, data)
    _serverdata.OnCravingMismatch(data, _netvars, DoDelta)
    if _updating then
        _netvars.current:set(_netvars.current:value())
        _netvars.levelstart:set(_netvars.current:value())
        _syncdelay = SYNC_PERIOD
    end
    if _rumbledelay ~= nil then
        _rumbledelay = _serverdata.GetRumbleDelay()
    end
    _netvars.matched:set_local(false)
    _netvars.matched:set(false)
    OnMatched()
end or nil

local function OnLevelStartDirty()
    if _netvars.levelstart:value() > 0 then
        if not _updating then
            _updating = true
            inst:StartUpdatingComponent(self)
            if _ismastersim then
                _serverdata.OnLevelStart(inst, OnCravingMatch, OnCravingMismatch)
            end
        end
    elseif _updating then
        _updating = false
        inst:StopUpdatingComponent(self)
        if _ismastersim then
            _serverdata.OnLevelStop(inst, OnCravingMatch, OnCravingMismatch)
        end
    end
end

local OnInit = not _ismastersim and function()
    inst:ListenForEvent("rumbleddirty", OnRumbled)
    inst:ListenForEvent("matcheddirty", OnMatched)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_netvars.current:set(MAX_HANGRY)
_netvars.speed:set(0)
_netvars.levelstart:set(0)
_netvars.rumbled:set(false)
_netvars.matched:set(false)

if _ismastersim then
    _serverdata = event_server_data("quagmire", "components/quagmire_hangriness")
    _serverdata.master_postinit(self, inst, _netvars, MAX_HANGRY, TimeStr)
else
    --Register network variable sync events
    inst:ListenForEvent("levelstartdirty", OnLevelStartDirty)

    inst:DoTaskInTime(0, OnInit)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetCurrent()
    return _netvars.current:value()
end

function self:GetPercent()
    return _netvars.current:value() / MAX_HANGRY
end

function self:GetLevel()
    return (_netvars.current:value() <= 0 and 3)
        or (_netvars.speed:value() >= 8 and 3)
        or (_netvars.speed:value() >= 4 and 2)
        or 1
end

function self:GetTimeRemaining()
    local dt = 0
    local v0 = _netvars.speed:value()
    local x = _netvars.current:value()
    for i, v in ipairs(ACCEL_THRESHOLDS) do
        if x > v.threshold then
            local dt1 = CalcTime(v0, v.accel, x - v.threshold)
            dt = dt + dt1
            v0 = v0 + v.accel * dt1
            x = v.threshold
        end
    end
    return dt
end

if _ismastersim then function self:Start(levelstart)
    _serverdata.OnStart(_netvars, levelstart)
    _syncdelay = SYNC_PERIOD
    _rumbledelay = _serverdata.GetRumbleDelay()
    OnLevelStartDirty()
end end

if _ismastersim then function self:Stop()
    _serverdata.OnStop(_netvars)
    _syncdelay = nil
    _rumbledelay = nil
    OnLevelStartDirty()
end end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    local dt0 = dt
    local v0 = _netvars.speed:value()
    local x = _netvars.current:value()
    for i, v in ipairs(ACCEL_THRESHOLDS) do
        if x > v.threshold then
            local dv = v.accel * dt0
            local dx = (v0 + .5 * dv) * dt0
            local dx1 = x - v.threshold
            if dx1 < dx then
                local dt1 = CalcTime(v0, v.accel, dx1)
                v0 = v0 + v.accel * dt1
                x = v.threshold
                dt0 = dt0 - dt1
            else
                v0 = v0 + v.accel * dt0
                x = x - dx
                break
            end
        end
    end
    _netvars.speed:set_local(v0)
    DoDelta(x - _netvars.current:value())

    if _rumbledelay ~= nil then
        local level = self:GetLevel()
        if level > 1 then
            local major = level > 2
            _rumbledelay = _rumbledelay - (major and dt * 1.5 or dt)
            if _rumbledelay <= 0 then
                _rumbledelay = _serverdata.GetRumbleDelay()
                _serverdata.DoRumble(_netvars, major)
                OnRumbled()
            end
        end
    end

    --Periodically force sync data to clients
    if _syncdelay ~= nil then
        _syncdelay = _syncdelay - dt
        if _syncdelay <= 0 then
            _syncdelay = _syncdelay + SYNC_PERIOD
            _serverdata.DoSync(_netvars)
        end
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
