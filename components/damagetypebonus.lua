local SourceModifierList = require("util/sourcemodifierlist")

local DamageTypeBonus = Class(function(self, inst)
	self.inst = inst
	self.tags = {}
end)

function DamageTypeBonus:AddBonus(tag, src, pct, key)
	local modifiers = self.tags[tag]
	if modifiers == nil then
		modifiers = SourceModifierList(self.inst)
		self.tags[tag] = modifiers
	end
	modifiers:SetModifier(src, pct, key)
end

function DamageTypeBonus:RemoveBonus(tag, src, key)
	local modifiers = self.tags[tag]
	if modifiers ~= nil then
		modifiers:RemoveModifier(src, key)
		if modifiers:IsEmpty() then
			self.tags[tag] = nil
		end
	end
end

function DamageTypeBonus:GetBonus(target)
	local mult = 1
	if target ~= nil then
		for k, v in pairs(self.tags) do
			if target:HasTag(k) then
				mult = mult * v:Get()
			end
		end
	end
	return mult
end

function DamageTypeBonus:GetDebugString()
	local str
	for k, v in pairs(self.tags) do
		str = (str or "")..string.format("\n\t[%s] %f", k, v:Get())
	end
	return str
end

return DamageTypeBonus
