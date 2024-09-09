local RainDomeWatcher = Class(function(self, inst)
	self.inst = inst
	self.underdome = false
	inst:StartUpdatingComponent(self)
end)

function RainDomeWatcher:IsUnderRainDome()
	return self.underdome
end

function RainDomeWatcher:OnUpdate(dt)
	local x, y, z = self.inst.Transform:GetWorldPosition()
	local domes = GetRainDomesAtXZ(x, z)
	if #domes > 0 then
		if not self.underdome then
			self.underdome = true
			self.inst:PushEvent("enterraindome")
		end
		self.inst:PushEvent("underraindomes", domes)
	elseif self.underdome then
		self.underdome = false
		self.inst:PushEvent("exitraindome")
	end
end

return RainDomeWatcher
