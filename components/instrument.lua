local Instrument = Class(function(self, inst)
    self.inst = inst
    self.range = 15
    self.onheard = nil
    self.onplayed = nil
end)

function Instrument:SetOnHeardFn(fn)
    self.onheard = fn
end

function Instrument:SetOnPlayedFn(fn)
    self.onplayed = fn
end

local NOTAGS = { "FX", "DECOR", "INLIMBO" }
function Instrument:Play(musician)
    if self.onplayed ~= nil then
        self.onplayed(self.inst, musician)
    end
    if self.onheard ~= nil then
        local x, y, z = musician.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, self.range, nil, NOTAGS)
        for i, v in ipairs(ents) do
            if v ~= self.inst then
                self.onheard(v, musician, self.inst)
            end
        end
    end
    return true
end

return Instrument
