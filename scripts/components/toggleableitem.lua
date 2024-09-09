local ToggleableItem = Class(function(self, inst)
	self.inst = inst
	self.onusefn = nil
	self.onstopusefn = nil
	self.on = false
	self.stopuseevents = nil
end)

function ToggleableItem:SetOnToggleFn(fn)
	self.onusefn = fn
end

function ToggleableItem:CanInteract(doer)
    return true
end

function ToggleableItem:ToggleItem()
	if self.on then 
		self.on = false
	else
		self.on = true
	end
	if self.onusefn then
		self.onusefn(self.inst,self.on)
	end
end

return ToggleableItem