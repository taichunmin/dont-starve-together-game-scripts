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

    wagstaff_experiment =
    {
        "moonstorm/characters/wagstaff/music_wagstaff_experiment",
    },

    crabking =
    {
        "dontstarve/music/music_epicfight_crabking",
    },

    malbatross =
    {
        "saltydog/music/malbatross",
    },

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

    pigking =
    {
        "dontstarve/music/music_pigking_minigame",
    },

    alterguardian_phase1 =
    {
        "moonstorm/creatures/boss/alterguardian1/music_epicfight",
    },
    alterguardian_phase2 =
    {
        "moonstorm/creatures/boss/alterguardian2/music_epicfight",
    },
    alterguardian_phase3 =
    {
        "moonstorm/creatures/boss/alterguardian3/music_epicfight",
    },

    eyeofterror =
    {
        "terraria1/common/music_epicfight_eot",
    },

    default =
    {
        "dontstarve/music/music_epicfight_ruins",
    },
}

local BUSYTHEMES = {
    FOREST = 1,
    CAVE = 2,
    RUINS = 3,
    OCEAN = 4,
    LUNARISLAND = 5,
    FEAST = 6,
    RACE = 7,
    TRAINING = 8,
    HERMIT = 9,
    FARMING = 10,
	CARNIVAL_AMBIENT = 11,
	CARNIVAL_MINIGAME = 12,
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
local _busytheme = nil
local _extendtime = nil
local _soundemitter = nil
local _activatedplayer = nil --cached for activation/deactivation only, NOT for logic use
local _hasinspirationbuff = nil

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function IsInRuins(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("Nightmare")
end

local function IsOnLunarIsland(player)
    return player.components.areaaware ~= nil
        and player.components.areaaware:CurrentlyInTag("lunacyarea")
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

        if _iscave then
            if IsInRuins(player) then
                if _busytheme ~= BUSYTHEMES.RUINS then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound("dontstarve/music/music_work_ruins", "busy")
                end
                _busytheme = BUSYTHEMES.RUINS
            else
                if _busytheme ~= BUSYTHEMES.CAVE then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound("dontstarve/music/music_work_cave", "busy")
                end
                _busytheme = BUSYTHEMES.CAVE
            end
        else
            if IsOnLunarIsland(player) then
                if _busytheme ~= BUSYTHEMES.LUNARISLAND then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound("turnoftides/music/working", "busy")
                end
                _busytheme = BUSYTHEMES.LUNARISLAND
            else
                if _busytheme ~= BUSYTHEMES.FOREST then
                    _soundemitter:KillSound("busy")
                    _soundemitter:PlaySound(SEASON_BUSY_MUSIC[inst.state.season], "busy")
                end
                _busytheme = BUSYTHEMES.FOREST
            end
        end

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(15, StopBusy, true)
        _extendtime = 0
    end
end

local function StartOcean(player)
    if not (_iscave or _isday) then
        return
    elseif _busytask ~= nil then
        _extendtime = GetTime() + 15
    elseif _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then

        if _busytheme ~= BUSYTHEMES.OCEAN then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("turnoftides/music/sailing", "busy")
        end
        _busytheme = BUSYTHEMES.OCEAN

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(30, StopBusy, true)
        _extendtime = 0
    end
end

local function StartFeasting(player)
    if _busytask ~= nil then
        _extendtime = 0
        _busytask:Cancel()
        _busytask = nil
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
    elseif _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then

        if _busytheme ~= BUSYTHEMES.FEAST then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("wintersfeast2019/music/feast", "busy")
        end
        _busytheme = BUSYTHEMES.FEAST

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartRacing(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.RACE then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("yotc_2020/music/race", "busy")
        end
        _busytheme = BUSYTHEMES.RACE

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartHermit(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.HERMIT then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("hookline_2/characters/hermit/music_work", "busy")
        end
        _busytheme = BUSYTHEMES.HERMIT

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(30, StopBusy, true)
        _extendtime = 0
    end
end

local function StartTraining(player)
    if _dangertask == nil and (_extendtime == 0 or GetTime() >= _extendtime) and _isenabled and _busytheme ~= BUSYTHEMES.RACE then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= BUSYTHEMES.TRAINING then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound("yotc_2020/music/training", "busy")
        end
        _busytheme = BUSYTHEMES.TRAINING

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(5, StopBusy, true)
        _extendtime = 0
    end
end

local function StartBusyTheme(player, theme, sound, duration, extendtime)
    if _dangertask == nil and (_busytheme ~= theme or _extendtime == 0 or GetTime() >= _extendtime) and _isenabled then
        if _busytask then
            _busytask:Cancel()
            _busytask = nil
        end
        if _busytheme ~= theme then
            _soundemitter:KillSound("busy")
            _soundemitter:PlaySound(sound, "busy")
	        _busytheme = theme
        end

        _soundemitter:SetParameter("busy", "intensity", 1)
        _busytask = inst:DoTaskInTime(duration, StopBusy, true)
        _extendtime = extendtime or 0
    end
end

local function StartFarming(player)
	StartBusyTheme(player, BUSYTHEMES.FARMING, "farming/music/farming", 15)
end

local function StartCarnivalMustic(player, is_game_active)
	if _dangertask ~= nil or (_busytask ~= nil and _busytheme == BUSYTHEMES.CARNIVAL_MINIGAME and not is_game_active) then
		return
	end

	local theme = is_game_active and BUSYTHEMES.CARNIVAL_MINIGAME or BUSYTHEMES.CARNIVAL_AMBIENT
	StartBusyTheme(player, theme, theme == BUSYTHEMES.CARNIVAL_MINIGAME and "summerevent/music/2" or "summerevent/music/1", 2)
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

local EPIC_TAGS = { "epic" }
local NO_EPIC_TAGS = { "noepicmusic" }
local function StartDanger(player)
    if _dangertask ~= nil then
        _extendtime = GetTime() + 10
    elseif _isenabled then
        StopBusy()
        local x, y, z = player.Transform:GetWorldPosition()
        _soundemitter:PlaySound(
            #TheSim:FindEntities(x, y, z, 30, EPIC_TAGS, NO_EPIC_TAGS) > 0
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

		if _hasinspirationbuff then
			_soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
		end
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
            if _hasinspirationbuff then
                _soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
            end
        end
        _dangertask = inst:DoTaskInTime(data.duration or 10, StopDanger, true)
        _triggeredlevel = level
        _extendtime = 0
    end
end

local function StartTriggeredWater(player, data)
    if player:GetCurrentPlatform() then
        StartOcean(player)
    end
end

local function StartTriggeredFeasting(player, data)
    if player and player.sg and player.sg:HasStateTag("feasting") then
        StartFeasting(player)
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
                target:HasTag("engineering") or
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

local function OnHasInspirationBuff(player, data)
	_hasinspirationbuff = (data ~= nil and data.on) and 1 or 0
	_soundemitter:SetParameter("danger", "wathgrithr_intensity", _hasinspirationbuff)
end

local function OnInsane()
    if _dangertask == nil and _isenabled then
        _soundemitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
        StopBusy()
        --Repurpose this as a delay before stingers or busy can start again
        _extendtime = GetTime() + 15
    end
end

local function OnEnlightened()
	-- TEMP
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
    inst:ListenForEvent("goenlightened", OnEnlightened, player)
    inst:ListenForEvent("triggeredevent", StartTriggeredDanger, player)
    inst:ListenForEvent("playboatmusic", StartTriggeredWater, player)
    inst:ListenForEvent("isfeasting", StartTriggeredFeasting, player)
    inst:ListenForEvent("playracemusic", StartRacing, player)
    inst:ListenForEvent("playhermitmusic", StartHermit, player)
    inst:ListenForEvent("playtrainingmusic", StartTraining, player)
    inst:ListenForEvent("playfarmingmusic", StartFarming, player)
    inst:ListenForEvent("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:ListenForEvent("playcarnivalmusic", StartCarnivalMustic, player)
end

local function StopPlayerListeners(player)
    inst:RemoveEventCallback("buildsuccess", StartBusy, player)
    inst:RemoveEventCallback("gotnewitem", ExtendBusy, player)
    inst:RemoveEventCallback("performaction", CheckAction, player)
    inst:RemoveEventCallback("attacked", OnAttacked, player)
    inst:RemoveEventCallback("goinsane", OnInsane, player)
    inst:RemoveEventCallback("goenlightened", OnEnlightened, player)
    inst:RemoveEventCallback("triggeredevent", StartTriggeredDanger, player)
    inst:RemoveEventCallback("playboatmusic", StartTriggeredWater, player)
    inst:RemoveEventCallback("isfeasting", StartTriggeredFeasting, player)
    inst:RemoveEventCallback("playracemusic", StartRacing, player)
    inst:RemoveEventCallback("playhermitmusic", StartHermit, player)
    inst:RemoveEventCallback("playtrainingmusic", StartTraining, player)
    inst:RemoveEventCallback("playfarmingmusic", StartFarming, player)
    inst:RemoveEventCallback("hasinspirationbuff", OnHasInspirationBuff, player)
    inst:RemoveEventCallback("playcarnivalmusic", StartCarnivalMustic, player)
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
    _busytheme = nil
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
		_busytheme = nil
        _isbusydirty = nil
        _extendtime = nil
        _soundemitter = nil
		_hasinspirationbuff = nil
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