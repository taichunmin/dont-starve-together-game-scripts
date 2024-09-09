local function oncurrent(self, current)
    if self.inst.player_classified ~= nil then
        assert(current >= 0 and current <= 255, "Player currentwereness out of range: "..tostring(current))
        self.inst.player_classified.currentwereness:set(math.ceil(current))
    end
end

local function onrate(self, rate)
    if self.inst.player_classified ~= nil then
        assert(rate <= 0 and rate >= -10, "Player wereness rate out of range: "..tostring(rate))
        self.inst.player_classified.werenessdrainrate:set(math.floor(.5 - 6.3 * rate))
    end
end

local Wereness = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("wereness")

    self.max = 100
    self.current = 0
    self._old = self.current
    self.rate = 0
    self.draining = false
    self.weremode = nil

    if inst.player_classified ~= nil then
        makereadonly(self, "max")
    end
end,
nil,
{
    current = oncurrent,
    rate = onrate,
})

function Wereness:SetWereMode(weremode)
    self.weremode = weremode
end

function Wereness:GetWereMode()
    return self.weremode
end

function Wereness:SetDrainRate(rate)
    self.rate = rate
end

function Wereness:StartDraining()
    if not self.draining and self.current > 0 then
        self.draining = true
        self.inst:StartUpdatingComponent(self)
    end
end

function Wereness:StopDraining()
    if self.draining then
        self.draining = false
        self.inst:StopUpdatingComponent(self)
    end
end

function Wereness:DoDelta(delta, overtime)
    local old = self._old
    self.current = math.clamp(self.current + delta, 0, self.max)
    self._old = self.current

    if self.current <= 0 then
        self:StopDraining()
    end

    self.inst:PushEvent("werenessdelta", { oldpercent = old / self.max, newpercent = self.current / self.max, overtime = overtime })
end

function Wereness:GetPercent()
    return self.current / self.max
end

function Wereness:SetPercent(percent, overtime)
    self.current = self.max * percent
    self:DoDelta(0, overtime)
end

function Wereness:OnUpdate(dt)
    if self.rate ~= 0 and dt ~= 0 then
        self:DoDelta(self.rate * dt, true)
    end
end

function Wereness:OnSave()
    return self.current > 0 and {
        current = self.current,
        mode = self.weremode,
    } or nil
end

function Wereness:OnLoad(data)
    if data.current ~= nil and data.current > 0 then
        self.weremode = data.mode
        self.current = data.current
        self:StartDraining()
        self:DoDelta(0, true)
    end
end

function Wereness:GetDebugString()
    return string.format("%.2f/%.2f (%s%.2f/s)", self.current, self.max, ((not self.draining or self.rate == 0) and "-") or (self.rate >= 0 and "+") or "", not self.draining and 0 or self.rate)
end

return Wereness
