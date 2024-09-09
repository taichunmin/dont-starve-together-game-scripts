local SavedScale = Class(function(self, inst)
    self.inst = inst
end)

function SavedScale:OnSave()
    local sx, sy, sz = self.inst.Transform:GetScale()
    local data =
    {
        x = sx ~= 1 and sx or nil,
        y = sy ~= sx and sy or nil,
        z = sz ~= sx and sz or nil,
    }
    return next(data) ~= nil and data or nil
end

function SavedScale:OnLoad(data)
    local scale = data.x or 1
    self.inst.Transform:SetScale(scale, data.y or scale, data.z or scale)
end

return SavedScale
