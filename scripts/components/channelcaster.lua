local function onchanneling(self, channeling)
	if self.inst.player_classified then
		self.inst.player_classified.ischannelcasting:set(channeling == true)
	end
end

local function onitem(self, item)
	if self.inst.player_classified then
		self.inst.player_classified.ischannelcastingitem:set(item ~= nil)
	end
end

local ChannelCaster = Class(function(self, inst)
	self.inst = inst
	self.item = nil
	self.channeling = false
	self.onstartchannelingfn = nil
	self.onstopchannelingfn = nil
end,
nil,
{
	channeling = onchanneling,
	item = onitem,
})

function ChannelCaster:SetOnStartChannelingFn(fn)
	self.onstartchannelingfn = fn
end

function ChannelCaster:SetOnStopChannelingFn(fn)
	self.onstopchannelingfn = fn
end

function ChannelCaster:IsChannelingItem(item)
	return item and item == self.item
end

function ChannelCaster:IsChanneling()
	return self.channeling
end

local function OnNewState(inst, data)
	if not inst.sg:HasAnyStateTag("idle", "running", "keepchannelcasting") then
		inst.components.channelcaster:StopChanneling()
	end
end

function ChannelCaster:StartChanneling(item)
	if not self.channeling or item ~= self.item then
		self:StopChanneling()

		if item == nil or (item.components.channelcastable and item:IsValid()) then
			if item then
				self.item = item
				item.components.channelcastable:OnStartChanneling(self.inst)
			end

			if self.inst.components.locomotor then
				self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "channelcaster", TUNING.CHANNELCAST_SPEED_MOD)
			end

			self.inst:ListenForEvent("newstate", OnNewState)

			self.channeling = true

			if self.onstartchannelingfn then
				self.onstartchannelingfn(self.inst, item)
			end
			self.inst:PushEvent("startchannelcast", { item = item })
			return true
		end
	end
end

function ChannelCaster:StopChanneling()
	if self.channeling then
		local item = self.item
		if item then
			if item.components.channelcastable then
				item.components.channelcastable:OnStopChanneling(self.inst)
			end
			self.item = nil
		end

		if self.inst.components.locomotor then
			self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "channelcaster")
		end

		self.inst:RemoveEventCallback("newstate", OnNewState)

		self.channeling = false

		if self.onstopchannelingfn then
			self.onstopchannelingfn(self.inst, item)
		end
		self.inst:PushEvent("stopchannelcast", { item = item })
		return true
	end
end

ChannelCaster.OnRemoveFromEntity = ChannelCaster.StopChanneling
ChannelCaster.OnRemoveEntity = ChannelCaster.StopChanneling

function ChannelCaster:GetDebugString()
	return string.format("channeling=%s item=%s", tostring(self.channeling), tostring(self.item))
end

return ChannelCaster
