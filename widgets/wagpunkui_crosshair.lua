local UIAnim = require "widgets/uianim"
--local Widget = require "widgets/widget"
--local Image = require "widgets/image"

local Wagpunkui_crosshair =  Class(UIAnim, function(self, owner)
    self.owner = owner
    UIAnim._ctor(self, "Wagpunkui_crosshair")

    self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)

    self:GetAnimState():SetBank("wagstaff_armor_target")
    self:GetAnimState():SetBuild("wagstaff_armor_target")
    self:GetAnimState():PlayAnimation("distance_meter")
    self:GetAnimState():AnimateWhilePaused(false)

end)

return Wagpunkui_crosshair
