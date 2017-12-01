--------------------------------------------------------------------------
--[[ DynamicMusic class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local SEASON_BUSY_MUSIC =
{
    autumn = "dontstarve/music/music_work",
    winter = "dontstarve/music/music_work_winter",
    spring = "dontstarve_DLC001/music/music_work_spring",
    summer = "dontstarve_DLC001/music/music_work_summer",
}

local SEASON_EPICFIGHT_MUSIC =
{
    autumn = "dontstarve/music/music_epicfight",
    winter = "dontstarve/music/music_epicfight_winter",
    spring = "dontstarve_DLC001/music/music_epicfight_spring",
    summer = "dontstarve_DLC001/music/music_epicfight_summer",
}

local SEASON_DANGER_MUSIC =
{
    autumn = "dontstarve/music/music_danger",
    winter = "dontstarve/music/music_danger_winter",
    spring = "dontstarve_DLC001/music/music_danger_spring",
    summer = "dontstarve_DLC001/music/music_danger_summer",
}

local TRIGGERED_DANGER_MUSIC =
{
    moonbase =
    {
        "dontstarve/music/music_epicfight_moonbase",
        "dontstarve/music/music_epicfight_moonbase_b",
    },

    toadstool =
    {
        "dontstarve/music/music_epicfight_toadboss",
    },

    beequeen =
    {
        "dontstarve/music/music_epicfight_4",
    },

    dragonfly =
    {
        "dontstarve/music/music_epicfight_3",
    },

    shadowchess =
    {
        "dontstarve/music/music_epicfight_ruins",
    },

    klaus =
    {
        "dontstarve/music/music_epicfight_5a",
        "",
        "dontstarve/music/music_epicfight_5b",
    },

    antlion =
    {
        "dontstarve/music/music_epicfight_antlion",
    },

    stalker =
    {
        "dontstarve/music/music_epicfight_stalker",
        "dontstarve/music/music_epicfight_stalker_b",
        "",
    },

    default =
    {
        "dontstarve/music/music_epicfight_ruins",
    },
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _iscave = inst:HasTag("cave")
local _isenabled = true
local _busytask = nil
local _dangertask = nil
local _triggeredlevel = nil
local _isday = nil
local _isbusydirty = nil
local _isbusyruins = nil
local _extendtime = nil
local _soundemitter = nil
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function IsInRuins(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("Nightmare")
end

local function StopBusy(inst, istimeout)
    if _busytask ~= nil then
        if not istimeout then
            _busytask:Cancel()
        elseif _extendtime > 0 then
            local time = GetTime()
            if time < _extendtime then
                _busytask = inst:DoTaskInTime(_extendtime - time, StopBusy, true)
                _extendtime = 0
                return
            end
        end
        _busytask = nil
        _extendtime = 0
        _soundemitter:SetParameter("busy", "intensity", 0)
    end
end

local function StartBusy(player)
    if not (_iscave or _isday) then
        return
    elseif _busytask ~= nil then
        _extendtime = GetTime() + 15
    elseif _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _isbusydirty then
            _isbusydirty = false
            _soundemitter:KillSound("busy")
            if _iscave then
                _isbusyruins = IsInRuins(player)
                _soundemitter:PlaySound(_isbusyruins and "dontstarve/music/music_work_ruins" or "dontstarve/music/music_work_cave", "busy")
            else
                _soundemitter:PlaySound(SEASON_BUSY_MUSIC[inst.state.season], "busy")
            end
        elseif _iscave and _isbusyruins ~= IsInRuins(player) then
            _isbusyruins = not _isbusyruins
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound(_isbusyruins and "dontstarve/music/music_work_ruins" or "dontstarve/music/music_work_cave", "busy")
        end
        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(15, StopBusy, true)
        _extendtime = 0
    end
end

local function ExtendBusy()
    if _busytask ~= nil then
        _extendtime = math.max(_extendtime, GetTime() + 10)
    end
end

local function StopDanger(inst, istimeout)
    if _dangertask ~= nil then
        if not istimeout then
            _dangertask:Cancel()
        elseif _extendtime > 0 then
            local time = GetTime()
            if time < _extendtime then
                _dangertask = inst:DoTaskInTime(_extendtime - time, StopDanger, true)
                _extendtime = 0
                return
            end
        end
        _dangertask = nil
        _triggeredlevel = nil
        _extendtime = 0
        _soundemitter:KillSound("danger")
    end
end

local function StartDanger(player)
    if _dangertask ~= nil then
        _extendtime = GetTime() + 10
    elseif _isenabled then
        StopBusy()
        local x, y, z = player.Transform:GetWorldPosition()
        _soundemitter:PlaySound(
            #TheSim:FindEntities(x, y, z, 30, { "epic" }, { "noepicmusic" }) > 0
            and ((IsInRuins(player) and "dontstarve/music/music_epicfight_ruins") or
                (_iscave and "dontstarve/music/music_epicfight_cave") or
                (SEASON_EPICFIGHT_MUSIC[inst.state.season]))
            or ((IsInRuins(player) and "dontstarve/music/music_danger_ruins") or
                (_iscave and "dontstarve/music/music_danger_cave") or
                (SEASON_DANGER_MUSIC[inst.state.season])),
            "danger")
        _dangertask = inst:DoTaskInTime(10, StopDanger, true)
        _triggeredlevel = nil
        _extendtime = 0
    end
end

local function StartTriggeredDanger(player, data)
    local level = math.max(1, math.floor(data ~= nil and data.level or 1))
    if _triggeredlevel == level then
        _extendtime = math.max(_extendtime, GetTime() + (data.duration or 10))
    elseif _isenabled then
        StopBusy()
        StopDanger()
        local music = data ~= nil and TRIGGERED_DANGER_MUSIC[data.name or "default"] or TRIGGERED_DANGER_MUSIC.default
        music = music[level] or music[1]
        if #music > 0 then
            _soundemitter:PlaySound(music, "danger")
        end
        _dangertask = inst:DoTaskInTime(data.duration or 10, StopDanger, true)
        _triggeredlevel = level
        _extendtime = 0
    end
end

local function CheckAction(player)
    if player:HasTag("attack") then
        local target = player.replica.combat:GetTarget()
        if target ~= nil and
            target:HasTag("_combat") and
            not ((target:HasTag("prey") and not target:HasTag("hostile")) or
                target:HasTag("bird") or
                target:HasTag("butterfly") or
                target:HasTag("shadow") or
                target:HasTag("shadowchesspiece") or
                target:HasTag("noepicmusic") or
                target:HasTag("thorny") or
                target:HasTag("smashable") or
                target:HasTag("wall") or
                target:HasTag("smoldering") or
                target:HasTag("veggie")) then
            if target:HasTag("shadowminion") or target:HasTag("abigail") then
                local follower = target.replica.follower
                if not (follower ~= nil and follower:GetLeader() == player) then
                    StartDanger(player)
                    return
                end
            else
                StartDanger(player)
                return
            end
        end
    end
    if player:HasTag("working") then
        StartBusy(player)
    end
end

local function OnAttacked(player, data)
    if data ~= nil and
        --For a valid client side check, shadowattacker must be
        --false and not nil, pushed from player_classified
        (data.isattackedbydanger == true or
        --For a valid server side check, attacker must be non-nil
        (data.attacker ~= nil and
        not (data.attacker:HasTag("shadow") or
            data.attacker:HasTag("shadowchesspiece") or
            data.attacker:HasTag("noepicmusic") or
            data.attacker:HasTag("thorny") or
            data.attacker:HasTag("smolder")))) then

        StartDanger(player)
    end
end

local function OnInsane()
    if _dangertask == nil and _isenabled then
        _soundemitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
        StopBusy()
        --Repurpose this as a delay before stingers or busy can start again
        _extendtime = GetTime() + 15
    end
end

local function StartPlayerListeners(player)
    inst:ListenForEvent("buildsuccess", StartBusy, player)
    inst:ListenForEvent("gotnewitem", ExtendBusy, player)
    inst:ListenForEvent("performaction", CheckAction, player)
    inst:ListenForEvent("attacked", OnAttacked, player)
    inst:ListenForEvent("goinsane", OnInsane, player)
    inst:ListenForEvent("triggeredevent", StartTriggeredDanger, player)
end

local function StopPlayerListeners(player)
    inst:RemoveEventCallback("buildsuccess", StartBusy, player)
    inst:RemoveEventCallback("gotnewitem", ExtendBusy, player)
    inst:RemoveEventCallback("performaction", CheckAction, player)
    inst:RemoveEventCallback("attacked", OnAttacked, player)
    inst:RemoveEventCallback("goinsane", OnInsane, player)
    inst:RemoveEventCallback("triggeredevent", StartTriggeredDanger, player)
end

local function OnPhase(inst, phase)
    _isday = phase == "day"
    if _dangertask ~= nil or not _isenabled then
        return
    end
    --Don't want to play overlapping stingers
    local time
    if _busytask == nil and _extendtime ~= 0 then
        time = GetTime()
        if time < _extendtime then
            return
        end
    end
    if _isday then
        _soundemitter:PlaySound("dontstarve/music/music_dawn_stinger")
    elseif phase == "dusk" then
        _soundemitter:PlaySound("dontstarve/music/music_dusk_stinger")
    else
        return
    end
    StopBusy()
    --Repurpose this as a delay before stingers or busy can start again
    _extendtime = (time or GetTime()) + 15
end

local function OnSeason()
    _isbusydirty = true
end

local function StartSoundEmitter()
    if _soundemitter == nil then
        _soundemitter = TheFocalPoint.SoundEmitter
        _extendtime = 0
        _isbusydirty = true
        if not _iscave then
            _isday = inst.state.isday
            inst:WatchWorldState("phase", OnPhase)
            inst:WatchWorldState("season", OnSeason)
        end
    end
end

local function StopSoundEmitter()
    if _soundemitter ~= nil then
        StopDanger()
        StopBusy()
        _soundemitter:KillSound("busy")
        inst:StopWatchingWorldState("phase", OnPhase)
        inst:StopWatchingWorldState("season", OnSeason)
        _isday = nil
        _isbusydirty = nil
        _extendtime = nil
        _soundemitter = nil
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPlayerActivated(inst, player)
    if _activatedplayer == player then
        return
    elseif _activatedplayer ~= nil and _activatedplayer.entity:IsValid() then
        StopPlayerListeners(_activatedplayer)
    end
    _activatedplayer = player
    StopSoundEmitter()
    StartSoundEmitter()
    StartPlayerListeners(player)
end

local function OnPlayerDeactivated(inst, player)
    StopPlayerListeners(player)
    if player == _activatedplayer then
        _activatedplayer = nil
        StopSoundEmitter()
    end
end

local function OnEnableDynamicMusic(inst, enable)
    if _isenabled ~= enable then
        if not enable and _soundemitter ~= nil then
            StopDanger()
            StopBusy()
            _soundemitter:KillSound("busy")
            _isbusydirty = true
        end
        _isenabled = enable
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("playeractivated", OnPlayerActivated)
inst:ListenForEvent("playerdeactivated", OnPlayerDeactivated)
inst:ListenForEvent("enabledynamicmusic", OnEnableDynamicMusic)

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)