
local DECORE_MUST_TAGS = {"carnivaldecor"}
local function recalculate_decor(inst)
	local self = inst.components.carnivaldecorranker

    local x, y, z = inst.Transform:GetWorldPosition()
	local count = 0
	local decors = TheSim:FindEntities(x, y, z, TUNING.CARNIVAL_DECOR_RANK_RANGE, DECORE_MUST_TAGS)
	for _, decor in ipairs(decors) do
		if decor:GetCurrentPlatform() == nil then
			self.decor[decor] = decor.components.carnivaldecor:GetDecorValue()
		end
	end

	self:UpdateDecorValue(true)
end

local CarnivalDecorRanker = Class(function(self, inst)
    self.inst = inst

	self.decor = {}
	self.totalvalue = 0
	self.rank = 0

	--self.onrankchanged = nil

	inst:AddTag("carnivaldecor_ranker")

	inst:DoTaskInTime(0, recalculate_decor)
end)

function CarnivalDecorRanker:UpdateDecorValue(snap)
	self.totalvalue = 0
	for _, v in pairs(self.decor) do
		self.totalvalue = self.totalvalue + v
	end

	local new_rank = math.min(math.floor(self.totalvalue / TUNING.CARNIVAL_DECOR_VALUE_PER_RANK) + 1, TUNING.CARNIVAL_DECOR_RANK_MAX)
	if new_rank ~= self.rank then
		if self.onrankchanged ~= nil then
			local prev_rank = self.rank
			self.rank = new_rank
			self.onrankchanged(self.inst, new_rank, prev_rank, snap)
		end
	end
end

function CarnivalDecorRanker:AddDecor(decor)
	self.decor[decor] = decor.components.carnivaldecor ~= nil and decor.components.carnivaldecor:GetDecorValue() or nil
	self:UpdateDecorValue()
end

function CarnivalDecorRanker:RemoveDecor(decor)
	self.decor[decor] = nil
	self:UpdateDecorValue()
end

function CarnivalDecorRanker:GetDebugString()
	return "Num Decor: " .. tostring(GetTableSize(self.decor)) .. " Value: " .. tostring(self.totalvalue) .. " Rank: " .. tostring(self.rank)
end

return CarnivalDecorRanker