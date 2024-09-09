local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local KitcoonPoop = Class(Widget, function(self, kit, gamescreen, profile)
    Widget._ctor(self)
    
    self:StartUpdating()
    
    self.kit = kit
    self.gamescreen = gamescreen

    self.anim = self:AddChild(UIAnim())
    self.animstate = self.anim:GetAnimState()
    self.animstate:SetBank( "kitcoon_poop" )
    self.animstate:SetBuild( "kitcoon_poop" )
    
    self.animstate:OverrideSymbol( "poop1", "kitcoon_poop", GetRandomItem( {"poop1", "poop2", "poop3", "poop4", "poop5"} ) )

	self.animstate:PlayAnimation("idle", true)
    self.animstate:SetDefaultEffectHandle("shaders/ui_anim_cc.ksh")
    self.animstate:UseColourCube(true)
    self.animstate:SetUILightParams(2.0, 4.0, 4.0, 20.0)

    self.onclick = function()
        self.animstate:PlayAnimation("poop_gone")
        self.kit:RemovePoop()
        self.gamescreen:RemovePoop(self)
        self.onclick = nil
        
        staticScheduler:ExecuteInTime( 12*FRAMES, function(inst) TheFrontEnd:GetSound():PlaySound("yotc_2022_1/kitpet/poop_splode") end )
    end

    local s = Remap( profile:GetKitSize(), 0.3, 1.2, 0.3, 0.7 ) --hacked, copied constants from kitcoonpuppet
    self.anim:SetScale(s)
end)

function KitcoonPoop:OnGainFocus()
	self._base.OnGainFocus(self)
end

function KitcoonPoop:OnUpdate(dt)    
    if self.animstate:IsCurrentAnimation("poop_gone") and self.animstate:AnimDone() then
        self:Kill()
    end
end

function KitcoonPoop:OnControl(control, down)
	if self._base.OnControl(self, control, down) then return true end

	if not down then
		if control == CONTROL_ACCEPT and self.onclick then
			self:onclick()
        end
    end
end

return KitcoonPoop
