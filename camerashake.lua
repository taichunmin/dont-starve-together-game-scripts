local easing = require("easing")
--
-- Adapted from
-- Shank2 / Ninja CameraShake.cpp
--

local ShakeDeltas =
{
    [CAMERASHAKE.FULL] =
    {
    	--------------------------------------------------------------------------
    	--     4
    	--  7     1
    	-- 2   S   6
    	--  5     3
    	--     0
    	--------------------------------------------------------------------------
    	Vector3( 0,-1):GetNormalized(),
    	Vector3( 1, 1):GetNormalized(),
    	Vector3(-1, 0):GetNormalized(),
    	Vector3( 1,-1):GetNormalized(),
    	Vector3( 0, 1):GetNormalized(),
    	Vector3(-1,-1):GetNormalized(),
    	Vector3( 1, 0):GetNormalized(),
    	Vector3(-1, 1):GetNormalized(),
    },

    [CAMERASHAKE.SIDE] =
    {
    	--------------------------------------------------------------------------
    	-- 0   S   1
    	--------------------------------------------------------------------------
    	Vector3(-1, 0):GetNormalized(),
    	Vector3( 1, 0):GetNormalized(),
    },

    [CAMERASHAKE.VERTICAL] =
    {
    	--------------------------------------------------------------------------
    	--     0
    	--     S
    	--     1
    	--------------------------------------------------------------------------
    	Vector3( 0, 1):GetNormalized(),
    	Vector3( 0,-1):GetNormalized(),
    },
}

CameraShake = Class(function(self, mode, duration, speed, scale)
    self:StopShaking()
    --TheInputProxy:RemoveVibration(VIBRATION_CAMERA_SHAKE)

    self.mode = mode or CAMERASHAKE.FULL
    self.duration = duration or 1
    self.speed = speed or 0.05
    self.scale = scale or 1
end)

function CameraShake:StopShaking()
    --TheInputProxy:RemoveVibration(VIBRATION_CAMERA_SHAKE)
    self.currentTime = 0
    self.duration = 0
    self.speed = 0
    self.scale = 1
    self.mode = nil
end

function CameraShake:Update(dt)

    if self.mode == nil or self.speed == 0 or self.duration == 0 then
        self:StopShaking()
        return
    end

    self.currentTime = self.currentTime + dt

    if self.currentTime > self.duration + 2*self.speed then
        self:StopShaking()
        return
    end

    local shakeDeltas = ShakeDeltas[self.shakeType] or ShakeDeltas[CAMERASHAKE.FULL]

    local fromPos = nil
    local toPos = nil

    if self.currentTime < self.speed then
        fromPos = Vector3()
        toPos = shakeDeltas[1]
    elseif self.currentTime >= self.duration + self.speed then
        local last = math.floor(self.duration/self.speed) % #shakeDeltas
        fromPos = shakeDeltas[last+1]
        toPos = Vector3()
    else
        local fromIndex = math.floor( (self.currentTime - self.speed)/self.speed) % #shakeDeltas
        local toIndex = (fromIndex+1) % #shakeDeltas
        fromIndex = fromIndex + 1
        toIndex = toIndex + 1
        fromPos = shakeDeltas[fromIndex]
        toPos = shakeDeltas[toIndex]
    end

    local t = self.currentTime / self.speed - math.floor(self.currentTime/self.speed)
    local scale = easing.linear(self.currentTime, self.scale, -self.scale, self.duration)
    local shakeDelta = (fromPos*(1-t) + toPos*t) * scale
    return shakeDelta
end