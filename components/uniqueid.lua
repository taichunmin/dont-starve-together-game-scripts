
local function TryGetNewId(inst)
    local self = inst.components.uniqueid
    if self.id == nil then
        self.id = TheWorld.components.uniqueprefabids:GetNextID(inst.prefab)
        return
    end
    -- else we must have loaded with an ID!
end

local UniqueID = Class(function(self, inst)
    self.inst = inst

    self.id = nil

    self.task = self.inst:DoTaskInTime(0, TryGetNewId)
end)

function UniqueID:OnSave()
    return {
        id = self.id,
    }
end

function UniqueID:OnLoad(data)
    self.id = data.id -- even if it's nil!
    if self.id ~= nil then
        self.task:Cancel()
    end
end

function UniqueID:GetDebugString()
    return tostring(self.id)
end

return UniqueID
