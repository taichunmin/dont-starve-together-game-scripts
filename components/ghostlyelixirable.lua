
local GhostlyElixirable = Class(function(self, inst)
    self.inst = inst

	self.inst:AddTag("ghostlyelixirable")
end)

function GhostlyElixirable:GetApplyToTarget(doer, elixir)
	if self.overrideapplytotargetfn ~= nil then
		return self.overrideapplytotargetfn(self.inst, doer, elixir)
	end

	return self.inst
end

function GhostlyElixirable:OnRemoveFromEntity()
    self.inst:RemoveTag("ghostlyelixirable")
end

return GhostlyElixirable
