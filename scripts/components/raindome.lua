--------------------------------------------------------------------------
local _sizes = {}
local _maxsize = 0

local function _reg_active_dome_size(size)
	_maxsize = math.max(size, _maxsize)
	_sizes[size] = (_sizes[size] or 0) + 1
end

local function _unreg_active_dome_size(size)
	if _sizes[size] > 1 then
		_sizes[size] = _sizes[size] - 1
	else
		_sizes[size] = nil
		if size == _maxsize then
			_maxsize = 0
			for k in pairs(_sizes) do
				_maxsize = math.max(k, _maxsize)
			end
		end
	end
end

--------------------------------------------------------------------------
--GLOBAL--

local DOME_TAGS = { "raindome" }

function GetRainDomesAtXZ(x, z)
	if _maxsize <= 0 then
		return {}
	end
	local domes = TheSim:FindEntities(x, 0, z, _maxsize, DOME_TAGS)
	for i = #domes, 1, -1 do
		local v = domes[i]
		local r = v.components.raindome:GetActiveRadius()
		if r < _maxsize and v:GetDistanceSqToPoint(x, 0, z) > r * r then
			--for dsq check, use >, not >=, to match spatial hash query
			table.remove(domes, i)
		end
	end
	return domes
end

function IsUnderRainDomeAtXZ(x, z)
	if _maxsize <= 0 then
		return false
	end
	local domes = TheSim:FindEntities(x, 0, z, _maxsize, DOME_TAGS)
	for i = 1, #domes do
		local v = domes[i]
		local r = v.components.raindome:GetActiveRadius()
		if r >= _maxsize or v:GetDistanceSqToPoint(x, 0, z) <= r * r then
			--for dsq check, use <=, not <, to match spatial hash query
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------

local function onradius(self, radius, oldradius)
	if self.enabled then
		self:SetActiveRadius_Internal(radius, oldradius or 0)
	end
end

local function OnActiveRadiusDirty(inst)
	local self = inst.components.raindome
	if self._lastactiveradius ~= 0 then
		_unreg_active_dome_size(self._lastactiveradius)
	end
	self._lastactiveradius = self._activeradius:value()
	if self._lastactiveradius ~= 0 then
		_reg_active_dome_size(self._lastactiveradius)
	end
end

local RainDome = Class(function(self, inst)
	self.inst = inst

	--cache variables
	self.ismastersim = TheWorld.ismastersim

	--network variables
	self._activeradius = net_float(inst.GUID, "raindome._activeradius", "_activeradiusdirty")

	if self.ismastersim then
		--Server only
		self.radius = 16
		self.enabled = false
		--self.targets = nil
		--self.newtargets = nil
		--self.delay = nil
	else
		self._lastactiveradius = 0
		inst:ListenForEvent("_activeradiusdirty", OnActiveRadiusDirty)
	end
end,
nil,
{
	radius = onradius,
})

--------------------------------------------------------------------------
--Client & Server

function RainDome:OnRemoveFromEntity()
	assert(false)
end

function RainDome:OnRemoveEntity()
	if self._activeradius:value() ~= 0 then
		_unreg_active_dome_size(self._activeradius:value())
	end
end

function RainDome:GetActiveRadius()
	return self._activeradius:value()
end

--------------------------------------------------------------------------
--Master Sim

function RainDome:SetRadius(radius)
	if self.ismastersim then
		self.radius = radius
	end
end

function RainDome:Enable()
	if self.ismastersim and not self.enabled then
		self.enabled = true
		self:SetActiveRadius_Internal(self.radius, 0)
	end
end

function RainDome:Disable()
	if self.ismastersim and self.enabled then
		self.enabled = false
		self:SetActiveRadius_Internal(0, self.radius)
	end
end

function RainDome:SetActiveRadius_Internal(new, old)
	--assert(self.ismastersim)
	if new ~= old then
		if old ~= 0 then
			_unreg_active_dome_size(old)
			if new == 0 then
				--assert(self.targets ~= nil)
				for tgt in pairs(self.targets) do
					if tgt.components.rainimmunity ~= nil and tgt:IsValid() then
						tgt.components.rainimmunity:RemoveSource(self.inst)
					end
				end
				self.targets = nil
				self.newtargets = nil
				self.delay = nil
				self.inst:RemoveTag("raindome")
				self.inst:StopUpdatingComponent(self)
			end
		end
		if new ~= 0 then
			if old == 0 then
				assert(self.targets == nil)
				self.targets = {}
				self.newtargets = {}
				self.delay = math.random() * .5
				self.inst:AddTag("raindome")
				self.inst:StartUpdatingComponent(self)
			end
			_reg_active_dome_size(new)
		end
		self._activeradius:set(new)
	end
end

local TAGS = { "inspectable" }
local NOTAGS = { "INLIMBO" }

function RainDome:OnUpdate(dt)
	--assert(self.ismastersim)
	if self.delay > dt then
		self.delay = self.delay - dt
		return
	end

	local awake = not self.inst:IsAsleep()

	local oldtargets = self.targets
	local x, y, z = self.inst.Transform:GetWorldPosition()
	for _, target in ipairs(TheSim:FindEntities(x, y, z, self.radius, TAGS, NOTAGS)) do
		if oldtargets[target] then
			oldtargets[target] = nil
		else
			if not target.components.rainimmunity then
				target:AddComponent("rainimmunity")
			end
			target.components.rainimmunity:AddSource(self.inst)
		end
		self.newtargets[target] = true
		awake = awake or not target:IsAsleep()
	end
	for tgt in pairs(oldtargets) do
		if tgt.components.rainimmunity ~= nil and tgt:IsValid() then
			tgt.components.rainimmunity:RemoveSource(self.inst)
		end
		oldtargets[tgt] = nil
	end
	self.targets = self.newtargets
	self.newtargets = oldtargets --just swapping over the now empty table

	self.delay = awake and 1 or 3
end

return RainDome
