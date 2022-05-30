local SourceModifierList = require("util/sourcemodifierlist")

local FarmPlantStress = Class(function(self, inst)
    self.inst = inst

	self.stressors = {}
	self.stressors_testfns = {}
	self.stressor_fns = {}
	self.stress_points = 0
	self.num_stressors = 0

	self.final_stress_state = nil

	self.inst:AddTag("farmplantstress")
end)

function FarmPlantStress:AddStressCategory(name, testfn, onchangefn)
	self.stressors[name] = true -- default to stressed
	self.stressors_testfns[name] = testfn
	self.stressor_fns[name] = onchangefn
	self.num_stressors = self.num_stressors + 1
end

function FarmPlantStress:CopyFrom(rhs)
	self:OnLoad(rhs:OnSave())
end

function FarmPlantStress:Reset()
	for stressor, stressed in pairs(self.stressors) do
		self.stressors[stressor] = true -- reset to stressed
	end

	self.stress_points = 0
	self.final_stress_state = nil
end

function FarmPlantStress:SetStressed(name, stressed, doer)
	local prev = self.stressors[name]
	if prev ~= nil then
		self.stressors[name] = stressed == true
		if stressed ~= prev and self.stressor_fns[name] ~= nil then
			self.stressor_fns[name](self.inst, stressed, doer)
		end
	end
end

function FarmPlantStress:MakeCheckpoint()
	if c_sel() == self.inst then
		print("FarmPlantStress: ", self.inst)
		for stressor, stressed in pairs(self.stressors) do
			print("  " .. (stressed and "stressed" or "all good"), stressor)
		end
	end

	local stress = 0
	for stressor, stressed in pairs(self.stressors) do
		if stressed then
			stress = stress + 1
		else
			self.stressors[stressor] = true -- reset to stressed
		end

	end

	self.stress_points = self.stress_points + stress

	-- debugging data
	self.checkpoint_stress_points = stress
	self.max_stress_points = (self.max_stress_points or 0) + self.num_stressors
end

function FarmPlantStress:CalcFinalStressState()
	local stress = self.stress_points
	self.final_stress_state = stress <= 1 and FARM_PLANT_STRESS.NONE		-- allow one mistake
							or stress <= 6 and FARM_PLANT_STRESS.LOW		-- one and half categories can fail, take your pick
							or stress <= 11 and FARM_PLANT_STRESS.MODERATE  -- almost 3 categories can fail
							or FARM_PLANT_STRESS.HIGH						-- you aren't even trying now, are you?

	return self.final_stress_state
end

function FarmPlantStress:GetFinalStressState()
	return self.final_stress_state
end

function FarmPlantStress:OnInteractWith(doer)
	return self.oninteractwithfn ~= nil and self.oninteractwithfn(self.inst, doer)
end

function FarmPlantStress:GetStressDescription(viewer)
    if self.inst == viewer then
        return
    elseif not CanEntitySeeTarget(viewer, self.inst) then
		return GetString(viewer, "DESCRIBE_TOODARK")
	elseif self.inst.components.burnable ~= nil and self.inst.components.burnable:IsSmoldering() then
        return GetString(viewer, "DESCRIBE_SMOLDERING")
	end

	local stressors = {}
	for stressor, testfn in pairs(self.stressors_testfns) do
		if testfn(self.inst, self.stressors[stressor], false) then
			table.insert(stressors, stressor)
		end
	end

	if #stressors == 0 then
		return GetString(viewer, "DESCRIBE_PLANTHAPPY")
	elseif viewer:HasTag("plantkin") or (viewer.replica.inventory and viewer.replica.inventory:EquipHasTag("detailedplanthappiness")) then
		local stressor = shuffleArray(stressors)[1]
		return GetString(viewer, "DESCRIBE_PLANTSTRESSOR"..string.upper(stressor))
	else
		if #stressors >= 5 then
			return GetString(viewer, "DESCRIBE_PLANTVERYSTRESSED")
		else --if #stressors <= 4 then
			return GetString(viewer, "DESCRIBE_PLANTSTRESSED")
		end
	end
end

function FarmPlantStress:OnSave()
	return {
		final_stress_state = self.final_stress_state,
		stress_points = self.stress_points,
		stressors = self.stressors,
	}
end

function FarmPlantStress:OnLoad(data)
	if data ~= nil then
		self.final_stress_state = data.final_stress_state
		self.stress_points = data.stress_points
		for k, _ in pairs(self.stressors) do
			self.stressors[k] = data.stressors[k]
		end
	end
end

function FarmPlantStress:GetDebugString()
	local final_stress = self.final_stress_state ~= nil and (", Final: " .. tostring(table.invert(FARM_PLANT_STRESS)[self.final_stress_state])) or ""
	local str = "" .. tostring(self.stress_points) .. "/" .. tostring(self.max_stress_points or 0) .. " Prev Checkpoint:" .. tostring(self.checkpoint_stress_points) .. final_stress

	for stressor, testfn in pairs(self.stressors_testfns) do
		str = str .. "\n  " .. stressor .. ":".. (testfn(self.inst, self.stressors[stressor], false) and "stressed" or "calm")
	end

	return str
end

return FarmPlantStress
