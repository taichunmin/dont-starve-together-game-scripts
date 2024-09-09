local ShadowLevel = Class(function(self, inst)
	self.inst = inst
	self.level = 1
	--self.levelfn = nil

	--V2C: Recommended to explicitly add tag to prefab pristine state
	inst:AddTag("shadowlevel")
end)

function ShadowLevel:OnRemoveFromEntity()
	self.inst:RemoveTag("shadowlevel")
end

function ShadowLevel:SetDefaultLevel(level)
	self.level = level
end

function ShadowLevel:SetLevelFn(fn)
	self.levelfn = fn
end

function ShadowLevel:GetCurrentLevel()
	return self.levelfn ~= nil and self.levelfn(self.inst) or self.level
end

return ShadowLevel
