--NOTE: This is a client side component. No server
--      logic should be driven off this component!

local FocalPoint = Class(function(self, inst)
    self.inst = inst
    self.targets = {}
    self._onsourceremoved = function(source) self:StopFocusSource(source) end
	self.current_focus = nil
end)

function FocalPoint:Reset(no_snap)
	self.current_focus = nil
    TheCamera:SetDefault()
	if not no_snap then
	    TheCamera:Snap()
	end
end
-- TheFocalPoint.components.focalpoint:StartFocusSource(c_sel(), "large", nil, 5, 12, 4)
-- TheFocalPoint.components.focalpoint:StartFocusSource(c_sel(), "small", nil, 999, 999, 3)
-- TheFocalPoint.components.focalpoint:StopFocusSource(c_sel(), "large")

function FocalPoint:StartFocusSource(source, id, target, minrange, maxrange, priority, updater)
    id = id or "_default_"
    local sourcetbl = self.targets[source]
    if sourcetbl == nil then
        self.targets[source] = { [id] = { target = target or source, source = source, id = id, minrange = minrange, maxrange = maxrange, priority = priority, updater = updater } }
        self.inst:ListenForEvent("onremove", self._onsourceremoved, source)
    else
        local params = sourcetbl[id]
        if params == nil then
            sourcetbl[id] = { target = target or source, source = source, id = id, minrange = minrange, maxrange = maxrange, priority = priority, updater = updater }
        else
            params.target = target or source
			params.source = source
            params.id = id
            params.minrange = minrange
            params.maxrange = maxrange
            params.priority = priority
			params.updater = updater
        end
    end
	self:CameraUpdate(0)
end

function FocalPoint:StopFocusSource(source, id)
    local sourcetbl = self.targets[source]
    if sourcetbl ~= nil then
        if id ~= nil then
            sourcetbl[id] = nil
            if next(sourcetbl) == nil then
                self.targets[source] = nil
                self.inst:RemoveEventCallback("onremove", self._onsourceremoved, source)
            end
        else
            self.targets[source] = nil
            self.inst:RemoveEventCallback("onremove", self._onsourceremoved, source)
        end
    end

	if self.current_focus ~= nil and self.current_focus.source == source and (id == nil or self.current_focus.id == id) then
		self:Reset(true)
	end
end

function FocalPoint:RemoveAllFocusSources(no_snap)
	for source, sourcetbl in pairs(self.targets) do
		for id, params in pairs(sourcetbl) do
			self:StopFocusSource(source, id)
		end
	end
	self:Reset(no_snap)
end

-- deprecated, kept for backward compatibility
function FocalPoint:PushTempFocus(target, minrange, maxrange, priority)
	print("PushTempFocus is deprecated")
end

local function UpdateFocus(dt, params, parent, dist_sq)
    local tpos = params.target:GetPosition()
    local ppos = parent:GetPosition()

    local offs = tpos - ppos
    if dist_sq > params.minrange * params.minrange then
		local range = params.maxrange - params.minrange
        offs = offs * (range ~= 0 and ((params.maxrange - math.sqrt(dist_sq)) / range))
    end
    offs.y = offs.y + 1.5
    TheCamera:SetOffset(offs)
end

function FocalPoint:CameraUpdate(dt)
    local parent = self.inst.entity:GetParent()
	if parent ~= nil and next(self.targets) ~= nil then
		local best_focus = nil
		local best_dist_sq = math.huge
		local best_priority = -math.huge

		local toremove = {}
		for source, sourcetbl in pairs(self.targets) do
			for id, params in pairs(sourcetbl) do
				if params.target ~= nil and params.target:IsValid() then
					local dist_sq = distsq(params.target:GetPosition(), parent:GetPosition())
				    if dist_sq <= (params.maxrange * params.maxrange) and (params.updater == nil or params.updater.IsEnabled == nil or params.updater.IsEnabled(parent, params, source)) and (params.priority > best_priority or (params.priority == best_priority and dist_sq < best_dist_sq)) then
						best_focus = params
						best_dist_sq = dist_sq
						best_priority = params.priority
					end
				else
					table.insert(toremove, { source, id })
				end
			end
		end
		for i, v in ipairs(toremove) do
			self:StopFocusSource(unpack(toremove))
		end

		if best_focus ~= nil then
			if self.current_focus ~= best_focus then
				if self.current_focus ~= nil then
					self:StopFocusSource(self.current_focus.source, self.current_focus.id)
				end
				self.current_focus = best_focus
				if best_focus.updater ~= nil and best_focus.updater.ActiveFn ~= nil then
					best_focus.updater.ActiveFn(best_focus, parent, best_dist_sq)
				end
			end
			local fn = best_focus.updater and best_focus.updater.UpdateFn or UpdateFocus
			fn(dt, best_focus, parent, best_dist_sq)
		else
			self:Reset(true)
		end
	elseif self.current_focus ~= nil then
		self:Reset(true)
	end
end

function FocalPoint:GetDebugString()
	local str = string.format("Offset: %0.2f, %0.2f, %0.2f", TheCamera.targetoffset.x, TheCamera.targetoffset.y, TheCamera.targetoffset.z)
	str = str .. "\n" .. string.format("Gains: %0.2f, %0.2f, %0.2f", TheCamera:GetGains())
	str = str .. "\nCurrent Focus: " .. (self.current_focus == nil and "none" or (tostring(self.current_focus.target) .. ", " .. tostring(self.current_focus.id)))
	for source, sourcetbl in pairs(self.targets) do
		for id, params in pairs(sourcetbl) do
			str = str .. "\nID: " .. tostring(id) .. ", Priority: " .. tostring(params.priority) .. ", Source: " .. tostring(source) .. ", Target: " .. tostring(params.target) .. ", Range: " .. tostring(params.maxrange)
		end
	end
	return str
end

return FocalPoint
