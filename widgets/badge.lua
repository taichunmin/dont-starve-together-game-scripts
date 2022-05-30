local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local easing = require "easing"
local Widget = require "widgets/widget"

local Badge = Class(Widget, function(self, anim, owner, tint, iconbuild, circular_meter, use_clear_bg, dont_update_while_paused)
    Widget._ctor(self, "Badge")
    self:UpdateWhilePaused(not dont_update_while_paused)
    self.owner = owner

    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)
    self.percent = 1
    self:SetScale(1, 1, 1)

    self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")
    self.pulse:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)

    self.warning = self:AddChild(UIAnim())
    self.warning:GetAnimState():SetBank("pulse")
    self.warning:GetAnimState():SetBuild("hunger_health_pulse")
    self.warning:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)
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
        if use_clear_bg then
            self.backing = self:AddChild(UIAnim())
            self.backing:GetAnimState():SetBank ("status_clear_bg")
            self.backing:GetAnimState():SetBuild("status_clear_bg")
            self.backing:GetAnimState():PlayAnimation("backing")
        else
            self.backing = self:AddChild(UIAnim())
            self.backing:GetAnimState():SetBank("status_meter")
            self.backing:GetAnimState():SetBuild("status_meter")
            self.backing:GetAnimState():PlayAnimation("bg")
        end
        self.backing:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)

        self.anim = self:AddChild(UIAnim())
        self.anim:GetAnimState():SetBank("status_meter")
        self.anim:GetAnimState():SetBuild("status_meter")
        self.anim:GetAnimState():PlayAnimation("anim")
        if tint ~= nil then
            self.anim:GetAnimState():SetMultColour(unpack(tint))
        end

        if circular_meter then
            --self.circular_meter = self.underNumber:AddChild(UIAnim())
            self.circular_meter = self:AddChild(UIAnim())
            self.circular_meter:GetAnimState():SetBank( "status_meter_circle")
            self.circular_meter:GetAnimState():SetBuild("status_meter_circle")
            self.circular_meter:GetAnimState():PlayAnimation("meter")
            self.circular_meter:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)

            if tint ~= nil then
                self.circular_meter:GetAnimState():SetMultColour(unpack(tint))
            end

            self.anim:Hide()
        end

        --self.frame clashes with existing mods
        self.circleframe = self:AddChild(UIAnim())
        self.circleframe:GetAnimState():SetBank("status_meter")
        self.circleframe:GetAnimState():SetBuild("status_meter")
        self.circleframe:GetAnimState():PlayAnimation("frame")
        self.circleframe:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)
		--self.dont_animate_circleframe = false
        if iconbuild ~= nil then
            self.circleframe:GetAnimState():OverrideSymbol("icon", iconbuild, "icon")
            self.iconbuild = iconbuild
        end
    end
    self.anim:GetAnimState():AnimateWhilePaused(not dont_update_while_paused)

    self.underNumber = self:AddChild(Widget("undernumber"))

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:Hide()
end)

function Badge:SetIconSkin( skinname )
    if self.iconbuild ~= nil then --Do we want to allow a skin on the icon for badges that didn't have a default?
        if skinname ~= "" then
            self.circleframe:GetAnimState():OverrideSkinSymbol("icon", GetBuildForItem(skinname), "icon")
            --self.circleframe:GetAnimState():OverrideSkinSymbol("icon_angry", GetBuildForItem(skinname), "icon_angry")
        else
            self.circleframe:GetAnimState():OverrideSymbol("icon", self.iconbuild, "icon")
        end
    end
end

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

    if self.circular_meter ~= nil then
        self.circular_meter:GetAnimState():SetPercent("meter", val)
    else
        self.anim:GetAnimState():SetPercent("anim", 1 - val)
        if self.circleframe ~= nil and not self.dont_animate_circleframe then
            self.circleframe:GetAnimState():SetPercent("frame", 1 - val)
        end
    end

    --print(val, max, val * max)
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
