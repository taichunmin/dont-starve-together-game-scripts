local RuinsShadelingSpawner = Class(function(self, inst)
	self.inst = inst
	self.shadeling = nil
	self.cooldowntask = nil
	self.cooldown = TUNING.TOTAL_DAY_TIME
end)

local function OnCooldown(inst, self)
	self.cooldowntask = nil
end

local function OnShadelingLooted(shadeling)
	local self = TheWorld.components.ruinsshadelingspawner
	if self.cooldowntask ~= nil then
		self.cooldowntask:Cancel()
	end
	self.cooldowntask = self.inst:DoTaskInTime(self.cooldown, OnCooldown, self)
end

local function OnShadelingRemoved(shadeling)
	local self = TheWorld.components.ruinsshadelingspawner
	self.shadeling = nil
end

local function OnChairRemoved(chair)
	local self = TheWorld.components.ruinsshadelingspawner
	if self.shadeling ~= nil then
		self.shadeling:Despawn()
	end
end

local function OnChairBecameUnsittable(chair)
	local self = TheWorld.components.ruinsshadelingspawner
	if self.shadeling ~= nil and not (chair.components.sittable ~= nil and chair.components.sittable:IsOccupiedBy(self.shadeling)) then
		self.shadeling:Despawn()
	end
end

function RuinsShadelingSpawner:TrySpawnShadeling(chair)
	if self.shadeling == nil and
		self.cooldowntask == nil and
		chair.components.sittable ~= nil and
		not chair.components.sittable:IsOccupied() then
		--
		local x, y, z = chair.Transform:GetWorldPosition()
		if self.inst.Map:FindVisualNodeAtPoint(x, y, z, "Nightmare") then
			self.shadeling = SpawnPrefab("ruins_shadeling")
			self.shadeling.Transform:SetPosition(x, y, z)
			self.inst:ListenForEvent("ruins_shadeling_looted", OnShadelingLooted, self.shadeling)
			self.inst:ListenForEvent("onremove", OnShadelingRemoved, self.shadeling)
			self.inst:ListenForEvent("onremove", OnChairRemoved, chair)
			self.inst:ListenForEvent("becomeunsittable", OnChairBecameUnsittable, chair)
			chair.components.sittable:SetOccupier(self.shadeling)
			return self.shadeling
		end
	end
end

function RuinsShadelingSpawner:LongUpdate(dt)
	if self.cooldowntask ~= nil then
		local t = GetTaskRemaining(self.cooldowntask)
		self.cooldowntask:Cancel()
		self.cooldowntask = t > dt and self.inst:DoTaskInTime(t - dt, OnCooldown, self) or nil
	end
end

return RuinsShadelingSpawner
