
local MadScienceLab = Class(function(self, inst)
    self.inst = inst

    self.task = nil
    self.product = nil

	self.stages = {}
end)

function MadScienceLab:OnRemoveFromEntity()
	if self.task ~= nil then
		self.task:Cancel()
		self.task = nil
	end
end

function MadScienceLab:IsMakingScience()
    return self.task ~= nil
end

function MadScienceLab:SetStage(stage, time_override) -- time override is for save/load
	if stage > #self.stages then
		local result = self.product
		self.task = nil
		self.product = nil

		if self.OnScienceWasMade ~= nil then
			self.OnScienceWasMade(self.inst, result)
		end
	else
		self.stage = stage
		self.task = self.inst:DoTaskInTime(time_override or self.stages[self.stage].time, function() self:SetStage(self.stage + 1) end)

		if self.OnStageStarted ~= nil then
			self.OnStageStarted(self.inst, self.stage)
		end
	end
end

function MadScienceLab:StartMakingScience(product)
	self.product = product
	self:SetStage(1)

	if self.OnStartMakingScience ~= nil then
		self.OnStartMakingScience(self.inst)
	end
end

function MadScienceLab:OnSave()
    return {
		product = self.product,
		stage = self.stage,
		time_remaining = self.task ~= nil and GetTaskRemaining(self.task) or nil
	}
end

function MadScienceLab:OnLoad(data)
	if data ~= nil and data.time_remaining ~= nil then
		self.product = data.product
		self:SetStage(data.stage, data.time_remaining)
	end
end

function MadScienceLab:GetDebugString()
	local str = "Inactive"
	if self.task ~= nil then
		str = "Making Science: " .. tostring(self.product) .. ". Stage: " .. tostring(self.stage) .. " done in " .. tostring(GetTaskRemaining(self.task)) .. "s."
	end
    return str
end

function MadScienceLab:LongUpdate(dt)
end

return MadScienceLab
