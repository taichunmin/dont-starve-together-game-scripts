local function onrepairmaterial(self, repairmaterial, old_repairmaterial)
	if old_repairmaterial ~= nil then
		self.inst:RemoveTag("forgerepair_"..old_repairmaterial)
	end
	if repairmaterial ~= nil then
		self.inst:AddTag("forgerepair_"..repairmaterial)
	end
end

local ForgeRepair = Class(function(self, inst)
	self.inst = inst
	self.repairmaterial = nil
	--self.onrepaired = nil
end,
nil,
{
	repairmaterial = onrepairmaterial,
})

function ForgeRepair:SetRepairMaterial(material)
	self.repairmaterial = material
end

function ForgeRepair:SetOnRepaired(fn)
	self.onrepaired = fn
end

function ForgeRepair:OnRepair(target, doer)
	local success
	if target.components.armor ~= nil then
		if target.components.armor:IsDamaged() then
			target.components.armor:SetPercent(1)
			success = true
		end
	elseif target.components.finiteuses ~= nil then
		if target.components.finiteuses:GetPercent() < 1 then
			target.components.finiteuses:SetPercent(1)
			success = true
		end
	elseif target.components.fueled ~= nil then
		if target.components.fueled:GetPercent() < 1 then
			target.components.fueled:SetPercent(1)
			success = true
		end
	end

	if success then
		if self.inst.components.finiteuses ~= nil then
			self.inst.components.finiteuses:Use(1)
		elseif self.inst.components.stackable ~= nil then
			self.inst.components.stackable:Get():Remove()
		else
			self.inst:Remove()
		end

		if self.onrepaired ~= nil then
			self.onrepaired(self.inst, target, doer)
		end
		return true
	end
end

return ForgeRepair
