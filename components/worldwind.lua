local easing = require("easing")

local MIN_TIME_TO_WIND_CHANGE = .5*TUNING.SEG_TIME
local MAX_TIME_TO_WIND_CHANGE = TUNING.SEG_TIME

local WorldWind = Class(function(self, inst)

    self.inst = inst

	self.velocity = 1

	self.angle = math.random(0,360)

	self.timeToWindChange = 1

	self.inst:StartUpdatingComponent(self)
end)

function WorldWind:Start()
	self.inst:StartUpdatingComponent(self)
end

function WorldWind:Stop()
	self.inst:StopUpdatingComponent(self)
end

function WorldWind:GetWindAngle()
	return self.angle
end

function  WorldWind:GetWindVelocity()
	return self.velocity
end

function WorldWind:GetDebugString()
	return string.format("Angle: %4.4f, Veloc: %3.3f", self.angle, self.velocity)
end

function WorldWind:OnUpdate(dt)

	if not self.inst then 
		self:Stop()
		return
	end

	self.timeToWindChange = self.timeToWindChange - dt

	if self.timeToWindChange <= 0 then
		self.angle = math.random(0,360)
		self.inst:PushEvent("windchange", {angle=self.angle, velocity=self.velocity})

		self.timeToWindChange = math.random(MIN_TIME_TO_WIND_CHANGE, MAX_TIME_TO_WIND_CHANGE)
	end
end

return WorldWind