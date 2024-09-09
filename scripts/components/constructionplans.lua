local ConstructionPlans = Class(function(self, inst)
    self.inst = inst
    self.targetprefabs = {}
end)

function ConstructionPlans:AddTargetPrefab(prefab, constructionprefab)
    if self.targetprefabs[prefab] == nil then
        self.inst:AddTag(prefab.."_plans")
    end
    self.targetprefabs[prefab] = constructionprefab
end

function ConstructionPlans:RemoveTargetPrefab(prefab)
    if self.targetprefabs[prefab] ~= nil then
        self.targetprefabs[prefab] = nil
        self.inst:RemoveTag(prefab.."_plans")
    end
end

function ConstructionPlans:StartConstruction(target)
    if target == nil or target.components.constructionsite ~= nil then
        return
    end
    local constructionprefab = self.targetprefabs[target.prefab]
    if constructionprefab == nil then
        return nil, "MISMATCH"
    end
    local product = SpawnPrefab(constructionprefab)
    if product == nil then
        return
    end
    product.Transform:SetPosition(target.Transform:GetWorldPosition())
    target:Remove()
    product:PushEvent("onstartconstruction")
    return product
end

function ConstructionPlans:OnRemoveFromEntity()
    for k, v in pairs(targetprefabs) do
        self.inst:RemoveTag(k.."_plans")
    end
end

return ConstructionPlans
