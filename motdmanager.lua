
local TEMPLATES = require "widgets/redux/templates"

local MAX_RETRIES = 4
local MAX_IMAGE_RETRIES = 1
local CACHE_FILE_NAME = ENCODE_SAVES and "motd_info" or "motd_info_dev"

local MotdManager = Class(function(self)
	self.motd_info = nil
	self.isloading = true
	self.error = false
	self.on_loading_complete_fns = {}
end)

function MotdManager:IsEnabled()
	return IsSteam() or IsRail()
end

function MotdManager:Initialize()
	if MotdManager:IsEnabled() then
		self:LoadCachedMotdInfo()
		self:QueryForMotdInfo(MAX_RETRIES)
	end
end

function MotdManager:IsLoading()
	return self.isloading 
end

function MotdManager:GetMotd()
	return self.motd_info
end

function MotdManager:AddOnLoadingDoneCB(ent, cb_fn)
	ent:ListenForEvent("motd_loading_done", cb_fn, TheGlobalInstance)
end

function MotdManager:SetLoadingDone(motd_info)
	self.motd_info = motd_info
	self.isloading = false
	self.error = motd_info == nil
	print("[MOTD] Done Loading.")
	TheGlobalInstance:PushEvent("motd_loading_done", {success = motd_info == nil})
end

function MotdManager:LoadCachedMotdInfo()
	TheSim:GetPersistentString(CACHE_FILE_NAME, function(load_success, json_info)
		if load_success and string.len(json_info) > 1 then
			local status, motd_info = pcall( function() return json.decode(json_info) end )
			if status and motd_info ~= nil then
				self.motd_info = motd_info
			end
		end
	end)
end


-- for each image, added to images_to_get and mark as 'new' if versions are different
-- 

function MotdManager:DownloadNewMotdImages(motd_info, remaining_retries)
	local images_to_get = {}
	for i = 1, 6 do
		local box_id = "box"..i
		local box = motd_info[box_id][1]
		if box.image ~= "" then
			table.insert(images_to_get, {boxid = box_id, url = box.image, is_new = box.requires_download or false})
		end
	end

--[[	
	for _, box in pairs(images_to_get) do
		motd_info[box.boxid][1].time = 0
		motd_info[box.boxid][1].requires_download = true
	end
	images_to_get = {}
]]

	TheSim:DownloadMOTDImages(images_to_get, function(image_results) 
		local failed_images = 0

		if image_results ~= nil then
			for boxid, valid_image in pairs(image_results) do
				if not valid_image then
					print("[MOTD] Failed to download image: ", boxid, motd_info[boxid][1].image)
					failed_images = failed_images + 1
					motd_info[boxid][1].requires_download = true
				else
					motd_info[boxid][1].requires_download = nil
				end
			end
		end

		if failed_images == 0 or remaining_retries <= 0 then
			if failed_images > 0 then
				print("[MOTD] Failed to download (" .. failed_images .. ") MOTD images. Using default image.")
			end

			if self.motd_info ~= nil and self.motd_info.most_recent_seen ~= nil then
				motd_info.last_seen = self.motd_info.most_recent_seen
			end
			motd_info.most_recent_seen = os.time()

			motd_info.version = nil
			motd_info.version = hash(json.encode(motd_info))

			SavePersistentString(CACHE_FILE_NAME, json.encode(motd_info), ENCODE_SAVES)

			self:SetLoadingDone(motd_info)
		else
			print("[MOTD] Failed to download (" .. failed_images .. ") MOTD images. Remaining retries: " .. tostring(remaining_retries) .. ".")
			TheGlobalInstance:DoTaskInTime(1, function() self:DownloadNewMotdImages(motd_info, remaining_retries - 1) end)
		end
	end )
end

local function fix_web_string(text)
	if type(text) ~= "string" then
		text = tostring(text)
	end
	text = string.gsub(tostring(text), "\\r\\n", "\\n")
	return text
end

function MotdManager:QueryForMotdInfo(remaining_retries)
	local url = TheSim:GetMOTDQueryURL()
	print("[MOTD] Downloading info from", url)

	TheSim:QueryServer( url, function(motd_json, isSuccessful, resultCode) 
		local status, motd_info = "", "" 
		if isSuccessful and string.len(motd_json) > 1 and resultCode == 200 then 
			motd_json = fix_web_string(motd_json)
			status, motd_info = pcall( function() return json.decode(motd_json) end )
			if status and motd_info ~= nil then
				for i = 1, 6 do
					local box_id = "box"..i
					if motd_info[box_id] == nil then
						motd_info[box_id] = {{}}
					end
					local box = motd_info[box_id][1]
					if box == nil then
						motd_info[box_id][1] = {}
						box = motd_info[box_id][1]
					end
					if box.image ~= nil and type(box.image) == "string" and string.match(box.image, ".tex") then
						box.requires_download = self.motd_info == nil or self.motd_info[box_id][1].download_failed or (self.motd_info[box_id][1].time ~= box.time) or (self.motd_info[box_id][1].image ~= box.image)
					else
						box.image = ""
					end
				end
				self:DownloadNewMotdImages(motd_info, MAX_IMAGE_RETRIES)
			else
				isSuccessful = false
			end
		else
			isSuccessful = false
		end

		if not isSuccessful then
			if remaining_retries >= 1 then
				print("[MOTD] Failed To Get MOTD Info from '"..url.."' due to "..(resultCode ~= 200 and tostring(resultCode) or tostring(status))..". Retrying ("..tostring(remaining_retries)..").")
				TheGlobalInstance:DoTaskInTime(2, function() self:QueryForMotdInfo(remaining_retries - 1) end)
			else
				print("[MOTD] Failed To Get MOTD Info. Too many retries.")
				self:SetLoadingDone(nil)
			end
		end
	end, "GET" )
end

return MotdManager
