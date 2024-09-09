
local WANDER_AWAY_DIST = 100


function GetWanderAwayPoint(pt)
    local theta = math.random() * TWOPI
    local radius = WANDER_AWAY_DIST

    local ground = TheWorld

    -- Walk the circle trying to find a valid spawn point
    local steps = 12
    for i = 1, 12 do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset
        local wx, wy, wz = wander_point:Get()
        if ground.Map:IsPassableAtPoint(wx, wy, wz, false, true) and
            ground.Pathfinder:IsClear(
                pt.x, pt.y, pt.z,
                wander_point.x, wander_point.y, wander_point.z,
                { ignorewalls = true }) then
            return wander_point
        end
        theta = theta - (TWOPI / steps)
    end
end

