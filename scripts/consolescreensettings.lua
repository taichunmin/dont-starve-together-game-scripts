local MAX_SAVED_COMMANDS = 20

ConsoleScreenSettings = Class(function(self)
    self.persistdata = {}
	self.profanityservers = {}

    self.dirty = true
end)

function ConsoleScreenSettings:Reset()
    self.persistdata = {}
	self.dirty = true
	self:Save()
end

function ConsoleScreenSettings:GetConsoleHistory()
	return self.persistdata["historylines"] or {}
end

function ConsoleScreenSettings:AddLastExecutedCommand(command_str, toggle_remote_execute)
	--trim whitespace
	command_str = command_str:gsub("^%s*(.-)%s*$", "%1")

	if #command_str <= 0 or command_str == "c_repeatlastcommand()" then
		--Don't record history for c_repeatlastcommand() or empty strings
		return
	end

	toggle_remote_execute = toggle_remote_execute == true or nil

	local history = self.persistdata["historylines"]
	if history == nil then
		history = {}
		self.persistdata["historylines"] = history
	else
		for i = #history, 1, -1 do
			local v = history[i]
			if v.str == command_str then
				if v.remote ~= toggle_remote_execute then
					v.remote = toggle_remote_execute
					self.dirty = true
				end
				if i ~= #history then
					table.remove(history, i)
					table.insert(history, v)
					self.dirty = true
				end
				--duplicate found and shifted to the bottom
				return
			end
		end

		while #history >= MAX_SAVED_COMMANDS do
			table.remove(history, 1)
		end
	end

	table.insert(history, { str = command_str, remote = toggle_remote_execute })
	self.dirty = true
end

function ConsoleScreenSettings:IsWordPredictionWidgetExpanded()
	return self.persistdata["expanded"] or false
end

function ConsoleScreenSettings:SetWordPredictionWidgetExpanded(value)
	self.persistdata["expanded"] = value
	self.dirty = true
end

----------------------------

function ConsoleScreenSettings:GetSaveName()
    return BRANCH ~= "dev" and "consolescreen" or ("consolescreen_"..BRANCH)
end

function ConsoleScreenSettings:Save(callback)
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

function ConsoleScreenSettings:Load(callback)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str)
        	-- Can ignore the successfulness cause we check the string
			self:OnLoad( str, callback )
        end, false)
end

function ConsoleScreenSettings:OnLoad(str, callback)
	if str == nil or string.len(str) == 0 then
		print ("ConsoleScreenSettings could not load ".. self:GetSaveName())
		if callback then
			callback(false)
		end
	else
		print ("ConsoleScreenSettings loaded ".. self:GetSaveName(), #str)

		self.persistdata = TrackedAssert("TheSim:GetPersistentString ConsoleScreenSettings",  json.decode, str)
		self.dirty = false

		--V2C: #CONSOLE_HISTORY_REFACTOR convert old savedata
		if self.persistdata["history"] then
			self.persistdata["historylines"] = {}
			for i, v in ipairs(self.persistdata["history"]) do
				v = v:gsub("^%s*(.-)%s*$", "%1")
				if #v > 0 then
					table.insert(self.persistdata["historylines"], { str = v, remote = self.persistdata["localremotehistory"][i] or nil })
				end
			end
			self.persistdata["history"] = nil
			self.persistdata["localremotehistory"] = nil
			self.dirty = true
		end
	end
end
