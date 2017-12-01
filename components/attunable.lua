local Attunable = Class(function(self, inst)
    self.inst = inst

    inst:AddTag("ATTUNABLE_ID_"..tostring(inst.GUID))

    self.attuned_players = {} --attuned and online
    self.attuned_userids = {} --attuned but not online

    --Tag specifies what group this belongs to since you
    --can only attune to one entity at a time per group.
    --e.g. Players can only attune one remoteresurrector
    --     at a time.
    --Tag can also be used in Attuner:HasAttunement(tag)
    self.attunable_tag = nil

    self.onattunecostfn = nil
    self.onlinkfn = nil
    self.onunlinkfn = nil

    self.onplayerattuned = function(player, data)
        if data.prefab == inst.prefab then
            --Player has attuned to another of the same prefab
            self:UnlinkFromPlayer(player, data.isloading)
        end
    end

    self.onplayerremoved = function(player)
        self.attuned_userids[player.userid] = true
        self.attuned_players[player] = nil
    end

    self.onplayerjoined = function(world, player)
        if self.attuned_userids[player.userid] then
            self.attuned_userids[player.userid] = nil
            self:LinkToPlayer(player, true)
        end
    end

    self.inst:ListenForEvent("ms_playerjoined", self.onplayerjoined, TheWorld)
end)

function Attunable:OnRemoveEntity()
    self.inst:RemoveTag("ATTUNABLE_ID_"..tostring(self.inst.GUID))
    self.inst:RemoveEventCallback("ms_playerjoined", self.onplayerjoined, TheWorld)
    local toremove = {}
    for k, v in pairs(self.attuned_players) do
        table.insert(toremove, k)
    end
    for i, v in ipairs(toremove) do
        self:UnlinkFromPlayer(v)
    end
end

Attunable.OnRemoveFromEntity = Attunable.OnRemoveEntity

function Attunable:GetAttunableTag()
    return self.attunable_tag
end

function Attunable:SetAttunableTag(tag)
    self.attunable_tag = tag
end

function Attunable:SetOnAttuneCostFn(fn)
    self.onattunecostfn = fn
end

function Attunable:SetOnLinkFn(fn)
    self.onlinkfn = fn
end

function Attunable:SetOnUnlinkFn(fn)
    self.onunlinkfn = fn
end

function Attunable:IsAttuned(player)
    return self.attuned_players[player] ~= nil
end

function Attunable:CanAttune(player)
    return player.userid ~= nil and string.len(player.userid) > 0 and player.components.attuner ~= nil and not self:IsAttuned(player)
end

function Attunable:LinkToPlayer(player, isloading)
    if not self:CanAttune(player) then
        return false
    end

    if not isloading and self.onattunecostfn ~= nil then
        local success, reason = self.onattunecostfn(self.inst, player)
        if not success then
            return false, reason
        end
    end

    self.attuned_players[player] = SpawnPrefab("attunable_classified")
    if self.attunable_tag ~= nil then
        self.attuned_players[player]:AddTag(self.attunable_tag)
    end
    self.attuned_players[player]:AttachToPlayer(player, self.inst)

    player:PushEvent("attuned", { prefab = self.inst.prefab, isloading = isloading })
    self.inst:ListenForEvent("onremove", self.onplayerremoved, player)
    self.inst:ListenForEvent("attuned", self.onplayerattuned, player)

    if self.onlinkfn ~= nil then
        self.onlinkfn(self.inst, player, isloading)
    end
    return true
end

function Attunable:UnlinkFromPlayer(player, isloading)
    if not self:IsAttuned(player) then
        return
    end

    self.attuned_players[player]:Remove()
    self.attuned_players[player] = nil

    self.inst:RemoveEventCallback("onremove", self.onplayerremoved, player)
    self.inst:RemoveEventCallback("attuned", self.onplayerattuned, player)

    if self.onunlinkfn ~= nil then
        self.onunlinkfn(self.inst, player, isloading)
    end
end

function Attunable:OnSave()
    local userids = {}
    for k, v in pairs(self.attuned_players) do
        table.insert(userids, k.userid)
    end
    for k, v in pairs(self.attuned_userids) do
        table.insert(userids, k)
    end
    return #userids > 0 and { links = userids } or nil
end

function Attunable:OnLoad(data)
    if data ~= nil and data.links ~= nil and #data.links > 0 then
        local available_players = {}
        for i, v in ipairs(AllPlayers) do
            if v.userid ~= nil and string.len(v.userid) > 0 then
                available_players[v.userid] = v
            end
        end
        for i, v in ipairs(data.links) do
            if available_players[v] ~= nil then
                self:LinkToPlayer(available_players[v], true)
            else
                self.attuned_userids[v] = true
            end
        end
    end
end

function Attunable:GetDebugString()
    local str = "\n          online:"
    if next(self.attuned_players) ~= nil then
        for k, v in pairs(self.attuned_players) do
            str = str.."\n               "..k.name.." ("..tostring(k)..")"
        end
    end
    str = str.."\n          offline:"
    if next(self.attuned_userids) ~= nil then
        for k, v in pairs(self.attuned_userids) do
            str = str.."\n               "..k
        end
    end
    return str
end

return Attunable
