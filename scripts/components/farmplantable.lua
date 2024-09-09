
local FarmPlantable = Class(function(self, inst)
    self.inst = inst
    self.plant = nil
end)

function FarmPlantable:Plant(target, planter)
    if self.plant ~= nil and target:HasTag("soil") then
        local pt = target:GetPosition()

		local plant_prefab = FunctionOrValue(self.plant, self.inst)
		if plant_prefab ~= nil then
			target:Remove()

			local plant = SpawnPrefab(plant_prefab)
			plant.Transform:SetPosition(pt:Get())
			plant:PushEvent("on_planted", { doer = planter, seed = self.inst, in_soil = true })

			if plant.SoundEmitter ~= nil then
				plant.SoundEmitter:PlaySound("dontstarve/common/plant")
			end

			TheWorld:PushEvent("itemplanted", { doer = planter, pos = pt }) --this event is pushed in other places too

			self.inst:Remove()
			return true
		end
    end
    return false
end

return FarmPlantable
