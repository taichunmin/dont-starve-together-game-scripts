local function onloadedammo(self, loadedammo)
	if loadedammo ~= nil then
		self.inst:AddTag("ammoloaded")
	else
		self.inst:RemoveTag("ammoloaded")
	end
end

local BoatCannon = Class(function(self, inst)
    self.inst = inst

	self.loadedammo = nil

	--self.operator = nil
	--self.onstartfn = nil
	--self.onstopfn = nil

	self.onoperatorremoved = function(operator) if operator == self.operator then self:StopAiming() end end
end,
nil,
{
	loadedammo = onloadedammo,
})

function BoatCannon:OnSave()
	return self.loadedammo ~= nil and { loadedammo = self.loadedammo } or nil
end

function BoatCannon:OnLoad(data)
	self:LoadAmmo(data.loadedammo)
end

function BoatCannon:SetOnStartAimingFn(fn)
	self.onstartfn = fn
end

function BoatCannon:SetOnStopAimingFn(fn)
	self.onstopfn = fn
end

function BoatCannon:StartAiming(operator)
	self.operator = operator
	self.inst:ListenForEvent("onremove", self.onoperatorremoved, operator)

	self.inst:AddTag("occupied")

	if self.onstartfn ~= nil then
		self.onstartfn(self.inst, operator)
	end
end

function BoatCannon:StopAiming()
	if self.operator ~= nil then
		self.inst:ListenForEvent("onremove", self.onoperatorremoved, self.operator)
	end
	self.inst:RemoveTag("occupied")

	if self.onstopfn ~= nil then
		self.onstopfn(self.inst, self.operator)
	end
	self.operator = nil
end

function BoatCannon:OnRemoveFromEntity()
	if self.operator ~= nil then
		if self.operator.components.boatcannonuser ~= nil then
			self.operator.components.boatcannonuser:SetCannon(nil)
		else
			self:StopAiming()
		end
	end
end

function BoatCannon:IsAmmoLoaded()
	return self.loadedammo ~= nil
end

function BoatCannon:LoadAmmo(projectileprefab)
	self.loadedammo = projectileprefab
	self.inst:PushEvent(projectileprefab ~= nil and "ammoloaded" or "ammounloaded")
end

function BoatCannon:Shoot()
	if self.loadedammo == nil then
		return
	end

	local x, y, z = self.inst.Transform:GetWorldPosition()
    local projectile = SpawnPrefab(self.loadedammo)
	if projectile == nil then
		self:LoadAmmo(nil)
		return
	end

	local theta = self.inst.Transform:GetRotation()* DEGREES
	local radius = 0.5
	local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))

    projectile.Transform:SetPosition(x + offset.x, y + TUNING.BOAT.BOATCANNON.PROJECTILE_INITIAL_HEIGHT, z + offset.z)

	projectile.shooter = self.inst

	local angle = -self.inst.Transform:GetRotation() * DEGREES
	local range = TUNING.BOAT.BOATCANNON.RANGE

	-- Apply direction & power to shot
	local targetpos = Vector3(x + math.cos(angle) * range, y, z + math.sin(angle) * range)
    projectile.components.complexprojectile:Launch(targetpos, self.inst, self.inst)

	-- Remove cannon ammo reference
	self:LoadAmmo(nil)

	-- Add a shot recoil to the boat
	local force_direction = -Vector3(math.cos(angle), 0, math.sin(angle))
	local force = 1
	local boat = self.inst:GetCurrentPlatform()
	if boat ~= nil then
		boat.components.boatphysics:ApplyForce(force_direction.x, force_direction.z, force)
	end
end

return BoatCannon
