local Plantable = Class(function(self, inst)
    self.inst = inst
    self.growtime = 120
    self.product = nil
end)

return Plantable