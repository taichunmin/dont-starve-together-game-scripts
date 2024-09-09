local Hudindicatable = Class(function(self, inst)
    self.inst = inst
    self.shouldtrackfn = function() return true end
    self.inst:DoTaskInTime(0,function() self:RegisterWithWorldComponent() end)
    self.inst:ListenForEvent("onremove", self.UnRegisterWithWorldComponent)
end,
nil,
{})

function Hudindicatable:SetShouldTrackFunction(fn)
    self.shouldtrackfn = fn
end

function Hudindicatable:ShouldTrack(viewer)
    return self.shouldtrackfn(self.inst, viewer)
end

function Hudindicatable:UnRegisterWithWorldComponent()
     if TheWorld.components.hudindicatablemanager then
        TheWorld.components.hudindicatablemanager:UnRegisterItem(self.inst)
        TheWorld:PushEvent("unregister_hudindicatable",self.inst)
    end
end

function Hudindicatable:RegisterWithWorldComponent()
    if TheWorld.components.hudindicatablemanager then
        TheWorld.components.hudindicatablemanager:RegisterItem(self.inst)
    end
end

function Hudindicatable:OnRemoveFromEntity()
    self:UnRegisterWithWorldComponent()
end

return Hudindicatable
