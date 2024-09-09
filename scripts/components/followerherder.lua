local FollowerHerder = Class(function(self, inst)
    self.inst = inst
    self.hostile = true
end)

function FollowerHerder:SetCanHerdFn(fn)
    self.canherdfn = fn
end

function FollowerHerder:SetOnHerdFn(fn)
    self.onherfn = fn
end

function FollowerHerder:SetUseAmount(use_amount)
    self.use_amount = use_amount
end

function FollowerHerder:CanHerd(leader)
    if self.canherdfn then
        local can_herd, reason = self.canherdfn(self.inst, leader)
        if not can_herd then
            return false, reason
        end
    end

    return true
end

function FollowerHerder:Herd(leader)
    self.hostile = not self.hostile
    for follower, v in pairs(leader.components.leader.followers) do
        follower.hostile = self.hostile
    end

    if self.inst.components.finiteuses ~= nil then
        self.inst.components.finiteuses:Use(self.use_amount or 1)
    end

    if self.onherfn then
        self.onherfn(self.inst, leader)
    end
end

return FollowerHerder