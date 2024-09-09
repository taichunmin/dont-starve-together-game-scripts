require "dumper"

local DEV_MODE = BRANCH == "dev"

-- Base class for handling save data to external files
local SaveData = Class(function(self, filename)
	assert(filename ~= nil and filename:len() > 0)
	self.filename = filename
	if DEV_MODE then
		self.filename = self.filename.."_"..string.lower(BRANCH)
	end
	self.persistdata = {}
	self.dirty = true
end)

function SaveData:SetValue(name, value)
	--Currently not bothering with deepcompare
	if self.persistdata[name] ~= value then
		self.persistdata[name] = value
		self.dirty = true
	end
end

function SaveData:GetValue(name)
	return self.persistdata[name]
end

function SaveData:Save(cb)
	if self.dirty then
		print("Saving: /"..self.filename.."...")
		local PRETTY_PRINT = false --DEV_MODE
		local data = DataDumper(self.persistdata, nil, not PRETTY_PRINT)
		TheSim:SetPersistentString(self.filename, data, ENCODE_SAVES, function(success)
			if success then
				print("Successfuly saved: /"..self.filename)
				self.dirty = false
			else
				print("Failed to save: /"..self.filename)
				dbassert(false)
			end
			if cb ~= nil then
				cb(success)
			end
		end)
	else
		print("Skipping save: /"..self.filename)
		if cb ~= nil then
			cb(true) --success = true
		end
	end
end

function SaveData:Load(cb)
	print("Loading: /"..self.filename.."...")
	TheSim:GetPersistentString(self.filename, function(success, data)
		if success and string.len(data) > 0 then
			success, data = RunInSandbox(data)
			if success and data ~= nil then
				self.persistdata = data
				self.dirty = false
				print("Successfully loaded: /"..self.filename)
				if cb ~= nil then
					cb(true) --success = true
				end
				return
			end
		end
		print("Failed to load: /"..self.filename)
		if cb ~= nil then
			cb(false) --success = false
		end
	end)
end

function SaveData:Reset()
	if next(self.persistdata) ~= nil then
		self.persistdata = {}
		self.dirty = true
	end
end

function SaveData:Erase(cb)
	self:Reset()
	print("Deleting: /"..self.filename.."...")
	TheSim:CheckPersistentStringExists(self.filename, function(exists)
		if exists then
			TheSim:ErasePersistentString(self.filename, function(success)
				if success then
					print("Successfully deleted: /"..self.filename)
					self.dirty = true
				else
					print("failed to delete: /"..self.filename)
					dbassert(false)
				end
				if cb ~= nil then
					cb(success)
				end
			end)
		else
			print("File not found: /"..self.filename)
			dbassert(self.dirty)
			if cb ~= nil then
				cb(true)
			end
		end
	end)
end

return SaveData
