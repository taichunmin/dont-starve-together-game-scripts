local Cooker = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("cooker")
end)

function Cooker:OnRemoveFromEntity()
    self.inst:RemoveTag("cooker")
end

function Cooker:CanCook(item, chef)
    return item ~= nil
        and item.components.cookable ~= nil
        and not (self.inst.components.fueled ~= nil and self.inst.components.fueled:IsEmpty())
        and not (item.components.burnable ~= nil and item.components.burnable:IsBurning())
        and not (item.components.projectile ~= nil and item.components.projectile:IsThrown())
        and (not self.inst:HasTag("dangerouscooker") or chef:HasTag("expertchef"))

    --V2C: don't do held or canbepickedup checks here, because it's really
    --     inconsistent; lots of code that shoves not canbepickedup things
    --     into your inventory!
end

function Cooker:CookItem(item, chef)
    if self:CanCook(item, chef) then
        local newitem = item.components.cookable:Cook(self.inst, chef)
        ProfileStatsAdd("cooked_"..item.prefab)

        if self.oncookitem ~= nil then
            self.oncookitem(item, newitem)
        end

        local sound_inst =
            self.inst.components.inventoryitem ~= nil and
            self.inst.components.inventoryitem:GetGrandOwner() or
            self.inst

        if sound_inst.SoundEmitter ~= nil then
            sound_inst.SoundEmitter:PlaySound("dontstarve/wilson/cook")
        end

        if self.oncookfn ~= nil then
            self.oncookfn(self.inst, newitem, chef)
        end

        item:Remove()
        return newitem
    end
end

return Cooker
