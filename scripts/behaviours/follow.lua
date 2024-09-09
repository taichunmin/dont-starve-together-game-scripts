Follow = Class(BehaviourNode, function(self, inst, target, min_dist, target_dist, max_dist, canrun, alwayseval, inlimbo_invalid)
    BehaviourNode._ctor(self, "Follow")
    self.inst = inst
    self.target = target

	if type(min_dist) == "function" then
		self.min_dist_fn = min_dist
		self.min_dist = nil
	else
	    self.min_dist = min_dist
	end

	if type(max_dist) == "function" then
		self.max_dist_fn = max_dist
		self.max_dist = nil
	else
	    self.max_dist = max_dist
	end

	if type(target_dist) == "function" then
		self.target_dist_fn = target_dist
		self.target_dist = nil
	else
	    self.target_dist = target_dist
	end

    self.canrun = canrun ~= false
    self.alwayseval = alwayseval ~= false
    self.inlimbo_invalid = inlimbo_invalid
    self.currenttarget = nil
    self.action = "STAND"
end)

function Follow:GetTarget()
    local target = FunctionOrValue(self.target, self.inst)
    return target ~= nil and target:IsValid() and target or nil
end

function Follow:EvaluateDistances() -- this is run once per follow target
	if self.min_dist_fn ~= nil then
		self.min_dist = self.min_dist_fn(self.inst)
	end
	if self.max_dist_fn ~= nil then
		self.max_dist = self.max_dist_fn(self.inst)
	end
	if self.target_dist_fn ~= nil then
		self.target_dist = self.target_dist_fn(self.inst)
	end
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

function Follow:AreDifferentPlatforms(inst, target)
    if self.inst.components.locomotor.allow_platform_hopping then
        return inst:GetCurrentPlatform() ~= target:GetCurrentPlatform()
    end
    return false
end

function Follow:Visit()
    --cached in case we need to use this multiple times
    local dist_sq, target_pos

    if self.status == READY then
		local prev_target = self.currenttarget
        self.currenttarget = self:GetTarget()
        if self.currenttarget ~= nil then
            dist_sq, target_pos = _distsq(self.inst, self.currenttarget)

			if prev_target ~= self.currenttarget or self.alwayseval then
				self:EvaluateDistances()
			end

            local on_different_platforms = self:AreDifferentPlatforms(self.inst, self.currenttarget)

            if not on_different_platforms and dist_sq < self.min_dist * self.min_dist then
                self.status = RUNNING
                self.action = "BACKOFF"
            elseif on_different_platforms or dist_sq > self.max_dist * self.max_dist then
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
            or (self.currenttarget.components.health ~= nil and self.currenttarget.components.health:IsDead())
            or (self.inlimbo_invalid and self.currenttarget:IsInLimbo())
        then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
            return
        end

        if self.action == "APPROACH" then
            if dist_sq == nil then
                dist_sq, target_pos = _distsq(self.inst, self.currenttarget)
            end

            local different_platforms = self:AreDifferentPlatforms(self.inst, self.currenttarget)

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
