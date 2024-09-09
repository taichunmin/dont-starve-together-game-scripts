local SavedRotation = Class(function(self, inst)
    self.inst = inst

    --self.dodelayedpostpassapply = false
end)

function SavedRotation:OnSave()
    local rot = self.inst.Transform:GetRotation()
    return rot ~= 0 and { rotation = rot } or nil
end

function SavedRotation:LoadPostPass(newents, data)
    --this only affects the rotation of platform followers, not the translation.
    self.inst.Transform:LoadRotation(data.rotation or 0)

    if self.dodelayedpostpassapply then
        self:ApplyPostPassRotation(data.rotation or 0)
    end
end

-- Note: If an object can be placed on a rotated boat, this function must be called in OnLoadPostPass() in order to correctly orient the object on the boat.
function SavedRotation:ApplyPostPassRotation(angle)
    self.inst:DoTaskInTime(0, function(inst)
        inst.Transform:SetRotation(angle)
    end)
end

return SavedRotation
