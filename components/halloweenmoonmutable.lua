local HalloweenMoonMutable = Class(function(self, inst)
    self.inst = inst
	self.prefab_mutated = nil
	self.onmutatefn = nil
	self.push_attacked_on_new_inst = true

	self.conversionoverridefn = nil

	self.inst:AddTag("halloweenmoonmutable")
end)

function HalloweenMoonMutable:OnRemoveFromEntity()
    self.inst:RemoveTag("halloweenmoonmutable")
end

function HalloweenMoonMutable:SetPrefabMutated(prefab)
	self.prefab_mutated = prefab
end

function HalloweenMoonMutable:SetOnMutateFn(fn)
	self.onmutatefn = fn
end

function HalloweenMoonMutable:SetConversionOverrideFn(fn) -- Overrides usage of self.prefab_mutated
	self.conversionoverridefn = fn
end

function HalloweenMoonMutable:Mutate(overrideprefab)
	if self.inst.components.health ~= nil and self.inst.components.health:IsDead() then
		return
	end

	local transformed_inst, container

	if self.conversionoverridefn ~= nil then
		transformed_inst, container = self.conversionoverridefn(self.inst)

		if self.onmutatefn ~= nil then
			self:onmutatefn(self.inst, nil)
		end
		self.inst:PushEvent("onhalloweenmoonmutate")

		return transformed_inst
	else
		local prefab = overrideprefab or self.prefab_mutated

		if prefab ~= nil then
			local transformed_inst = SpawnPrefab(prefab)
			if transformed_inst ~= nil then
				transformed_inst.Transform:SetPosition(self.inst.Transform:GetWorldPosition())

				if self.inst.components.health ~= nil and transformed_inst.components.health ~= nil then
					transformed_inst.components.health:SetPercent(self.inst.components.health:GetPercent())
				end

				if self.onmutatefn ~= nil then
					self.onmutatefn(self.inst, transformed_inst)
				end
				self.inst:PushEvent("onhalloweenmoonmutate")

				-- GetContainer() can return container or inventory component.
				local container = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem:GetContainer() or nil

				if self.inst.components.stackable ~= nil and self.inst.components.stackable:IsStack() then
					self.inst.components.stackable:Get():Remove()
				else
					self.inst:Remove()
				end

				if container ~= nil then
					-- GiveItem() works for both container and inventory.
					container:GiveItem(transformed_inst, nil, transformed_inst:GetPosition())
				elseif self.push_attacked_on_new_inst then
					transformed_inst:PushEvent("attacked", { attacker = nil, damage = 0 })
				end

				return transformed_inst
			end
		end
	end

	return nil
end

return HalloweenMoonMutable
