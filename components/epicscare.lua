local EpicScare = Class(function(self, inst)
    self.inst = inst
    self.range = 15
    self.defaultduration = 5
    self.scaremusttags = nil
    self.scareexcludetags = { "epic", "INLIMBO" }
    self.scareoneoftags = { "_combat", "locomotor" }
end)

function EpicScare:SetRange(range)
    self.range = range
end

function EpicScare:SetDefaultDuration(duration)
    self.defaultduration = duration
end

function EpicScare:Scare(duration)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.range, self.scaremusttags, self.scareexcludetags, self.scareoneoftags)
    for i, v in ipairs(ents) do
        if v ~= self.inst and v.entity:IsVisible() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            v:PushEvent("epicscare", { scarer = self.inst, duration = duration or self.defaultduration })
        end
    end
end

return EpicScare
