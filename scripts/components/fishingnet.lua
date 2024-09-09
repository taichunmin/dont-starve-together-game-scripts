local FishingNet = Class(function(self, inst)
    self.inst = inst
end)

function FishingNet:CastNet(pos_x, pos_z, doer)
	local visualizer = SpawnPrefab("fishingnetvisualizer")
	visualizer.components.fishingnetvisualizer:BeginCast(doer, pos_x, pos_z)

	self.visualizer = visualizer

	return true
end

return FishingNet
