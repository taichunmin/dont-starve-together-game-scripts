


local PositionalWarp = Class(function(self, inst)
    self.inst = inst

	self.showmarker = false
	self.markers = {}
	self.cur_marker = 0
	self.marker_cache_size = 3 -- recycle the entites instead of creating new ones all the time

	self.history_x = {}
	self.history_y = {} -- 3d because mods
	self.history_z = {}
	self.history_rollback_dist = 1
	self.history_max = 60
	self.history_cur = 0	-- this is a 0-based index, this is to make the math easier, but always add +1 when accessing the table's data
	self.history_back = 0	-- this is a 0-based index, this is to make the math easier, but always add +1 when accessing the table's data

	self.update_dist_sq = 2*2
	self.updatetask = inst:DoPeriodicTask(0.1, function() self:CachePosition() end)

	self.inittask = inst:DoTaskInTime(0, function() if self.inittask ~= nil then self.inittask:Cancel() self.inittask = nil end self:Reset() end)

	for i = 1, self.history_max do
		table.insert(self.history_x, 0)
		table.insert(self.history_y, 0)
		table.insert(self.history_z, 0)
	end

end)

function PositionalWarp:OnRemoveFromEntity()
	if self.updatetask ~= nil then
		self.updatetask:Cancel()
		self.updatetask = nil
	end

	for _, v in ipairs(self.markers) do
		v:Remove()
	end
	self.markers = {}
end

function PositionalWarp:OnRemoveEntity()
	for _, v in ipairs(self.markers) do
		v:Remove()
	end
	self.markers = {}
end

function PositionalWarp:_MakeMarker(i, prefab)
	if self.markers[i] ~= nil and self.markers[i]:IsValid() then
		self.markers[i]:Remove()
	end
	self.markers[i] = SpawnPrefab(prefab)
	if self.markers[i].SetMarkerViewer ~= nil then
		self.markers[i]:SetMarkerViewer(self.inst)
	end
	self.markers[i]:ListenForEvent("onremove", function() self.markers[i] = nil self:_MakeMarker(i, prefab) end)
end

function PositionalWarp:SetMarker(prefab)
	for i = 1, self.marker_cache_size do
		self:_MakeMarker(i, prefab)
	end

	self:UpdateMarker()
end

function PositionalWarp:SetWarpBackDist(num_cache_points)
	self.history_rollback_dist = num_cache_points
	self:UpdateMarker()
end

function PositionalWarp:UpdateMarker()
	if self.markers[1] ~= nil then
		local x, y, z = self:GetHistoryPosition(false)
		if x == nil or not self.showmarker then
			for _, v in ipairs(self.markers) do
				v:HideMarker()
			end
		else
			local marker = self.markers[self.cur_marker + 1]
			local _x, _y, _z = marker.Transform:GetWorldPosition()
			if not marker.inuse or VecUtil_DistSq(x, z, _x, _z) > 0.01 then
				marker:HideMarker()

				self.cur_marker = (self.cur_marker + 1) % self.marker_cache_size
				marker = self.markers[self.cur_marker + 1]

				marker.Transform:SetPosition(x, y, z)
				marker:ShowMarker()
			end
		end
	end
end

function PositionalWarp:CachePosition()
	if self.inst.sg == nil or self.inst.sg:HasStateTag("jumping") then
		return
	end

	local x, y, z = self.inst.Transform:GetWorldPosition()
	local recent_x, recent_y, recent_z = self.history_x[self.history_cur + 1], self.history_y[self.history_cur + 1], self.history_z[self.history_cur + 1]

	if Vec3Util_DistSq(x, y, z, recent_x, recent_y, recent_z) > self.update_dist_sq then
		self.history_cur = (self.history_cur + 1) % self.history_max
		if self.history_cur == self.history_back then
			self.history_back = (self.history_back + 1) % self.history_max
		end
		self.history_x[self.history_cur + 1] = x
		self.history_y[self.history_cur + 1] = y
		self.history_z[self.history_cur + 1] = z

		self:UpdateMarker()
	end
end

function PositionalWarp:GetHistoryPosition(rewind)
	if self.history_cur == self.history_back then
		return nil
	end

	local cur = self.history_cur
	for i = 1, self.history_rollback_dist do
		if cur == self.history_back then
			break
		end
		cur = (cur - 1) % self.history_max
	end

	if rewind then
		self.history_cur = cur
		self:UpdateMarker()
	end

	return self.history_x[cur + 1], self.history_y[cur + 1], self.history_z[cur + 1]
end

function PositionalWarp:Reset()
	self.history_x[1], self.history_y[1], self.history_z[1] = self.inst.Transform:GetWorldPosition() 
	self.history_cur = 0
	self.history_back = 0
	self:UpdateMarker()
end

function PositionalWarp:EnableMarker(enable)
	self.showmarker = enable
	self:UpdateMarker()
end

function PositionalWarp:OnSave()
	return {
		history_x = self.history_x,
		history_y = self.history_y,
		history_z = self.history_z,
		cur = self.history_cur,
		back = self.history_back,
	}
end

function PositionalWarp:OnLoad(data)
	if data ~= nil and self.inst.migration == nil then -- dont save/load across servers
		self.history_x = data.history_x or self.history_x
		self.history_y = data.history_y or self.history_y
		self.history_z = data.history_z or self.history_z
		self.history_cur = data.cur or self.history_cur
		self.history_back = data.back or self.history_back

		if self.inittask ~= nil and self.history_cur ~= nil and self.history_back ~= nil then
			self.inittask:Cancel() 
			self.inittask = nil
		end
	end
end

function PositionalWarp:GetDebugString()
	return "history size: " .. tostring(self.history_cur == self.history_back and 0 or (self.history_cur > self.history_back and (self.history_cur) or (self.history_cur + self.history_max)) - self.history_back)
end

return PositionalWarp