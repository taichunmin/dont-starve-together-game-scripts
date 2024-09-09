local UIAnim = require "widgets/uianim"

local SOUND_NAME = "loop"

local NightVisionFruitOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("nightvision_fruit_over")
    self:GetAnimState():SetBuild("nightvision_fruit_over")
    self:GetAnimState():PlayAnimation("over_idle", true)
    self:GetAnimState():AnimateWhilePaused(false)

    self:Hide()

    self.inst:ListenForEvent("ccoverrides", function(owner, cctable)
        self:Toggle(cctable ~= nil and cctable.nightvision_fruit)
    end, owner)

    if owner ~= nil and
        owner.components.playervision ~= nil and
        owner.components.playervision:GetCCTable() ~= nil and
        owner.components.playervision:GetCCTable().nightvision_fruit ~= nil
    then
        self:Toggle(true)
    end

    self.inst:ListenForEvent("onremove", function(inst) self:Toggle(false) end)
end)

function NightVisionFruitOver:Toggle(show)
    if show and not self.shown then
        self:Enable()

    elseif not show and self.shown then
        self:Disable()
    end

    self.shown = show
end

function NightVisionFruitOver:Enable()
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end

    self:Show()

    self:GetAnimState():PlayAnimation("over_pre")
    self:GetAnimState():PushAnimation("over_idle", true)

    TheFocalPoint.SoundEmitter:PlaySound("meta4/ancienttree/nightvision/effect_LP", SOUND_NAME)

    TheWorld:PushEvent("overrideambientlighting", Point(255/255, 175/255, 255/255))
end

function NightVisionFruitOver:Disable()
    self:GetAnimState():PlayAnimation("over_pst")

    local time = self.inst.AnimState:GetCurrentAnimationLength() + FRAMES

    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end

    self.hidetask = self.inst:DoTaskInTime(time, function(inst) self:Hide() end)

    TheFocalPoint.SoundEmitter:KillSound(SOUND_NAME)

    TheWorld:PushEvent("overrideambientlighting", nil)
end

return NightVisionFruitOver
