local UIAnim = require("widgets/uianim")

local RoseGlassesOver = Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self)

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    local animstate = self:GetAnimState()
    animstate:SetBank("roseglasshat_over")
    animstate:SetBuild("roseglasseshat_over")
    animstate:PlayAnimation("over_idle", true)

    self:Hide()

    self.inst:ListenForEvent("roseglassesvision", function(owner, data)
        self:Toggle(data.enabled)
    end, owner)

    if owner ~= nil and owner.components.playervision ~= nil and owner.components.playervision:HasRoseGlassesVision() then
        self:Toggle(true)
    end
end)

function RoseGlassesOver:Toggle(show)
    if show and not self.shown then
        self:Enable()
    elseif not show and self.shown then
        self:Disable()
    end
    self.shown = show
end

function RoseGlassesOver:Enable()
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self:Show()

    local animstate = self:GetAnimState()
    animstate:PlayAnimation("over_pre")
    animstate:PushAnimation("over_idle", true)
end

function RoseGlassesOver:Disable()
    local animstate = self:GetAnimState()
    animstate:PlayAnimation("over_pst")

    local duration = self.inst.AnimState:GetCurrentAnimationLength() + FRAMES
    if self.hidetask ~= nil then
        self.hidetask:Cancel()
        self.hidetask = nil
    end
    self.hidetask = self.inst:DoTaskInTime(duration, function(inst) self:Hide() end)
end

return RoseGlassesOver
