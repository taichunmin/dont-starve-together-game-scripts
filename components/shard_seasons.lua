--------------------------------------------------------------------------
--[[ Shard_Seasons ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_Seasons should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NUM_SEASONS = 4 --keep in sync with seasons.lua SEASON_NAMES table

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard

--Network
local _lengths = {}
for i = 1, NUM_SEASONS do
    table.insert(_lengths, net_byte(inst.GUID, "shard_seasons.lengths["..tostring(i).."]"))
end
local _season = net_tinybyte(inst.GUID, "shard_seasons._season", "seasonsdirty")
local _totaldaysinseason = net_byte(inst.GUID, "shard_seasons._totaldaysinseason", "seasonsdirty")
local _remainingdaysinseason = net_byte(inst.GUID, "shard_seasons._remainingdaysinseason", "seasonsdirty")
local _elapseddaysinseason = net_ushortint(inst.GUID, "shard_seasons._elapseddaysinseason", "seasonsdirty")
local _endlessdaysinseason = net_bool(inst.GUID, "shard_seasons._endlessdaysinseason", "seasonsdirty")

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnSeasonsUpdate = _ismastershard and function(src, data)
    local dirty = false

    for i, v in ipairs(_lengths) do
        if v:value() ~= data.lengths[i] then
            v:set(data.lengths[i])
            dirty = true
        end
    end

    if _season:value() ~= data.season then
        _season:set(data.season)
        dirty = true
    end

    if _totaldaysinseason:value() ~= data.totaldaysinseason then
        _totaldaysinseason:set(data.totaldaysinseason)
        dirty = true
    end

    if _remainingdaysinseason:value() ~= data.remainingdaysinseason then
        _remainingdaysinseason:set(data.remainingdaysinseason)
        dirty = true
    end

    if _elapseddaysinseason:value() ~= data.elapseddaysinseason then
        _elapseddaysinseason:set(data.elapseddaysinseason)
        dirty = true
    end

    if _endlessdaysinseason:value() ~= data.endlessdaysinseason then
        _endlessdaysinseason:set(data.endlessdaysinseason)
        dirty = true
    end

    if dirty then
    end
end or nil

local OnSeasonsDirty = not _ismastershard and function()
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
    _world:PushEvent("secondary_seasonsupdate", data)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Register master shard events
    inst:ListenForEvent("master_seasonsupdate", OnSeasonsUpdate, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("seasonsdirty", OnSeasonsDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
