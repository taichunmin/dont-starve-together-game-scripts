local function on_death(inst)
    inst.components.boatring:OnDeath()
end

local BoatRing = Class(function(self, inst)
    self.inst = inst
    self.rotationdirection = 0
    self.rotate_speed = 0.5
    self.max_rotate_speed = 2
    self.updating = false

    assert(inst.components.boatringdata ~= nil, "missing boatringdata component")

    self.boatbumpers = {}

    self.rotators = {}
    self.onrotationchanged = function(inst, direction)
        if direction == nil then
            return
        end

        for i, rotator in ipairs(self.rotators) do
            if direction ~= 0 then
                rotator.inst.sg.mem.direction = direction
                rotator.inst.sg:GoToState("on")
            else
                rotator.inst.sg:GoToState("off")
            end
        end
    end

    --"onignite" doesn't work; boat does not have burnable component
    --self.inst:ListenForEvent("onignite", function() print("onignite") self:OnIgnite() end)
    self.inst:ListenForEvent("death", on_death)
    self.inst:ListenForEvent("rotationdirchanged", self.onrotationchanged)
end)

function BoatRing:GetRadius()
    return self.inst.components.boatringdata:GetRadius()
end

function BoatRing:GetNumSegments()
    return self.inst.components.boatringdata:GetNumSegments()
end

function BoatRing:SetRotationDirection(dir)
    self.rotationdirection = dir

    local isrotating = dir ~= 0
    self.inst.components.boatringdata:SetIsRotating(isrotating)

    if isrotating then
        if not self.updating then
            self.updating = true
            self.inst:StartUpdatingComponent(self)
        end
    elseif self.updating then
        self.updating = false
        self.inst:StopUpdatingComponent(self)
    end
end

function BoatRing:GetRotationDirection()
    return self.rotationdirection
end

function BoatRing:AddBumper(bumper)
    table.insert(self.boatbumpers, bumper)
end

function BoatRing:RemoveBumper(bumper)
    table.removearrayvalue(self.boatbumpers, bumper)
end

function BoatRing:AddRotator(rotator)
    table.insert(self.rotators, rotator)
end

function BoatRing:RemoveRotator(rotator)
    table.removearrayvalue(self.rotators, rotator)
end

function BoatRing:GetBumperAtPoint(x, z)
    -- Search through all bumpers until we find one that's covering (x, z)
    local boatposition = self.inst:GetPosition()
    local boatsegments = self.inst.components.boatringdata:GetNumSegments()

    for i, bumper in ipairs(self.boatbumpers) do
        local forward = bumper:GetPosition() - boatposition

        local segmentwidth = (boatsegments > 0 and 360 / boatsegments or 360) / RADIANS
        local testpos = Vector3(x, 0, z)
        if bumper:IsValid() and IsWithinAngle(boatposition, forward, segmentwidth, testpos) then
            return bumper
        end
    end

    return nil
end

function BoatRing:OnDeath()
    self.inst.SoundEmitter:KillSound("boat_movement")
end

function BoatRing:OnUpdate(dt)
    -- Rotate the actual boat
    -- If no rotators but still rotating, set the num rotators to 1 to simulate a malfunctioning boat
    local numrotators = math.max(1, #self.rotators)
    local speed = math.min(numrotators * self.rotate_speed, self.max_rotate_speed)
    local angle = ReduceAngle(self.inst.Transform:GetRotation() + speed * self.rotationdirection)
    self.inst.Transform:SetRotation(angle)
end

function BoatRing:OnSave()
    return
    {
        rotationdirection = self.rotationdirection,
    }
end

function BoatRing:OnLoad(data)
    if data ~= nil then
        self:SetRotationDirection(data.rotationdirection or 0)
    end
end

return BoatRing
