require("behaviours/wander")

local SharkboiWaterBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function SharkboiWaterBrain:OnStart()
	local root = PriorityNode({
		Wander(self.inst),
	}, 0.5)

	self.bt = BT(self.inst, root)
end

return SharkboiWaterBrain
