--this is called back by the engine side

PhysicsCollisionCallbacks = {}
function OnPhysicsCollision(guid1, guid2)
    local i1 = Ents[guid1]
    local i2 = Ents[guid2]

    if PhysicsCollisionCallbacks[guid1] then
        PhysicsCollisionCallbacks[guid1](i1, i2)
    end

    if PhysicsCollisionCallbacks[guid2] then
        PhysicsCollisionCallbacks[guid2](i2, i1)
    end
end

function Launch(inst, launcher, basespeed)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = launcher.Transform:GetWorldPosition()
        local vx, vz = x - x1, z - z1
        local spd = math.sqrt(vx * vx + vz * vz)
        if spd ~= nil then
            --normalize
            vx, vz = vx / spd, vz / spd
        end
        local angle = math.atan2(vz, vx) + (math.random() * 20 - 10) * DEGREES
        spd = (basespeed or 5) + math.random() * 2
        inst.Physics:Teleport(x, .1, z)
        inst.Physics:SetVel(math.cos(angle) * spd, 10, math.sin(angle) * spd)
    end
end

function LaunchAt(inst, launcher, target, speedmult, startheight, startradius)
    if inst ~= nil and inst.Physics ~= nil and inst.Physics:IsActive() and launcher ~= nil then
        local x, y, z = launcher.Transform:GetWorldPosition()
        local angle
        if target ~= nil then
            angle = (150 + math.random() * 60 - target:GetAngleToPoint(x, 0, z)) * DEGREES
        else
            local down = TheCamera:GetDownVec()
            angle = math.atan2(down.z, down.x) + (math.random() * 60 - 30) * DEGREES
        end
        local sina, cosa = math.sin(angle), math.cos(angle)
        local spd = (math.random() * 2 + 1) * (speedmult or 1)
        inst.Physics:Teleport(x + (startradius or 0) * cosa, startheight or .1, z + (startradius or 0) * sina)
        inst.Physics:SetVel(spd * cosa, math.random() * 2 + 4 + 2 * (speedmult or 1), spd * sina)
    end
end
