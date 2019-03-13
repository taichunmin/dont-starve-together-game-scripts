

local Minigame = Class(function(self, inst)
    self.inst = inst

	self.active = false
	self.activate_fn = nil
	self.deactivate_fn = nil

	self.spectator_dist = 20
	self.participator_dist = 20

	self.active_pulse = nil
end)

function Minigame:OnRemoveFromEntity()
	self:Deactivate()
end

function Minigame:SetOnActivatedFn(fn)
	self.activate_fn = fn
end

function Minigame:SetOnDeactivatedFn(fn)
	self.deactivate_fn = fn
end

function Minigame:IsActive()
	return self.active
end

function Minigame:Activate()
	self:Deactivate()

	self.active = true
	self:DoActivePulse()
	self.active_pulse = self.inst:DoPeriodicTask(.75, function() self:DoActivePulse() end)

	if self.activate_fn ~= nil then
		self.activate_fn(self.inst)
	end
end

function Minigame:Deactivate()
	if self.active_pulse ~= nil then
		self.active_pulse:Cancel()
		self.active_pulse = nil
	end

	if not self.active then
		return
	end

	self.active = false
	self.inst:PushEvent("ms_minigamedeactivated")

	if self.deactivate_fn ~= nil then
		self.deactivate_fn(self.inst)
	end
end

function Minigame:DoActivePulse()
	local x, y, z = self.inst.Transform:GetWorldPosition()

	local spectators = TheSim:FindEntities(x, y, z, self.spectator_dist, nil, {"monster", "player"}, {"character"})
	for _, spectator in ipairs(spectators) do
		if spectator.components.follower == nil or spectator.components.follower.leader == nil then
			if spectator.components.minigame_spectator == nil then
				spectator:AddComponent("minigame_spectator")
			end
			spectator.components.minigame_spectator:SetWatchingMinigame(self.inst)
		end
	end

	local participators = TheSim:FindEntities(x, y, z, self.participator_dist, {"player"}, nil, nil)
	for _, participator in ipairs(participators) do
		if participator.components.minigame_participator == nil then
			participator:AddComponent("minigame_participator")
		end
		participator.components.minigame_participator:SetMinigame(self.inst)
	end
end

function Minigame:GetDebugString()
    return "Is Active: " .. tostring(self.active)
end

return Minigame
