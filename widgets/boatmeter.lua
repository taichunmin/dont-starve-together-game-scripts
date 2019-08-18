local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"

-------------------------------------------------------------------------------------------------------

local BoatMeter = Class(Widget, function(self)

    Widget._ctor(self, "BoatMeter")        

    --self:AddChild(self.label)

    self.badge = self:AddChild(UIAnim())
    self.badge:GetAnimState():SetBank("boat")
    self.badge:GetAnimState():SetBuild("boat_meter")
    self.badge:SetClickable(true)      

    self.leak_anim = self:AddChild(UIAnim())
    self.leak_anim:GetAnimState():SetBank("leak_arrow")
    self.leak_anim:GetAnimState():SetBuild("boat_meter_leak")
    self.leak_anim:SetClickable(false)    

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("boat")
    self.anim:GetAnimState():SetBuild("boat_meter")
    self.anim:SetClickable(false)    

    self.anim.inst:ListenForEvent("animqueueover", function() self.inst:PushEvent("animqueueover") end)

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(5, 0, 0)
    self.num:SetClickable(false)  
    self.num:Hide()  

    self.inst:SetStateGraph("SGboatmeter")
    self.previous_health_percent = 1

    self.refresh_health_cb = function() self:RefreshHealth() end
    self.is_showing_leak = false
end)

function BoatMeter:OnGainFocus()
    BoatMeter._base:OnGainFocus(self)
    self.num:Show()
end

function BoatMeter:OnLoseFocus()
    BoatMeter._base:OnLoseFocus(self)
    self.num:Hide()
end

function BoatMeter:Enable(platform)
    self.boat = platform

    self.inst:PushEvent("open_meter")

    self:RefreshHealth()

    self:StartUpdating()
end

function BoatMeter:Disable(platform)
    self.inst:PushEvent("close_meter")

    self.boat = nil

    self:StopUpdating()
end

function BoatMeter:OnUpdate(dt)
    self:RefreshHealth()
end

function BoatMeter:UpdateLeak()
    if self.boat == nil then return end
    local is_leaking = self.boat:HasTag("is_leaking")
    if self.is_leaking ~= is_leaking then
        if is_leaking then
            self.leak_anim:GetAnimState():PlayAnimation("arrow_pre")
            self.leak_anim:GetAnimState():PushAnimation("arrow_loop")
        else
            self.leak_anim:GetAnimState():PlayAnimation("arrow_pst")
        end
        self.is_leaking = is_leaking
    end
end

function BoatMeter:RefreshHealth()	  
    local new_health_percent = self.boat.components.healthsyncer:GetPercent()
    
    if self.previous_health_percent ~= new_health_percent then
        self:PulseRed()
        self.previous_health_percent = new_health_percent
    end

    self.badge:GetAnimState():SetPercent("anim", 1 - new_health_percent)    
    self.num:SetString(math.ceil(self.boat.components.healthsyncer.max_health * new_health_percent))
end

function BoatMeter:PulseRed()
    self.badge:GetAnimState():SetMultColour(1, 0.0, 0.0, 1)
    self.leak_anim:GetAnimState():SetMultColour(1, 0.0, 0.0, 1)
    self.inst:DoTaskInTime(0.2, function() 
        self.badge:GetAnimState():SetMultColour(1, 1, 1, 1) 
        self.leak_anim:GetAnimState():SetMultColour(1, 1, 1, 1) 
        end, self)
end

return BoatMeter