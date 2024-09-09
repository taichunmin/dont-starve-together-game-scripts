--Falloff, Intensity, Radius, Colour.
local SizeTweener = Class(function(self, inst)
    self.inst = inst

    self.i_size = nil
    self.t_size = nil
    self.callback = nil
    self.time = nil
    self.timepassed = nil
    self.tweening = false
end)

function SizeTweener:EndTween()
    if self.tweening then
        self.tweening = false
        self.inst:StopUpdatingComponent(self)

        self.i_size = nil
        if self.t_size ~= nil then
            self.inst.Transform:SetScale(self.t_size, self.t_size, self.t_size)
            self.t_size = nil
        end

        local cb = self.callback
        self.callback = nil
        self.time = nil
        self.timepassed = nil

        self.inst:PushEvent("sizetweener_end")

        if cb ~= nil then
            cb(self.inst)
        end
    end
end

function SizeTweener:StartTween(size, time, callback)
    self.i_size = self.inst.Transform:GetScale()
    self.t_size = size
    self.callback = callback
    self.time = time
    self.timepassed = 0
    self.tweening = true
    self.inst:PushEvent("sizetweener_start")

    if self.time > 0 then
        self.inst:StartUpdatingComponent(self)
    else
        self:EndTween()
    end
end

function SizeTweener:OnUpdate(dt)
    self.timepassed = self.timepassed + dt
    if self.timepassed >= self.time then
        self:EndTween()
    elseif self.t_size ~= nil and self.i_size ~= nil then
        local s = Lerp(self.i_size, self.t_size, self.timepassed / self.time)
        self.inst.Transform:SetScale(s, s, s)
    end
end

return SizeTweener
