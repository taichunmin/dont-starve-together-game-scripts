--------------------------------------------------------------------------
--[[ Shard_WorldVoter ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_WorldVoter should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_SLOTS = 64

--Keep in sync with playervoter.lua and worldvoter.lua
local CANNOT_VOTE = 0
local VOTE_PENDING = MAX_VOTE_OPTIONS + 1

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard

--Network
local _enabled = net_bool(inst.GUID, "shard_worldvoter._enabled", "voterenableddirty")
local _countdown = net_byte(inst.GUID, "shard_worldvoter._countdown", "voterdirty")
local _commandid = net_uint(inst.GUID, "shard_worldvoter._commandid", "voterdirty")
local _targetuserid = net_string(inst.GUID, "shard_worldvoter._targetuserid", "voterdirty")
local _starteruserid = net_string(inst.GUID, "shard_worldvoter._starteruserid", "voterdirty")
local _voters = {}
local _squelchedpool
local _squelched = {}
for i = 1, MAX_SLOTS do
    table.insert(_voters, {
        userid = net_string(inst.GUID, "shard_worldvoter._voters["..tostring(i).."].userid", "voterdirty"),
        selection = net_tinybyte(inst.GUID, "shard_worldvoter._voters["..tostring(i).."].selection", "voterdirty"),
    })
    table.insert(_squelched, net_string(inst.GUID, "shard_worldvoter._squelched["..tostring(i).."]", "squelcheddirty"))
end

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnVoterEnabled = _ismastershard and function(src, data)
    _enabled:set(data)
end

local OnVoterEnabledDirty = not _ismastershard and function()
    _world:PushEvent("secondary_worldvoterenabled", _enabled:value())
end

local OnVoterUpdate = _ismastershard and function(src, data)
    _countdown:set(data.countdown)
    _commandid:set(data.commandid)
    _targetuserid:set(data.targetuserid)
    _starteruserid:set(data.starteruserid)

    local i = 1

    if data.voters ~= nil then
        for k, v in pairs(data.voters) do
            _voters[i].userid:set(k)
            _voters[i].selection:set(v)
            if i >= #_voters then
                return
            end
            i = i + 1
        end
    end

    for j = i, #_voters do
        _voters[j].userid:set("")
        _voters[j].selection:set(CANNOT_VOTE)
    end
end or nil

local OnVoterDirty = not _ismastershard and function()
    local voters = {}
    for i, v in ipairs(_voters) do
        if v.userid:value():len() <= 0 then
            break
        end
        voters[v.userid:value()] = v.selection:value()
    end
    _world:PushEvent("secondary_worldvoterupdate", {
        countdown = _countdown:value(),
        commandid = _commandid:value(),
        targetuserid = _targetuserid:value(),
        starteruserid = _starteruserid:value(),
        voters = next(voters) ~= nil and voters or nil,
    })
end or nil

local OnSquelchedUpdate = _ismastershard and function(src, data)
    local alreadysquelched = {}
    for i = #_squelched, 1, -1 do
        local v = _squelched[i]
        if data.squelched[v:value()] then
            alreadysquelched[v:value()] = true
        else
            v:set("")
            table.insert(_squelchedpool, table.remove(_squelched, i))
        end
    end
    for k, v in pairs(data.squelched) do
        if v and not alreadysquelched[k] then
            alreadysquelched[k] = true
            local netvar = table.remove(_squelchedpool)
            netvar:set(k)
            table.insert(_squelched, netvar)
        end
    end
end or nil

local OnSquelchedDirty = not _ismastershard and function()
    local squelched = {}
    for i, v in ipairs(_squelched) do
        if v:value():len() > 0 then
            squelched[v:value()] = true
        end
    end
    _world:PushEvent("secondary_worldvotersquelchedupdate", {
        squelched = next(squelched) ~= nil and squelched or nil,
    })
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Initialize master simulation variables
    _squelchedpool = _squelched
    _squelched = {}

    --Register master shard events
    inst:ListenForEvent("master_worldvoterenabled", OnVoterEnabled, _world)
    inst:ListenForEvent("master_worldvoterupdate", OnVoterUpdate, _world)
    inst:ListenForEvent("master_worldvotersquelchedupdate", OnSquelchedUpdate, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("voterenableddirty", OnVoterEnabledDirty)
    inst:ListenForEvent("voterdirty", OnVoterDirty)
    inst:ListenForEvent("squelcheddirty", OnSquelchedDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
