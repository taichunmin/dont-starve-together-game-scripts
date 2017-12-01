local Dryable = Class(function(self, inst)
    self.inst = inst

    self.product = nil
    self.drytime = nil

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

return Dryable