local easing = require("easing")
local SourceModifierList = require("util/sourcemodifierlist")

local function onmax(self, max)
    self.inst.replica.sanity:SetMax(max)
end

local function oncurrent(self, current)
    self.inst.replica.sanity:SetCurrent(self.inducedinsanity and 0 or current)
end

local function onratescale(self, ratescale)
    self.inst.replica.sanity:SetRateScale(ratescale)
end

local function onsane(self, sane)
    self.inst.replica.sanity:SetIsSane(not self.inducedinsanity and sane)
end

local function oninducedinsanity(self, inducedinsanity)
    self.inst.replica.sanity:SetIsSane(not inducedinsanity and self.sane)
    self.inst.replica.sanity:SetCurrent(inducedinsanity and 0 or self.current)
end

local function onpenalty(self, penalty)
    self.inst.replica.sanity:SetPenalty(penalty)
end

local function onghostdrainmult(self, ghostdrainmult)
    self.inst.replica.sanity:SetGhostDrainMult(ghostdrainmult)
end

local Sanity = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = self.max
    
    self.rate = 0
    self.ratescale = RATE_SCALE.NEUTRAL
    self.rate_modifier = 1
    self.sane = true
    self.fxtime = 0
    self.dapperness = 0
	self.externalmodifiers = SourceModifierList(self.inst, 0, SourceModifierList.additive)
    self.inducedinsanity = nil
    self.inducedinsanity_sources = nil
    self.night_drain_mult = 1
    self.neg_aura_mult = 1
    self.neg_aura_absorb = 0
    self.dapperness_mult = 1

    self.penalty = 0

    self.sanity_penalties = {}

    self.ghost_drain_mult = 0

    self.custom_rate_fn = nil

    self._oldissane = self:IsSane()
    self._oldpercent = self:GetPercent()

    self.inst:StartUpdatingComponent(self)
    self:RecalcGhostDrain()
end,
nil,
{
    max = onmax,
    current = oncurrent,
    ratescale = onratescale,
    sane = onsane,
    inducedinsanity = oninducedinsanity,
    penalty = onpenalty,
    ghost_drain_mult = onghostdrainmult,
})

function Sanity:IsSane()
    return not self.inducedinsanity and self.sane
end

function Sanity:IsCrazy()
    return self.inducedinsanity or not self.sane
end

function Sanity:AddSanityPenalty(key, mod)
    self.sanity_penalties[key] = mod
    self:RecalculatePenalty()
end

function Sanity:RemoveSanityPenalty(key)
    self.sanity_penalties[key] = nil
    self:RecalculatePenalty()
end

function Sanity:RecalculatePenalty()
    local penalty = 0
    
    for k,v in pairs(self.sanity_penalties) do
        penalty = penalty + v
    end

    penalty = math.max(penalty, -self.max)

    self.penalty = penalty

    self:DoDelta(0)
end

function Sanity:OnSave()
    return
    {
        current = self.current,
        sane = self.sane,
    }
end

function Sanity:OnLoad(data)
    if data.sane ~= nil then
        self.sane = data.sane
    end

    if data.current ~= nil then
        self.current = data.current
        self:DoDelta(0)
    end
end

function Sanity:GetPenaltyPercent()
    return self.penalty
end

function Sanity:GetPercent()
    return self.inducedinsanity and 0 or self.current / self.max
end

function Sanity:GetPercentWithPenalty()
    return self.inducedinsanity and 0 or self.current / (self.max - (self.max * self.penalty))
end

function Sanity:SetPercent(per, overtime)
    local target = per * self.max
    local delta = target - self.current
    self:DoDelta(delta, overtime)
end

function Sanity:GetDebugString()
    return string.format("%2.2f / %2.2f at %2.4f. Penalty of %2.2f", self.current, self.max, self.rate, self.penalty)
end

function Sanity:SetMax(amount)
    self.max = amount
    self.current = amount
    self:DoDelta(0)
end

function Sanity:GetMaxWithPenalty()
    return self.max - (self.max * self.penalty)
end

function Sanity:GetRateScale()
    return self.ratescale
end

function Sanity:SetInducedInsanity(src, val)
    if val then
        if self.inducedinsanity_sources == nil then
            self.inducedinsanity_sources = { [src] = true }
        else
            self.inducedinsanity_sources[src] = true
        end
    elseif self.inducedinsanity_sources ~= nil then
        self.inducedinsanity_sources[src] = nil
        if next(self.inducedinsanity_sources) == nil then
            self.inducedinsanity_sources = nil
            val = nil
        else
            val = true
        end
    end
    if self.inducedinsanity ~= val then
        self.inducedinsanity = val
        self:DoDelta(0)
        self.inst:PushEvent("inducedinsanity", val)
    end
end

function Sanity:DoDelta(delta, overtime)
    if self.redirect ~= nil then
        self.redirect(self.inst, delta, overtime)
        return
    end

    if self.ignore then
        return
    end

    local oldpct_ignoresinduced = self.current / self.max
    self.current = math.min(math.max(self.current + delta, 0), self.max - (self.max * self.penalty))
    local newpct_ignoresinduced = self.current / self.max

    --due to inducedinsanity hack...
    if self.sane and oldpct_ignoresinduced > TUNING.SANITY_BECOME_INSANE_THRESH and newpct_ignoresinduced <= TUNING.SANITY_BECOME_INSANE_THRESH then
        self.sane = false
    elseif not self.sane and oldpct_ignoresinduced < TUNING.SANITY_BECOME_SANE_THRESH and newpct_ignoresinduced >= TUNING.SANITY_BECOME_SANE_THRESH then
        self.sane = true
    end

    self.inst:PushEvent("sanitydelta", { oldpercent = self._oldpercent, newpercent = self:GetPercent(), overtime = overtime })
    self._oldpercent = self:GetPercent()

--KAJ: TODO: taken out for now, stats
--    if delta > 0 and self.inst == ThePlayer then
--        ProfileStatsAdd("sane+", math.floor(delta))
--    end

    if self:IsSane() ~= self._oldissane then
        self._oldissane = self:IsSane()
        if self._oldissane then
            if self.onSane ~= nil then
                self.onSane(self.inst)
            end
            self.inst:PushEvent("gosane")
            ProfileStatsSet("went_sane", true)
        else
            if self.onInsane ~= nil then
                self.onInsane(self.inst)
            end
            self.inst:PushEvent("goinsane")
            ProfileStatsSet("went_insane", true)
        end
    end
end

function Sanity:OnUpdate(dt)
    if not (self.inst.components.health.invincible or
            self.inst.sg:HasStateTag("sleeping") or --need this now because you are no longer invincible during sleep
            self.inst.is_teleporting or
            (self.ignore and self.redirect == nil)) then
        self:Recalc(dt)
    else
        --Always want to update badge
        self:RecalcGhostDrain()

        --Disable arrows
        self.rate = 0
        self.ratescale = RATE_SCALE.NEUTRAL
    end
end

function Sanity:RecalcGhostDrain()
    if GetGhostSanityDrain(TheNet:GetServerGameMode()) then
        local num_ghosts = TheWorld.shard.components.shard_players:GetNumGhosts()
        local num_alive = TheWorld.shard.components.shard_players:GetNumAlive()
        local group_resist = num_alive > num_ghosts and 1 - num_ghosts / num_alive or 0

        self.ghost_drain_mult = math.min(num_ghosts, TUNING.MAX_SANITY_GHOST_PLAYER_DRAIN_MULT) * (1 - group_resist * group_resist)
    else
        self.ghost_drain_mult = 0
    end
end

function Sanity:Recalc(dt)
    local total_dapperness = self.dapperness
    for k, v in pairs(self.inst.components.inventory.equipslots) do
        if v.components.equippable ~= nil then
            total_dapperness = total_dapperness + v.components.equippable:GetDapperness(self.inst)
        end
    end

    total_dapperness = total_dapperness * self.dapperness_mult

    local dapper_delta = total_dapperness * TUNING.SANITY_DAPPERNESS

    local moisture_delta = easing.inSine(self.inst.components.moisture:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, self.inst.components.moisture:GetMaxMoisture())

    local light_delta
    if TheWorld.state.isday and not TheWorld:HasTag("cave") then
        light_delta = TUNING.SANITY_DAY_GAIN
    else
        local lightval = CanEntitySeeInDark(self.inst) and .9 or self.inst.LightWatcher:GetLightValue()
        light_delta =
            (   (lightval > TUNING.SANITY_HIGH_LIGHT and TUNING.SANITY_NIGHT_LIGHT) or
                (lightval < TUNING.SANITY_LOW_LIGHT and TUNING.SANITY_NIGHT_DARK) or
                TUNING.SANITY_NIGHT_MID
            ) * self.night_drain_mult
    end

    local aura_delta = 0
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SANITY_EFFECT_RANGE, nil, { "FX", "NOCLICK", "DECOR","INLIMBO" })
    for i, v in ipairs(ents) do 
        if v.components.sanityaura ~= nil and v ~= self.inst then
            local aura_val = v.components.sanityaura:GetAura(self.inst) / math.max(1, self.inst:GetDistanceSqToInst(v))
            aura_delta = aura_delta + (aura_val < 0 and (self.neg_aura_absorb > 0 and self.neg_aura_absorb * -aura_val or aura_val) * self.neg_aura_mult or aura_val)
        end
    end

    local mount = self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
    if mount ~= nil and mount.components.sanityaura ~= nil then
        local aura_val = mount.components.sanityaura:GetAura(self.inst)
        aura_delta = aura_delta + (aura_val < 0 and (self.neg_aura_absorb > 0 and self.neg_aura_absorb * -aura_val or aura_val) * self.neg_aura_mult or aura_val)
    end

    self:RecalcGhostDrain()
    local ghost_delta = TUNING.SANITY_GHOST_PLAYER_DRAIN * self.ghost_drain_mult

    self.rate = dapper_delta + moisture_delta + light_delta + aura_delta + ghost_delta + self.externalmodifiers:Get()

    if self.custom_rate_fn ~= nil then
        --NOTE: dt param was added for wormwood's custom rate function
        --      dt shouldn't have been applied to the return value yet
        self.rate = self.rate + self.custom_rate_fn(self.inst, dt)
    end

    self.rate = self.rate * self.rate_modifier
    self.ratescale =
        (self.rate > .2 and RATE_SCALE.INCREASE_HIGH) or
        (self.rate > .1 and RATE_SCALE.INCREASE_MED) or
        (self.rate > .01 and RATE_SCALE.INCREASE_LOW) or
        (self.rate < -.3 and RATE_SCALE.DECREASE_HIGH) or
        (self.rate < -.1 and RATE_SCALE.DECREASE_MED) or
        (self.rate < -.02 and RATE_SCALE.DECREASE_LOW) or
        RATE_SCALE.NEUTRAL

    --print (string.format("dapper: %2.2f light: %2.2f TOTAL: %2.2f", dapper_delta, light_delta, self.rate*dt))
    self:DoDelta(self.rate * dt, true)
end

Sanity.LongUpdate = Sanity.OnUpdate

return Sanity
