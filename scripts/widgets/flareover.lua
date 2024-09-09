local Widget = require "widgets/widget"
local Image = require "widgets/image"

local FlareOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FlareOver")

    self._hide_task = nil
    self._alpha = 0.0
    self._alpha_target = 0.0
    self._alpha_speed = 0.5 -- rate of change from alpha=1 to alpha=0

    self:SetClickable(false)

    self.bg = self:AddChild(Image("images/fx4.xml", "flare_over.tex"))
    self.bg:SetVRegPoint(ANCHOR_TOP)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_TOP)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)

    self:Hide()

    self.inst:ListenForEvent("startflareoverlay", function(src,data) self:StartFlare(data) end, owner)
end)

function FlareOver:StartFlare(data)
    self:Show()
    self._alpha = 1.0

    self:StartUpdating()
    if data then
        self.bg:SetTint(data.r,data.g,data.b, self._alpha)
    end
end

function FlareOver:OnUpdate(dt)
    local delta = dt * self._alpha_speed
    self._alpha = (1 - delta) * self._alpha

    -- Delay our alpha fade until the second half of the update period.
    -- That is, we display at full alpha for the first half of our period,
    -- and fade from 1 to 0 in the other half.
    self.bg:SetFadeAlpha((self._alpha > 0.5 and 1) or self._alpha / 0.5)
    if self._alpha <= 0.01 then
        self:Hide()
        self:StopUpdating()
    else
        self:Show()
    end
end

return FlareOver
