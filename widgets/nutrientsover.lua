local Widget = require "widgets/widget"
local Image = require "widgets/image"

local NutrientsOver =  Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "NutrientsOver")

    self:SetClickable(false)

    self.bg = self:AddChild(Image("images/fx4.xml", "nutrients_over.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.bg:SetTint(1,1,1,0.75)

    self:Hide()

    self.inst:ListenForEvent("nutrientsvision", function(owner, data) self:ToggleNutrients(data.enabled) end, TheWorld)
    if owner ~= nil and
        owner.components.playervision ~= nil and
        owner.components.playervision:HasNutrientsVision() then
        self:ToggleNutrients(true)
    end
end)

function NutrientsOver:ToggleNutrients(show)
    print(show, self.shown)
    if show and not self.shown then
        self:Show()
    elseif not show and self.shown then
        self:Hide()
    end
    self.shown = show
end

return NutrientsOver
