local Oasis = Class(function(self, inst)
    self.inst = inst
    self.radius = 1
end)

function Oasis:IsEntityInOasis(ent)
    return ent:IsNear(self.inst, self.radius)
end

--Proximity level [0,1] based on distance from boundary
--0: at or beyond range from boundary
--1: at or within boundary
function Oasis:GetProximityLevel(ent, range)
    local distsq = ent:GetDistanceSqToInst(self.inst)
    if distsq <= self.radius * self.radius then
        return 1
    end
    local maxradius = self.radius + range
    return distsq < maxradius * maxradius
        and math.clamp(1 + (self.radius - math.sqrt(distsq)) / range, 0, 1)
        or 0
end

return Oasis
