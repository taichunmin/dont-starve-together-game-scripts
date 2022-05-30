local easing = require("easing")

local SOURCE_MODIFIER_LIST_KEY = "groggyresistance"

local Grogginess = Class(function(self, inst)
    self.inst = inst

    self.resistance = 1
    self.grog_amount = 0
    self.knockouttime = 0
    self.knockoutduration = 0
    self.wearofftime = 0
    self.wearoffduration = TUNING.GROGGINESS_WEAR_OFF_DURATION
    self.decayrate = TUNING.GROGGINESS_DECAY_RATE
    self.speedmod = nil
    self.enablespeedmod = true
    self.isgroggy = false
    self.knockedout = false

    self._resistance_sources = SourceModifierList(inst, 0, SourceModifierList.additive)

    --self._disable_task = nil
    --self._disable_finish = nil

    self:SetDefaultTests()
end)

function Grogginess:OnRemoveFromEntity()
    if self.isgroggy then
        self.isgroggy = false
        self.inst:RemoveTag("groggy")
        if self.onwearofffn ~= nil then
            self.onwearofffn(self.inst)
        end
    end
end

function DefaultKnockoutTest(inst)
    local self = inst.components.grogginess
    return self.grog_amount >= self:GetResistance()
        and not (inst.components.health ~= nil and inst.components.health.takingfiredamage)
        and not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
end

function DefaultComeToTest(inst)
    local self = inst.components.grogginess
    return self.knockouttime > self.knockoutduration and self.grog_amount < self:GetResistance()
end

function DefaultWhileGroggy(inst)
    --assume grog_amount > 0
    local self = inst.components.grogginess
    local pct = self.grog_amount < self:GetResistance() and self.grog_amount / self:GetResistance() or 1
    self.speedmod = Remap(pct, 1, 0, TUNING.MIN_GROGGY_SPEED_MOD, TUNING.MAX_GROGGY_SPEED_MOD)
    if self.enablespeedmod then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "grogginess", self.speedmod)
    end
end

function DefaultWhileWearingOff(inst)
    --assume wearofftime > 0
    local self = inst.components.grogginess
    local pct = self.wearofftime < self.wearoffduration and easing.inQuad(self.wearofftime / self.wearoffduration, 0, 1, 1) or 1
    self.speedmod = Remap(pct, 0, 1, TUNING.MAX_GROGGY_SPEED_MOD, 1)
    if self.enablespeedmod then
        inst.components.locomotor:SetExternalSpeedMultiplier(inst, "grogginess", self.speedmod)
    end
end

function DefaultOnWearOff(inst)
    --check required in case we're coming from OnRemoveFromEntity
    if inst.components.grogginess ~= nil then
        inst.components.grogginess.speedmod = nil
    end
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "grogginess")
end

function Grogginess:SetDefaultTests()
    self.knockouttestfn = DefaultKnockoutTest
    self.cometotestfn = DefaultComeToTest
    self.whilegroggyfn = DefaultWhileGroggy
    self.whilewearingofffn = DefaultWhileWearingOff
    self.onwearofffn = DefaultOnWearOff
end

-----------------------------------------------------------------------------------------------------

function Grogginess:SetComeToTest(fn)
    self.cometotestfn = fn
end

function Grogginess:SetKnockOutTest(fn)
    self.knockouttestfn = fn
end

function Grogginess:SetResistance(resist)
    self.resistance = resist
end

function Grogginess:GetResistance()
    return self.resistance + self._resistance_sources:CalculateModifierFromKey(SOURCE_MODIFIER_LIST_KEY)
end

function Grogginess:SetDecayRate(rate)
    self.decayrate = rate
end

function Grogginess:SetWearOffDuration(duration)
    self.wearoffduration = duration
end

function Grogginess:SetEnableSpeedMod(enable)
    if enable then
        if not self.enablespeedmod then
            self.enablespeedmod = true
            if self.speedmod ~= nil then
                self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "grogginess", self.speedmod)
            end
            if self.isgroggy then
                self.inst:AddTag("groggy")
            end
        end
    elseif self.enablespeedmod then
        self.enablespeedmod = false
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "grogginess")
        self.inst:RemoveTag("groggy")
    end
end

function Grogginess:IsKnockedOut()
    return self.inst.sg ~= nil and self.inst.sg:HasStateTag("knockout")
end

function Grogginess:IsGroggy()
    return self.grog_amount > 0 and self.enablespeedmod and not self:IsKnockedOut()
end

function Grogginess:HasGrogginess()
    return self.grog_amount > 0 and self.enablespeedmod
end

function Grogginess:GetDebugString()
    return string.format("%s, KO time=%2.2f Groggy: %d/%d%s (%.2f)",
            self:IsKnockedOut() and "KNOCKED OUT" or "AWAKE",
            self.knockouttime,
            self.grog_amount,
            self:GetResistance(),
            self.enablespeedmod and "" or " (disable speed mod)",
			self.grog_amount)
end

function Grogginess:AddGrogginess(grogginess, knockoutduration)
    if grogginess <= 0 then
        return
    end

    self.grog_amount = self.grog_amount + grogginess
    self.wearofftime = 0

    if not self.isgroggy then
        self.isgroggy = true
        if self.enablespeedmod then
            self.inst:AddTag("groggy")
        end
        self.inst:StartUpdatingComponent(self)
        self.knockouttime = 0
    end

    if self.knockouttestfn ~= nil and self.knockouttestfn(self.inst) then
        if not self:IsKnockedOut() then
            self.knockouttime = 0
        end
        self.knockoutduration = math.max(self.knockoutduration, knockoutduration or TUNING.MIN_KNOCKOUT_TIME)
        self:KnockOut()
    end
end

function Grogginess:MaximizeGrogginess()
    local delta = self:GetResistance() - self.grog_amount
    if delta > .1 then
        self:AddGrogginess(delta - .1)
    end
end

function Grogginess:SubtractGrogginess(grogginess)
    if grogginess <= 0 then
        return
    end

    self.grog_amount = math.max(0, self.grog_amount - grogginess)

    if self.isgroggy then
        -- Make sure we're updating so we hit the end-of-grogginess behaviour.
        self.inst:StartUpdatingComponent(self)
    end
end

function Grogginess:ResetGrogginess()
    if self.grog_amount > 0 then
        self:SubtractGrogginess(self.grog_amount)
    end
end

function Grogginess:ExtendKnockout(knockoutduration)
    if self:IsKnockedOut() then
        self.knockoutduration = knockoutduration
        self.knockouttime = 0
        self.grog_amount = math.max(self.grog_amount, self:GetResistance())
    end
end

function Grogginess:KnockOut()
    if self.inst.entity:IsVisible() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self.inst:PushEvent("knockedout")
        self.knockedout = true
    end
end

function Grogginess:ComeTo()
    self.knockedout = false
    if self:IsKnockedOut() and not (self.inst.components.health ~= nil and self.inst.components.health:IsDead()) then
        self.grog_amount = self.resistance
        self.inst:PushEvent("cometo")
    end
end

function Grogginess:AddResistanceSource(source, resistance)
    self._resistance_sources:SetModifier(source, resistance, SOURCE_MODIFIER_LIST_KEY)
end

function Grogginess:RemoveResistanceSource(source)
    self._resistance_sources:RemoveModifier(source, SOURCE_MODIFIER_LIST_KEY)
end

function Grogginess:OnUpdate(dt)
    self.grog_amount = math.max(0, self.grog_amount - self.decayrate)

    if self:IsKnockedOut() then
        self.knockouttime = self.knockouttime + dt
        if self.cometotestfn ~= nil and self.cometotestfn(self.inst) then
            self:ComeTo()
        end
    elseif self.grog_amount <= 0 then
        self.isgroggy = false
        self.inst:RemoveTag("groggy")
        self.wearofftime = math.min(self.wearoffduration, self.wearofftime + dt)
        if self.wearofftime >= self.wearoffduration then
            self.inst:StopUpdatingComponent(self)
            self.knockouttime = 0
            self.knockoutduration = 0
            self.wearofftime = 0
            if self.onwearofffn ~= nil then
                self.onwearofffn(self.inst)
            end
        elseif self.whilewearingofffn ~= nil then
            self.whilewearingofffn(self.inst)
        end
    elseif self.whilegroggyfn ~= nil then
        self.whilegroggyfn(self.inst)
    end
end

return Grogginess
