local ReplayProxy = Class(function(self, inst)
	self.inst = inst
	self.real_entity_guid = nil
	self.real_entity_prefab_name = ""
end)

function ReplayProxy:SetRealEntityGUID(guid)
	self.real_entity_guid = guid
end

function ReplayProxy:GetRealEntityGUID()
	return self.real_entity_guid
end

function ReplayProxy:SetRealEntityPrefabName(name)
	self.real_entity_prefab_name = name
end

function ReplayProxy:GetRealEntityPrefabName()
	return string.format("%d - %s", self.real_entity_guid, self.real_entity_prefab_name)
end

return ReplayProxy
