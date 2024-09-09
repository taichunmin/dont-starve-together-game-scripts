local ExplosiveResist = Class(function(self,inst)
    self.inst = inst
    self.resistance = 0
    self.maxresistdamage = TUNING.EXPLOSIVE_MAX_RESIST_DAMAGE
    self.decaytime = TUNING.EXPLOSIVE_RESIST_DECAY_TIME
    self.decaydelay = TUNING.EXPLOSIVE_RESIST_DECAY_DELAY
    self.delayremaining = 0
end)

function ExplosiveResist:OnExplosiveDamage(damage, src)
    if damage > 0 then
        self.delayremaining = self.decaydelay
        self:DoDelta(damage / self.maxresistdamage)
    end
end

function ExplosiveResist:GetResistance()
    return self.resistance
end

function ExplosiveResist:DoDelta(delta)
    self:SetResistance(self.resistance + delta)
end

function ExplosiveResist:SetResistance(resistance)
    self.resistance = math.clamp(resistance, 0, 1)
    if self.resistance > 0 then
        self.inst:StartUpdatingComponent(self)
    else
        self.inst:StopUpdatingComponent(self)
        self.delayremaining = 0
    end
end

function ExplosiveResist:OnUpdate(dt)
    if dt < self.delayremaining then
        self.delayremaining = self.delayremaining - dt
    else
        self:DoDelta(-dt / self.decaytime)
    end
end

function ExplosiveResist:OnSave()
    return self.resistance >= 0.01
        and { resistance = math.floor(self.resistance * 100) }
        or nil
end

function ExplosiveResist:OnLoad(data)
    if data ~= nil and data.resistance ~= nil then
        self:SetResistance(data.resistance * .01)
    end
end

function ExplosiveResist:GetDebugString()
    return string.format("Resistance: %.2f", self.resistance)
end

return ExplosiveResist
