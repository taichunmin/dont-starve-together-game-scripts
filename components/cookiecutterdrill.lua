local CookieCutterDrill = Class(function(self, inst)
    self.inst = inst

	self.drill_progress = 0
	self.drill_duration = 10

	self.leak_type = "med_leak"
	self.drill_damage = nil

	self.sound = "turnoftides/common/together/boat/damage"
	self.sound_intensity = 0.8
end)

-- No need to start drilling on wake as it is handled from the state graph
function CookieCutterDrill:OnEntitySleep()
	self.inst:StopUpdatingComponent(self)
end

function CookieCutterDrill:GetIsDoneDrilling()
	return self.drill_progress >= self.drill_duration
end

function CookieCutterDrill:ResetDrilling()
	self.drill_progress = 0
end

function CookieCutterDrill:ResumeDrilling()
	self.inst:StartUpdatingComponent(self)
end

function CookieCutterDrill:PauseDrilling()
	self.inst:StopUpdatingComponent(self)
end

function CookieCutterDrill:FinishDrilling()
	self.inst:StopUpdatingComponent(self)
	self.drill_progress = 0

	local pt = self.inst:GetPosition()
	local boat = self.inst:GetCurrentPlatform()
	if boat ~= nil then
		if self.inst.components.eater ~= nil then
			self.inst.components.eater.lasteattime = GetTime()
		end

        if self.leak_damage and boat.components.hullhealth then
            boat.components.health:DoDelta(self.leak_damage, false, self.inst)
        end

		boat:PushEvent("spawnnewboatleak", {pt = pt, leak_size = "med_leak", playsoundfx = true})
	end
end

function CookieCutterDrill:OnUpdate(dt)
	self.drill_progress = self.drill_progress + dt
end

return CookieCutterDrill