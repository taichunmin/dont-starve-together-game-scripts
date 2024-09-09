local SHARDSAVEINDEX_VERSION = 1

local SHARD_NAMES = {
    "Master",
    "Caves",
}

ShardSaveIndex = Class(function(self)
    self.version = SHARDSAVEINDEX_VERSION
    self.slot_cache = {}
    self.slots = {}
end)

function ShardSaveIndex:GetShardSaveIndexName()
    return "shardsaveindex"
end

--potential optimization:
--make self.slot_cache[slot][shard] have weak values, and have a seperate table contain the hard references,
--the second table circularly loops through X(say 50) caches, deleting the oldest cached entries and replacing them with newer ones.
function ShardSaveIndex:GetShardIndex(slot, shard, create_if_missing)
    if not self.slot_cache[slot] or not self.slot_cache[slot][shard] then
        self.slot_cache[slot] = self.slot_cache[slot] or {}
        local shardIndex = ShardIndex()
        shardIndex:LoadShardInSlot(slot, shard)
        if create_if_missing and not shardIndex:IsValid() then
            shardIndex:NewShardInSlot(slot, shard)
        end
        if shardIndex:IsValid() then
            self.slot_cache[slot][shard] = shardIndex
        end
    end
    return self.slot_cache[slot] and self.slot_cache[slot][shard] or nil
end

function ShardSaveIndex:Save(callback)
    if not self.invalid then
        for _, slot in pairs(self.slot_cache) do
            for _, shard_name in ipairs(SHARD_NAMES) do
                if slot[shard_name] then
                    slot[shard_name]:Save()
                end
            end
        end
        local data = DataDumper({
            version = self.version,
            failed_slot_conversions = self.failed_slot_conversions,
        }, nil, false)
        TheSim:SetPersistentString(self:GetShardSaveIndexName(), data, false, callback)
    end
end

local function UpgradeShardSaveIndexData(savedata)
    local savefileupgrades = require "savefileupgrades"
    local upgraded = false

    --[[
    if savedata.version == nil or savedata.version == 1 then
        savefileupgrades.utilities.UpgradeShardSaveIndexFromV1toV2(savedata)
        upgraded = true
    end
    --]]
    return upgraded
end

local function RetryFailedSlotConversion(self, slot)
    local savefileupgrades = require "savefileupgrades"
    if TheSim:EnsureShardIndexPathExists(slot) then
        local masterShardIndex = self:GetShardIndex(slot, "Master", true)
        savefileupgrades.utilities.ConvertSaveSlotToShardIndex(SaveGameIndex, slot, masterShardIndex)
        self.failed_slot_conversions[slot] = nil
        self.slots[slot] = false
    else
        print("Failed to migrate slot "..tostring(slot).." from saveindex to shardindex")
    end
end

local function RetryLegacyPathConversion(self, slot)
    if not self:IsSlotMultiLevel(slot) then
        local serverdata = self:GetSlotServerData(slot)
        if serverdata.use_legacy_session_path then
            local session = self:GetSlotSession(slot, "Master")
            if session and TheSim:CopyLegacySessionToSlot(slot, session) then
                serverdata.use_legacy_session_path = nil
                self:GetShardIndex(slot, "Master"):MarkDirty()
            else
                print("Failed to migrate legacy session data for slot "..tostring(slot))
            end
        end
    end
end

local function RetryFailedSaveConversions(self)
    if self.failed_slot_conversions and SaveGameIndex.loaded_from_file then
        for slot in pairs(self.failed_slot_conversions) do
            RetryFailedSlotConversion(self, slot)
        end
    end

    for slot in pairs(self.slots) do
        RetryLegacyPathConversion(self, slot)
    end
    self:Save()
end

function ShardSaveIndex:ForceRetrySlotConversion(slot, skiplegacyconversion)
    RetryFailedSlotConversion(self, slot)
    if not skiplegacyconversion then
        self:ForceRetryLegacyPathConversion(slot)
    end
end

function ShardSaveIndex:ForceRetryLegacyPathConversion(slot)
    local serverdata = self:GetSlotServerData(slot)
    serverdata.use_legacy_session_path = true
    RetryLegacyPathConversion(self, slot)
end

function ShardSaveIndex:RerunSlotConversion(slot)
    local savefileupgrades = require "savefileupgrades"
    if SaveGameIndex and SaveGameIndex.loaded_from_file then
        savefileupgrades.utilities.ConvertSaveIndexSlotToShardIndexSlots(SaveGameIndex, self, slot, self:IsSlotMultiLevel(slot))
    end
end

local function OnLoad(self, callback, str)
    local success, savedata = RunInSandbox(str)

    -- If we are on steam cloud this will stop a corrupt shardsaveindex file from
    -- ruining everyone's day..
    if success and string.len(str) > 0 and type(savedata) == "table" then

        local was_upgraded = false
        if savedata.version ~= SHARDSAVEINDEX_VERSION then
            was_upgraded = UpgradeShardSaveIndexData(savedata)
        end

        self.failed_slot_conversions = savedata.failed_slot_conversions
        self.version = savedata.version

        local filename = self:GetShardSaveIndexName()
        if filename ~= nil then
            print("loaded "..filename)

			if was_upgraded then
				print("Saving upgraded "..filename)
				self:Save()
			end
        end

        self.slots = TheSim:GetSaveFiles()

        RetryFailedSaveConversions(self)
    elseif not TheNet:IsDedicated() and IsInFrontEnd() and SaveGameIndex.loaded_from_file then
        local savefileupgrades = require "savefileupgrades"
        savefileupgrades.utilities.ConvertSaveIndexToShardSaveIndex(SaveGameIndex, self)
        self:Save()
    elseif not TheNet:IsDedicated() then
        self.slots = TheSim:GetSaveFiles()
        self:Save()
    end

    if callback ~= nil then
        callback()
    end
end

function ShardSaveIndex:Load(callback)
    --This happens on game start.
    if not IsInFrontEnd() then
        self.invalid = true
        if callback ~= nil then
            callback()
        end
        return
    end
    TheSim:GetPersistentString(self:GetShardSaveIndexName(),
        function(load_success, str)
            OnLoad(self, callback, str)
        end)
end

function ShardSaveIndex:GetSlotGameMode(slot)
    --only valid on Master
    local shardIndex = self:GetShardIndex(slot, "Master")
    return shardIndex and shardIndex:GetGameMode() or DEFAULT_GAME_MODE
end

function ShardSaveIndex:DeleteSlot(slot, cb, save_options)
    local function callback()
        if not save_options and not TheNet:IsDedicated() then
            TheNet:DeleteCluster(slot)
        end

        if cb ~= nil then
            cb()
        end
    end

    local shardIndex = self:GetShardIndex(slot, "Master")
    self.slots[slot] = nil
    self.slot_cache[slot] = nil

    if shardIndex then
        shardIndex:Delete(callback, save_options)
    else
        callback()
    end
end

function ShardSaveIndex:GetValidSlots()
    local slots = {}
    for slot, ismultilevel in pairs(self.slots) do
        if not ShardSaveGameIndex:IsSlotEmpty(slot) then
            table.insert(slots, slot)
        else
            table.removearrayvalue(slots, slot)
        end
    end
    return slots
end

function ShardSaveIndex:GetNextNewSlot(force_slot_type)
    if force_slot_type == "cloud" or (force_slot_type ~= "local" and Profile:GetDefaultCloudSaves()) then
        return TheSim:GetNextCloudSaveSlot()
    end

    local i = 1 
    while true do
        if (self.failed_slot_conversions or {})[i] == nil and (self.slots[i] == nil or self:IsSlotEmpty(i))  then
            return i
        end
        i = i + 1
    end
end

function ShardSaveIndex:IsSlotEmpty(slot)
    if self.slots[slot] == nil then
        return true
    end
    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        return shardIndex:IsEmpty()
    end
    return true
end

function ShardSaveIndex:IsSlotMultiLevel(slot)
    return self.slots[slot] == true
end

function ShardSaveIndex:GetSlotLastTimePlayed(slot)
    local time
    local function ontimefileloaded(load_success, str)
        local success, timedata = RunInSandbox(str)

        if success and string.len(str) > 0 then
            if type(timedata) == "number" then
                time = timedata
            elseif type(timedata) == "table" then
                time = timedata.saved
            end
        end
    end
    local filename = ShardIndex:GetShardIndexName().."_time"
    if slot then
        TheSim:GetPersistentStringInClusterSlot(slot, "Master", filename, ontimefileloaded)
    else
        TheSim:SetPersistentString(filename, ontimefileloaded)
    end
    return time
end

function ShardSaveIndex:GetSlotDateCreated(slot)
    local created = 0
    local function ontimefileloaded(load_success, str)
        if load_success then
            local success, timedata = RunInSandbox(str)

            if success and string.len(str) > 0 then
                if type(timedata) == "table" then
                    created = timedata.created
                end
            end
        end
    end
    local filename = ShardIndex:GetShardIndexName().."_time"
    if slot then
        TheSim:GetPersistentStringInClusterSlot(slot, "Master", filename, ontimefileloaded)
    else
        TheSim:SetPersistentString(filename, ontimefileloaded)
    end
    return created
end

function ShardSaveIndex:GetSlotServerData(slot)
    if self:IsSlotEmpty(slot) then return {} end
    local shardIndex = self:GetShardIndex(slot, "Master")
    return shardIndex and shardIndex:GetServerData() or {}
end

function ShardSaveIndex:SetSlotServerData(slot, serverdata)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        shardIndex:SetServerData(serverdata)
    end
end

function ShardSaveIndex:GetSlotGenOptions(slot, shard)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, shard)
    return shardIndex and shardIndex:GetGenOptions()
end

function ShardSaveIndex:SetSlotGenOptions(slot, shard, options)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, shard)
    if shardIndex then
        shardIndex:SetGenOptions(options)
    end
end

function ShardSaveIndex:GetSlotSession(slot, shard)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, shard)
    return shardIndex and shardIndex:GetSession()
end

--V2C: This is no longer cheap because it's not cached, but supports
--     dynamically switching user accounts locally, mmm'kay
function ShardSaveIndex:GetSlotCharacter(slot)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        local session_id = shardIndex:GetSession()
        local online_mode = shardIndex.server.online_mode ~= false
        local encode_user_path = shardIndex:GetServerData().encode_user_path == true

        local character = nil

        if session_id then
            local function onreadmetasession(success, str, slot, shard, file)
                if success then
                    if str ~= nil and #str > 0 then
                        local success, metadata = RunInSandbox(str)
                        if success and metadata ~= nil and GetTableSize(metadata) > 0 then
                            character = metadata.character
                        end
                    end
                else
                    local function onreadusersession(success, str)
                        if success and str ~= nil and #str > 0 then
                            local success, savedata = RunInSandbox(str)
                            if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                                character = savedata.prefab
                            end
                        end
                    end
                    if slot and shard then
                        TheNet:DeserializeUserSessionInClusterSlot(slot, shard, file, onreadusersession)
                    else
                        TheNet:DeserializeUserSession(file, onreadusersession)
                    end
                end
            end

            if self:IsSlotMultiLevel(slot) then
                local shard, snapshot = TheNet:GetPlayerSaveLocationInClusterSlot(slot, session_id, online_mode, encode_user_path)
                if shard and snapshot then
                    if shard ~= "Master" then
                        local secondaryShardIndex = self:GetShardIndex(slot, shard)
                        if secondaryShardIndex then
                            session_id = secondaryShardIndex:GetSession()
                            encode_user_path = secondaryShardIndex:GetServerData().encode_user_path == true
                        else
                            session_id = nil
                        end
                    end
                    if session_id then
                        local file = TheNet:GetUserSessionFileInClusterSlot(slot, shard, session_id, snapshot, online_mode, encode_user_path)
                        if file ~= nil then
                            TheNet:DeserializeUserSessionInClusterSlot(slot, shard, file..".meta", function(success, str)
                                onreadmetasession(success, str, slot, shard, file)
                            end)
                        end
                    end
                end
            else
                if not shardIndex:GetServerData().use_legacy_session_path then
                    local file = TheNet:GetUserSessionFileInClusterSlot(slot, "Master", session_id, nil, online_mode, encode_user_path)
                    if file ~= nil then
                        TheNet:DeserializeUserSessionInClusterSlot(slot, "Master", file..".meta", function(success, str)
                            onreadmetasession(success, str, slot, "Master", file)
                        end)
                    end
                else
                    local file = TheNet:GetUserSessionFile(session_id, nil, online_mode, encode_user_path)
                    if file ~= nil then
                        TheNet:DeserializeUserSession(file..".meta", function(success, str)
                            onreadmetasession(success, str, nil, nil, file)
                        end)
                    end
                end
            end
        end
        return character
    end
end

function ShardSaveIndex:GetSlotDayAndSeasonText(slot)
	local slot_day_and_season_str = STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY_NEW
    if self:IsSlotEmpty(slot) then return slot_day_and_season_str end

    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        local session_id = shardIndex:GetSession()

        if session_id then
            local day = 1
            local season = nil

            local function onreadmetafile(success, str, slot, shard, file)
                if success then
                    if str ~= nil and #str > 0 then
                        local success, metadata = RunInSandbox(str)
                        if success and metadata ~= nil and GetTableSize(metadata) > 0 then
                            if metadata.clock ~= nil then
                                day = (metadata.clock.cycles or 0) + 1
                            end

                            if metadata.seasons ~= nil and metadata.seasons.season ~= nil then
                                season = STRINGS.UI.SERVERLISTINGSCREEN.SEASONS[string.upper(metadata.seasons.season)]
                                if season ~= nil and
                                    metadata.seasons.elapseddaysinseason ~= nil and
                                    metadata.seasons.remainingdaysinseason ~= nil then
                                    if metadata.seasons.remainingdaysinseason * 3 <= metadata.seasons.elapseddaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.LATE_SEASON_2
                                    elseif metadata.seasons.elapseddaysinseason * 3 <= metadata.seasons.remainingdaysinseason then
                                        season = STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_1..season..STRINGS.UI.SERVERLISTINGSCREEN.EARLY_SEASON_2
                                    end
                                end
                            end
                        end
                    end
                else
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

                    if slot and shard then
                        TheSim:GetPersistentStringInClusterSlot(slot, shard, file, onreadworldfile)
                    else
                        TheSim:GetPersistentString(file, onreadworldfile)
                    end
                end
            end

            if not self:GetSlotServerData(slot).use_legacy_session_path then
                local file = TheNet:GetWorldSessionFileInClusterSlot(slot, "Master", session_id)
                if file ~= nil then
                    TheSim:GetPersistentStringInClusterSlot(slot, "Master", file..".meta", function(success, str)
                        onreadmetafile(success, str, slot, "Master", file)
                    end)
                end
            else
                local file = TheNet:GetWorldSessionFile(session_id)
                if file ~= nil then
                    TheSim:GetPersistentString(file..".meta", function(success, str)
                        onreadmetafile(success, str, nil, nil, file)
                    end)
                end
            end

            slot_day_and_season_str = (season ~= nil and (season.." ") or "")..STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY.." "..day
        end
    end
    return slot_day_and_season_str
end

function ShardSaveIndex:GetSlotDay(slot)
	local day = 1
    if self:IsSlotEmpty(slot) then return day end

    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        local session_id = shardIndex:GetSession()

        if session_id then
            local function onreadmetafile(success, str, slot, shard, file)
                if success then
                    if str ~= nil and #str > 0 then
                        local success, metadata = RunInSandbox(str)
                        if success and metadata ~= nil and GetTableSize(metadata) > 0 then
                            if metadata.clock ~= nil then
                                day = (metadata.clock.cycles or 0) + 1
                            end
                        end
                    end
                else
                    local function onreadworldfile(success, str)
                        if success and str ~= nil and #str > 0 then
                            local success, savedata = RunInSandbox(str)
                            if success and savedata ~= nil and GetTableSize(savedata) > 0 then
                                local worlddata = savedata.world_network ~= nil and savedata.world_network.persistdata or nil
                                if worlddata ~= nil then
                                    if worlddata.clock ~= nil then
                                        day = (worlddata.clock.cycles or 0) + 1
                                    end
                                end
                            end
                        end
                    end

                    if slot and shard then
                        TheSim:GetPersistentStringInClusterSlot(slot, shard, file, onreadworldfile)
                    else
                        TheSim:GetPersistentString(file, onreadworldfile)
                    end
                end
            end

            if not self:GetSlotServerData(slot).use_legacy_session_path then
                local file = TheNet:GetWorldSessionFileInClusterSlot(slot, "Master", session_id)
                if file ~= nil then
                    TheSim:GetPersistentStringInClusterSlot(slot, "Master", file..".meta", function(success, str)
                        onreadmetafile(success, str, slot, "Master", file)
                    end)
                end
            else
                local file = TheNet:GetWorldSessionFile(session_id)
                if file ~= nil then
                    TheSim:GetPersistentString(file..".meta", function(success, str)
                        onreadmetafile(success, str, nil, nil, file)
                    end)
                end
            end
        end
    end
    return day
end

function ShardSaveIndex:GetSlotPresetText(slot)
	local preset_str = ""
    if self:IsSlotEmpty(slot) then return preset_str end

    if self:GetShardIndex(slot, "Master") then
        preset_str = STRINGS.UI.SERVERCREATIONSCREEN.FORESTONLY
        if self:IsSlotMultiLevel(slot) and self:GetShardIndex(slot, "Caves") then
            preset_str = STRINGS.UI.SERVERCREATIONSCREEN.FORESTANDCAVES
        end
    end
    return preset_str
end

function ShardSaveIndex:GetSlotEnabledServerMods(slot)
    if self:IsSlotEmpty(slot) then return self.enabled_mods_cache or {} end
    local shardIndex = self:GetShardIndex(slot, "Master")
    return shardIndex and shardIndex:GetEnabledServerMods() or {} --Only valid on the master shard.
end

function ShardSaveIndex:SetSlotEnabledServerMods(slot)
    local server_enabled_mods = ModManager:GetEnabledServerModNames()

    local enabled_mods = {}
    for _,modname in pairs(server_enabled_mods) do
        --Note(Peter): The format of mod_data now must match the format expected in modoverrides.lua. See ModIndex:ApplyEnabledOverrides
        local mod_data = {
            enabled = true,
            configuration_options = {},
        }
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

    if self:IsSlotEmpty(slot) then
        self.enabled_mods_cache = enabled_mods
        return
    end

    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        return shardIndex:SetEnabledServerMods(enabled_mods)
    end
end

function ShardSaveIndex:LoadSlotEnabledServerMods(slot)
    if self:IsSlotEmpty(slot) then return end
    local shardIndex = self:GetShardIndex(slot, "Master")
    if shardIndex then
        return shardIndex:LoadEnabledServerMods() --Only valid on the master shard.
    end
end