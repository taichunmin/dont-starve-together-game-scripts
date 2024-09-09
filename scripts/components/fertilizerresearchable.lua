local FertilizerResearchable = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("fertilizerresearchable")
end)

function FertilizerResearchable:SetResearchFn(fn)
    self.reasearchinfofn = fn
end

function FertilizerResearchable:GetResearchInfo()
    if self.reasearchinfofn then
        return self.reasearchinfofn(self.inst)
    end
end

function FertilizerResearchable:LearnFertilizer(doer)
    local fertilizer = self:GetResearchInfo()
    if fertilizer then
        doer:PushEvent("learnfertilizer", {fertilizer = fertilizer})
    end
end

return FertilizerResearchable