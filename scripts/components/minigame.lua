

local Minigame = Class(function(self, inst)
    self.inst = inst

	self.active = false
	self.activate_fn = nil
	self.deactivate_fn = nil

	self.spectator_dist = 20
	self.participator_dist = 20

	self.watchdist_min = TUNING.MINIGAME_CROWD_DIST_MIN
	self.watchdist_target = TUNING.MINIGAME_CROWD_DIST_TARGET
	self.watchdist_max = TUNING.MINIGAME_CROWD_DIST_MAX

	self.gametype = "unknown"
	self.excitement_time = 0
	self.excitement_delay = 5
	self.state = "intro" -- playing, outro

	self.active_pulse = nil
	self._do_periodic_active_pulse = function()
		self:DoActivePulse()
	end
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
	self.active_pulse = self.inst:DoPeriodicTask(.75, self._do_periodic_active_pulse)

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

function Minigame:AddSpectator(spectator)
	if spectator.components.minigame_spectator == nil then
		spectator:AddComponent("minigame_spectator")
	end
	spectator.components.minigame_spectator:SetWatchingMinigame(self.inst)
end

function Minigame:AddParticipator(participator, notimeout)
    if participator.components.minigame_participator == nil then
        participator:AddComponent("minigame_participator")
        participator.components.minigame_participator.notimeout = notimeout
    end
    participator.components.minigame_participator:SetMinigame(self.inst)
end

local SPECTATOR_CANT_TAGS = {"monster", "player"}
local SPECTATOR_ONEOF_TAGS = {"character"}
local PARTICIPATOR_MUST_TAG = {"player"}
function Minigame:DoActivePulse()
	local x, y, z = self.inst.Transform:GetWorldPosition()

	if self.spectator_dist and self.spectator_dist > 0 then
		local spectators = TheSim:FindEntities(x, y, z, self.spectator_dist, nil, SPECTATOR_CANT_TAGS, SPECTATOR_ONEOF_TAGS)
		for _, spectator in ipairs(spectators) do
			if spectator.components.follower == nil or spectator.components.follower.leader == nil then
				self:AddSpectator(spectator)
			end
		end
	end

	if self.participator_dist and self.participator_dist > 0 then
		local participators = TheSim:FindEntities(x, y, z, self.participator_dist, PARTICIPATOR_MUST_TAG)
		for _, participator in ipairs(participators) do
			self:AddParticipator(participator)
		end
	end
end

function Minigame:SetIsIntro()
	self.state = "intro"
end

function Minigame:GetIsIntro()
	return self.state == "intro"
end

function Minigame:SetIsPlaying()
	self.state = "playing"
end

function Minigame:GetIsPlaying()
	return self.state == "playing"
end

function Minigame:SetIsOutro()
	self.state = "outro"
end

function Minigame:GetIsOutro()
	return self.state == "outro"
end

function Minigame:RecordExcitement()
	self.excitement_time = GetTime()
end

function Minigame:TimeSinceLastExcitement()
	return GetTime() - self.excitement_time
end

function Minigame:IsExciting()
	return GetTime() - self.excitement_time <= self.excitement_delay
end

function Minigame:GetDebugString()
    return "Is Active: " .. tostring(self.active) .. " Is Exciting: " .. tostring(self:IsExciting())
end

return Minigame
