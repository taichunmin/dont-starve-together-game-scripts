
local StoryTellingProp = Class(function(self, inst)
    self.inst = inst
	self.inst:AddTag("storytellingprop")
end)

function StoryTellingProp:OnRemoveFromEntity()
    self.inst:RemoveTag("storytellingprop")
end

return StoryTellingProp