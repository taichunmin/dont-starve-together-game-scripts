--Damage reflect component used by combat component

local DamageReflect = Class(function(self, inst)
    self.inst = inst

    self.reflectdamagefn = nil
    self.defaultdamage = 10
end)

function DamageReflect:SetReflectDamageFn(fn)
    self.reflectdamagefn = fn
end

function DamageReflect:SetDefaultDamage(value)
    self.defaultdamage = value
end

function DamageReflect:GetReflectedDamage(attacker, damage, weapon, stimuli)
    return self.reflectdamagefn ~= nil
        and self.reflectdamagefn(self.inst, attacker, damage, weapon, stimuli)
        or self.defaultdamage
end

return DamageReflect
