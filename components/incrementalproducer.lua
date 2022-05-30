
local IncrementalProducer = Class(function(self, inst)
	self.inst = inst
	self.producefn = nil

	self.countfn = nil
	self.maxcount = 0
	self.maxcountfn = nil

	self.increment = 1
	self.incrementfn = nil
	self.incrementdelay = 1

	self.toproduce = 0

	self.lastproduction = 0
end)


function IncrementalProducer:CanProduce()
	if self.maxcountfn then
		self.maxcount = self.maxcountfn(self.inst)
	end

	if self.incrementfn then
		self.increment = self.incrementfn(self.inst)
	end

	local count = self.countfn(self.inst)

	if GetTime() > self.lastproduction + self.incrementdelay and count < self.maxcount then
		self.toproduce = self.incrementfn and self.incrementfn(self.inst) or self.increment
		self.toproduce = math.min(self.maxcount - count, self.toproduce)
	end

	return self.toproduce > 0
end

function IncrementalProducer:TryProduce()
	if self:CanProduce() then
		self:DoProduce()
	end
end

function IncrementalProducer:DoProduce()
	if self.producefn then
		self.producefn(self.inst)
		self.toproduce = math.max(0, self.toproduce - 1)
		self.lastproduction = GetTime()
	end
end

function IncrementalProducer:GetDebugString()
	return string.format("count:%d toproduce:%d max:%d nextincrement:%f", self.countfn(self.inst), self.toproduce, self.maxcount, self.incrementdelay + self.lastproduction - GetTime())
end

return IncrementalProducer