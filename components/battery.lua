local Battery = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("battery")

    --self.canbeused = nil
    --self.onused = nil
end)

function Battery:OnRemoveFromEntity()
    self.inst:RemoveTag("battery")
end

---------------------------------------------------------------------------------

function Battery:CanBeUsed(user)
    if self.canbeused ~= nil then
        return self.canbeused(self.inst, user)
    else
        return true
    end
end

function Battery:OnUsed(user)
    if self.onused ~= nil then
        self.onused(self.inst, user)
    end
end

return Battery
