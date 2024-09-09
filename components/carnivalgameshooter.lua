local easing = require("easing")

local CarnivalGameShooter = Class(function(self, inst)
    self.inst = inst
	
	-- self.angle = nil
	-- self.power = nil
	-- self.meterdirection = nil
end)

function CarnivalGameShooter:Initialize()
	self.angle = (TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN + TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX)/2
	self.power = TUNING.CARNIVALGAME_SHOOTING_POWER
	self.meterdirection = 1
end

function CarnivalGameShooter:UpdateAiming(dt)
	self.angle = self.angle + dt * TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_SPEED * self.meterdirection

	-- Move up or down if we've reached an angle extreme
	if self.angle <= TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN then
		self.meterdirection = 1
		self.angle = TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MIN
	elseif self.angle >= TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX then
		self.meterdirection = -1
		self.angle = TUNING.CARNIVALGAME_SHOOTING_ANGLE_METER_MAX
	end

	return self.angle, self.meterdirection
end

function CarnivalGameShooter:SetAim()
	self.inst.SoundEmitter:PlaySound("summerevent/cannon/place", nil, nil, true)
end

function CarnivalGameShooter:Shoot()
	local x, y, z = self.inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("carnivalgame_shooting_projectile")
	projectile.shooter = self.inst
	
	local angle = -((self.angle + 90)/TUNING.CARNIVALGAME_SHOOTING_TARGET_ARC_X) * DEGREES
	local r = TUNING.CARNIVALGAME_SHOOTING_TARGET_ARC_R
	local sin_rot = math.sin(angle) * TUNING.CARNIVALGAME_SHOOTING_TARGET_ARC_X
	local cos_rot = math.cos(angle)
	local targetpos = Vector3(r * cos_rot, 0, r * sin_rot)

	targetpos.x, targetpos.z = VecUtil_RotateDir(targetpos.x, targetpos.z, (self.inst.Transform:GetRotation()) * -DEGREES)

	local startpos = targetpos:GetNormalized()
    projectile.Transform:SetPosition(startpos.x + x, y + 1, startpos.z + z)
	
	targetpos.x = targetpos.x + x
	targetpos.z = targetpos.z + z

    projectile.components.complexprojectile:SetHorizontalSpeed(20)
    projectile.components.complexprojectile:SetGravity(-40)
    projectile.components.complexprojectile:Launch(targetpos, self.inst)
end

return CarnivalGameShooter
