local Fertilizer = Class(function(self, inst)
    self.inst = inst
    self.fertilizervalue = 1
    self.soil_cycles = 1
    self.withered_cycles = 1
    self.fertilize_sound = "dontstarve/common/fertilize"
end)

return Fertilizer
