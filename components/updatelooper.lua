--V2C: component for adding generic onupdate loops to entities
--     since we found out that DoPeriodicTask(0) doesn't trigger precisely every frame

local _PostUpdates = {}

local UpdateLooper = Class(function(self, inst)
    self.inst = inst
    self.onupdatefns = {}
    self.longupdatefns = {}
	self.onwallupdatefns = {}
	self.postupdatefns = {}
end)

function UpdateLooper:OnRemoveFromEntity()
    self.inst:StopUpdatingComponent(self)
    self.inst:StopWallUpdatingComponent(self)
	_PostUpdates[self.inst] = nil
end

function UpdateLooper:OnRemoveEntity()
	_PostUpdates[self.inst] = nil
end

function UpdateLooper:AddOnUpdateFn(fn)
    if #self.onupdatefns <= 0 then
        self.inst:StartUpdatingComponent(self)
    end
    table.insert(self.onupdatefns, fn)
end

function UpdateLooper:RemoveOnUpdateFn(fn)
	if #self.onupdatefns > 0 then
		if not self.OnUpdatesToRemove then
			self.OnUpdatesToRemove = {}
		end
		table.insert(self.OnUpdatesToRemove,fn)
	end
end

function UpdateLooper:AddLongUpdateFn(fn)
    table.insert(self.longupdatefns, fn)
end

function UpdateLooper:RemoveLongUpdateFn(fn)
	if #self.longupdatefns > 0 then
		if not self.OnLongUpdatesToRemove then
			self.OnLongUpdatesToRemove = {}
		end
		table.insert(self.OnLongUpdatesToRemove,fn)
	end
end

function UpdateLooper:OnUpdate(dt)
    if self.OnUpdatesToRemove then
        for i = 1, #self.OnUpdatesToRemove do
            local fn = self.OnUpdatesToRemove[i]
            table.removearrayvalue(self.onupdatefns, fn)
        end
        if #self.onupdatefns <= 0 then
            self.inst:StopUpdatingComponent(self)
        end
        self.OnUpdatesToRemove = nil
    end

	for i = #self.onupdatefns, 1, -1 do
        self.onupdatefns[i](self.inst, dt)
    end
end

function UpdateLooper:LongUpdate(dt)
    if self.OnLongUpdatesToRemove then
        for i = 1, #self.OnLongUpdatesToRemove do
            local fn = self.OnLongUpdatesToRemove[i]
            table.removearrayvalue(self.longupdatefns, fn)
        end
        self.OnLongUpdatesToRemove = nil
    end

	for i = #self.longupdatefns, 1, -1 do
        self.longupdatefns[i](self.inst, dt)
    end
end

function UpdateLooper:AddOnWallUpdateFn(fn)
    if #self.onwallupdatefns <= 0 then
	    self.inst:StartWallUpdatingComponent(self)
    end
    table.insert(self.onwallupdatefns, fn)
end

function UpdateLooper:RemoveOnWallUpdateFn(fn)
	if #self.onwallupdatefns > 0 then
		if not self.OnWallUpdatesToRemove then
			self.OnWallUpdatesToRemove = {}
		end
		table.insert(self.OnWallUpdatesToRemove, fn)
	end
end

function UpdateLooper:OnWallUpdate(dt)
    if TheNet:IsServerPaused() then return end

    if self.OnWallUpdatesToRemove then
        for i = 1, #self.OnWallUpdatesToRemove do
            local fn = self.OnWallUpdatesToRemove[i]
            table.removearrayvalue(self.onwallupdatefns, fn)
        end
        if #self.onwallupdatefns <= 0 then
            self.inst:StopWallUpdatingComponent(self)
        end
        self.OnWallUpdatesToRemove = nil
    end

	for i = 1, #self.onwallupdatefns do
        self.onwallupdatefns[i](self.inst, dt)
    end
end

--------------------------------------------------------------------------
--#V2C: quick and dirty post update implementation for now.
--      not safe to add remove fns during UpdateLooper_PostUpdate.

function UpdateLooper:AddPostUpdateFn(fn)
	if #self.postupdatefns <= 0 then
		_PostUpdates[self.inst] = self.postupdatefns
	end
	table.insert(self.postupdatefns, fn)
end

function UpdateLooper:RemovePostUpdateFn(fn)
	table.removearrayvalue(self.postupdatefns, fn)
	if #self.postupdatefns <= 0 then
		_PostUpdates[self.inst] = nil
	end
end

function UpdateLooper_PostUpdate()
	for inst, fns in pairs(_PostUpdates) do
		for _, fn in ipairs(fns) do
			fn(inst)
		end
	end
end

--------------------------------------------------------------------------

return UpdateLooper
