--------------------------------------------------------------------------
--[[ Shard_Sinkholes ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Shard_Sinkholes should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_TARGETS = 2

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastershard = _world.ismastershard

--Network
local _targets = {}
for i = 1, MAX_TARGETS do
    local prefix = "shard_sinkholes._targets["..tostring(i).."]."
    table.insert(_targets, {
        userhash = net_hash(inst.GUID, prefix.."userhash", "sinkholesdirty"),
        state = net_tinybyte(inst.GUID, prefix.."state", "sinkholesdirty"),
    })
end

--------------------------------------------------------------------------
--[[ Private event listeners ]]
--------------------------------------------------------------------------

local OnSinkholesUpdate = _ismastershard and function(src, data)
    for i, v in ipairs(_targets) do
        local t = data.targets[i]
        if t == nil then
            v.userhash:set(0)
            break
        end

        local userchanged = v.userhash:value() ~= t.userhash
        if userchanged then
            v.userhash:set(t.userhash)
        end

        if t.warn then
            v.state:set_local(1)
            v.state:set(1)
        elseif t.attack then
            v.state:set(2)
        elseif userchanged or v.state:value() ~= 1 then
            v.state:set(0)
        end
    end
end or nil

local OnSinkholesDirty = not _ismastershard and function()
    local data = {}
    for i, v in ipairs(_targets) do
        if v.userhash:value() == 0 then
            break
        end

        table.insert(data, {
            userhash = v.userhash:value(),
            warn = v.state:value() == 1 or nil,
            attack = v.state:value() == 2 or nil,
        })
    end
    _world:PushEvent("secondary_sinkholesupdate", { targets = data })
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

if _ismastershard then
    --Register master shard events
    inst:ListenForEvent("master_sinkholesupdate", OnSinkholesUpdate, _world)
else
    --Register network variable sync events
    inst:ListenForEvent("sinkholesdirty", OnSinkholesDirty)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
