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


local function onmode(self, mode)
    self.inst.replica.sanity:SetSanityMode(mode)
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

local function OnChangeArea(inst, area)
	local area_sanity_mode = area ~= nil and area.tags and table.contains(area.tags, "lunacyarea") and SANITY_MODE_LUNACY or SANITY_MODE_INSANITY
	inst.components.sanity:SetSanityMode(area_sanity_mode)
end

local Sanity = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = self.max

	self.mode = SANITY_MODE_INSANITY
    
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

	self.inst:ListenForEvent("changearea", OnChangeArea)
end,
nil,
{
    max = onmax,
    current = oncurrent,
    ratescale = onratescale,
	mode = onmode,
    sane = onsane,
    inducedinsanity = oninducedinsanity,
    penalty = onpenalty,
    ghost_drain_mult = onghostdrainmult,
})

function Sanity:IsSane()
    return (self.mode == SANITY_MODE_INSANITY and (not self.inducedinsanity and self.sane))
			or (self.mode == SANITY_MODE_LUNACY and (self.inducedinsanity or self.sane))
end

function Sanity:IsInsane()
    return self.mode == SANITY_MODE_INSANITY and (self.inducedinsanity or not self.sane)
end

function Sanity:IsEnlightened()
	return self.mode == SANITY_MODE_LUNACY and (not self.inducedinsanity and not self.sane)
end

function Sanity:IsCrazy()
	-- deprecated
    return self:IsInsane()
end

function Sanity:SetSanityMode(mode)
	if self.mode ~= mode then
		self.mode = mode
        self.inst:PushEvent("sanitymodechanged", {mode = self.mode})
		self:DoDelta(0)
	end
end

function Sanity:IsInsanityMode()
	return self.mode == SANITY_MODE_INSANITY
end

function Sanity:IsLunacyMode()
	return self.mode == SANITY_MODE_LUNACY
end

function Sanity:GetSanityMode()
	return self.mode
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
        mode = self.mode,
    }
end

function Sanity:OnLoad(data)
    if data.sane ~= nil then
        self.sane = data.sane
    end

    self.mode = data.mode or 0

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
    return string.format("%2.2f / %2.2f at %2.4f. Penalty %2.2f, Mode %s", self.current, self.max, self.rate, self.penalty, self.mode == SANITY_MODE_INSANITY and "INSANITY" or "LUNACY")
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

    self.current = math.min(math.max(self.current + delta, 0), self.max - (self.max * self.penalty))

    -- must calculate it due to inducedinsanity ...
    local percent_ignoresinduced = self.current / self.max
	if self.mode == SANITY_MODE_INSANITY then
		if self.sane and percent_ignoresinduced <= TUNING.SANITY_BECOME_INSANE_THRESH then --30
			self.sane = false
		elseif not self.sane and percent_ignoresinduced >= TUNING.SANITY_BECOME_SANE_THRESH then --35
			self.sane = true
		end
	else
		if self.sane and percent_ignoresinduced >= TUNING.SANITY_BECOME_ENLIGHTENED_THRESH then
			self.sane = false
		elseif not self.sane and percent_ignoresinduced <= TUNING.SANITY_LOSE_ENLIGHTENMENT_THRESH then
			self.sane = true
		end
	end

    self.inst:PushEvent("sanitydelta", { oldpercent = self._oldpercent, newpercent = self:GetPercent(), overtime = overtime, sanitymode = self.mode })
    self._oldpercent = self:GetPercent()

    if self:IsSane() ~= self._oldissane then
        self._oldissane = self:IsSane()
        if self._oldissane then
            if self.onSane ~= nil then
                self.onSane(self.inst)
            end
            self.inst:PushEvent("gosane")
            ProfileStatsSet("went_sane", true)
        else
			if self.mode == SANITY_MODE_INSANITY then
				if self.onInsane ~= nil then
					self.onInsane(self.inst)
				end
				self.inst:PushEvent("goinsane")
				ProfileStatsSet("went_insane", true)
			else --self.mode == SANITY_MODE_LUNACY
				if self.onEnlightened ~= nil then
					self.onEnlightened(self.inst)
				end
				self.inst:PushEvent("goenlightened")
				ProfileStatsSet("went_enlightened", true)
			end
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

local LIGHT_SANITY_DRAINS =
{
	[SANITY_MODE_INSANITY] = {
		DAY = TUNING.SANITY_DAY_GAIN,
		NIGHT_LIGHT = TUNING.SANITY_NIGHT_LIGHT,
		NIGHT_DIM = TUNING.SANITY_NIGHT_MID,
		NIGHT_DARK = TUNING.SANITY_NIGHT_DARK,
	},
	[SANITY_MODE_LUNACY] = {
		DAY = TUNING.SANITY_LUNACY_DAY_GAIN,
		NIGHT_LIGHT = TUNING.SANITY_LUNACY_NIGHT_LIGHT,
		NIGHT_DIM = TUNING.SANITY_LUNACY_NIGHT_MID,
		NIGHT_DARK = TUNING.SANITY_LUNACY_NIGHT_DARK,
	},
}

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

    local light_sanity_drain = LIGHT_SANITY_DRAINS[self.mode]
	local light_delta
    if TheWorld.state.isday and not TheWorld:HasTag("cave") then
        light_delta = light_sanity_drain.DAY
    else
        local lightval = CanEntitySeeInDark(self.inst) and .9 or self.inst.LightWatcher:GetLightValue()
        light_delta =
            (   (lightval > TUNING.SANITY_HIGH_LIGHT and light_sanity_drain.NIGHT_LIGHT) or
                (lightval < TUNING.SANITY_LOW_LIGHT and light_sanity_drain.NIGHT_DARK) or
                light_sanity_drain.NIGHT_DIM
            ) * self.night_drain_mult
    end

    local aura_delta = 0
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SANITY_AURA_SEACH_RANGE, { "sanityaura" }, { "FX", "NOCLICK", "DECOR","INLIMBO" })
    for i, v in ipairs(ents) do 
        if v.components.sanityaura ~= nil and v ~= self.inst then
            local aura_val = v.components.sanityaura:GetAura(self.inst)
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
