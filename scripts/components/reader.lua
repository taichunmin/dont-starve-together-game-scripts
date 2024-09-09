local function onaspiringbookworm(self, bookworm)
	if bookworm then
		self.inst:AddTag("aspiring_bookworm")
	else
		self.inst:RemoveTag("aspiring_bookworm")
	end
end

local Reader = Class(function(self, inst)
    self.inst = inst
    --self.aspiring_bookworm = nil

    inst:AddTag("reader")
end,
nil,
{
	aspiring_bookworm = onaspiringbookworm,
})

function Reader:OnRemoveFromEntity()
    self.inst:RemoveTag("reader")
    self.inst:RemoveTag("aspiring_bookworm")
end

function Reader:SetAspiringBookworm(bookworm)
	self.aspiring_bookworm = bookworm
end

function Reader:IsAspiringBookworm()
	return self.aspiring_bookworm or false
end

function Reader:SetSanityPenaltyMultiplier(mult)
	self.sanity_mult = mult
end

function Reader:GetSanityPenaltyMultiplier()
	return self.sanity_mult or 1
end


function Reader:SetOnReadFn(fn)
	self.onread = fn
end

function Reader:Read(book)
	if book.components.book then
		if self.aspiring_bookworm then
			return book.components.book:OnPeruse(self.inst)
		else
			local success, reason = book.components.book:OnRead(self.inst)
			
			if success and self.onread then
				self.onread(self.inst, book)
			end
			
			return success, reason
		end
	end
end

return Reader