local EntityTracker = Class(function(self, inst)
    self.inst = inst
    self.entities = {}
end)

function EntityTracker:OnRemoveFromEntity()
    for k, v in pairs(self.entities) do
        self.inst:RemoveEventCallback("onremove", v.onremove, v.inst)
    end
end

function EntityTracker:GetDebugString()
    local str = "\n"
    for k, v in pairs(self.entities) do
        str = str.."    --"..k.."\n"
        str = str..string.format("      --entity: %s \n", tostring(v.inst))
    end
    return str
end

function EntityTracker:TrackEntity(name, inst)
    local function onremove()
        self.entities[name] = nil
    end
    self.entities[name] = { inst = inst, onremove = onremove }
    self.inst:ListenForEvent("onremove", onremove, inst)
end

function EntityTracker:ForgetEntity(name)
    if self.entities[name] ~= nil then
        self.inst:RemoveEventCallback("onremove", self.entities[name].onremove, self.entities[name].inst)
        self.entities[name] = nil
    end
end

function EntityTracker:GetEntity(name)
    return self.entities[name] ~= nil and self.entities[name].inst or nil
end

function EntityTracker:OnSave()
    if next(self.entities) == nil then
        return
    end

    local ents = {}
    local refs = {}

    for k, v in pairs(self.entities) do
        table.insert(ents, { name = k, GUID = v.inst.GUID })
        table.insert(refs, v.inst.GUID)
    end

    return { entities = ents }, refs
end

function EntityTracker:LoadPostPass(ents, data)
    if data.entities ~= nil then
        for i, v in ipairs(data.entities) do
            local ent = ents[v.GUID]
            if ent ~= nil then
                self:TrackEntity(v.name, ent.entity)
            end
        end
    end
end

return EntityTracker
