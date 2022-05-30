local Murderable = Class(function(self, inst)
    self.inst = inst

	self.murdersound = nil

	self.inst:AddTag("murderable")
end)

function Murderable:OnRemoveFromEntity()
    self.inst:RemoveTag("murderable")
end

return Murderable
