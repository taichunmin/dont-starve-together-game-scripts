local function on_charge_level_changed(self, new_charge, old_charge)
    self.inst:PushEvent("energylevelupdate", {
        new_level = new_charge,
        old_level = old_charge,
    })
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.currentenergylevel:set(new_charge)
    end
end

local UpgradeModuleOwner = Class(function(self, inst)
    self.inst = inst
    self.modules = {}
    self.charge_level = 0
    self.max_charge = TUNING.WX78_MAXELECTRICCHARGE
    self.upgrade_cooldown = 15*FRAMES

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("upgrademoduleowner")

    --self.onmoduleadded = nil
    --self.onmoduleremoved = nil
    --self.onallmodulespopped = nil
    --self.canupgradefn = nil
    --self._last_upgrade_time = nil
end,
nil,
{
    charge_level = on_charge_level_changed,
})

-- Remove Callbacks -----------------------------------------------------------------

function UpgradeModuleOwner:OnRemoveFromEntity()
    self.inst:RemoveTag("upgrademoduleowner")
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:NumModules()
    return #self.modules
end

function UpgradeModuleOwner:GetModuleInSlot(slotnum)
    return self.modules[slotnum]
end

function UpgradeModuleOwner:GetModuleTypeCount(moduletype)
    local count = 0
    local module_prefab = "wx78module_"..moduletype

    for _, module in ipairs(self.modules) do
        if module.prefab == module_prefab then
            count = count + 1
        end
    end

    return count
end

function UpgradeModuleOwner:UsedSlotCount()
    local cost = 0

    for _, module in ipairs(self.modules) do
        cost = cost + module.components.upgrademodule.slots
    end

    return cost
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:CanUpgrade(module_instance)
    if self._last_upgrade_time ~= nil then
        if (self._last_upgrade_time + self.upgrade_cooldown) > GetTime() then
            return false, "COOLDOWN"
        end
    end

    if self.canupgradefn ~= nil then
        return self.canupgradefn(self.inst, module_instance)
    else
        return true
    end
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:UpdateActivatedModules(isloading)
    local remaining_charge = self.charge_level
    for _, module in ipairs(self.modules) do
        remaining_charge = remaining_charge - module.components.upgrademodule.slots
        if remaining_charge < 0 then
            module.components.upgrademodule:TryDeactivate()
        else
            module.components.upgrademodule:TryActivate(isloading)
        end
    end
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:PushModule(module, isloading)
    table.insert(self.modules, module)

    module.components.upgrademodule:SetTarget(self.inst)

    self.inst:AddChild(module)
    module:RemoveFromScene()
    module.Transform:SetPosition(0, 0, 0)

    self:UpdateActivatedModules(isloading)

    if self.onmoduleadded then
        self.onmoduleadded(self.inst, module)
    end

    self._last_upgrade_time = GetTime()
end

function UpgradeModuleOwner:PopModule(index)
    local top_module = nil

    if #self.modules > 0 then
        top_module = table.remove(self.modules, index)

        self.inst:RemoveChild(top_module)
        top_module:ReturnToScene()
        top_module.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

        top_module.components.upgrademodule:TryDeactivate()

        if self.onmoduleremoved then
            self.onmoduleremoved(self.inst, top_module)
        end

        -- Tell the module it's removed the very end; TryDeactivate needs the target,
        -- and the moduleremoved callback might want to access it too.
        top_module.components.upgrademodule:RemoveFromOwner()

        -- Re-settle our activated and de-activated modules, since one was removed from the table.
        self:UpdateActivatedModules()
    end

    return top_module
end

function UpgradeModuleOwner:PopAllModules()
    if #self.modules > 0 then
        while #self.modules > 0 do
            self:PopModule(1)
        end

        if self.onallmodulespopped then
            self.onallmodulespopped(self.inst)
        end
    end
end

function UpgradeModuleOwner:PopOneModule()
    local energy_cost = 0

    if #self.modules > 0 then
        local pre_remove_slotcount = self:UsedSlotCount()

        local popped_module = self:PopModule()

        -- If the module we just popped was charged, return that charge
        -- as the cost of this removal.
        if pre_remove_slotcount <= self.charge_level then
            energy_cost = popped_module.components.upgrademodule.slots
        end

        if self.ononemodulepopped then
            self.ononemodulepopped(self.inst, popped_module)
        end
    end

    return energy_cost
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:SetChargeLevel(new_level)
    local old_level = self.charge_level
    self.charge_level = math.clamp(new_level, 0, self.max_charge)

    self:UpdateActivatedModules()
end

function UpgradeModuleOwner:AddCharge(n)
    self:SetChargeLevel(self.charge_level + n)
end

function UpgradeModuleOwner:ChargeIsMaxed()
    return self.charge_level == self.max_charge
end

function UpgradeModuleOwner:IsChargeEmpty()
    return self.charge_level == 0
end

---- SAVE/LOAD ----------------------------------------------------------------------

function UpgradeModuleOwner:OnSave()
    local data = {
        modules = {},
        charge_level = self.charge_level,
    }
    local our_references = {}
    local saved_object_references = {}
    for i, module in ipairs(self.modules) do

        -- modules should persist so we're ok grabbing save records
        data.modules[i], saved_object_references = module:GetSaveRecord()
        if saved_object_references then
            for k, v in pairs(saved_object_references) do
                table.insert(our_references, v)
            end
        end
    end

    return data, our_references
end

function UpgradeModuleOwner:OnLoad(data, newents)
    if data ~= nil then
        self.charge_level = data.charge_level or self.charge_level

        for _, module_record in ipairs(data.modules) do
            local module = SpawnSaveRecord(module_record, newents)
            if module ~= nil then
                self:PushModule(module, true)
            end
        end
    end
end

-------------------------------------------------------------------------------------

function UpgradeModuleOwner:GetDebugString()
    local str = "Charge: " .. tostring(self.charge_level)

    str = str .. "\nNum Modules: " .. tostring(GetTableSize(self.modules))
    for _, module in ipairs(self.modules) do
        str = str .. "\n  " .. tostring(module.prefab)
    end

    return str
end

-------------------------------------------------------------------------------------

return UpgradeModuleOwner
