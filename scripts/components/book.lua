local Book = Class(function(self, inst)
    self.inst = inst
end)

function Book:SetOnPeruse(fn)
	self.onperuse = fn
end

function Book:SetOnRead(fn)
	self.onread = fn
end

function Book:SetReadSanity(sanity)
	self.read_sanity = sanity
end

function Book:SetPeruseSanity(sanity)
	self.peruse_sanity = sanity
end

function Book:SetFx(fx, fxmount)
	self.fx = fx
	self.fxmount = fxmount or fx
end

function Book:ConsumeUse()
	if self.inst.components.finiteuses then
		self.inst.components.finiteuses:Use(1)
	end
end

function Book:Interact(fn, reader)
	local success = true
	local reason
	if fn then
		success, reason = fn(self.inst, reader)
		if success then
			self:ConsumeUse()
		end
	end

	return success, reason
end

function Book:OnPeruse(reader)
	local success = self:Interact(self.onperuse, reader)
	if success and reader.components.sanity then
		reader.components.sanity:DoDelta(self.peruse_sanity or 0)
	end

	return success
end

function Book:OnRead(reader)
	local success, reason = self:Interact(self.onread, reader)
	if success and reader.components.sanity then
		local ismount = reader.components.rider ~= nil and reader.components.rider:IsRiding()
		local fx = ismount and self.fxmount or self.fx
		if fx ~= nil then
			fx = SpawnPrefab(fx)
			if ismount then
				--In case we did not specify fxmount, convert fx to SixFaced
				fx.Transform:SetSixFaced()
			end
			fx.Transform:SetPosition(reader.Transform:GetWorldPosition())
			fx.Transform:SetRotation(reader.Transform:GetRotation())
		end

		reader.components.sanity:DoDelta( (self.read_sanity or 0) * reader.components.reader:GetSanityPenaltyMultiplier() )
	end

	return success, reason
end

return Book