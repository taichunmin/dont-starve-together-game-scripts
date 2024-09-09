local MagicianTool = Class(function(self, inst)
	self.inst = inst
	self.user = nil
	self.onstartusingfn = nil
	self.onstopusingfn = nil

	inst:AddTag("magiciantool")
end)

function MagicianTool:OnRemoveFromEntity()
	self:StopUsing()
	self.inst:RemoveTag("magiciantool")
end

function MagicianTool:OnRemoveEntity()
	if self.user ~= nil then
		if self.user.components.magician ~= nil then
			self.user.components.magician:DropToolOnStop()
		end
		self:StopUsing()
	end
end

function MagicianTool:SetOnStartUsingFn(fn)
	self.onstartusingfn = fn
end

function MagicianTool:SetOnStopUsingFn(fn)
	self.onstopusingfn = fn
end

--called by magician component
function MagicianTool:OnStartUsing(doer)
	if self.user ~= nil then
		return
	end
	self.user = doer
	if self.onstartusingfn ~= nil then
		self.onstartusingfn(self.inst, doer)
	end
end

--called by magician component
function MagicianTool:OnStopUsing(doer)
	if self.user ~= doer then
		return
	end
	self.user = nil
	if self.onstopusingfn ~= nil then
		self.onstopusingfn(self.inst, doer)
	end
end

function MagicianTool:StopUsing()
	if self.user ~= nil then
		if self.user.components.magician ~= nil then
			self.user.components.magician:StopUsing()
		else
			self:OnStopUsing(self.user)
		end
	end
end

return MagicianTool
