local DEBUG_MODE = BRANCH == "dev"

ERRORS = {
    CONFIG_DIR_WRITE_PERMISSION = {
        message = "Unable to write to config directory.\nPlease make sure you have permissions for your Klei save folder.",
        url = "https://support.klei.com/hc/en-us/articles/360029882171",
    },
    CONFIG_DIR_READ_PERMISSION = {
        message = "Unable to read from config directory.\nPlease make sure you have read permissions for your Klei save folder.",
        url = "https://support.klei.com/hc/en-us/articles/360035294792",
    },
    CONFIG_DIR_CLIENT_LOG_PERMISSION = {
        message = "Unable to write to files in the config directory.\nPlease make sure you have permissions for your Klei save folder.",
        url = "https://support.klei.com/hc/en-us/articles/360029882171",
    },
    CUSTOM_COMMANDS_ERROR = {
        message = "Error loading customcommands.lua.",
    },
    AGREEMENTS_WRITE_PERMISSION = {
        message = "Unable to write to the agreements file.\nPlease make sure you have permissions for your Klei save folder.",
        url = "https://support.klei.com/hc/en-us/articles/360029881751",
    },
    CONFIG_DIR_DISK_SPACE = {
        message = "There is not enough available hard drive space to reliably save worlds. Please free up some hard drive space.",
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
