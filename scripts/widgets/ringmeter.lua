local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local COLOUR = { 1, .55, .3, 1 }

local RingMeter = Class(Widget, function(self, owner)
    Widget._ctor(self, "PopupNumber")
    self.owner = owner
    self.meter = self:AddChild(UIAnim())
    self.meter:SetPosition(0, 30)
    self.meter:GetAnimState():SetBuild("ringmeter")
    self.meter:GetAnimState():SetBank("ringmeter")
    self.meter:GetAnimState():SetMultColour(unpack(COLOUR))
    self.meter:GetAnimState():AnimateWhilePaused(false)
    self:SetClickable(false)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
end)

function RingMeter:SetWorldPosition(pos)
    self.pos = pos
    self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))
end

function RingMeter:StartTimer(duration, starttime)
    self.t = starttime or 0
    self.duration = duration
    self:StartUpdating()
    self:OnUpdate(0)
end

function RingMeter:FadeOut(duration)
    self.fadetime = duration or .2
    self.fade = self.fadetime
    self.flash = nil
    self.flashtime = nil
    self:OnUpdate(0)
end

function RingMeter:FlashOut(duration)
    self.meter:GetAnimState():PlayAnimation("flash")
    self.meter:GetAnimState():SetMultColour(unpack(COLOUR))
    self.scaletime = duration or .5
    self.scale = self.scaletime
    self.flashtime = math.max(0, self.scaletime - self.meter:GetAnimState():GetCurrentAnimationLength())
    self.flash = self.flashtime
    self.fade = nil
    self.fadetime = nil
    self.t = self.duration
    self:OnUpdate(0)
end

function RingMeter:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))

    if self.fade ~= nil then
        self.fade = math.max(0, self.fade - dt)
        if self.fade > 0 then
            local k = self.fade / self.fadetime
            self.meter:GetAnimState():SetMultColour(COLOUR[1], COLOUR[2], COLOUR[3], COLOUR[4] * k * k)
        else
            self:Kill()
        end
    elseif self.flash ~= nil then
        self.scale = math.max(0, self.scale - dt)
        local k = self.scale / self.scaletime
        k = 1.1 - k * k * .1
        self.meter:SetScale(k, k)
        if self.meter:GetAnimState():AnimDone() then
            self.flash = math.max(0, self.flash - dt)
            if self.flash > 0 then
                k = self.flash / self.flashtime
                self.meter:GetAnimState():SetMultColour(COLOUR[1], COLOUR[2], COLOUR[3], COLOUR[4] * k * k)
            else
                self:Kill()
            end
        end
    else
        self.t = math.min(self.t + dt, self.duration)
        self.meter:GetAnimState():SetPercent("progress", self.t / self.duration)
    end
end

return RingMeter
