local function OnStartStrafing(inst)
	local self = inst.components.strafer
	if not self.aiming and self.playercontroller then
		self.aiming = true
		inst:StartUpdatingComponent(self)
	end
	if not self.ismastersim and inst.components.locomotor then
		inst.components.locomotor:SetStrafing(true)
	end
end

local function OnStopStrafing(inst)
	local self = inst.components.strafer
	if self.aiming then
		self.aiming = false
		self.lastdir = nil
		inst:StopUpdatingComponent(self)
	end
	if not self.ismastersim and inst.components.locomotor then
		inst.components.locomotor:SetStrafing(false)
	end
end

local Strafer = Class(function(self, inst)
	self.inst = inst
	self.ismastersim = TheWorld.ismastersim
	self.playercontroller = inst.components.playercontroller
	--don't cache locomotor because there's none for non-predicting clients

	self.aiming = false

	inst:ListenForEvent("startstrafing", OnStartStrafing)
	inst:ListenForEvent("stopstrafing", OnStopStrafing)
	if inst.player_classified and inst.player_classified.isstrafing:value() then
		OnStartStrafing(inst)
	end
end)

function Strafer:IsAiming()
	return self.aiming
end

function Strafer:OnRemoveFromEntity()
	self.inst:RemoveEventCallback("startstrafing", OnStartStrafing)
	self.inst:RemoveEventCallback("stopstrafing", OnStopStrafing)
	if not self.ismastersim and self.inst.components.locomotor then
		self.inst.components.locomotor:SetStrafing(false)
	end
end

function Strafer:OnUpdate(dt)
	if not self.playercontroller:IsEnabled() or (self.inst.sg and self.inst.sg:HasStateTag("busy")) then
		self.lastdir = nil
		return
	end

	local dir
	if TheInput:ControllerAttached() then
		local xdir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_LEFT)
		local ydir = TheInput:GetAnalogControlValue(CONTROL_INVENTORY_UP) - TheInput:GetAnalogControlValue(CONTROL_INVENTORY_DOWN)
		local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
		if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
			dir = TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir
			dir = math.atan2(-dir.z, dir.x) * RADIANS
		end
	else
		local x, z = TheInput:GetWorldXZWithHeight(1)
		if x and z then
			dir = self.inst:GetAngleToPoint(x, 0, z)
		end
	end

	if dir then
		if self.inst.components.locomotor then
			self.inst.components.locomotor:OnStrafeFacingChanged(dir)
		end
		if not self.ismastersim and self.lastdir ~= dir then
			self.lastdir = dir
			SendRPCToServer(RPC.StrafeFacing, dir)
		end
	end
end

return Strafer
