local WaterProofer = Class(function(self, inst)
    self.inst = inst

    self.effectiveness = 1

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("waterproofer")

    if inst.components.inventoryitem ~= nil then
        inst.components.inventoryitem:EnableMoisture(false)
    end
end)

function WaterProofer:OnRemoveFromEntity()
    self.inst:RemoveTag("waterproofer")

    if self.inst.components.inventoryitem ~= nil then
        self.inst.components.inventoryitem:EnableMoisture(true)
    end
end

function WaterProofer:GetEffectiveness()
    return self.effectiveness
end

function WaterProofer:SetEffectiveness(val)
    self.effectiveness = val
end

return WaterProofer
