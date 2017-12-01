local Occupier = Class(function(self, inst)
    self.inst = inst
end)

--Registered actions in componentactions.lua

function Occupier:GetOwner()
	return self.owner
end

function Occupier:SetOwner(owner)
	self.owner = owner
end

return Occupier