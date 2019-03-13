PanicAndAvoid = Class(BehaviourNode, function(self, inst, findavoidanceobjectfn, avoid_dist)
    BehaviourNode._ctor(self, "PanicAndAvoid")
    self.inst = inst
    self.waittime = 0
    self.findavoidanceobjectfn = findavoidanceobjectfn
    self.avoid_dist = avoid_dist
end)

function PanicAndAvoid:Visit()
    if self.status == READY then
        if self.findavoidanceobjectfn ~= nil then
            self.avoidtarget = self.findavoidanceobjectfn(self.inst)
        end
        self:PickNewDirection()
        self.status = RUNNING
    else
        if GetTime() > self.waittime then
            self:PickNewDirection()
        else
            local rot = self.inst.Transform:GetRotation()
            local newrot = self:ResolveDirection(rot)
            if rot ~= newrot then
                self.inst.components.locomotor:RunInDirection(newrot)
            end
        end
    end
end

function PanicAndAvoid:PickNewDirection()
    self.inst.components.locomotor:RunInDirection(self:ResolveDirection(math.random() * 360))
    self.waittime = GetTime() + .25 + math.random() * .25
end

function PanicAndAvoid:ResolveDirection(rot)
    if self.avoidtarget ~= nil and self.avoidtarget:IsValid() then
        local pt = Point(self.inst.Transform:GetWorldPosition())
        local ap = Point(self.avoidtarget.Transform:GetWorldPosition())
        local dist = self.avoid_dist * 2
        if distsq(ap, pt) < dist * dist then
            local delta_dir = anglediff(rot, self.inst:GetAngleToPoint(ap))
            if math.abs(delta_dir) < 45 then
                local angle = rot * DEGREES
                return delta_dir < 0
                    and self.inst:GetAngleToPoint(ap.x + math.sin(angle) * self.avoid_dist, pt.y, ap.z + math.cos(angle) * self.avoid_dist)
                    or self.inst:GetAngleToPoint(ap.x - math.sin(angle) * self.avoid_dist, pt.y, ap.z - math.cos(angle) * self.avoid_dist)
            end
        end
    end
    return rot
end
