local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"

local Badge = Class(Widget, function(self, anim, owner, tint, iconbuild)
    Widget._ctor(self, "Badge")
    self.owner = owner

    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)
    self.percent = 1
    self:SetScale(1, 1, 1)

    self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")

    self.warning = self:AddChild(UIAnim())
    self.warning:GetAnimState():SetBank("pulse")
    self.warning:GetAnimState():SetBuild("hunger_health_pulse")
    self.warning:Hide()
    self.warningstarted = nil
    self.warningdelaytask = nil

    if anim ~= nil then
        self.anim = self:AddChild(UIAnim())
        self.anim:GetAnimState():SetBank(anim)
        self.anim:GetAnimState():SetBuild(anim)
        self.anim:GetAnimState():PlayAnimation("anim")
    else
        --self.bg clashes with existing mods
        self.backing = self:AddChild(UIAnim())
        self.backing:GetAnimState():SetBank("status_meter")
        self.backing:GetAnimState():SetBuild("status_meter")
        self.backing:GetAnimState():PlayAnimation("bg")

        self.anim = self:AddChild(UIAnim())
        self.anim:GetAnimState():SetBank("status_meter")
        self.anim:GetAnimState():SetBuild("status_meter")
        self.anim:GetAnimState():PlayAnimation("anim")
        if tint ~= nil then
            self.anim:GetAnimState():SetMultColour(unpack(tint))
        end

        --self.frame clashes with existing mods
        self.circleframe = self:AddChild(UIAnim())
        self.circleframe:GetAnimState():SetBank("status_meter")
        self.circleframe:GetAnimState():SetBuild("status_meter")
        self.circleframe:GetAnimState():PlayAnimation("frame")
        if iconbuild ~= nil then
            self.circleframe:GetAnimState():OverrideSymbol("icon", iconbuild, "icon")
        end
    end

    self.underNumber = self:AddChild(Widget("undernumber"))

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:Hide()
end)

function Badge:OnGainFocus()
    Badge._base.OnGainFocus(self)
    self.num:Show()
end

function Badge:OnLoseFocus()
    Badge._base.OnLoseFocus(self)
    self.num:Hide()
end

function Badge:SetPercent(val, max)
    val = val or self.percent
    max = max or 100

    self.anim:GetAnimState():SetPercent("anim", 1 - val)
    if self.circleframe ~= nil then
        self.circleframe:GetAnimState():SetPercent("frame", 1 - val)
    end
    -- print(val, max, val * max)
    self.num:SetString(tostring(math.ceil(val * max)))

    self.percent = val
end

local function CheckWarning(inst, self)
    self.warningdelaytask = nil

    if self.warningstarted and not self.warning.shown then
        self.warning:Show()
        self.warning:GetAnimState():PlayAnimation("pulse", true)
    end
end

function Badge:PulseGreen()
    self.pulse:GetAnimState():SetMultColour(0, 1, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("pulse")

    if self.warning.shown then
        self.warning:Hide()
    end

    if self.warningdelaytask ~= nil then
        self.warningdelaytask:Cancel()
    end
    self.warningdelaytask = self.inst:DoTaskInTime(2 * self.pulse:GetAnimState():GetCurrentAnimationLength(), CheckWarning, self)
end

function Badge:PulseRed()
    self.pulse:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.pulse:GetAnimState():PlayAnimation("pulse")

    if self.warning.shown then
        self.warning:Hide()
    end

    if self.warningdelaytask ~= nil then
        self.warningdelaytask:Cancel()
    end
    self.warningdelaytask = self.inst:DoTaskInTime(self.pulse:GetAnimState():GetCurrentAnimationLength(), CheckWarning, self)
end

function Badge:StopWarning()
    if self.warningstarted then
        self.warningstarted = nil

        if self.warning.shown then
            self.warning:Hide()
        end
    end
end

function Badge:StartWarning(r, g, b, a)
    if r == nil or g == nil or b == nil or a == nil then
        -- default to red if no valid color is provided
        r, g, b, a = 1, 0, 0, 1
    end
    self.warning:GetAnimState():SetMultColour(r, g, b, a)

    if not self.warningstarted then
        self.warningstarted = true

        if self.warningdelaytask == nil and not self.warning.shown then
            self.warning:Show()
            self.warning:GetAnimState():PlayAnimation("pulse", true)
        end
    end
end

return Badge
