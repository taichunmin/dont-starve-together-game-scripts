

local MinigameSpectator = Class(function(self, inst)
    self.inst = inst

	self.minigame = nil

	self.onminigameover = function() self.inst:RemoveComponent("minigame_spectator") end
end)

function MinigameSpectator:OnRemoveFromEntity()
	if self.minigame ~= nil and self.minigame:IsValid() then
		self.inst:RemoveEventCallback("onremove", self.onminigameover, self.minigame)
		self.inst:RemoveEventCallback("ms_minigamedeactivated", self.onminigameover, self.minigame)
	end
end

function MinigameSpectator:SetWatchingMinigame(minigame)
	if self.minigame == nil then
		self.minigame = minigame
		self.inst:ListenForEvent("onremove", self.onminigameover, minigame)
		self.inst:ListenForEvent("ms_minigamedeactivated", self.onminigameover, minigame)

		-- stop attacking players when the mini game starts
		if self.inst.components.combat ~= nil and self.inst.components.combat.target ~= nil and self.inst.components.combat.target:HasTag("player") then
			self.inst.components.combat:DropTarget()
		end
	end
end

function MinigameSpectator:GetMinigame()
	return self.minigame
end

function MinigameSpectator:GetDebugString()
    return "Is Watching: " .. tostring(self.minigame)
end

return MinigameSpectator
