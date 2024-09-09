local SourceModifierList = require("util/sourcemodifierlist")

local PlanarDamage = Class(function(self, inst)
	self.inst = inst
	self.basedamage = 0
	self.externalmultipliers = SourceModifierList(inst)
	self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function PlanarDamage:SetBaseDamage(damage)
	self.basedamage = damage
end

function PlanarDamage:GetBaseDamage()
	return self.basedamage
end

function PlanarDamage:GetDamage()
	return self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function PlanarDamage:AddMultiplier(src, mult, key)
	self.externalmultipliers:SetModifier(src, mult, key)
end

function PlanarDamage:RemoveMultiplier(src, key)
	self.externalmultipliers:RemoveModifier(src, key)
end

function PlanarDamage:GetMultiplier()
	return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function PlanarDamage:AddBonus(src, bonus, key)
	self.externalbonuses:SetModifier(src, bonus, key)
end

function PlanarDamage:RemoveBonus(src, key)
	self.externalbonuses:RemoveModifier(src, key)
end

function PlanarDamage:GetBonus()
	return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function PlanarDamage:GetDebugString()
	return string.format("Damage=%.2f [%.2fx%.2f+%.2f]", self:GetDamage(), self:GetBaseDamage(), self:GetMultiplier(), self:GetBonus())
end

return PlanarDamage
