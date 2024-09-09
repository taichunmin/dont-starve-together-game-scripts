--------------------------------------------------------------------------
--[[ Shard_AutoSaver ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_AutoSaver should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard

--Network
local _snapshot = net_uint(inst.GUID, "shard_autosaver._snapshot", "snapshotdirty")

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnAutoSaverUpdate = _ismastershard and function(src, data)
    _snapshot:set(data.snapshot)
end or nil

local OnSnapshotDirty = not _ismastershard and function()
    _world:PushEvent("secondary_autosaverupdate", { snapshot = _snapshot:value() })
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Initialize variables
    _snapshot:set(TheNet:GetCurrentSnapshot())

    --Register master shard events
    inst:ListenForEvent("master_autosaverupdate", OnAutoSaverUpdate, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("snapshotdirty", OnSnapshotDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
