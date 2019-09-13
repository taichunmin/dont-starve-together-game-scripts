local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local MoistureMeter = Class(Widget, function(self, owner)
    Widget._ctor(self, "MoistureMeter")
    self.owner = owner

    self:SetPosition(0, 0, 0)

    self.moisture = 0
    self.moisturedelta = 0
    self.active = false

    --self.bg clashes with existing mods
    self.backing = self:AddChild(UIAnim())
    self.backing:GetAnimState():SetBank("status_meter")
    self.backing:GetAnimState():SetBuild("status_wet")
    self.backing:GetAnimState():Hide("frame")
    self.backing:GetAnimState():Hide("icon")
    self.backing:SetClickable(true)

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("status_meter")
    self.anim:GetAnimState():SetBuild("status_meter")
    self.anim:Hide("icon")
    self.anim:GetAnimState():SetMultColour(48 / 255, 97 / 255, 169 / 255, 1)
    self.anim:SetClickable(true)

    --self.frame clashes with existing mods
    self.circleframe = self:AddChild(UIAnim())
    self.circleframe:GetAnimState():SetBank("status_meter")
    self.circleframe:GetAnimState():SetBuild("status_meter")
    self.circleframe:GetAnimState():OverrideSymbol("icon", "status_wet", "icon")
    self.circleframe:GetAnimState():Hide("bg")
    self.circleframe:SetClickable(true)

    self.arrowdir = "neutral"
    self.arrow = self:AddChild(UIAnim())
    self.arrow:GetAnimState():SetBank("sanity_arrow")
    self.arrow:GetAnimState():SetBuild("sanity_arrow")
    self.arrow:GetAnimState():PlayAnimation(self.arrowdir)
    self.arrow:SetClickable(false)

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:SetClickable(false)
    self.num:Hide()
end)

function MoistureMeter:Activate()
    self.backing:GetAnimState():PlayAnimation("open")
    self.circleframe:GetAnimState():PlayAnimation("open")
    self.anim:Show()
    self.animtime = 0
    self:StartUpdating()
    self:OnUpdate(0)
    TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/common/HUD_wet_open")
end

function MoistureMeter:Deactivate()
    self.backing:GetAnimState():PlayAnimation("close")
    self.circleframe:GetAnimState():PlayAnimation("close")
    self.anim:Hide()
    self:StopUpdating()
    TheFrontEnd:GetSound():PlaySound("dontstarve_DLC001/common/HUD_wet_close")
end

function MoistureMeter:OnGainFocus()
    MoistureMeter._base:OnGainFocus(self)
    self.num:Show()
end

function MoistureMeter:OnLoseFocus()
    MoistureMeter._base:OnLoseFocus(self)
    self.num:Hide()
end

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function MoistureMeter:SetValue(moisture, max, ratescale)
    if moisture > 0 then
        if not self.active then
            self.active = true
            self:Activate()
        end
        self.anim:GetAnimState():SetPercent("anim", 1 - moisture / max)
        self.num:SetString(tostring(math.ceil(moisture)))
    elseif self.active then
        self.active = false
        self:Deactivate()
    end

    -- Update arrow
    local anim = "neutral"
    if ratescale == RATE_SCALE.INCREASE_LOW or
        ratescale == RATE_SCALE.INCREASE_MED or
        ratescale == RATE_SCALE.INCREASE_HIGH then
        if moisture < max then
            anim = RATE_SCALE_ANIM[ratescale]
        end
    elseif ratescale == RATE_SCALE.DECREASE_LOW or
        ratescale == RATE_SCALE.DECREASE_MED or
        ratescale == RATE_SCALE.DECREASE_HIGH then
        if moisture > 0 then
            anim = RATE_SCALE_ANIM[ratescale]
        end
    end
    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.arrow:GetAnimState():PlayAnimation(anim, true)
    end
end

function MoistureMeter:OnUpdate(dt)
    local curframe = self.circleframe:GetAnimState():GetCurrentAnimationTime() / FRAMES
    if curframe < 1 then
        self.anim:SetScale(.955, .096, 1)
    elseif curframe < 2 then
        self.anim:SetScale(.977, .333, 1)
    elseif curframe < 3 then
        self.anim:SetScale(1.044, 1.044, 1)
    elseif curframe < 4 then
        self.anim:SetScale(1.019, 1.019, 1)
    elseif curframe < 5 then
        self.anim:SetScale(1.005, 1.005, 1)
    else
        self.anim:SetScale(1, 1, 1)
        self:StopUpdating()
    end
end

return MoistureMeter
