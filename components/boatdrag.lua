local BoatDrag = Class(function(self, inst)
	self.inst = inst

	self.drag = 0
	self.max_velocity_mod = 1

	self.forcedampening = 0

	self.sailforcemodifier = 1
end,
nil,
{})

function BoatDrag:GetDebugString()
	return string.format("drag:%f,  max_velocity_mod:%f,  forcedampening:%f", self.drag, self.max_velocity_mod, self.forcedampening)
end

return BoatDrag
