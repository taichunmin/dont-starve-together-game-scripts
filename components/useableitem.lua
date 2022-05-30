local function oninuse(self, inuse)
    if inuse then
        self.inst:AddTag("inuse")
    else
        self.inst:RemoveTag("inuse")
    end
end

local UseableItem = Class(function(self, inst)
	self.inst = inst
	self.onusefn = nil
	self.onstopusefn = nil
	self.inuse = false
	self.stopuseevents = nil
end,
nil,
{
    inuse = oninuse,
})

function UseableItem:OnRemoveFromEntity()
    self.inst:RemoveTag("inuse")
end

function UseableItem:SetOnUseFn(fn)
	self.onusefn = fn
end

function UseableItem:SetOnStopUseFn(fn)
	self.onstopusefn = fn
end

function UseableItem:CanInteract()
    return not self.inuse and self.inst.replica.equippable ~= nil and self.inst.replica.equippable:IsEquipped()
end

function UseableItem:StartUsingItem()
	self.inuse = true
	if self.onusefn then
		self.inuse = self.onusefn(self.inst) ~= false
	end

	if self.stopuseevents then
		self.stopuseevents(self.inst)
	end
	return self.inuse
end

function UseableItem:StopUsingItem()
	self.inuse = false
	if self.onstopusefn then
		self.onstopusefn(self.inst)
	end
end

return UseableItem