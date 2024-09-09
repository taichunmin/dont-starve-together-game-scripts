local Grabbable = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("grabbable")

    --self.cangrabfn = nil
end)

function Grabbable:OnRemoveFromEntity()
    self.inst:RemoveTag("grabbable")
end

function Grabbable:SetCanGrabFn(fn)
    self.cangrabfn = fn
end

function Grabbable:CanGrab(doer)
    if self.cangrabfn ~= nil then
        return self.cangrabfn(self.inst, doer)
    end

    return false
end

return Grabbable
