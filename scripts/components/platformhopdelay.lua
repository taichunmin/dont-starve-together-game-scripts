local PlatformHopDelay = Class(function(self, inst)
	self.inst = inst
	self.delayticks = 8
end)

function PlatformHopDelay:SetDelay(time)
	self.delayticks = math.ceil(time / FRAMES)
end

function PlatformHopDelay:SetDelayTicks(ticks)
	self.delayticks = ticks
end

function PlatformHopDelay:GetDelayTicks()
	return self.delayticks
end

return PlatformHopDelay
