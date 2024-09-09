local _overriders = {}

local function _reg_active_overrider(inst)
	_overriders[inst] = true
end

local function _unreg_active_overrider(inst)
	_overriders[inst] = nil
end

----------------------------------------------------------------------------------
-- Globals

function GetTemperatureAtXZ(x, z)
	local mindsq = math.huge
	local closest_ent = nil
	for ent in pairs(_overriders) do
		local dsq = ent:GetDistanceSqToPoint(x, 0, z)
		if dsq < mindsq then
			local r = ent.components.temperatureoverrider:GetActiveRadius()
			if dsq <= r * r then
				--for dsq check, use <=, not <, to match spatial hash query
				mindsq = dsq
				closest_ent = ent
			end
		end
	end

	return closest_ent ~= nil
		and closest_ent.components.temperatureoverrider:GetTemperature()
		or TheWorld.state.temperature
end

function GetLocalTemperature(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    return GetTemperatureAtXZ(x, z)
end

----------------------------------------------------------------------------------

local function onradius(self, radius, oldradius)
    if self.enabled then
        self:SetActiveRadius_Internal(radius, oldradius or 0)
    end
end

local function OnActiveRadiusDirty(inst)
    local self = inst.components.temperatureoverrider
	if self._activeradius:value() == 0 then
		_unreg_active_overrider(inst)
	else
		_reg_active_overrider(inst)
	end
end

local TemperatureOverrider = Class(function(self, inst)
    self.inst = inst

    -- Cache variables.
    self.ismastersim = TheWorld.ismastersim

    -- Network variables.
    self._activeradius = net_float(inst.GUID, "temperatureoverrider._activeradius", "_activeradiusdirty" )
    self._temperature  = net_float(inst.GUID, "temperatureoverrider._temperature"                        )

    if self.ismastersim then
        --Server only
        self.radius = 16
        self.enabled = false
        self._temperature:set(25)
    else
		inst:ListenForEvent("_activeradiusdirty", OnActiveRadiusDirty)
    end
end,
nil,
{
    radius = onradius,
})

----------------------------------------------------------------------------------
-- Globals

function TemperatureOverrider:OnRemoveFromEntity()
    assert(false)
end

function TemperatureOverrider:OnRemoveEntity()
    if self._activeradius:value() ~= 0 then
		_unreg_active_overrider(self.inst)
    end
end

function TemperatureOverrider:GetActiveRadius()
    return self._activeradius:value()
end

function TemperatureOverrider:GetTemperature()
    return self._temperature:value()
end

----------------------------------------------------------------------------------
-- Master Sim

function TemperatureOverrider:SetTemperature(temperature)
    if self.ismastersim then
        self._temperature:set(temperature)
    end
end

function TemperatureOverrider:SetRadius(radius)
    if self.ismastersim then
        self.radius = radius
    end
end

function TemperatureOverrider:Enable()
    if self.ismastersim and not self.enabled then
        self.enabled = true
        self:SetActiveRadius_Internal(self.radius, 0)
    end
end

function TemperatureOverrider:Disable()
    if self.ismastersim and self.enabled then
        self.enabled = false
        self:SetActiveRadius_Internal(0, self.radius)
    end
end

function TemperatureOverrider:SetActiveRadius_Internal(new, old)
    if new ~= old then
		if new == 0 then
			_unreg_active_overrider(self.inst)
		elseif old == 0 then
			_reg_active_overrider(self.inst)
		end
        self._activeradius:set(new)
    end
end

return TemperatureOverrider
