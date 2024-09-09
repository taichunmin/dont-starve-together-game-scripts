local UIAnim = require("widgets/uianim")

local MiasmaCloudsOver = Class(UIAnim, function(self, owner)
	self.owner = owner
	UIAnim._ctor(self)

	self:SetClickable(false)

	self:SetHAnchor(ANCHOR_MIDDLE)
	self:SetVAnchor(ANCHOR_MIDDLE)
	self:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

	self:GetAnimState():SetBank("miasma_over")
	self:GetAnimState():SetBuild("miasma_over")
	self:GetAnimState():PlayAnimation("dust_loop", true)
	self:GetAnimState():AnimateWhilePaused(false)
end)

return MiasmaCloudsOver
