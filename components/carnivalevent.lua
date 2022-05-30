--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ CarnivalEvent class definition ]]
--------------------------------------------------------------------------
return Class(function(self, inst)

assert(TheWorld.ismastersim, "CarnivalEvent should not exist on client")

--------------------------------------------------------------------------
--[[ Private constants ]]
--------------------------------------------------------------------------

local PORTAL_LONG_DIST = 12
local PORTAL_SHORT_DIST = 6

--------------------------------------------------------------------------
--[[ Public Member Variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private Member Variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _carnival_host
local _openpts = {}
local _plazas = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetCarnivalHostPortalLocation()
	local pos = Vector3(TheWorld.components.playerspawner:GetAnySpawnPoint())

	local offset = FindWalkableOffset(pos, math.random() * 2 * PI, PORTAL_LONG_DIST, 16)
					or FindWalkableOffset(pos, math.random() * 2 * PI, PORTAL_SHORT_DIST, 16)
					or Vector3(0, 0, 0)

    return pos + offset
end

local SpawnCarnivalHost

local function OnCarnivalHostRemoved(src)
	_carnival_host = nil
	SpawnCarnivalHost()
end

SpawnCarnivalHost = function(carnival_host, loading)
	if not IsSpecialEventActive(SPECIAL_EVENTS.CARNIVAL) then
		return
	end

	if carnival_host then
		_carnival_host = carnival_host
	else
		_carnival_host = carnival_host or SpawnPrefab("carnival_host")
		if _carnival_host.components.knownlocations:GetLocation("home") == nil then
			local pos = GetCarnivalHostPortalLocation()
			_carnival_host.components.knownlocations:RememberLocation("home", pos)
			_carnival_host.Transform:SetPosition(pos.x, 0, pos.z)
		end
		if not loading then
			_carnival_host.sg:GoToState("glide")
		end
	end

	_world:ListenForEvent("onremove", OnCarnivalHostRemoved, _carnival_host)
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--_world:ListenForEvent("ms_registerspawnpoint", OnRegisterSpawnPoint)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:RegisterPlaza(plaza)
	_plazas[plaza] = true
	TheWorld:PushEvent("ms_carnivalplazabuilt", plaza)
end

function self:UnregisterPlaza(plaza)
	_plazas[plaza] = nil
	--warning plaza should already return false for IsValid
	--TheWorld:PushEvent("ms_carnivalplazadestroyed", plaza)
end

function self:DoesAnyPlazaExist()
	return not IsTableEmpty(_plazas)
end

function self:GetRandomPlaza()
	return GetRandomItemWithIndex(_plazas)
end

function self:SummonHost(plaza)
	if _carnival_host == nil then
		return false
	end

	return _carnival_host:SummonedToPlaza(plaza)
end

function self:OnPostInit()
    if not _carnival_host then
		SpawnCarnivalHost(nil, true)
	end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	local data =
	{
	}

	local ents = {}
	if _carnival_host ~= nil then
		data.carnival_host = _carnival_host.GUID
		table.insert(ents, _carnival_host.GUID)
	end

	return data, ents
end

function self:OnLoad(data)

end

function self:LoadPostPass(newents, savedata)
	if savedata.carnival_host ~= nil and newents[savedata.carnival_host] ~= nil then
		SpawnCarnivalHost(newents[savedata.carnival_host].entity, true)
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

end)