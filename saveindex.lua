local SAVEDATA_VERSION = 4

local Levels = require"map/levels"

SaveIndex = Class(function(self)
    self:Init()
end)

function SaveIndex:Init()
    self.data = {
        version = SAVEDATA_VERSION,
        slots = {}
    }
    self:GuaranteeMinNumSlots(NUM_SAVE_SLOTS)
    self.current_slot = 1
end

local function NewSlotData()
    return
    {
        world = {},
        server = {},
        session_id = nil,
        enabled_mods = {},
    }
end

local function ResetSlotData(data)
    data.world = {}
    data.server = {}
    data.session_id = nil
    data.enabled_mods = {}
end

local function GetLevelDataOverride(slotnum, force_shard_path, cb)
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

    if force_shard_path ~= nil then
        TheSim:GetPersistentStringInClusterSlot(slotnum, force_shard_path, filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end
end

local function SanityCheckWorldGenOverride(wgo)
    print("  sanity-checking worldgenoverride.lua...")
    local validfields = {
        overrides = true,
        preset = true,
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
        for i,value in ipairs(option.options) do
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

local function GetWorldgenOverride(slotnum, force_shard_path, cb)
    local filename = "../worldgenoverride.lua"

    local function onload(load_success, str)
        if load_success == true then
            local success, savedata = RunInSandboxSafe(str)
            if success and string.len(str) > 0 then
                print("Found a worldgen override file with these contents:")
                dumptable(savedata)

                if savedata ~= nil then

                    -- gjans: Added upgrade path 28/03/2016. Because this is softer and user editable, will probably have to leave this one in longer than the other upgrades from this same change set.
                    local savefileupgrades = require("savefileupgrades")
                    savedata = savefileupgrades.utilities.UpgradeWorldgenoverrideFromV1toV2(savedata)

                    SanityCheckWorldGenOverride(savedata)

                    if savedata.override_enabled then
                        print("Loaded and applied world gen overrides from "..filename)
                        savedata.override_enabled = nil -- Only part of worldgenoverride, not standard level definition.

                        local presetdata = nil
                        local frompreset = false
                        if savedata.preset ~= nil then
                            print("  contained preset "..savedata.preset..", loading...")
                            local Levels = require("map/levels")
                            presetdata = Levels.GetDataForLevelID(savedata.preset)
                            if presetdata ~= nil then
                                if GetTableSize(savedata) > 0 then
                                    print("  applying overrides to preset...")
                                    presetdata = MergeMapsDeep(presetdata, savedata)
                                end
                                frompreset = true
                            else
                                print("Worldgenoverride specified a nonexistent preset: "..savedata.preset..". If this is a custom preset, it may not exist in this save location. Ignoring it and applying overrides.")
                                presetdata = savedata
                            end
                            savedata.preset = nil -- Only part of worldgenoverride, not standard level definition.
                        else
                            presetdata = savedata
                        end

                        presetdata.override_enabled = nil
                        presetdata.preset = nil

                        cb( presetdata, frompreset )
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

    if force_shard_path ~= nil then
        TheSim:GetPersistentStringInClusterSlot(slotnum, force_shard_path, filename, onload)
    else
        TheSim:GetPersistentString(filename, onload)
    end
end

function SaveIndex:GuaranteeMinNumSlots(numslots)
    for i = #self.data.slots + 1, numslots do
        table.insert(self.data.slots, NewSlotData())
    end
end

function SaveIndex:GetNumSlots()
    return #self.data.slots
end

function SaveIndex:GetSaveIndexName()
    return "saveindex"..(BRANCH == "dev" and ("_"..BRANCH) or "")
end

function SaveIndex:Save(callback)
    --09/09/2020 SaveIndex is depreciated, and will no longer save.
    --local data = DataDumper(self.data, nil, false)
    --local insz, outsz = TheSim:SetPersistentString(self:GetSaveIndexName(), data, false, callback)
    if callback then
        callback()
    end
end

-- gjans: Added this upgrade path 28/03/2016
local function UpgradeSavedLevelData(worldoptions)
    local savefileupgrades = require "savefileupgrades"
    local ret = {}
	local upgraded = false
    for i,level in ipairs(worldoptions) do
        ret[i] = deepcopy(level)

        if level.version == nil or level.version == 1 then
            ret[i] = savefileupgrades.utilities.UpgradeSavedLevelFromV1toV2(ret[i], i == 1)
			upgraded = true
        end

        if level.version == 2 then
            ret[i] = savefileupgrades.utilities.UpgradeSavedLevelFromV2toV3(ret[i], i == 1)
			upgraded = true
        end

        if level.version == 3 then
            ret[i] = savefileupgrades.utilities.UpgradeSavedLevelFromV3toV4(ret[i], i == 1) -- RoT: Turn of Tids
			upgraded = true
        end

    end
    return ret, upgraded
end

local function OnLoad(self, filename, callback, load_success, str)
    local success, savedata = RunInSandbox(str)

    -- If we are on steam cloud this will stop a corrupt saveindex file from
    -- ruining everyone's day..
    if success and
        string.len(str) > 0 and
        savedata ~= nil and
        savedata.slots ~= nil and
        type(savedata.slots) == "table" then

        self:GuaranteeMinNumSlots(#savedata.slots)
        self.data.last_used_slot = savedata.last_used_slot
		local was_upgraded = false
        for i, v in ipairs(self.data.slots) do
            ResetSlotData(v)
            local v2 = savedata.slots[i]
            if v2 ~= nil then
                v.world = v2.world or v.world
                if v.world == nil then
                    print("OnLoad slot",i,": World was nil!")
                    v.world = {}
                end
                if v.world.options == nil then
                    print("OnLoad slot",i,": World options was nil! Populating with default.")
                    v.world.options = {}
                    v.world.options[1] = Levels.GetDefaultLevelData(LEVELTYPE.SURVIVAL)
                elseif next(v.world.options) == nil then
                    print("OnLoad slot",i,": World options was empty! Populating with default")
                    v.world.options[1] = Levels.GetDefaultLevelData(LEVELTYPE.SURVIVAL)
                else
                    v.world.options, was_upgraded = UpgradeSavedLevelData(v.world.options)
                end
                v.server = v2.server or v.server
                v.session_id = v2.session_id or v.session_id
                v.enabled_mods = v2.enabled_mods or v.enabled_mods
            end
        end

        if filename ~= nil then
            print("loaded "..filename)

			if was_upgraded then
				print("Saving upgraded "..filename)
				self:Save()
			end
        end
        self.loaded_from_file = true --for use with saveindex to shardsaveindex migration.
    elseif filename ~= nil then
        --print("Could not load "..filename)
    end

    if callback ~= nil then
        callback()
    end
end

function SaveIndex:Load(callback)
    --This happens on game start.
    local filename = self:GetSaveIndexName()
    TheSim:GetPersistentString(filename,
        function(load_success, str)
            OnLoad(self, filename, callback, load_success, str)
        end)
end

function SaveIndex:LoadClusterSlot(slot, shard, callback)
    --This happens in FE when we need data from cluster slots
    --Don't pass filename to OnLoad, so we don't print errors
    --for attempting to load empty slots
    TheSim:GetPersistentStringInClusterSlot(slot, shard, self:GetSaveIndexName(),
        function(load_success, str)
            OnLoad(self, nil, callback, load_success, str)
        end)
end

local function OnLoadSaveDataFile(file, cb, load_success, str)
    if not load_success then
        if TheNet:GetIsClient() then
            assert(load_success, "SaveIndex:GetSaveData: Load failed for file ["..file.."] Please try joining again.")
        else
            assert(load_success, "SaveIndex:GetSaveData: Load failed for file ["..file.."] please consider deleting this save slot and trying again.")
        end
    end
    assert(str, "SaveIndex:GetSaveData: Encoded Savedata is NIL on load ["..file.."]")
    assert(#str > 0, "SaveIndex:GetSaveData: Encoded Savedata is empty on load ["..file.."]")

    print("Loading world: "..file)
    local success, savedata = RunInSandbox(str)

    assert(success, "Corrupt Save file ["..file.."]")
    assert(savedata, "SaveIndex:GetSaveData: Savedata is NIL on load ["..file.."]")
    assert(GetTableSize(savedata) > 0, "SaveIndex:GetSaveData: Savedata is empty on load ["..file.."]")

    cb(savedata)
end

function SaveIndex:GetSaveDataFile(file, cb)
    TheSim:GetPersistentString(file, function(load_success, str)
        OnLoadSaveDataFile(file, cb, load_success, str)
    end)
end

function SaveIndex:GetSaveData(slotnum, cb)
    self.current_slot = slotnum
    if not TheNet:IsDedicated() and SaveGameIndex:GetSlotServerData(slotnum).use_cluster_path then
        local file = TheNet:GetWorldSessionFileInClusterSlot(slotnum, "Master", self.data.slots[slotnum].session_id)
        if file ~= nil then
            TheSim:GetPersistentStringInClusterSlot(slotnum, "Master", file, function(load_success, str)
                OnLoadSaveDataFile(file, cb, load_success, str)
            end)
        elseif cb ~= nil then
            cb()
        end
    else
        local file = TheNet:GetWorldSessionFile(self.data.slots[slotnum].session_id)
        if file ~= nil then
            self:GetSaveDataFile(file, cb)
        elseif cb ~= nil then
            cb()
        end
    end
end

function SaveIndex:DeleteSlot(slot, cb, save_options)
    local slotdata = slot ~= nil and self.data.slots[slot] or nil
    if slotdata ~= nil then
        local server = slotdata.server
        local options = slotdata.world.options
        local session_id = self:GetSlotSession(slot)
        local enabled_mods = slotdata.enabled_mods

        --DST session file stuff
        if session_id ~= nil and session_id ~= "" then
            TheNet:DeleteSession(session_id)
        end

        if not TheNet:IsDedicated() then
            TheNet:DeleteCluster(slot)
        end

        ResetSlotData(slotdata)

        if save_options then
            slotdata.server = server
            slotdata.world.options = options
            slotdata.enabled_mods = enabled_mods
        end

        self:Save(cb)
    elseif cb ~= nil then
        cb()
    end
end

--isshutdown means players have been cleaned up by OnDespawn()
--and the sim will shutdown after saving
function SaveIndex:SaveCurrent(onsavedcb, isshutdown)
    -- Only servers save games in DST
    if TheNet:GetIsClient() then
        return
    end

    assert(TheWorld ~= nil, "missing world?")

    local slotdata = self.data.slots[self.current_slot]
    slotdata.session_id = TheNet:GetSessionIdentifier()

    SaveGame(isshutdown, onsavedcb)
end

function SaveIndex:SetCurrentIndex(saveslot)
    self.current_slot = saveslot
end

function SaveIndex:GetCurrentSaveSlot()
    return self.current_slot
end

--called upon relaunch when a new level needs to be loaded
function SaveIndex:OnGenerateNewWorld(saveslot, savedata, session_identifier, cb)
    self.current_slot = saveslot

    local function onsavedatasaved()
        local slotdata = self.data.slots[self.current_slot]
        slotdata.session_id = session_identifier

        if slotdata.server ~= nil then
            slotdata.server.encode_user_path = TheNet:TryDefaultEncodeUserPath()
        end

        self:Save(cb)
    end

    SerializeWorldSession(savedata, session_identifier, onsavedatasaved)
end

function SaveIndex:UpdateServerData(saveslot, serverdata, onsavedcb)
    self.current_slot = saveslot

    local slotdata = self.data.slots[saveslot]
    if slotdata ~= nil and serverdata ~= nil then
        slotdata.server = deepcopy(serverdata)
    end

    self.data.last_used_slot = saveslot

    self:Save(onsavedcb)
end

function SaveIndex:GetGameMode(saveslot)
    local game_mode = self.data.slots[saveslot].server.game_mode or DEFAULT_GAME_MODE
    return game_mode
end

local function GetDefaultWorldOptions(level_type)
    local Levels = require "map/levels"
    return { Levels.GetDefaultLevelData(level_type, nil) }
end

--call after you have worldgen data to initialize a new survival save slot
function SaveIndex:StartSurvivalMode(saveslot, customoptions, serverdata, onsavedcb)
    self.current_slot = saveslot

    local slot = self.data.slots[saveslot]
    slot.session_id = TheNet:GetSessionIdentifier()

    slot.world.options = customoptions or GetDefaultWorldOptions(GetLevelType(serverdata.game_mode or DEFAULT_GAME_MODE))
    slot.server = {}

    --NOTE: Always overrides layer 1, as that's what worldgen will generate
    if slot.world.options[1] == nil then
        slot.world.options[1] = {}
    end

    local force_shard_path = serverdata ~= nil and serverdata.use_cluster_path and not TheNet:IsDedicated() and "Master" or nil

    -- gjans:
    -- leveldataoverride is for GAME USE. It contains a _complete level definition_ and is used by the clusters to transfer level settings reliably from the client to the cluster servers. It completely overrides existing saved world data.
    -- worldgenoverride is for USER USE. It contains optionally:
    --   a) a preset name. If present, this preset will be loaded and completely override existing save data, including the above. (Note, this is not reliable between client and cluster, but users can do this if they please.)
    --   b) a partial list of overrides that are layered on top of whatever savedata we have at this point now.
    GetLevelDataOverride(saveslot, force_shard_path, function(leveldata)
        if leveldata ~= nil then
            print("Overwriting savedata with level data file.")
            slot.world.options[1] = leveldata
        end

        GetWorldgenOverride(saveslot, force_shard_path, function(overridedata, frompreset)
            if overridedata ~= nil then
                if frompreset == true then
                    print("Overwriting savedata with override file.")
                    slot.world.options[1] = overridedata
                else
                    print("Merging override file into savedata.")
                    slot.world.options[1] = MergeMapsDeep(slot.world.options[1], overridedata)
                end
            end

            self:UpdateServerData(saveslot, serverdata, onsavedcb)
        end)
    end)
end

function SaveIndex:IsSlotEmpty(slot)
    return slot == nil or self.data.slots[slot] == nil or self.data.slots[slot].session_id == nil
end

function SaveIndex:IsSlotMultiLevel(slot)
    if TheNet:IsDedicated() then
        return false
    end
    local slotdata = self.data.slots[slot]
    return slotdata ~= nil and slotdata.session_id == "" and slotdata.world ~= nil and slotdata.world.options ~= nil and slotdata.world.options[1] ~= nil and slotdata.world.options[2] ~= nil
end

function SaveIndex:GetLastUsedSlot()
    return self.data.last_used_slot or -1
end

function SaveIndex:SetLastUsedSlot(slot)
    self.data.last_used_slot = slot
end

function SaveIndex:GetSlotServerData(slot)
    return slot ~= nil and self.data.slots[slot] ~= nil and self.data.slots[slot].server or {}
end

function SaveIndex:GetSlotGenOptions(slot)
    return deepcopy(self.data.slots[slot or self.current_slot].world.options)
end

function SaveIndex:GetSlotSession(slot, caves_session)
    if self:IsSlotMultiLevel(slot or self.current_slot) then
        local session_id = nil
        local clusterSaveIndex = SaveIndex()
		local shard_name = caves_session == true and "Caves" or "Master"
        clusterSaveIndex:LoadClusterSlot(slot or self.current_slot, shard_name, function()
            session_id = clusterSaveIndex.data.slots[clusterSaveIndex.current_slot].session_id
        end)
        return session_id
    end
    return self.data.slots[slot or self.current_slot].session_id
end

function SaveIndex:BuildSlotDayAndSeasonText(slotnum)
	local slot_day_and_season_str = ""

    if SaveGameIndex:IsSlotEmpty(slotnum) then
        slot_day_and_season_str = STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_NEW
    else
        local session_id = SaveGameIndex:GetSlotSession(slotnum)
        if session_id ~= nil then
            local day = 1
            local season = nil
            local function onreadworldfile(success, str)
                if success and str ~= nil and #str > 0 then
                    local success, savedata = RunInSandbox(str)
                    if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                        local worlddata = savedata.world_network ~= nil and savedata.world_network.persistdata or nil
                        if worlddata ~= nil then
                            if worlddata.clock ~= nil then
                                day = (worlddata.clock.cycles or 0) + 1
                            end

                            if worlddata.seasons ~= nil and worlddata.seasons.season ~= nil then
                                season = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(worlddata.seasons.season)]
                                if season ~= nil and
                                    worlddata.seasons.elapseddaysinseason ~= nil and
                                    worlddata.seasons.remainingdaysinseason ~= nil then
                                    if worlddata.seasons.remainingdaysinseason * 3 <= worlddata.seasons.elapseddaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
                                    elseif worlddata.seasons.elapseddaysinseason * 3 <= worlddata.seasons.remainingdaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if SaveGameIndex:IsSlotMultiLevel(slotnum) or SaveGameIndex:GetSlotServerData(slotnum).use_cluster_path then
                local file = TheNet:GetWorldSessionFileInClusterSlot(slotnum, "Master", session_id)
                if file ~= nil then
                    if USE_SESSION_METADATA then
                        file = file..".meta"
                    end
                    TheSim:GetPersistentStringInClusterSlot(slotnum, "Master", file, onreadworldfile)
                end
            else
                local file = TheNet:GetWorldSessionFile(session_id)
                if file ~= nil then
                    if USE_SESSION_METADATA then
                        file = file..".meta"
                    end
                    TheSim:GetPersistentString(file, onreadworldfile)
                end
            end
            slot_day_and_season_str = (season ~= nil and (season.." ") or "")..STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY.." "..day
        else
            slot_day_and_season_str = STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_NEW
        end
    end

    return slot_day_and_season_str
end

function SaveIndex:CheckWorldFile(slot)
    local session_id = self:GetSlotSession(slot)
    return session_id ~= nil and TheNet:GetWorldSessionFile(session_id) ~= nil
end

--V2C: This is no longer cheap because it's not cached, but supports
--     dynamically switching user accounts locally, mmm'kay
function SaveIndex:LoadSlotCharacter(slot)
    local character = nil

    local function onreadusersession(success, str)
        if success and str ~= nil and #str > 0 then
            local success, savedata = RunInSandbox(str)
            if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                character = savedata.prefab
            end
        end
    end

    local slotdata = self.data.slots[slot or self.current_slot]
    if slotdata.session_id ~= nil then
        local online_mode = slotdata.server.online_mode ~= false
        if self:IsSlotMultiLevel(slot or self.current_slot) then
            local clusterSaveIndex = SaveIndex()
            clusterSaveIndex:LoadClusterSlot(slot, "Master", function()
                local slotdata = clusterSaveIndex.data.slots[clusterSaveIndex.current_slot]
                if slotdata.session_id ~= nil then
                    local encode_user_path = slotdata.server.encode_user_path == true
                    local shard, snapshot = TheNet:GetPlayerSaveLocationInClusterSlot(slot, slotdata.session_id, online_mode, encode_user_path)
                    if shard ~= nil and snapshot ~= nil then
                        if shard ~= "Master" then
                            clusterSaveIndex = SaveIndex()
                            clusterSaveIndex:LoadClusterSlot(slot, shard, function()
                                slotdata = clusterSaveIndex.data.slots[clusterSaveIndex.current_slot]
                                encode_user_path = slotdata.server.encode_user_path == true
                            end)
                        end
                        if slotdata.session_id ~= nil then
                            local file = TheNet:GetUserSessionFileInClusterSlot(slot, shard, slotdata.session_id, snapshot, online_mode, encode_user_path)
                            if file ~= nil then
                                TheNet:DeserializeUserSessionInClusterSlot(slot, shard, file, onreadusersession)
                            end
                        end
                    end
                end
            end)
        else
            local encode_user_path = slotdata.server.encode_user_path == true
            if slotdata.server.use_cluster_path then
                local file = TheNet:GetUserSessionFileInClusterSlot(slot, "Master", slotdata.session_id, nil, online_mode, encode_user_path)
                if file ~= nil then
                    TheNet:DeserializeUserSessionInClusterSlot(slot, "Master", file, onreadusersession)
                end
            else
                local file = TheNet:GetUserSessionFile(slotdata.session_id, nil, online_mode, encode_user_path)
                if file ~= nil then
                    TheNet:DeserializeUserSession(file, onreadusersession)
                end
            end
        end
    end
    return character
end

function SaveIndex:LoadServerEnabledModsFromSlot(slot)
    local enabled_mods = self.data.slots[slot or self.current_slot].enabled_mods
    ModManager:DisableAllServerMods()
    for modname,mod_data in pairs(enabled_mods) do
        if mod_data.enabled then
            KnownModIndex:Enable(modname)
        end

        local config_options = mod_data.config_data or mod_data.configuration_options or {} --config_data is the legacy format
        for option_name,value in pairs(config_options) do
            KnownModIndex:SetConfigurationOption( modname, option_name, value )
        end
        KnownModIndex:SaveHostConfiguration(modname)
    end
end

function SaveIndex:SetServerEnabledMods(slot)
    --Save enabled server mods to the save index
    local server_enabled_mods = ModManager:GetEnabledServerModNames()

    local enabled_mods = {}
    for _,modname in pairs(server_enabled_mods) do
        local mod_data = { enabled = true } --Note(Peter): The format of mod_data now must match the format expected in modoverrides.lua. See ModIndex:ApplyEnabledOverrides
        mod_data.configuration_options = {}
        local force_local_options = true
        local config = KnownModIndex:LoadModConfigurationOptions(modname, false)
        if config and type(config) == "table" then
            for i,v in pairs(config) do
                if v.saved ~= nil then
                    mod_data.configuration_options[v.name] = v.saved
                else
                    mod_data.configuration_options[v.name] = v.default
                end
            end
        end
        enabled_mods[modname] = mod_data
    end
    self.data.slots[slot or self.current_slot].enabled_mods = enabled_mods
end

function SaveIndex:GetEnabledMods(slot)
    return self.data.slots[slot or self.current_slot].enabled_mods
end
