local Firebug = Class(function(self, inst)
    self.inst = inst
    self.time_to_fire = 60
    self.time_interval = 120
    self.time_variance = 120
    self.sanity_threshold = nil
    self.prefab = nil
    self.enabled = nil
    self:Enable()
end)

function Firebug:Enable(enable)
    if not self.enabled then
        self.enabled = true
        self.inst:StartUpdatingComponent(self)
    end
end

function Firebug:Disable()
    if self.enabled then
        self.enabled = false
        self.inst:StopUpdatingComponent(self)
    end
end

function Firebug:OnUpdate(dt)
    if self.sanity_threshold ~= nil and self.inst.components.sanity:IsInsanityMode() and self.inst.components.sanity:GetPercent() >= self.sanity_threshold then
        return
    elseif self.time_to_fire > dt then
        self.time_to_fire = self.time_to_fire - dt
    else
        self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_LIGHTFIRE"))
        if self.prefab ~= nil then
            SpawnPrefab(self.prefab).Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        end
        self.time_to_fire = self.time_interval + self.time_variance * math.random()
    end
end

function Firebug:GetDebugString()
    return string.format("enabled=%s, time_to_fire=%2.2f", tostring(self.enabled), self.time_to_fire)
end

return Firebug