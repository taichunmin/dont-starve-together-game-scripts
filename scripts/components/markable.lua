local function onmarkable(self)
    if self.canbemarked then
        self.inst:AddTag("markable")
    else
        self.inst:RemoveTag("markable")
    end
end

local Markable = Class(function(self, inst)
	self.inst = inst
	self.marks = {}
	self.markpool_reset = {1,2,3,4,5,6,7,8}
	self.markpool = deepcopy(self.markpool_reset)
end,
nil,
{
    canbemarked = onmarkable,
})

function Markable:getid()
	if #self.markpool > 0 then
		local rand = math.random(1,#self.markpool)
		local id = self.markpool[rand]
		table.remove(self.markpool,rand)
		return id
	end
end

function Markable:returnid(id)
	table.insert(self.markpool,id)
end

function Markable:Mark(doer)
	-- if found unmark it
	for i,data in ipairs(self.marks)do
		if doer == data.doer then
			-- UNMARk
			if self.unmarkfn then
				self.unmarkfn(self.inst,doer,data.id)
			end

			self:returnid(data.id)

			table.remove(self.marks,i)
			return true
		end
	end

	-- nothing was found so mark it.
	local can, failreason = false, nil
	if self.canmarkfn then
		can, failreason = self.canmarkfn(self.inst,doer)
	end

	if can then
		local id = self:getid()

		if self.markfn then
			self.markfn(self.inst,doer,id)
		end
		table.insert(self.marks,{doer=doer,id=id})

		return true
	end

	return false, failreason
end


function Markable:Unmarkall()
	if self.unmarkallfn then
		self.unmarkallfn(self.inst)
	end
	self.markpool = deepcopy(self.markpool_reset)
	self.marks = {}
end

function Markable:SetMarkable( markable )
	self.canbemarked = markable
end

--[[
function Markable:CanMark( doer )
	if self.canmarkfn then
		self.canmarkfn(self.inst,doer)
	end
end
]]

function Markable:HasMarked( doer )
	for i,mark in ipairs(self.marks)do
		if mark.doer == doer then
			return true
		end
	end
end

function Markable:OnSave()
	local data = {}
	return data
end

function Markable:OnLoad(data)

end

return Markable
