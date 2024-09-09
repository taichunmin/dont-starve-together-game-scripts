local RecallMark = Class(function(self, inst)
    self.inst = inst

	inst:AddTag("recall_unmarked")
end)

function RecallMark:MarkPosition(recall_x, recall_y, recall_z, recall_worldid)
	if recall_x ~= nil then
		self.recall_x = recall_x or 0
		self.recall_y = recall_y or 0
		self.recall_z = recall_z or 0
		self.inst:RemoveTag("recall_unmarked")

		self.recall_worldid = recall_worldid or TheShard:GetShardId()
	end

	if self.onMarkPosition ~= nil then
		self.onMarkPosition(self.inst, recall_x, recall_y, recall_z, recall_worldid)
	end
end

function RecallMark:Copy(rhs)
	rhs = rhs ~= nil and rhs.components.recallmark
	if rhs then
		self:MarkPosition(rhs.recall_x, rhs.recall_y, rhs.recall_z, rhs.recall_worldid)
	end
end

function RecallMark:IsMarked()
	return self.recall_worldid ~= nil
end

function RecallMark:IsMarkedForSameShard()
	return self.recall_worldid == TheShard:GetShardId()
end

function RecallMark:GetMarkedPosition()
	if self.recall_worldid == TheShard:GetShardId() then
		return self.recall_x, self.recall_y, self.recall_z
	end

	return nil
end

function RecallMark:OnSave()
	return {
		recall_x = self.recall_x,
		recall_y = self.recall_y,
		recall_z = self.recall_z,
		recall_worldid = self.recall_worldid,
	}
end

function RecallMark:OnLoad(data)
	if data ~= nil and data.recall_worldid ~= nil then
		self:MarkPosition(data.recall_x, data.recall_y, data.recall_z, data.recall_worldid)
	end
end

return RecallMark