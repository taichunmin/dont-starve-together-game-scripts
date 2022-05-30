--local easing = require("easing")

local Circler = Class(function(self, inst)
    self.inst = inst

    self.scale = 1
    self.speed = math.random(3)
    self.circleTarget = nil

    self.minSpeed = 5
    self.maxSpeed = 7

    self.minDist = 8
    self.maxDist = 20

    self.minScale = 8
    self.maxScale = 12

    self.onaccelerate = nil
    self.numAccelerates = 0

    self.sineMod = math.random(20, 30) * .001
    self.sine = 0
end)

function Circler:Start()
    if self.circleTarget == nil or not self.circleTarget:IsValid() then
        self.circleTarget = nil
        return
    end

    self.speed = math.random(self.minSpeed, self.maxSpeed) * .01
    self.distance = math.random(self.minDist, self.maxDist)
    self.angleRad = math.random() * 2 * PI
    self.offset = Vector3(self.distance * math.cos(self.angleRad), 0, -self.distance * math.sin(self.angleRad))
    self.facingAngle = self.angleRad * RADIANS

    self.direction = (math.random() < .5 and .5 or -.5) * PI
    self.facingAngle = (math.atan2(self.offset.x, self.offset.z) + self.direction) * RADIANS

    local x, y, z = self.circleTarget.Transform:GetWorldPosition()
    self.inst.Transform:SetRotation(self.facingAngle)
    self.inst.Transform:SetPosition(x + self.offset.x, 0, z + self.offset.z)
    self.inst:StartUpdatingComponent(self)
end

function Circler:Stop()
    self.inst:StopUpdatingComponent(self)
end

function Circler:SetCircleTarget(tar)
    self.circleTarget = tar
end

function Circler:GetSpeed(dt)
    local speed = self.speed * 2 * PI * dt
    return self.direction > 0 and -speed or speed
end

function Circler:GetMinSpeed()
    return self.minSpeed * .01
end

function  Circler:GetMaxSpeed()
    return self.maxSpeed * .01
end

function Circler:GetMinScale()
    return self.minScale * .1
end

function  Circler:GetMaxScale()
    return self.maxScale * .1
end

function Circler:GetDebugString()
    return string.format("Sine: %4.4f, Speed: %3.3f/%3.3f", self.sine, self.speed, self:GetMaxSpeed())
end

function Circler:OnUpdate(dt)
    if self.circleTarget == nil or not self.circleTarget:IsValid() then
        self:Stop()
        self.circleTarget = nil
        return
    end

    self.sine = GetSineVal(self.sineMod, true, self.inst)

    --self.speed = easing.inExpo(self.sine, self:GetMinSpeed(), self:GetMaxSpeed() - self:GetMinSpeed() , 1)
    self.speed = Lerp(self:GetMinSpeed() - .003, self:GetMaxSpeed() + .003, self.sine)
    self.speed = math.clamp(self.speed, self:GetMinSpeed(), self:GetMaxSpeed())

    self.scale = Lerp(self:GetMaxScale(), self:GetMinScale(), (self.speed - self:GetMinSpeed())/(self:GetMaxSpeed() - self:GetMinSpeed()))
    self.inst.Transform:SetScale(self.scale, self.scale, self.scale)

    self.angleRad = self.angleRad + self:GetSpeed(dt)

    self.offset = Vector3(self.distance * math.cos(self.angleRad), 0, -self.distance * math.sin(self.angleRad))

    self.facingAngle = (math.atan2(self.offset.x, self.offset.z) + self.direction) * RADIANS

    local x, y, z = self.circleTarget.Transform:GetWorldPosition()
    self.inst.Transform:SetRotation(self.facingAngle)
    self.inst.Transform:SetPosition(x + self.offset.x, 0, z + self.offset.z)
end

Circler.OnEntitySleep = Circler.Stop
Circler.OnEntityWake = Circler.Start

return Circler
