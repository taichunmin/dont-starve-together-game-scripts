local easing = require("easing")

local SPEED_VAR_PERIOD = 5
local SPEED_VAR_PERIOD_VARIANCE = 2

local BlowInWind = Class(function(self, inst)

    self.inst = inst

	self.maxSpeedMult = 1.5
	self.minSpeedMult = .5
	self.averageSpeed = (TUNING.WILSON_RUN_SPEED + TUNING.WILSON_WALK_SPEED)/2
	self.speed = 0

	self.windAngle = 0
	self.windVector = Vector3(0,0,0)

	self.currentAngle = 0
	self.currentVector = Vector3(0,0,0)

	self.velocity = Vector3(0,0,0)

	self.speedVarTime = 0
	self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)

	self.soundParameter = nil
	self.soundName = nil

	-- self.sineMod = math.random(20, 30) * 0.001
	-- self.sine = 0
end)

function BlowInWind:OnEntitySleep()
	self:Stop()
end

function BlowInWind:OnEntityWake()
	self:Start(self.windAngle, self.velocMult)
end

function BlowInWind:StartSoundLoop()
    if self.inst.SoundEmitter ~= nil and
        self.soundPath ~= nil and
        self.soundName ~= nil and
        not (self.inst.SoundEmitter:PlayingSound(self.soundName) or self.inst:IsAsleep()) then
        self.inst.SoundEmitter:PlaySound(self.soundPath, self.soundName)
    end
end

function BlowInWind:StopSoundLoop()
    if self.inst.SoundEmitter ~= nil and self.soundName ~= nil then
        self.inst.SoundEmitter:KillSound(self.soundName)
    end
end

function BlowInWind:Start(ang, vel)
	if ang then
		self.windAngle = ang
		self.windVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
		self.currentAngle = ang
		self.currentVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
		self.inst.Transform:SetRotation(self.currentAngle)
	end
	if vel then self.velocMult = vel end
    self:StartSoundLoop()
	self.inst:StartUpdatingComponent(self)
end

function BlowInWind:Stop()
    self:StopSoundLoop()
	self.inst:StopUpdatingComponent(self)
end

function BlowInWind:ChangeDirection(ang, vel)
	if ang then
		self.windAngle = ang
		self.windVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
	end
	--if vel then self.velocMult = vel end
end

function BlowInWind:SetMaxSpeedMult(spd)
	if spd then self.maxSpeedMult = spd end
end

function BlowInWind:SetMinSpeedMult(spd)
	if spd then self.minSpeedMult = spd end
end

function BlowInWind:SetAverageSpeed(spd)
	if spd then self.averageSpeed = spd end
end

function BlowInWind:GetSpeed()
	return self.speed
end

function  BlowInWind:GetVelocity()
	return self.velocity
end

function BlowInWind:GetDebugString()
	--return string.format("Sine: %4.4f, Speed: %3.3f/%3.3f", self.sine, self.speed, self:GetMaxSpeed())
end

function BlowInWind:OnUpdate(dt)

	if not self.inst then
		self:Stop()
		return
	end

	self.velocity = self.velocity + (self.windVector * dt)

	if self.velocity:Length() > 1 then self.velocity = self.velocity:GetNormalized() end

	-- Map velocity magnitudes to a useful range of walkspeeds
	local curr_speed = self.averageSpeed
	--[[local player = ThePlayer
	if player and player.components.locomotor then
		curr_speed = (player.components.locomotor:GetRunSpeed() + TUNING.WILSON_WALK_SPEED) / 2
	end]]
	self.speed = Remap(self.velocity:Length(), 0, 1, 0, curr_speed) --maybe only if changing dir??

	-- Do some variation on the speed if velocity is a reasonable amount
	if self.velocity:Length() >= .5 then
		self.speedVarTime = self.speedVarTime + dt
		if self.speedVarTime > SPEED_VAR_PERIOD then
			self.speedVarTime = 0
			self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)
		end
		local speedvar = math.sin(2*PI*(self.speedVarTime / self.speedVarPeriod))
		local mult = Remap(speedvar, -1, 1, self.minSpeedMult, self.maxSpeedMult)
		self.speed = self.speed * mult
	end

	-- Change the sound parameter if there is one
	if self.soundName and self.soundParameter and self.inst.SoundEmitter then
		-- Might just be able to use self.velocity:Length() here?
		self.soundspeed = Remap(self.speed, 0, curr_speed*self.maxSpeedMult, 0, 1)
        if self.inst.SoundEmitter:PlayingSound(self.soundName) then
            self.inst.SoundEmitter:SetParameter(self.soundName, self.soundParameter, self.soundspeed)
        end
	end

	-- Walk!
	if self.inst.components.locomotor then
		self.inst.components.locomotor.walkspeed = self.speed
		self.currentAngle = math.atan2(self.velocity.z, self.velocity.x)/DEGREES
		self.inst.Transform:SetRotation(self.currentAngle)
		self.inst.components.locomotor:WalkForward(true)
	end
end

return BlowInWind
