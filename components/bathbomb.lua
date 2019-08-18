local BathBomb = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("bathbomb")
end)

function BathBomb:OnRemoveFromEntity()
    self.inst:RemoveTag("bathbomb")
end

function BathBomb:ApplyBathBomb(bathbombable_target)
    bathbombable_target:OnBathBombed(self.inst)
end

return BathBomb
