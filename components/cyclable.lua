local function oncancycle(self, cancycle)
	if cancycle then
		if not self.inst:HasTag("cancycle") then
			self.inst:AddTag("cancycle")
		end
	else
		if self.inst:HasTag("cancycle") then
			self.inst:RemoveTag("cancycle")
		end
	end
end

local function onnum_steps(self, num_steps)
	self.step = math.max(math.min(self.step, self.num_steps), 1)
end

local Cyclable = Class(function(self, inst, activcb)
	self.inst = inst

	--self.oncyclefn = nil
	self.cancycle = true

	self.step = 1
	self.num_steps = 3
end,
nil,
{
	num_steps = onnum_steps,
	cancycle = oncancycle,
})

function Cyclable:SetNumSteps(num)
	self.num_steps = num
end

function Cyclable:SetOnCycleFn(fn)
	self.oncyclefn = fn
end

function Cyclable:SetStep(step, doer, ignore_callback)
	self.step = math.max(math.min(step, self.num_steps), 1)

	if not ignore_callback and self.oncyclefn ~= nil then
		self.oncyclefn(self.inst, self.step, doer)
	end
end

function Cyclable:Cycle(doer, negative)
	if negative then
		self.step = self.step - 1
		if self.step <= 0 then
			self.step = self.num_steps
		end
	else
		self.step = self.step + 1
		if self.step > self.num_steps then
			self.step = 1
		end
	end

	if self.oncyclefn ~= nil then
		self.oncyclefn(self.inst, self.step, doer)
	end
end

function Cyclable:OnSave()
	return {
		step = self.step,
	}
end

function Cyclable:OnLoad(data)
	if data ~= nil then
		self.step = data.step or self.step
		self:SetStep(self.step)
	end
end

return Cyclable
