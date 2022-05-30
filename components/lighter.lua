local Lighter = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("lighter")

    self.onlight = nil
end)

function Lighter:OnRemoveFromEntity()
    self.inst:RemoveTag("lighter")
end

function Lighter:SetOnLightFn(fn)
    self.onlight = fn
end

function Lighter:Light(target)
    if target.components.burnable ~= nil and not ((target:HasTag("fueldepleted") and not target:HasTag("burnableignorefuel")) or target:HasTag("INLIMBO")) then
        target.components.burnable:Ignite()
        if self.onlight ~= nil then
            self.onlight(self.inst, target)
        end
    end
end

return Lighter
