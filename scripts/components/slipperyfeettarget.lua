local SlipperyFeetTarget = Class(function(self, inst)
    self.inst = inst

    --self.isslipperyatfeetfn = nil
    --self.ratefn = nil

    -- NOTES(JBK): Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("slipperyfeettarget")
end)

function SlipperyFeetTarget:OnRemoveFromEntity()
    self.inst:RemoveTag("slipperyfeettarget")
end

function SlipperyFeetTarget:SetIsSlipperyAtPoint(fn)
    self.isslipperyatfeetfn = fn
end

function SlipperyFeetTarget:IsSlipperyAtPosition(x, y, z)
    if self.isslipperyatfeetfn ~= nil then
        return self.isslipperyatfeetfn(self.inst, x, y, z)
    end

    if self.inst.Physics ~= nil then
        local r = self.inst.Physics:GetRadius()
        local ex, ey, ez = self.inst.Transform:GetWorldPosition()
        local dx, dz = ex - x, ez - z
        return dx * dx + dz * dz < r * r
    end

    return false
end

function SlipperyFeetTarget:SetSlipperyRate(fn)
    self.ratefn = fn
end

function SlipperyFeetTarget:GetSlipperyRate(target)
    if self.ratefn ~= nil then
        return self.ratefn(self.inst, target)
    end

    return 1
end

return SlipperyFeetTarget
