local PowerLoad = Class(function(self, inst)
	self.inst = inst
	self.load = 1
	self.isidle = false
end)

function PowerLoad:SetLoad(_load, idle)
	self.load = _load
	self.isidle = idle == true
end

function PowerLoad:GetLoad()
	return self.load
end

function PowerLoad:IsIdle()
	return self.isidle
end

return PowerLoad
