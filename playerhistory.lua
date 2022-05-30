
local SECONDS_PER_DAY = 60*60*24

PlayerHistory = Class(function(self)
	self.seen_players = {}
	self.seen_players_updatetime = {}

    self.task = nil
    self.dirty = false

	self.target_max_entries = 100
end)

function PlayerHistory:StartListening()
    if self.task == nil then
        self.task = TheWorld:DoPeriodicTask(60, function() self:UpdateHistoryFromClientTable() end)
    end
end

function PlayerHistory:Reset()
	self.seen_players = {}
	self.seen_players_updatetime = {}

    self.dirty = true
    self:Save()
end

function PlayerHistory:DiscardOldData()
    local current_date = os.time()

	-- delete entries that are really old
	for k, v in pairs(self.seen_players) do
		local delta_time = os.difftime(current_date, v.last_seen_date)
		if delta_time > USER_HISTORY_EXPIRY_TIME then
			self.seen_players[k] = nil
		    self.dirty = true
		end
	end

	-- if there are still too many entries the get rid of some
	if GetTableSize(self.seen_players) > self.target_max_entries then
		local ordered = self:GetRows()
		for i = self.target_max_entries + 1, #ordered do
			self.seen_players[ordered[i].userid] = nil
		    self.dirty = true
		end
	end
end

function PlayerHistory:UpdateHistoryFromClientTable()
    local ClientObjs = TheNet:GetClientTable()
    if ClientObjs ~= nil and #ClientObjs > 0 then
        local my_userid = TheNet:GetUserID()
        local server_name = TheNet:GetServerName()
		local is_client_hosted = TheNet:GetServerIsClientHosted()
        local current_time = os.time()

        for i, v in ipairs(ClientObjs) do
            if v.userid ~= my_userid and (is_client_hosted or v.performance == nil) then -- Skip yourself and dedicated server host
				if self.seen_players[v.userid] == nil then
					self.seen_players[v.userid] =
					{
						userid = v.userid,
						netid = v.netid,
						time_played_with = 0,
					}
				end

				local stats = self.seen_players[v.userid]

				if self.seen_players_updatetime[v.userid] ~= nil then
					local dt = current_time - self.seen_players_updatetime[v.userid]
					stats.time_played_with = stats.time_played_with + dt
				end

				stats.name = v.name
				stats.server_name = server_name
				stats.prefab = v.prefab
				stats.last_seen_date = current_time

				self.seen_players_updatetime[v.userid] = current_time

                self.dirty = true
            end
        end

		-- removed last update time for players who have left the world
		for k, v in pairs(self.seen_players_updatetime) do
			if v ~= current_time then
				self.seen_players_updatetime[k] = nil
			end
		end

        self:Save()
    end
end

function PlayerHistory:GetRows() -- sort by last seen
	local history = {}
	for k, v in pairs(self.seen_players) do
		local data = deepcopy(v)
		table.insert(history, data)
	end
	table.sort(history, function(a, b)
		if (a.last_seen_date or 0) > (b.last_seen_date or 0) then
			return true
		elseif (a.last_seen_date or 0) < (b.last_seen_date or 0) then
			return false
		end

		if (a.time_played_with or 0) > (b.time_played_with or 0) then
			return true
		elseif (a.time_played_with or 0) < (b.time_played_with or 0) then
			return false
		end

		return a.name < b.name
	end)
	return history
end

function PlayerHistory:GetRowsMostTime()
	local history = {}
	for k, v in pairs(self.seen_players) do
		local data = deepcopy(v)
		table.insert(history, data)
	end
	table.sort(history, function(a, b)
		if (a.time_played_with or 0) > (b.time_played_with or 0) then
			return true
		elseif (a.time_played_with or 0) < (b.time_played_with or 0) then
			return false
		end

		if (a.last_seen_date or 0) > (b.last_seen_date or 0) then
			return true
		elseif (a.last_seen_date or 0) < (b.last_seen_date or 0) then
			return false
		end
		return a.name < b.name
	end)
	return history
end

function PlayerHistory:RemoveUser(userid)
	self.seen_players[userid] = nil
	self.dirty = true
	self:Save()
end


function PlayerHistory:SortBackwards(field)
	print("Warning: PlayerHistory:SortBackwards in playerhistory.lua is deprecated.")
end

function PlayerHistory:GetSaveName()
    return BRANCH == "release" and "player_history" or ("player_history_"..BRANCH)
end

function PlayerHistory:Save(callback)
    if self.dirty then
        local str = json.encode({version = 2, seen_players = self.seen_players})
        local insz, outsz = SavePersistentString(self:GetSaveName(), str, ENCODE_SAVES, callback)
	end
end

function PlayerHistory:LoadDataVersion1(data)
	self.seen_players = {}
	for k, v in pairs(data) do
		local last_seen_date = os.time({year = tonumber(string.sub(v.sort_date, 1, 4)), month = tonumber(string.sub(v.sort_date, 5, 6)), day = tonumber(string.sub(v.sort_date, 7, 8))})
		if self.seen_players[v.userid] == nil then
			self.seen_players[v.userid] =
			{
				userid = v.userid,
				netid = v.netid,
				name = v.name,
				time_played_with = 0,
				prefab = v.prefab,
				server_name = v.server_name,
				last_seen_date = last_seen_date,
			}
		elseif last_seen_date > self.seen_players[v.userid].last_seen_date then
			self.seen_players[v.userid].last_seen_date = last_seen_date
			self.seen_players[v.userid].name = v.name
			self.seen_players[v.userid].server_name = v.server_name
			self.seen_players[v.userid].prefab = v.prefab
		end
	end
end

function PlayerHistory:Load(callback)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str)
			local success = false
		    if str == nil or string.len(str) == 0 then
				print("PlayerHistory could not load "..self:GetSaveName())
			else
				local status, data = pcall( function() return json.decode(str) end )
				if status and data then
					print("PlayerHistory loaded " .. self:GetSaveName() .. " (v" .. tostring(data.version or 1) .. ") len:" .. tostring(#str))
					if data.version == nil then
						self:LoadDataVersion1(data)
					elseif data.version == 2 then
						self.seen_players = data.seen_players
					end
					self:DiscardOldData()

					self.dirty = false
					success = true
				else
					print("PlayerHistory failed to decode json "..self:GetSaveName(), #str)
				end
			end

			if callback ~= nil then
				callback(success)
			end
        end, false)
end

