local Book = Class(function(self, inst)
    self.inst = inst
end)

function Book:OnRead(reader)
    if self.onread then
        return self.onread(self.inst, reader)
    end

    return true
end

return Book