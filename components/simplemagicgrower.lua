local SimpleMagicGrower = Class(function(self, inst)
    self.inst = inst
end)

function SimpleMagicGrower:SetLastStage(last_stage)
	self.last_stage = last_stage
end

function SimpleMagicGrower:Grow()

	if self.inst.components.growable == nil or self.last_stage == nil then
		return
	end

	if self.inst.components.growable.stage < self.last_stage then
		self.inst.components.growable:DoGrowth()
		self.inst:DoTaskInTime(math.random(), function() self:Grow() end)
	else
		self.inst.components.growable:StartGrowing()
		self.inst:RemoveTag("magicgrowth")
	end
end

function SimpleMagicGrower:StartGrowing()
	self.inst:AddTag("magicgrowth")
	self:Grow()
end

return SimpleMagicGrower