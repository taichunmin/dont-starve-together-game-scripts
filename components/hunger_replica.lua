local Hunger = Class(function(self, inst)
    self.inst = inst

    if TheWorld.ismastersim then
        self.classified = inst.player_classified
    elseif self.classified == nil and inst.player_classified ~= nil then
        self:AttachClassified(inst.player_classified)
    end
end)

--------------------------------------------------------------------------

function Hunger:OnRemoveFromEntity()
    if self.classified ~= nil then
        if TheWorld.ismastersim then
            self.classified = nil
        else
            self.inst:RemoveEventCallback("onremove", self.ondetachclassified, self.classified)
            self:DetachClassified()
        end
    end
end

Hunger.OnRemoveEntity = Hunger.OnRemoveFromEntity

function Hunger:AttachClassified(classified)
    self.classified = classified
    self.ondetachclassified = function() self:DetachClassified() end
    self.inst:ListenForEvent("onremove", self.ondetachclassified, classified)
end

function Hunger:DetachClassified()
    self.classified = nil
    self.ondetachclassified = nil
end

--------------------------------------------------------------------------

function Hunger:SetCurrent(current)
    if self.classified ~= nil then
        self.classified:SetValue("currenthunger", current)
    end
end

function Hunger:SetMax(max)
    if self.classified ~= nil then
        self.classified:SetValue("maxhunger", max)
    end
end

function Hunger:Max()
    if self.inst.components.hunger ~= nil then
        return self.inst.components.hunger.max
    elseif self.classified ~= nil then
        return self.classified.maxhunger:value()
    else
        return 100
    end
end

function Hunger:GetPercent()
    if self.inst.components.hunger ~= nil then
        return self.inst.components.hunger:GetPercent()
    elseif self.classified ~= nil then
        return self.classified.currenthunger:value() / self.classified.maxhunger:value()
    else
        return 1
    end
end

function Hunger:GetCurrent()
    if self.inst.components.hunger ~= nil then
        return self.inst.components.hunger.current
    elseif self.classified ~= nil then
        return self.classified.currenthunger:value()
    else
        return 100
    end
end


function Hunger:IsStarving()
    if self.inst.components.hunger ~= nil then
        return self.inst.components.hunger:IsStarving()
    else
        return self.classified ~= nil and self.classified.currenthunger:value() <= 0
    end
end

return Hunger