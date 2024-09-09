--------------------------------------------------------------------------
--[[ WorldReset class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local SYNC_PERIOD_SLOW = 5
local SYNC_PERIOD_FAST = 2

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
local _resetting = false
local _countdownf = nil
local _lastcountdown = nil
local _dtoverride = 0

--Master simulation
local _instant
local _countdownmax
local _countdownloadingmax
local _syncperiod
local _cancelwhenempty
local _wasempty

--Network
local _countdown = net_byte(inst.GUID, "worldreset._countdown", "countdowndirty")

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function UpdateCountdown(time)
    _world:PushEvent("worldresettick", { time = time })
end

local OnWorldResetFromSim = _ismastershard and function()
    if _updating then
        inst:StopUpdatingComponent(self)
        _updating = false
    end
    _resetting = true
end or nil

local function ShowResetDialog()
    if not _shown then
        _shown = true
        if _ismastershard then
            inst:ListenForEvent("ms_worldreset", OnWorldResetFromSim, _world)
        end
    end
    _world:PushEvent("showworldreset")
    if _lastcountdown ~= nil then
        UpdateCountdown(_lastcountdown)
    end
end

local function HideResetDialog()
    if _shown then
        _shown = false
        if _ismastershard then
            inst:RemoveEventCallback("ms_worldreset", OnWorldResetFromSim, _world)
        end
    end
    _world:PushEvent("hideworldreset")
end

local DoDeleteAndReset = _ismastershard and function()
    if IsXB1() and TheInputProxy:IsMainUserChanged() then
        --print("We are restarting the game instead of resetting the world")
        TheSim:SendCommandToInstance(Instances.Player1, "DoRestart")
        return
    end
    TheNet:SendWorldResetRequestToServer()
end or nil

local WorldReset = _ismastershard and function()
    if _resetting then
        return
    end
    _resetting = true
    if TheNet:IsDedicated() then
        DoDeleteAndReset()
    else
        TheFrontEnd:Fade(FADE_OUT, .25, DoDeleteAndReset)
    end
end or nil

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function CancelCountdown()
    if _resetting then
        return
    end
    if _updating then
        print("Stop world reset countdown")
        inst:StopUpdatingComponent(self)
        _updating = false
    end
    if _ismastershard then
        TheNet:SetIsWorldResetting(false)
        _countdown:set(0)
        _cancelwhenempty = false
    end
    _countdownf = nil
    _lastcountdown = nil
    HideResetDialog()
end

local function OnCountdownDirty()
    if _resetting then
        return
    elseif _countdown:value() > 0 then
        if not _updating then
            print("Start world reset countdown... "..tostring(_countdown:value()).." seconds...")
            inst:StartUpdatingComponent(self)
            _updating = true
            ShowResetDialog()
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
    if _ismastershard then
        _world:PushEvent("master_worldresetupdate", { countdown = _countdown:value() })
    end
end

local function OnRefreshDialog()
    if _resetting then
        return
    elseif _shown then
        ShowResetDialog()
    else
        HideResetDialog()
    end
end

local OnPlayerCounts = _ismastershard and function(src, data)
    if _resetting then
        return
    elseif data.ghosts < data.total then
        CancelCountdown()
    elseif data.total <= 0 then
        if _cancelwhenempty then
            CancelCountdown()
        end
    elseif _instant then
        if _ismastershard then
            WorldReset()
        end
    elseif _countdown:value() <= 0 then
        --everyone's a ghost, it's hopeless, sigh...
        --3 min bonus time if loading
        TheNet:SetIsWorldResetting(true)
        local countdown = _wasempty and _countdownloadingmax or _countdownmax
        _countdown:set(countdown < 255 and countdown or 255)
        _syncperiod = _countdown:value() > 10 and SYNC_PERIOD_SLOW or SYNC_PERIOD_FAST
        _cancelwhenempty = _wasempty and TheNet:IsDedicated()
    end
    _wasempty = data.total <= 0
end or nil

local OnSetWorldResetTime = _ismastershard and function(src, data)
    local wasenabled = _countdownmax > 0 or _instant
    _instant = data ~= nil and data.instant or false
    _countdownmax = data ~= nil and data.time or 0
    _countdownloadingmax = data ~= nil and data.loadingtime or _countdownmax
    if wasenabled ~= (_countdownmax > 0 or _instant) then
        if wasenabled then
            inst:RemoveEventCallback("ms_playercounts", OnPlayerCounts, _world)
            CancelCountdown()
            _wasempty = true
        else
            inst:ListenForEvent("ms_playercounts", OnPlayerCounts, _world)
            OnPlayerCounts(_world,
            {
                total = _world.shard.components.shard_players:GetNumPlayers(),
                ghosts = _world.shard.components.shard_players:GetNumGhosts(),
                alive = _world.shard.components.shard_players:GetNumAlive(),
            })
        end
    end
end or nil

local OnWorldResetUpdate = _ismastersim and not _ismastershard and function(src, data)
    _countdown:set(data.countdown)
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register network variable sync events
inst:ListenForEvent("countdowndirty", OnCountdownDirty)

if not (_ismastersim and TheNet:IsDedicated()) then
    --Register events
    inst:ListenForEvent("playeractivated", OnRefreshDialog, _world)
    inst:ListenForEvent("entercharacterselect", OnRefreshDialog, _world)
end

if _ismastersim then
    if _ismastershard then
        --Initialize master simulation variables
        _instant = false
        _countdownmax = 0
        _countdownloadingmax = 0
        _syncperiod = SYNC_PERIOD_SLOW
        _cancelwhenempty = false
        _wasempty = true

        --Register master simulation events
        inst:ListenForEvent("ms_setworldresettime", OnSetWorldResetTime, _world)
    else
        --Register secondary shard events
        inst:ListenForEvent("secondary_worldresetupdate", OnWorldResetUpdate, _world)
    end

    --Also reset this flag in case it's invalid
    TheNet:SetIsWorldResetting(false)
end

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    OnCountdownDirty()
    if not _ismastersim and _countdown:value() > 0 then
        --HACK: fast forward a bit, donno where we seem to be getting
        --      some delay to process the packet after loading
        _dtoverride = _dtoverride + 4
    end
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
        else
            _countdown:set_local(newcountdown + 1)
            if newcountdown < _lastcountdown then
                _lastcountdown = newcountdown
                UpdateCountdown(newcountdown)
            end
        end
    end

    if _countdownf <= 0 then
        if _updating then
            inst:StopUpdatingComponent(self)
            _updating = false
        end
        if _ismastershard then
            WorldReset()
        end
    end
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
