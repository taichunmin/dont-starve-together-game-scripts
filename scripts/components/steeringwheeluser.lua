local SteeringWheelUser = Class(function(self, inst)
    self.inst = inst
    self.should_play_left_turn_anim = false

    self.wheel_remove_callback = function(wheel)
        if self.steering_wheel == wheel then
		    self.inst:StopUpdatingComponent(self)
			self.inst:RemoveTag("steeringboat")

            self.steering_wheel.components.steeringwheel:StopSteering()
            self.inst:PushEvent("stop_steering_boat")
            self.steering_wheel = nil

        end
    end
    self.onstopturning = function()
       self.inst:PushEvent("playerstopturning")
    end
    self.onboatremoved = function()
		self.boat = nil
    end
end)

function SteeringWheelUser:SetSteeringWheel(steering_wheel)
	if self.steering_wheel == steering_wheel then
		return
	end

	local prev_steering_wheel = self.steering_wheel
	self.steering_wheel = steering_wheel

	if prev_steering_wheel ~= nil then
	    self.inst:StopUpdatingComponent(self)
		self.inst:RemoveTag("steeringboat")
        self.inst:RemoveEventCallback("onremove", self.wheel_remove_callback, prev_steering_wheel)

		if steering_wheel == nil and self.inst.sg:HasStateTag("is_using_steering_wheel") then
			self.inst.sg.statemem.steering = true
			self.inst.sg:GoToState("stop_steering")
		end

		if prev_steering_wheel.components.steeringwheel ~= nil then
			prev_steering_wheel.components.steeringwheel:StopSteering()
		end

		if self.boat then
			self.inst:RemoveEventCallback("stopturning", self.onstopturning, self.boat)
			self.inst:RemoveEventCallback("onremove", self.onboatremoved, self.boat)
		end
	end

	self.boat = self.inst:GetCurrentPlatform()

	if steering_wheel ~= nil then
	    self.inst:StartUpdatingComponent(self)
		self.inst:AddTag("steeringboat")

		self.inst.Physics:Teleport(steering_wheel.Transform:GetWorldPosition())

        self.inst:ListenForEvent("onremove", self.wheel_remove_callback, steering_wheel)

		steering_wheel.components.steeringwheel:StartSteering(self.inst)

		self.inst:ListenForEvent("stopturning", self.onstopturning, self.boat)
		self.inst:ListenForEvent("onremove", self.onboatremoved, self.boat)
	else
		if self.boat ~= nil then
			local dir_x, dir_z = self.boat.components.boatphysics:GetRudderDirection()
			self.boat.components.boatphysics:SetTargetRudderDirection(dir_x, dir_z)
			self.boat = nil
		end
	end
end

function SteeringWheelUser:Steer(pos_x, pos_z)
	if self.boat == nil then
		return false
	end

	local x, y, z = self.boat.Transform:GetWorldPosition()
	local dir_x, dir_z = VecUtil_Normalize(pos_x - x, pos_z - z)
	self:SteerInDir(dir_x, dir_z)

	return true
end

function SteeringWheelUser:SteerInDir(dir_x, dir_z)
	if self.boat == nil then
		return
	end

	self.boat.components.boatphysics:SetTargetRudderDirection(dir_x, dir_z)

	local tx,tz = self.boat.components.boatphysics:GetTargetRudderDirection()
	local rx, rz = self.boat.components.boatphysics:GetRudderDirection()
	local TOLERANCE = 0.1
	local dontsteer = math.abs(tx - rx) < TOLERANCE and math.abs(tz - rz) < TOLERANCE	-- if you are on a boat and the target heading is close enough to the current heading, don't play the animation.
	if not dontsteer then
		self.should_play_left_turn_anim = (rz * dir_x - rx * dir_z) > 0
		self.inst:PushEvent("set_heading")
	end
end

function SteeringWheelUser:GetBoat()
	return self.inst:GetCurrentPlatform()
end

function SteeringWheelUser:OnUpdate(dt)
	if self.steering_wheel == nil then
	    self.inst:StopUpdatingComponent(self)
		return
	end

	--State graph was interrupted
	if not self.inst.sg:HasStateTag("is_using_steering_wheel") then
		self:SetSteeringWheel(nil)
		return
	end

	self.inst.Transform:SetPosition(self.steering_wheel.Transform:GetWorldPosition())
end

return SteeringWheelUser
