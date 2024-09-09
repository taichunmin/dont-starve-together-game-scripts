local ExpertSailor = Class(function(self, inst)
    self.inst = inst
end)

function ExpertSailor:GetRowForceMultiplier()
    return self.row_force_mult
end

function ExpertSailor:SetRowForceMultiplier(force)
    self.row_force_mult = force
end

function ExpertSailor:GetRowExtraMaxVelocity()
    return self.extra_max_velocity
end

function ExpertSailor:SetRowExtraMaxVelocity(vel)
    self.extra_max_velocity = vel
end

function ExpertSailor:GetAnchorRaisingSpeed()
    return self.anchor_raise_speed
end

function ExpertSailor:SetAnchorRaisingSpeed(speed)
    self.anchor_raise_speed = speed
end

function ExpertSailor:GetLowerSailStrength()
    return self.lower_sail_strength
end

function ExpertSailor:SetLowerSailStrength(strength)
    self.lower_sail_strength = strength
end



return ExpertSailor