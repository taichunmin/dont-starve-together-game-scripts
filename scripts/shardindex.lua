local SHARDINDEX_VERSION = 5

ShardIndex = Class(function(self)
    self.ismaster = false
    self.slot = nil
    self.shard = nil
    self.version = SHARDINDEX_VERSION

    self.world = {options = {}}
    self.server = {}
    self.session_id = nil
    self.enabled_mods = {}
end)

function ShardIndex:GetShardIndexName()
    return "shardindex"
end

function ShardIndex:Save(callback)
    if not self.invalid and (self.isdirty or TheNet:GetIsServer()) then
        local data = DataDumper({
            world = self.world,
            server = self.server,
            session_id = self.session_id,
            enabled_mods = self.enabled_mods,
            version = self.version,
        }, nil, false)

        local filename = self:GetShardIndexName()
        if self.slot and self.shard then
            TheSim:SetPersistentStringInClusterSlot(self.slot, self.shard, filename, data, false, callback)
        else
            TheSim:SetPersistentString(filename, data, false, callback)
        end
        self.isdirty = false
        return
    end
    if callback then
        callback()
    end
end

function ShardIndex:WriteTimeFile(callback)
    local filename = self:GetShardIndexName().."_time"
    local function onreadtimefile(load_success, str)
        local date_created = os.time()
        if load_success == true then
            local success, data = RunInSandboxSafe(str)
            if success and string.len(str) > 0 then
                if type(data) == "table" then
                    date_created = data.created
                else
                    date_created = 0
                end
            end
        end
        local data = DataDumper({saved = os.time(), created = date_created}, nil, false)
        if self.slot and self.shard then
            TheSim:SetPersistentStringInClusterSlot(self.slot, self.shard, filename, data, false, callback)
        else
            TheSim:SetPersistentString(filename, data, false, callback)
        end
    end
    if self.slot and self.shard then
        TheSim:GetPersistentStringInClusterSlot(self.slot, self.shard, filename, onreadtimefile)
    else
        TheSim:GetPersistentString(filename, onreadtimefile)
    end
end

local function UpgradeShardIndexData(self)
    local savefileupgrades = require "savefileupgrades"
    local upgraded = false

    if self.version == nil or self.version == 1 then
        savefileupgrades.utilities.UpgradeShardIndexFromV1toV2(self)
        upgraded = true
    end

    if self.version == 2 then
        savefileupgrades.utilities.UpgradeShardIndexFromV2toV3(self)
        upgraded = true
    end

    if self.version == 3 then
        savefileupgrades.utilities.UpgradeShardIndexFromV3toV4(self)
        upgraded = true
    end

    if self.version == 4 then
        savefileupgrades.utilities.UpgradeShardIndexFromV4toV5(self)
        upgraded = true
    end

    return upgraded
end

local function OnLoad(self, slot, shard, callback, str)
    local success, savedata = RunInSandbox(str)

    -- If we are on steam cloud this will stop a corrupt saveindex file from
    -- ruining everyone's day..
    if success and string.len(str) > 0 and type(savedata) == "table" then
        self.slot = slot
        self.shard = shard
        self.ismaster = shard == "Master"
        self.valid = true
        self.isdirty = false

        self.world = savedata.world
        self.server = savedata.server
        self.session_id = savedata.session_id
        self.enabled_mods = savedata.enabled_mods
        self.version = savedata.version

        if self.world and self.world.options and self.world.options.overrides == nil then
            self.world.options.overrides = {}
        end

        local was_upgraded = false
        if self.version ~= SHARDINDEX_VERSION then
            was_upgraded = UpgradeShardIndexData(self)
        end

        local filename = self:GetShardIndexName()
        if was_upgraded then
            print("Saving upgraded "..filename)
            self:Save()
        end
    elseif TheNet:IsDedicated() then
        self.slot = slot
        self.shard = shard
        self.ismaster = false
        self.valid = true
        self.isdirty = true

        if SaveGameIndex and SaveGameIndex.loaded_from_file then
            local savefileupgrades = require "savefileupgrades"
            savefileupgrades.utilities.ConvertSaveSlotToShardIndex(SaveGameIndex, SaveGameIndex.current_slot, self)

            self:Save()
        else
            self.world = {options = {}}
            self.server = {}
            self.session_id = nil
            self.enabled_mods = {}
        end
    else
        self.ismaster = false
        self.slot = nil
        self.shard = nil
        self.valid = false
        self.isdirty = false

        self.world = {options = {}}
        self.server = {}
        self.session_id = nil
        self.enabled_mods = {}
    end

    if callback ~= nil then
        callback()
    end
end

function ShardIndex:Load(callback)
    --dedicated servers are never invalid
    --non servers are always invalid
    --client hosted servers must define the Settings.save_slot to be valid

    if TheNet:IsDedicated() then
        TheSim:GetPersistentString(self:GetShardIndexName(),
            function(load_success, str)
                --slot 0 isn't inside a Cluster_XX folder, instead its the (client_)save/ folder
                OnLoad(self, 0, nil, callback, str)
            end)
        return
    elseif TheNet:GetServerIsClientHosted() and Settings.save_slot then
        self:LoadShardInSlot(Settings.save_slot, "Master", callback)
        return
    end

    self.invalid = true
    if callback ~= nil then
        callback()
    end
end

function ShardIndex:LoadShardInSlot(slot, shard, callback)
    TheSim:GetPersistentStringInClusterSlot(slot, shard, self:GetShardIndexName(),
        function(load_success, str)
            OnLoad(self, slot, shard, callback, str)
        end)
end

local function OnLoadSaveDataFile(file, cb, load_success, str)
    if not load_success then
        if TheNet:GetIsClient() then
            assert(load_success, "ShardIndex:GetSaveData: Load failed for file ["..file.."] Please try joining again.")
        else
            assert(load_success, "ShardIndex:GetSaveData: Load failed for file ["..file.."] please consider deleting this save slot and trying again.")
        end
    end
    assert(str, "ShardIndex:GetSaveData: Encoded Savedata is NIL on load ["..file.."]")
    assert(#str > 0, "ShardIndex:GetSaveData: Encoded Savedata is empty on load ["..file.."]")

    print("Loading world: "..file)
    local success, savedata = RunInSandbox(str)

    assert(success, "Corrupt Save file ["..file.."]")
    assert(savedata, "ShardIndex:GetSaveData: Savedata is NIL on load ["..file.."]")
    assert(GetTableSize(savedata) > 0, "ShardIndex:GetSaveData: Savedata is empty on load ["..file.."]")

    cb(savedata)
end

function ShardIndex:GetSaveDataFile(file, cb)
    TheSim:GetPersistentString(file, function(load_success, str)
        OnLoadSaveDataFile(file, cb, load_success, str)
    end)
end

function ShardIndex:GetSaveData(cb)
    local session_id = self:GetSession()

    if not TheNet:IsDedicated() and not self:GetServerData().use_legacy_session_path then
        local slot = self:GetSlot()
        local file = TheNet:GetWorldSessionFileInClusterSlot(slot, "Master", session_id)
        if file ~= nil then
            TheSim:GetPersistentStringInClusterSlot(slot, "Master", file, function(load_success, str)
                OnLoadSaveDataFile(file, cb, load_success, str)
            end)
        elseif cb ~= nil then
            cb()
        end
    else
        local file = TheNet:GetWorldSessionFile(session_id)
        if file ~= nil then
            self:GetSaveDataFile(file, cb)
        elseif cb ~= nil then
            cb()
        end
    end
end

function ShardIndex:IsMasterShardIndex()
    return self.ismaster
end

function ShardIndex:GetSlot()
    return self.slot
end

function ShardIndex:GetShard()
    return self.shard
end

function ShardIndex:NewShardInSlot(slot, shard)
    self.slot = slot
    self.shard = shard
    self.ismaster = shard == "Master"
    self.valid = true
    self.isdirty = true

    self.world = {options = {}}
    self.server = {}
    self.session_id = nil
    self.enabled_mods = {}
end

local function ResetSlotData(self)
    self.world = {options = {}}
    self.server = {}
    self.session_id = nil
    self.enabled_mods = {}
end

function ShardIndex:Delete(cb, save_options)
    local server = self:GetServerData()
    local options = self:GetGenOptions()
    local enabled_mods = self:GetEnabledServerMods()

    local session_id = self:GetSession()
    if session_id ~= nil and session_id ~= "" then
        TheNet:DeleteSession(session_id)
    end

    ResetSlotData(self)

    if save_options then
        self.server = server
        self.world.options = options
        self.enabled_mods = enabled_mods
        self:Save(cb)
        return
    else
        self.invalid = true
    end

    if cb ~= nil then
        cb()
    end
end

--isshutdown means players have been cleaned up by OnDespawn()
--and the sim will shutdown after saving
function ShardIndex:SaveCurrent(onsavedcb, isshutdown)
    -- Only servers save games in DST
    if TheNet:GetIsClient() then
        return
    end

    known_assert(TheSim:HasEnoughFreeDiskSpace(), "CONFIG_DIR_DISK_SPACE")

    assert(TheWorld ~= nil, "missing world?")

    self.session_id = TheNet:GetSessionIdentifier()

    SaveGame(isshutdown, onsavedcb)
end

function ShardIndex:OnGenerateNewWorld(savedata, metadataStr, session_identifier, cb)
    local function onsavedatasaved()
        self.session_id = session_identifier
        self.server.encode_user_path = TheNet:TryDefaultEncodeUserPath()

        local function onsaved()
            ShardGameIndex:WriteTimeFile(cb)
        end
        self:Save(onsaved)
    end

    SerializeWorldSession(savedata, session_identifier, onsavedatasaved, metadataStr)
end

local function GetLevelDataOverride(slot, shard, cb)
    local filename = "../leveldataoverride.lua"

    local function onload(load_success, str)
        if load_success == true then
            local success, savedata = RunInSandboxSafe(str)
            if success and string.len(str) > 0 then
                print("Found a level data override file with these contents:")
                dumptable(savedata)
                if savedata ~= nil then
                    print("Loaded and applied level data override from "..filename)
                    assert(savedata.id ~= nil
                        and savedata.name ~= nil
                        and savedata.desc ~= nil
                        and savedata.location ~= nil
                        and savedata.overrides ~= nil, "Level data override is invalid!")

                    cb(savedata)
                    return
                end
            else
                print("ERROR: Failed to load "..filename)
            end
        end
        print("Not applying level data overrides.")
        cb(nil, nil)
    end

    if shard ~= nil then
        TheSim:GetPersistentStringInClusterSlot(slot, shard, filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end
end

local function SanityCheckWorldGenOverride(wgo)
    print("  sanity-checking worldgenoverride.lua...")
    local validfields = {
        overrides = true,
        preset = true,
        settings_preset = true,
        worldgen_preset = true,
        override_enabled = true,
    }
    for k,v in pairs(wgo) do
        if validfields[k] == nil then
            print(string.format("    WARNING! Found entry '%s' in worldgenoverride.lua, but this isn't a valid entry.", k))
        end
    end

    local optionlookup = {}
    local Customize = require("map/customize")
    for i,option in ipairs(Customize.GetOptions(nil, true)) do
        optionlookup[option.name] = {}
        for i, value in ipairs(option.options) do
            table.insert(optionlookup[option.name], value.data)
        end
    end

    --depreciated values(don't warn in the log files)
    optionlookup.disease_delay = true

    if wgo.overrides ~= nil then
        for k,v in pairs(wgo.overrides) do
            if optionlookup[k] == nil then
                print(string.format("    WARNING! Found override '%s', but this doesn't match any known option. Did you make a typo?", k))
            elseif optionlookup[k] ~= true then
                if not table.contains(optionlookup[k], v) then
                    print(string.format("    WARNING! Found value '%s' for setting '%s', but this is not a valid value. Use one of {%s}.", v, k, table.concat(optionlookup[k], ", ")))
                end
            end
        end
    end
end

local function GetWorldgenOverride(slot, shard, cb)
    local filename = "../worldgenoverride.lua"

    local function onload(load_success, str)
        if load_success == true then
            local success, savedata = RunInSandboxSafe(str)
            if success and string.len(str) > 0 then
                print("Found a worldgen override file with these contents:")
                dumptable(savedata)
                if savedata ~= nil then

                    local savefileupgrades = require("savefileupgrades")
                    savedata = savefileupgrades.utilities.UpgradeWorldgenoverrideFromV1toV2(savedata)

                    SanityCheckWorldGenOverride(savedata)

                    if savedata.override_enabled then
                        print("Loaded and applied world gen overrides from "..filename)

                        local presetdata = {overrides = {}}
                        local fromworldgenpreset = false
                        local fromsettingspreset = false

                        local worldgen_preset = savedata.worldgen_preset or savedata.preset
                        local worldgen_presetdata = nil

                        local settings_preset = savedata.settings_preset or savedata.preset
                        local settings_presetdata = nil

                        savedata.preset = nil
                        savedata.worldgen_preset = nil
                        savedata.settings_preset = nil
                        savedata.override_enabled = nil

                        if worldgen_preset then
                            print("  contained worldgen preset "..worldgen_preset..", loading...")
                            local Levels = require("map/levels")
                            worldgen_presetdata = Levels.GetDataForWorldGenID(worldgen_preset)

                            if worldgen_presetdata then
                                presetdata = MergeMapsDeep(presetdata, worldgen_presetdata)
                                fromworldgenpreset = true
                            else
                                print("Worldgenoverride specified a nonexistent worldgen preset: "..worldgen_preset..". If this is a custom worldgen preset, it may not exist in this save location. Ignoring it and applying overrides.")
                            end
                        end

                        if settings_preset then
                            print("  contained settings preset "..settings_preset..", loading...")
                            local Levels = require("map/levels")
                            settings_presetdata  = Levels.GetDataForSettingsID(settings_preset)

                            if settings_presetdata then
                                presetdata = MergeMapsDeep(presetdata, settings_presetdata)
                                fromsettingspreset = true
                            else
                                print("Worldgenoverride specified a nonexistent settings preset: "..settings_preset..". If this is a custom settings preset, it may not exist in this save location. Ignoring it and applying overrides.")
                            end
                        end

                        if savedata.overrides then
                            presetdata.overrides = MergeMapsDeep(presetdata.overrides, savedata.overrides)
                        end

                        cb(presetdata, not (fromworldgenpreset and fromsettingspreset))
                        return
                    else
                        print("Found world gen overrides but not enabled.")
                    end
                end
            else
                print("ERROR: Failed to load "..filename)
            end
        end
        print("Not applying world gen overrides.")
        cb(nil, nil)
    end

    if shard ~= nil then
        TheSim:GetPersistentStringInClusterSlot(slot, shard, filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end
end

local function GetDefaultWorldOptions(level_type)
    local Levels = require "map/levels"
    return Levels.GetDefaultLevelData(level_type, nil)
end

function ShardIndex:SetServerShardData(customoptions, serverdata, onsavedcb)
    local session_identifier = TheNet:GetSessionIdentifier()
    self.session_id = session_identifier ~= "" and session_identifier or self.session_id
    self.server = serverdata
    self.enabled_mods = KnownModIndex:LoadModOverides(self)

    self:MarkDirty()
    -- gjans:
    -- leveldataoverride is for GAME USE. It contains a _complete level definition_ and is used by the clusters to transfer level settings reliably from the client to the cluster servers. It completely overrides existing saved world data.
    -- worldgenoverride is for USER USE. It contains optionally:
    --   a) a preset name. If present, this preset will be loaded and completely override existing save data, including the above. (Note, this is not reliable between client and cluster, but users can do this if they please.)
    --   b) a partial list of overrides that are layered on top of whatever savedata we have at this point now.
    local slot = self:GetSlot()
    local shard = self:GetShard()
    GetLevelDataOverride(slot, shard, function(leveldata)
        if leveldata ~= nil then
            print("Overwriting savedata with level data file.")
            self.world.options = leveldata
        else
            local defaultoptions = GetDefaultWorldOptions(GetLevelType(serverdata.game_mode or DEFAULT_GAME_MODE))
            self.world.options = (customoptions ~= nil and not IsTableEmpty(customoptions) and customoptions) or defaultoptions
            assert(self.world.options, "no world options defined")
            if self.world.options.overrides == nil or IsTableEmpty(self.world.options.overrides) then
                self.world.options.overrides = defaultoptions.overrides
            end
        end

        GetWorldgenOverride(slot, shard, function(overridedata, partial)
            if overridedata ~= nil then
                if not partial then
                    print("Overwriting savedata with override file.")
                    self.world.options = overridedata
                else
                    print("Merging override file into savedata.")
                    self.world.options = MergeMapsDeep(self.world.options, overridedata)
                end
            end

			if not TheNet:GetServerIsClientHosted() then
				if self.server.game_mode == "wilderness" then
					-- crazy retrofitting code for a new server that still happen to be using game_mode set to wilderness or endless in the cluster.ini 
					require("savefileupgrades").utilities.ApplyPlaystyleOverridesForGameMode(self.world.options, self.server.game_mode)
					self.world.options = MergeMapsDeep(self.world.options, overridedata) -- still allow the override data to stop the default game_mode values
	                self.server.game_mode = "survival"
					TheNet:SetDefaultGameMode("survival")
				elseif self.server.game_mode == "endless" then
					-- crazy retrofitting code for a new server that still happen to be using game_mode set to wilderness or endless in the cluster.ini 
					require("savefileupgrades").utilities.ApplyPlaystyleOverridesForGameMode(self.world.options, self.server.game_mode)
					self.world.options = MergeMapsDeep(self.world.options, overridedata) -- still allow the override data to stop the default game_mode values
	                self.server.game_mode = "survival"
					TheNet:SetDefaultGameMode("survival")
				end
			end

			local Levels = require("map/levels")
			self.server.playstyle = Levels.CalcPlaystyleForSettings(self.world.options.overrides)

            self:Save(onsavedcb)
        end)
    end)
end

function ShardIndex:CheckWorldFile()
    local session_id = self:GetSession()
    return session_id ~= nil and TheNet:GetWorldSessionFile(session_id) ~= nil
end

function ShardIndex:MarkDirty()
    self.isdirty = true
end

function ShardIndex:IsValid()
    return self.valid
end

function ShardIndex:IsEmpty()
    return self.session_id == nil or self.session_id == ""
end

function ShardIndex:GetServerData()
    return self.server or {}
end

function ShardIndex:GetGenOptions()
    return self.world.options
end

function ShardIndex:GetSession()
    return self.session_id
end

function ShardIndex:GetGameMode()
    return self.server.game_mode or DEFAULT_GAME_MODE
end

function ShardIndex:GetEnabledServerMods()
    return self.ismaster and self.enabled_mods or {}
end

function ShardIndex:LoadEnabledServerMods()
    if not self.ismaster then return end

    ModManager:DisableAllServerMods()
    for modname, mod_data in pairs(self.enabled_mods) do
        if mod_data.enabled then
            KnownModIndex:Enable(modname)
        end

        local config_options = mod_data.config_data or mod_data.configuration_options or {} --config_data is the legacy format
        for option_name,value in pairs(config_options) do
            KnownModIndex:SetConfigurationOption(modname, option_name, value)
        end
        KnownModIndex:SaveHostConfiguration(modname)
    end
end

--Used in FE only, used so that we can save changes made to the server creation screen without having to save the world
function ShardIndex:SetEnabledServerMods(enabled_mods)
    if not self.ismaster then return end
    self.enabled_mods = enabled_mods
    self:MarkDirty()
end

function ShardIndex:SetServerData(serverdata)
    if not self.ismaster then return end
    self.server = serverdata
    self:MarkDirty()
end

function ShardIndex:SetGenOptions(options)
    if not self.ismaster then return end
    self.world.options = options
    self:MarkDirty()
end
