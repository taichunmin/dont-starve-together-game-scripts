--------------------------------------------------------------------------
--[[ WorldCharacterSelectLobby class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local ALLOW_DEBUG_START = BRANCH == "dev"

local COUNTDOWN_TIME = ALLOW_DEBUG_START and 1 or 6
local COUNTDOWN_INACTIVE = 255

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim

local _lobby_up_time = 0
local _client_wait_time = {}

--Master simulation
local _countdownf = -1

--Network
local _countdowni = net_byte(inst.GUID, "worldcharacterselectlobby._countdowni", "spawncharacterdelaydirty")
local _lockedforshutdown = net_bool(inst.GUID, "worldcharacterselectlobby._lockedforshutdown", "lockedforshutdown")

local _nowaiting_vote = {}
for i = 1, TheNet:GetServerMaxPlayers() do
	table.insert(_nowaiting_vote, net_string(inst.GUID, "worldcharacterselectlobby._nowaiting_vote."..i, "nowaiting_vote_dirty"))
end

--------------------------------------------------------------------------
--[[ Local Functions ]]
--------------------------------------------------------------------------
local function GetPlayersClientTable()
    local clients = TheNet:GetClientTable() or {}
    if not TheNet:GetServerIsClientHosted() then
		for i, v in ipairs(clients) do
			if v.performance ~= nil then
				table.remove(clients, i) -- remove "host" object
				break
			end
		end
    end
    return clients
end

local function SetNoWaitingVote(userid, no_waiting)
	if _countdowni:value() ~= COUNTDOWN_INACTIVE then
		return
	end
	    
    if no_waiting then
		local empty_slot = nil
		for i, v in ipairs(_nowaiting_vote) do
			local value = v:value()
			if value == userid then
				return
			elseif value == "" then
				empty_slot = i
			end
		end
		if empty_slot ~= nil then
			_nowaiting_vote[empty_slot]:set(userid)
		end
    else
		for i, v in ipairs(_nowaiting_vote) do
			if v:value() == userid then
				_nowaiting_vote[i]:set("")
				return
			end
		end
	end
end

local function ToggleNoWaitingVote(userid)
	if _countdowni:value() ~= COUNTDOWN_INACTIVE then
		return
	end

	local empty_slot = nil
	for i, v in ipairs(_nowaiting_vote) do
		local value = v:value()
		if value == userid then
			_nowaiting_vote[i]:set("")
			return
		elseif value == "" then
			empty_slot = i
		end
	end
	if empty_slot ~= nil then
		_nowaiting_vote[empty_slot]:set(userid)
	end
end

--------------------------------------------------------------------------
--[[ Global Setup ]]
--------------------------------------------------------------------------

AddUserCommand("nowaitingforplayers", {
    prettyname = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.PRETTYNAME
    desc = nil, --default to STRINGS.UI.BUILTINCOMMANDS.RESCUE.DESC
    permission = COMMAND_PERMISSION.USER,
    slash = false,
    usermenu = false,
    servermenu = false,
    params = {"no_waiting"},
    vote = false,
    canstartfn = function(command, caller, targetid)
        return _countdowni:value() == COUNTDOWN_INACTIVE and not _lockedforshutdown:value()
    end,
    serverfn = function(params, caller)
		--SetNoWaitingVote(caller.userid, params.no_waiting == "true")
		ToggleNoWaitingVote(caller.userid)
    end,
})

--------------------------------------------------------------------------
--[[ Private Server event handlers ]]
--------------------------------------------------------------------------

local function ClearNoWaitingVotes()
	for i, v in ipairs(_nowaiting_vote) do
		v:set("")
	end
end

local function StarTimer(time)
	print ("[WorldCharacterSelectLobby] Countdown started")

	local msg = {}	
	msg.up_time = _lobby_up_time and (GetTimeRealSeconds() - _lobby_up_time) or 0
	TheWorld.components.lavaarenaanalytics:SendAnalyticsLobbyEvent("forge.lobby.startmatch", nil, msg)
	
	_countdownf = time
    _countdowni:set(math.ceil(time))

	TheNet:SetAllowNewPlayersToConnect(false)
    TheNet:SetIsMatchStarting(true)
	ClearNoWaitingVotes()

	self.inst:StartWallUpdatingComponent(self)
end

local function CountStartWithoutWaitingPlayers()
	local count = 0
	for i, v in ipairs(_nowaiting_vote) do
		if v:value() ~= "" then
			count = count + 1
		end
	end
	return count
end

local function TryStartCountdown()
	if not self:IsAllowingCharacterSelect() then
		return false
	end

    local clients = GetPlayersClientTable()
	if #clients < TheNet:GetServerMaxPlayers() and #clients > CountStartWithoutWaitingPlayers() then
		return false
	end
	for _, v in ipairs(clients) do
        if v.lobbycharacter == nil or v.lobbycharacter == "" then
            return
        end
    end

	StarTimer(COUNTDOWN_TIME)
end

local function OnRequestLobbyCharacter(world, data)
	if data == nil or not self:IsAllowingCharacterSelect() then
		return
	end

	local client = TheNet:GetClientTableForUser(data.userid)
	if not client then
		return
	end

	TheNet:SetLobbyCharacter(data.userid, data.prefab_name, data.skin_base, data.clothing_body, data.clothing_hand, data.clothing_legs, data.clothing_feet)
	SetNoWaitingVote(data.userid, false)
	
	TryStartCountdown()
end

local function OnLobbyClientConnected(src, data)
	ClearNoWaitingVotes()

	if _countdowni:value() == COUNTDOWN_INACTIVE then
		if GetTableSize(_client_wait_time) == 0 then
			_lobby_up_time = GetTimeRealSeconds()
		end
		_client_wait_time[data.userid] = GetTimeRealSeconds()

		local msg = {}
		msg.up_time = _lobby_up_time and (GetTimeRealSeconds() - _lobby_up_time) or 0
		TheWorld.components.lavaarenaanalytics:SendAnalyticsLobbyEvent("forge.lobby.join", data.userid, msg)
		
	else		
		-- TODO: force disconnection
	end
end

local function OnLobbyClientDisconnected(src, data)
	ClearNoWaitingVotes()

	if self:IsAllowingCharacterSelect() and _client_wait_time[data.userid] ~= nil then
		local wait_time = _client_wait_time[data.userid] and (GetTimeRealSeconds() - _client_wait_time[data.userid]) or 0
		_client_wait_time[data.userid] = nil 
		local num_remaining_players = GetTableSize(_client_wait_time)

		local msg = {}
		msg.up_time = _lobby_up_time and (GetTimeRealSeconds() - _lobby_up_time) or 0
		msg.duration = wait_time
		msg.consecutive_match = TheNet:IsConsecutiveMatchForPlayer(data.userid)
		TheWorld.components.lavaarenaanalytics:SendAnalyticsLobbyEvent("forge.lobby.leave", data.userid, msg)
		
		if GetTableSize(_client_wait_time) == 0 then
			local msg = {}
			msg.up_time = _lobby_up_time and (GetTimeRealSeconds() - _lobby_up_time) or 0
			TheWorld.components.lavaarenaanalytics:SendAnalyticsLobbyEvent("forge.lobby.cancelmatch", nil, msg)

			_lobby_up_time = nil
		end
	end
end



--------------------------------------------------------------------------
--[[ Private Client event handlers ]]
--------------------------------------------------------------------------

local function OnCountdownDirty()
    if _ismastersim and _countdowni:value() == 0 then
        inst:StopWallUpdatingComponent(self)
        print("[WorldCharacterSelectLobby] Countdown finished")

        --Use regular update to poll for when to clear match starting flag
        inst:StartUpdatingComponent(self)
    end

    local t = _countdowni:value()
    _world:PushEvent("lobbyplayerspawndelay", { time = t, active = t ~= COUNTDOWN_INACTIVE })
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize network variables
_countdowni:set(COUNTDOWN_INACTIVE)

--Register network variable sync events
inst:ListenForEvent("spawncharacterdelaydirty", OnCountdownDirty)

if _ismastersim then
    TheNet:SetIsMatchStarting(false) --Reset flag in case it's invalid

    --Register events
    inst:ListenForEvent("ms_requestedlobbycharacter", OnRequestLobbyCharacter, _world)
    inst:ListenForEvent("nowaiting_vote_dirty", TryStartCountdown)
    inst:ListenForEvent("ms_clientauthenticationcomplete", OnLobbyClientConnected, _world)
    inst:ListenForEvent("ms_clientdisconnected", OnLobbyClientDisconnected, _world)

	local clients = GetPlayersClientTable()
	for _, c in ipairs(clients) do
		OnLobbyClientConnected(TheWorld, {userid = c.userid})
	end
end

--------------------------------------------------------------------------
--[[ Public members ]]
--------------------------------------------------------------------------

function self:GetSpawnDelay()
	local delay = _countdowni:value()
	return delay ~= COUNTDOWN_INACTIVE and delay or -1
end

if _ismastersim then function self:IsAllowingCharacterSelect()
	return _countdowni:value() == COUNTDOWN_INACTIVE and not _lockedforshutdown:value()
end end

function self:IsServerLockedForShutdown()
	return _lockedforshutdown:value()
end

function self:GetNoWaitingVote(userid)
	for i, v in ipairs(_nowaiting_vote) do
		if v:value() == userid then
			return true
		end
	end
	return false
end

if _ismastersim then function self:OnPostInit()
	if TheNet:GetDeferredServerShutdownRequested() then
		_lockedforshutdown:set(true)
	end
end end

-- TheWorld.net.components.worldcharacterselectlobby:Dump()
function self:Dump()
	local str = ""
	for i, v in ipairs(_nowaiting_vote) do
		str = str .. ", " .. tostring(v:value())
	end
	print(str)
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnWallUpdate(dt)
	_countdownf = math.max(0, _countdownf - dt)
	local c = math.ceil(_countdownf)
	if _countdowni:value() ~= c then
		_countdowni:set(c)
	end
end

function self:OnUpdate(dt)
    if #AllPlayers <= 0 then
        local isdedicated = not TheNet:GetServerIsClientHosted()
        local index = 1
        for i, v in ipairs(TheNet:GetClientTable()) do
            if not isdedicated or v.performance == nil then
                --Still someone connected
                return
            end
        end
    end
    --Either someone has spawned in, or everybody disconnceted
    TheNet:SetIsMatchStarting(false)
    inst:StopUpdatingComponent(self)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

if _ismastersim then function self:OnSave()
	local data =
	{
		match_started = _countdowni:value() == 0,
	}

	return data
end end

if _ismastersim then function self:OnLoad(data)
	if data then
		if data.match_started then
			_countdownf = 0
			_countdowni:set(0)
			inst:DoTaskInTime(0, function() TheNet:SetAllowNewPlayersToConnect(false) end)
		end
	end
end end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)