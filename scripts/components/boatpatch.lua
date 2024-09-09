local BoatPatch = Class(function(self, inst)
    self.inst = inst
    self.patch_type = nil

    inst:AddTag("boat_patch")
end)

function BoatPatch:OnRemoveFromEntity()
    self.inst:RemoveTag("boat_patch")
end

function BoatPatch:GetPatchType()
    return self.patch_type
end

return BoatPatch
