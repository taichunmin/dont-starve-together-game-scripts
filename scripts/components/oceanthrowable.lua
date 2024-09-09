local OceanThrowable = Class(function(self, inst)
    self.inst = inst

    --self.onaddprojectilefn = nil
end)

function OceanThrowable:SetOnAddProjectileFn(fn)
    self.onaddprojectilefn = fn
end

function OceanThrowable:AddProjectile()
    if self.inst.components.complexprojectile == nil then
        self.inst:AddComponent("complexprojectile")
    end

    if self.onaddprojectilefn ~= nil then
        self.onaddprojectilefn(self.inst)
    end
end

return OceanThrowable
