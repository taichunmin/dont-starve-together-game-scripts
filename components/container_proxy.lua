local ContainerProxy = Class(function(self, inst)
	self.inst = inst

	--cache variables
	self.ismastersim = TheWorld.ismastersim

	--network variables
	self._cannotbeopened = net_bool(inst.GUID, "container_proxy._cannotbeopened")

	if self.ismastersim then
		--Server only
		self.master = nil
		self.openlist = {}
		self.opencount = 0
		self.onopenfn = nil
		self.onclosefn = nil
		--self._onmasteropenother = nil
		--self._onmasterclose = nil
	else
		--Client only
		self.container_opener = nil
	end
end)

--------------------------------------------------------------------------
--Client & Server

function ContainerProxy:OnRemoveFromEntity()
	assert(false)
end

function ContainerProxy:OnRemoveEntity()
	if self.ismastersim then
		self:Close()
		self:SetMaster(nil)
	end
end

function ContainerProxy:SetCanBeOpened(canbeopened)
	self._cannotbeopened:set(not canbeopened)
end

function ContainerProxy:CanBeOpened()
	return not self._cannotbeopened:value()
end

function ContainerProxy:IsOpenedBy(guy)
	if self.ismastersim then
		return self.openlist[guy] ~= nil
	else
		return self.container_opener ~= nil and guy == ThePlayer
	end
end

--------------------------------------------------------------------------
--Client only

function ContainerProxy:AttachOpener(container_opener)
	assert(not self.ismastersim and self.container_opener == nil)
	self.container_opener = container_opener
	self.inst:ListenForEvent("onremove", function() self.container_opener = nil end, container_opener)
end

--------------------------------------------------------------------------
--Master Sim

function ContainerProxy:GetMaster()
	--assert(self.ismastersim)
	return self.master
end

function ContainerProxy:SetMaster(ent)
	if self.master == ent then
		return
	elseif self.master ~= nil then
		self.inst:RemoveEventCallback("onopenother", self._onmasteropenother, self.master)
		self.inst:RemoveEventCallback("onclose", self._onmasterclose, self.master)
		self._onmasteropenother = nil
		self._onmasterclose = nil
		self.master = nil
	end

	if ent ~= nil then
		self.master = ent
		self._onmasteropenother = function(ent, data)
			if data ~= nil then
				self:Close(data.doer)
			end
		end
		self._onmasterclose = function(ent, data)
			if data ~= nil then
				self:OnClose(data.doer)
			end
		end
		self.inst:ListenForEvent("onopenother", self._onmasteropenother, ent)
		self.inst:ListenForEvent("onclose", self._onmasterclose, ent)
	end
end

function ContainerProxy:SetOnOpenFn(fn)
	assert(self.ismastersim)
	self.onopenfn = fn
end

function ContainerProxy:SetOnCloseFn(fn)
	assert(self.ismastersim)
	self.onclosefn = fn
end

function ContainerProxy:Open(doer)
	--assert(self.ismastersim)
	if doer ~= nil and self.openlist[doer] == nil then
		self.master:PushEvent("onopenother", { doer = doer, other = self.inst })
		self.master.components.container:Open(doer)
		if not self.master.components.container:IsOpenedBy(doer) then
			return
		end

		local container_opener = SpawnPrefab("container_opener")
		container_opener.entity:SetParent(self.inst.entity)
		container_opener.Network:SetClassifiedTarget(doer)

		self.openlist[doer] = container_opener
		self.opencount = self.opencount + 1

		if doer.components.inventory ~= nil then
			doer.components.inventory.opencontainerproxies[self.inst] = true
		end

		if self.opencount == 1 then
			if self.inst.Transform ~= nil then
				self.inst:StartUpdatingComponent(self)
			end

			if self.onopenfn ~= nil then
				self.onopenfn(self.inst)
			end
		end
	end
end

function ContainerProxy:Close(doer)
	--assert(self.ismastersim)
	if doer ~= nil then
		self.master.components.container:Close(doer)
	else
		for opener in pairs(self.openlist) do
			self.master.components.container:Close(opener)
		end
	end
end

function ContainerProxy:OnClose(doer)
	--assert(self.ismastersim)
	if doer ~= nil and self.openlist[doer] ~= nil then
		self.master:PushEvent("oncloseother", { doer = doer, other = self.inst })
		self.openlist[doer]:Remove()
		self.openlist[doer] = nil
		self.opencount = self.opencount - 1

		if doer.components.inventory ~= nil then
			doer.components.inventory.opencontainerproxies[self.inst] = nil
		end

		if self.opencount == 0 then
			self.inst:StopUpdatingComponent(self)

			if self.onclosefn ~= nil then
				self.onclosefn(self.inst)
			end
		end
	end
end

function ContainerProxy:OnUpdate(dt)
	--assert(self.ismastersim)
	--Use original container component's OnUpdate logic
	--Requires:
	--  self.opencount
	--  self.openlist
	--  self:Close(doer)
	self.master.components.container.OnUpdate(self, dt)
end

return ContainerProxy
