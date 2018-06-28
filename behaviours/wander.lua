-- Parameters:
-- inst: the entity that is wandering
-- homelocation: a position or a function that gets a position. If nil, the entity won't be leashed to their home
-- max_dist: maximum distance to go away from home (if there is a home) or a function returning such
-- times: see constructor. Note that the wander distance is hard-coded - if the walk time is too long, the entity will merely stand still after reaching their target point
-- getdirectionFn: instead of picking a random direction, try to use the one returned by this function
-- setdirectionFn: use this to store the direction that was randomly chosen
Wander = Class(BehaviourNode, function(self, inst, homelocation, max_dist, times, getdirectionFn, setdirectionFn, checkpointFn)
    BehaviourNode._ctor(self, "Wander")
    self.homepos = homelocation
    self.maxdist = max_dist
    self.inst = inst
    self.far_from_home = false

    self.getdirectionFn = getdirectionFn
    self.setdirectionFn = setdirectionFn

	self.checkpointFn = checkpointFn

    self.times =
    {
        minwalktime = times and times.minwalktime or 2,
        randwalktime = times and times.randwalktime or 3,
        minwaittime = times and times.minwaittime or 1,
        randwaittime = times and times.randwaittime or 3,
    }
end)


function Wander:Visit()
    if self.status == READY then
        self.inst.components.locomotor:Stop()
        self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
        self.walking = false
        self.status = RUNNING
    elseif self.status == RUNNING then
        if not self.walking and self:IsFarFromHome() then
            self:PickNewDirection()
        end

        if GetTime() > self.waittime then
            if not self.walking then
                self:PickNewDirection()
            else
                self:HoldPosition()
            end
        else
            if not self.walking then
                self:Sleep(self.waittime - GetTime())
            else
                if not self.inst.components.locomotor:WantsToMoveForward() then
                    self:HoldPosition()
                end
            end
        end
    end
end

local function tostring_float(f)
    return f and string.format("%2.2f", f) or tostring(f)
end

function Wander:DBString()
    local w = self.waittime - GetTime()
    return string.format("%s for %2.2f, %s, %s, %s",
        self.walking and 'walk' or 'wait',
        w,
        tostring(self:GetHomePos() or false),
        tostring_float(math.sqrt(self:GetDistFromHomeSq() or 0)),
        self.far_from_home and "Go Home" or "Go Wherever")
end

function Wander:GetHomePos()
    if type(self.homepos) == "function" then 
        return self.homepos(self.inst)
    end

    return self.homepos
end

function Wander:GetDistFromHomeSq()
    local homepos = self:GetHomePos()
    return homepos and distsq(homepos, self.inst:GetPosition()) or nil
end

function Wander:IsFarFromHome()
    local homedistsq = self:GetDistFromHomeSq()
    return homedistsq ~= nil and homedistsq > self:GetMaxDistSq()
end

function Wander:GetMaxDistSq()
    if type(self.maxdist) == "function" then
        local dist = self.maxdist(self.inst)
        return dist*dist
    end

    return self.maxdist*self.maxdist
end

function Wander:Wait(t)
    self.waittime = t+GetTime()
    self:Sleep(t)
end

function Wander:PickNewDirection()
    self.far_from_home = self:IsFarFromHome()

    self.walking = true

    if self.far_from_home then
        --print("Far from home, going back")
        --print(self.inst, Point(self.inst.Transform:GetWorldPosition()), "FAR FROM HOME", self:GetHomePos())
        self.inst.components.locomotor:GoToPoint(self:GetHomePos())
    else
        local pt = Point(self.inst.Transform:GetWorldPosition())
        local angle = (self.getdirectionFn and self.getdirectionFn(self.inst)) 
       -- print("got angle ", angle) 
        if not angle then 
            angle = math.random()*2*PI
            --print("no angle, picked", angle, self.setdirectionFn)
            if self.setdirectionFn then
                --print("set angle to ", angle) 
                self.setdirectionFn(self.inst, angle)
            end
        end

        local radius = 12
        local attempts = 8
        local offset, check_angle, deflected = FindWalkableOffset(pt, angle, radius, attempts, true, false, self.checkpointFn) -- try to avoid walls
        if not check_angle then
            --print(self.inst, "no los wander, fallback to ignoring walls")
            offset, check_angle, deflected = FindWalkableOffset(pt, angle, radius, attempts, true, true, self.checkpointFn) -- if we can't avoid walls, at least avoid water
        end
        if check_angle then
            angle = check_angle
            if self.setdirectionFn then
                --print("(second case) reset angle to ", angle) 
                self.setdirectionFn(self.inst, angle)
            end
        else
            -- guess we don't have a better direction, just go whereever
            --print(self.inst, "no walkdable wander, fall back to random")
        end
        --print(self.inst, pt, string.format("wander to %s @ %2.2f %s", tostring(offset), angle/DEGREES, deflected and "(deflected)" or ""))
        if offset then
            self.inst.components.locomotor:GoToPoint(self.inst:GetPosition() + offset)
        else
            self.inst.components.locomotor:WalkInDirection(angle/DEGREES)
        end
    end

    self:Wait(self.times.minwalktime+math.random()*self.times.randwalktime)
end

function Wander:HoldPosition()
    self.walking = false
    self.inst.components.locomotor:Stop()
    self:Wait(self.times.minwaittime+math.random()*self.times.randwaittime)
end
