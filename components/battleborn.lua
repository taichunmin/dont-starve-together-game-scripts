local Battleborn = Class(function(self, inst)
    self.inst = inst

    self.battleborn = 0
    self.battleborn_time = 0

    self.battleborn_trigger_threshold = TUNING.BATTLEBORN_TRIGGER_THRESHOLD
    self.battleborn_decay_time = TUNING.BATTLEBORN_DECAY_TIME
    self.battleborn_store_time = TUNING.BATTLEBORN_STORE_TIME

    self.battleborn_bonus = 0

    self.clamp_min = 0.33
    self.clamp_max = 2.0

    self.inst:ListenForEvent("onattackother", function(inst, data) self:OnAttack(data) end)
    self.inst:ListenForEvent("death", function(inst) self:OnDeath() end)
end)


function Battleborn:SetTriggerThreshold(threshold)
    self.battleborn_trigger_threshold = threshold
end

function Battleborn:SetDecayTime(time)
    self.battleborn_decay_time = time
end

function Battleborn:SetStoreTime(time)
    self.battleborn_store_time = time
end

function Battleborn:SetOnTriggerFn(ontriggerfn)
    self.ontriggerfn = ontriggerfn
end

function Battleborn:SetBattlebornBonus(bonus)
    self.battleborn_bonus = bonus
end

function Battleborn:SetSanityEnabled(enabled)
    self.sanity_enabled = enabled
end

function Battleborn:SetHealthEnabled(enabled)
    self.health_enabled = enabled
end

function Battleborn:SetClampMin(min)
    self.clamp_min = min
end

function Battleborn:SetClampMax(max)
    self.clamp_max = max
end

function Battleborn:SetValidVictimFn(fn)
    self.validvictimfn = fn
end

function Battleborn:OnAttack(data)

    local victim = data.target

    if not self.inst.components.health:IsDead() and (self.validvictimfn == nil or self.validvictimfn(victim)) then
        local total_health = victim.components.health:GetMaxWithPenalty()
        local damage = (data.weapon ~= nil and data.weapon.components.weapon:GetDamage(self.inst, victim))
                    or self.inst.components.combat.defaultdamage
        local percent = (damage <= 0 and 0)
                    or (total_health <= 0 and math.huge)
                    or damage / total_health

        --math and clamp does account for 0 and infinite cases
        local delta = math.clamp(victim.components.combat.defaultdamage * self.battleborn_bonus * percent, self.clamp_min, self.clamp_max)

        --decay stored battleborn
        if self.battleborn > 0 then
            local dt = GetTime() - self.battleborn_time - self.battleborn_store_time
            if dt >= self.battleborn_decay_time then
                self.battleborn = 0
            elseif dt > 0 then
                local k = dt / self.battleborn_decay_time
                self.battleborn = Lerp(self.battleborn, 0, k * k)
            end
        end

        --store new battleborn
        self.battleborn = self.battleborn + delta
        self.battleborn_time = GetTime()

        --consume battleborn if enough has been stored
        if self.battleborn > self.battleborn_trigger_threshold then
            if self.health_enabled then
                self.inst.components.health:DoDelta(self.battleborn, false, "battleborn")
            end

            if self.sanity_enabled then
                self.inst.components.sanity:DoDelta(self.battleborn)
            end

            if self.ontriggerfn ~= nil then
                self.ontriggerfn(self.inst, self.battleborn)
            end

            self.battleborn = 0
        end
    end
end

function Battleborn:OnDeath()
    self.battleborn = 0
end

return Battleborn