
local Poppable = Class(function(self, inst)
    self.inst = inst

	--self.onpopfn  = nil
	--self.popped = false
end)

function Poppable:Pop()
	if not self.popped then
		self.popped = true

		if self.onpopfn ~= nil then
			self.onpopfn(self.inst)
		end
	end
end

return Poppable
