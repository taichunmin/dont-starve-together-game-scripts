local Thief = Class(function(self, inst)
    self.inst = inst
    self.stolenitems = {} -- DEPRECATED: this was keeping a reference to objects which would prevent there memory from being freed
    --self.onstolen = nil
end)

function Thief:SetOnStolenFn(fn)
    self.onstolen = fn
end

function Thief:StealItem(victim, itemtosteal, attack)
    if victim.components.inventory ~= nil and victim.components.inventory.isopen then
        local item = itemtosteal or victim.components.inventory:FindItem(function(item) return not item:HasTag("nosteal") end)

        if attack then
            self.inst.components.combat:DoAttack(victim)
        end

        if item then
            local direction = Vector3(self.inst.Transform:GetWorldPosition()) - Vector3(victim.Transform:GetWorldPosition() )
            item = victim.components.inventory:DropItem(item, false, direction:GetNormalized())
            if self.onstolen then
                self.onstolen(self.inst, victim, item)
            end
        end
    elseif victim.components.container then
        local item = itemtosteal or victim.components.container:FindItem(function(item) return not item:HasTag("nosteal") end)

        if attack then
            if victim.components.equippable and victim.components.inventoryitem and victim.components.inventoryitem.owner  then
                self.inst.components.combat:DoAttack(victim.components.inventoryitem.owner)
            end
        end

        item = victim.components.container:DropItem(item)
        if self.onstolen then
            self.onstolen(self.inst, victim, item)
        end
    end
end

return Thief
