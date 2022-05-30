local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local HungerBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, { 255 / 255, 204 / 255, 51 / 255, 1 }, "status_hunger", nil, nil, true)

    self.hungerarrow = self.underNumber:AddChild(UIAnim())
    self.hungerarrow:GetAnimState():SetBank("sanity_arrow")
    self.hungerarrow:GetAnimState():SetBuild("sanity_arrow")
    self.hungerarrow:GetAnimState():PlayAnimation("neutral")
    self.hungerarrow:SetClickable(false)
    self.hungerarrow:GetAnimState():AnimateWhilePaused(false)

    self:StartUpdating()
end)

function HungerBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    local anim = "neutral"
    if  self.owner ~= nil and
        self.owner:HasTag("sleeping") and
        self.owner.replica.hunger ~= nil and
        self.owner.replica.hunger:GetPercent() > 0 then

        anim = "arrow_loop_decrease"
    end

    if self.owner:HasDebuff("wintersfeastbuff") or self.owner:HasDebuff("hungerregenbuff") then
        anim = "arrow_loop_increase"
    end

    if self.arrowdir ~= anim then
        self.arrowdir = anim
        self.hungerarrow:GetAnimState():PlayAnimation(anim, true)
    end
end

return HungerBadge
