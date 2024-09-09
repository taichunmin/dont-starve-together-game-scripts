--------------------------------------------------------------------------
--[[ Shard_Clock ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_Clock should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NUM_PHASES = 3 --keep in sync with clock.lua PHASE_NAMES table

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard

--Network
local _segs = {}
for i = 1, NUM_PHASES do
    table.insert(_segs, net_smallbyte(inst.GUID, "shard_clock.segs["..tostring(i).."]"))
end
local _cycles = net_ushortint(inst.GUID, "shard_clock._cycles", "clockdirty")
local _phase = net_tinybyte(inst.GUID, "shard_clock._phase", "clockdirty")
local _moonphase = net_tinybyte(inst.GUID, "shard_clock._moonphase", "clockdirty")
local _mooniswaxing = net_bool(inst.GUID, "shard_clock._mooniswaxing", "clockdirty")
local _totaltimeinphase = net_float(inst.GUID, "shard_clock._totaltimeinphase", "clockdirty")
local _remainingtimeinphase = net_float(inst.GUID, "shard_clock._remainingtimeinphase", "clockdirty")

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnClockUpdate = _ismastershard and function(src, data)
    local dirty = false

    for i, v in ipairs(_segs) do
        if v:value() ~= data.segs[i] then
            v:set(data.segs[i])
            dirty = true
        end
    end

    if _cycles:value() ~= data.cycles then
        _cycles:set(data.cycles)
        dirty = true
    end

    if _phase:value() ~= data.phase then
        _phase:set(data.phase)
        dirty = true
    end

    if _moonphase:value() ~= data.moonphase then
        _moonphase:set(data.moonphase)
        dirty = true
    end

    if _mooniswaxing:value() ~= data.mooniswaxing then
        _mooniswaxing:set(data.mooniswaxing)
        dirty = true
    end

    if _totaltimeinphase:value() ~= data.totaltimeinphase then
        _totaltimeinphase:set(data.totaltimeinphase)
        dirty = true
    end

    if dirty then
        _remainingtimeinphase:set(data.remainingtimeinphase)
    else
        _remainingtimeinphase:set_local(data.remainingtimeinphase)
    end
end or nil

local OnClockDirty = not _ismastershard and function()
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
    _world:PushEvent("secondary_clockupdate", data)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Register master shard events
    inst:ListenForEvent("master_clockupdate", OnClockUpdate, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("clockdirty", OnClockDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
