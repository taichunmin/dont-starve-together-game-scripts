local function SpawnLightning(inst,x,y,z)
	local spark = SpawnPrefab("moonstorm_ground_lightning_fx")
	spark.Transform:SetRotation(math.random()*360)
	spark.Transform:SetPosition(x,y,z)
end

local function checkground(inst, map, x, y, z)
	if TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
		local node_index = map:GetNodeIdAtPoint(x, 0, z)
		local nodes = TheWorld.net.components.moonstorms._moonstorm_nodes:value()
		for i, node in pairs(nodes) do
			if node == node_index  then
				return true
			end
		end
	end
end

local MoonstormLightningManager = Class(function(self, inst)
	self.inst = inst

	self.spark = {per_sec = 5, spawn_rate = 0, checkfn = checkground, spawnfn = SpawnLightning}

	self.sparks_per_sec = 1
	self.sparks_idle_time = 5

	self.sparks_per_sec_mod = 1.0

	self.inst:ListenForEvent("moonstorm_nodes_dirty_relay", function(w,data)
		if TheWorld.net.components.moonstorms._moonstorm_nodes:value() then
			self.inst:StartUpdatingComponent(self)
		else
			self.inst:StopUpdatingComponent(self)
		end
	end, TheWorld)
end)

local function calcVisibleRadius()
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local radius = (75 - 30) * percent + 30
	return radius
end

local function calcPerSecMult(min, max)
	local percent = (math.clamp(TheCamera:GetDistance(), 30, 100) - 30) / (70)
	local mult = (1.5 - 1) * percent + 1
	return mult
end

function MoonstormLightningManager:OnUpdate(dt)

	if ThePlayer == nil then return end


	local map = TheWorld.Map
	if map == nil then return end

	local px, py, pz = ThePlayer.Transform:GetWorldPosition()
	local mult = calcPerSecMult()

	local radius = calcVisibleRadius()

	self.spark.spawn_rate = self.spark.spawn_rate + self.spark.per_sec * self.sparks_per_sec_mod * mult * dt
	while self.spark.spawn_rate > 1.0 do
		local dx, dz = radius * UnitRand(), radius * UnitRand()
		local x, y, z = px + dx, py, pz + dz
		if self.spark.checkfn(self, map, x, y, z) then
			self.spark.spawnfn(self, x, y, z)
		end
		self.spark.spawn_rate = self.spark.spawn_rate - 1.0
	end

	if self.sparks_per_sec_mod <= 0.0 then
		self.inst:StopUpdatingComponent(self)
	end
end
--[[
function MoonstormLightningManager:GetDebugString()
	return nil
end
]]
return MoonstormLightningManager
