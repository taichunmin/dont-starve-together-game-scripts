local SavedRotation = Class(function(self, inst)
    self.inst = inst
end)

function SavedRotation:OnSave()
    local rot = self.inst.Transform:GetRotation()
    return rot ~= 0 and { rotation = rot } or nil
end

function SavedRotation:LoadPostPass(newents, data)
    --this only affects the rotation of platform followers, not the translation.
    self.inst.Transform:LoadRotation(data.rotation or 0)
end

return SavedRotation
