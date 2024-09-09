local ChannelCastable = Class(function(self, inst)
	self.inst = inst
	self.user = nil
	self.strafing = true
	self.onstartchannelingfn = nil
	self.onstopchannelingfn = nil
end)

function ChannelCastable:SetStrafing(enable)
	self.strafing = enable
end

function ChannelCastable:SetOnStartChannelingFn(fn)
	self.onstartchannelingfn = fn
end

function ChannelCastable:SetOnStopChannelingFn(fn)
	self.onstopchannelingfn = fn
end

function ChannelCastable:IsUserChanneling(user)
	return user and user == self.user
end

function ChannelCastable:IsAnyUserChanneling()
	return self.user ~= nil
end

local function OnUnequipped(inst)
	inst.components.channelcastable:StopChanneling()
	inst:RemoveComponent("channelcastable")
end

--Only called by channelcaster component
function ChannelCastable:OnStartChanneling(user)
	if user ~= self.user then
		self:OnStopChanneling(self.user)

		if user and user.components.channelcaster and user:IsValid() then
			self.user = user

			self.inst:ListenForEvent("unequipped", OnUnequipped)

			if self.onstartchannelingfn then
				self.onstartchannelingfn(self.inst, user)
			end
		end
	end
end

--Only called internally or by channelcaster component
function ChannelCastable:OnStopChanneling(user)
	if user and user == self.user then
		self.user = nil

		self.inst:RemoveEventCallback("unequipped", OnUnequipped)

		if self.onstopchannelingfn then
			self.onstopchannelingfn(self.inst, user)
		end
	end
end

function ChannelCastable:StopChanneling()
	if self.user then
		self.user.components.channelcaster:StopChanneling()
	end
end

ChannelCastable.OnRemoveFromEntity = ChannelCastable.StopChanneling
ChannelCastable.OnRemoveEntity = ChannelCastable.StopChanneling

function ChannelCastable:GetDebugString()
	return string.format("channeling=%s user=%s", tostring(self.user ~= nil), tostring(self.user))
end

return ChannelCastable
