local Resistance = Class(function(self, inst)
    self.inst = inst
    self.tags = {}
    --self.onresistdamage = nil
    --self.shouldresistfn = nil
end)

function Resistance:AddResistance(tag)
    self.tags[tag] = tag
end

function Resistance:RemoveResistance(tag)
    self.tags[tag] = nil
end

function Resistance:HasResistance(attacker, weapon)
    if attacker ~= nil then
        for k, v in pairs(self.tags) do
            if attacker:HasTag(v) or (weapon ~= nil and weapon:HasTag(v)) then
                return true
            end
        end
    end
end

function Resistance:HasResistanceToTag(tag)
    return self.tags[tag] ~= nil
end

function Resistance:SetOnResistDamageFn(fn)
    self.onresistdamage = fn
end

function Resistance:SetShouldResistFn(fn)
    self.shouldresistfn = fn
end

function Resistance:ShouldResistDamage()
    return self.shouldresistfn == nil or self.shouldresistfn(self.inst)
end

function Resistance:ResistDamage(damage_amount)
    if self.onresistdamage ~= nil then
        self.onresistdamage(self.inst, damage_amount)
    end
    self.inst:PushEvent("damageresisted", damage_amount)
end

function Resistance:GetDebugString()
    local str
    for k, v in pairs(self.tags) do
        str = str ~= nil and (", "..v) or v
    end
    return "Resists: "..(str or "")
end

return Resistance
