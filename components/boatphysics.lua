local easing = require("easing")

local function OnCollide(inst, other, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)
    if other ~= nil and other:IsValid() and (other == TheWorld or other:HasTag("BLOCKER") or other.components.boatphysics) then

        if inst.invalid_collision_remove then
            return
        end

        --vertical collision, destroy the boat and early out to prevent NaN save corruption.
        if world_normal_on_b_x == 0 and world_normal_on_b_z == 0 then
            print("invalid boat collision, removing.")
            inst.invalid_collision_remove = true
            if inst.components.health then
                inst.components.health:Kill()
            else
                inst:Remove()
            end
            return
        end

        local boat_physics = inst.components.boatphysics

        -- Prevent multiple collisions with the same object in very short time periods ---------
        local current_tick = GetTick()
        local too_soon = false
        for id, tick in pairs(boat_physics._recent_collisions) do
            if (tick + 4 < current_tick) then
                boat_physics._recent_collisions[id] = nil
            else
                if other.GUID == id then
                    boat_physics._recent_collisions[other.GUID] = current_tick
                    too_soon = true
                end
            end
        end

        if too_soon then
            -- Instead of exiting early, we could potentially reduce damage & pushback instead.
            return
        end
        boat_physics._recent_collisions[other.GUID] = current_tick
        ----------------------------------------------------------------------------------------

    	local relative_velocity_x = boat_physics.velocity_x
    	local relative_velocity_z = boat_physics.velocity_z

    	local other_boat_physics = other.components.boatphysics
    	if other_boat_physics ~= nil then
            if other_boat_physics.cached_velocity_x and other_boat_physics.cached_velocity_z then
                relative_velocity_x = relative_velocity_x - other_boat_physics.cached_velocity_x
                relative_velocity_z = relative_velocity_z - other_boat_physics.cached_velocity_z
                other_boat_physics.cached_velocity_x = nil
                other_boat_physics.cached_velocity_z = nil
            else
                boat_physics.cached_velocity_x = relative_velocity_x
                boat_physics.cached_velocity_z = relative_velocity_z
                relative_velocity_x = relative_velocity_x - other_boat_physics.velocity_x
                relative_velocity_z = relative_velocity_z - other_boat_physics.velocity_z
            end
    	end

    	local speed = VecUtil_Length(relative_velocity_x, relative_velocity_z)

    	local velocity_normalized_x, velocity_normalized_z = relative_velocity_x, relative_velocity_z
    	if speed > 0 then
    		velocity_normalized_x, velocity_normalized_z = velocity_normalized_x / speed, velocity_normalized_z / speed
    	end

    	local hit_normal_x, hit_normal_z = VecUtil_Normalize(world_normal_on_b_x, world_normal_on_b_z)
    	local hit_dot_velocity = VecUtil_Dot(hit_normal_x, hit_normal_z, velocity_normalized_x, velocity_normalized_z)

        if not other_boat_physics then --if other is a boat, then in its OnCollide callback it will push the event outside this loop.
            inst:PushEvent("on_collide", {
                other = other,
                world_position_on_a_x = world_position_on_a_x,
                world_position_on_a_y = world_position_on_a_y,
                world_position_on_a_z = world_position_on_a_z,
                world_position_on_b_x = world_position_on_b_x,
                world_position_on_b_y = world_position_on_b_y,
                world_position_on_b_z = world_position_on_b_z,
                world_normal_on_b_x = world_normal_on_b_x,
                world_normal_on_b_y = world_normal_on_b_y,
                world_normal_on_b_z = world_normal_on_b_z,
                lifetime_in_frames = lifetime_in_frames,
                hit_dot_velocity = hit_dot_velocity,
            })
        end

        other:PushEvent("on_collide", {
            other = inst,
            world_position_on_a_x = world_position_on_b_x,
            world_position_on_a_y = world_position_on_b_y,
            world_position_on_a_z = world_position_on_b_z,
            world_position_on_b_x = world_position_on_a_x,
            world_position_on_b_y = world_position_on_a_y,
            world_position_on_b_z = world_position_on_a_z,
            world_normal_on_b_x = -world_normal_on_b_x,
            world_normal_on_b_y = -world_normal_on_b_y,
            world_normal_on_b_z = -world_normal_on_b_z,
            lifetime_in_frames = lifetime_in_frames,
            hit_dot_velocity = hit_dot_velocity,
        })

		--[[
    	print("HIT DOT:", hit_dot_velocity)
    	print("HIT NORMAL:", hit_normal_x, hit_normal_z)
    	print("VELOCITY:", velocity_normalized_x, velocity_normalized_z)
    	print("PUSH BACK:", push_back)
    	]]--

    	other:PushEvent("hit_boat", inst)

        local destroyed_other = not other:IsValid()

        local restitution = (other.components.waterphysics and other.components.waterphysics.restitution) or 1
    	local push_back = restitution * math.max(speed, 0) * math.abs(hit_dot_velocity)
        if destroyed_other then
            push_back = push_back * 0.35
        end

        local shake_percent = math.min(math.abs(hit_dot_velocity) * speed / TUNING.BOAT.MAX_ALLOWED_VELOCITY, 1)
        inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", { intensity = shake_percent })

        ShakeAllCamerasOnPlatform(CAMERASHAKE.FULL, destroyed_other and 1.5 or 0.7, 0.02, (destroyed_other and 0.45 or 0.15) * shake_percent, inst)

    	boat_physics.velocity_x, boat_physics.velocity_z = relative_velocity_x + push_back * hit_normal_x, relative_velocity_z + push_back * hit_normal_z
    end
end

local function on_boatdrag_removed(boatdraginst)
	local boat = boatdraginst:GetCurrentPlatform()
	if boat ~= nil and boat.components.boatphysics ~= nil then
		boat.components.boatphysics:RemoveBoatDrag(boatdraginst)
	end
end

local BoatPhysics = Class(function(self, inst)
    self.inst = inst
    self.velocity_x = 0
    self.velocity_z = 0
    self.has_speed = false
    self.damageable_velocity = 1.25
    self.max_velocity = TUNING.BOAT.MAX_VELOCITY_MOD
    self.rudder_turn_speed = TUNING.BOAT.RUDDER_TURN_SPEED
    self.masts = {}
    self.boatdraginstances = {}

    self.lastzoomtime = nil
    self.lastzoomwasout = false

    self.target_rudder_direction_x = 1
    self.target_rudder_direction_z = 0
    self.rudder_direction_x = 1
    self.rudder_direction_z = 0

    self.boat_rotation_offset = 0
    self.steering_rotate = false

    self.turn_vel = 0
    self.turn_acc = PI

    --self.startmovingfn = nil
    --self.stopmovingfn = nil

    self:StartUpdating()

    self.inst.Physics:SetCollisionCallback(OnCollide)
    self._recent_collisions = {}

    self.inst:ListenForEvent("onignite", function() self:OnIgnite() end)
    self.inst:ListenForEvent("death", function() self:OnDeath() end)
end)

function BoatPhysics:OnSave()
    local data =
    {
        target_rudder_direction_x = self.target_rudder_direction_x,
        target_rudder_direction_z = self.target_rudder_direction_z,
        boat_rotation_offset = self.boat_rotation_offset,
    }

    return data
end

function BoatPhysics:OnLoad(data)
    if data ~= nil then
        self.target_rudder_direction_x = data.target_rudder_direction_x
        self.rudder_direction_x = data.target_rudder_direction_x
        self.target_rudder_direction_z = data.target_rudder_direction_z
        self.rudder_direction_z = data.target_rudder_direction_z
        self.boat_rotation_offset = data.boat_rotation_offset or self.boat_rotation_offset
    end
end

function BoatPhysics:AddAnchorCmp(anchor_cmp)
    print("BoatPhysics:AddAnchorCmp is deprecated, please use AddBoatDrag instead.")
end

function BoatPhysics:RemoveAnchorCmp(anchor_cmp)
    print("BoatPhysics:RemoveAnchorCmp is deprecated, please use RemoveBoatDrag instead.")
end

function BoatPhysics:AddBoatDrag(boatdraginst)
	self.boatdraginstances[boatdraginst] = boatdraginst.components.boatdrag

	self.inst:ListenForEvent("onremove", on_boatdrag_removed, boatdraginst)
	self.inst:ListenForEvent("death", on_boatdrag_removed, boatdraginst)
	self.inst:ListenForEvent("onburnt", on_boatdrag_removed, boatdraginst)
end

function BoatPhysics:RemoveBoatDrag(boatdraginst)
	self.boatdraginstances[boatdraginst] = nil

	self.inst:RemoveEventCallback("onremove", on_boatdrag_removed, boatdraginst)
	self.inst:RemoveEventCallback("death", on_boatdrag_removed, boatdraginst)
	self.inst:RemoveEventCallback("onburnt", on_boatdrag_removed, boatdraginst)
end

function BoatPhysics:SetTargetRudderDirection(dir_x, dir_z)
	self.target_rudder_direction_x = dir_x
	self.target_rudder_direction_z = dir_z
end

function BoatPhysics:GetTargetRudderDirection()
    return self.target_rudder_direction_x, self.target_rudder_direction_z
end

function BoatPhysics:GetRudderDirection()
    return self.rudder_direction_x, self.rudder_direction_z
end

function BoatPhysics:AddMast(mast)
    self.masts[mast] = mast
end

function BoatPhysics:RemoveMast(mast)
    self.masts[mast] = nil
end

function BoatPhysics:OnDeath()
    self.inst.SoundEmitter:KillSound("boat_movement")
end

function BoatPhysics:GetVelocity()
    return math.sqrt(self.velocity_x * self.velocity_x + self.velocity_z * self.velocity_z)
end

function BoatPhysics:GetForceDampening()
    local dampening = 1

    for k,v in pairs(self.boatdraginstances) do
		dampening = dampening - v.forcedampening
    end

    return math.max(0, dampening)
end

function BoatPhysics:DoApplyForce(dir_x, dir_z, force)
    self.velocity_x, self.velocity_z = self.velocity_x + dir_x * force, self.velocity_z + dir_z * force

    local velocity_length = VecUtil_Length(self.velocity_x, self.velocity_z)

    if velocity_length > TUNING.BOAT.MAX_ALLOWED_VELOCITY then
        local velocity_normal_x, velocity_normal_z = VecUtil_Normalize(self.velocity_x, self.velocity_z)
        self.velocity_x, self.velocity_z = VecUtil_Scale(velocity_normal_x, velocity_normal_z, TUNING.BOAT.MAX_ALLOWED_VELOCITY)
    end
end

function BoatPhysics:ApplyRowForce(dir_x, dir_z, force, max_velocity)
    local dir_normal_x, dir_normal_z = VecUtil_NormalizeNoNaN(dir_x, dir_z)
    local velocity_normal_x, velocity_normal_z = VecUtil_NormalizeNoNaN(self.velocity_x, self.velocity_z)
    local force_dir_modifier = math.max(0, VecUtil_Dot(velocity_normal_x, velocity_normal_z, dir_normal_x, dir_normal_z))

    local base_dampening = self:GetForceDampening()

    if force_dir_modifier > 0 then
        local dir_length = VecUtil_Length(dir_normal_x, dir_normal_z)

        local forward_dir_length = dir_length * force_dir_modifier
        local side_dir_length = dir_length * (1 - force_dir_modifier)

        local velocity_left_normal_x, velocity_left_normal_z = velocity_normal_z, -velocity_normal_x
        local is_left = VecUtil_Dot(velocity_left_normal_x, velocity_left_normal_z, dir_normal_x, dir_normal_z) > 0

        local velocity_dampening = base_dampening - easing.inExpo(
            math.min(VecUtil_Length(self.velocity_x, self.velocity_z), max_velocity),
            TUNING.BOAT.BASE_DAMPENING,
            TUNING.BOAT.MAX_DAMPENING - TUNING.BOAT.BASE_DAMPENING,
            max_velocity
        )

        self:DoApplyForce(velocity_normal_x, velocity_normal_z, force * math.max(0, velocity_dampening) * forward_dir_length)
        self:DoApplyForce(velocity_left_normal_x, velocity_left_normal_z, force * math.max(0, base_dampening) * side_dir_length * (is_left and 1 or -1))
    else
        self:DoApplyForce(dir_x, dir_z, force * math.max(0, base_dampening))
    end
end

function BoatPhysics:ApplyForce(dir_x, dir_z, force)
    self:DoApplyForce(dir_x, dir_z, force * self:GetForceDampening())
end

function BoatPhysics:GetMaxVelocity()
    local max_vel = 0

    local mast_maxes = {}
    for k,v in pairs(self.masts) do
		local vel = k:CalcMaxVelocity()
        if vel ~= 0 then
            table.insert(mast_maxes, vel)
        end
    end

    table.sort(mast_maxes)
    local mult = 1
    for i,mast_vel in ipairs(mast_maxes)do
        max_vel = max_vel + (mast_vel * mult)
        mult = mult * 0.7
    end

    max_vel = max_vel * self.max_velocity

    for k,v in pairs(self.boatdraginstances) do
        max_vel = max_vel * v.max_velocity_mod
    end

    return math.min(max_vel, TUNING.BOAT.MAX_ALLOWED_VELOCITY)
end

function BoatPhysics:GetTotalAnchorDrag()
    local total_anchor_drag = 0
    for k,v in pairs(self.boatdraginstances) do
        total_anchor_drag = total_anchor_drag + v.drag
    end
    return total_anchor_drag
end

function BoatPhysics:GetBoatDrag(velocity, total_anchor_drag)
    return easing.inCubic(
        velocity,
        TUNING.BOAT.BASE_DRAG,
        TUNING.BOAT.MAX_DRAG - TUNING.BOAT.BASE_DRAG,
        TUNING.BOAT.MAX_ALLOWED_VELOCITY
    ) + easing.outExpo(
        velocity,
        0,
        total_anchor_drag,
        TUNING.BOAT.MAX_ALLOWED_VELOCITY
    )
end

function BoatPhysics:GetAnchorSailForceModifier()
    local sail_force_modifier = 1
    for k,v in pairs(self.boatdraginstances) do
        sail_force_modifier = sail_force_modifier * v.sailforcemodifier
    end
    return sail_force_modifier
end

function BoatPhysics:GetRudderTurnSpeed()
    local velocity_length = VecUtil_Length(self.velocity_x, self.velocity_z)

    local speed = 0.6
    if velocity_length > 7 then
        speed = 0.1975
    elseif velocity_length > 5 then
        speed = 0.255
    elseif velocity_length > 3 then
        speed = 0.37
    elseif velocity_length > 1.5 then
        speed = 0.48
    end

    return speed
end

function BoatPhysics:SetCanSteeringRotate(can_rotate)
    if self.steering_rotate == can_rotate then return end
    self.steering_rotate = can_rotate

    if can_rotate then
        self.boat_rotation_offset = self.inst.Transform:GetRotation() - -VecUtil_GetAngleInDegrees(self.rudder_direction_x, self.rudder_direction_z)
    end
end

function BoatPhysics:ApplyDrag(dt, total_drag, cur_velocity, velocity_normal_x, velocity_normal_z)
    if cur_velocity > 0 then
        local velocity_length = math.min(-total_drag, 0) * dt
        self.velocity_x, self.velocity_z = VecUtil_Add(self.velocity_x, self.velocity_z, VecUtil_Scale(velocity_normal_x, velocity_normal_z, velocity_length))
        cur_velocity = cur_velocity + velocity_length

        if cur_velocity < 0 then
            self.velocity_x, self.velocity_z = 0, 0
            cur_velocity = 0
        end
	end

    return cur_velocity
end

function BoatPhysics:ApplySailForce(dt, sail_force, cur_velocity, max_velocity)
    if sail_force > 0 and cur_velocity < max_velocity then
        local velocity_length = sail_force * dt
        self.velocity_x, self.velocity_z = VecUtil_Add(self.velocity_x, self.velocity_z, VecUtil_Scale(self.rudder_direction_x, self.rudder_direction_z, velocity_length))
        cur_velocity = cur_velocity + velocity_length

        if cur_velocity > max_velocity then
            local velocity_normal_x, velocity_normal_z = VecUtil_Normalize(self.velocity_x, self.velocity_z)
            self.velocity_x, self.velocity_z = VecUtil_Scale(velocity_normal_x, velocity_normal_z, max_velocity)
            cur_velocity = max_velocity
        end
    end

    return cur_velocity
end

function BoatPhysics:OnUpdate(dt)
-- TURNING
    local stop = false

    local p1_angle = VecUtil_GetAngleInRads(self.rudder_direction_x, self.rudder_direction_z)
    local p2_angle = VecUtil_GetAngleInRads(self.target_rudder_direction_x, self.target_rudder_direction_z)

    if math.abs(p2_angle - p1_angle) > PI then
        if p2_angle > p1_angle then
            p2_angle = p2_angle - PI - PI
        else
            p1_angle = p1_angle - PI - PI
        end
    end
    if math.abs(p2_angle - p1_angle) < PI/32 then
        stop = true
    end

    local target_vel = self:GetRudderTurnSpeed()
    if stop then
        target_vel = 0
    end

    if target_vel > self.turn_vel then
        self.turn_vel = math.min(self.turn_vel + (dt * self.turn_acc),self:GetRudderTurnSpeed())
    else
        self.turn_vel = math.max(self.turn_vel - (dt * self.turn_acc),0)
    end

    if self.turn_vel > 0 then
        local newangle = nil
        if p1_angle < p2_angle then
            newangle = p1_angle + (dt *self.turn_vel)
        else
            newangle = p1_angle - (dt * self.turn_vel)
        end
        self.rudder_direction_x = math.cos(newangle)
        self.rudder_direction_z = math.sin(newangle)
    end
    --END TURNING

    --This is used to tell the steering characters to stop turning the wheel.
    local TOLERANCE = 0.1   
    if math.abs(self.rudder_direction_x - self.target_rudder_direction_x) < TOLERANCE and math.abs(self.rudder_direction_z - self.target_rudder_direction_z) < TOLERANCE then
        self.inst:PushEvent("stopturning")
    end


    local sail_force_modifier = self:GetAnchorSailForceModifier()
    local sail_force = 0
    for k,v in pairs(self.masts) do
        sail_force = sail_force + k:CalcSailForce() * sail_force_modifier
    end

    local velocity_normal_x, velocity_normal_z, cur_velocity = VecUtil_NormalAndLength(self.velocity_x, self.velocity_z)
    local max_velocity = self:GetMaxVelocity()

    local total_anchor_drag = self:GetTotalAnchorDrag()

    if total_anchor_drag > 0 and sail_force > 0 then
        cur_velocity = self:ApplySailForce(dt, sail_force, cur_velocity, max_velocity)
        cur_velocity = self:ApplyDrag(dt, self:GetBoatDrag(cur_velocity, total_anchor_drag), cur_velocity, VecUtil_Normalize(self.velocity_x, self.velocity_z))
    else
        cur_velocity = self:ApplyDrag(dt, self:GetBoatDrag(cur_velocity, total_anchor_drag), cur_velocity, velocity_normal_x, velocity_normal_z)
        cur_velocity = self:ApplySailForce(dt, sail_force, cur_velocity, max_velocity)
    end

    local is_moving = cur_velocity > 0
    if self.was_moving and not is_moving then
        if self.inst.components.boatdrifter then
            self.inst.components.boatdrifter:OnStopMoving()
        end
        if self.stopmovingfn then
            self.stopmovingfn(self.inst)
        end
        self.inst:PushEvent("boat_stop_moving")
        self.was_moving = is_moving
    elseif not self.was_moving and is_moving then
        if self.inst.components.boatdrifter then
            self.inst.components.boatdrifter:OnStartMoving()
        end
        if self.startmovingfn then
            self.startmovingfn(self.inst)
        end
        self.inst:PushEvent("boat_start_moving")
        self.was_moving = is_moving
    end

    local new_speed_is_scary = cur_velocity > TUNING.BOAT.SCARY_MINSPEED
    if not self.has_speed and new_speed_is_scary then
        self.has_speed = true
        self.inst:AddTag("scarytoprey")
    elseif self.has_speed and not new_speed_is_scary then
        self.has_speed = false
        self.inst:RemoveTag("scarytoprey")
    end

    local time = GetTime()
    if self.lastzoomtime == nil or time - self.lastzoomtime > 1.0 then
        local should_zoom_out = sail_force > 0 and total_anchor_drag <= 0
        if not self.inst.doplatformcamerazoom:value() and should_zoom_out then
            self.inst.doplatformcamerazoom:set(true)
        elseif self.inst.doplatformcamerazoom:value() and not should_zoom_out then
            self.inst.doplatformcamerazoom:set(false)
        end

        self.lastzoomtime = time
    end

    if self.steering_rotate then
        self.inst.Transform:SetRotation(-VecUtil_GetAngleInDegrees(self.rudder_direction_x, self.rudder_direction_z) + self.boat_rotation_offset)
    else
        for mast in pairs(self.masts) do
            mast:SetRudderDirection(self.rudder_direction_x, self.rudder_direction_z)
        end
        self.inst.Transform:SetRotation(self.boat_rotation_offset)
    end

    local corrected_vel_x, corrected_vel_z = VecUtil_RotateDir(self.velocity_x, self.velocity_z, self.inst.Transform:GetRotation() * DEGREES)
    self.inst.Physics:SetMotorVel(corrected_vel_x, 0, corrected_vel_z)

    self.inst.SoundEmitter:SetParameter("boat_movement", "speed", cur_velocity / TUNING.BOAT.MAX_ALLOWED_VELOCITY)
end

function BoatPhysics:GetDebugString()
    return string.format("(%2.2f, %2.2f) : %2.2f", self.velocity_x, self.velocity_z, self:GetVelocity())
end

function BoatPhysics:StartUpdating()
    self.inst:StartUpdatingComponent(self)
end

function BoatPhysics:StopUpdating()
    self.inst:StopUpdatingComponent(self)
end

function BoatPhysics:OnEntitySleep()
    --close all the masts on the boat
    for mast in pairs(self.masts) do
        mast:CloseSail()
    end
end

return BoatPhysics
