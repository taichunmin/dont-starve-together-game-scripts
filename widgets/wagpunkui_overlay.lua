local UIAnim = require "widgets/uianim"
--local Widget = require "widgets/widget"
--local Image = require "widgets/image"

local Wagpunkui_overlay =  Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self, "Wagpunkui_overlay")

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self:GetAnimState():SetBank("wagpunk_over")
    self:GetAnimState():SetBuild("wagpunk_over")
    self:GetAnimState():PlayAnimation("over")
    self:GetAnimState():AnimateWhilePaused(false)

end)

return Wagpunkui_overlay
