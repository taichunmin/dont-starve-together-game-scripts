local function onmarkable(self)
    if self.canbemarked then
        self.inst:AddTag("markable_proxy")
    else
        self.inst:RemoveTag("markable_proxy")
    end
end

local Markable_proxy = Class(function(self, inst)
	self.inst = inst
	self.proxy = nil
end,
nil,
{
    canbemarked = onmarkable,
})

function Markable_proxy:Mark(doer)
	if self.proxy and self.proxy.components.markable then
		return self.proxy.components.markable:Mark(doer)
	end
	return false
end

function Markable_proxy:SetMarkable( markable )
	if self.proxy and self.proxy.components.markable then
		self.proxy.components.markable:SetMarkable( markable )
		self.canbemarked = self.proxy.components.markable.canbemarked
	end
end

function Markable_proxy:HasMarked( doer )
	if self.proxy and self.proxy.components.markable then
		return self.proxy.components.markable:HasMarked( doer )
	end
end


return Markable_proxy
