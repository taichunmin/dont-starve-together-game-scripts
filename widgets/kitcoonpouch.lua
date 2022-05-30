local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local KitcoonPouch = Class(Widget, function(self)
    Widget._ctor(self)
    
    self.anim = self:AddChild(UIAnim())
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank( "kitcoon_pouch" )
    self.animstate:SetBuild( "kitcoon_pouch" )
    
    self.animstate:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.animstate:UseColourCube(true)
    self.animstate:SetUILightParams(2.0, 4.0, 4.0, 20.0)

    if Profile:GetKitIsHibernating() then
        self.animstate:PlayAnimation("sleep_loop", true)
    else
        self.animstate:PlayAnimation("empty", true)
    end
    self.onclick = function()
        if Profile:GetKitBuild() ~= "" then
            if Profile:GetKitIsHibernating() then
                --end the hibernation
                Profile:SetKitIsHibernating(false)

                self.kit:WakeFromHibernation()
                self.animstate:PlayAnimation("empty", true)
            else
                Profile:SetKitIsHibernating(true)
                
                self.kit:GoToHibernation( function() self.animstate:PlayAnimation("sleep_loop", true) end ) 
            end
        end
    end

    self.anim:SetScale(.3)
end)

function KitcoonPouch:SetKit( kit )
    self.kit = kit
end

function KitcoonPouch:OnGainFocus()
	self._base.OnGainFocus(self)
end

function KitcoonPouch:OnControl(control, down)
	if self._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_ACCEPT then
			self:onclick()
        end
    end
end

return KitcoonPouch
