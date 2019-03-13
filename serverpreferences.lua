ServerPreferences = Class(function(self)
    self.persistdata = {} 

    self.dirty = true
end)

function ServerPreferences:Reset()
    self.persistdata = {}
	self.dirty = true
	self:Save()
end

local function MakeServerID(server_data)
	if server_data == nil then
		server_data = {name = TheNet:GetServerName()}
	elseif type(server_data) == "string" then
		server_data = {name = server_data}
	end

	return "ID_"..tostring(smallhash(tostring(server_data.name)))
end

function ServerPreferences:ToggleNameAndDescriptionFilter(server_data)
	local server_id = MakeServerID(server_data)
	local hide = self.persistdata[server_id] == nil or not self.persistdata[server_id].hidename
	if hide then
		if self.persistdata[server_id] == nil then
			self.persistdata[server_id] = {}
			self.persistdata[server_id].lastseen = os.time()
		end

		self.persistdata[server_id].hidename = true
		self.dirty = true
	else
		if self.persistdata[server_id] ~= nil and self.persistdata[server_id].hidename then
			self.persistdata[server_id].hidename = nil

			if GetTableSize(self.persistdata[server_id].hidename) <= 1 then -- 1 for lastseen
				self.persistdata[server_id] = nil
			end

			self.dirty = true
		end
	end

	self:Save()
end

function ServerPreferences:IsNameAndDescriptionHidden(server_data)
	local server_id = MakeServerID(server_data)
	return self.persistdata[server_id] ~= nil and self.persistdata[server_id].hidename
end

function ServerPreferences:RefreshLastSeen(server_list)

	local time = os.time()
	local dirty = false
	for _, server in ipairs(server_list) do
		local server_id = MakeServerID(server)
		if self.persistdata[server_id] ~= nil and os.difftime(time, self.persistdata[server_id].lastseen) > 60*5 then
			self.persistdata[server_id].lastseen = time
			dirty = true
		end
	end

	self:Save()
end

----------------------------

function ServerPreferences:GetSaveName()
    return BRANCH ~= "dev" and "server_preferences" or ("server_preferences_"..BRANCH)
end

function ServerPreferences:Save(callback)
	local current_time = os.time()
	for k, v in pairs(self.persistdata) do
		local delta_time = os.difftime(current_time, v.lastseen)
		if delta_time > USER_HISTORY_EXPIRY_TIME then
			self.persistdata[k] = nil
			self.dirty = true
		end
	end

    if self.dirty then
		self.dirty = false

        local str = json.encode(self.persistdata)
        local insz, outsz = SavePersistentString(self:GetSaveName(), str, ENCODE_SAVES, callback)
    else
		if callback then
			callback(true)
		end
    end
end

function ServerPreferences:Load(callback)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str) 
        	-- Can ignore the successfulness cause we check the string
			self:OnLoad( str, callback )
        end, false)    
end

function ServerPreferences:OnLoad(str, callback)
	if str == nil or string.len(str) == 0 then
		print ("ServerPreferences could not load ".. self:GetSaveName())
		if callback then
			callback(false)
		end
	else
		print ("ServerPreferences loaded ".. self:GetSaveName(), #str)

		self.persistdata = TrackedAssert("TheSim:GetPersistentString ServerPreferences",  json.decode, str)

		self.dirty = false
		self:Save()
		if callback then
			callback(true)
		end
	end
end
