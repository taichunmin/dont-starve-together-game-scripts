local DEBUG_MODE = BRANCH == "dev"

DEFAULT_GAME_MODE = "survival" --only used when we can't actually find the game mode of a saved server slot

GAME_MODES =
{
    survival =
    {
        text = "",
        description = "",
        level_type = LEVELTYPE.SURVIVAL,
        mod_game_mode = false,
        spawn_mode = "fixed",
        resource_renewal = false,
        ghost_sanity_drain = true,
        ghost_enabled = true,
        portal_rez = false,
        reset_time = { time = 120, loadingtime = 180 },
        invalid_recipes = nil,
    },
    wilderness =
    {
        text = "",
        description = "",
        level_type = LEVELTYPE.SURVIVAL,
        mod_game_mode = false,
        spawn_mode = "scatter",
        resource_renewal = true,
        ghost_sanity_drain = false,
        ghost_enabled = false,
        portal_rez = false,
        reset_time = nil,
        invalid_recipes = { "resurrectionstatue" },
    },
    endless =
    {
        text = "",
        description = "",
        level_type = LEVELTYPE.SURVIVAL,
        mod_game_mode = false,
        spawn_mode = "fixed",
        resource_renewal = true,
        ghost_sanity_drain = false,
        ghost_enabled = true,
        portal_rez = true,
        reset_time = nil,
        invalid_recipes = nil,
    },
    lavaarena =
    {
        internal = true,
        text = "",
        description = "",
        level_type = LEVELTYPE.LAVAARENA,
        mod_game_mode = false,
        spawn_mode = "fixed",
        resource_renewal = false,
        ghost_sanity_drain = false,
        ghost_enabled = false,
        revivable_corpse = true,
        spectator_corpse = true,
        portal_rez = false,
        reset_time = nil,
        invalid_recipes = nil,
        --
        override_item_slots = 0,
        drop_everything_on_despawn = true,
        no_air_attack = true,
        no_crafting = true,
        no_minimap = true,
        no_hunger = true,
        no_sanity = true,
        no_avatar_popup = true,
        no_morgue_record = true,
        override_normal_mix = "lavaarena_normal",
        override_lobby_music = "dontstarve/music/lava_arena/FE2",
        cloudcolour = { .4, .05, 0 },
        cameraoverridefn = function(camera)
            camera.mindist = 20
            camera.mindistpitch = 32
            camera.maxdist = 55
            camera.maxdistpitch = 60
            camera.distancetarget = 32
        end,
        lobbywaitforallplayers = true,
        hide_worldgen_loading_screen = true,
        hide_received_gifts = true,
        skin_tag = "LAVA",
    },
    quagmire =
    {
        internal = true,
        text = "",
        description = "",
        level_type = LEVELTYPE.QUAGMIRE,
        mod_game_mode = false,
        spawn_mode = "fixed",
        resource_renewal = false,
        ghost_sanity_drain = false,
        ghost_enabled = false,
        revivable_corpse = true,
        portal_rez = true,
        reset_time = nil,
        invalid_recipes = nil,
        --
        max_players = 3,
        override_item_slots = 4,
        drop_everything_on_despawn = true,
        non_item_equips = true,
        no_air_attack = true,
        no_minimap = false, -- the minimap gets hijacked for the recipe book
        no_hunger = true,
        no_eating = true,
        no_sanity = true,
        no_temperature = true,
        no_avatar_popup = true,
        no_morgue_record = true,
        override_normal_mix = "lavaarena_normal",
        override_lobby_music = "dontstarve/quagmire/music/FE",
        lobbywaitforallplayers = true,
        hide_worldgen_loading_screen = true,
        hide_received_gifts = true,
        skin_tag = "VICTORIAN",
        disable_transplanting = true,
        disable_bird_mercy_items = true,
        icons_use_cc = true,
		hud_atlas = "images/quagmire_hud.xml",
		eventannouncer_offset = -40,
		override_farm_till_spacing = 1,
    },
}

local GAME_MODE_ERROR =
{
    text = "",
    description = "",
    level_type = LEVELTYPE.SURVIVAL,
    mod_game_mode = true,
    spawn_mode = "fixed",
    resource_renewal = false,
    ghost_sanity_drain = false,
    ghost_enabled = true,
    portal_rez = false,
    reset_time = nil,
    invalid_recipes = nil,
}

GAME_MODES_ORDER =
{
    survival = 1,
    wilderness = 2,
    endless = 3,
    lavaarena = 4,
    quagmire = 5,
}

local function mode_cmp(a, b)
    return (GAME_MODES_ORDER[a.data] or math.huge) < (GAME_MODES_ORDER[b.data] or math.huge)
end

local function GameModeError(game_mode)
    if not IsInFrontEnd() then
        moderror(string.format("Game mode '%s' not found in GAME_MODES", tostring(game_mode)))
    end
    return GAME_MODE_ERROR
end

local function GetGameMode(game_mode)
    return GAME_MODES[game_mode] or GameModeError(game_mode)
end

--------------------------------------------------------------------------

function AddGameMode(game_mode, game_mode_text)
    GAME_MODES[game_mode] =
    {
        modded_mode = true,
        text = game_mode_text,
        description = "",
        level_type = LEVELTYPE.SURVIVAL,
        mod_game_mode = true,
        spawn_mode = "fixed",
        resource_renewal = false,
        ghost_sanity_drain = false,
        ghost_enabled = true,
        portal_rez = false,
        reset_time = nil,
        invalid_recipes = {},
    }
    return GAME_MODES[game_mode]
end

function GetGameModeProperty(property)
    --print ("GetGameModeProperty:", tostring(TheNet:GetServerGameMode()), property, tostring(GetGameMode(TheNet:GetServerGameMode())[property]))
    return GetGameMode(TheNet:GetServerGameMode())[property]
end

function GetGameModesSpinnerData(enabled_mods)
    local spinner_data = {}
    for k, v in pairs(GAME_MODES) do
        if (not v.internal or DEBUG_MODE) and not v.modded_mode then
            table.insert(spinner_data, { text = STRINGS.UI.GAMEMODES[string.upper(k)] or "blank", data = k })
        end
    end

    if enabled_mods ~= nil then
        --add game modes from mods
        for _, modname in pairs(enabled_mods) do
            local modinfo = KnownModIndex:GetModInfo(modname)
            if modinfo ~= nil and modinfo.game_modes ~= nil then
                for _, game_mode in pairs(modinfo.game_modes) do
                    table.insert(spinner_data, { text = game_mode.label or "blank", data = game_mode.name })
                end
            end
        end
    end

    table.sort(spinner_data, mode_cmp)
    return spinner_data
end

function GetGameModeTag(game_mode)
    return game_mode ~= nil
        and game_mode ~= ""
        and (STRINGS.TAGS.GAMEMODE[string.upper(game_mode)] or game_mode)
        or nil
end

-- Used by C side. Do NOT rename without editing simulation.cpp
function GetGameModeString(game_mode)
    if game_mode == "" then
        return STRINGS.UI.GAMEMODES.UNKNOWN
    end
    local data = GAME_MODES[game_mode]
    return data == nil and STRINGS.UI.GAMEMODES.CUSTOM
        or STRINGS.UI.GAMEMODES[string.upper(game_mode)]
        or data.text
end

function GetGameModeDescriptionString(game_mode)
    if game_mode == "" then
        return ""
    end
    local data = GAME_MODES[game_mode]
    return data == nil and ""
        or data.hover_text
        or STRINGS.UI.GAMEMODES[string.upper(game_mode).."_DESCRIPTION"]
        or data.description
end

-- For backwards compatibility
GetGameModeHoverTextString = GetGameModeDescriptionString

function GetIsModGameMode(game_mode)
    --Used by serverlistingscreen, don't want to spam mod error message
    return (GAME_MODES[game_mode] or GAME_MODE_ERROR).mod_game_mode
end

function GetGhostSanityDrain(game_mode)
    return GetGameMode(game_mode).ghost_sanity_drain
end

function GetIsSpawnModeFixed(game_mode)
    return GetGameMode(game_mode).spawn_mode == "fixed"
end

function GetSpawnMode(game_mode)
    return GetGameMode(game_mode).spawn_mode
end

function GetHasResourceRenewal(game_mode)
    return GetGameMode(game_mode).resource_renewal
end

function GetGhostEnabled(game_mode)
    return GetGameMode(game_mode).ghost_enabled
end

function GetPortalRez(game_mode)
    return GetGameMode(game_mode).portal_rez
end

function GetResetTime(game_mode)
    return GetGameMode(game_mode).reset_time
end

function IsRecipeValidInGameMode(game_mode, recipe_name)
    local invalid_recipes = GetGameMode(game_mode).invalid_recipes
    if invalid_recipes ~= nil then
        for i, v in ipairs(invalid_recipes) do
            if v == recipe_name then
                return false
            end
        end
    end
    return true
end

function GetLevelType(game_mode)
    return GetGameMode(game_mode).level_type
end

function GetMaxItemSlots(game_mode)
    return GetGameMode(game_mode).override_item_slots or MAXITEMSLOTS
end

function GetFarmTillSpacing(game_mode)
    return GetGameMode(game_mode or TheNet:GetServerGameMode()).override_farm_till_spacing or TUNING.FARM_TILL_SPACING
end

function GetGameModeMaxPlayers(game_mode)
    local data = GAME_MODES[game_mode]
    return data ~= nil and data.max_players or nil
end
