local function ontype(self, type, old_type)
	if old_type ~= nil then
		self.inst:Removetag("trophyscale_"..old_type)
	end
	if type ~= nil then
		self.inst:AddTag("trophyscale_"..type)
	end
end

local TrophyScale = Class(function(self, inst)
    self.inst = inst

	self.type = nil
	self.item_data = nil
	self.compare_postfn = nil

	--self.onspawnitemfromdatafn = nil
	--self.onitemtakenfn = nil
	--self.takeitemtestfn = nil

	self.accepts_items = true

	self.inst:AddTag("trophyscale")
end,
nil,
{
	type = ontype
})

function TrophyScale:OnRemoveFromEntity()
    self.inst:RemoveTag("trophyscale")
end

function TrophyScale:GetDebugString()
    return self.item_data ~= nil and string.format("weight: %.5f,   prefab: %s,   owner: %s,	override owner: %s",
		self.item_data.weight,
		self.item_data.prefab or "nil",
		self.item_data.owner_userid ~= nil and self.item_data.owner_userid or "nil",
		self.item_data.prefab_override_owner ~= nil and self.item_data.prefab_override_owner or "nil")
		or string.format("empty")
end

function TrophyScale:SetComparePostFn(fn)
	self.compare_postfn = fn
end

function TrophyScale:SetOnSpawnItemFromDataFn(fn)
	self.onspawnitemfromdatafn = fn
end

function TrophyScale:SetTakeItemTestFn(fn)
	self.takeitemtestfn = fn
end

function TrophyScale:SetOnItemTakenFn(fn)
	self.onitemtakenfn = fn
end

function TrophyScale:GetItemData()
	return self.item_data
end

function TrophyScale:Compare(inst_compare, doer)
	local new_weight = inst_compare.components.weighable:GetWeight()

	if self.item_data == nil or (self.item_data.weight == nil or self.item_data.weight <= 0) or (new_weight ~= nil and new_weight > self.item_data.weight) then
		local item_data_old = deepcopy(self.item_data)

		self.item_data = {}
		self.item_data.weight = new_weight or 0
		self.item_data.is_heavy = inst_compare.components.weighable.weight_percent ~= nil
			and inst_compare.components.weighable.weight_percent >= TUNING.WEIGHABLE_HEAVY_WEIGHT_PERCENT
			or false
		self.item_data.prefab = inst_compare.prefab
		self.item_data.build = inst_compare.AnimState:GetBuild()
		self.item_data.owner_userid = inst_compare.components.weighable.owner_userid
		self.item_data.owner_name = inst_compare.components.weighable.owner_name
		self.item_data.prefab_override_owner = inst_compare.components.weighable.prefab_override_owner

		if self.compare_postfn ~= nil then
			self.compare_postfn(self.item_data, inst_compare)
		end

		if inst_compare.components.stackable and inst_compare.components.stackable:IsStack() then
			inst_compare.components.stackable:Get():Remove()
		else
			inst_compare:Remove()
		end

		self.inst:PushEvent("onnewtrophy", { old = item_data_old, new = self.item_data, doer = doer })

		return true
	else
		return false, self.type.."_TOO_SMALL"
	end
end

function TrophyScale:ClearItemData()
	self.item_data = nil
end

function TrophyScale:SpawnItemFromData(override_data)
	local data = override_data or self.item_data
	if data ~= nil and data.prefab ~= nil then
		local item = SpawnPrefab(data.prefab)

		if item.components.weighable ~= nil then
			item.components.weighable:SetWeight(data.weight or 0)

			item.components.weighable.owner_userid = data.owner_userid
			item.components.weighable.owner_name = data.owner_name
			item.components.weighable.prefab_override_owner = data.prefab_override_owner
		end

		if self.onspawnitemfromdatafn ~= nil then
			self.onspawnitemfromdatafn(item, data)
		end

		return item
	end

	return nil
end

function TrophyScale:SetItemCanBeTaken(can_be_taken)
	if can_be_taken then
		if not self.inst:HasTag("trophycanbetaken") then
			self.inst:AddTag("trophycanbetaken")
		end
	else
		if self.inst:HasTag("trophycanbetaken") then
			self.inst:RemoveTag("trophycanbetaken")
		end
	end
end

function TrophyScale:TakeItem(receiver)
	local item = nil

	if self.item_data ~= nil and self.item_data.prefab ~= nil and
		receiver ~= nil and receiver.components.inventory ~= nil then

		item = self:SpawnItemFromData()
		if item ~= nil then
			receiver.components.inventory:GiveItem(item, nil, self.inst:GetPosition())
		end
	end

	if item ~= nil then
		self.onitemtakenfn(self.inst, self.item_data)
		self:ClearItemData()
		return true
	else
		return false
	end
end

function TrophyScale:OnSave()
	return self.item_data
end

function TrophyScale:OnLoad(data)
	if data ~= nil then
		self.item_data = data
	end
end

return TrophyScale