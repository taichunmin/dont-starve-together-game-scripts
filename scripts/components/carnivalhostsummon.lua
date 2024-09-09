
local CarnivalHostSummon = Class(function(self, inst)
    self.inst = inst

    self.inst:AddTag("carnivalhostsummon")
end)

function CarnivalHostSummon:SetCanSummon(cansummon)
    if cansummon then
        self.inst:AddTag("carnivalhostsummon")
    else
        self.inst:RemoveTag("carnivalhostsummon")
    end
end

return CarnivalHostSummon
