local WinchTarget = Class(function(self, inst)
    self.inst = inst

    self.depth = -1 -- -1: use ocean depth value at point

    self.salvagefn = nil

    self.inst:AddTag("winchtarget")
end)

function WinchTarget:OnRemoveFromEntity()
    self.inst:RemoveTag("winchtarget")
end

function WinchTarget:SetSalvageFn(fn)
    self.salvagefn = fn
end

function WinchTarget:Salvage()
    local sunken_obj = self:GetSunkenObject()
    if sunken_obj ~= nil and sunken_obj.components.submersible ~= nil then
        sunken_obj.components.submersible.force_no_repositioning = false
    end

    return self.salvagefn ~= nil and self.salvagefn(self.inst) or nil
end

function WinchTarget:GetSunkenObject()
    if self.inst.components.inventory ~= nil then
        return self.inst.components.inventory:GetItemInSlot(1)
    else
        return nil
    end
end

return WinchTarget