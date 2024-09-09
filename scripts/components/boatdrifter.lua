local BOAT_PHYSICS_SLEEP_DELAY = 1

local BoatDrifter = Class(function(self, inst)
    self.inst = inst

    self.is_moving = false
    self.is_drifting = false
end)

function BoatDrifter:OnRemoveEntity()
    self:StopWakeTests()
    if self.stop_boat_physics_task then
        self.stop_boat_physics_task:Cancel()
        self.stop_boat_physics_task = nil
    end
end

BoatDrifter.OnRemoveFromEntity = BoatDrifter.OnRemoveEntity

function BoatDrifter:IsMoving()
    return self.is_moving
end

function BoatDrifter:IsDrifting()
    return self:IsMoving() and self.is_drifting
end

function BoatDrifter:StartBoatPhysics()
    if self.stop_boat_physics_task then
        self.stop_boat_physics_task:Cancel()
        self.stop_boat_physics_task = nil
    else
        self.inst:StartBoatPhysics()
    end
end

function BoatDrifter:StopBoatPhysics()
    if not self.stop_boat_physics_task then
        self.stop_boat_physics_task = self.inst:DoTaskInTime(BOAT_PHYSICS_SLEEP_DELAY, self.inst.StopBoatPhysics)
    end
end

function BoatDrifter:StartWakeTests()
    self.inst.PhysicsWaker:StartWakeTests()
end

function BoatDrifter:StopWakeTests()
    self.inst.PhysicsWaker:StopWakeTests()
end

function BoatDrifter:OnStartDrifting()
    self.is_drifting = true
    if self:IsMoving() then
        self:StartWakeTests()
    end
end

function BoatDrifter:OnStopDrifting()
    self.is_drifting = false
    self:StopWakeTests()
end

function BoatDrifter:OnStopMoving()
    self.is_moving = false
    if self.inst:IsAsleep() then
        self:StopBoatPhysics()
    end
    self:StopWakeTests()
end

function BoatDrifter:OnStartMoving()
    self.is_moving = true
    if self:IsDrifting() then
        self:StartWakeTests()
    end
    self:StartBoatPhysics()
end

function BoatDrifter:OnEntitySleep()
    if not self:IsMoving() then
        self:StopBoatPhysics()
    end
end

function BoatDrifter:OnEntityWake()
    self:StartBoatPhysics()
end

return BoatDrifter
