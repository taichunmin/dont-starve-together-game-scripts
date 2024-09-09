local function OnFadeDirty(inst)
	local self = inst.components.despawnfader
	if not self.updating then
		self.fadeval = self._fade:value() / 7
		self.updating = true
		self.inst:StartUpdatingComponent(self)
		self:OnUpdate(FRAMES)
	end
end

local DespawnFader = Class(function(self, inst)
	self.inst = inst

	self._fade = net_tinybyte(inst.GUID, "despawnfader._fade", "fadedirty")
	self.fadeval = 0
	self.updating = false

	if not TheWorld.ismastersim then
		inst:ListenForEvent("fadedirty", OnFadeDirty)
	end
end)

function DespawnFader:OnRemoveFromEntity()
	if not TheWorld.ismastersim then
		self.inst:RemoveEventCallback("fadedirty", OnFadeDirty)
	end
end

function DespawnFader:FadeOut()
	self.fadeval = 1
	if not self.updating then
		self.updating = true
		self.inst:StartUpdatingComponent(self)
		self.inst:AddTag("NOCLICK")
		self.inst.persists = false
		self:OnUpdate(FRAMES)
	end
end

function DespawnFader:OnUpdate(dt)
	local resync = self.fadeval == 1
	self.fadeval = math.max(0, self.fadeval - dt)
	local k = 1 - self.fadeval
	k = 1 - k * k
	self.inst.AnimState:OverrideMultColour(1, 1, 1, k)
	if self.fadeval <= 0 then
		if TheWorld.ismastersim then
			self.inst:Remove()
		else
			self.updating = false
			self.inst:StopUpdatingComponent(self)
		end
	elseif TheWorld.ismastersim then
		if resync then
			self._fade:set(math.floor(7 * self.fadeval + .5))
		else
			self._fade:set_local(math.floor(7 * self.fadeval + .5))
		end
	end
end

return DespawnFader
