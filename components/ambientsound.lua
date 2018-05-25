--------------------------------------------------------------------------
--[[ AmbientSound class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local HALF_TILES = 5
local MAX_MIX_SOUNDS = 3
local WAVE_VOLUME_SCALE = 3 / (HALF_TILES * HALF_TILES * 8)
local WAVE_SOUNDS = { 
    ["autumn"] = "dontstarve/ocean/waves",
    ["winter"] = "dontstarve/winter/winterwaves",
    ["spring"] = "dontstarve/ocean/waves",--"dontstarve_DLC001/spring/springwaves",
    ["summer"] = "dontstarve_DLC001/summer/summerwaves",
}
local SANITY_SOUND = "dontstarve/sanity/sanity"

local AMBIENT_SOUNDS =
{
    [GROUND.ROAD] = {sound = "dontstarve/rocky/rockyAMB", wintersound = "dontstarve/winter/winterrockyAMB", springsound = "dontstarve/rocky/rockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},
    [GROUND.ROCKY] = {sound = "dontstarve/rocky/rockyAMB", wintersound = "dontstarve/winter/winterrockyAMB", springsound = "dontstarve/rocky/rockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},
    [GROUND.DIRT] = {sound = "dontstarve/badland/badlandAMB", wintersound = "dontstarve/winter/winterbadlandAMB", springsound = "dontstarve/badland/badlandAMB", summersound = "dontstarve_DLC001/summer/summerbadlandAMB", rainsound = "dontstarve/rain/rainbadlandAMB"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/summer/summerbadlandAMB", rainsound = "dontstarve/rain/rainbadlandAMB"},
    [GROUND.WOODFLOOR] = {sound = "dontstarve/rocky/rockyAMB", wintersound = "dontstarve/winter/winterrockyAMB", springsound = "dontstarve/rocky/rockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/summer/summerrockyAMB", rainsound = "dontstarve/rain/rainrockyAMB"},
    [GROUND.SAVANNA] = {sound = "dontstarve/grassland/grasslandAMB", wintersound = "dontstarve/winter/wintergrasslandAMB", springsound = "dontstarve/grassland/grasslandAMB", summersound = "dontstarve_DLC001/summer/summergrasslandAMB", rainsound = "dontstarve/rain/raingrasslandAMB"},--springsound = "dontstarve_DLC001/spring/springgrasslandAMB", summersound = "dontstarve_DLC001/summer/summergrasslandAMB", rainsound = "dontstarve/rain/raingrasslandAMB"},
    [GROUND.GRASS] = {sound = "dontstarve/meadow/meadowAMB", wintersound = "dontstarve/winter/wintermeadowAMB", springsound = "dontstarve/meadow/meadowAMB", summersound = "dontstarve_DLC001/summer/summermeadowAMB", rainsound = "dontstarve/rain/rainmeadowAMB"},--springsound = "dontstarve_DLC001/spring/springmeadowAMB", summersound = "dontstarve_DLC001/summer/summermeadowAMB", rainsound = "dontstarve/rain/rainmeadowAMB"},
    [GROUND.FOREST] = {sound = "dontstarve/forest/forestAMB", wintersound = "dontstarve/winter/winterforestAMB", springsound = "dontstarve/forest/forestAMB", summersound = "dontstarve_DLC001/summer/summerforestAMB", rainsound = "dontstarve/rain/rainforestAMB"},--springsound = "dontstarve_DLC001/spring/springforestAMB", summersound = "dontstarve_DLC001/summer/summerforestAMB", rainsound = "dontstarve/rain/rainforestAMB"},
    [GROUND.MARSH] = {sound = "dontstarve/marsh/marshAMB", wintersound = "dontstarve/winter/wintermarshAMB", springsound = "dontstarve/marsh/marshAMB", summersound = "dontstarve_DLC001/summer/summermarshAMB", rainsound = "dontstarve/rain/rainmarshAMB"},--springsound = "dontstarve_DLC001/spring/springmarshAMB", summersound = "dontstarve_DLC001/summer/summermarshAMB", rainsound = "dontstarve/rain/rainmarshAMB"},
    [GROUND.DECIDUOUS] = {sound = "dontstarve/forest/forestAMB", wintersound = "dontstarve/winter/winterforestAMB", springsound = "dontstarve/forest/forestAMB", summersound = "dontstarve_DLC001/summer/summerforestAMB", rainsound = "dontstarve/rain/rainforestAMB"},
    [GROUND.DESERT_DIRT] = {sound = "dontstarve/badland/badlandAMB", wintersound = "dontstarve/winter/winterbadlandAMB", springsound = "dontstarve/badland/badlandAMB", summersound = "dontstarve_DLC001/summer/summerbadlandAMB", rainsound = "dontstarve/rain/rainbadlandAMB"},
    [GROUND.CHECKER] = {sound = "dontstarve/chess/chessAMB", wintersound = "dontstarve/winter/winterchessAMB", springsound = "dontstarve/chess/chessAMB", summersound = "dontstarve_DLC001/summer/summerchessAMB", rainsound = "dontstarve/rain/rainchessAMB"},--springsound = "dontstarve_DLC001/spring/springchessAMB", summersound = "dontstarve_DLC001/summer/summerchessAMB", rainsound = "dontstarve/rain/rainchessAMB"},
    [GROUND.CAVE] = {sound = "dontstarve/cave/caveAMB"},

    [GROUND.FUNGUS] = { sound = "dontstarve/cave/fungusforestAMB" },
    [GROUND.FUNGUSRED] = { sound = "dontstarve/cave/fungusforestAMB" },
    [GROUND.FUNGUSGREEN] = { sound = "dontstarve/cave/fungusforestAMB" },

    [GROUND.SINKHOLE] = { sound = "dontstarve/cave/litcaveAMB" },
    [GROUND.UNDERROCK] = { sound = "dontstarve/cave/caveAMB" },
    [GROUND.MUD] = { sound = "dontstarve/cave/fungusforestAMB" },
    [GROUND.UNDERGROUND] = { sound = "dontstarve/cave/caveAMB" },
    [GROUND.BRICK] = { sound = "dontstarve/cave/ruinsAMB" },
    [GROUND.BRICK_GLOW] = { sound = "dontstarve/cave/ruinsAMB" },
    [GROUND.TILES] = { sound = "dontstarve/cave/civruinsAMB" },
    [GROUND.TILES_GLOW] = { sound = "dontstarve/cave/civruinsAMB" },
    [GROUND.TRIM] = { sound = "dontstarve/cave/ruinsAMB" },
    [GROUND.TRIM_GLOW] = { sound = "dontstarve/cave/ruinsAMB" },

    [GROUND.LAVAARENA_FLOOR] = { sound = "dontstarve/lava_arena_amb/arena_day" },
    [GROUND.LAVAARENA_TRIM] = { sound = "dontstarve/lava_arena_amb/arena_day" },

    ABYSS = { sound = "dontstarve/cave/pitAMB" },
    VOID = { sound = "dontstarve/chess/void", wintersound = "dontstarve/chess/void", springsound="dontstarve/chess/void", summersound="dontstarve/chess/void", rainsound = "dontstarve/chess/void" },
    CIVRUINS = { sound = "dontstarve/cave/civruinsAMB" },
}
local SEASON_SOUND_KEY =
{
    ["autumn"] = "sound",
    ["winter"] = "wintersound",
    ["spring"] = "springsound",
    ["summer"] = "summersound",
}

local DAYTIME_PARAMS =
{
    day = 1,
    dusk = 1.5,
    night = 2,
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _map = inst.Map
local _lightattenuation = false
local _seasonmix = "autumn"
local _rainmix = false
local _heavyrainmix = false
local _lastplayerpos = nil
local _daytimeparam = 1
local _sanityparam = 0
local _soundvolumes = {}
local _wavesenabled = not inst:HasTag("cave")
local _wavessound = WAVE_SOUNDS[_seasonmix]
local _wavesvolume = 0
local _ambientvolume = 1
local _tileoverrides = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SortByCount(a, b)
    return a.count > b.count
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnPrecipitationChanged(src, preciptype)
    if _rainmix ~= (preciptype == "rain") then
        _rainmix = not _rainmix
        _lastplayerpos = nil
    end
end

local function OnWeatherTick(src, data)
    -- We don't want to play rain ambients if it's just trickling down
    if _heavyrainmix  ~= (data.precipitationrate > 0.5) then
        _heavyrainmix = not _heavyrainmix
        _lastplayerpos = nil
    end
end

local function OnOverrideAmbientSound(src, data)
    _tileoverrides[data.tile] = data.override
end

local function OnSetAmbientSoundDaytime(src, daytime)
    if _daytimeparam ~= daytime and daytime ~= nil then
        _daytimeparam = daytime

        for k, v in pairs(_soundvolumes) do
            if v > 0 then
                inst.SoundEmitter:SetParameter(k, "daytime", daytime)
            end
        end
    end
end

local function OnPhaseChanged(src, phase)
    _lightattenuation = phase ~= "day"
    OnSetAmbientSoundDaytime(src, DAYTIME_PARAMS[phase])
end

local function OnSeasonTick(src, data)
    if _seasonmix ~= data.season then
        _seasonmix = data.season
        _lastplayerpos = nil

        if _wavesvolume <= 0 then
            _wavessound = WAVE_SOUNDS[_seasonmix]
        end
    end
end

--------------------------------------------------------------------------
--[[ Public Methods ]]
--------------------------------------------------------------------------

function self:SetReverbPreset(preset)
    TheSim:SetReverbPreset(preset)
end

function self:SetWavesEnabled(enabled)
    _wavesenabled = enabled
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
inst:ListenForEvent("overrideambientsound", OnOverrideAmbientSound)
inst:ListenForEvent("setambientsounddaytime", OnSetAmbientSoundDaytime)
inst:ListenForEvent("seasontick", OnSeasonTick)
inst:ListenForEvent("weathertick", OnWeatherTick)
inst:ListenForEvent("precipitationchanged", OnPrecipitationChanged)

self:SetReverbPreset("default")

--------------------------------------------------------------------------
--[[ Wrapper function for calls into actual sound system ]]
--------------------------------------------------------------------------

local function StartSanitySound()
	inst.SoundEmitter:PlaySound(SANITY_SOUND, "SANITY")
end

local function SetSanity(sanity)
	inst.SoundEmitter:SetParameter("SANITY", "sanity", sanity)
end

local function StartWavesSound()
	inst.SoundEmitter:PlaySound(_wavessound, "waves")
end

local function StopWavesSound()
	inst.SoundEmitter:KillSound("waves")
end

local function SetWavesVolume(volume)
	inst.SoundEmitter:SetVolume("waves", volume)
end

StartSanitySound()
SetSanity(_sanityparam)

inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
    --Start the right sounds and give a large enough timestep to finish
    --any initial fading immediately
    self:OnUpdate(20)
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    local player = ThePlayer
    local soundvolumes = nil
    local totalsoundcount = 0
    local wavesvolume = _wavesvolume
    local ambientvolume = _ambientvolume

    --Update the ambient mix based upon the player's surroundings
    --Only update if we've actually walked somewhere new
    if player == nil then
        _lastplayerpos = nil
        wavesvolume = math.max(0, wavesvolume - dt)
    elseif _lastplayerpos == nil or player:GetDistanceSqToPoint(_lastplayerpos:Get()) >= 16 then
        _lastplayerpos = player:GetPosition()

        local x, y = _map:GetTileCoordsAtPoint(_lastplayerpos:Get())
        local wavecount = 0
        local soundmixcounters = {}
        local soundmix = {}

        for x1 = -HALF_TILES, HALF_TILES do
            for y1 = -HALF_TILES, HALF_TILES do
                local tile = _map:GetTile(x + x1, y + y1)
                tile = _tileoverrides[tile] or tile
                if tile == GROUND.IMPASSABLE then
                    wavecount = wavecount + 1
                elseif tile ~= nil then
                    local soundgroup = AMBIENT_SOUNDS[tile]
                    if soundgroup ~= nil then
                        local sound = 
                                (_rainmix and _heavyrainmix and soundgroup.rainsound) or
                                (_seasonmix and soundgroup[SEASON_SOUND_KEY[_seasonmix]]) or
                                soundgroup.sound
                        local counter = soundmixcounters[sound]
                        if counter == nil then
                            counter = { sound = sound, count = 1 }
                            soundmixcounters[sound] = counter
                            table.insert(soundmix, counter)
                        else
                            counter.count = counter.count + 1
                        end
                    end
                end
            end
        end

        --Sort by highest count and truncate soundmix to MAX_MIX_SOUNDS
        table.sort(soundmix, SortByCount)
        soundmix[MAX_MIX_SOUNDS + 1] = nil
        soundvolumes = {}

        for i, v in ipairs(soundmix) do
            totalsoundcount = totalsoundcount + v.count
            soundvolumes[v.sound] = v.count
        end

        wavesvolume = _wavesenabled and math.min(math.max(wavecount * WAVE_VOLUME_SCALE, 0), 1) or 0
    end

    if player == nil then
        ambientvolume = math.max(0, ambientvolume - dt)
    elseif _lightattenuation and player.LightWatcher ~= nil then
        --Night/dusk ambience is attenuated in the light
        local lightval = player.LightWatcher:GetLightValue()
        local highlight = .9
        local lowlight = .2
        local lowvolume = .5
        ambientvolume = (lightval > highlight and lowvolume) or
                        (lightval < lowlight and 1) or
                        easing.outCubic(lightval - lowlight, 1, lowvol - 1, highlight - lowlight)
    elseif ambientvolume < 1 then
        ambientvolume = math.min(ambientvolume + dt * .05, 1)
    end

    if _wavessound ~= WAVE_SOUNDS[_seasonmix] then
        if _wavesvolume > 0 then
			StopWavesSound()
        end
        _wavessound = WAVE_SOUNDS[_seasonmix]
        _wavesvolume = wavesvolume
        if wavesvolume > 0 then
			StartWavesSound()
			SetWavesVolume(wavesvolume)
        end
    elseif _wavesvolume ~= wavesvolume then
        if wavesvolume <= 0 then
			StopWavesSound()
        else
            if _wavesvolume <= 0 then
				StartWavesSound()
            end
			SetWavesVolume(wavesvolume)
        end
        _wavesvolume = wavesvolume
    end

    if soundvolumes ~= nil then
        for k, v in pairs(_soundvolumes) do
            if soundvolumes[k] == nil then
                inst.SoundEmitter:KillSound(k)
            end
        end
        for k, v in pairs(soundvolumes) do
            local oldvol = _soundvolumes[k]
            local newvol = v / totalsoundcount
            if oldvol == nil then
                inst.SoundEmitter:PlaySound(k, k)
                inst.SoundEmitter:SetParameter(k, "daytime", _daytimeparam)
                inst.SoundEmitter:SetVolume(k, newvol * ambientvolume)
            elseif oldvol ~= newvol then
                inst.SoundEmitter:SetVolume(k, newvol * ambientvolume)
            end
            soundvolumes[k] = newvol
        end
        _soundvolumes = soundvolumes
        _ambientvolume = ambientvolume
    elseif _ambientvolume ~= ambientvolume then
        for k, v in pairs(_soundvolumes) do
            inst.SoundEmitter:SetVolume(k, v * ambientvolume)
        end
        _ambientvolume = ambientvolume
    end

    local sanity = player ~= nil and player.replica.sanity or nil
    local sanityparam = sanity ~= nil and (1 - sanity:GetPercent()) or 0
    if player ~= nil and player:HasTag("dappereffects") then
        sanityparam = sanityparam * sanityparam
    end
    if _sanityparam ~= sanityparam then
		SetSanity(sanityparam)
        _sanityparam = sanityparam
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = {}
    
    table.insert(str, string.format("AMBIENT SOUNDS: raining:%s heavy:%s season:%s", tostring(_rainmix), tostring(_heavyrainmix), _seasonmix))
    table.insert(str, string.format("atten=%2.2f, day=%2.2f, waves=%2.2f", _ambientvolume, _daytimeparam, _wavesvolume))
    
    for k, v in pairs(_soundvolumes) do
        table.insert(str, string.format("\t%s = %2.2f", k, v))
    end

    return table.concat(str, "\n")
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
