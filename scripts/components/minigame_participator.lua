local MinigameParticipator = Class(function(self, inst)
    self.inst = inst

	self.minigame = nil
	self.updatecheck = nil

	--self.notimeout = nil

	self.inst:AddTag("minigame_participator")

	self.onminigameover = function()
        self.inst:RemoveComponent("minigame_participator")
        self.minigame = nil
    end
end)

function MinigameParticipator:OnRemoveFromEntity()
	self.inst:RemoveTag("minigame_participator")

	if self.updatecheck ~= nil then
		self.updatecheck:Cancel()
		self.updatecheck = nil
	end

	if self.minigame ~= nil and self.minigame:IsValid() then
		self.inst:RemoveEventCallback("onremove", self.onminigameover, self.minigame)
		self.inst:RemoveEventCallback("ms_minigamedeactivated", self.onminigameover, self.minigame)
	end

	if self.inst.components.leader ~= nil then
		for k,v in pairs(self.inst.components.leader.followers) do
			if k.components.combat ~= nil then
				k.components.combat.keeptargettimeout = 0 -- revalidate the target
			end
		end
	end
end

function MinigameParticipator:GetMinigame()
	return self.minigame
end

function MinigameParticipator:SetMinigame(minigame)
	if not self.notimeout then
		self.expireytime = GetTime() + 3
	end
	if self.minigame == nil then
		self.minigame = minigame
		self.inst:ListenForEvent("onremove", self.onminigameover, minigame)
		self.inst:ListenForEvent("ms_minigamedeactivated", self.onminigameover, minigame)

		if not self.notimeout then
			self.updatecheck = self.inst:DoPeriodicTask(0.9, function()
                if self.expireytime - GetTime() < 0 then
                    self:onminigameover()
                end
            end)
		end

		if self.inst.components.leader ~= nil then
		    for k,v in pairs(self.inst.components.leader.followers) do
				if k.components.follower ~= nil and not k.components.follower.keepleaderduringminigame then
					k.components.follower:StopFollowing()
				end
			end
		end
	end
end

function MinigameParticipator:CurrentMinigameType()
    return (self.minigame and self.minigame.components.minigame and self.minigame.components.minigame.gametype)
        or nil
end

function MinigameParticipator:GetDebugString()
    return "Playing: " .. tostring(self.minigame)
end

return MinigameParticipator
