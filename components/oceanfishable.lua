
local OceanFishable = Class(function(self, inst)
    self.inst = inst

	self.rod = nil
	self.rod_onremove = function(rod) if self.rod == rod then self:SetRod(nil) end end

	self.catch_distance = 4

--	self.onsetrodfn = nil
--	self.oneatenfn = nil
--	self.onreelinginfn = nil
--	self.onreelinginpstfn = nil
--  self.makeprojectilefn = nil -- implement this if you want to catch something other than this object.


	-- Use StrugglingSetup to initialize all these
--	self.stamina_def = {}
--	self.stamina = 1.0
--  self.is_struggling_state = false
--  self.pending_is_struggling_state = false
--  self.struggling_state_timer = 0
--	self.max_walk_speed = nil
--	self.max_run_speed = nil

end)

function OceanFishable:OnRemoveFromEntity()
	self:SetRod(nil)
end

function OceanFishable:OnReelingIn(doer)
	if self.onreelinginfn ~= nil then
		self.onreelinginfn(self.inst, doer)
	end
end

function OceanFishable:OnReelingInPst(doer)
	if self.onreelinginpstfn ~= nil then
		self.onreelinginpstfn(self.inst, doer)
	end
end

function OceanFishable:WasEatenByA(tunafish)
	if self.oneatenfn ~= nil then
		self.oneatenfn(self.inst, tunafish)
	end

	self.inst:Remove()
end

function OceanFishable:MakeProjectile()
	return self.makeprojectilefn ~= nil and self.makeprojectilefn(self.inst) or self.inst
end

function OceanFishable:StrugglingSetup(walk_speed, run_speed, stamina_def)
	self.max_walk_speed = walk_speed
	self.max_run_speed = run_speed

	self.stamina_def = stamina_def
	self.is_struggling_state = false
	self.pending_is_struggling_state = false
	self.struggling_state_timer = 0
	self.stamina = 1.0
end

function OceanFishable:SetRod(rod)
	if self.rod ~= rod then
		self.inst:RemoveTag("oceachfishing_catchable")

		local prev_rod = self.rod
		self.rod = rod

		if prev_rod ~= nil then
		    self.inst:StopUpdatingComponent(self)
			self.inst:RemoveEventCallback("onremove", self.rod_onremove, prev_rod)
			prev_rod.components.oceanfishingrod:SetTarget(nil)
			if self.onsetrodfn ~= nil then
				self.onsetrodfn(self.inst, nil)
			end
		end
		if rod ~= nil then
			self.inst:ListenForEvent("onremove", self.rod_onremove, rod)
			rod.components.oceanfishingrod:SetTarget(self.inst)

		    self.inst:StartUpdatingComponent(self)

			if self.onsetrodfn ~= nil then
				self.onsetrodfn(self.inst, rod)
			end
		end
		self:UpdateRunSpeed()
		return self.rod ~= nil
	end
end

function OceanFishable:GetRod()
	return self.rod
end

function OceanFishable:IsStruggling()
	return self.is_struggling_state
end

function OceanFishable:UpdateRunSpeed()
	if self.inst.components.locomotor ~= nil then
		local tension_mod = self.rod == nil and 1
							or math.abs(anglediff(self.inst.Transform:GetRotation(), self.inst:GetAngleToPoint(self.rod.Transform:GetWorldPosition()))) > 90 and (1 - math.min(0.8, self.rod.components.oceanfishingrod:GetTensionRating()))
							or (1 + self.rod.components.oceanfishingrod:GetTensionRating() * 0.5)

		if self.max_walk_speed ~= nil then
			self.inst.components.locomotor.walkspeed = self.max_walk_speed * tension_mod
		end
		if self.max_run_speed ~= nil then
			self.inst.components.locomotor.runspeed = self.max_run_speed * tension_mod
		end
	end
end

function OceanFishable:CalcStaminaDrainRate()
	local extra_stamina_drain = (self.rod ~= nil and self.rod.components.oceanfishingrod ~= nil) and self.rod.components.oceanfishingrod:GetExtraStaminaDrain() or 0
	return -(self.stamina_def.drain_rate + extra_stamina_drain)
end

function OceanFishable:OnUpdate(dt)
	if self.stamina ~= nil then
		local delta = dt * ((self.rod == nil or self.rod.components.oceanfishingrod == nil) and 0
							or self.rod.components.oceanfishingrod:IsLineTensionHigh() and self:CalcStaminaDrainRate()
							or self.rod.components.oceanfishingrod:IsLineTensionLow() and self.stamina_def.recover_rate
							or 0)
		self.stamina = math.clamp(self.stamina + delta, 0, 1)

		if self.struggling_state_timer > 0 then
			self.struggling_state_timer = self.struggling_state_timer - dt
			if self.struggling_state_timer <= 0 then
				self.pending_is_struggling_state = not self.is_struggling_state
			end
		end
	end

	if self.rod ~= nil and self.inst:IsValid() and self.inst:IsNear(self.rod, self.catch_distance) then
		self.inst:AddTag("oceachfishing_catchable")
	else
		self.inst:RemoveTag("oceachfishing_catchable")
	end

	self:UpdateRunSpeed()
end

function OceanFishable:ResetStruggling()
	self.pending_is_struggling_state = true
	self.is_struggling_state = true
	self.stamina = 1
	self.struggling_state_timer = self:CalcStruggleDuration()
end

function OceanFishable:CalcStruggleDuration()
	local times = self.is_struggling_state and self.stamina_def.struggle_times or self.stamina_def.tired_times
	return Lerp(times.low, times.high, self.stamina) + math.random() * Lerp(times.r_low, times.r_high, self.stamina)
end

function OceanFishable:UpdateStruggleState()
	if self.is_struggling_state ~= self.pending_is_struggling_state then
		self.is_struggling_state = self.pending_is_struggling_state
		self.struggling_state_timer = self:CalcStruggleDuration()
	end
end

function OceanFishable:CalcLineUnreelRate(rod)
	if self.overrideunreelratefn ~= nil then
		return self.overrideunreelratefn(self.inst, rod)
	end

	if self.stamina and self.is_struggling_state and self.inst.components.locomotor ~= nil then
		local angle_scale = (90 - math.abs(anglediff(self.inst.Transform:GetRotation(), rod:GetAngleToPoint(self.inst.Transform:GetWorldPosition())))) / 90
		return self.inst.components.locomotor.runspeed * angle_scale
	end

	return 0
end

function OceanFishable:GetDebugString()
	local str = ""
	if self.stamina ~= nil then
		str = str .. "Rod: " .. tostring(self.rod) .. ", Struggling: " .. tostring(self.is_struggling_state) .. " (" .. (self.struggling_state_timer > 0 and string.format("%0.2f", self.struggling_state_timer) or tostring(self.pending_is_struggling_state)) .. ") Stamina: " .. string.format("%0.3f", self.stamina)
	else
		str = str .. "Rod: " .. tostring(self.rod) .. ", No Stamina."
	end

	if self.inst.fish_def ~= nil and self.inst.fish_def.lures ~= nil then
		str = str .. "\n  Lure Mods:"
		for k, v in pairs(self.inst.fish_def.lures) do
			str = str .. " " .. k .. ": " .. tostring(v) .. ","
		end
	end

	return str
end

return OceanFishable