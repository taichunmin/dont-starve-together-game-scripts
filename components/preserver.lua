local Preserver = Class(function(self, inst)
    self.inst = inst
	--self.perish_rate_multiplier = 1
end,
nil)

function Preserver:SetPerishRateMultiplier(rate)
	self.perish_rate_multiplier = rate
end

function Preserver:GetPerishRateMultiplier(item)
	return type(self.perish_rate_multiplier) == "number" and self.perish_rate_multiplier
			or self.perish_rate_multiplier(self.inst, item)
			or 1
end

return Preserver