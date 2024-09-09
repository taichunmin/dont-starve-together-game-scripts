local Widget = require "widgets/widget"
local Image = require "widgets/image"

local GogglesOver =  Class(Widget, function(self, owner, storm_overlays)
    self.owner = owner
    Widget._ctor(self, "GogglesOver")

    self:SetClickable(false)

    self.storm_overlays = storm_overlays
    self.storm_root = storm_overlays:GetParent()

    self.bg = self:AddChild(Image("images/fx3.xml", "goggle_over.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self:Hide()

    self.inst:ListenForEvent("gogglevision", function(owner, data) self:ToggleGoggles(data.enabled) end, owner)
    if owner ~= nil and
        owner.components.playervision ~= nil and
        owner.components.playervision:HasGoggleVision() then
        self:ToggleGoggles(true)
    end
end)

function GogglesOver:ToggleGoggles(show)
    if show then
        if not self.shown then
            self:Show()
            self:AddChild(self.storm_overlays):MoveToBack()
        end
    elseif self.shown then
        self:Hide()
        self.storm_root:AddChild(self.storm_overlays)
    end
end

return GogglesOver
