local TreasureMarked = Class(function(self, inst)
    self.inst = inst

    self.marker = nil
end)

function TreasureMarked:TurnOn()
    self.marker = SpawnPrefab("messagebottletreasure_marker")
    if self.marker ~= nil then
        self.marker.entity:SetParent(self.inst.entity)
    end
end

function TreasureMarked:TurnOff()
    if self.marker ~= nil and self.marker:IsValid() then
        self.marker:Remove()
    end
end

function TreasureMarked:OnRemoveFromEntity()
    self:TurnOff()
end

function TreasureMarked:OnSave()
    if self.marker ~= nil and self.marker:IsValid() then
        local data = { on = true }
        return data
    end
end

function TreasureMarked:LoadPostPass(ents, data)
    if data ~= nil and data.on then
        self:TurnOn()
    end
end

return TreasureMarked
