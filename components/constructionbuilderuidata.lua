--V2C: This exists just to avoid adding constructionbuilder_replica

local EMPTY_TABLE = {}

local ConstructionBuilderUIData = Class(function(self, inst)
    self.inst = inst

    self._containerinst = net_entity(inst.GUID, "constructionbuilderuidata._containerinst")
    self._targetinst = net_entity(inst.GUID, "constructionbuilderuidata._targetinst")
end)

function ConstructionBuilderUIData:SetContainer(containerinst)
    self._containerinst:set(containerinst)
end

function ConstructionBuilderUIData:GetContainer()
    return self._containerinst:value()
end

function ConstructionBuilderUIData:SetTarget(targetinst)
    self._targetinst:set(targetinst)
end

function ConstructionBuilderUIData:GetTarget()
    return self._targetinst:value()
end

function ConstructionBuilderUIData:GetConstructionSite()
    return self._targetinst:value() ~= nil and self._targetinst:value().replica.constructionsite or nil
end

function ConstructionBuilderUIData:GetIngredientForSlot(slot)
    return (self._targetinst:value() ~= nil and (CONSTRUCTION_PLANS[self._targetinst:value().prefab] or EMPTY_TABLE)[slot] or EMPTY_TABLE).type
end

function ConstructionBuilderUIData:GetSlotForIngredient(prefab)
    if self._targetinst:value() ~= nil then
        for i, v in ipairs(CONSTRUCTION_PLANS[self._targetinst:value().prefab] or EMPTY_TABLE) do
            if v.type == prefab then
                return i
            end
        end
    end
end

return ConstructionBuilderUIData
