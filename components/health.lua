local SourceModifierList = require("util/sourcemodifierlist")

local function onpercent(self)
    if self.inst.components.combat ~= nil then
        self.inst.components.combat.panic_thresh = self.inst.components.combat.panic_thresh
    end
end

local function onmaxhealth(self, maxhealth)
    self.inst.replica.health:SetMax(maxhealth)
    local repairable = self.inst.components.repairable
    if repairable then
        repairable:SetHealthRepairable((self.currenthealth or maxhealth) < maxhealth)
    end
    onpercent(self)
end

local function oncurrenthealth(self, currenthealth)
    self.inst.replica.health:SetCurrent(currenthealth)
    self.inst.replica.health:SetIsDead(currenthealth <= 0)
    local repairable = self.inst.components.repairable
    if repairable then
        repairable:SetHealthRepairable(currenthealth < self.maxhealth)
    end
    onpercent(self)
end

local function ontakingfiredamage(self, takingfiredamage)
    self.inst.replica.health:SetIsTakingFireDamage(takingfiredamage)
end

local function ontakingfiredamagelow(self, takingfiredamagelow)
    self.inst.replica.health:SetIsTakingFireDamageLow(takingfiredamagelow == true)
end

local function onpenalty(self, penalty)
    self.inst.replica.health:SetPenalty(penalty)
end

local function oncanmurder(self, canmurder)
    self.inst.replica.health:SetCanMurder(canmurder)
end

local function oncanheal(self, canheal)
    self.inst.replica.health:SetCanHeal(canheal)
end

local function oninvincible(self, invincible)
    if CHEATS_ENABLED then --use this to visualize godmode on the client
        if invincible then
            self.inst:AddTag("invincible")
        else
            self.inst:RemoveTag("invincible")
        end
    end
end

local Health = Class(function(self, inst)
    self.inst = inst
    self.maxhealth = 100
    self.minhealth = 0
    self.currenthealth = self.maxhealth
    self.invincible = false

    --V2C: Not used at all, but who knows about MODs?
    --     Save memory instead by making nil default to true
    --self.vulnerabletoheatdamage = true
    -----

    self.takingfiredamage = false
    self.takingfiredamagetime = 0
    --self.takingfiredamagelow = nil
    self.fire_damage_scale = 1
    self.externalfiredamagemultipliers = SourceModifierList(inst)
    self.fire_timestart = 1
    self.firedamageinlastsecond = 0
    self.firedamagecaptimer = 0
    self.nofadeout = false
    self.penalty = 0

    self.absorb = 0 -- DEPRECATED, please use externalabsorbmodifiers instead
    self.playerabsorb = 0 -- DEPRECATED, please use externalabsorbmodifiers instead

    self.externalabsorbmodifiers = SourceModifierList(inst, 0, SourceModifierList.additive)

    self.destroytime = nil
    self.canmurder = true
    self.canheal = true
end,
nil,
{
    maxhealth = onmaxhealth,
    currenthealth = oncurrenthealth,
    takingfiredamage = ontakingfiredamage,
    takingfiredamagelow = ontakingfiredamagelow,
    penalty = onpenalty,
    canmurder = oncanmurder,
    canheal = oncanheal,
    invincible = oninvincible,
})

function Health:OnRemoveFromEntity()
    self:StopRegen()
    onpercent(self)
end

function Health:RecalculatePenalty()
    --deprecated, keeping the function around so mods don't crash
end

function Health:SetInvincible(val)
    self.invincible = val
    self.inst:PushEvent("invincibletoggle", { invincible = val })
end

function Health:ForceUpdateHUD(overtime)
    self:DoDelta(0, overtime, nil, true, nil, true)
end

function Health:OnSave()
    return
    {
        health = self.currenthealth,
        penalty = self.penalty > 0 and self.penalty or nil,
		maxhealth = self.save_maxhealth and self.maxhealth or nil
    }
end

function Health:OnLoad(data)
	if data.maxhealth ~= nil then
		self.maxhealth = data.maxhealth
	end

    local haspenalty = data.penalty ~= nil and data.penalty > 0 and data.penalty < 1
    if haspenalty then
        self:SetPenalty(data.penalty)
    end

    if data.invincible ~= nil then
        self.invincible = data.invincible
    end
    if data.health ~= nil then
        self:SetVal(data.health, "file_load")
        self:ForceUpdateHUD(true)
    elseif data.percent ~= nil then
        -- used for setpieces!
        -- SetPercent already calls ForceUpdateHUD
        self:SetPercent(data.percent, true, "file_load")
    elseif haspenalty then
        self:ForceUpdateHUD(true)
    end
end

local FIRE_TIMEOUT = .5

function Health:GetFireDamageScale()
    return self.fire_damage_scale * self.externalfiredamagemultipliers:Get()
end

function Health:DoFireDamage(amount, doer, instant)
    --V2C: "not instant" generally means that we are burning or being set on fire at the same time
    local mult = self:GetFireDamageScale()
    if not self:IsInvincible() and (not instant or mult > 0) then
        local time = GetTime()
        if not self.takingfiredamage then
            self.takingfiredamage = true
            self.takingfiredamagestarttime = time
            if (self.fire_timestart > 1 and not instant) or mult <= 0 then
                self.takingfiredamagelow = true
            end
            self.inst:StartUpdatingComponent(self)
            self.inst:PushEvent("startfiredamage", { low = self.takingfiredamagelow })
            ProfileStatsAdd("onfire")
        end

        self.lastfiredamagetime = time

        if (instant or time - self.takingfiredamagestarttime > self.fire_timestart) and amount > 0 then
            if mult > 0 then
                if self.takingfiredamagelow then
                    self.takingfiredamagelow = nil
                    self.inst:PushEvent("changefiredamage", { low = false })
                end

                --We're going to take damage at this point, so make sure it's not over the cap/second
                if self.firedamagecaptimer <= time then
                    self.firedamageinlastsecond = 0
                    self.firedamagecaptimer = time + 1
                end

                if self.firedamageinlastsecond + amount > TUNING.MAX_FIRE_DAMAGE_PER_SECOND then
                    amount = TUNING.MAX_FIRE_DAMAGE_PER_SECOND - self.firedamageinlastsecond
                end

                self:DoDelta(-amount * mult, false, doer ~= nil and (doer.nameoverride or doer.prefab) or "fire", nil, doer)
                self.inst:PushEvent("firedamage")

                self.firedamageinlastsecond = self.firedamageinlastsecond + amount
            elseif not self.takingfiredamagelow then
                self.takingfiredamagelow = true
                self.inst:PushEvent("changefiredamage", { low = true })
            end
        end
    end
end

function Health:OnUpdate(dt)
    local time = GetTime()

    if time - self.lastfiredamagetime > FIRE_TIMEOUT then
        self.takingfiredamage = false
        if self.takingfiredamagelow then
            self.takingfiredamagelow = nil
        end
        self.inst:StopUpdatingComponent(self)
        self.inst:PushEvent("stopfiredamage")
        ProfileStatsAdd("fireout")
    end
end

local function DoRegen(inst, self)
    --print(string.format("Health:DoRegen ^%.2g/%.2fs", self.regen.amount, self.regen.period))
    if not self:IsDead() then
        self:DoDelta(self.regen.amount, true, "regen")
    --else
        --print("    can't regen from dead!")
    end
end

function Health:StartRegen(amount, period, interruptcurrentregen)
    -- We don't always do this just for backwards compatibility sake. While unlikely, it's possible some modder was previously relying on
    -- the fact that StartRegen didn't stop the existing task. If they want to continue using that behavior, they now just need to add
    -- a "false" flag as the last parameter of their StartRegen call. Generally, we want to restart the task, though.
    if interruptcurrentregen ~= false then
        self:StopRegen()
    end

    if self.regen == nil then
        self.regen = {}
    end
    self.regen.amount = amount
    self.regen.period = period

    if self.regen.task == nil then
        self.regen.task = self.inst:DoPeriodicTask(self.regen.period, DoRegen, nil, self)
    end
end

function Health:SetAbsorptionAmount(amount)
    self.absorb = amount
end

function Health:SetAbsorptionAmountFromPlayer(amount)
    self.playerabsorb = amount
end

function Health:StopRegen()
    --print("Health:StopRegen")
    if self.regen ~= nil then
        if self.regen.task ~= nil then
            --print("   stopping task")
            self.regen.task:Cancel()
            self.regen.task = nil
        end
        self.regen = nil
    end
end

function Health:SetPenalty(penalty)
	if not self.disable_penalty then
		--Penalty should never be less than 0% or ever above 75%.
		self.penalty = math.clamp(penalty, 0, TUNING.MAXIMUM_HEALTH_PENALTY)
	end
end

function Health:DeltaPenalty(delta)
    self:SetPenalty(self.penalty + delta)
    self:ForceUpdateHUD(false) --handles capping health at max with penalty
end

function Health:GetPenaltyPercent()
    return self.penalty
end

function Health:GetPercent()
    return self.currenthealth / self.maxhealth
end

function Health:GetPercentWithPenalty()
    return self.currenthealth / self:GetMaxWithPenalty()
end

function Health:IsInvincible()
    return self.invincible or (self.inst.sg and self.inst.sg:HasStateTag("temp_invincible"))
end

function Health:GetDebugString()
    local s = string.format("%2.2f / %2.2f", self.currenthealth, self:GetMaxWithPenalty())
    if self.regen ~= nil then
        s = s..string.format(", regen %.2f every %.2fs", self.regen.amount, self.regen.period)
    end
    return s
end

function Health:SetCurrentHealth(amount)
    self.currenthealth = amount
end

function Health:SetMaxHealth(amount)
    self.maxhealth = amount
    self.currenthealth = amount
    self:ForceUpdateHUD(true) --handles capping health at max with penalty
end

function Health:SetMinHealth(amount)
    self.minhealth = amount
end

function Health:IsHurt()
    return self.currenthealth < self:GetMaxWithPenalty()
end

function Health:GetMaxWithPenalty()
    return self.maxhealth - self.maxhealth * self.penalty
end

function Health:Kill()
    if self.currenthealth > 0 then
        self:DoDelta(-self.currenthealth, nil, nil, nil, nil, true)
    end
end

function Health:IsDead()
    return self.currenthealth <= 0
end

function Health:SetPercent(percent, overtime, cause)
    self:SetVal(self.maxhealth * percent, cause)
    self:DoDelta(0, overtime, cause, true, nil, true)
end

function Health:SetVal(val, cause, afflicter)
    local old_health = self.currenthealth
    local max_health = self:GetMaxWithPenalty()
    local min_health = math.min(self.minhealth or 0, max_health)

    if val > max_health then
        val = max_health
    end

    if val <= min_health then
        self.currenthealth = min_health
        self.inst:PushEvent("minhealth", { cause = cause, afflicter = afflicter })
    else
        self.currenthealth = val
    end

    if old_health > 0 and self.currenthealth <= 0 then
        --Push world event first, because the entity event may invalidate itself
        --i.e. items that use .nofadeout and manually :Remove() on "death" event
        TheWorld:PushEvent("entity_death", { inst = self.inst, cause = cause, afflicter = afflicter })
        self.inst:PushEvent("death", { cause = cause, afflicter = afflicter })

		--Here, check if killing player or monster
		if(self.inst:HasTag("player")) then
			NotifyPlayerProgress("TotalPlayersKilled", 1, afflicter);
		else
			NotifyPlayerProgress("TotalEnemiesKilled", 1, afflicter);
		end

        --V2C: If "death" handler removes ourself, then the prefab should explicitly set nofadeout = true.
        --     Intentionally NOT using IsValid() here to hide those bugs.
        if not self.nofadeout then
            self.inst:AddTag("NOCLICK")
            self.inst.persists = false
            self.inst:DoTaskInTime(self.destroytime or 2, ErodeAway)
        end
    end
end

function Health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if self.redirect ~= nil and self.redirect(self.inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb) then
        return 0
    elseif not ignore_invincible and (self:IsInvincible() or self.inst.is_teleporting) then
        return 0
    elseif amount < 0 and not ignore_absorb then
        amount = amount * math.clamp(1 - (self.playerabsorb ~= 0 and afflicter ~= nil and afflicter:HasTag("player") and self.playerabsorb + self.absorb or self.absorb), 0, 1) * math.clamp(1 - self.externalabsorbmodifiers:Get(), 0, 1)
    end

    local old_percent = self:GetPercent()
    self:SetVal(self.currenthealth + amount, cause, afflicter)

    self.inst:PushEvent("healthdelta", { oldpercent = old_percent, newpercent = self:GetPercent(), overtime = overtime, cause = cause, afflicter = afflicter, amount = amount })

    if self.ondelta ~= nil then
        -- Re-call GetPercent on the slight chance that "healthdelta" changed it.
        self.ondelta(self.inst, old_percent, self:GetPercent(), overtime, cause, afflicter, amount)
    end
    return amount
end

return Health
