-- NOTES(JBK): This is a wrapper for TheInventory synchronization steps please use other saving methods for mods it will not be safe here.

local GenericKV = Class(function(self)
    self.kvs = {}

    --self.save_enabled = nil
    --self.dirty = nil
    --self.synced = nil
    --self.loaded = nil
end)

function GenericKV:GetKV(key)
    return self.kvs[key]
end

function GenericKV:SetKV(key, value)
    --print("[GenericKV] SetKV", key, value)
    if self.kvs[key] == value then
        return true
    end

    assert(type(value) == "string")
    self.dirty = true
    if self.save_enabled then
        if not TheNet:IsDedicated() then
            TheInventory:SetGenericKVValue(key, value)
        end
        self.kvs[key] = value
        self:Save(true)

        return true
    end
    return false
end

function GenericKV:Save(force_save)
    --print("[GenericKV] Save")
    if force_save or (self.save_enabled and self.dirty) then
        local str = json.encode({kvs = self.kvs or self.kvs, })
        TheSim:SetPersistentString("generickv", str, false)
        self.dirty = false
    end
end

function GenericKV:Load()
    --print("[GenericKV] Load")
    self.kvs = {}
    TheSim:GetPersistentString("generickv", function(load_success, data)
        if load_success and data ~= nil then
            local status, generickv_data = pcall(function() return json.decode(data) end)
            if status and generickv_data then
                self.kvs = generickv_data.kvs
                self.loaded = true
            else
                print("Failed to load the data in generickv!", status, generickv_data)
            end
        end
    end)
end

function GenericKV:ApplyOnlineProfileData()
    --print("[GenericKV] ApplyOnlineProfileData")
    if not self.synced and
        (TheInventory:HasSupportForOfflineSkins() or not (TheFrontEnd ~= nil and TheFrontEnd:GetIsOfflineMode() or not TheNet:IsOnlineMode())) and
        TheInventory:HasDownloadedInventory() then
        self.kvs = TheInventory:GetLocalGenericKV()
        self.synced = true
        if not self.loaded then -- We loaded a file from the player's profile but there is no save data on disk save it now.
            self.loaded = true
            self:Save(true)
        end
    end
    return self.synced
end

return GenericKV
