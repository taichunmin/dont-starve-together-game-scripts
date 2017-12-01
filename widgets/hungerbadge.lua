local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local HungerBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "hunger", owner)

	self.hungerarrow = self.underNumber:AddChild(UIAnim())
	self.hungerarrow:GetAnimState():SetBank("sanity_arrow")
	self.hungerarrow:GetAnimState():SetBuild("sanity_arrow")
	self.hungerarrow:GetAnimState():PlayAnimation("neutral")
	self.hungerarrow:SetClickable(false)

	self:StartUpdating()
end)

function HungerBadge:OnUpdate(dt)
	local down = self.owner ~= nil and
        self.owner:HasTag("sleeping") and
        self.owner.replica.hunger ~= nil and
        self.owner.replica.hunger:GetPercent() > 0

	local anim = down and "arrow_loop_decrease" or "neutral"
	if self.arrowdir ~= anim then
		self.arrowdir = anim
		self.hungerarrow:GetAnimState():PlayAnimation(anim, true)
	end
end

return HungerBadge