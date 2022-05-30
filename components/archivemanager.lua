--------------------------------------------------------------------------
--[[ grottowarmanager class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "ArchiveManager should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------



--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _power_enabled = false


--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SwitchPowerOn(setting)
	print("SWITCHING ",setting)
	if _power_enabled ~= true and setting == true then
		print("ARCHIVE ON")
		_power_enabled = true
		self.inst:PushEvent("arhivepoweron")
	elseif _power_enabled ~= false and setting  == false then
		print("ARCHIVE OFF")
		_power_enabled = false
		self.inst:PushEvent("arhivepoweroff")
	end
end

function self:GetPowerSetting()
	return _power_enabled
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
--inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return
	{
		power_enabled = _power_enabled,
	}
end

function self:OnLoad(data)
	if data._power_enabled then
		_power_enabled = data._power_enabled
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return tostring(_power_enabled)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)