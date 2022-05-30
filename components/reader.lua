local Reader = Class(function(self, inst)
    self.inst = inst

    inst:AddTag("reader")
end)

function Reader:OnRemoveFromEntity()
    self.inst:RemoveTag("reader")
end

function Reader:Read(book)
	if book.components.book then
		if book.components.book:OnRead(self.inst) then
			if book.components.finiteuses then
				book.components.finiteuses:Use(1)
			end
			return true
		end
	end
end

return Reader