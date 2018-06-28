require("map/level")

--[[

Level versions:
1 - Format pre-launch of DST. Has evolved from DS format a fair amount, but still had the "tuple" style overrides.
2 - Changed tuple-style overrides to standard lua key-value pairs, and moved some things around.


--]]

DEFAULT_LOCATION = "forest"

local levellist = {}
levellist[LEVELTYPE.SURVIVAL] = {}
levellist[LEVELTYPE.LAVAARENA] = {}
levellist[LEVELTYPE.QUAGMIRE] = {}
levellist[LEVELTYPE.TEST] = {}
levellist[LEVELTYPE.CUSTOM] = {}

local modlevellist = {}

local locations = {}

local modlocations = {}

------------------------------------------------------------------
-- Module functions
------------------------------------------------------------------

local function GetDataForLocation(location)
    for mod,data in pairs(modlocations) do
        if data[location] ~= nil then
            return deepcopy(data[location])
        end
    end
    return deepcopy(locations[location])
end

local function GetTypeForLevelID(id)
    if id == nil or id:lower() == "unknown" then
        return LEVELTYPE.UNKNOWN
    end

    id = id:lower()

    for mod,leveltypes in pairs(modlevellist) do
        for type, levels in pairs(leveltypes) do
            for idx, level in ipairs(levels) do
                if level.id:lower() == id then
                    return type
                end
            end
        end
    end

    for type, levels in pairs(levellist) do
        for idx, level in ipairs(levels) do
            if level.id:lower() == id then
                return type
            end
        end
    end

    -- Note: custom presets are unknown, this method can be used to distinguish them.
    return LEVELTYPE.UNKNOWN
end

local function GetDataForLevelID(id, nolocation) -- nolocation should generally only be used when copying presets to custom presets
	
    id = id:lower()

    for mod,leveltypes in pairs(modlevellist) do
		for level_type,levels in pairs(leveltypes) do
			for i,level in ipairs(levels) do
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

	for level_type,levels in pairs(levellist) do
		for i,level in ipairs(levels) do
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
                if level.id:lower() == id then
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

local function GetDefaultLevelData(leveltype, location) -- implicitly "frontend", that's part of what "default" means
    location = location or DEFAULT_LOCATION
    local validlevels = GetLevelList(leveltype, location, true)
    if #validlevels > 0 then
        return GetDataForLevelID(validlevels[1].data)
    end
    return nil
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

local function ClearModData(mod)
    if mod ~= nil then
        modlocations[mod] = nil
        modlevellist[mod] = nil
    else
        modlocations = {}
        modlevellist = {}
    end
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
    if modlocations[mod] == nil then modlocations[mod] = {} end
    modlocations[mod][data.location] = data
end

function AddLevel(type, data)
    if ModManager.currentlyloadingmod ~= nil then
        AddModLevel(ModManager.currentlyloadingmod, type, data)
        return
    end
    assert(GetDataForLevelID(data.id) == nil, string.format("Tried adding a level with id %s, but one already exists!", data.id))
	table.insert(levellist[type], Level(data))
end

function AddModLevel(mod, type, data)
    if GetDataForLevelID(data.id) ~= nil then
        moderror(string.format("Tried adding a level with id %s, but one already exists!", data.id))
        return
    end
    if modlevellist[mod] == nil then modlevellist[mod] = {} end
    if modlevellist[mod][type] == nil then modlevellist[mod][type] = {} end
    table.insert(modlevellist[mod][type], Level(data))
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
            GetLevelList = GetLevelList,
            GetDefaultLevelData = GetDefaultLevelData,
            GetDataForLevelID = GetDataForLevelID,
            GetTypeForLevelID = GetTypeForLevelID,
            GetNameForLevelID = GetNameForLevelID,
            GetDescForLevelID = GetDescForLevelID,
            GetLocationForLevelID = GetLocationForLevelID,
            GetDataForLocation = GetDataForLocation,
            ClearModData = ClearModData,
        }
