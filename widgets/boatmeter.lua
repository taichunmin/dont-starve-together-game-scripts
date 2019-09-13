local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"

local BOAT_TINT = { 21 / 255, 102 / 255, 117 / 255, 1 }

-------------------------------------------------------------------------------------------------------

local BoatMeter = Class(Widget, function(self)
    Widget._ctor(self, "BoatMeter")

    --self.bg clashes with existing mods
    self.backing = self:AddChild(UIAnim())
    self.backing:GetAnimState():SetBank("status_meter")
    self.backing:GetAnimState():SetBuild("status_meter")
    self.backing:GetAnimState():PlayAnimation("bg")
    self.backing:SetClickable(true)

    self.badge = self:AddChild(UIAnim())
    self.badge:GetAnimState():SetBank("status_meter")
    self.badge:GetAnimState():SetBuild("status_meter")
    self.badge:GetAnimState():SetMultColour(unpack(BOAT_TINT))
    self.badge:SetClickable(true)

    self.icon = self:AddChild(UIAnim())
    self.icon:GetAnimState():SetBank("status_meter")
    self.icon:GetAnimState():SetBuild("status_boat")
    self.icon:GetAnimState():Hide("frame")
    self.icon:SetClickable(true)

    self.leak_anim = self:AddChild(UIAnim())
    self.leak_anim:GetAnimState():SetBank("status_boat")
    self.leak_anim:GetAnimState():SetBuild("status_boat")
    self.leak_anim:SetClickable(false)

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("status_boat")
    self.anim:GetAnimState():SetBuild("status_boat")
    self.anim:GetAnimState():OverrideSymbol("frame_circle", "status_meter", "frame_circle")
    self.anim:SetClickable(false)

    self.anim.inst:ListenForEvent("animover", function() self.inst:PushEvent("animover") end)

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, 0, 0)
    self.num:SetClickable(false)
    self.num:Hide()

    self.inst:SetStateGraph("SGboatmeter")
    self.previous_health_percent = 1

    self.refresh_health_cb = function() self:RefreshHealth() end
    self.is_leaking = false
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

    local pct = 1 - new_health_percent
    self.badge:GetAnimState():SetPercent("anim", pct)
    self.icon:GetAnimState():SetPercent("frame", pct)
    self.num:SetString(math.ceil(self.boat.components.healthsyncer.max_health * new_health_percent))
end

local function OnPulseOver(inst, self)
    self.pulsetask = nil
    self.backing:GetAnimState():SetMultColour(1, 1, 1, 1)
    self.badge:GetAnimState():SetMultColour(unpack(BOAT_TINT))
    self.icon:GetAnimState():SetMultColour(1, 1, 1, 1)
    self.leak_anim:GetAnimState():SetMultColour(1, 1, 1, 1)
end

function BoatMeter:PulseRed()
    self.backing:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.badge:GetAnimState():SetMultColour(BOAT_TINT[1], 0, 0, 1)
    self.icon:GetAnimState():SetMultColour(1, 0, 0, 1)
    self.leak_anim:GetAnimState():SetMultColour(1, 0, 0, 1)
    if self.pulsetask ~= nil then
        self.pulsetask:Cancel()
    end
    self.pulsetask = self.inst:DoTaskInTime(.2, OnPulseOver, self)
end

return BoatMeter
