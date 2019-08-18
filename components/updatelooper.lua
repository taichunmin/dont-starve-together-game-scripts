--V2C: component for adding generic onupdate loops to entities
--     since we found out that DoPeriodicTask(0) doesn't trigger precisely every frame

local UpdateLooper = Class(function(self, inst)
    self.inst = inst
    self.onupdatefns = {}
    self.longupdatefns = {}
end)

function UpdateLooper:OnRemoveFromEntity()
    self.inst:StopUpdatingComponent(self)
end

function UpdateLooper:AddOnUpdateFn(fn)
    if #self.onupdatefns <= 0 then
        self.inst:StartUpdatingComponent(self)
    end
    table.insert(self.onupdatefns, fn)
end

function UpdateLooper:RemoveOnUpdateFn(fn)
    table.removearrayvalue(self.onupdatefns, fn)
    if #self.onupdatefns <= 0 then
        self.inst:StopUpdatingComponent(self)
    end
end

function UpdateLooper:AddLongUpdateFn(fn)
    table.insert(self.longupdatefns, fn)
end

function UpdateLooper:RemoveLongUpdateFn(fn)
    table.removearrayvalue(self.longupdatefns, fn)
end

function UpdateLooper:OnUpdate(dt)
    for i, v in ipairs(self.onupdatefns) do
        v(self.inst, dt)
    end
end

function UpdateLooper:LongUpdate(dt)
    for i, v in ipairs(self.longupdatefns) do
        v(self.inst, dt)
    end
end

return UpdateLooper
