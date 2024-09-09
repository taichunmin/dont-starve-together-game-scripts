

local WinterTreeGiftable = Class(function(self, inst)
    self.inst = inst

    self.previousgiftday = -100
end)

function WinterTreeGiftable:GetDaysSinceLastGift()
    return TheWorld.state.cycles - self.previousgiftday
end

function WinterTreeGiftable:OnGiftGiven()
    self.previousgiftday = TheWorld.state.cycles
end

function WinterTreeGiftable:OnSave()
    return
    {
        previousgiftday = self.previousgiftday,
    }
end

function WinterTreeGiftable:OnLoad(data)
    if data ~= nil and self.previousgiftday ~= nil then
        self.previousgiftday = data.previousgiftday
    end
end

return WinterTreeGiftable
