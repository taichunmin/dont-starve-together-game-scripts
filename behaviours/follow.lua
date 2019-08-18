Follow = Class(BehaviourNode, function(self, inst, target, min_dist, target_dist, max_dist, canrun)
    BehaviourNode._ctor(self, "Follow")
    self.inst = inst
    self.target = target
    self.min_dist = min_dist
    self.max_dist = max_dist
    self.target_dist = target_dist
    self.canrun = canrun ~= false
    self.currenttarget = nil
    self.action = "STAND"
end)

function Follow:GetTarget()
    local target = self.target
    if type(target) == "function" then
        target = target(self.inst)
    end
    return target ~= nil and target:IsValid() and target or nil
end

function Follow:DBString()
    local dist =
        self.currenttarget ~= nil and
        self.currenttarget:IsValid() and
        math.sqrt(self.currenttarget:GetDistanceSqToInst(self.inst)) or 0
    return string.format("%s %s, (%2.2f) ", tostring(self.currenttarget), self.action, dist)
end

local function _distsq(inst, targ)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = targ.Transform:GetWorldPosition()
    local dx = x1 - x
    local dy = y1 - y
    local dz = z1 - z
    --Note: Currently, this is 3D including y-component
    return dx * dx + dy * dy + dz * dz, Vector3(x1, y1, z1)
end

function Follow:AreDifferentPlatforms(my_x, my_z, target_x, target_z)
    local different_platforms = false
    if self.inst.components.locomotor.allow_platform_hopping then
        local map = TheWorld.Map
        local my_platform = map:GetPlatformAtPoint(my_x, my_z)
        local target_platform = map:GetPlatformAtPoint(target_x, target_z)
        return my_platform ~= target_platform
    end    
    return false
end

function Follow:Visit()
    --cached in case we need to use this multiple times
    local dist_sq, target_pos

    if self.status == READY then
        self.currenttarget = self:GetTarget()
        if self.currenttarget ~= nil then
            dist_sq, target_pos = _distsq(self.inst, self.currenttarget)

            local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
            local target_x, target_y, target_z = self.currenttarget.Transform:GetWorldPosition()

            local on_different_platforms = self:AreDifferentPlatforms(my_x, my_z, target_x, target_z)

            if not on_different_platforms and dist_sq < self.min_dist * self.min_dist then
                self.status = RUNNING
                self.action = "BACKOFF"
            elseif dist_sq > self.max_dist * self.max_dist or on_different_platforms then
                self.status = RUNNING
                self.action = "APPROACH"
            else
                self.status = FAILED
            end
        else
            self.status = FAILED
        end
    end

    if self.status == RUNNING then
        if self.currenttarget == nil
            or not self.currenttarget:IsValid()
            or (self.currenttarget.components.health ~= nil and
                self.currenttarget.components.health:IsDead()) then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
            return
        end

        if self.action == "APPROACH" then
            if dist_sq == nil then
                dist_sq, target_pos = _distsq(self.inst, self.currenttarget)
            end

            local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
            local target_x, target_y, target_z = self.currenttarget.Transform:GetWorldPosition()

            local different_platforms = self:AreDifferentPlatforms(my_x, my_z, target_x, target_z)

            if not different_platforms and dist_sq < self.target_dist * self.target_dist then
                self.status = SUCCESS
                return
            end

            local max_dist = self.max_dist * .75

            if different_platforms then
                max_dist = 0
            end
            if self.canrun and (dist_sq > max_dist * max_dist or self.inst.sg:HasStateTag("running")) then
                self.inst.components.locomotor:GoToPoint(target_pos, nil, true)
            else
                self.inst.components.locomotor:GoToPoint(target_pos)
            end
        elseif self.action == "BACKOFF" then
            if dist_sq == nil then
                dist_sq, target_pos = _distsq(self.inst, self.currenttarget)
            end
            if dist_sq > self.target_dist * self.target_dist then
                self.status = SUCCESS
                return
            end
            local angle = self.inst:GetAngleToPoint(target_pos)
            if self.canrun then
                self.inst.components.locomotor:RunInDirection(angle + 180)
            else
                self.inst.components.locomotor:WalkInDirection(angle + 180)
            end
        end

        self:Sleep(.25)
    end
end
