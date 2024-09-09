--------------------------------------------------------------------------
--[[ Shard_Players ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_Players should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard
local _localPlayerTable = {}
local _localPlayers = 0
local _localGhosts = 0
local _localDirty = true
local _secondaryShardPlayers = 0
local _secondaryShardGhosts = 0
local _secondaryShardDirty = true
local _task = nil

--Network
local _numPlayers = net_byte(inst.GUID, "shard_players._numPlayers", "playercountsdirty")
local _numGhosts = net_byte(inst.GUID, "shard_players._numGhosts", "playercountsdirty")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local UpdatePlayerCounts = _ismastershard and function()
    _task = nil

    if _localDirty then
        _localPlayers, _localGhosts = 0, 0
        for i, v in ipairs(AllPlayers) do
            _localPlayers = _localPlayers + 1
            if v:HasTag("playerghost") then
                _localGhosts = _localGhosts + 1
            end
        end
        _localDirty = false
    end

    if _secondaryShardDirty then
        _secondaryShardPlayers, _secondaryShardGhosts = TheShard:GetSecondaryShardPlayerCounts(USERFLAGS.IS_GHOST)
        _secondaryShardDirty = false
    end

    _numPlayers:set(_localPlayers + _secondaryShardPlayers)
    _numGhosts:set(_localGhosts + _secondaryShardGhosts)
end or nil

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnSecondaryShardPlayersChanged = _ismastershard and function()
    _secondaryShardDirty = true
    if _task == nil then
        _task = inst:DoTaskInTime(0, UpdatePlayerCounts)
    end
end or nil

local OnLocalPlayersChanged = _ismastershard and function()
    _localDirty = true
    if _task == nil then
        _task = inst:DoTaskInTime(0, UpdatePlayerCounts)
    end
end or nil

local OnPlayerSpawn = _ismastershard and function(src, player)
    if not _localPlayerTable[player] then
        _localPlayerTable[player] = true
        inst:ListenForEvent("ms_becameghost", OnLocalPlayersChanged, player)
        inst:ListenForEvent("ms_respawnedfromghost", OnLocalPlayersChanged, player)
        _secondaryShardDirty = true --cuz we might just be swapping from local to secondary status
        OnLocalPlayersChanged()
    end
end or nil

local OnPlayerLeft = _ismastershard and function(src, player)
    if _localPlayerTable[player] then
        _localPlayerTable[player] = nil
        inst:RemoveEventCallback("ms_becameghost", OnLocalPlayersChanged, player)
        inst:RemoveEventCallback("ms_respawnedfromghost", OnLocalPlayersChanged, player)
        _secondaryShardDirty = true --cuz we might just be swapping from local to secondary status
        OnLocalPlayersChanged()
    end
end or nil

local function OnPlayerCountsDirty()
    _world:PushEvent("ms_playercounts",
    {
        total = _numPlayers:value(),
        ghosts = _numGhosts:value(),
        alive = _numPlayers:value() - _numGhosts:value(),
    })
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Register master shard events
    inst:ListenForEvent("master_secondaryplayerschanged", OnSecondaryShardPlayersChanged, _world)
    inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn, _world)
    inst:ListenForEvent("ms_playerleft", OnPlayerLeft, _world)

    --Initialize network variables
    for i, v in ipairs(AllPlayers) do
        OnPlayerSpawn(nil, v)
    end
    if _task ~= nil then
        _task:Cancel()
    end
    UpdatePlayerCounts()
end

--Register network variable sync events
inst:ListenForEvent("playercountsdirty", OnPlayerCountsDirty)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:GetNumPlayers()
    return _numPlayers:value()
end

function self:GetNumGhosts()
    return _numGhosts:value()
end

function self:GetNumAlive()
    return _numPlayers:value() - _numGhosts:value()
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
