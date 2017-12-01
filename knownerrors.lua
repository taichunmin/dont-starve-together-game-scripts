local DEBUG_MODE = BRANCH == "dev"

ERRORS = {
    CONFIG_DIR_WRITE_PERMISSION = {
        message = "Unable to write to config directory. Please make sure you have permissions for your Klei save folder.",
        url = "http://support.kleientertainment.com/customer/portal/articles/2409757",
    },
    CUSTOM_COMMANDS_ERROR = {
        message = "Error loading customcommands.lua.",
    },
}

if DEBUG_MODE then
    -- These are developer-specific and should only be used inside DEBUG_MODE.
    ERRORS.DEV_FAILED_TO_SPAWN_WORLD = {
        message = "Failed to load world from save slot.\n\n Delete the save you loaded.\n If you used Host Game, delete your first saveslot.",
    }
    ERRORS.DEV_FAILED_TO_LOAD_PREFAB = {
        message = "Failed to load prefab from file.\n\n Run updateprefabs.bat to fix.",
    }
end

function known_assert(condition, key)
    if not condition then
        if ERRORS[key] ~= nil then
            known_error_key = key
            error(ERRORS[key].message, 2)
        else
            error(key, 2)
        end
    else
        return condition
    end
end
