local Follower = Class(function(self, inst)
    self.inst = inst

    self._leader = net_entity(inst.GUID, "follower._leader")
end)

function Follower:SetLeader(leader)
    self._leader:set(leader)
end

function Follower:GetLeader()
    return self._leader:value()
end

return Follower