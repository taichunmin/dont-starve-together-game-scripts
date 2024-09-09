local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"

local WendyFlowerOver =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "InkOver")

    self.anim = self:AddChild(UIAnim(owner))

    self:SetClickable(false)

    self.anim:SetHAnchor(ANCHOR_MIDDLE)
    self.anim:SetVAnchor(ANCHOR_MIDDLE)
    self.anim:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self.anim:GetAnimState():SetBank("wendy_flower_over")
    self.anim:GetAnimState():SetBuild("wendy_flower_over")
    self.anim:GetAnimState():AnimateWhilePaused(false)
end)

function WendyFlowerOver:SetSkin( skinname )
    if skinname == "" then
        self.skinbuild = nil
    else
        self.skinbuild = GetBuildForItem( skinname )
    end
end

function WendyFlowerOver:Play( level )
    local skinsym = ""
    if self.skinbuild ~= nil then
        self.anim:GetAnimState():SetSkin(self.skinbuild, "wendy_flower_over")
    else
        self.anim:GetAnimState():SetBuild("wendy_flower_over")
    end

    self.anim:GetAnimState():PlayAnimation("over_stage"..tostring(level))
end

return WendyFlowerOver
