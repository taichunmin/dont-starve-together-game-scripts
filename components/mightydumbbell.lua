local MightyDumbbell = Class(function(self, inst)
    self.inst = inst
    self.efficiency_wimpy =  TUNING.DUMBBELL_EFFICIENCY_LOW
    self.efficiency_normal = TUNING.DUMBBELL_EFFICIENCY_LOW
    self.efficiency_mighty = TUNING.DUMBBELL_EFFICIENCY_LOW
end)

function MightyDumbbell:CanWorkout(doer)
    return doer:HasTag("strongman") and doer.components.mightiness ~= nil
end

function MightyDumbbell:IsWorkingOut(doer)
    print ("strongman", self.strongman, doer)
    return self.strongman == doer
end

local efficiency_rate_scale = 
{
    [TUNING.DUMBBELL_EFFICIENCY_LOW] =  RATE_SCALE.INCREASE_LOW,
    [TUNING.DUMBBELL_EFFICIENCY_MED] =  RATE_SCALE.INCREASE_MED,
    [TUNING.DUMBBELL_EFFICIENCY_HIGH] = RATE_SCALE.INCREASE_HIGH,
}

function MightyDumbbell:CheckEfficiency(doer)
    if self.strongman ~= nil then
        local mightiness = self.strongman.components.mightiness
        if mightiness ~= nil then
            local efficiency = self.efficiency_mighty
            
            if mightiness.current < TUNING.WIMPY_THRESHOLD then
                efficiency = self.efficiency_wimpy
            elseif mightiness.current < TUNING.MIGHTY_THRESHOLD then
                efficiency = self.efficiency_normal
            end
            
            mightiness:SetRateScale(efficiency_rate_scale[efficiency])
            return efficiency
        end
    end

    return 0
end

function MightyDumbbell:CheckAttackEfficiency(doer)
    if doer ~= nil then
        local mightiness = doer.components.mightiness
        if mightiness ~= nil then
            local efficiency = self.efficiency_mighty
            
            if mightiness.current < TUNING.WIMPY_THRESHOLD then
                efficiency = self.efficiency_wimpy
            elseif mightiness.current < TUNING.MIGHTY_THRESHOLD then
                efficiency = self.efficiency_normal
            end

            return efficiency
        end
    end
    return 0
end

function MightyDumbbell:StartWorkout(doer)
    self.inst:AddTag("lifting")
    self.strongman = doer
    self:CheckEfficiency()
end

function MightyDumbbell:StopWorkout(doer)
    self.inst:RemoveTag("lifting")
    self.strongman.components.mightiness:SetRateScale(RATE_SCALE.NEUTRAL)
    self.strongman = nil
end

function MightyDumbbell:SetConsumption(consumption)
    self.consumption = consumption
end

function MightyDumbbell:SetEfficiency(wimpy, normal, mighty)
    self.efficiency_wimpy =  wimpy
    self.efficiency_normal = normal
    self.efficiency_mighty = mighty
end

function MightyDumbbell:DoAttackWorkout(doer)

    if doer.components.mightiness then
        local mightiness = self:CheckAttackEfficiency(doer) * TUNING.DUMBBELL_EFFICIENCY_ATTCK_SCALE
        doer.components.mightiness:DoDelta(mightiness)
    end
end

function MightyDumbbell:DoWorkout(doer)
    if doer.components.mightiness then
        local mightiness = self:CheckEfficiency()
        doer.components.mightiness:DoDelta(mightiness)

        if self.inst.components.finiteuses then
            self.inst.components.finiteuses:Use(self.consumption)

            if self.inst.components.finiteuses:GetUses() == 0 then
                self:StopWorkout()
                return false
            end
        end

        return true
    end
end

return MightyDumbbell