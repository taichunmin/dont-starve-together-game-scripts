local Dryable = Class(function(self, inst)
    self.inst = inst

    self.product = nil
    self.drytime = nil
	self.buildfile = nil

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("dryable")
end)

function Dryable:OnRemoveFromEntity()
    self.inst:RemoveTag("dryable")
end

function Dryable:SetProduct(product)
    self.product = product
end

function Dryable:GetProduct()
    return self.product
end

function Dryable:SetDryTime(time)
    self.drytime = time
end

function Dryable:GetDryTime()
    return self.drytime
end

function Dryable:SetBuildFile(buildfile)
    self.buildfile = buildfile
end

function Dryable:GetBuildFile()
    return self.buildfile
end

function Dryable:SetDriedBuildFile(dried_buildfile)
    self.dried_buildfile = dried_buildfile
end

function Dryable:GetDriedBuildFile()
    return self.dried_buildfile or self.buildfile
end

return Dryable