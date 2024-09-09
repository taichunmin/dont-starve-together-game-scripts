LeashAndAvoid = Class(BehaviourNode, function(self, inst, findavoidanceobjectfn, avoid_dist, homelocation, max_dist, inner_return_dist, running)
    BehaviourNode._ctor(self, "LeashAndAvoid")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
    self.returndist = inner_return_dist
    self.running = running or false
    self.findavoidanceobjectfn = findavoidanceobjectfn
    self.avoid_dist = avoid_dist
end)

function LeashAndAvoid:Visit()
    --V2C: there should be no legacy code using this behaviour, so
    --     don't support "false" like the old Leash behaviour does
    if self:GetHomePos() == nil then
        self.status = FAILED
    elseif self.status == READY then
        if self:IsInsideLeash() then
            self.status = FAILED
        else
            if self.findavoidanceobjectfn ~= nil then
                self.avoidtarget = self.findavoidanceobjectfn(self.inst)
            end
            self.inst.components.locomotor:Stop()
            self.status = RUNNING
        end
    elseif self.status == RUNNING then
        if self:IsOutsideReturnDist() then
            local hp = self:GetHomePos()

            -- V2C: copied my own hack from chaseandattackandavoid =)
            -- this is probably the biggest hack i've done in my life...
            -- ^ not true
            if self.avoidtarget ~= nil and self.avoidtarget:IsValid() then
                local pt = Point(self.inst.Transform:GetWorldPosition())
                local ap = Point(self.avoidtarget.Transform:GetWorldPosition())
                if distsq(ap, pt) < distsq(hp, pt) then
                    local delta_dir = anglediff(self.inst:GetAngleToPoint(hp), self.inst:GetAngleToPoint(ap))
                    if math.abs(delta_dir) < 45 then
                        local offset = (hp - pt):GetNormalized()
                        hp = delta_dir < 0 and
                            Point(  ap.x - offset.z * self.avoid_dist,
                                    ap.y + offset.y * self.avoid_dist,
                                    ap.z + offset.x * self.avoid_dist   ) or
                            Point(  ap.x + offset.z * self.avoid_dist,
                                    ap.y + offset.y * self.avoid_dist,
                                    ap.z - offset.x * self.avoid_dist   )
                    end
                end
            end

			local run = FunctionOrValue(self.running, self.inst)
			self.inst.components.locomotor:GoToPoint(hp, nil, run)
        else
            self.status = SUCCESS
        end
    end
end

function LeashAndAvoid:DBString()
    return string.format("%s, %2.2f, avoiding %s, %2.2f", tostring(self:GetHomePos()), math.sqrt(self:GetDistFromHomeSq() or 0), tostring(self.avoidtarget), self.avoid_dist or 0)
end

function LeashAndAvoid:GetHomePos()
    return FunctionOrValue(self.homepos, self.inst)
end

function LeashAndAvoid:GetDistFromHomeSq()
    --V2C: there should be no legacy code using this behaviour, so
    --     don't support "false" like the old Leash behaviour does
    local homepos = self:GetHomePos()
    return homepos ~= nil and distsq(homepos, self.inst:GetPosition()) or nil
end

function LeashAndAvoid:IsInsideLeash()
    return self:GetDistFromHomeSq() < self:GetMaxDistSq()
end

function LeashAndAvoid:IsOutsideReturnDist()
    return self:GetDistFromHomeSq() > self:GetReturnDistSq()
end

function LeashAndAvoid:GetMaxDistSq()
    local dist = FunctionOrValue(self.maxdist, self.inst)
    return dist * dist
end

function LeashAndAvoid:GetReturnDistSq()
    local dist = FunctionOrValue(self.returndist, self.inst)
    return dist * dist
end