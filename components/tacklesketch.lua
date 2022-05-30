local TackleSketch = Class(function(self, inst)
    self.inst = inst

	self.inst:AddTag("tacklesketch")
end,
nil,
{})

function TackleSketch:OnRemoveFromEntity()
    self.inst:RemoveTag("tacklesketch")
end

function TackleSketch:Teach(target)
	target.components.craftingstation:LearnItem(self.inst:GetSpecificSketchPrefab(), self.inst:GetRecipeName())
	target:PushEvent("onlearnednewtacklesketch")

	self.inst:Remove()
end

return TackleSketch