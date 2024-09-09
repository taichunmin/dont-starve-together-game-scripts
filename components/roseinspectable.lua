local RoseInspectable = Class(function(self, inst)
    self.inst = inst

    --self.forcedinducedcooldown = false
    --self.willinducecooldownonactivatefn = nil
    --self.onresidueactivatedfn = nil
    --self.onresiduecreatedfn = nil
    --self.canresiduebespawnedbyfn = nil
end)

function RoseInspectable:SetOnResidueActivated(fn)
    self.onresidueactivatedfn = fn
end

function RoseInspectable:SetOnResidueCreated(fn)
    self.onresiduecreatedfn = fn
end

function RoseInspectable:SetCanResidueBeSpawnedBy(fn)
    self.canresiduebespawnedbyfn = fn
end

function RoseInspectable:CanResidueBeSpawnedBy(doer)
    if self.canresiduebespawnedbyfn == nil then
        return true
    end

    return self.canresiduebespawnedbyfn(self.inst, doer)
end

function RoseInspectable:SetForcedInduceCooldownOnActivate(bool)
    self.forcedinducedcooldown = bool
end

function RoseInspectable:SetWillInduceCooldownOnActivate(fn)
    self.willinducecooldownonactivatefn = fn
end

function RoseInspectable:WillInduceCooldownOnActivate(doer)
    if self.forcedinducedcooldown ~= nil then
        return self.forcedinducedcooldown
    end

    if self.willinducecooldownonactivatefn ~= nil then
        return self.willinducecooldownonactivatefn(self.inst, doer)
    end

    return false
end

function RoseInspectable:HookupResidue(residueowner, residue)
    if self.onresiduecreatedfn then
        self.onresiduecreatedfn(self.inst, residueowner, residue)
    end
end

function RoseInspectable:DoRoseInspection(doer)
    if self.onresidueactivatedfn then
        self.onresidueactivatedfn(self.inst, doer)
    end
end

return RoseInspectable
