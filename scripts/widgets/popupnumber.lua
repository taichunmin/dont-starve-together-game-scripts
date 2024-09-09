local Widget = require "widgets/widget"
local Text = require "widgets/text"

local PopupNumber = Class(Widget, function(self, owner, val, size, pos, height, colour, burst)
    Widget._ctor(self, "PopupNumber")
    self.owner = owner
    self.text = self:AddChild(Text(NUMBERFONT, size, val ~= nil and tostring(val) or nil))
    self.pos = pos
    self.colour = colour
    self.xoffs = math.random() * 8 - 4
    self.yoffs = math.random() * 4 - 2 + height
    self.xoffs2 = 0
    self.yoffs2 = 0
    self.dir = (self.xoffs < 0 or (self.xoffs == 0 and math.random() < .5)) and -1 or 1
    self.rise = 8
    self.drop = 24
    self.speed = 68
    self.progress = 0
    self.burst = burst
    self:SetClickable(false)
    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:StartUpdating()
    self:OnUpdate(0)
end)

function PopupNumber:OnUpdate(dt)
    if self.progress < 1 then
        self.progress = math.min(1, self.progress + dt * 8)

        local k = 1 - math.min(1, self.progress / .75)
        k = k * k
        self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * (1 - k * k))

        k = 1 - self.progress
        k = k * k
        k = 1 - k * k
        self.xoffs2 = self.xoffs2 + dt * self.dir * self.speed
        self.yoffs2 = k * self.rise

        if self.burst then
            local s = 2 - k
            self:SetScale(s, s)
        end

    elseif self.progress < 2 then
        self.progress = math.min(2, self.progress + dt * 3)

        local k = math.max(0, self.progress - 1.1) / .9
        self.text:SetColour(self.colour[1], self.colour[2], self.colour[3], self.colour[4] * (1 - k * k))

        k = self.progress - 1
        self.xoffs2 = self.xoffs2 + dt * self.dir * self.speed
        self.yoffs2 = self.rise - self.drop * k * k
    else
        self:Kill()
        return
    end

    self:SetPosition(TheSim:GetScreenPos(self.pos:Get()))
    self.text:SetPosition(self.xoffs + self.xoffs2, self.yoffs + self.yoffs2)
end

return PopupNumber
