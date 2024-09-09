require("map/level")
require("map/settings")

global("CustomPresetManager")

--[[
Level versions:
1 - Format pre-launch of DST. Has evolved from DS format a fair amount, but still had the "tuple" style overrides.
2 - Changed tuple-style overrides to standard lua key-value pairs, and moved some things around.
--]]

local levellist = {}
local settingslist = {}
local worldgenlist = {}

for i , leveltype in ipairs({LEVELTYPE.SURVIVAL, LEVELTYPE.LAVAARENA, LEVELTYPE.QUAGMIRE, LEVELTYPE.TEST, LEVELTYPE.CUSTOM}) do
    levellist[leveltype] = {}
    settingslist[leveltype] = {}
    worldgenlist[leveltype] = {}
end

local modlevellist = {}
local modsettingslist = {}
local modworldgenlist = {}

local locations = {}

local modlocations = {}

local playstyle_defs = {}
local playstyle_order = {}

------------------------------------------------------------------
-- Module functions
------------------------------------------------------------------

local function GetDataForLocation(location)
    for mod, data in pairs(modlocations) do
        if data[location] ~= nil then
            return deepcopy(data[location])
        end
    end
    return deepcopy(locations[location])
end

local function ClearModData(mod)
    if mod ~= nil then
        modlocations[mod] = nil
        modlevellist[mod] = nil
        modsettingslist[mod] = nil
        modworldgenlist[mod] = nil
    else
        modlocations = {}
        modlevellist = {}
        modsettingslist = {}
        modworldgenlist = {}
    end
end

--old LevelID System
local function GetLevelList(leveltype, location, frontend)
    local ret = {}
    if levellist[leveltype] ~= nil then
		for i,level in ipairs(levellist[leveltype]) do
			if location == nil or level.location == location then
				if frontend ~= true or level.hideinfrontend ~= true then
					table.insert(ret, {text=level.name, data=level.id})
				end
			end
		end
	end

    for mod,leveltypes in pairs(modlevellist) do
        if leveltypes[leveltype] ~= nil then
			for i,level in ipairs(leveltypes[leveltype]) do
				if location == nil or level.location == location then
					if frontend ~= true or level.hideinfrontend ~= true then
						table.insert(ret, {text=level.name, data=level.id})
					end
				end
			end
		end
    end

    local profilepresets = Profile:GetWorldCustomizationPresets()
    if profilepresets ~= nil then
        for i, level in pairs(profilepresets) do
            if location == nil or level.location == location then
                if level.id ~= nil and level.name ~= nil then -- could be looking at a preset that hasn't been upgraded yet, just skip it...
                    table.insert(ret, {text=level.name, data=level.id})
                end
            end
        end
    end

    return ret
end

local function GetDataForLevelID(id, nolocation) -- nolocation should generally only be used when copying presets to custom presets
    id = id:lower()

    for _, leveltypes in pairs(modlevellist) do
		for _, levels in pairs(leveltypes) do
			for _, level in ipairs(levels) do
				if level.id:lower() == id then
					if nolocation == nil or nolocation == false then
						local ret = GetDataForLocation(level.location)
						return MergeMapsDeep(ret, level)
					else
						return level
					end
				end
			end
		end
    end

	for _, levels in pairs(levellist) do
		for _, level in ipairs(levels) do
			if level.id:lower() == id then
				if nolocation == nil or nolocation == false then
					local ret = GetDataForLocation(level.location)
					return MergeMapsDeep(ret, level)
				else
					return level
				end
			end
		end
	end

    global("Profile")
    if Profile ~= nil then -- Profile is nil during startup
        local profilepresets = Profile:GetWorldCustomizationPresets()
        if profilepresets ~= nil then
            for i, level in pairs(profilepresets) do
                if level.id ~= nil and level.id:lower() == id then
                    assert(level.location ~= nil, "Preset level missing a location! "..level.id)
                    if nolocation == nil or nolocation == false then
                        local ret = GetDataForLocation(level.location)
                        return MergeMapsDeep(ret, level)
                    else
                        return level
                    end
                end
            end
        end
    end

    return nil
end

local function GetDefaultLevelData(leveltype, location) -- implicitly "frontend", that's part of what "default" means
    location = location or DEFAULT_LOCATION
    local validlevels = GetLevelList(leveltype, location, true)
    if #validlevels > 0 then
        return GetDataForLevelID(validlevels[1].data)
    end
    return nil
end

local function GetTypeForLevelID(id)
    if id == nil or id:lower() == "unknown" then
        return LEVELTYPE.UNKNOWN
    end

    id = id:lower()

    for _, leveltypes in pairs(modlevellist) do
        for type, levels in pairs(leveltypes) do
            for _, level in ipairs(levels) do
                if level.id:lower() == id then
                    return type
                end
            end
        end
    end

    for type, levels in pairs(levellist) do
        for _, level in ipairs(levels) do
            if level.id:lower() == id then
                return type
            end
        end
    end

    -- Note: custom presets are unknown, this method can be used to distinguish them.
    return LEVELTYPE.UNKNOWN
end

local function GetNameForLevelID(level_id)
    local level = GetDataForLevelID(level_id)
    return level ~= nil and level.name or nil
end

local function GetDescForLevelID(level_id)
    local level = GetDataForLevelID(level_id)
    return level ~= nil and level.desc or nil
end

local function GetLocationForLevelID(level_id)
    local level = GetDataForLevelID(level_id)
    return level ~= nil and level.location or nil
end

--SettingsID
local function GetSettingsList(leveltype, location, frontend)
    local ret = {}
    local ret_indexes = {}

    if settingslist[leveltype] ~= nil then
		for _, level in ipairs(settingslist[leveltype]) do
			if location == nil or level.location == location then
                if frontend ~= true or level.hideinfrontend ~= true then
					table.insert(ret, {text = level.settings_name, data = level.settings_id})
                    ret_indexes[level.settings_id] = #ret
				end
			end
		end
	end

    for _, leveltypes in pairs(modsettingslist) do
        if leveltypes[leveltype] ~= nil then
			for _, level in ipairs(leveltypes[leveltype]) do
				if location == nil or level.location == location then
                    if frontend ~= true or level.hideinfrontend ~= true then
						table.insert(ret, {text = level.settings_name, data = level.settings_id, modded = true})
                        ret_indexes[level.settings_id] = #ret
					end
				end
			end
		end
    end

    for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.SETTINGS)) do
        local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.SETTINGS, custompresetid)
        if level and (location == nil or level.location == location) and ret_indexes[level.settings_baseid] then
            table.insert(ret, {text = level.settings_name, data = level.settings_id, modded = ret[ret_indexes[level.settings_baseid]].modded})
        end
    end

    return ret
end

local function MergeLocationSettings(level)
    local Customize = require("map/customize")
    local ret = GetDataForLocation(level.location)
    if ret.overrides then
        for name, value in pairs(ret.overrides) do
            if Customize.GetCategoryForOption(name) == LEVELCATEGORY.SETTINGS then
                ret.overrides[name] = value
            else
                ret.overrides[name] = nil
            end
        end
    end
    local _level = deepcopy(level)
    _level.overrides = MergeMapsDeep(ret.overrides, _level.overrides)
    return _level
end

local function GetDataForSettingsID(id, nolocation) -- nolocation should generally only be used when copying presets to custom presets
    id = id:lower()

    for _, leveltypes in pairs(modsettingslist) do
		for _, levels in pairs(leveltypes) do
			for _, level in ipairs(levels) do
				if level.settings_id:lower() == id then
                    if not nolocation then
                        return MergeLocationSettings(level)
					else
						return level
					end
				end
			end
		end
    end

	for _, levels in pairs(settingslist) do
		for _, level in ipairs(levels) do
			if level.settings_id:lower() == id then
                if not nolocation then
                    return MergeLocationSettings(level)
				else
					return level
				end
			end
		end
    end

    if CustomPresetManager then
        for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.SETTINGS)) do
            if custompresetid:lower() == id then
                local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.SETTINGS, custompresetid)
                if level then
                    if not nolocation then
                        return MergeLocationSettings(level)
                    else
                        return level
                    end
                end
            end
        end
    end

    return nil
end

local function GetDefaultSettingsData(leveltype, location) -- implicitly "frontend", that's part of what "default" means
    location = location or DEFAULT_LOCATION
    local validlevels = GetSettingsList(leveltype, location, true)
    if #validlevels > 0 then
        return GetDataForSettingsID(validlevels[1].data)
    end
    return nil
end

local function GetTypeForSettingsID(id)
    if id == nil or id:lower() == "unknown" then
        return LEVELTYPE.UNKNOWN
    end

    id = id:lower()

    for _, leveltypes in pairs(modsettingslist) do
        for type, levels in pairs(leveltypes) do
            for _, level in ipairs(levels) do
                if level.settings_id:lower() == id then
                    return type
                end
            end
        end
    end

    for type, levels in pairs(settingslist) do
        for _, level in ipairs(levels) do
            if level.settings_id:lower() == id then
                return type
            end
        end
    end

    --Note: custom presets are special
    return LEVELTYPE.CUSTOMPRESET
end

local function GetNameForSettingsID(level_id)
    local level = GetDataForSettingsID(level_id)
    return level ~= nil and level.settings_name or nil
end

local function GetDescForSettingsID(level_id)
    local level = GetDataForSettingsID(level_id)
    return level ~= nil and level.settings_desc or nil
end

local function GetLocationForSettingsID(level_id)
    local level = GetDataForSettingsID(level_id)
    return level ~= nil and level.location or nil
end

--WorldGenID
local function GetWorldGenList(leveltype, location, frontend)
    local ret = {}
    local ret_indexes = {}

    if worldgenlist[leveltype] ~= nil then
		for _, level in ipairs(worldgenlist[leveltype]) do
			if location == nil or level.location == location then
                if frontend ~= true or level.hideinfrontend ~= true then
					table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id})
                    ret_indexes[level.worldgen_id] = #ret
				end
			end
		end
	end

    for _, leveltypes in pairs(modworldgenlist) do
        if leveltypes[leveltype] ~= nil then
			for _, level in ipairs(leveltypes[leveltype]) do
				if location == nil or level.location == location then
                    if frontend ~= true or level.hideinfrontend ~= true then
						table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id, modded = true})
                        ret_indexes[level.worldgen_id] = #ret
					end
				end
			end
		end
    end

    for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.WORLDGEN)) do
        local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.WORLDGEN, custompresetid)
        if level and (location == nil or level.location == location) and ret_indexes[level.worldgen_baseid] then
            table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id, modded = ret[ret_indexes[level.worldgen_baseid]].modded})
        end
    end

    return ret
end

local function MergeLocationWorldGen(level)
    local Customize = require("map/customize")
    local ret = GetDataForLocation(level.location)
    if ret.overrides then
        for name, value in pairs(ret.overrides) do
            if Customize.GetCategoryForOption(name) ~= LEVELCATEGORY.SETTINGS then
                ret.overrides[name] = value
            else
                ret.overrides[name] = nil
            end
        end
    end
    return Level(MergeMapsDeep(ret, level))
end

local function GetDataForWorldGenID(id, nolocation) --nolocation should generally only be used when copying presets to custom presets
    id = id:lower()

    for _, leveltypes in pairs(modworldgenlist) do
		for _, levels in pairs(leveltypes) do
			for _, level in ipairs(levels) do
				if level.worldgen_id:lower() == id then
                    if not nolocation then
                        return MergeLocationWorldGen(level)
					else
						return level
					end
				end
			end
		end
    end

	for _, levels in pairs(worldgenlist) do
		for _, level in ipairs(levels) do
			if level.worldgen_id:lower() == id then
                if not nolocation then
                    return MergeLocationWorldGen(level)
				else
					return level
				end
			end
		end
	end

    if CustomPresetManager then
        for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.WORLDGEN)) do
            if custompresetid:lower() == id then
                local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.WORLDGEN, custompresetid)
                if level then
                    if not nolocation then
                        return MergeLocationWorldGen(level)
                    else
                        return level
                    end
                end
            end
        end
    end

    return nil
end

local function GetDefaultWorldGenData(leveltype, location) -- implicitly "frontend", that's part of what "default" means
    location = location or DEFAULT_LOCATION
    local validlevels = GetWorldGenList(leveltype, location, true)
    if #validlevels > 0 then
        return GetDataForWorldGenID(validlevels[1].data)
    end
    return nil
end

local function GetTypeForWorldGenID(id)
    if id == nil or id:lower() == "unknown" then
        return LEVELTYPE.UNKNOWN
    end

    id = id:lower()

    for _, leveltypes in pairs(modworldgenlist) do
        for type, levels in pairs(leveltypes) do
            for _, level in ipairs(levels) do
                if level.worldgen_id:lower() == id then
                    return type
                end
            end
        end
    end

    for type, levels in pairs(worldgenlist) do
        for _, level in ipairs(levels) do
            if level.worldgen_id:lower() == id then
                return type
            end
        end
    end

    --Note: custom presets are special
    return LEVELTYPE.CUSTOMPRESET
end

local function GetNameForWorldGenID(level_id)
    local level = GetDataForWorldGenID(level_id)
    return level ~= nil and level.worldgen_name or nil
end

local function GetDescForWorldGenID(level_id)
    local level = GetDataForWorldGenID(level_id)
    return level ~= nil and level.worldgen_desc or nil
end

local function GetLocationForWorldGenID(level_id)
    local level = GetDataForWorldGenID(level_id)
    return level ~= nil and level.location or nil
end

local function GetCombinedList(leveltype, location, frontend)
    local ret = {}
    local ret_indexes = {}

    if worldgenlist[leveltype] ~= nil then
		for _, level in ipairs(worldgenlist[leveltype]) do
			if location == nil or level.location == location then
                if (frontend ~= true or level.hideinfrontend ~= true) and not ret_indexes[level.worldgen_id] then
					table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id})
                    ret_indexes[level.worldgen_id] = #ret
				end
			end
		end
	end

    if settingslist[leveltype] ~= nil then
		for _, level in ipairs(settingslist[leveltype]) do
			if location == nil or level.location == location then
                if (frontend ~= true or level.hideinfrontend ~= true) and not ret_indexes[level.settings_id] then
					table.insert(ret, {text = level.settings_name, data = level.settings_id})
                    ret_indexes[level.settings_id] = #ret
				end
			end
		end
	end

    for _, leveltypes in pairs(modworldgenlist) do
        if leveltypes[leveltype] ~= nil then
			for _, level in ipairs(leveltypes[leveltype]) do
				if location == nil or level.location == location then
                    if (frontend ~= true or level.hideinfrontend ~= true) and not ret_indexes[level.worldgen_id] then
						table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id, modded = true})
                        ret_indexes[level.worldgen_id] = #ret
					end
				end
			end
		end
    end

    for _, leveltypes in pairs(modsettingslist) do
        if leveltypes[leveltype] ~= nil then
			for _, level in ipairs(leveltypes[leveltype]) do
				if location == nil or level.location == location then
                    if (frontend ~= true or level.hideinfrontend ~= true) and not ret_indexes[level.settings_id] then
						table.insert(ret, {text = level.settings_name, data = level.settings_id, modded = true})
                        ret_indexes[level.settings_id] = #ret
					end
				end
			end
		end
    end

    for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.WORLDGEN)) do
        local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.WORLDGEN, custompresetid)
        if level and (location == nil or level.location == location) and ret_indexes[level.worldgen_baseid] and not ret_indexes[level.worldgen_id] then
            table.insert(ret, {text = level.worldgen_name, data = level.worldgen_id, modded = ret[ret_indexes[level.worldgen_baseid]].modded})
            ret_indexes[level.worldgen_id] = #ret
        end
    end

    for _, custompresetid in ipairs(CustomPresetManager:GetPresetIDs(LEVELCATEGORY.SETTINGS)) do
        local level = CustomPresetManager:LoadCustomPreset(LEVELCATEGORY.SETTINGS, custompresetid)
        if level and (location == nil or level.location == location) and ret_indexes[level.settings_baseid] and not ret_indexes[level.settings_id] then
            table.insert(ret, {text = level.settings_name, data = level.settings_id, modded = ret[ret_indexes[level.settings_baseid]].modded})
            ret_indexes[level.settings_id] = #ret
        end
    end

    return ret
end

local function GetList(category, ...)
    if category == LEVELCATEGORY.SETTINGS then
        return GetSettingsList(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetWorldGenList(...)
    elseif category == LEVELCATEGORY.COMBINED then
        return GetCombinedList(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetLevelList(...)
    end
end
local function GetDefaultData(category, ...)
    if category == LEVELCATEGORY.SETTINGS then
        return GetDefaultSettingsData(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetDefaultWorldGenData(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetDefaultLevelData(...)
    end
end
local function GetDataForID(category, ...)
    if category == LEVELCATEGORY.COMBINED then
        return GetDataForSettingsID(...) or GetDataForWorldGenID(...)
    elseif category == LEVELCATEGORY.SETTINGS then
        return GetDataForSettingsID(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetDataForWorldGenID(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetDataForLevelID(...)
    end
end
local function GetTypeForID(category, ...)
    if category == LEVELCATEGORY.SETTINGS then
        return GetTypeForSettingsID(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetTypeForWorldGenID(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetTypeForLevelID(...)
    end
end
local function GetNameForID(category, ...)
    if category == LEVELCATEGORY.COMBINED then
        return GetNameForSettingsID(...) or GetNameForWorldGenID(...)
    elseif category == LEVELCATEGORY.SETTINGS then
        return GetNameForSettingsID(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetNameForWorldGenID(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetNameForLevelID(...)
    end
end
local function GetDescForID(category, ...)
    if category == LEVELCATEGORY.COMBINED then
        return GetDescForSettingsID(...) or GetDescForWorldGenID(...)
    elseif category == LEVELCATEGORY.SETTINGS then
        return GetDescForSettingsID(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetDescForWorldGenID(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetDescForLevelID(...)
    end
end
local function GetLocationForID(category, ...)
    if category == LEVELCATEGORY.SETTINGS then
        return GetLocationForSettingsID(...)
    elseif category == LEVELCATEGORY.WORLDGEN then
        return GetLocationForWorldGenID(...)
    elseif category == LEVELCATEGORY.LEVEL then
        return GetLocationForLevelID(...)
    end
end

local function GetPlaystyles()
	return playstyle_order
end

local function GetPlaystyleDef(id)
	return playstyle_defs[id]
end

function CalcPlaystyleForSettings(settings_overrides)
	local scores = {}

	for i, playstyle_def in pairs(playstyle_defs) do
		local score = playstyle_def.is_default and 0.5 or 1
		for override, value in pairs(playstyle_def.overrides) do
			if settings_overrides[override] ~= value then
				score = 0
				break
			end
		end

		table.insert(scores, {id = playstyle_def.id, score = score, priority = playstyle_def.priority})
	end

	table.sort(scores, function(a, b) return a.score > b.score or (a.score == b.score and a.priority > b.priority) end)

	--print("scores")
	--dumptable(scores)


	return scores[1].id
end

------------------------------------------------------------------
-- GLOBAL functions
------------------------------------------------------------------

function AddLocation(data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModLocation(ModManager.currentlyloadingmod, data)
        return
    end
    assert(GetDataForLocation(data.location) == nil, string.format("Tried adding a location '%s', but one already exists!", data.location))
    locations[data.location] = data
end

function AddModLocation(mod, data)
    if GetDataForLocation(data.location) ~= nil then
        moderror(string.format("Tried adding a location '%s', but one already exists!", data.location))
        return
    end
    modlocations[mod] = modlocations[mod] or {}
    modlocations[mod][data.location] = data
end

function AddLevel(type, data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModLevel(ModManager.currentlyloadingmod, type, data)
        return
    end
    assert(GetDataForLevelID(data.id, true) == nil, string.format("Tried adding a level with id %s, but one already exists!", data.id))
	table.insert(levellist[type], Level(data))
end

function AddModLevel(mod, type, data)
    assert(string.sub(data.id, 1, 7) ~= "CUSTOM_", "the prefix \"CUSTOM_\" Is reserved.")
    if GetDataForLevelID(data.id, true) ~= nil then
        moderror(string.format("Tried adding a level with id %s, but one already exists!", data.id))
        return
    end
    modlevellist[mod] = modlevellist[mod] or {}
    modlevellist[mod][type] = modlevellist[mod][type] or {}
    table.insert(modlevellist[mod][type], Level(data))

    local settings = {version = 1}
    for _, index in ipairs({"id", "name", "desc", "location", "hideinfrontend", "hideminimap"}) do
        settings[index] = data[index]
    end
    local Customize = require("map/customize")
    settings.overrides = Customize.GetWorldSettingsFromLevelSettings(data.overrides)
    AddModSettingsPreset(mod, type, settings)

    local worldgen = deepcopy(data)
    for override in pairs(settings.overrides) do
        worldgen.overrides[override] = nil
    end
    worldgen.hideminimap = nil
    AddModWorldGenLevel(mod, type, worldgen)
end

function AddSettingsPreset(type, data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModSettingsPreset(ModManager.currentlyloadingmod, type, data)
        return
    end
    assert(GetDataForSettingsID(data.id, true) == nil, string.format("Tried adding a SettingsPreset with id %s, but one already exists!", data.id))
    table.insert(settingslist[type], SettingsPreset(data))
end

function AddModSettingsPreset(mod, type, data)
    assert(string.sub(data.id, 1, 7) ~= "CUSTOM_", "the prefix \"CUSTOM_\" Is reserved.")
    if GetDataForSettingsID(data.id, true) ~= nil then
        moderror(string.format("Tried adding a SettingsPreset with id %s, but one already exists!", data.id))
        return
    end
    modsettingslist[mod] = modsettingslist[mod] or {}
    modsettingslist[mod][type] = modsettingslist[mod][type] or {}
    table.insert(modsettingslist[mod][type], SettingsPreset(data))
end

function AddWorldGenLevel(type, data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModWorldGenLevel(ModManager.currentlyloadingmod, type, data)
        return
    end
    assert(GetDataForWorldGenID(data.id, true) == nil, string.format("Tried adding a WorldGenLevel with id %s, but one already exists!", data.id))
	table.insert(worldgenlist[type], Level(data))
end

function AddModWorldGenLevel(mod, type, data)
    assert(string.sub(data.id, 1, 7) ~= "CUSTOM_", "the prefix \"CUSTOM_\" Is reserved.")
    if GetDataForWorldGenID(data.id, true) ~= nil then
        moderror(string.format("Tried adding a WorldGenLevel with id %s, but one already exists!", data.id))
        return
    end
    modworldgenlist[mod] = modworldgenlist[mod] or {}
    modworldgenlist[mod][type] = modworldgenlist[mod][type] or {}
    table.insert(modworldgenlist[mod][type], Level(data))
end

function AddPlaystyleDef(def)
	assert(playstyle_defs[def.id] == nil, string.format("Tried adding a Playstyle with id %s, but one already exists!", def.id))

	table.insert(playstyle_order, def.id)
	playstyle_defs[def.id] = def
end

------------------------------------------------------------------
-- Load the data
------------------------------------------------------------------

require("map/locations")

require("map/levels/forest")
require("map/levels/caves")
require("map/levels/lavaarena")
require("map/levels/quagmire")

------------------------------------------------------------------
-- Export functions
------------------------------------------------------------------

return {
    GetDataForLocation = GetDataForLocation,
    ClearModData = ClearModData,

    --Depreciated
    GetLevelList = GetLevelList,
    GetDefaultLevelData = GetDefaultLevelData,
    GetDataForLevelID = GetDataForLevelID,
    GetTypeForLevelID = GetTypeForLevelID,
    GetNameForLevelID = GetNameForLevelID,
    GetDescForLevelID = GetDescForLevelID,
    GetLocationForLevelID = GetLocationForLevelID,
    --Depreciated

    GetSettingsList = GetSettingsList,
    GetDefaultSettingsData = GetDefaultSettingsData,
    GetDataForSettingsID = GetDataForSettingsID,
    GetTypeForSettingsID = GetTypeForSettingsID,
    GetNameForSettingsID = GetNameForSettingsID,
    GetDescForSettingsID = GetDescForSettingsID,
    GetLocationForSettingsID = GetLocationForSettingsID,

    GetWorldGenList = GetWorldGenList,
    GetDefaultWorldGenData = GetDefaultWorldGenData,
    GetDataForWorldGenID = GetDataForWorldGenID,
    GetTypeForWorldGenID = GetTypeForWorldGenID,
    GetNameForWorldGenID = GetNameForWorldGenID,
    GetDescForWorldGenID = GetDescForWorldGenID,
    GetLocationForWorldGenID = GetLocationForWorldGenID,

    GetList = GetList,
    GetDefaultData = GetDefaultData,
    GetDataForID = GetDataForID,
    GetTypeForID = GetTypeForID,
    GetNameForID = GetNameForID,
    GetDescForID = GetDescForID,
    GetLocationForID = GetLocationForID,

	GetPlaystyles = GetPlaystyles,
	GetPlaystyleDef = GetPlaystyleDef,

	CalcPlaystyleForSettings = CalcPlaystyleForSettings,
}
