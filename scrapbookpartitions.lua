-- NOTES(JBK): This is a wrapper for partitioning up the scrapbookdata space into chunks instead of being one blob to send to the backend.
--
-- All entries will be handled in this file for partitioning up the key space across a set number of buckets to distribute the backend load.
-- You should not manually handle any of the data layer outside of this file.
--

------------------------------------------------------------
-- Constants be very careful editing any of these or you will cause player data corruption!
------------------------------------------------------------

-- 32 bits of storage space has been allocated.
-- [hash('thing')] = [which character inspected this 'thing':24 bits][FLAGS:8 bits]

local scrapbook_dataset = require("screens/redux/scrapbookdata")

local FLAGS = { -- DO NOT REARRANGE ORDER OR CHANGE VALUES
    ["VIEWED_IN_SCRAPBOOK"] = 0x00000001, -- 1
    --[""]                  = 0x00000002, -- 2
    --[""]                  = 0x00000004, -- 3
    --[""]                  = 0x00000008, -- 4
--
    --[""]                  = 0x00000010, -- 5
    --[""]                  = 0x00000020, -- 6
    --[""]                  = 0x00000040, -- 7
    --[""]                  = 0x00000080, -- 8
-- Do not add more flags 8 max.
}

-- NOTES(JBK): Keep this up to date with DST_CHARACTERLIST in constants.lua
local LOOKUP_LIST = { -- DO NOT REARRANGE ORDER OR CHANGE VALUES
    ["wilson"]       = 0x00000100, --  1
    ["willow"]       = 0x00000200, --  2
    ["wolfgang"]     = 0x00000400, --  3
    ["wendy"]        = 0x00000800, --  4
--
    ["wx78"]         = 0x00001000, --  5
    ["wickerbottom"] = 0x00002000, --  6
    ["woodie"]       = 0x00004000, --  7
    ["wes"]          = 0x00008000, --  8
--
    ["waxwell"]      = 0x00010000, --  9
    ["wathgrithr"]   = 0x00020000, -- 10
    ["webber"]       = 0x00040000, -- 11
    ["winona"]       = 0x00080000, -- 12
--
    ["warly"]        = 0x00100000, -- 13
    ["wortox"]       = 0x00200000, -- 14
    ["wormwood"]     = 0x00400000, -- 15
    ["wurt"]         = 0x00800000, -- 16
--
    ["walter"]       = 0x01000000, -- 17
    ["wanda"]        = 0x02000000, -- 18
    --[""]           = 0x04000000, -- 19
    --[""]           = 0x08000000, -- 20
--
    --[""]           = 0x10000000, -- 21
    --[""]           = 0x20000000, -- 22
    --[""]           = 0x40000000, -- 23
    --[""]           = 0x80000000, -- 24
-- Do not add more characters past 24 without consulting with an engineer first.
-- If in an emergency break glass and smile.
--
    --["wonkey"] = DO NOT ADD
}
local LOOKUP_LIST_MASK = 0
for _, v in pairs(LOOKUP_LIST) do
    LOOKUP_LIST_MASK = LOOKUP_LIST_MASK + v
end

local BUCKETS_MASK = 0xF -- 16 buckets 0 to 15 make this always 2^N-1 in size. Keep in sync with InventoryManager.h


------------------------------------------------------------
-- Internal use
------------------------------------------------------------

local SCRAPBOOK_DATA_SET = require("screens/redux/scrapbookdata")

-- Small speedups.
local band = bit.band
local bor  = bit.bor
local bnot = bit.bnot
local hash = hash
local sformat = string.format
local next = next
local type = type

local function GetBucketForHash(hashed)
    return band(BUCKETS_MASK, hashed)
end

local function WriteTriStateString(data)
    return (data == nil or data == -1) and "" or sformat("%X", data)
end

local function ReadTriStateString(str)
    return str and str ~= "" and tonumber(str, 16) or nil
end

local function UpdatePlayerScreens(thing)
    if ThePlayer then
        ThePlayer.scrapbook_seen = ThePlayer.scrapbook_seen or {}
        ThePlayer.scrapbook_seen[thing] = true

        local ok = false
        for i,cat in ipairs(SCRAPBOOK_CATS)do
            if scrapbook_dataset[thing].type == cat then
                ok = true
            end
        end

        if ok then
            ThePlayer:PushEvent("scrapbookupdated")
        end
    end
end


------------------------------------------------------------
-- Class
------------------------------------------------------------


local ScrapbookPartitions = Class(function(self)
    self.storage = {}
    self.dirty_buckets = {}

    --self.save_enabled = nil
    --self.dirty = nil
    --self.synced = nil
    --self.loaded = nil
end)


------------------------------------------------------------
-- Public
------------------------------------------------------------

function ScrapbookPartitions:RedirectThing(thing) -- NOTES(JBK): Use this wrapper function to redirect an object into a string if available.
    if EntityScript.is_instance(thing) then
        return thing.scrapbook_proxy or thing.prefab
    end

    return thing
end


function ScrapbookPartitions:WasSeenInGame(thing)
    -- If a thing has been seen but not necessarily inspected.

    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return false
    end

    local hashed = hash(thing)
    local data = self.storage[hashed]

    return data ~= nil
end
function ScrapbookPartitions:SetSeenInGame(thing)
    -- When a thing has been seen but not necessarily inspected.

    thing = self:RedirectThing(thing)

    if not SCRAPBOOK_DATA_SET[thing] then -- This validates the strings only check.
        return -- No information on what the thing is.
    end

    local hashed = hash(thing)
    local data = self.storage[hashed]
    if data then
        return -- No change.
    end
    
    local newdata = 0

    self:UpdateStorageData(hashed, newdata)

    UpdatePlayerScreens(thing)
end

--

function ScrapbookPartitions:WasViewedInScrapbook(thing)
    -- If a thing has been clicked on inside the Scrapbook.

    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return false
    end

    local hashed = hash(thing)
    local data = self.storage[hashed]
    if not data then
        return false
    end

    return band(data, FLAGS.VIEWED_IN_SCRAPBOOK) == FLAGS.VIEWED_IN_SCRAPBOOK
end
function ScrapbookPartitions:SetViewedInScrapbook(thing, value)
    -- When a thing has been clicked on inside the Scrapbook.

    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return -- Strings only.
    end

    if not SCRAPBOOK_DATA_SET[thing] then
        return -- No information on what the thing is.
    end

    local hashed = hash(thing)
    local data = self.storage[hashed] or 0
    local newdata
    if value == nil or value then
        newdata = bor(data, FLAGS.VIEWED_IN_SCRAPBOOK)
    else
        newdata = band(data, bnot(FLAGS.VIEWED_IN_SCRAPBOOK))
    end
    if data == newdata then
        return -- No change.
    end

    self:UpdateStorageData(hashed, newdata)
  
    --UpdatePlayerScreens(thing)
end

--

function ScrapbookPartitions:WasInspectedByCharacter(thing, character)
    -- If a specific character has personally inspected a prefab.

    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return false -- Strings only.
    end

    if table.contains(MODCHARACTERLIST, character) then
        character = "wilson" -- Modded characters do not save instead use Wilson as a fallback.
    end

    local charactermask = LOOKUP_LIST[character]
    if not charactermask then
        return false -- Nothing unexpected allowed.
    end

    local hashed = hash(thing)
    local data = self.storage[hashed]
    if not data then
        return false
    end

    return band(data, charactermask) == charactermask
end

function ScrapbookPartitions:SetInspectedByCharacter(thing, character)
    -- If a specific character has personally inspected a prefab.

    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return -- Strings only.
    end

    if table.contains(MODCHARACTERLIST, character) then
        character = "wilson" -- Modded characters do not save instead use Wilson as a fallback.
    end

    if not SCRAPBOOK_DATA_SET[thing] then
        return -- No information on what the thing is.
    end

    local charactermask = LOOKUP_LIST[character]
    if not charactermask then
        return -- Nothing unexpected allowed.
    end

    local hashed = hash(thing)
    local data = self.storage[hashed] or 0
    local newdata = bor(data, charactermask)
    if data == newdata then
        return -- No change.
    end

    self:UpdateStorageData(hashed, newdata)

    UpdatePlayerScreens(thing)

    self:SetViewedInScrapbook(thing, false) -- Mark as new.
end


------------------------------------------------------------
-- Utility
------------------------------------------------------------


function ScrapbookPartitions:GetLevelFor(thing)
    thing = self:RedirectThing(thing)

    if type(thing) ~= "string" then
        return 0
    end

    local hashed = hash(thing)
    local data = self.storage[hashed]

    if data == nil then
        return 0 -- If a thing is unknown it is level 0.
    end

    if band(data, LOOKUP_LIST_MASK) == 0 then
        return 1 -- If a thing has been seen but not inspected it is level 1.
    end

    return 2 -- If a thing has been seen and inspected once it is level 2.
end

function ScrapbookPartitions:TryToTeachScrapbookData_Random(numofentries)
    local learned_something = false

    local unknown = {}
    for prefab, data in pairs(scrapbook_dataset) do
        if self:GetLevelFor(prefab) < 1 then
            table.insert(unknown, prefab)
        end
    end

    if #unknown then
        while #unknown > 0 and numofentries > 0 do
            local choice = math.random(1, #unknown)

            local ok = false
            for i, cat in ipairs(SCRAPBOOK_CATS) do
                if scrapbook_dataset[unknown[choice]].type == cat then
                    ok = true
                    break
                end
            end
            if ok then
                learned_something = true
                self:SetSeenInGame(unknown[choice])
                numofentries = numofentries - 1
            end
            table.remove(unknown, choice)
        end
    end

    return learned_something
end

function ScrapbookPartitions:TryToTeachScrapbookData_Special(index)
    local learned_something = false

    local page_data = SPECIAL_SCRAPBOOK_PAGES_LOOKUP[index]
    if page_data ~= nil then
        for i, entry in ipairs(page_data.entries) do
            if self:GetLevelFor(entry) < 1 then
                learned_something = true
                self:SetSeenInGame(entry)
            end
        end
    end

    return learned_something
end

function ScrapbookPartitions:TryToTeachScrapbookData_Note(entry)
    self:SetInspectedByCharacter(entry, ThePlayer.prefab)

    if ThePlayer.HUD ~= nil then
        ThePlayer.HUD:OpenScrapbookScreen()

        if ThePlayer.HUD.scrapbookscreen ~= nil then
            ThePlayer.HUD.scrapbookscreen:SelectEntry(entry)
        end
    end

    return true
end

function ScrapbookPartitions:TryToTeachScrapbookData(is_server, inst)
    local learned_something = false

    local index = inst._id ~= nil and inst._id:value() or 0
    if index > 0 then
        learned_something = self:TryToTeachScrapbookData_Special(index)
    elseif inst:HasTag("scrapbook_note") then
        learned_something = self:TryToTeachScrapbookData_Note(inst.prefab)
    else
        learned_something = self:TryToTeachScrapbookData_Random(math.random(3, 4))
    end

    if not is_server then
        SendRPCToServer(RPC.OnScrapbookDataTaught, inst, learned_something)
    end

    return learned_something
end


------------------------------------------------------------
-- Debug
------------------------------------------------------------

function ScrapbookPartitions:_GetBucketForHash(hashed) -- Exporter use.
    return GetBucketForHash(hashed)
end

-- NOTES(JBK): Debug commands are not expected to run seamlessly run the command at the main menu wait for the backend timer to sync and then go through login again to properly sync up.
function ScrapbookPartitions:DebugDeleteAllData()
    local newdata = -1
    for prefab, data in pairs(SCRAPBOOK_DATA_SET) do
        local hashed = hash(prefab)
        self:UpdateStorageData(hashed, newdata)
    end
end

function ScrapbookPartitions:DebugSeenEverything()
    for prefab, data in pairs(SCRAPBOOK_DATA_SET) do
        self:SetSeenInGame(prefab)
    end
end

function ScrapbookPartitions:DebugUnlockEverything()
    local newdata = 0xFFFFFFFF
    for prefab, data in pairs(SCRAPBOOK_DATA_SET) do
        local hashed = hash(prefab)
        self:UpdateStorageData(hashed, newdata)
    end
end


------------------------------------------------------------
-- Save / Load
------------------------------------------------------------


function ScrapbookPartitions:UpdateMultiStorageData()
    -- We have a bundle of stored up data send it all off as one big chunk if possible.
    local bucketarray -- Arbitrary arrays to store each bucket into.
    for i = 0, BUCKETS_MASK do
        if self.dirty_buckets[i] then
            bucketarray = bucketarray or {}
            bucketarray[i] = {}
        end
    end
    if bucketarray then
        -- We have something to save time to do the more expensive save operation to find out what to save.
        for hashed, data in pairs(self.storage) do
            local bucket = GetBucketForHash(hashed)
            local bucketdata = bucketarray[bucket]
            if bucketdata then
                bucketdata[sformat("%X", hashed)] = WriteTriStateString(data)
            end
        end
        local bigbucketdata = {}
        -- Save the filtered buckets out.
        for i = 0, BUCKETS_MASK do
            bigbucketdata[sformat("SCRAPBOOK%d", i)] = bucketarray[i]
        end
        -- Send to backend.
        TheInventory:SetStorageValueMulti(bigbucketdata)
        self:Save() -- Save a local copy too.
    end
end
local function DoBackendSync()
    TheGlobalInstance._scrapbook_update_task = nil
    TheScrapbookPartitions:UpdateMultiStorageData()
end
local function DoOfflineSync()
    TheGlobalInstance._scrapbook_update_task = nil
    TheScrapbookPartitions:Save()
end


function ScrapbookPartitions:UpdateStorageData(hashed, newdata)
    self.storage[hashed] = newdata
    local bucket = GetBucketForHash(hashed)
    self.dirty_buckets[bucket] = true
    if (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode()) then
        if TheInventory:HasSupportForOfflineSkins() then
            -- Offline mode must send one KV at a time to get into pending KV stores.
            local KVstorage = sformat("SetScrapbook%dValue", bucket)
            TheInventory[KVstorage](TheInventory, sformat("%X", hashed), WriteTriStateString(newdata))
            -- TheInventory:SetScrapbookValue() TheInventory:SetScrapbook0Value() : Search Strings.
        end
        if TheGlobalInstance._scrapbook_update_task ~= nil then
            TheGlobalInstance._scrapbook_update_task:Cancel()
            TheGlobalInstance._scrapbook_update_task = nil
        end
        TheGlobalInstance._scrapbook_update_task = TheGlobalInstance:DoTaskInTime(TUNING.SCRAPBOOK_BACKEND_SYNC, DoOfflineSync)
    elseif TheInventory:HasDownloadedInventory() then
        -- Online mode and we have downloaded the inventory.
        if TheGlobalInstance._scrapbook_update_task ~= nil then
            TheGlobalInstance._scrapbook_update_task:Cancel()
            TheGlobalInstance._scrapbook_update_task = nil
        end
        TheGlobalInstance._scrapbook_update_task = TheGlobalInstance:DoTaskInTime(TUNING.SCRAPBOOK_BACKEND_SYNC, DoBackendSync)
    end
end


function ScrapbookPartitions:Save(force_save)
    --print("[ScrapbookPartitions] Save")
    local bucketarray -- Arbitrary arrays to store each bucket into.
    for i = 0, BUCKETS_MASK do
        if force_save or self.dirty_buckets[i] then
            bucketarray = bucketarray or {}
            bucketarray[i] = {}
        end
    end
    if bucketarray then
        -- We have something to save time to do the more expensive save operation to find out what to save.
        for hashed, data in pairs(self.storage) do
            local bucket = GetBucketForHash(hashed)
            local bucketdata = bucketarray[bucket]
            if bucketdata then
                bucketdata[sformat("%X", hashed)] = WriteTriStateString(data)
            end
        end
        -- Save the filtered buckets out.
        for i = 0, BUCKETS_MASK do
            local bucketdata = bucketarray[i]
            if bucketdata then
                if next(bucketdata) then
                    local str = json.encode(bucketdata)
                    TheSim:SetPersistentString("scrapbook_" .. i, str, false)
                else
                    TheSim:ErasePersistentString("scrapbook_" .. i)
                end
                self.dirty_buckets[i] = nil
            end
        end
    end
end

function ScrapbookPartitions:MergeValues(storage, k, v)
    if v then
        -- Merge with what is there already.
        storage[k] = bor(storage[k] or 0, v)
    else
        -- Deleted entry from debug command use.
        storage[k] = nil
    end
end

function ScrapbookPartitions:Load()
    --print("[ScrapbookPartitions] Load")
    local storage = {}
    self.storage = storage
    self.dirty_buckets = {}
    for i = 0, BUCKETS_MASK do
        TheSim:GetPersistentString("scrapbook_" .. i, function(load_success, str)
            if load_success and str ~= nil then
                local status, bucketdata = pcall(function() return json.decode(str) end)
                if status and bucketdata then
                    for k, v in pairs(bucketdata) do
                        storage[tonumber(k, 16)] = ReadTriStateString(v)
                    end
                else
                    print("Failed to load the bucketdata in ScrapbookPartitions!", status, bucketdata, i)
                end
            end
        end)
    end
end

function ScrapbookPartitions:ApplyOnlineProfileData()
    --print("[ScrapbookPartitions] ApplyOnlineProfileData")
    if not self.synced and
        (TheInventory:HasSupportForOfflineSkins() or not (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode())) and
        TheInventory:HasDownloadedInventory() then
        local storage = self.storage or {}
        self.storage = storage
        for i = 0, BUCKETS_MASK do
            local KVstorage = sformat("GetLocalScrapbook%d", i)
            local data = TheInventory[KVstorage](TheInventory)
            for k, v in pairs(data) do
                self:MergeValues(storage, tonumber(k, 16), ReadTriStateString(v))
            end
            -- TheInventory:GetLocalScrapbook() TheInventory:GetLocalScrapbook0() : Search Strings.
        end
        self.synced = true
        if not self.loaded then -- We loaded a file from the player's profile but there is no save data on disk save it now.
            self.loaded = true
            self:Save(true) -- Force the issue to save to disk.
        end
    end
    return self.synced
end



return ScrapbookPartitions
