Leash = Class(BehaviourNode, function(self, inst, homelocation, max_dist, inner_return_dist, running)
    BehaviourNode._ctor(self, "Leash")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
    self.returndist = inner_return_dist
    self.running = running or false
end)

function Leash:Visit()
    --V2C: legacy code may still be returning "false" instead of nil
    if not self:GetHomePos() then
        self.status = FAILED
    elseif self.status == READY then
        if self:IsInsideLeash() then
            self.status = FAILED
        else
            self.inst.components.locomotor:Stop()
            self.status = RUNNING
        end
    elseif self.status == RUNNING then
        if self:IsOutsideReturnDist() then
            local run = FunctionOrValue(self.running, self.inst)
            self.inst.components.locomotor:GoToPoint(self:GetHomePos(), nil, run)
        else
            self.status = SUCCESS
        end
    end
end

function Leash:DBString()
    return string.format("%s, %2.2f", tostring(self:GetHomePos()), math.sqrt(self:GetDistFromHomeSq() or 0))
end

function Leash:GetHomePos()
    return FunctionOrValue(self.homepos, self.inst)
end

function Leash:GetDistFromHomeSq()
    --V2C: legacy code may still be returning "false" instead of nil
    local homepos = self:GetHomePos()
    return homepos and distsq(homepos, self.inst:GetPosition()) or nil
end

function Leash:IsInsideLeash()
    return self:GetDistFromHomeSq() < self:GetMaxDistSq()
end

function Leash:IsOutsideReturnDist()
    return self:GetDistFromHomeSq() > self:GetReturnDistSq()
end

function Leash:GetMaxDistSq()
    local dist = FunctionOrValue(self.maxdist, self.inst)
    return dist * dist
end

function Leash:GetReturnDistSq()
    local dist = FunctionOrValue(self.returndist, self.inst)
    return dist * dist
end
