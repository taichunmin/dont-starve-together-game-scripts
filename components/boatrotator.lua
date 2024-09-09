local BoatRotator = Class(function(self, inst)
    self.inst = inst
	self.boat = nil

	self.OnBoatRemoved = function() self.boat = nil end
    self.OnBoatDeath = function() self:OnDeath() end

	self._setup_boat_task = self.inst:DoTaskInTime(0, function()
        self:SetBoat(self.inst:GetCurrentPlatform())
		self._setup_boat_task = nil
    end)
end)

function BoatRotator:OnRemoveFromEntity()
	if self._setup_boat_task ~= nil then
		self._setup_boat_task:Cancel()
        self._setup_boat_task = nil
	end
end

function BoatRotator:OnRemoveEntity()
    if self ~= nil then
        self:SetBoat(nil)
    end
end

function BoatRotator:SetRotationDirection(dir)
	local boat = self.inst:GetCurrentPlatform()
	if boat == nil or boat.components.boatring == nil or not boat:HasTag("boat") then
		return
	end

	dir = (dir > 0 and 1) or (dir < 0 and -1) or 0
	boat.components.boatring:SetRotationDirection(dir)

    -- Tell all boat rotators on the boat that its rotation has changed
    boat:PushEvent("rotationdirchanged", dir)
end

function BoatRotator:SetBoat(boat)
	if boat == self.boat then return end

	if self.boat ~= nil then
        self.boat.components.boatring:RemoveRotator(self)
        self.inst:RemoveEventCallback("onremove", self.OnBoatRemoved, boat)
        self.inst:RemoveEventCallback("death", self.OnBoatDeath, boat)
    end

    self.boat = boat

    if boat ~= nil then
        self.inst.Transform:SetRotation(self.boat.Transform:GetRotation())
        boat.components.boatring:AddRotator(self)
        self.inst.sg.mem.direction = boat.components.boatring:GetRotationDirection()
        if self.inst.sg:HasStateTag("idle") then
            --refresh direction when loading back onto a boat
            self.inst.sg:GoToState("idle")
        end
        self.inst:ListenForEvent("onremove", self.OnBoatRemoved, boat)
        self.inst:ListenForEvent("death", self.OnBoatDeath, boat)
    end
end

function BoatRotator:OnDeath()
	if self.inst:IsValid() then
	    --self.inst.SoundEmitter:KillSound("boat_movement")
        self:SetBoat(nil)
	end
end

return BoatRotator
