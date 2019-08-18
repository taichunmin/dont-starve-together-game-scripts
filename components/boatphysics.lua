local function OnCollide(inst, other, world_position_on_a_x, world_position_on_a_y, world_position_on_a_z, world_position_on_b_x, world_position_on_b_y, world_position_on_b_z, world_normal_on_b_x, world_normal_on_b_y, world_normal_on_b_z, lifetime_in_frames)
	local boat_physics = inst.components.boatphysics
    if other ~= nil and other:IsValid() and (other == TheWorld or other:HasTag("BLOCKER") or other.components.boatphysics) and lifetime_in_frames <= 1 then

    	local relative_velocity_x = boat_physics.velocity_x
    	local relative_velocity_z = boat_physics.velocity_z

    	local other_boat_physics = other.components.boat_physics
    	if other_boat_physics ~= nil then
    		if other_boat_physics ~= nil then
	    		relative_velocity_x = relative_velocity_x - other_boat_physics.velocity_x
    			relative_velocity_z = relative_velocity_z - other_boat_physics.velocity_z
    		end
    	end  	

    	local velocity = VecUtil_Length(relative_velocity_x, relative_velocity_z)  


    	local hit_normal_x, hit_normal_z = VecUtil_Normalize(world_normal_on_b_x, world_normal_on_b_z)
    	local velocity_normalized_x, velocity_normalized_z = relative_velocity_x, relative_velocity_z
    	if velocity > 0 then
    		velocity_normalized_x, velocity_normalized_z = velocity_normalized_x / velocity, velocity_normalized_z / velocity
    	end
    	local hit_dot_velocity = VecUtil_Dot(hit_normal_x, hit_normal_z, velocity_normalized_x, velocity_normalized_z)

    	inst:PushEvent("on_collide", { other = other,
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
    									    hit_dot_velocity = hit_dot_velocity})

        other:PushEvent("on_collide", { other = inst,
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
                                            hit_dot_velocity = hit_dot_velocity})

		--[[
    	print("HIT DOT:", hit_dot_velocity)
    	print("HIT NORMAL:", hit_normal_x, hit_normal_z)
    	print("VELOCITY:", velocity_normalized_x, velocity_normalized_z)
    	print("PUSH BACK:", push_back)
    	]]--

        local restitution = 1
        local other_water_physics = other.components.waterphysics
        if other_water_physics ~= nil then
            restitution = other_water_physics.restitution
        end

    	other:PushEvent("hit_boat", inst)

        local destroyed_other = not other:IsValid()

    	local push_back = restitution * velocity * math.abs(hit_dot_velocity)
        
        local shake_percent = math.min(math.abs(hit_dot_velocity) * velocity / boat_physics.max_velocity, 1)
        local max_shake = 0.15
        local duration = 0.7

        if destroyed_other then
            max_shake = 0.45
            duration = 1.5            
            push_back = push_back * 0.35
        end 

        local hit_intensity = shake_percent
        inst.SoundEmitter:PlaySoundWithParams("turnoftides/common/together/boat/damage", { intensity = hit_intensity })

        local platform = inst.components.walkableplatform
        if platform ~= nil then
            for k,v in pairs(inst.components.walkableplatform:GetEntitiesOnPlatform({"player"})) do
                v:ShakeCamera(CAMERASHAKE.FULL, duration, .02, max_shake * shake_percent)
            end     
        end

    	boat_physics.velocity_x, boat_physics.velocity_z = relative_velocity_x + push_back * hit_normal_x, relative_velocity_z + push_back * hit_normal_z
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
    self.anchor_cmps = {}

    self.lastzoomtime = nil
    self.lastzoomwasout = false

    self.target_rudder_direction_x = 1
    self.target_rudder_direction_z = 0
    self.rudder_direction_x = 1
    self.rudder_direction_z = 0

    self.turn_vel = 0
    self.turn_acc = PI

    self.inst:StartUpdatingComponent(self)

    self.inst.Physics:SetCollisionCallback(OnCollide)

    self.inst:ListenForEvent("onignite", function() self:OnIgnite() end)
    self.inst:ListenForEvent("onbuilt", function(inst, data)  self:OnBuilt(data.builder, data.pos) end)  
    self.inst:ListenForEvent("deployed", function(inst, data)  self:OnBuilt(data.deployer, data.pos) end)  
    self.inst:ListenForEvent("death", function() self:OnDeath() end)    
end)

function BoatPhysics:OnSave()
    local data =
    {
        target_rudder_direction_x = self.target_rudder_direction_x,
        target_rudder_direction_z = self.target_rudder_direction_z,
    }

    return data
end

function BoatPhysics:OnLoad(data)
    if data ~= nil then
        self.target_rudder_direction_x = data.target_rudder_direction_x
        self.rudder_direction_x = data.target_rudder_direction_x
        self.target_rudder_direction_z = data.target_rudder_direction_z
        self.rudder_direction_z = data.target_rudder_direction_z
    end
end

function BoatPhysics:AddAnchorCmp(anchor_cmp)
    self.anchor_cmps[anchor_cmp] = anchor_cmp
end

function BoatPhysics:RemoveAnchorCmp(anchor_cmp)
    self.anchor_cmps[anchor_cmp] = nil
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
	self.sinking = true

    self.inst.SoundEmitter:KillSound("boat_movement")
end

function BoatPhysics:GetVelocity()
    return math.sqrt(self.velocity_x * self.velocity_x + self.velocity_z * self.velocity_z)
end

function BoatPhysics:ApplyForce(dir_x, dir_z, force)
    self.velocity_x, self.velocity_z = self.velocity_x + dir_x * force, self.velocity_z + dir_z * force
end

function BoatPhysics:GetMaxVelocity()    
    local max_vel = 0 

    local mast_maxes = {}
    for k,v in pairs(self.masts) do
        if k.is_sail_raised then
           -- max_vel = max_vel * k.max_velocity_mod
            table.insert(mast_maxes,k.max_velocity * (1 - k:GetFurled0to1()))
        end
    end

    table.sort(mast_maxes)
    local mult = 1
    for i,mast_vel in ipairs(mast_maxes)do
        max_vel = max_vel + (mast_vel * mult)
        mult = mult * 0.7
    end

    max_vel = max_vel * self.max_velocity 
    max_vel = math.max(self.max_velocity, max_vel)
    
    for k,v in pairs(self.anchor_cmps) do
        max_vel = max_vel * k.max_velocity_mod
    end

    return max_vel
end

function BoatPhysics:GetTotalAnchorDrag()
    local total_anchor_drag = 0
    for k,v in pairs(self.anchor_cmps) do
        total_anchor_drag = total_anchor_drag + k:GetDrag()
    end
    return total_anchor_drag
end

function BoatPhysics:GetRudderTurnSpeed()

    local velocity_length = VecUtil_Length(self.velocity_x, self.velocity_z)
    
    local speed = 0.6

    if velocity_length >= 1.3 and velocity_length < 2 then
        speed = 0.37
    elseif velocity_length >= 2 and velocity_length < 3 then
        speed = 0.255
    elseif velocity_length >= 3 then
        speed = 0.1975
    end
    
    return speed
end

function BoatPhysics:OnUpdate(dt)
    local boat_pos_x, boat_pos_y, boat_pos_z = self.inst.Transform:GetWorldPosition()



-- TURNING    
    local stop = false

    local p1_angle = VecUtil_GetAngleInRads(self.rudder_direction_x, self.rudder_direction_z)
    local p2_angle = VecUtil_GetAngleInRads(self.target_rudder_direction_x, self.target_rudder_direction_z)

--    print("ANGLES",p1_angle,p2_angle)

    if math.abs(p2_angle - p1_angle) > PI then
        if p2_angle > p1_angle then
            p2_angle = p2_angle - PI - PI 
        else
            p1_angle = p1_angle - PI - PI
        end
    end
--    print("-- STOP TEST")
    if math.abs(p2_angle - p1_angle) < PI/32 then        
--        print("   - STOP!")
        stop = true
    end

    local target_vel = self:GetRudderTurnSpeed()
    if stop then
        target_vel = 0
    end
    --print("-- target_vel",target_vel)

    if target_vel > self.turn_vel then
        self.turn_vel = math.min(self.turn_vel + (dt * self.turn_acc),self:GetRudderTurnSpeed())         
    else
        self.turn_vel = math.max(self.turn_vel - (dt * self.turn_acc),0)               
    end

    --print("-- self.turn_vel",self.turn_vel)
    if self.turn_vel > 0 then
        local newangle = nil
        if p1_angle < p2_angle then
            newangle = p1_angle + (dt *self.turn_vel)
        else
            newangle = p1_angle - (dt * self.turn_vel)
        end
--        print("-- NEW ANGLE ",newangle)
        self.rudder_direction_x = math.cos(newangle)
        self.rudder_direction_z = math.sin(newangle)
    end
-- END TURNING

-- old turning
--    self.rudder_direction_x, self.rudder_direction_z = VecUtil_Lerp(self.rudder_direction_x, self.rudder_direction_z, self.target_rudder_direction_x, self.target_rudder_direction_z, dt * self:GetRudderTurnSpeed())
    
    -- This is used to tell the steering characters to stop turning the wheel.
    local TOLLERANCE = 0.1   
    if math.abs(self.rudder_direction_x - self.target_rudder_direction_x) < TOLLERANCE and math.abs(self.rudder_direction_z - self.target_rudder_direction_z) < TOLLERANCE then
        self.inst:PushEvent("stopturning")
    end

    local raised_sail_count = 0
    local sail_force = 0
    for k,v in pairs(self.masts) do
        if k.is_sail_raised then
            sail_force = sail_force + k.sail_force * (1 - k:GetFurled0to1())
            raised_sail_count = raised_sail_count + 1
        end
    end

    local total_anchor_drag = self:GetTotalAnchorDrag()

    if raised_sail_count > 0 then -- and total_anchor_drag <= 0      
        --print("SAIL FORCE",sail_force,"ANCHOR",total_anchor_drag)  
        local accel = math.max(sail_force - total_anchor_drag,0)
        self.velocity_x, self.velocity_z = VecUtil_Add(self.velocity_x, self.velocity_z, VecUtil_Scale(self.rudder_direction_x, self.rudder_direction_z, accel * dt))
	elseif raised_sail_count == 0 or total_anchor_drag > 0 then
		local velocity_length = VecUtil_Length(self.velocity_x, self.velocity_z)	
		local min_velocity = 0.55
		local drag = TUNING.BOAT.BASE_DRAG

		if total_anchor_drag > 0 then
			min_velocity = 0
			drag = drag + total_anchor_drag
		end

		if velocity_length > min_velocity then			
			local dragged_velocity_length = Lerp(velocity_length, min_velocity, dt * drag)
			self.velocity_x, self.velocity_z = VecUtil_Scale(self.velocity_x, self.velocity_z, dragged_velocity_length / velocity_length)
		end
	end
	
    --This clamps the velocity to a maximum to prevent the boat from going crazy
	local velocity_length = VecUtil_Length(self.velocity_x, self.velocity_z)
    local MAX_ALLOWED_VELOCITY = 5
    if velocity_length > MAX_ALLOWED_VELOCITY then
        local maxx,maxz = VecUtil_Scale(self.rudder_direction_x, self.rudder_direction_z,  MAX_ALLOWED_VELOCITY)
        self.velocity_x, self.velocity_z = maxx,maxz
        velocity_length = MAX_ALLOWED_VELOCITY
    end

    if velocity_length > self:GetMaxVelocity() then 
        self.velocity_x, self.velocity_z = self.velocity_x * 0.95, self.velocity_z * 0.95
	end
    
    local new_speed_is_scary = ((self.velocity_x*self.velocity_x) + (self.velocity_z*self.velocity_z)) > TUNING.BOAT.SCARY_MINSPEED_SQR
    if not self.has_speed and new_speed_is_scary then
        self.has_speed = true
        self.inst:AddTag("scarytoprey")
    elseif self.has_speed and not new_speed_is_scary then
        self.has_speed = false
        self.inst:RemoveTag("scarytoprey")
    end

    local time = GetTime()
    if self.lastzoomtime == nil or time - self.lastzoomtime > 1.0 then
        local should_zoom_out = raised_sail_count > 0 and total_anchor_drag <= 0
        if not self.lastzoomwasout and should_zoom_out then
            self.inst:AddTag("doplatformcamerazoom")
            self.lastzoomwasout = true
        elseif self.lastzoomwasout and not should_zoom_out then
            self.inst:RemoveTag("doplatformcamerazoom")
            self.lastzoomwasout = false
        end

        self.lastzoomtime = time
    end

	self.inst.Physics:SetMotorVel(self.velocity_x, 0, self.velocity_z)	

    self.inst.SoundEmitter:SetParameter("boat_movement", "speed", velocity_length / self.max_velocity)
end

function BoatPhysics:OnRemoveFromEntity()
    self.inst:RemoveTag("doplatformcamerazoom")
end

return BoatPhysics
