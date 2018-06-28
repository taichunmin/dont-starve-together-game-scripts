RunAway = Class(BehaviourNode, function(self, inst, hunterparams, see_dist, safe_dist, fn, runhome, fix_overhang)
    BehaviourNode._ctor(self, "RunAway")
    self.safe_dist = safe_dist
    self.see_dist = see_dist
    if type(hunterparams) == "string" then
        self.huntertags = { hunterparams }
        self.hunternotags = { "NOCLICK" }
    elseif type(hunterparams) == "table" then
        self.hunterfn = hunterparams.fn
        self.huntertags = hunterparams.tags
        self.hunternotags = hunterparams.notags
        self.hunteroneoftags = hunterparams.oneoftags
    else
        self.hunterfn = hunterparams
    end
    self.inst = inst
    self.runshomewhenchased = runhome
    self.shouldrunfn = fn
	self.fix_overhang = fix_overhang -- this will put the point check back on land if self.inst is stepping on the ocean overhang part of the land
end)

function RunAway:__tostring()
    return string.format("RUNAWAY %f from: %s", self.safe_dist, tostring(self.hunter))
end

function RunAway:GetRunAngle(pt, hp)
    if self.avoid_angle ~= nil then
        local avoid_time = GetTime() - self.avoid_time
        if avoid_time < 1 then
            return self.avoid_angle
        else
            self.avoid_time = nil
            self.avoid_angle = nil
        end
    end

    local angle = self.inst:GetAngleToPoint(hp) + 180 -- + math.random(30)-15
    if angle > 360 then
        angle = angle - 360
    end

    --print(string.format("RunAway:GetRunAngle me: %s, hunter: %s, run: %2.2f", tostring(pt), tostring(hp), angle))

    local radius = 6

    local result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, false) -- try avoiding walls
    if result_angle == nil then
        result_offset, result_angle, deflected = FindWalkableOffset(pt, angle*DEGREES, radius, 8, true, true) -- ok don't try to avoid walls, but at least avoid water
        if result_angle == nil then
			if self.fix_overhang and not TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
				local back_on_ground = FindNearbyLand(pt, 1) -- find a point back on proper ground
				if back_on_ground ~= nil then
			        result_offset, result_angle, deflected = FindWalkableOffset(back_on_ground, math.random()*2*math.pi, radius - 1, 8, true, true) -- ok don't try to avoid walls, but at least avoid water
				end
			end
			if result_angle == nil then
	            return angle -- ok whatever, just run
			end
        end
    end

    result_angle = result_angle / DEGREES
    if deflected then
        self.avoid_time = GetTime()
        self.avoid_angle = result_angle
    end
    return result_angle
end

function RunAway:Visit()
    if self.status == READY then
        self.hunter = FindEntity(self.inst, self.see_dist, self.hunterfn, self.huntertags, self.hunternotags, self.hunteroneoftags)

        if self.hunter ~= nil and self.shouldrunfn ~= nil and not self.shouldrunfn(self.hunter) then
            self.hunter = nil
        end

        self.status = self.hunter ~= nil and RUNNING or FAILED
    end

    if self.status == RUNNING then
        if self.hunter == nil or not self.hunter.entity:IsValid() then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
        else
            if self.runshomewhenchased and
                self.inst.components.homeseeker ~= nil then
                self.inst.components.homeseeker:GoHome(true)
            else
                local pt = self.inst:GetPosition()
                local hp = self.hunter:GetPosition()

                local angle = self:GetRunAngle(pt, hp)
                if angle ~= nil then
                    self.inst.components.locomotor:RunInDirection(angle)
                else
                    self.status = FAILED
                    self.inst.components.locomotor:Stop()
                end

                if distsq(hp, pt) > self.safe_dist * self.safe_dist then
                    self.status = SUCCESS
                    self.inst.components.locomotor:Stop()
                end
            end

            self:Sleep(.25)
        end
    end
end
