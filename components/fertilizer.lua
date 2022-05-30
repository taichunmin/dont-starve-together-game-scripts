
local Fertilizer = Class(function(self, inst)
    self.inst = inst
    self.fertilizervalue = 1
    self.soil_cycles = 1
    self.withered_cycles = 1
    self.fertilize_sound = "dontstarve/common/fertilize"

    self.nutrients = { 0, 0, 0 }

    self.inst:AddTag("fertilizer")
end)

function Fertilizer:OnRemoveFromEntity()
    self.inst:RemoveTag("heal_fertilize")
end

function Fertilizer:SetHealingAmount(health) -- deprecated
end

function Fertilizer:SetNutrients(nutrient1, nutrient2, nutrient3)
    if type(nutrient1) == "table" then
        self.nutrients = nutrient1
    else
        self.nutrients = { nutrient1, nutrient2, nutrient3 }
    end
end

function Fertilizer:OnApplied(doer, target)
	local final_use = true
	if self.inst.components.finiteuses ~= nil then
		self.inst.components.finiteuses:Use()
		final_use = self.inst.components.finiteuses:GetUses() <= 0
	end

	if self.onappliedfn ~= nil then
		self.onappliedfn(self.inst, final_use, doer, target)
	end

	if final_use then
		if self.inst.components.stackable ~= nil then
			self.inst.components.stackable:Get():Remove()
		else
			self.inst:Remove()
		end
	end
end

function Fertilizer:Heal(target)
	return false -- deprecated
end

return Fertilizer
