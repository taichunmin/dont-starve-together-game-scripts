

local UniquePrefabIDs = Class(function(self, inst)
    self.inst = inst

    self.topprefabids = {}
end)

function UniquePrefabIDs:GetNextID(prefabname)
    if self.topprefabids[prefabname] ~= nil then
        self.topprefabids[prefabname] = self.topprefabids[prefabname] + 1
    else
        self.topprefabids[prefabname] = 1
    end
    return self.topprefabids[prefabname]
end

function UniquePrefabIDs:OnSave()
    return {
        topprefabids = self.topprefabids,
    }
end

function UniquePrefabIDs:OnLoad(data)
    self.topprefabids = data.topprefabids or {}
end

function UniquePrefabIDs:GetDebugString()
    local s = ""
    for name, top in pairs(self.topprefabids) do
        s = s..string.format("%s: %d ", name, top)
    end
    return s
end


return UniquePrefabIDs
