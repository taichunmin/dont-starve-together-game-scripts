local ConstructionSite = Class(function(self, inst)
    self.inst = inst

    if TheWorld.ismastersim then
        self.classified = SpawnPrefab("constructionsite_classified")
        self.classified.entity:SetParent(inst.entity)
    elseif self.classified == nil and inst.constructionsite_classified ~= nil then
        self.classified = inst.constructionsite_classified
        inst.constructionsite_classified.OnRemoveEntity = nil
        inst.constructionsite_classified = nil
        self:AttachClassified(self.classified)
    end
end)

--------------------------------------------------------------------------

function ConstructionSite:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified:Remove()
            self.classified = nil
        else
            self.classified._parent = nil
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

ConstructionSite.OnRemoveEntity = ConstructionSite.OnRemoveFromEntity

--------------------------------------------------------------------------

function ConstructionSite:AttachClassified(classified)
    self.classified = classified

    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function ConstructionSite:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------
--Server interface
--------------------------------------------------------------------------

function ConstructionSite:SetBuilder(builder)
    self.classified.Network:SetClassifiedTarget(builder or self.inst)
    if self.inst.components.constructionsite == nil then
        --Should only reach here during constructionsite construction
        assert(builder == nil)
    end
end

function ConstructionSite:SetSlotCount(slot, num)
    self.classified:SetSlotCount(slot, num)
end

--------------------------------------------------------------------------
--Common interface
--------------------------------------------------------------------------

function ConstructionSite:IsBuilder(guy)
    if self.inst.components.constructionsite ~= nil then
        return self.inst.components.constructionsite:IsBuilder(guy)
    else
        return self.classified ~= nil and guy ~= nil and guy == ThePlayer
    end
end

function ConstructionSite:GetSlotCount(slot)
    if self.inst.components.constructionsite ~= nil then
        return self.inst.components.constructionsite:GetSlotCount(slot)
    else
        return self.classified ~= nil and self.classified:GetSlotCount(slot) or 0
    end
end

function ConstructionSite:GetIngredients()
    return CONSTRUCTION_PLANS[self.inst.prefab] or {}
end

return ConstructionSite
