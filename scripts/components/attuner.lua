--For players only
--On the server, data for all the players is available
--On clients, only your local player data is available
local Attuner = Class(function(self, inst)
    self.inst = inst
    self.ismastersim = TheWorld.ismastersim
    self.attuned = {}
end)

--------------------------------------------------------------------------
--Common (but for clients, will only work for local player)

function Attuner:IsAttunedTo(target)
    if self.ismastersim then
        return self.attuned[target.GUID] ~= nil
    end

    for k, v in pairs(self.attuned) do
        if target:HasTag("ATTUNABLE_ID_"..tostring(k)) then
            return true
        end
    end
    return false
end

function Attuner:HasAttunement(tag)
    for k, v in pairs(self.attuned) do
        if v:HasTag(tag) then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------
--Server only

function Attuner:GetAttunedTarget(tag)
    if self.ismastersim then
        for k, v in pairs(self.attuned) do
            if v:HasTag(tag) then
                return Ents[k]
            end
        end
    end
end


function Attuner:TransferComponent(newinst)
    for k, v in pairs(self.attuned) do
        local ent = Ents[k]
        local attunable = ent.components.attunable
        attunable:UnlinkFromPlayer(self.inst, true)
        attunable:LinkToPlayer(newinst, true)
    end
end

--------------------------------------------------------------------------
--proxy is attunable_classifed
--proxy is always available to the attuned player, even on clients
--the actual entity may not be available on clients if it's far away
--proxy:IsAttunableType(tag) can be used on clients at any distance

--NOTE: On clients, the order for dispatching gotnewattunement
--      and attunementlost from the same frame is not reliable

function Attuner:RegisterAttunedSource(proxy)
    if not self.attuned[proxy.source_guid:value()] then
        self.attuned[proxy.source_guid:value()] = proxy
        self.inst:PushEvent("gotnewattunement", { proxy = proxy })
    end
end

function Attuner:UnregisterAttunedSource(proxy)
    if self.attuned[proxy.source_guid:value()] then
        self.attuned[proxy.source_guid:value()] = nil
        self.inst:PushEvent("attunementlost", { proxy = proxy })
    end
end

--------------------------------------------------------------------------
--Debug

function Attuner:GetDebugString()
    local str = ""
    if self.ismastersim then
        for k, v in pairs(self.attuned) do
            str = str.."\n          "..tostring(Ents[k])
        end
    else
        for k, v in pairs(self.attuned) do
            str = str.."\n          "..tostring(k)
        end
    end
    return str
end

return Attuner
