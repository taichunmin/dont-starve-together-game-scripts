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
    ["autumn"] = "dontstarve/AMB/waves",
    ["winter"] = "dontstarve/AMB/waves_winter",
    ["spring"] = "dontstarve/AMB/waves",--"dontstarve_DLC001/spring/springwaves",
    ["summer"] = "dontstarve_DLC001/AMB/waves_summer",
}
local SANITY_SOUND = "dontstarve/sanity/sanity"
local ENLIGHTENMENT_SOUND = "turnoftides/sanity/lunacy_LP"

local AMBIENT_SOUNDS =
{
    [WORLD_TILES.ROAD] = {sound = "dontstarve/AMB/rocky", wintersound = "dontstarve/AMB/rocky_winter", springsound = "dontstarve/AMB/rocky", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},
    [WORLD_TILES.ROCKY] = {sound = "dontstarve/AMB/rocky", wintersound = "dontstarve/AMB/rocky_winter", springsound = "dontstarve/AMB/rocky", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},
    [WORLD_TILES.DIRT] = {sound = "dontstarve/AMB/badland", wintersound = "dontstarve/AMB/badland_winter", springsound = "dontstarve/AMB/badland", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},
    [WORLD_TILES.WOODFLOOR] = {sound = "dontstarve/AMB/rocky", wintersound = "dontstarve/AMB/rocky_winter", springsound = "dontstarve/AMB/rocky", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},--springsound = "dontstarve_DLC001/spring/springrockyAMB", summersound = "dontstarve_DLC001/AMB/rocky_summer", rainsound = "dontstarve/AMB/rocky_rain"},
    [WORLD_TILES.SAVANNA] = {sound = "dontstarve/AMB/grassland", wintersound = "dontstarve/AMB/grassland_winter", springsound = "dontstarve/AMB/grassland", summersound = "dontstarve_DLC001/AMB/grassland_summer", rainsound = "dontstarve/AMB/grassland_rain"},--springsound = "dontstarve_DLC001/spring/springgrasslandAMB", summersound = "dontstarve_DLC001/AMB/grassland_summer", rainsound = "dontstarve/AMB/grassland_rain"},
    [WORLD_TILES.GRASS] = {sound = "dontstarve/AMB/meadow", wintersound = "dontstarve/AMB/meadow_winter", springsound = "dontstarve/AMB/meadow", summersound = "dontstarve_DLC001/AMB/meadow_summer", rainsound = "dontstarve/AMB/meadow_rain"},--springsound = "dontstarve_DLC001/spring/springmeadowAMB", summersound = "dontstarve_DLC001/AMB/meadow_summer", rainsound = "dontstarve/AMB/meadow_rain"},
    [WORLD_TILES.FOREST] = {sound = "dontstarve/AMB/forest", wintersound = "dontstarve/AMB/forest_winter", springsound = "dontstarve/AMB/forest", summersound = "dontstarve_DLC001/AMB/forest_summer", rainsound = "dontstarve/AMB/forest_rain"},--springsound = "dontstarve_DLC001/spring/springforestAMB", summersound = "dontstarve_DLC001/AMB/forest_summer", rainsound = "dontstarve/AMB/forest_rain"},
    [WORLD_TILES.MARSH] = {sound = "dontstarve/AMB/marsh", wintersound = "dontstarve/AMB/marsh_winter", springsound = "dontstarve/AMB/marsh", summersound = "dontstarve_DLC001/AMB/marsh_summer", rainsound = "dontstarve/AMB/marsh_rain"},--springsound = "dontstarve_DLC001/spring/springmarshAMB", summersound = "dontstarve_DLC001/AMB/marsh_summer", rainsound = "dontstarve/AMB/marsh_rain"},
    [WORLD_TILES.DECIDUOUS] = {sound = "dontstarve/AMB/forest", wintersound = "dontstarve/AMB/forest_winter", springsound = "dontstarve/AMB/forest", summersound = "dontstarve_DLC001/AMB/forest_summer", rainsound = "dontstarve/AMB/forest_rain"},
    [WORLD_TILES.DESERT_DIRT] = {sound = "dontstarve/AMB/badland", wintersound = "dontstarve/AMB/badland_winter", springsound = "dontstarve/AMB/badland", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},
    [WORLD_TILES.CHECKER] = {sound = "dontstarve/AMB/chess", wintersound = "dontstarve/AMB/chess_winter", springsound = "dontstarve/AMB/chess", summersound = "dontstarve_DLC001/AMB/chess_summer", rainsound = "dontstarve_DLC001/AMB/chess_summer"},--springsound = "dontstarve_DLC001/spring/springchessAMB", summersound = "dontstarve_DLC001/AMB/chess_summer", rainsound = "dontstarve_DLC001/AMB/chess_summer"},
    [WORLD_TILES.METEOR] = {sound = "turnoftides/together_amb/moon_island/fall", wintersound = "turnoftides/together_amb/moon_island/winter", springsound = "turnoftides/together_amb/moon_island/spring", summersound = "turnoftides/together_amb/moon_island/summer", rainsound = "dontstarve_DLC001/AMB/chess_summer"},
    [WORLD_TILES.PEBBLEBEACH] = {sound = "turnoftides/together_amb/moon_island/fall", wintersound = "turnoftides/together_amb/moon_island/winter", springsound = "turnoftides/together_amb/moon_island/spring", summersound = "turnoftides/together_amb/moon_island/summer", rainsound = "dontstarve/AMB/badland_rain"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},
    [WORLD_TILES.SHELLBEACH] = {sound = "hookline_2/amb/hermit_island", wintersound = "hookline_2/amb/hermit_island", springsound = "hookline_2/amb/hermit_island", summersound = "hookline_2/amb/hermit_island", rainsound = "hookline_2/amb/hermit_island"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},

    -- TODO: Properly add these
    [WORLD_TILES.MONKEY_DOCK] = {sound = "monkeyisland/amb/dock_ambience", wintersound = "monkeyisland/amb/dock_ambience", springsound = "monkeyisland/amb/dock_ambience", summersound = "monkeyisland/amb/dock_ambience", rainsound = "monkeyisland/amb/dock_ambience_rain"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},
    [WORLD_TILES.MONKEY_GROUND] = {sound = "monkeyisland/amb/island_amb", wintersound = "monkeyisland/amb/island_amb", springsound = "monkeyisland/amb/island_amb", summersound = "monkeyisland/amb/island_amb", rainsound = "monkeyisland/amb/island_amb_rain"},--springsound = "dontstarve_DLC001/spring/springbadlandAMB", summersound = "dontstarve_DLC001/AMB/badland_summer", rainsound = "dontstarve/AMB/badland_rain"},

    [WORLD_TILES.CAVE] = {sound = "dontstarve/AMB/caves/main"},

    [WORLD_TILES.FUNGUS] = { sound = "dontstarve/AMB/caves/fungus_forest" },
    [WORLD_TILES.FUNGUSRED] = { sound = "dontstarve/AMB/caves/fungus_forest" },
    [WORLD_TILES.FUNGUSGREEN] = { sound = "dontstarve/AMB/caves/fungus_forest" },

    [WORLD_TILES.ARCHIVE] = {sound = "grotto/amb/archive"},
    [WORLD_TILES.FUNGUSMOON] = {sound = "grotto/amb/grotto"},

    [WORLD_TILES.RIFT_MOON] = {sound = "rifts/ambience/rift_tile_amb", rainsound = "dontstarve_DLC001/AMB/chess_summer"},

    [WORLD_TILES.SHADOW_MARSH] = {sound = "meta4/marshify/shadow_cast_field_amb"},

    [WORLD_TILES.SINKHOLE] = { sound = "dontstarve/AMB/caves/litcave" },
    [WORLD_TILES.UNDERROCK] = { sound = "dontstarve/AMB/caves/main" }, --- rocky
    [WORLD_TILES.MUD] = { sound = "dontstarve/AMB/caves/fungus_forest" },
    [WORLD_TILES.BRICK] = { sound = "dontstarve/AMB/caves/ruins" },
    [WORLD_TILES.BRICK_GLOW] = { sound = "dontstarve/AMB/caves/ruins" },
    [WORLD_TILES.TILES] = { sound = "dontstarve/AMB/caves/civ_ruins" },
    [WORLD_TILES.TILES_GLOW] = { sound = "dontstarve/AMB/caves/civ_ruins" },
    [WORLD_TILES.TRIM] = { sound = "dontstarve/AMB/caves/ruins" },
    [WORLD_TILES.TRIM_GLOW] = { sound = "dontstarve/AMB/caves/ruins" },

	[WORLD_TILES.OCEAN_COASTAL] =       { sound = "hookline_2/amb/sea_shore", rainsound = "hookline_2/amb/sea_shore" },
	[WORLD_TILES.OCEAN_SWELL] =         { sound = "turnoftides/together_amb/ocean/shallow", rainsound = "turnoftides/together_amb/ocean/shallow_rain" },
	[WORLD_TILES.OCEAN_ROUGH] =         { sound = "turnoftides/together_amb/ocean/deep",    rainsound = "turnoftides/together_amb/ocean/deep_rain" },
	[WORLD_TILES.OCEAN_BRINEPOOL] =     { sound = "turnoftides/together_amb/ocean/deep",    rainsound = "turnoftides/together_amb/ocean/deep_rain" },
	[WORLD_TILES.OCEAN_HAZARDOUS] =     { sound = "turnoftides/together_amb/ocean/deep",    rainsound = "turnoftides/together_amb/ocean/deep_rain" },
    [WORLD_TILES.OCEAN_WATERLOG] =      {sound = "waterlogged2/amb/fall", wintersound = "waterlogged2/amb/winter", springsound = "waterlogged1/amb/spring", summersound = "waterlogged1/amb/summer", rainsound = "waterlogged1/amb/spring"},

    [WORLD_TILES.LAVAARENA_FLOOR] = { sound = "dontstarve/AMB/lava_arena/arena_day" },
    [WORLD_TILES.LAVAARENA_TRIM] = { sound = "dontstarve/AMB/lava_arena/arena_day" },

    [WORLD_TILES.QUAGMIRE_PEATFOREST] = {sound = "dontstarve/AMB/quagmire/peat_forest"},
    [WORLD_TILES.QUAGMIRE_PARKFIELD] = {sound = "dontstarve/AMB/quagmire/park_field"},
    [WORLD_TILES.QUAGMIRE_PARKSTONE] = {sound = "dontstarve/AMB/quagmire/park_field"},
    [WORLD_TILES.QUAGMIRE_GATEWAY] = {sound = "dontstarve/AMB/quagmire/gateway"},
    [WORLD_TILES.QUAGMIRE_SOIL] = {sound = "dontstarve/AMB/quagmire/city_stone"},
    [WORLD_TILES.QUAGMIRE_CITYSTONE] = {sound = "dontstarve/AMB/quagmire/city_stone"},

    ABYSS = { sound = "dontstarve/AMB/caves/pit" }, --- IMPASSABLE
    VOID = { sound = "dontstarve/AMB/caves/void", wintersound = "dontstarve/AMB/caves/void", springsound="dontstarve/AMB/caves/void", summersound="dontstarve/AMB/caves/void", rainsound = "dontstarve/AMB/caves/void" },
    CIVRUINS = { sound = "dontstarve/AMB/caves/civ_ruins" },
}

if TheNet:GetServerGameMode() == "quagmire" then
    AMBIENT_SOUNDS[WORLD_TILES.ROAD] = {sound = "dontstarve/AMB/quagmire/city_stone"}
end

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
local _lightattenuation = inst.state.phase ~= "day"
local _seasonmix = "autumn"
local _rainmix = false
local _heavyrainmix = false
local _lastplayerpos = nil
local _daytimeparam = 1
local _sanityparam = 0
local _enlightparam = 0
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

local function OnPhaseChange(src, phase)
    OnPhaseChanged(src, phase)
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

inst:WatchWorldState("phase", OnPhaseChange)

self:SetReverbPreset("default")

--------------------------------------------------------------------------
--[[ Wrapper function for calls into actual sound system ]]
--------------------------------------------------------------------------

local function StartEnlightenmentSound()
    inst.SoundEmitter:PlaySound(ENLIGHTENMENT_SOUND, "ENLIGHT")
end

local function SetEnlightenment(sanity)
    inst.SoundEmitter:SetParameter("ENLIGHT", "sanity", sanity)
end

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
StartEnlightenmentSound()
SetEnlightenment(_enlightparam)

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
                if TileGroupManager:IsImpassableTile(tile) then
                    wavecount = wavecount + 1
                elseif tile ~= nil then
                    tile = _tileoverrides[tile] or tile
                    local soundgroup = AMBIENT_SOUNDS[tile]
                    if soundgroup ~= nil then
                        local sound =
                                (_rainmix and _heavyrainmix and soundgroup.rainsound) or
                                (_seasonmix and soundgroup[SEASON_SOUND_KEY[_seasonmix]]) or
                                soundgroup.sound
                        local counter = soundmixcounters[sound]
                        local increment = 1
                        if sound == AMBIENT_SOUNDS.ABYSS.sound then
                            increment = 0.5
                        end

                        if counter == nil then
                            counter = { sound = sound, count = increment }
                            soundmixcounters[sound] = counter
                            table.insert(soundmix, counter)
                        else
                            counter.count = counter.count + increment
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
                        easing.outCubic(lightval - lowlight, 1, lowvolume - 1, highlight - lowlight)
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

    local sanityparam = (sanity ~= nil and sanity:IsInsanityMode()) and (1 - sanity:GetPercent()) or 0
    if player ~= nil and player:HasTag("dappereffects") then
        sanityparam = sanityparam * sanityparam
    end
    if _sanityparam ~= sanityparam then
		SetSanity(sanityparam)
        _sanityparam = sanityparam
    end

    local enlightparam = (sanity ~= nil and sanity:IsLunacyMode()) and (sanity:GetPercent()) or 0
    if player ~= nil and player:HasTag("dappereffects") then
        enlightparam = enlightparam * enlightparam
    end
    if _enlightparam ~= enlightparam then
        SetEnlightenment(enlightparam)
        _enlightparam = enlightparam
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = {}

    table.insert(str, string.format("AMBIENT SOUNDS: raining:%s heavy:%s season:%s", tostring(_rainmix), tostring(_heavyrainmix), _seasonmix))
    table.insert(str, string.format("    atten=%2.2f, day=%2.2f, waves=%2.2f", _ambientvolume, _daytimeparam, _wavesvolume))

    for k, v in pairs(_soundvolumes) do
        table.insert(str, string.format("\t%s = %2.2f", k, v))
    end

    return table.concat(str, "\n")
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
