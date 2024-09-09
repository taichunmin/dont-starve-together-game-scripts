--------------------------------------------------------------------------
--[[ ShardState ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim

--Network
local _mastersessionid = net_string(inst.GUID, "shardstate._mastersessionid", "mastersessioniddirty")

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnNewMasterSessionId = _ismastersim and function(src, session_id)
    _mastersessionid:set(session_id)
end or nil

local OnMasterSessionIdDirty = not _ismastersim and function()
    TheNet:SetClientCacheSessionIdentifier(_mastersessionid:value())
    SerializeUserSession(ThePlayer, true)
end or nil

--------------------------------------------------------------------------
--[[ Public methods ]]
--------------------------------------------------------------------------

function self:GetMasterSessionId()
    return _mastersessionid:value()
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_mastersessionid:set(_world.meta.session_identifier)

if _ismastersim then
    --Register master simulation events
    inst:ListenForEvent("ms_newmastersessionid", OnNewMasterSessionId, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("mastersessioniddirty", OnMasterSessionIdDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
