local Book = Class(function(self, inst)
    self.inst = inst
end)

function Book:OnRead(reader)
	if reader:HasTag("aspiring_bookworm") then
		if self.onperuse then
	        return self.onperuse(self.inst, reader)
	    end
	else
    	if self.onread then
	        return self.onread(self.inst, reader)
	    end
	end
    return true
end

return Book