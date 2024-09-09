--------------------------------------------------------------------------
--[[ WorldVoter class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local UserCommands = require("usercommands")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_SLOTS = 64

local SYNC_PERIOD_SLOW = 5
local SYNC_PERIOD_FAST = 2
local END_VOTE_DELAY = 2 --delay closing the dialog after last vote received

--Keep in sync with shard_worldvoter.lua and playervoter.lua
local CANNOT_VOTE = 0
local VOTE_PENDING = MAX_VOTE_OPTIONS + 1

--player_classified.voteselection is a net_tinybyte
assert(VOTE_PENDING <= 7, "Vote options limited by network data type.")

local DEFAULT_VOTE_OPTIONS = { STRINGS.UI.VOTEDIALOG.YES, STRINGS.UI.VOTEDIALOG.NO }

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _world = TheWorld
local _ismastersim = _world.ismastersim
local _ismastershard = _world.ismastershard
local _updating = false
local _shown = false
local _countdownf = nil
local _lastcountdown = nil
local _dtoverride = 0
local _dialogdata = nil

--Master simulation
local _syncperiod
local _voterdata
local _votesdirty
local _resultdelay
local _squelched
local _numsquelched
local _targetname

--Network
local _enabled = net_bool(inst.GUID, "worldvoter._enabled")
local _countdown = net_byte(inst.GUID, "worldvoter._countdown", "countdowndirty")
local _commandid = net_uint(inst.GUID, "worldvoter._commandid")
local _targetuserid = net_string(inst.GUID, "worldvoter._targetuserid")
local _starteruserid = net_string(inst.GUID, "worldvoter._starteruserid")
local _votecounts = {}
for i = 1, MAX_VOTE_OPTIONS do
    table.insert(_votecounts, net_byte(inst.GUID, "worldvoter._votecounts["..tostring(i).."]", "votecountsdirty"))
end

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function UpdateCountdown(time)
    _world:PushEvent("worldvotertick", { time = time })
end

local function GetVoteDialogData(commandhash, targetuserid, starteruserid)
    --Re-cache table only when needed
    if _dialogdata == nil or
        _dialogdata.hash ~= commandhash or
        _dialogdata.targetuserid ~= targetuserid or
        _dialogdata.starteruserid ~= starteruserid then
        local command = UserCommands.GetCommandFromHash(commandhash)
        if command ~= nil and command.vote then
            _dialogdata =
            {
                name = command.name,
                hash = command.hash,
                targetuserid = targetuserid,
                starteruserid = starteruserid,
                cantargetself = command.cantargetself,
                votecountvisible = command.votecountvisible,
                votetitlefmt = command.votetitlefmt,
                votetimeout = command.votetimeout,
                options = {},
            }

            if targetuserid ~= nil and targetuserid ~= "" then
                for i, v in ipairs(TheNet:GetClientTable() or {}) do
                    if v.userid == targetuserid and (v.performance == nil or TheNet:GetServerIsClientHosted()) then
                        _dialogdata.targetclient = v
                        break
                    end
                end
            end

            if starteruserid ~= nil and starteruserid ~= "" then
                for i, v in ipairs(TheNet:GetClientTable() or {}) do
                    if v.userid == starteruserid and (v.performance == nil or TheNet:GetServerIsClientHosted()) then
                        _dialogdata.starterclient = v
                        break
                    end
                end
            end

            for i, v in ipairs(command.voteoptions or DEFAULT_VOTE_OPTIONS) do
                table.insert(_dialogdata.options, { description = v })
            end
        else
            _dialogdata = nil
        end
    end

    --Always update vote counts
    if _dialogdata ~= nil and _dialogdata.votecountvisible then
        for i, v in ipairs(_dialogdata.options) do
            v.vote_count = _votecounts[i] ~= nil and _votecounts[i]:value() or 0
        end
    end

    return _dialogdata
end

local function UpdateVoteCounts()
    local data = GetVoteDialogData(_commandid:value(), _targetuserid:value(), _starteruserid:value())
    if data ~= nil and data.votecountvisible then
        _world:PushEvent("votecountschanged", data)
    end
end

local function ShowVoteDialog()
    local data = GetVoteDialogData(_commandid:value(), _targetuserid:value(), _starteruserid:value())
    if not _shown then
        _shown = true
        print(string.format(
            "Vote started by (%s) %s: \"%s\" (%s) %s",
            data ~= nil and data.starteruserid or "",
            data ~= nil and data.starterclient ~= nil and data.starterclient.name or "",
            data ~= nil and data.name or "",
            data ~= nil and data.targetuserid or "",
            data ~= nil and data.targetclient ~= nil and data.targetclient.name or ""
        ))
    end
    _world:PushEvent("showvotedialog", data)
    if _lastcountdown ~= nil then
        UpdateCountdown(_lastcountdown)
    end
end

local function HideVoteDialog()
    if _shown then
        _shown = false
        print("Vote ended")
    end
    _world:PushEvent("hidevotedialog")
end

local UpdatePlayerSelection = _ismastersim and function(player)
    if player.components.playervoter ~= nil then
        player.components.playervoter:SetSelection(_voterdata ~= nil and _voterdata[player.userid] or CANNOT_VOTE)
    end
end or nil

local UpdatePlayerSquelched = _ismastersim and function(player)
    if player.components.playervoter ~= nil then
        player.components.playervoter:SetSquelched(_squelched ~= nil and _squelched[player.userid] and true or false)
    end
end or nil

local UpdatePlayerVoters = _ismastersim and function()
    local counts = {}
    if _voterdata ~= nil then
        for k, v in pairs(_voterdata) do
            if v > CANNOT_VOTE and v < VOTE_PENDING then
                counts[v] = (counts[v] or 0) + 1
            end
        end
    end
    for i, v in ipairs(_votecounts) do
        v:set(counts[i] or 0)
    end
    for i, v in ipairs(AllPlayers) do
        UpdatePlayerSelection(v)
    end
    UpdateVoteCounts()
end or nil

local UpdateSquelchedPlayers = _ismastersim and function()
    for i, v in ipairs(AllPlayers) do
        UpdatePlayerSquelched(v)
    end
end or nil

local PushMasterVoterData = _ismastershard and function()
    _world:PushEvent("master_worldvoterupdate", {
        countdown = _countdown:value(),
        commandid = _commandid:value(),
        targetuserid = _targetuserid:value(),
        starteruserid = _starteruserid:value(),
        voters = _voterdata,
    })
    UpdatePlayerVoters()
end or nil

local PushMasterSquelchedData = _ismastershard and function()
    _world:PushEvent("master_worldvotersquelchedupdate", {
        squelched = _squelched,
    })
    UpdateSquelchedPlayers()
end or nil

local OnEndSquelched = _ismastershard and function(inst, userid)
    if _squelched[userid] then
        _squelched[userid] = nil
        _numsquelched = _numsquelched - 1
        PushMasterSquelchedData()
    end
end or nil

local SquelchPlayer = _ismastershard and function(userid, duration)
    if userid ~= nil and duration > 0 then
        local temp = _squelched[userid]
        if temp ~= nil then
            temp:Cancel()
            --num squelched won't change if we were already squelched
        elseif _numsquelched < MAX_SLOTS then
            _numsquelched = _numsquelched + 1
        else
            --shard_worldvoter doesn't support more than MAX_SLOTS squelched at
            --a time, although it is highly unlikely that this can even happen.
            local mintime = math.huge
            local minuserid
            for k, v in pairs(_squelched) do
                local t = GetTaskRemaining(v)
                if t < mintime then
                    mintime = t
                    minuserid = k
                end
            end
            --commented sanity checks as reminders
            --assert(minuserid ~= nil)
            --assert(minuserid ~= userid)
            _squelched[minuserid]:Cancel()
            _squelched[minuserid] = nil
            --num squelched won't change because we're just replacing another one
        end
        _squelched[userid] = inst:DoTaskInTime(duration, OnEndSquelched, userid)
        if temp == nil then
            PushMasterSquelchedData()
        end
    end
end or nil

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function CancelCountdown()
    if _updating then
        inst:StopUpdatingComponent(self)
        _updating = false
    end
    HideVoteDialog()
    if _ismastershard then
        _countdown:set(0)
        _commandid:set(0)
        _targetuserid:set("")
        _starteruserid:set("")
        _voterdata = nil
        _votesdirty = false
        _resultdelay = nil
        _targetname = nil
        PushMasterVoterData()
    end
    _countdownf = nil
    _lastcountdown = nil
    _dialogdata = nil
end

local function OnCountdownDirty()
    if _countdown:value() > 0 then
        if not _updating then
            inst:StartUpdatingComponent(self)
            _updating = true
            ShowVoteDialog()
        end
        _countdownf = _countdown:value()
        local newcountdown = _countdownf - 1
        if _lastcountdown == nil or _lastcountdown > newcountdown then
            _lastcountdown = newcountdown
            UpdateCountdown(newcountdown)
        end
    else
        CancelCountdown()
    end
end

local function OnRefreshDialog()
    if _shown then
        ShowVoteDialog()
    else
        HideVoteDialog()
    end
end

local OnPlayerJoined = _ismastersim and function(world, player)
    UpdatePlayerSelection(player)
    UpdatePlayerSquelched(player)
end or nil

local OnStartVote = _ismastershard and function(src, data)
    if _shown or _dialogdata ~= nil then
        print("Cannot start a new vote while another is in progress")
    elseif data.starteruserid ~= nil and _squelched[data.starteruserid] ~= nil then
        print("Squelched user ("..data.starteruserid..") attempted to start a vote")
    else
		local starterclient = TheNet:GetClientTableForUser(data.starteruserid)
		local canstartvote, reason
		if starterclient ~= nil then
			canstartvote, reason = UserCommands.CanUserStartVote(data.commandhash, starterclient, data.targetuserid)
		end
		if not canstartvote then
			print("Blocked user ("..data.starteruserid..") from starting a vote due to: " .. (reason ~= nil and STRINGS.UI.PLAYERSTATUSSCREEN.VOTECANNOTSTART[reason] or "unknown"))
		else
			local newdata = GetVoteDialogData(data.commandhash, data.targetuserid, data.starteruserid)
			if newdata ~= nil then
				_countdown:set(math.min(255, newdata.votetimeout or TUNING.VOTE_TIMEOUT_DEFAULT))
				_commandid:set(data.commandhash)
				_targetuserid:set(data.targetuserid or "")
				_starteruserid:set(data.starteruserid or "")
				_syncperiod = _countdown:value() > 10 and SYNC_PERIOD_SLOW or SYNC_PERIOD_FAST
				_resultdelay = nil
				_votesdirty = false
				_voterdata = {}
				_targetname = UserToName(data.targetuserid)
				for i, v in ipairs(TheNet:GetClientTable() or {}) do
					if v.performance == nil or TheNet:GetServerIsClientHosted() then
						_voterdata[v.userid] = not newdata.cantargetself and v.userid == data.targetuserid and CANNOT_VOTE or VOTE_PENDING
					end
				end
				PushMasterVoterData()
			end
		end
    end
end or nil

local OnStopVote = _ismastershard and function()
    SquelchPlayer(_starteruserid:value(), TUNING.VOTE_CANCELLED_SQUELCH_TIME)
    CancelCountdown()
end or nil

local OnReceiveVote = _ismastershard and function(src, data)
    if _voterdata ~= nil and
        _voterdata[data.userid] == VOTE_PENDING and
        _dialogdata ~= nil and
        _dialogdata.options[data.selection] ~= nil then
        _voterdata[data.userid] = data.selection
        _votesdirty = true
        PushMasterVoterData()

        print(string.format(
            "Vote received: (%s) %s (%d)",
            data.userid,
            _dialogdata.options[data.selection].description or tostring(data.selection),
            _votecounts[data.selection] ~= nil and _votecounts[data.selection]:value() or 0
        ))
    end
end or nil

local CheckVoteResults = _ismastershard and function(timedout)
    _votesdirty = false
    if _voterdata ~= nil and _dialogdata ~= nil then
        local results =
        {
            total_not_voted = 0,
            total_voted = 0,
            total = 0,
            options = {},
        }
        for i, v in ipairs(_dialogdata.options) do
            table.insert(results.options, 0)
        end
        for i, v in pairs(_voterdata) do
            if v >= VOTE_PENDING then
                if not timedout then
                    --Not timed out yet, so keep waiting for everyone to vote
                    return
                end
                results.total_not_voted = results.total_not_voted + 1
            elseif v > CANNOT_VOTE and v <= #results.options then
                results.total_voted = results.total_voted + 1
                results.options[v] = results.options[v] + 1
            end
            results.total = results.total + 1
        end
        --All votes are in (or we're timed out)
        if not timedout and END_VOTE_DELAY ~= nil and END_VOTE_DELAY > 0 then
            --Delay 2 seconds before actually ending and the vote dialog
            _resultdelay = END_VOTE_DELAY
            return
        end
        local commandname = _dialogdata.name
        local targetuserid = _dialogdata.targetuserid
        local params = { user = targetuserid, username = _targetname }
        local starteruserid = _dialogdata.starteruserid
        CancelCountdown()
        local success = UserCommands.FinishVote(commandname, params, results)
        SquelchPlayer(starteruserid, success and TUNING.VOTE_PASSED_SQUELCH_TIME or TUNING.VOTE_FAILED_SQUELCH_TIME)
        UserCommands.SendVoteMetricsEvent(commandname, targetuserid, success, starteruserid)
    else
        OnStopVote()
    end
end or nil

local OnWorldVoterUpdate = _ismastersim and not _ismastershard and function(src, data)
    _countdown:set(data.countdown)
    _commandid:set(data.commandid)
    _targetuserid:set(data.targetuserid)
    _starteruserid:set(data.starteruserid)
    _voterdata = data.voters
    UpdatePlayerVoters()
end or nil

local OnWorldVoterSquelchedUpdate = _ismastersim and not _ismastershard and function(src, data)
    _squelched = data._squelched
    UpdateSquelchedPlayers()
end or nil

local OnWorldVoterEnabled = _ismastersim and not _ismastershard and function(src, data)
    _enabled:set(data)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register network variable sync events
inst:ListenForEvent("countdowndirty", OnCountdownDirty)

if not (_ismastersim and TheNet:IsDedicated()) then
    --Register events
    inst:ListenForEvent("playeractivated", OnRefreshDialog, _world)
    --inst:ListenForEvent("entercharacterselect", OnRefreshDialog, _world)
end

if _ismastersim then
    --Initialize master simulation variables
    _voterdata = nil

    inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, _world)

    if _ismastershard then
        --Initialize master simulation variables
        _syncperiod = SYNC_PERIOD_SLOW
        _votesdirty = false
        _resultdelay = nil
        _squelched = {}
        _numsquelched = 0
        _targetname = nil

        inst:ListenForEvent("ms_startvote", OnStartVote, _world)
        inst:ListenForEvent("ms_stopvote", OnStopVote, _world)
        inst:ListenForEvent("ms_receivevote", OnReceiveVote, _world)
    else
        _squelched = nil

        --Register secondary shard events
        inst:ListenForEvent("secondary_worldvoterupdate", OnWorldVoterUpdate, _world)
        inst:ListenForEvent("secondary_worldvotersquelchedupdate", OnWorldVoterSquelchedUpdate, _world)
        inst:ListenForEvent("secondary_worldvoterenabled", OnWorldVoterEnabled, _world)
    end
else
    inst:ListenForEvent("votecountsdirty", UpdateVoteCounts)
end

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    if _ismastershard and (TheNet:GetDefaultVoteEnabled() or BRANCH == "dev") then
        _enabled:set(true)
        _world:PushEvent("master_worldvoterenabled", true)
    end

    OnCountdownDirty()
    if not _ismastersim and _countdown:value() > 0 then
        --HACK: fast forward a bit, donno where we seem to be getting
        --      some delay to process the packet after loading
        _dtoverride = _dtoverride + 4
    end
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:IsVoteActive()
    return _shown
end

function self:IsEnabled()
    return _enabled:value()
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    if _dtoverride > 0 then
        dt = dt + _dtoverride
        _dtoverride = 0
    end

    if _countdownf <= dt then
        _countdownf = 0
    else
        _countdownf = _countdownf - dt
    end

    local newcountdown = math.floor(_countdownf)
    if _lastcountdown ~= newcountdown then
        if _ismastershard and (newcountdown <= 0 or (newcountdown % _syncperiod) == 0) then
            _countdown:set(newcountdown > 0 and (newcountdown + 1) or 1)
            PushMasterVoterData()
        else
            _countdown:set_local(newcountdown + 1)
            if newcountdown < _lastcountdown then
                _lastcountdown = newcountdown
                UpdateCountdown(newcountdown)
            end
        end
    end

    if _countdownf <= 0 then
        if _ismastershard then
            CheckVoteResults(true)
        elseif _updating then
            inst:StopUpdatingComponent(self)
            _updating = false
        end
    elseif _votesdirty then
        CheckVoteResults(false)
    elseif _resultdelay ~= nil then
        if _resultdelay > dt then
            _resultdelay = _resultdelay - dt
        else
            CheckVoteResults(true)
        end
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
