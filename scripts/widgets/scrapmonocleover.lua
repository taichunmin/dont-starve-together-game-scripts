local UIAnim = require "widgets/uianim"

local ScrapMonocleOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("scrap_monocle_over")
    self:GetAnimState():SetBuild("scrap_monocle_over")
    self:GetAnimState():PlayAnimation("over_idle", true)

    self:Hide()

    self.inst:ListenForEvent("scrapmonolevision", function(owner, data) self:Toggle(data.enabled) end, owner)

    if owner ~= nil and
        owner.components.playervision ~= nil and
        owner.components.playervision:HasScrapMonoleVision()
    then
        self:Toggle(true)
    end
end)

function ScrapMonocleOver:Toggle(show)
    if show and not self.shown then
        self:Enable()

    elseif not show and self.shown then
        self:Disable()
    end

    self.shown = show
end

function ScrapMonocleOver:Enable()
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self:Show()

    self:GetAnimState():PlayAnimation("over_pre")
    self:GetAnimState():PushAnimation("over_idle", true)
end

function ScrapMonocleOver:Disable()
    self:GetAnimState():PlayAnimation("over_pst")

    local time = self.inst.AnimState:GetCurrentAnimationLength() + FRAMES

    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self.hidetask = self.inst:DoTaskInTime(time, function(inst) self:Hide() end)
end

return ScrapMonocleOver
