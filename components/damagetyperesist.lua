local SourceModifierList = require("util/sourcemodifierlist")

local DamageTypeResist = Class(function(self, inst)
	self.inst = inst
	self.tags = {}
end)

function DamageTypeResist:AddResist(tag, src, pct, key)
	local modifiers = self.tags[tag]
	if modifiers == nil then
		modifiers = SourceModifierList(self.inst)
		self.tags[tag] = modifiers
	end
	modifiers:SetModifier(src, pct, key)
end

function DamageTypeResist:RemoveResist(tag, src, key)
	local modifiers = self.tags[tag]
	if modifiers ~= nil then
		modifiers:RemoveModifier(src, key)
		if modifiers:IsEmpty() then
			self.tags[tag] = nil
		end
	end
end

function DamageTypeResist:GetResist(attacker, weapon)
	local mult = 1
	if attacker ~= nil then
		for k, v in pairs(self.tags) do
			if attacker:HasTag(k) or (weapon ~= nil and weapon:HasTag(k)) then
				mult = mult * v:Get()
			end
		end
	end
	return mult
end

function DamageTypeResist:GetDebugString()
	local str
	for k, v in pairs(self.tags) do
		str = (str or "")..string.format("\n\t[%s] %f", k, v:Get())
	end
	return str
end

return DamageTypeResist
