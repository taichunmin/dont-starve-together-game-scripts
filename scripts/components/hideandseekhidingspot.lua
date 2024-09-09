local HideAndSeekHidingSpot = Class(function(self, inst)
    self.inst = inst

	self.evict_fn = function(hidingspot, data) 
		local finder = data ~= nil and data.picker or data.doer or data.worker or data.owner
		if finder ~= nil and not finder.isplayer then
			finder = nil
		end

		self:SearchHidingSpot(finder) 
	end
	self.onremove_hider = function() self.hider = nil self.inst:RemoveComponent("hideandseekhidingspot") end

	self.on_collecthiddenkitcoons = function(w, data) table.insert(data.hidingspots, inst) end
	self.inst:ListenForEvent("ms_collecthiddenkitcoons", self.on_collecthiddenkitcoons, TheWorld)
end)

function HideAndSeekHidingSpot:_ReleaesHider(doer)
	if self.hider ~= nil then
		if self.hiding_prop ~= nil then
			self.hider.entity:SetParent(nil)
			self.hider:ReturnToScene()
			self.hider.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
			self.hider.components.hideandseekhider:Found(doer)
		end

		self.finder = doer

		self.inst:RemoveEventCallback("onremove", self.onremove_hider, self.hider)
		self.hider = nil
	end
end

function HideAndSeekHidingSpot:OnRemoveEntity()
	self:_ReleaesHider()
end

function HideAndSeekHidingSpot:OnRemoveFromEntity()
	self:_ReleaesHider()

	self.inst:RemoveEventCallback("ms_collecthiddenkitcoons", self.on_collecthiddenkitcoons, TheWorld)

	self.inst:PushEvent("onhidingspotremoved", {finder = self.finder})

	if self.hiding_prop ~= nil and self.hiding_prop:IsValid() then
		self.hiding_prop:Remove()
	end
end

function HideAndSeekHidingSpot:SetHider(hider)
	-- this is just setting who will be hiding here, they may take some time to arrive at the hiding spot
	if self.hider == nil then
		self.hider = hider
		self.inst:ListenForEvent("onremove", self.onremove_hider, hider)
	end
end

function HideAndSeekHidingSpot:HideInSpot(hider)
	self:SetHider(hider)

	hider.entity:SetParent(self.inst.entity)
	hider:RemoveFromScene()
	hider.Transform:SetPosition(0, 0, 0)

	self.hiding_prop = SpawnPrefab(hider._hiding_prop)
	self.hiding_prop.entity:SetParent(self.inst.entity)
	self.hiding_prop.AnimState:SetBuild(self.hider.AnimState:GetBuild())

	local offset = TUNING.KITCOON_HIDING_OFFSET[self.inst.prefab]
	if offset ~= nil then
		self.hiding_prop.entity:AddFollower()
		self.hiding_prop.Follower:FollowSymbol(self.inst.GUID, nil, offset[1], offset[2], offset[3])
	end
	
	-- Note: using the hiding_prop as the event listener so they will clean up on their own (if it was on self.inst, then we have to call RemoveEventCallback on all of these)
	--self.hiding_prop:ListenForEvent("haunted", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("picked", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("worked", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("onignite", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("onopen", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("onactivated", self.evict_fn, self.inst)
	self.hiding_prop:ListenForEvent("onpickup", self.evict_fn, self.inst)
end

function HideAndSeekHidingSpot:SearchHidingSpot(doer)
	self:_ReleaesHider(doer)
	self.inst:RemoveComponent("hideandseekhidingspot")
end

function HideAndSeekHidingSpot:Abort()
	self:_ReleaesHider(nil)
	self.inst:RemoveComponent("hideandseekhidingspot")
end


function HideAndSeekHidingSpot:OnSave()
	local hider_is_hiding = self.hider ~= nil and self.hiding_prop ~= nil

	local data = { add_component_if_missing = true }
	local refs = nil

	if hider_is_hiding then
		data.hider_saverecord, refs = self.hider:GetSaveRecord()
	end

	return data, refs
end

function HideAndSeekHidingSpot:OnLoad(data, newents)
	if data ~= nil then
		if data.hider_saverecord ~= nil then
			local hider = SpawnSaveRecord(data.hider_saverecord, newents)
			self:HideInSpot(hider)
		end
	end
end

function HideAndSeekHidingSpot:GetDebugString()
    return "" .. (self.hider ~= nil and self.hider.prefab or "This component should not be here!")
end

return HideAndSeekHidingSpot
