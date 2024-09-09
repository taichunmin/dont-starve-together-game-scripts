local function StopSizzle(item)
    item._acidsizzlingtimer = nil
    item.components.inventoryitem.isacidsizzling = false
end

local function MakeSizzle(item)
    item.components.inventoryitem.isacidsizzling = true
    if item._acidsizzlingtimer ~= nil then
        item._acidsizzlingtimer:Cancel()
        item._acidsizzlingtimer = nil
    end
    item._acidsizzlingtimer = item:DoTaskInTime(TUNING.ACIDRAIN_DAMAGE_TIME * 1.1, StopSizzle)
end

local function StopSizzlePlayer(player)
    player._acidsizzlingtimer = nil
    if player.player_classified then
        player.player_classified.isacidsizzling:set(false)
    end
end

local function MakeSizzlePlayer(player)
    if player.player_classified then
        player.player_classified.isacidsizzling:set(true)
        if player._acidsizzlingtimer ~= nil then
            player._acidsizzlingtimer:Cancel()
            player._acidsizzlingtimer = nil
        end
        player._acidsizzlingtimer = player:DoTaskInTime(TUNING.ACIDRAIN_DAMAGE_TIME * 1.1, StopSizzlePlayer)
    end
end

local function DoAcidRainDamageOnEquipped(item, damage)
    if item:HasTag("acidrainimmune") then
        return
    end

    local dosizzle = false

    if item.components.armor then
        item.components.armor:TakeDamage(damage)
        if not item:IsValid() then
            return
        end
        dosizzle = true
    end

    if item.components.fueled and item.components.fueled.fueltype == FUELTYPE.USAGE then
        item.components.fueled:DoDelta(-damage * TUNING.ACIDRAIN_DAMAGE_FUELED_SCALER)
        if not item:IsValid() then
            return
        end
        dosizzle = true
    end

    if dosizzle then
        MakeSizzle(item)
    end
end

local function DoAcidRainRotOnAllItems(item, percent)
    if item:HasTag("acidrainimmune") then
        return
    end

    local dosizzle = false

    if item.components.perishable then
        item.components.perishable:ReducePercent(percent)
        if not item:IsValid() then
            return
        end
        dosizzle = true
    end

    if dosizzle then
        MakeSizzle(item)
    end
end

local function DoAcidRainDamageOnHealth(inst, damage)
    if inst:HasTag("acidrainimmune") then
        return
    end

    if damage > 0 and inst.player_classified then
        MakeSizzlePlayer(inst)
    end

    if inst.components.health then
        inst.components.health:DoDelta(-damage, false, "acidrain")
    end
end

local AcidLevel = Class(function(self, inst)
    self.inst = inst

    self.max = 100
    self.current = 0
    --self.ignoreacidrainticks = nil

    --self.overrideacidraintick = nil

    self.DoAcidRainDamageOnEquipped = DoAcidRainDamageOnEquipped -- Mods.
    self.DoAcidRainRotOnAllItems = DoAcidRainRotOnAllItems -- Mods.
    self.DoAcidRainDamageOnHealth = DoAcidRainDamageOnHealth -- Mods.

    self:WatchWorldState("isacidraining", self.OnIsAcidRaining)
    self:WatchWorldState("israining", self.OnIsRaining)
    self.inst:DoTaskInTime(0, function() -- NOTES(JBK): LoadPostPass without regard to save data.
        self:OnIsAcidRaining(TheWorld.state.isacidraining)
        self:OnIsRaining(TheWorld.state.israining)
    end)
end)

function AcidLevel:SetIgnoreAcidRainTicks(ignoreacidrainticks)
    if self.ignoreacidrainticks ~= ignoreacidrainticks then
        if self.inst.acidlevel_acid_task ~= nil then
            -- Ticks are ticking.
            if ignoreacidrainticks then
                -- From allowing to ignoring.
                if self.onstopisacidrainingfn then
                    self.onstopisacidrainingfn(self.inst)
                end
            else
                -- From ignoring to allowing.
                if self.onstartisacidrainingfn then
                    self.onstartisacidrainingfn(self.inst)
                end
            end
        end
        self.ignoreacidrainticks = ignoreacidrainticks
    end
end

local function DoAcidRainTick(inst, self)
	if inst.components.rainimmunity ~= nil or self.ignoreacidrainticks then
		return
	end

    local damage = TUNING.ACIDRAIN_DAMAGE_TIME * TUNING.ACIDRAIN_DAMAGE_PER_SECOND -- Do not apply rate here.
    local rate = (inst.components.moisture and inst.components.moisture:_GetMoistureRateAssumingRain() or TheWorld.state.precipitationrate)

    if inst.components.inventory then
        if inst.components.inventory:EquipHasTag("acidrainimmune") then
            damage = 0
        else
            -- Melt worn waterproofer equipment.
            local waterproofers, total_effectiveness = nil, 0
            for slot, item in pairs(inst.components.inventory.equipslots) do
                if item.components.waterproofer then
                    local effectiveness = item.components.waterproofer:GetEffectiveness()
                    if effectiveness > 0 then
                        if not waterproofers then
                            waterproofers = {}
                        end
                        table.insert(waterproofers, item)
                        total_effectiveness = total_effectiveness + effectiveness
                    end
                end
            end
            if waterproofers then
                total_effectiveness = math.clamp(total_effectiveness, 0, 1)

                local damageabsorbed = total_effectiveness * damage
                damage = damage - damageabsorbed

                local damagesplit = damageabsorbed / #waterproofers
                for _, item in ipairs(waterproofers) do
                    self.DoAcidRainDamageOnEquipped(item, damagesplit)
                end
            end

            if damage > 0 then
                -- Spoil perishables, using rate.
                inst.components.inventory:ForEachWetableItem(self.DoAcidRainRotOnAllItems, rate * TUNING.ACIDRAIN_PERISHABLE_ROT_PERCENT * TUNING.ACIDRAIN_DAMAGE_TIME)
            end
        end
    end

    -- Apply rate counter.
    self:DoDelta(rate * TUNING.ACIDRAIN_DAMAGE_TIME)

    -- Adjust damage dealt to health with rate now.
    damage = damage * rate

    local fn = self:GetOverrideAcidRainTickFn()
    if fn then
        damage = fn(inst, damage) or damage
    end

    if damage ~= 0 then -- NOTES(JBK): In case GetOverrideAcidRainTickFn returns a negative value to heal.
        self.DoAcidRainDamageOnHealth(inst, damage)
    end
end

local function DoRainTick(inst, self)
	if inst.components.rainimmunity ~= nil then
		return
	end
    local rate = (inst.components.moisture and inst.components.moisture:_GetMoistureRateAssumingRain() or TheWorld.state.precipitationrate) * TUNING.ACIDRAIN_DAMAGE_TIME
    self:DoDelta(-rate)
end

function AcidLevel:SetOverrideAcidRainTickFn(fn)
    -- Return 0 in overrideacidraintick to skip default behaviour on the inst.
    self.overrideacidraintick = fn
end
function AcidLevel:GetOverrideAcidRainTickFn()
    return self.overrideacidraintick
end

function AcidLevel:OnIsAcidRaining(isacidraining)
    if isacidraining then
        if self.inst.acidlevel_acid_task == nil then
            self.inst.acidlevel_acid_task = self.inst:DoPeriodicTask(TUNING.ACIDRAIN_DAMAGE_TIME, DoAcidRainTick, math.random() * TUNING.ACIDRAIN_DAMAGE_TIME, self)
        end
        if self.onstartisacidrainingfn then
            self.onstartisacidrainingfn(self.inst)
        end
    elseif self.inst.acidlevel_acid_task ~= nil then
        self.inst.acidlevel_acid_task:Cancel()
        self.inst.acidlevel_acid_task = nil
        if self.onstopisacidrainingfn then
            self.onstopisacidrainingfn(self.inst)
        end
    end
end

function AcidLevel:OnIsRaining(israining)
    if israining then
        if self.inst.acidlevel_rain_task == nil then
            self.inst.acidlevel_rain_task = self.inst:DoPeriodicTask(TUNING.ACIDRAIN_DAMAGE_TIME, DoRainTick, math.random() * TUNING.ACIDRAIN_DAMAGE_TIME, self)
        end
        if self.onstartisrainingfn then
            self.onstartisrainingfn(self.inst)
        end
    elseif self.inst.acidlevel_rain_task ~= nil then
        self.inst.acidlevel_rain_task:Cancel()
        self.inst.acidlevel_rain_task = nil
        if self.onstopisrainingfn then
            self.onstopisrainingfn(self.inst)
        end
    end
end


function AcidLevel:SetOnStartIsAcidRainingFn(fn)
    self.onstartisacidrainingfn = fn
end

function AcidLevel:SetOnStopIsAcidRainingFn(fn)
    self.onstopisacidrainingfn = fn
end

function AcidLevel:SetOnStartIsRainingFn(fn)
    self.onstartisrainingfn = fn
end

function AcidLevel:SetOnStopIsRainingFn(fn)
    self.onstopisrainingfn = fn
end


function AcidLevel:DoDelta(delta)
    local old = self.current
    self.current = math.clamp(self.current + delta, 0, self.max)

    self.inst:PushEvent("acidleveldelta", { oldpercent = old / self.max, newpercent = self.current / self.max, })
end

function AcidLevel:GetPercent()
    return self.current / self.max
end

function AcidLevel:SetPercent(percent)
    self:DoDelta(self.max * percent - self.current)
end

function AcidLevel:OnSave()
    return
    {
        current = self.current,
    }
end

function AcidLevel:OnLoad(data)
    if data ~= nil and data.current ~= nil and data.current ~= self.current then
        self:DoDelta(data.current - self.current)
    end
end

function AcidLevel:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

return AcidLevel
