local RainImmunity = Class(function(self, inst)
	self.inst = inst
	self.sources = {}

	inst:AddTag("rainimmunity")

	self._onremovesource = function(src)
		self.sources[src] = nil
		if next(self.sources) == nil then
			inst:RemoveComponent("rainimmunity")
		end
	end

    -- NOTES(JBK): Using a component check in a callback to this event will not work;
	-- EntityScript does not add the component until after this initialization happens.
    -- Assume the entity has the component when this event fires.
	inst:PushEvent("gainrainimmunity")
end)

function RainImmunity:OnRemoveFromEntity()
	self.inst:RemoveTag("rainimmunity")

	for src in pairs(self.sources) do
		if src ~= self.inst then
			self.inst:RemoveEventCallback("onremove", self._onremovesource, src)
		end
	end

	self.inst:PushEvent("loserainimmunity")
end

function RainImmunity:AddSource(src)
	if not self.sources[src] then
		self.sources[src] = true
		if src ~= self.inst then
			self.inst:ListenForEvent("onremove", self._onremovesource, src)
		end
	end
end

function RainImmunity:RemoveSource(src)
	if self.sources[src] then
		if src ~= self.inst then
			self.inst:RemoveEventCallback("onremove", self._onremovesource, src)
		end
		self._onremovesource(src)
	end
end

return RainImmunity
