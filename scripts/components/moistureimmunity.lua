local MoistureImmunity = Class(function(self, inst)
	self.inst = inst
	self.sources = {}

	self._onremovesource = function(src)
		self.sources[src] = nil
		if next(self.sources) == nil then
			inst:RemoveComponent("moistureimmunity")
		end
	end
end)

function MoistureImmunity:OnRemoveFromEntity()
	self.inst:RemoveTag("moistureimmunity")

	for src in pairs(self.sources) do
		self:RemoveSource_Internal(src)
	end
end

function MoistureImmunity:AddSource(src)
	if not self.sources[src] then
		if next(self.sources) == nil then
			self.inst:AddTag("moistureimmunity")
		end
		self.sources[src] = true
		if src ~= self.inst then
			self.inst:ListenForEvent("onremove", self._onremovesource, src)
		end

		if self.inst.components.moisture ~= nil then
			self.inst.components.moisture:ForceDry(true, src)
		end
	end
end

function MoistureImmunity:RemoveSource_Internal(src)
	--V2C: this is here and not in the _onremovesource because
	--     moisture component force dry already handles source
	--     "onremove" on its own.
	if self.inst.components.moisture ~= nil then
		self.inst.components.moisture:ForceDry(false, src)
	end

	if src ~= self.inst then
		self.inst:RemoveEventCallback("onremove", self._onremovesource, src)
	end
end

function MoistureImmunity:RemoveSource(src)
	if self.sources[src] then
		self:RemoveSource_Internal(src)
		self._onremovesource(src)
	end
end

return MoistureImmunity
