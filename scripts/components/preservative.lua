local Preservative = Class(function(self, inst)
    self.inst = inst
	self.percent_increase = 1

	self.divide_effect_by_stack_size = true
end,
nil)

return Preservative