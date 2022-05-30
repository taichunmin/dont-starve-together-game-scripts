
local HideAndSeekHider = Class(function(self, inst)
    self.inst = inst

	self.last_day_played = -1

	self.gohide_timeout = 3
    --self.OnHide = nil
end)

function HideAndSeekHider:IsPlaying()
	return self.hiding_spot ~= nil
end

function HideAndSeekHider:IsHidden()
	return self.hiding_spot ~= nil and inst.runtohidingspot_task == nil
end

HideAndSeekHider._OnGoHideTimout = function(inst)
	local self = inst.components.hideandseekhider

	if inst.runtohidingspot_task ~= nil then
		inst.runtohidingspot_task:Cancel()
		inst.runtohidingspot_task = nil
	end

	if self.hiding_spot ~= nil and self.hiding_spot:IsValid() then
        if self.OnHide ~= nil then
            self.OnHide(inst, self.hiding_spot)
        end
		self.hiding_spot.components.hideandseekhidingspot:HideInSpot(inst)
	else
		self:Found(nil)
	end
end

function HideAndSeekHider:GoHide(hiding_spot, timeout_time, isloading)
	if self.hiding_spot == nil and (hiding_spot.components.hideandseekhidingspot == nil or isloading) then
		self.last_day_played = TheWorld.state.cycles

		self.hiding_spot = hiding_spot
		hiding_spot:AddComponent("hideandseekhidingspot")
		hiding_spot.components.hideandseekhidingspot:SetHider(self.inst)

		local instantly_hide = timeout_time == 0
        local real_timeout_time = timeout_time or self.gohide_timeout

		if not instantly_hide then
			self.inst.runtohidingspot_task = self.inst:DoTaskInTime(real_timeout_time, self._OnGoHideTimout)
		end

		if self.StartGoingToHidingSpot ~= nil then
			self.StartGoingToHidingSpot(self.inst, hiding_spot, real_timeout_time)
		end

		if instantly_hide then
			hiding_spot.components.hideandseekhidingspot:HideInSpot(self.inst)
		end

		return true
	end

	return false
end

function HideAndSeekHider:CanPlayHideAndSeek()
	return self.last_day_played < TheWorld.state.cycles
end

function HideAndSeekHider:Found(doer)
	if self.hiding_spot then
		self.hiding_spot = nil

		if self.inst.runtohidingspot_task ~= nil then
			self.inst.runtohidingspot_task:Cancel()
			self.inst.runtohidingspot_task = nil
		end

		if self.OnFound ~= nil then
			self.OnFound(self.inst, doer)
		end
	end
end

function HideAndSeekHider:Abort()
	if self.hiding_spot ~= nil then
		if self.hiding_spot:IsValid() and self.hiding_spot.components.hideandseekhidingspot ~= nil then
			self.hiding_spot.components.hideandseekhidingspot:Abort()
		end

		self:Found(nil)
	end
end

function HideAndSeekHider:OnSave()
	local data = { last_day_played = self.last_day_played }
	local refs = nil

	if self.hiding_spot ~= nil then
		data.hiding_spot = self.hiding_spot.GUID
		refs = { self.hiding_spot.GUID }

		if self.inst.runtohidingspot_task ~= nil then
			data.hiding_timeout = GetTaskRemaining(self.inst.runtohidingspot_task)
		end
	end

	return data, refs
end

function HideAndSeekHider:LoadPostPass(newents, data)
	if data ~= nil then
		if data.last_day_played ~= nil then
			self.last_day_played = data.last_day_played
		end

		local hiding_spot = newents[data.hiding_spot] ~= nil and newents[data.hiding_spot].entity or nil
		if hiding_spot ~= nil then
			if data.hiding_timeout ~= nil then
				self:GoHide(hiding_spot, data.hiding_timeout, true)
			else
				self.hiding_spot = hiding_spot
			end
		end
	end
end

function HideAndSeekHider:GetDebugString()
    return "Hiding Spot: " .. tostring(self.hiding_spot)
end

return HideAndSeekHider
