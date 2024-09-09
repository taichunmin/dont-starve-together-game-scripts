local PaperEraser = Class(function(self, inst)
    self.inst = inst

    --self.stacksize = 1
	--self.erased_prefab = "papyrus"

	self.inst:AddTag("papereraser")
end)

function PaperEraser:OnRemoveFromEntity()
    self.inst:RemoveTag("papereraser")
end

function PaperEraser:DoErase(paper, doer)
	return paper.components.erasablepaper:DoErase(self.inst, doer) ~= nil
end

return PaperEraser