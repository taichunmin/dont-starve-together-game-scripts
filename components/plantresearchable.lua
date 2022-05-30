local PlantResearchable = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("plantresearchable")
end)

function PlantResearchable:SetResearchFn(fn)
    self.reasearchinfofn = fn
end

function PlantResearchable:GetResearchInfo()
    if self.reasearchinfofn then
        return self.reasearchinfofn(self.inst)
    end
end

function PlantResearchable:IsRandomSeed()
    local plant = self:GetResearchInfo()
    return plant == nil
end

function PlantResearchable:LearnPlant(doer)
    local plant, stage = self:GetResearchInfo()
    if plant and stage then
        doer:PushEvent("learnplantstage", {plant = plant, stage = stage})
    end
end

return PlantResearchable