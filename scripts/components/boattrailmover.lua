local BoatTrailMover = Class(function(self, inst)
    self.inst = inst

    self.track_boat_time = 0.4
end)

function BoatTrailMover:Setup(dir_x, dir_z, velocity, acceleration)
	self.dir_x = -dir_x
	self.dir_z = -dir_z
    local rudder_angle = VecUtil_GetAngleInDegrees(dir_x, dir_z)

    self.velocity = velocity
    self.acceleration = acceleration

    self.inst.Transform:SetRotation(-rudder_angle + 90)

    self.inst:StartUpdatingComponent(self)
end

function BoatTrailMover:OnUpdate(dt)
	self.track_boat_time = self.track_boat_time - dt

    self.velocity = self.velocity + dt * self.acceleration

    local x, y, z = self.inst.Transform:GetWorldPosition()
    x = x + self.dir_x * self.velocity * dt
    z = z + self.dir_z * self.velocity * dt

    self.inst.Transform:SetPosition(x, y, z)
end

return BoatTrailMover