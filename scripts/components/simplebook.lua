
local SimpleBook = Class(function(self, inst)
	self.inst = inst

	self.inst:AddTag("simplebook")

	--self.onreadfn = nil
end)

function SimpleBook:OnRemoveFromEntity()
    self.inst:RemoveTag("simplebook")
end

function SimpleBook:Read(doer)
	if not CanEntitySeeTarget(doer, self.inst) then
		return false
	end

	if self.onreadfn then
		self.onreadfn(self.inst, doer)
	end
end

return SimpleBook