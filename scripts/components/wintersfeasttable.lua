--[[local function oncanfeast(self)
	if self.canfeast and self.feaster == nil then
		self.inst:AddTag("readyforfeast")
	else
		self.inst:RemoveTag("readyforfeast")

		self:CancelFeasting()
	end
end]]
local function oncanfeast(self)
	if self.canfeast then
	--if self.canfeast and self.feaster == nil then
		self.inst:AddTag("readyforfeast")
	else
		self.inst:RemoveTag("readyforfeast")

		self:CancelFeasting()
	end
end

local WintersFeastTable = Class(function(self, inst)
    self.inst = inst

	--self.feaster = nil
	self.current_feasters = {}

	self.canfeast = false

	self.ondepletefoodfn = nil
	self.onfinishfoodfn = nil

	self.inst:AddTag("wintersfeasttable")
end,
nil,
{
	canfeast = oncanfeast,
	--feaster = oncanfeast,
})

function WintersFeastTable:GetDebugString()
	local item = self.inst.components.shelf.itemonshelf
	return string.format("feaster: %s, item: %s, uses: %2.2f",
		tostring(self.feaster),
		tostring(item),
		item ~= nil and item.components.finiteuses ~= nil and item.components.finiteuses:GetUses() or 0
	)
end

function WintersFeastTable:OnRemoveFromEntity()
	self.canfeast = false

	self.inst:RemoveTag("wintersfeasttable")
end

function WintersFeastTable:CancelFeasting()
	for k,_ in pairs(self.current_feasters) do
		if k:IsValid() then
			k:PushEvent("feastinterrupted")
		end
	end

	self.current_feasters = {}
end

function WintersFeastTable:DepleteFood(feasters)
	local item = self.inst.components.inventory:GetItemInSlot(1)

	if item ~= nil and item.components.finiteuses ~= nil then
		item.components.finiteuses:Use()

		if item:IsValid() and item.components.finiteuses:GetUses() > 0 then
			if self.ondepletefoodfn ~= nil then
				self.ondepletefoodfn(self.inst)
			end
		else
			if self.onfinishfoodfn ~= nil then
				self.onfinishfoodfn(self.inst)
			end
		end
	end
end

return WintersFeastTable