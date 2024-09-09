local BatteryUser = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("engineeringbatteryuser")

    --self.onbatteryused = nil
end)

function BatteryUser:OnRemoveFromEntity()
    self.inst:RemoveTag("engineeringbatteryuser")
end

---------------------------------------------------------------------------------

function BatteryUser:ChargeFrom(charge_target)
    local result, reason = charge_target.components.battery:CanBeUsed(self.inst)

    if result and self.onbatteryused ~= nil then
        result, reason = self.onbatteryused(self.inst, charge_target)
    end

    -- If we successfully used the battery, evoke the battery's result (i.e. to tick down a fueled component)
    if result then
        charge_target.components.battery:OnUsed(self.inst)
    end

    return result, reason
end

return BatteryUser
