local ObjectSpawner = Class(function(self, inst)
    self.inst = inst
    self.objects = {}
    self.onnewobjectfn = nil
end)

function ObjectSpawner:OnSave()
    local objects = {}
    local references = {}
    for i, v in ipairs(self.objects) do
        table.insert(objects, v.GUID)
        table.insert(references, v.GUID)
    end
    if #objects > 0 then
        return { objects = objects }, references
    end
end

function ObjectSpawner:LoadPostPass(newents, data)
    if data.objects ~= nil then
        for i, v in ipairs(data.objects) do
            local child = newents[v]
            if child ~= nil then
                self:TakeOwnership(child.entity)
            end
        end
    end
end

function ObjectSpawner:TakeOwnership(obj)
    table.insert(self.objects, obj)
    if self.onnewobjectfn ~= nil then
        self.onnewobjectfn(self.inst, obj)
    end
end

function ObjectSpawner:SpawnObject(obj, linked_skinname, skin_id)
    obj = SpawnPrefab(obj, linked_skinname, skin_id)
    self:TakeOwnership(obj)
    return obj
end

return ObjectSpawner
