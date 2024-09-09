

local function onset_damage_per_second(self, dps)
	if self.inst.player_classified ~= nil then
		self.inst.player_classified:SetOldagerRate(dps)
	end
end

local OldAger = Class(function(self, inst)
    self.inst = inst

	self.base_rate = 1/40	-- years per second
	self.rate = 1			-- todo: chagne to a source modifier list

	self.year_timer = 0

	self.damage_remaining = 0
	self.damage_per_second = 0

	self.valid_healing_causes = {}

    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    damage_per_second = onset_damage_per_second,
})

function OldAger:AddValidHealingCause(cause_name)
	self.valid_healing_causes[cause_name] = true
end

function OldAger:OnTakeDamage(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb) 
	if self._taking_time_damage then
		return false
	end
	if amount < 0 or self.valid_healing_causes[cause] then
		amount = -amount -- because aging is reversed from health

		local damage_remaining = self.damage_remaining
		if (damage_remaining > 0 and amount < 0) or (damage_remaining < 0 and amount > 0) then
			damage_remaining = 0
		end

		self.damage_remaining = damage_remaining + amount * TUNING.OLDAGE_HEALTH_SCALE
		self.damage_per_second = math.min(math.ceil(math.sqrt(math.abs(self.damage_remaining)) * 1.5), 30)
		if self.damage_remaining < 0 then
			self.damage_per_second = -self.damage_per_second
		end
	end

	return true
end

function OldAger:OnUpdate(dt)
	local frame_age_delta = (self.damage_remaining >= 0 and not self.inst.components.health:IsDead()) and (dt * (self.base_rate * self.rate)) or 0

	local sync_percent = false

	if self.damage_remaining ~= 0 then
		local frame_damage = self.damage_per_second * dt
		local prev_damage_remaining = self.damage_remaining
		self.damage_remaining = self.damage_remaining - frame_damage

		if (prev_damage_remaining > 0 and self.damage_remaining < 0) or (prev_damage_remaining < 0 and self.damage_remaining > 0) then
			frame_damage = prev_damage_remaining
			self.damage_remaining = 0
			self.damage_per_second = 0
			sync_percent = true
		end

		frame_age_delta = frame_age_delta + frame_damage
	end

	local year_timer_delta = self.year_timer + frame_age_delta
	local years_delta = math.floor(year_timer_delta)
	self.year_timer = year_timer_delta - years_delta

	if years_delta ~= 0 and self.inst.components.health ~= nil then
		if self.inst.player_classified ~= nil then
			self.inst.player_classified.oldager_yearpercent:set(self.year_timer) -- sync up the clients
		end

		if years_delta < 0 and self.inst.components.health.currenthealth == self.inst.components.health:GetMaxWithPenalty() then
			self.year_timer = 0
			self:StopDamageOverTime()
		else
			self._taking_time_damage = true
			local damage_taken = self.inst.components.health:DoDelta(-years_delta, false, "oldager_component")
			self._taking_time_damage = false

			if self.inst.components.health:IsDead() then
				self.year_timer = 0
				self.damage_remaining = 0
				self.damage_per_second = 0
			end
		end
	else
		if self.inst.player_classified ~= nil then
			if self.year_timer < 0 and self.inst.components.health.currenthealth == self.inst.components.health:GetMaxWithPenalty() then
				self.year_timer = 0
				self:StopDamageOverTime()
				sync_percent = true
			end

			if sync_percent then
				self.inst.player_classified.oldager_yearpercent:set(self.year_timer) -- sync up the clients
			else
				self.inst.player_classified.oldager_yearpercent:set_local(self.year_timer) -- allow clients to predict
			end
		end
	end
end

function OldAger:StopDamageOverTime()
	self.damage_remaining = 0
	self.damage_per_second = 0

	self._taking_time_damage = true
	self.inst.components.health:DoDelta(0, false, "oldager_component", true, nil, true) -- force an update event (mainly so the badge can refresh)
	self._taking_time_damage = false
end

function OldAger:GetCurrentYearPercent()
	return self.year_timer
end

function OldAger:LongUpdate(dt)
	self:OnUpdate(dt)
end


function OldAger:GetDebugString()
	return string.format("Year timer: %0.3f", self.year_timer) .. string.format(", Meter: %0.2f, DPS: %0.3f, Rate: %0.3f, delta %0.05f", self.damage_remaining, self.damage_per_second, self.rate, self.base_rate * self.rate)
end

return OldAger
