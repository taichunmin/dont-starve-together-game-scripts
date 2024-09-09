
local DECOR_RANKER_MUST_TAGS = {"carnivaldecor_ranker"}

local function add_to_counters(inst)
	if inst:GetCurrentPlatform() == nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		local rankers = TheSim:FindEntities(x, y, z, TUNING.CARNIVAL_DECOR_RANK_RANGE, DECOR_RANKER_MUST_TAGS)
		for _, obj in ipairs(rankers) do
			obj.components.carnivaldecorranker:AddDecor(inst)
		end
	end
end

local function remove_from_counters(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local rankers = TheSim:FindEntities(x, y, z, TUNING.CARNIVAL_DECOR_RANK_RANGE, DECOR_RANKER_MUST_TAGS)
	for _, obj in ipairs(rankers) do
		obj.components.carnivaldecorranker:RemoveDecor(inst)
	end
end

local CarnivalDecor = Class(function(self, inst)
    self.inst = inst
	self.value = 1

	if not POPULATING then
		inst:DoTaskInTime(0, add_to_counters)
	end

	inst:AddTag("carnivaldecor")
end)

function CarnivalDecor:OnRemoveFromEntity()
    self.inst:RemoveTag("carnivaldecor")
	remove_from_counters(self.inst)
end

function CarnivalDecor:OnRemoveEntity()
	remove_from_counters(self.inst)
end

function CarnivalDecor:GetDecorValue()
	return self.value
end

return CarnivalDecor