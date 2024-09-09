--------------------------------------------------------------------------
--[[ SingingShellManager class definition ]]
--------------------------------------------------------------------------

-- This component is dynamically added to the world from the singing shell
-- prefabs whenever it is relevant for any player to start checking for
-- them. It is removed when there is no longer any need to keep checking.

return Class(function(self, inst)

assert(TheWorld.ismastersim, "SingingShellManager should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

self.active_shells = {}
self.players_should_run_update = false

local function StartUpdatingPlayers()
	for _, v in ipairs(AllPlayers) do
		v.components.singingshelltrigger:StartUpdating()
	end
end

StartUpdatingPlayers()

local function StopUpdatingPlayers()
	for _, v in ipairs(AllPlayers) do
		v.components.singingshelltrigger:StopUpdating()
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnShellWake(inst, shell)
	self.active_shells[shell] = true
end

local function OnShellSleep(inst, shell)
	self.active_shells[shell] = nil
	if next(self.active_shells) == nil then
		self.inst:RemoveComponent("singingshellmanager")
	end
end

local function OnPlayerJoined(inst)
	StartUpdatingPlayers()
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("singingshell_wake", OnShellWake)
inst:ListenForEvent("singingshell_sleep", OnShellSleep)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:OnRemoveFromEntity()
	StopUpdatingPlayers()
end

function self:RememberActiveShell(shell)
	OnShellWake(self.inst, shell)
end

function self:ForgetActiveShell(shell)
	OnShellSleep(self.inst, shell)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

-- function self:GetDebugString()
-- end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
