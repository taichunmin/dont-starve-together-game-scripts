

local function Validate(inst)
	local self = inst.components.hideandseeker

	local game = inst.components.hideandseeker ~= nil and inst.components.hideandseeker.hideandseekgame or nil
	local hideandseek = (game ~= nil and game:IsValid()) and game.components.hideandseekgame or nil

	if hideandseek == nil or not hideandseek:IsActive() then
		if inst.components.talker ~= nil and self.abort_game_msg ~= nil then
			inst.components.talker:Say(GetString(inst, self.abort_game_msg))
		end
		inst:RemoveComponent("hideandseeker")

	elseif self.is_faraway then
		if inst:IsNear(game, hideandseek.hiding_range) then
			self.is_faraway = false
			if inst.components.talker ~= nil and hideandseek.seeker_too_far_return_announce ~= nil then
				inst.components.talker:Say(GetString(inst, hideandseek.seeker_too_far_return_announce))
			end
		end

	elseif not inst:IsNear(game, hideandseek.hiding_range_toofar) then
		self.is_faraway = true

		if inst.components.talker ~= nil and hideandseek.seeker_too_far_announce ~= nil then
			inst.components.talker:Say(GetString(inst, hideandseek.seeker_too_far_announce))
		end
			
	end
end

local HideAndSeeker = Class(function(self, inst)
    self.inst = inst

	self.validate_task = self.inst:DoPeriodicTask(1, Validate)
end)

function HideAndSeeker:OnRemoveFromEntity()
	if self.validate_task ~= nil then
		self.validate_task:Cancel()
		self.validate_task = nil
	end

end

function HideAndSeeker:SetGame(hideandseekgame)
	self.hideandseekgame = hideandseekgame
	self.abort_game_msg = hideandseekgame ~= nil and hideandseekgame.components.hideandseekgame.gameaborted_announce or nil
end

function HideAndSeeker:GetDebugString()
	return "" .. tostring(self.hideandseekgame) .. ", is far away: " .. tostring(self.is_faraway)

end

return HideAndSeeker
