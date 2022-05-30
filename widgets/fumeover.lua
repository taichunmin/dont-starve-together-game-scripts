local Widget = require "widgets/widget"
local Image = require "widgets/image"

local FAST_PERIOD = FRAMES
local MED_PERIOD = .2
local SLOW_PERIOD = .5

local function SwitchUpdatePeriod(self, period, UpdateLayers)
    if self._updateperiod ~= period then
        self._updateperiod = period
        self._updatetask:Cancel()
        self._updatetask = self.inst:DoPeriodicTask(period, UpdateLayers, nil, self)
    end
end

local FUME_MUST_TAGS = { "sporecloud" }

local function UpdateLayers(inst, self)
    if next(self.corrosives) ~= nil then
        return
    end

    local clouds = 0

    if not self.owner:HasTag("playerghost") then
        local x, y, z = self.owner.Transform:GetWorldPosition()
        local fumes = TheSim:FindEntities(x, y, z, 4, FUME_MUST_TAGS)
        for i, v in ipairs(fumes) do
            --3.5 ^ 2 = 12.25
            --4 ^ 2 = 16
            --16 - 12.25 = 3.75
            local k = math.max(0, (16 - v:GetDistanceSqToPoint(x, y, z)) / 3.75)
            if k >= 1 then
                clouds = 1
                break
            end
            clouds = clouds + k * k * .5
            if clouds >= 1 then
                clouds = 1
                break
            end
        end
    end

    if clouds > 0 then
        self:TurnOn(self.over, clouds)
        SwitchUpdatePeriod(self, clouds < 1 and FAST_PERIOD or MED_PERIOD, UpdateLayers)
    else
        self:TurnOff(self.over)
        SwitchUpdatePeriod(self, SLOW_PERIOD, UpdateLayers)
    end

    if clouds < 1 and next(self.debuffs) ~= nil then
        self:TurnOn(self.top)
    else
        self:TurnOff(self.top)
    end
end

local FumeOver =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FumeOver")
    self:UpdateWhilePaused(false)

    self:SetClickable(false)

    self.over =
    {
        base_level = 0,
        level = 0,
        k = 1,
        bg = self:AddChild(Image("images/fx2.xml", "fume_over.tex")),
    }
    self.over.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.over.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.over.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.over.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.over.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.over.bg:Hide()

    self.top =
    {
        base_level = 0,
        level = 0,
        k = 1,
        bg = self:AddChild(Image("images/fx2.xml", "fume_top.tex")),
    }
    self.top.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.top.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.top.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.top.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.top.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.top.bg:Hide()

    self:Hide()

    self._updateperiod = SLOW_PERIOD
    self._updatetask = self.inst:DoPeriodicTask(self._updateperiod, UpdateLayers, 0, self)

    self.debuffs = {}
    self._onremovedebuff = function(debuff)
        self.debuffs[debuff] = nil
        self._updatetask:Cancel()
        self._updatetask = self.inst:DoPeriodicTask(self._updateperiod, UpdateLayers, 0, self)
    end
    self.inst:ListenForEvent("startfumedebuff", function(owner, debuff)
        if self.debuffs[debuff] == nil then
            self.debuffs[debuff] = true
            self.inst:ListenForEvent("onremove", self._onremovedebuff, debuff)
            self._updatetask:Cancel()
            self._updatetask = self.inst:DoPeriodicTask(self._updateperiod, UpdateLayers, nil, self)
            UpdateLayers(self.inst, self)
        end
    end, owner)

    self.corrosives = {}
    self._onremovecorrosive = function(debuff)
        self.corrosives[debuff] = nil
        if self._updatetask ~= nil then
            self._updatetask:Cancel()
            self._updatetask = self.inst:DoPeriodicTask(self._updateperiod, UpdateLayers, 0, self)
        elseif next(self.corrosives) == nil then
            self:TurnOff(self.over)
        end
    end
    self.inst:ListenForEvent("startcorrosivedebuff", function(owner, debuff)
        if self.corrosives[debuff] == nil then
            self.corrosives[debuff] = true
            self.inst:ListenForEvent("onremove", self._onremovecorrosive, debuff)
            self:TurnOn(self.over)
            self:TurnOff(self.top)
        end
    end, owner)
end)

function FumeOver:TurnOn(layer, intensity)
    self:StartUpdating()
    layer.base_level = .5 * (intensity or 1)
    layer.k = 5
end

function FumeOver:TurnOff(layer)
    self:StartUpdating()
    layer.base_level = 0
    layer.k = 5
end

local function IsDone(layer)
    return layer.level == layer.base_level
end

function FumeOver:DoUpdate(layer, dt)
    if IsDone(layer) then
        return
    end

    local delta = layer.base_level - layer.level
    layer.level = math.abs(delta) < .025 and layer.base_level or layer.level + delta * dt * layer.k

    if layer.level > 0 then
        layer.bg:Show()
        layer.bg:SetTint(1, 1, 1, layer.level)
    else
        layer.bg:Hide()
    end
end

function FumeOver:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end
    -- ignore 0 interval
    -- ignore abnormally large intervals as they will destabilize the math in here
    if dt <= 0 or dt > 0.1 then
        return
    end

    self:DoUpdate(self.over, dt)
    self:DoUpdate(self.top, dt)

    if self.over.bg.shown or self.top.bg.shown then
        self:Show()
    else
        self:Hide()
    end

    if IsDone(self.over) and IsDone(self.top) then
        self:StopUpdating()
    end
end

return FumeOver
