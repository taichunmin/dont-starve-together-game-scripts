local Appraisable = Class(function(self, inst)
	self.inst = inst
end)

function Appraisable:CanAppraise(target)
	if self.canappraisefn then
		return self.canappraisefn(self.inst, target)
	end
	return true
end

function Appraisable:Appraise(target)
	if self.appraisefn then
		self.appraisefn(self.inst,target)
	end
end

return Appraisable
