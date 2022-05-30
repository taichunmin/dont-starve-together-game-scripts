local function ontype(self, type, old_type)
	if old_type ~= nil then
		self.inst:Removetag("trophyscale_"..old_type)
	end
	if type ~= nil then
		self.inst:AddTag("trophyscale_"..type)
	end
end

local ItemWeigher = Class(function(self, inst)
    self.inst = inst

	self.type = nil

	--self.ondoweighinfn = nil
end,
nil,
{
	type = ontype
})

function ItemWeigher:OnRemoveFromEntity()
	type = nil -- to remove the tag
end

function ItemWeigher:SetOnDoWeighInFn(fn)
	self.ondoweighinfn = fn
end

function ItemWeigher:DoWeighIn(target, doer)
	return self.ondoweighinfn ~= nil and self.ondoweighinfn(self.inst, target, doer) or nil
end

return ItemWeigher