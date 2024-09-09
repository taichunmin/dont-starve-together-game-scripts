local function oncurrent(self, current)
    if self.inst.player_classified ~= nil then
        assert(current >= 0 and current <= 255, "Player currentbeaverness out of range: "..tostring(current))
        self.inst.player_classified.currentbeaverness:set(math.ceil(current))
    end
end

local Beaverness = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("beaverness")

    self.max = 100
    self.current = 100
    self._old = self.current
    self.time_effect_multiplier = 1

    if inst.player_classified ~= nil then
        makereadonly(self, "max")
    end
end,
nil,
{
    current = oncurrent,
})

function Beaverness:IsStarving()
    return self.current <= 0
end

local function OnTimeEffectTick(inst, self, delta, dt)
    self:DoDelta(delta * self.time_effect_multiplier, true)
    --Beaverness hitting 0 does starving damage
    if self.current <= 0 then
        inst.components.health:DoDelta(-inst.components.hunger.hurtrate * dt, false, "hunger")
    end
end

function Beaverness:StartTimeEffect(dt, delta_b)
    if self.task ~= nil then
        self.task:Cancel()
    end
    self.task = self.inst:DoPeriodicTask(dt, OnTimeEffectTick, nil, self, delta_b, dt)
end

function Beaverness:StopTimeEffect()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function Beaverness:SetTimeEffectMultiplier(multiplier)
    self.time_effect_multiplier = multiplier or 1
end

function Beaverness:DoDelta(delta, overtime)
    local old = self._old
    self.current = math.clamp(self.current + delta, 0, self.max)
    self._old = self.current

    self.inst:PushEvent("beavernessdelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime })

    --push starving event if hunger value isn't currently starving
    if not self.inst.components.hunger:IsStarving() then
        if self.current <= 0 then
            if old > 0 then
                self.inst:PushEvent("startstarving")
                ProfileStatsSet("started_starving", true)
            end
        elseif old <= 0 then
            self.inst:PushEvent("stopstarving")
            ProfileStatsSet("stopped_starving", true)
        end
    end
end

function Beaverness:GetPercent()
    return self.current / self.max
end

function Beaverness:SetPercent(percent, overtime)
    self.current = self.max * percent
    self:DoDelta(0, overtime)
end

function Beaverness:OnSave()
    return
    {
        current = self.current,
    }
end

function Beaverness:OnLoad(data)
    if data ~= nil and data.current ~= nil and data.current ~= self.current then
        self.current = data.current
        self:DoDelta(0, true)
    end
end

function Beaverness:GetDebugString()
    return string.format("%2.2f / %2.2f", self.current, self.max)
end

return Beaverness
