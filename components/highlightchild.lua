local function OnSyncOwnerDirty(inst)
	local self = inst.components.highlightchild
	self:OnChangeOwner(self.syncowner:value())
end

local HighlightChild = Class(function(self, inst)
	self.inst = inst
	self.owner = nil
	if inst.Network ~= nil then
		self.syncowner = net_entity(inst.GUID, "highlightchild.syncowner", "syncownerdirty")
		if not TheWorld.ismastersim then
			inst:ListenForEvent("syncownerdirty", OnSyncOwnerDirty)
		end
	end
end)

function HighlightChild:OnRemoveEntity()
	if self.owner ~= nil then
		table.removearrayvalue(self.owner.highlightchildren, self.inst)
	end
end

function HighlightChild:SetOwner(owner)
	if self.syncowner ~= nil then
		self.syncowner:set(owner)
	end
	self:OnChangeOwner(owner)
end

function HighlightChild:OnChangeOwner(owner)
	--Dedicated server does not need highlighting
	if not TheNet:IsDedicated() then
		if self.owner ~= nil then
			self.inst.AnimState:SetHighlightColour()
			table.removearrayvalue(self.owner.highlightchildren, self.inst)
		end
		self.owner = owner
		if owner ~= nil then
			if owner.highlightchildren == nil then
				owner.highlightchildren = { self.inst }
			else
				table.insert(owner.highlightchildren, self.inst)
			end
		end
	end
end

return HighlightChild
