local Thief = Class(function(self, inst)
    self.inst = inst
    self.stolenitems = {} -- DEPRECATED: this was keeping a reference to objects which would prevent there memory from being freed
    --self.onstolen = nil
end)

function Thief:SetOnStolenFn(fn)
    self.onstolen = fn
end

local function item_is_stealable(item)
    return not item:HasTag("nosteal")
end

function Thief:StealItem(victim, itemtosteal, attack)
    if victim.components.inventory ~= nil and victim:IsValid() then
        local item = itemtosteal or victim.components.inventory:FindItem(item_is_stealable)

        if attack then
            self.inst.components.combat:DoAttack(victim)
        end

        if item then
            local direction = (self.inst:GetPosition() - victim:GetPosition()):GetNormalized()
            item = victim.components.inventory:DropItem(item, false, direction)
            if self.onstolen then
                self.onstolen(self.inst, victim, item)
            end
            victim:PushEvent("onitemstolen", { item = item, thief = self.inst, })
            return true
        else
            return false
        end
    elseif victim.components.container then
        local item = itemtosteal or victim.components.container:FindItem(item_is_stealable)

        if attack
                and victim.components.equippable
                and victim.components.inventoryitem
                and victim.components.inventoryitem.owner then
            self.inst.components.combat:DoAttack(victim.components.inventoryitem.owner)
        end

        victim.components.container:DropItem(item)
        if self.onstolen then
            self.onstolen(self.inst, victim, item)
        end
        victim:PushEvent("onitemstolen", { item = item, thief = self.inst, })

        return item ~= nil
    end

    return false
end

return Thief
