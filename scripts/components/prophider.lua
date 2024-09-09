local PropHider = Class(function(self, inst)
    self.inst = inst

    self.hideupdate_duration = 6
    self.hideupdate_variance = 1

    --self.propcreationfn = nil
    --self.onvisiblefn = nil
    --self.willunhidefn = nil
    --self.onunhidefn = nil
    --self.onhidefn = nil

    --self.prop = nil
    --self.counter = nil
end)

function PropHider:SetPropCreationFn(fn)
    self.propcreationfn = fn
end

function PropHider:SetOnVisibleFn(fn)
    self.onvisiblefn = fn
end

function PropHider:SetWillUnhideFn(fn)
    self.willunhidefn = fn
end

function PropHider:SetOnUnhideFn(fn)
    self.onunhidefn = fn
end

function PropHider:SetOnHideFn(fn)
    self.onhidefn = fn
end

function PropHider:GenerateHideTime()
    return self.hideupdate_duration + self.hideupdate_variance * (math.random() * 2 - 1)
end

function PropHider:ClearHideTask()
    if self.hide_task ~= nil then
        self.hide_task:Cancel()
        self.hide_task = nil
    end
end

local function WillUnhide_Bridge(inst, self)
	self.hide_task = nil

    if self.willunhidefn then
		local target = self.willunhidefn(self.inst)
		if target ~= nil then
            self:ShowFromProp()
            if self.onunhidefn then
				self.onunhidefn(self.inst, target)
            end
            return
        end
    end

	if self.counter > 1 then
		self.counter = self.counter - 1
	else
		self:ShowFromProp()
		--V2C: Not calling onunhidefn?
		--     Just because we don't have a "target"?
		--     Not the best, but leaving it for now to match original code.
		--     * The TRAP is that when authoring prefabs, likely to assume
		--     onunhide gets triggered in all cases.
		return
	end

	--Reschedule
	self.hide_task = self.inst:DoTaskInTime(self:GenerateHideTime(), WillUnhide_Bridge, self)
end

function PropHider:HideWithProp(duration, counter)
    if self.hiding then
        return
    end
    self.hiding = true
	self.counter = counter or 10

    if duration == nil then
        duration = self:GenerateHideTime()
    end

    self.inst:RemoveFromScene()

    self:ClearHideTask()
	self.hide_task = self.inst:DoTaskInTime(duration, WillUnhide_Bridge, self)

    if self.prop then
        if self.prop:IsValid() then
            self.prop:Remove()
        end
        self.prop = nil
    end

    if self.propcreationfn then
        local prop = self.propcreationfn(self.inst)
        if prop then
            self.prop = prop
            prop.persists = false -- Do not save props always generate them.
        end
    end

    if self.onhidefn then
        self.onhidefn(self.inst)
    end
end

function PropHider:ShowFromProp()
    if not self.hiding then
        return
    end
    self.hiding = nil
	self.counter = nil
    self:ClearHideTask()

    self.inst:ReturnToScene()

    if self.onvisiblefn then
        self.onvisiblefn(self.inst)
    end

    if self.prop and self.prop:IsValid() then
		self.prop:PushEvent("propreveal", self.inst)
    end
    self.prop = nil
end

PropHider.OnRemoveFromEntity =	PropHider.ClearHideTask
PropHider.OnEntitySleep =		PropHider.ClearHideTask

function PropHider:OnEntityWake()
	if self.hiding and self.hide_task == nil then
		self.hide_task = self.inst:DoTaskInTime(self:GenerateHideTime(), WillUnhide_Bridge, self)
	end
end

function PropHider:OnSave()
	return self.hiding and {
		hiding = true,
		counter = self.counter,
	} or nil
end

function PropHider:OnLoad(data)
	--"hidetime" backward compatibility save data
	if data ~= nil and (data.hiding or data.hidetime ~= nil) then
		self:HideWithProp(nil, data.counter)
    end
end

function PropHider:GetDebugString()
    return string.format("Counters: %d, Time for counter: %.1f", self.counter or 0, self.hide_task and GetTaskRemaining(self.hide_task) or 0)
end

return PropHider
