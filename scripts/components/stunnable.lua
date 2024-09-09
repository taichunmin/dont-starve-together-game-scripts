local Stunnable = Class(function(self, inst)
	self.inst = inst

	self.damage = {}
	self.stun_threshold = 1000
	self.stun_period = 5
	self.stun_duration = 10
	self.stun_resist = 150
	self.stun_cooldown = 60
	self.valid_stun_time = 0

	self.inst:ListenForEvent("healthdelta", function(inst, data) self:TakeDamage(data.amount) end)
end)

function Stunnable:Stun()
	self.damage = {}
	self.valid_stun_time = GetTime() + self.stun_cooldown
	self.stun_threshold = self.stun_threshold + self.stun_resist
	self.inst:PushEvent("stunned")
	self.inst:DoTaskInTime(self.stun_duration, function() self.inst:PushEvent("stun_finished") end)
end

function Stunnable:TakeDamage(damage)
	if GetTime() < self.valid_stun_time then return end

	self.damage[GetTime()] = math.abs(damage)

	if self:GetDamageInPeriod() > self.stun_threshold then
		self:Stun()
	end
end

function Stunnable:GetDamageInPeriod()
	local totaldamage = 0
	local toremove = {}

	for k,v in pairs(self.damage) do

		if k + self.stun_period > GetTime() then
			totaldamage = totaldamage + v
		else
			table.insert(toremove, k)
		end
	end

	for k,v in pairs(toremove) do
		self.damage[v] = nil
	end

	return totaldamage
end

return Stunnable