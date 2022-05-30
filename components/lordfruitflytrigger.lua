local FRUITFLYSPAWNER_MUST_TAGS = { "fruitflyspawner" }
local function findentities(inst, range)
	local x, y, z = inst.Transform:GetWorldPosition()
	return TheSim:FindEntities(x, y, z, range, FRUITFLYSPAWNER_MUST_TAGS)
end

local function ondeath(inst)
	inst.components.lordfruitflytrigger:StopUpdating()
end

local function onresurrect(inst)
	inst.components.lordfruitflytrigger:StartUpdating()
end

local function ontimerfinished(self)
    self.overlapping = {}
end

local LordFruitFlyTrigger = Class(function(self, inst)
	self.inst = inst

	self.trigger_range = 15
	self.findentitiesfn = findentities

	self.updating = false
	self.overlapping = {}

	if TheWorld.components.farming_manager ~= nil then
        self:StartUpdating()
	end

    self.inst:AddTag("lordfruitflytrigger")
    self:StartUpdating()

    function self._ontimerfinished() ontimerfinished(self) end
    self.inst:ListenForEvent("ms_fruitflytimerfinished", self._ontimerfinished, TheWorld)
	self.inst:ListenForEvent("death", ondeath)
	self.inst:ListenForEvent("respawnfromghost", onresurrect)
end)

function LordFruitFlyTrigger:OnRemoveFromEntity()
    self.inst:RemoveTag("lordfruitflytrigger")
    self.inst:RemoveEventCallback("ms_fruitflytimerfinished", self._ontimerfinished, TheWorld)
	self.inst:RemoveEventCallback("death", ondeath)
	self.inst:RemoveEventCallback("respawnfromghost", onresurrect)
end

function LordFruitFlyTrigger:StartUpdating()
	if not self.updating then
		self.inst:StartUpdatingComponent(self)
		self.updating = true
	end
end

function LordFruitFlyTrigger:StopUpdating()
	if self.updating then
		self.inst:StopUpdatingComponent(self)
		self.updating = false
	end
end

function LordFruitFlyTrigger:OnUpdate()
	for k, v in pairs(self.overlapping) do
		if v == true then
			self.overlapping[k] = false
		else
			self.overlapping[k] = nil
		end
	end

	for i, v in ipairs(self.findentitiesfn(self.inst, self.trigger_range)) do
		if self.overlapping[v] == nil then
			self.overlapping[v] = true
			v._activatefn(v, self.inst)
		elseif self.overlapping[v] == false then
			self.overlapping[v] = true
		end
	end
end

return LordFruitFlyTrigger