local Talkable = Class(function(self, inst)
    self.inst = inst
    self.conversation = nil
    self.conv_index = 1
end)

return Talkable