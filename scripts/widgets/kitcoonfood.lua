local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local KitcoonFood = Class(Widget, function(self, kit)
    Widget._ctor(self)
    
    self.kit = kit

    self.anim = self:AddChild(UIAnim())
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank( "kitcoon_food" )
    self.animstate:SetBuild( "kitcoon_food" )
    
	self.animstate:PlayAnimation("idle", true)
    self.animstate:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.animstate:UseColourCube(true)
    self.animstate:SetUILightParams(2.0, 4.0, 4.0, 20.0)

    self.onclick = function()
        if self.animstate:IsCurrentAnimation("idle") then
            local ok = self.kit:TryQueueEat()
            if ok then
                self.animstate:PlayAnimation("use")
                self.animstate:PushAnimation("idle", true)
                
                TheFrontEnd:GetSound():PlaySound("yotc_2022_1/kitpet/foodbag")

                staticScheduler:ExecuteInTime(0.6, function() self.kit:Eat() end)
            end
        end
    end

    self.anim:SetScale(.3)
end)

function KitcoonFood:OnGainFocus()
	self._base.OnGainFocus(self)
end

function KitcoonFood:OnControl(control, down)
	if self._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_ACCEPT then
			self:onclick()
        end
    end
end

return KitcoonFood
