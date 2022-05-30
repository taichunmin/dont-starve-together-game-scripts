
local Bloomness = Class(function(self, inst)
    self.inst = inst

    self.max = 3
    self.level = 0
	self.onlevelchangedfn = nil

	self.timer = 0
	self.stage_duration = 0
	self.full_bloom_duration = 0

    self.rate = 1
	self.fertilizer = 0
end)

function Bloomness:SetLevel(level)
	level = math.min(level, self.max)
	if self.level == level then
		return
	end

	self.fertilizer = 0

	if level == 0 then
		self.level = 0
		self.timer = 0
		self.is_blooming = false
		self:UpdateRate()
        self.inst:StopUpdatingComponent(self)
	else
		local prev_level = self.level

		self.is_blooming = level ~= self.max and level > self.level
		self.level = level

		if level == self.max then
			self.timer = self.timer + self.full_bloom_duration
		else
			self.timer = self.timer + self.stage_duration
		end

		self:UpdateRate()

		if prev_level == 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end
	self.onlevelchangedfn(self.inst, level)
end

function Bloomness:SetDurations(stage, full)
	self.stage_duration = stage
	self.full_bloom_duration = full
end

function Bloomness:GetLevel()
    return self.level
end

function Bloomness:UpdateRate()
	if self.level > 0 then
		self.rate = self.calcratefn ~= nil and self.calcratefn(self.inst, self.level, self.is_blooming, self.fertilizer) or 1
	end
end

function Bloomness:Fertilize(value)
	value = value or 0

	if self.level == self.max then
		self.timer = self.calcfullbloomdurationfn ~= nil and self.calcfullbloomdurationfn(self.inst, value, self.timer, self.full_bloom_duration) or self.timer
		--self.timer = math.min(self.timer + value, self.full_bloom_duration + value)
		self:UpdateRate()
	else
		if self.level == 0 then
			self:SetLevel(1)
		end

		if not self.is_blooming then
			self.is_blooming = true
			self.timer = self.stage_duration
		end
		self.fertilizer = self.fertilizer + value
		self:UpdateRate()
	end
end

function Bloomness:OnUpdate(dt)
	self.timer = self.timer - dt * self.rate
	if self.timer <= 0 then
		if self.is_blooming then
			self:SetLevel(self.level + 1)
		else
			self:SetLevel(self.level - 1)

			if self.level == 0 then
				self.timer = 0
				self.inst:StopUpdatingComponent(self)
			end
		end
	end
end

function Bloomness:LongUpdate(dt)
	if self.timer ~= 0 then
		self:OnUpdate(dt)
	end
end

function Bloomness:OnSave()
    return self.level > 0 and {
        level = self.level,
        timer = self.timer,
        rate = self.rate,
		is_blooming = self.is_blooming,
		fertilizer = self.fertilizer,
    } or nil
end

function Bloomness:OnLoad(data)
    if data ~= nil then
		self.timer = data.timer or 0
		self.rate = data.rate or 1
		self.is_blooming = data.is_blooming
		self.fertilizer = data.fertilizer or 0
		self.level = data.level or 0

		if self.level > 0 then
			self.inst:StartUpdatingComponent(self)
			self.onlevelchangedfn(self.inst, self.level)
		end
    end
end

function Bloomness:GetDebugString()
	return string.format("L: %d, B: %s, T: %0.2f (x%0.2f)", self.level, tostring(self.is_blooming), self.timer, self.rate)
end

return Bloomness
