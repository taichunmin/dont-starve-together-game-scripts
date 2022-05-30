local Widget = require "widgets/widget"
local Image = require "widgets/image"

local BloodOver =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "BloodOver")
    self:UpdateWhilePaused(false)

    self:SetClickable(false)

    self.bg = self:AddChild(Image("images/fx.xml", "blood_over.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self:Hide()
    self.base_level = 0
    self.level = 0
    self.k = 1
    --self:UpdateState()
    self.time_since_pulse = 0
    self.pulse_period = 1

    local function _Flash() self:Flash() end
    local function _UpdateState() self:UpdateState() end

    self.inst:ListenForEvent("badaura", _Flash, owner)
    self.inst:ListenForEvent("attacked", function(owner, data)
        if not data.redirected then
            self:Flash()
        end
    end, owner)
    self.inst:ListenForEvent("damaged", _Flash, owner) -- same as attacked, but for non-combat situations like making a telltale heart
    self.inst:ListenForEvent("startstarving", _UpdateState, owner)
    self.inst:ListenForEvent("stopstarving", _UpdateState, owner)
    self.inst:ListenForEvent("startfreezing", _UpdateState, owner)
    self.inst:ListenForEvent("stopfreezing", _UpdateState, owner)
    self.inst:ListenForEvent("startoverheating", _UpdateState, owner)
    self.inst:ListenForEvent("stopoverheating", _UpdateState, owner)
    self.inst:DoTaskInTime(0, _UpdateState)
end)

function BloodOver:UpdateState()
    if (self.owner.IsFreezing ~= nil and self.owner:IsFreezing()) or
        (self.owner.IsOverheating ~= nil and self.owner:IsOverheating()) or
        (self.owner.replica.hunger ~= nil and self.owner.replica.hunger:IsStarving()) then
        self:TurnOn()
    else
        self:TurnOff()
    end
end

function BloodOver:TurnOn()
    --TheInputProxy:AddVibration(VIBRATION_BLOOD_FLASH, .2, .7, true)
    self:StartUpdating()
    self.base_level = .5
    self.k = 5
    self.time_since_pulse = 0
end

function BloodOver:TurnOff()
    self.base_level = 0
    self.k = 5
    --self:OnUpdate(0)
end

function BloodOver:OnUpdate(dt)
    -- ignore 0 interval
    -- ignore abnormally large intervals as they will destabilize the math in here
    if dt <= 0 or dt > 0.1 then
        return
    end

    local delta = self.base_level - self.level

    if math.abs(delta) < .025 then
        self.level = self.base_level
    else
        self.level = self.level + delta * dt * self.k
    end

    --this runs on WallUpdate so the pause check is needed.
    if self.base_level > 0 and not TheNet:IsServerPaused() then
        self.time_since_pulse = self.time_since_pulse + dt
        if self.time_since_pulse > self.pulse_period then
            self.time_since_pulse = 0

            if not IsEntityDead(self.owner) then
                TheInputProxy:AddVibration(VIBRATION_BLOOD_OVER, .2, .3, false)
            end
        end
    end

    if self.level > 0 then
        self:Show()
        self.bg:SetTint(1, 1, 1, self.level)
    else
        self:StopUpdating()
        self:Hide()
    end
end

function BloodOver:Flash()
    TheInputProxy:AddVibration(VIBRATION_BLOOD_FLASH, .2, .7, false)
    self:StartUpdating()
    self.level = 1
    self.k = 1.33
end

return BloodOver
