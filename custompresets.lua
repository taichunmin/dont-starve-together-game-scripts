local Levels = require("map/levels")
local Customize = require("map/customize")

local WORLD_PRESETS_FOLDER = "world_presets/"
local PRESET_PREFIX = "CUSTOM_"
local EXTENSIONS = {
    [LEVELCATEGORY.SETTINGS] = ".wsp",
    [LEVELCATEGORY.WORLDGEN] = ".wgp",
}

local function UpgradeCustomPresets(custompreset)
    local upgraded = false
    local savefileupgrades = require "savefileupgrades"

    --[[
    if custompreset.version == nil or custompreset.version == 1 then
        savefileupgrades.utilities.UpgradeCustomPresetFromV1toV2(custompreset)
        upgraded = true
    end
    ]]

    return upgraded
end

CustomPresets = Class(function(self)
    self.presets = {
        [LEVELCATEGORY.SETTINGS] = {},
        [LEVELCATEGORY.WORLDGEN] = {},
    }

    self.presetIDs = {
        [LEVELCATEGORY.SETTINGS] = {},
        [LEVELCATEGORY.WORLDGEN] = {},
    }
end)

function CustomPresets:Load()
    self.presetIDs[LEVELCATEGORY.SETTINGS], self.presetIDs[LEVELCATEGORY.WORLDGEN] = TheSim:GetUserPresetFiles()

    global("Profile")
    if Profile then
        local profilepresets = Profile:GetWorldCustomizationPresets()
        if profilepresets ~= nil and not IsTableEmpty(profilepresets) then
            for i, level in pairs(profilepresets) do
                local basepreset = (level.location == "forest" and "SURVIVAL_TOGETHER") or (level.location == "cave" and "DST_CAVE") or (nil)
                if basepreset then
                    local id = "CUSTOM_"..(level.id):gsub("_", " ") --prepend CUSTOM_ because all custom presets start with that.
                    local defaultsettings = Customize.GetWorldSettingsOptionsWithLocationDefaults(level.location, level.location == "forest")
                    local settingsoverrides = {}
                    for _, v in ipairs(defaultsettings) do
                        settingsoverrides[v.name] = level.overrides[v.name] or v.default
                    end
                    self:SaveCustomPreset(LEVELCATEGORY.SETTINGS, id, basepreset, settingsoverrides, level.name, level.desc)

                    local defaultworldgen = Customize.GetWorldGenOptionsWithLocationDefaults(level.location, level.location == "forest")
                    local worldgenoverrides = {}
                    for _, v in ipairs(defaultworldgen) do
                        worldgenoverrides[v.name] = level.overrides[v.name] or v.default
                    end
                    self:SaveCustomPreset(LEVELCATEGORY.WORLDGEN, id, basepreset, worldgenoverrides, level.name, level.desc)
                end
            end
            Profile:SetValue("customizationpresets", nil)
            Profile.dirty = true
            Profile:Save()
        end
    end
end

local function GetPathString(category, presetid)
    return WORLD_PRESETS_FOLDER..string.upper(presetid)..EXTENSIONS[category]
end

function CustomPresets:LoadCustomPreset(category, presetid)
    assert(string.sub(presetid, 1, 7) == PRESET_PREFIX)

    if not table.contains(self.presetIDs[category], presetid) then
        --loading presets requires them to be in the presetIDs table.
        return
    end

    if self.presets[category][presetid] then
        return self.presets[category][presetid]
    end

    local presetdata
    TheSim:GetPersistentString(GetPathString(category, presetid), function(load_success, data)
		if load_success and data ~= nil then
            local success, custompreset = RunInSandbox(data)
            if success and custompreset then
                --[[
                custompreset = {
                    baseid = presetid --"The basegame/modded preset this is based off of."
                    overrides = overrides --all the overrides in the preset
                    name = name --the fancy name of the preset
                    desc = desc --the fancy description of the preset
                    version = version --the version of the custom preset.
                }
                --]]
                if custompreset.baseid == nil or custompreset.name == nil or custompreset.desc == nil or custompreset.overrides == nil then
                    return
                end

                local upgraded = UpgradeCustomPresets(custompreset)
                if upgraded then
                    TheSim:SetPersistentString(GetPathString(category, presetid), DataDumper(custompreset, nil, false))
                end

                presetdata = deepcopy(Levels.GetDataForID(category, custompreset.baseid))
                if presetdata == nil then
                    --if the preset is just missing, its probably a mod preset, so just do nothing.
                    return
                end

                presetdata:SetID(presetid)
                presetdata:SetBaseID(custompreset.baseid)
                presetdata:SetNameAndDesc(custompreset.name, custompreset.desc)
                presetdata.overrides = custompreset.overrides
            end
        end
    end)
    self.presets[category][presetid] = presetdata
    return presetdata
end

function CustomPresets:IsValidPreset(category, presetid)
    if category == LEVELCATEGORY.COMBINED then
        return self:IsValidPreset(LEVELCATEGORY.SETTINGS, presetid) or self:IsValidPreset(LEVELCATEGORY.WORLDGEN, presetid)
    end
    assert(string.sub(presetid, 1, 7) == PRESET_PREFIX)

    if not table.contains(self.presetIDs[category], presetid) then
        --loading presets requires them to be in the presetIDs table.
        return false
    end
    if self.presets[category][presetid] then
        return true
    end

    local ret = false
    TheSim:GetPersistentString(GetPathString(category, presetid), function(load_success, data)
		if load_success and data ~= nil then
            local success, custompreset = RunInSandbox(data)
            if success and custompreset then
                if custompreset.baseid == nil or custompreset.name == nil or custompreset.desc == nil or custompreset.overrides == nil then
                    return
                end
                ret = true
            end
        end
    end)
    return ret
end

function CustomPresets:SaveCustomPreset(category, presetid, basepreset, overrides, name, desc)
    assert(string.sub(presetid, 1, 7) == PRESET_PREFIX)

    assert(not self:IsCustomPreset(category, basepreset), "base preset cannot be a custom preset")

    if presetid == nil or basepreset == nil or overrides == nil or name == nil or desc == nil then
        return
    end
    local custompreset = {
        baseid = basepreset,
        overrides = overrides,
        name = name,
        desc = desc,
        version = 1,
    }
    local presetdata = deepcopy(Levels.GetDataForID(category, custompreset.baseid))
    if presetdata == nil then
        return
    end
    presetdata:SetID(presetid)
    presetdata:SetBaseID(custompreset.baseid)
    presetdata:SetNameAndDesc(custompreset.name, custompreset.desc)
    presetdata.overrides = custompreset.overrides

    self.presets[category][presetid] = presetdata
    if not table.contains(self.presetIDs[category], presetid) then
        table.insert(self.presetIDs[category], presetid)
        table.sort(self.presetIDs[category])
    end
    TheSim:SetPersistentString(GetPathString(category, presetid), DataDumper(custompreset, nil, false))
    return true
end

function CustomPresets:MoveCustomPreset(category, oldid, presetid, name, desc)
    assert(string.sub(oldid, 1, 7) == PRESET_PREFIX)
    assert(string.sub(presetid, 1, 7) == PRESET_PREFIX)

    local preset = self.presets[category][oldid]
    if preset == nil then
        return
    end

    if self:SaveCustomPreset(category, presetid, preset.baseid, preset.overrides, name, desc) then
        if oldid ~= presetid then self:DeleteCustomPreset(category, oldid) end
    end
    return self.presets[category][presetid]
end

function CustomPresets:DeleteCustomPreset(category, presetid)
    assert(string.sub(presetid, 1, 7) == PRESET_PREFIX)

    self.presets[category][presetid] = nil
    table.removearrayvalue(self.presetIDs[category], presetid)
    TheSim:ErasePersistentString(GetPathString(category, presetid))
end

function CustomPresets:PresetIDExists(category, presetid)
    if category == LEVELCATEGORY.COMBINED then
        return self:PresetIDExists(LEVELCATEGORY.SETTINGS, presetid) or self:PresetIDExists(LEVELCATEGORY.WORLDGEN, presetid)
    end
    return table.contains(self.presetIDs[category], presetid)
end

CustomPresets.IsCustomPreset = CustomPresets.PresetIDExists

function CustomPresets:GetPresetIDs(category)
    return self.presetIDs[category]
end