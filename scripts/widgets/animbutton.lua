local Widget = require "widgets/widget"
local Button = require "widgets/button"
local UIAnim = require "widgets/uianim"

local AnimButton = Class(Button, function(self, animname, states)
    Button._ctor(self, "AnimButton")
    self.anim = self:AddChild(UIAnim())
    self.anim:MoveToBack()
    self.anim:GetAnimState():SetBuild(animname)
    self.anim:GetAnimState():SetBank(animname)

    if states then
    	self.animstates = states
    end

    self.anim:GetAnimState():PlayAnimation(self.animstates and self.animstates.idle or "idle")
    self.anim:GetAnimState():SetRayTestOnBB(true);
end)

function AnimButton:OnGainFocus()
	AnimButton._base.OnGainFocus(self)

	if self:IsEnabled() and not self:IsSelected() then
		self.anim:GetAnimState():PlayAnimation(self.animstates and self.animstates.over or "over")
	end
end

function AnimButton:OnLoseFocus()
	AnimButton._base.OnLoseFocus(self)

	if not (self:IsSelected() or self:IsDisabledState()) then
		self.anim:GetAnimState():PlayAnimation(self.animstates and self.animstates.idle or "idle")
    end
end


function AnimButton:Enable()
	AnimButton._base.Enable(self)
	self.anim:GetAnimState():PlayAnimation(self.animstates and self.animstates.idle or "idle")
	--self.text:SetColour(1,1,1,1)
end

function AnimButton:Disable()
	AnimButton._base.Disable(self)
	self.anim:GetAnimState():PlayAnimation(self.animstates and self.animstates.disabled or "disabled")
	--self.text:SetColour(.7,.7,.7,1)
end

return AnimButton