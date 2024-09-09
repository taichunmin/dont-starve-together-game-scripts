local STUCK_DIST_SQ = .05 * .05

local StuckDetection = Class(function(self, inst)
	self.inst = inst
	self.timetostuck = 2
	--self.starttime = nil
	--self.lastx = nil
	--self.lastz = nil
end)

--How long before considering stuck
function StuckDetection:SetTimeToStuck(t)
	self.timetostuck = t
end

function StuckDetection:IsStuck()
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local t = GetTime()
	if self.starttime == nil or distsq(self.lastx, self.lastz, x, z) > STUCK_DIST_SQ then
		self.lastx, self.lastz = x, z
		self.starttime = t
		return false
	end
	self.lastx, self.lastz = x, z
	return self.starttime + self.timetostuck < t
end

function StuckDetection:Reset()
	if self.starttime ~= nil then
		local y
		self.lastx, y, self.lastz = self.inst.Transform:GetWorldPosition()
		self.starttime = GetTime()
	end
end

return StuckDetection
