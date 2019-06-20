local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local easing = require("easing")

local ALPHAMULT_LOW = .25
local ALPHAMULT_EASEIN_TIME = .5
local ALPHAMULT_EASEOUT_TIME = .25

local FireOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FireOver")
    self.anim = self:AddChild(UIAnim())
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)

    self:SetClickable(false)
    self.anim:GetAnimState():SetBank("fire_over")
    self.anim:GetAnimState():SetBuild("fire_over")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_TOP)
    self.targetalpha = 0
    self.startalpha = 0
    self.alpha = 0
    self.alphamult = 1
    self.alphamultdir = 0
    self:Hide()
    self.ease_time = .4
    self.t = 0
    self.anim:GetAnimState():SetMultColour(1, 1, 1, 0)

    self.inst:ListenForEvent("startfiredamage", function(owner, data) self:TurnOn(data ~= nil and data.low) end, self.owner)
    self.inst:ListenForEvent("stopfiredamage", function() self:TurnOff() end, self.owner)
    self.inst:ListenForEvent("changefiredamage", function(owner, data) self:OnChangeLevel(data ~= nil and data.low) end, self.owner)
    self.inst:ListenForEvent("onremove", function() self:TurnOff() end)
end)

function FireOver:TurnOn(low)
    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/wilson/burned", nil, low and .23 or nil)
    if self.targetalpha ~= 1 then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/campfire", "burning")
        TheFocalPoint.SoundEmitter:SetParameter("burning", "intensity", low and .5 or 1)
        self.targetalpha = 1
    end
    self.ease_time = 2
    self.startalpha = 0
    self.t = 0
    self.alpha = 0
    self.alphamult = low and ALPHAMULT_LOW or 1
    self.alphamultdir = 0
    self:StartUpdating()
end

function FireOver:TurnOff()
    if self.targetalpha ~= 0 then
        TheFocalPoint.SoundEmitter:KillSound("burning")
        self.targetalpha = 0
    end
    self.ease_time = 1
    self.startalpha = 1
    self.t = 0
    self.alpha = 1
end

function FireOver:OnChangeLevel(low)
    if TheFocalPoint.SoundEmitter:PlayingSound("burning") then
        if low then
            self.alphamultdir = -1
            self.alphamult = math.max(ALPHAMULT_LOW, self.alphamult + FRAMES * .5 * (ALPHAMULT_LOW - 1) / ALPHAMULT_EASEOUT_TIME)
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/fireOut", nil, .66)
        else
            self.alphamultdir = 1
            self.alphamult = math.min(1, self.alphamult + FRAMES * .5 * (1 - ALPHAMULT_LOW) / ALPHAMULT_EASEIN_TIME)
            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/wilson/burned", nil, .66)
        end
    end
end

function FireOver:OnUpdate(dt)
    self.t = self.t + dt
    self.alpha = math.clamp(easing.outCubic(self.t, self.startalpha, self.targetalpha - self.startalpha, self.ease_time), 0, 1)
    if self.alphamultdir == 0 or self.alphamult >= 1 or self.alphamult <= ALPHAMULT_LOW then
        self.alphamultdir = 0
    elseif self.alphamultdir > 0 then
        self.alphamult = math.min(1, self.alphamult + dt * (1 - ALPHAMULT_LOW) / ALPHAMULT_EASEIN_TIME)
    else--if self.alphamultdir < 0 then --redundant check
        self.alphamult = math.max(ALPHAMULT_LOW, self.alphamult + dt * (ALPHAMULT_LOW - 1) / ALPHAMULT_EASEOUT_TIME)
    end
    self.anim:GetAnimState():SetMultColour(1, 1, 1, self.alpha * self.alphamult)
    if self.alpha <= 0 then
        self:Hide()
        self:StopUpdating()
    else
        self:Show()
    end
end

return FireOver
