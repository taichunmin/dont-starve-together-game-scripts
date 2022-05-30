
local TEMPLATES = require "widgets/redux/templates"

local MAX_RETRIES = 4
local MAX_IMAGE_RETRIES = 1
local CACHE_FILE_NAME = ENCODE_SAVES and "motd_info" or "motd_info_dev"


local MAX_IMAGE_FILES = 10

local FAKE_MOTD_SRC_DATA = false
local ALWAYS_NEW = false
local ALWAYS_DOWNLOAD_IMAGES = false

local MotdManager = Class(function(self)
	self.motd_info = {}
	self.motd_images = {}
	self.live_build = -1
	self.isloading_motdinfo = true
end)

function MotdManager:IsEnabled()
	return IsSteam() or IsRail()
end

function MotdManager:Initialize()
	if MotdManager:IsEnabled() then
		self:LoadCachedMotdInfo()
		self:DownloadMotdInfo(MAX_RETRIES)
	end
end

function MotdManager:IsLoadingMotdInfo()
	return self.isloading_motdinfo
end

function MotdManager:Save()
	SavePersistentString(CACHE_FILE_NAME, json.encode_compliant(self.motd_info), ENCODE_SAVES)
end

function MotdManager:SetMotdInfo(info, live_build)
	self.motd_info = info
	self.motd_sorted_keys = self:MakeSortedKeys(info)
	self.live_build = tonumber(live_build) or -1


	-- only keep the best MAX_IMAGE_FILES boxes, we can only show that many
	for i = (MAX_IMAGE_FILES + 1), #self.motd_sorted_keys do
		self.motd_sorted_keys[i] = nil
	end

	self:Save()
end

function MotdManager:GetMotd()
	return self.motd_info, self.motd_sorted_keys
end

function MotdManager:IsNewUpdateAvailable()
	return APP_VERSION ~= "-1" and self.live_build > tonumber(APP_VERSION)
end

local function findfirstbox(category, motd_info)
	for id, v in pairs(motd_info) do
		if v.data.category == category and (v.data.group_order == nil or v.data.group_order == 1) and not v.data.hidden then
			return id
		end
	end
	return nil
end

function MotdManager:GetPatchNotes()
	local patchnotes_id = findfirstbox("patchnotes", self.motd_info)
	return patchnotes_id ~= nil and self.motd_info[patchnotes_id] or {data = { no_image = true }, meta = { is_new = true}, id = "unknown_patchnotes"}
end

function MotdManager:MarkAsSeen(boxid)
	if self.motd_info[boxid] ~= nil and self.motd_info[boxid].meta ~= nil then
		if self.motd_info[boxid].meta.is_new then
			self.motd_info[boxid].meta.last_seen = os.time()
			self:Save()
		end
	end
end

function MotdManager:IsImageLoaded(cell_id)
	local cell = self.motd_info[cell_id]
	return cell ~= nil and cell.meta.image_file
end

function MotdManager:SetLoadingDone()
	self.isloading_motdinfo = false
	print("[MOTD] Done Loading.")
	TheGlobalInstance:PushEvent("motd_info_loaded", {success = self.motd_info ~= nil})
end

function MotdManager:AddOnMotdDownloadedCB(ent, cb_fn)
	ent:ListenForEvent("motd_info_loaded", cb_fn, TheGlobalInstance)
end

function MotdManager:LoadCachedMotdInfo()
	self.motd_info = {}
	TheSim:GetPersistentString(CACHE_FILE_NAME, function(load_success, json_info)
		if load_success and string.len(json_info) > 1 then
			local status, motd_info = pcall( function() return json.decode(json_info) end )
			if status and motd_info ~= nil then
				self.motd_info = motd_info
			end
		end
	end)
end

local category_order =
{
	patchnotes = 1,
	skins = 2,
	twitch = 3,
	news = 4,

	none = 100,
}

function MotdManager:MakeSortedKeys(motd_info)
	local patchnotes = findfirstbox("patchnotes", motd_info)
	local box2 = (patchnotes == nil or not motd_info[patchnotes].meta.is_new) and patchnotes or findfirstbox("skins", motd_info)
	local box3 = findfirstbox("twitch", motd_info)

	local sorted_keys = {}
	for k, cell in pairs(motd_info) do
		if k ~= box2 and k ~= box3 and not cell.data.hidden then
			table.insert(sorted_keys, k)
		end
	end

	table.sort(sorted_keys, function(_a, _b)
		local a, b = motd_info[_a], motd_info[_b]
		if true or a.meta.is_new == b.meta.is_new then -- disabling is_new for the sort
			if category_order[a.data.category] == category_order[b.data.category] then
				if a.data.group_order == b.data.group_order then
					return a.data.title < b.data.title
				else
					return a.data.group_order < b.data.group_order
				end
			else
				return category_order[a.data.category] < category_order[b.data.category]
			end
		else
			return a.meta.is_new
		end
	end)

	if box2 ~= nil then
		table.insert(sorted_keys, 2, box2)
	end
	if box3 ~= nil then
		table.insert(sorted_keys, 3, box3)
	end

	return sorted_keys
end

function MotdManager:LoadCachedImages()
	for _, cell in pairs(self.motd_info) do
		if cell.meta.image_file ~= nil then
			TheSim:LoadMOTDImage(cell.meta.image_file)
		end
	end
end

function MotdManager:GetImagesToDownload()
	local free_boxes = {}
	for i = 1, MAX_IMAGE_FILES do
		free_boxes["box"..tostring(i)] = true
	end

	local download_queue = {}
	for i, cell_id in ipairs(self.motd_sorted_keys) do
		local cell = self.motd_info[cell_id]
		--print("cell image", cell.data.title, cell.id, cell.meta.image_file, cell.data.image_url)
		if cell.data.image_url ~= nil and cell.data.image_url ~= "" then
			if cell.meta.image_file ~= nil then
				free_boxes[cell.meta.image_file] = nil
			elseif not cell.data.no_image then
				table.insert(download_queue, {cell_id = cell_id, image_url = cell.data.image_url})
			end
		end
	end

	for i, v in ipairs(download_queue) do
		if v.image_file == nil then
			local box_num = next(free_boxes)
			if box_num ~= nil then
				v.image_file = box_num
				free_boxes[box_num] = nil
			end
		end
	end

--	print("download_queue")
--	dumptable(download_queue)

	return download_queue
end

local function makefakemotd()
-- live-version: used for patch notes and seeing if we are on the currect version or not
-- Category: [skins, patchnotes, twichdrops, news] - used to sort boxes

-- date - show date
-- finish-time: this box will be hidden once it expires
-- start-time: this box will be hidden until after this time, do not hide anything secret with this as the data will still be live
-- title: the main title to show
-- text: optional sub text at the bottom of the box, normally contains information about dates
-- image: url for the image to download for this box
-- link: an external url link
-- filter_menu: used for filtering skins screen
-- filter_discount = used for filtering skins screen
-- group: any boxes with the same group will be grouped up into a single box
-- weight: when there are mutliple boxes in a group, this will be used to do a weighted random select to determin the one that is showing

	local data =
	{
		["live-version"] = "-1",
		["boxes-live"] =
		{{
			Category =
			{
				skins =
				{
					{
						guid = "c4dda89e-5db1-4433-a343-74515503a2da",
						title = "New Wilson Winter's Feast Skins!",
						text = "new skins",
						image = "https://ds-motd.s3.amazonaws.com/converted/DST_YULE_ICE_MOTD_TEMPLATE.tex",
						href = "skins",
						filter_menu = "wilson",
						weight = "1",
						group = "character",
					},
					{
						guid = "d4dda89e-5db1-4433-a343-74515503a2da",
						title = "New Woodie Winter's Feast Skins!",
						text = "new skins",
						image = "https://ds-motd.s3.amazonaws.com/converted/DST_YULE_ICE_MOTD_TEMPLATE.tex",
						href = "skins",
						filter_menu = "Woodie",
						weight = "1",
						group = "character",
					},
					{
						guid = "e4dda89e-5db1-4433-a343-74515503a2da",
						title = "New Wickerbottom Winter's Feast Skins!",
						text = "new skins",
						image = "https://ds-motd.s3.amazonaws.com/converted/DST_YULE_ICE_MOTD_TEMPLATE.tex",
						href = "skins",
						filter_menu = "Wickerbottom",
						weight = "5",
						group = "character",
					},

					{
						guid = "a4dda89e-5db1-4433-a343-74515503a2da",
						title = "Victorian Antiques Chest",
						text = "new skins",
						image = "https://ds-motd.s3.amazonaws.com/converted/yotb/dst_yotb_victorian_items_bundle_motd.tex",
						href = "skins",
						filter_menu = "NEW",
						filter_discount = "SALE",
						weight = "2",
						group = "skin-pack",
					},
					{
						guid = "b4dda89e-5db1-4433-a343-74515503a2da",
						title = "Get Victorian Bundle!",
						text = "new skins",
						image = "https://ds-motd.s3.amazonaws.com/converted/yotb/dst_yotb_victorian_bundle_motd.tex",
						href = "skins",
						filter_menu = "NEW",
						filter_discount = "SALE",
						weight = "1",
						group = "skin-pack",
					},
 				},

				twitch =
				{
					{
						guid = "f4dda89e-5db1-4433-a343-74515503a2d1",
						title = "Twitch.tv Live stream by SomePerson",
						--text = {"Live at {date}", {date = 1612825755}},
						text = "Live on April 1st, 9:00 GMT",
						image = "https://s3.amazonaws.com/ds-motd/converted/RhymesWithPlay.tex",
						href = "https://forums.kleientertainment.com/forums/forum/217-ds-dst-art-music-and-lore/",
					}
				},

				patchnotes =
				{
					{
						guid = "g4dda89e-5db1-4433-a343-74515503a2d6",
						title = "Winter's Feast has Returned!",
						text = "Patch notes",
						image = "https://ds-motd.s3.amazonaws.com/converted/yotb/dst_yotb_event_motd_004.tex",
						href = "https://forums.kleientertainment.com/forums/topic/124931-game-update-445248/",
					}
				},

				news =
				{
					{
						guid = "k4dda89e-5db1-4433-a343-74515503a2da",
						title = "Roadmap 3030",
						text = "Head over to the forums to see what is coming to DST thoughout the year",
						image = "https://ds-motd.s3.amazonaws.com/converted/dst_roadmap_2020.tex",
						href = "https://forums.kleientertainment.com/forums/topic/115557-dont-starve-together-roadmap-2020/",
					},
					{
						guid = "j4dd289e-5db1-4433-a343-74515503a2d6",
						title = "Don't Starve Funko Pop start-time" ,
						['start-time'] = 1620318341,
						text = "Click for retail locations near you.",
						image = "https://s3.amazonaws.com/ds-motd/converted/pop-motd.tex",
						href = "https://shop.klei.com/dont-starve-funko-pops/",
					},
					{
						guid = "h4dd289e-5db1-4433-a343-74515503a2d1",
						title = "finish-time box!",
						["finish-time"] = "1616781756",
						text = "This is the description for some news",
						image = "https://ds-motd.s3.amazonaws.com/converted/yotb/dst_yotb_victorian_bundle_motd.tex",
						href = "https://forums.kleientertainment.com/forums/topic/124931-game-update-445248/",
					},
					{
						guid = "i4dda89e-5db1-4433-a343-74515503a2da",
						title = "This is another news thing",
						text = "This is another description for some news",
						image = "https://ds-motd.s3.amazonaws.com/converted/yotb/dst_yotb_victorian_bundle_motd.tex",
						href = "https://forums.kleientertainment.com/forums/topic/124931-game-update-445248/",
					},
				},
			},
	   }},

	}


	print("MOTD JSON:")
	print(json.encode_compliant(data))
	return json.encode_compliant(data)
end

local function fix_web_string(text)
	if FAKE_MOTD_SRC_DATA then
		return makefakemotd()
	end

	if type(text) ~= "string" then
		text = tostring(text)
	end
	text = string.gsub(tostring(text), "\\r\\n", "\\n")

	--Unicode conversion done here for the motd json instead in json.lua as our game relies on the old invalid json encoding/decoding.
	--https://github.com/craigmj/json4lua/blob/master/json/json.lua
	--Version: 1.0.0
	--see json.lua for further license information
	while true do
		local i, j = string.find(text, "\\u")
		if i ~= nil then
			local a = string.sub(text,j+1,j+4)

			local n = tonumber(a, 16)
			assert(n, "String decoding failed: bad Unicode escape " .. a .. " at position " .. i .. " : " .. j)
			-- math.floor(x/2^y) == lazy right shift
			-- a % 2^b == bitwise_and(a, (2^b)-1)
			-- 64 = 2^6
			-- 4096 = 2^12 (or 2^6 * 2^6)
			local x
			if n < 0x80 then
			x = string.char(n % 0x80)
			elseif n < 0x800 then
			-- [110x xxxx] [10xx xxxx]
			x = string.char(0xC0 + (math.floor(n/64) % 0x20), 0x80 + (n % 0x40))
			else
			-- [1110 xxxx] [10xx xxxx] [10xx xxxx]
			x = string.char(0xE0 + (math.floor(n/4096) % 0x10), 0x80 + (math.floor(n/64) % 0x40), 0x80 + (n % 0x40))
			end
			
			text = string.gsub(text, "\\u"..a, x)
		else
			break
		end
	end

	return text
end

local function convert_epoch_time_str(t)
	if type(t) == "table" and t[2] ~= nil and t[2].date ~= nil then
		t[2].date = str_date(t[2].date)
	end
	return t
end

local function reformat_motd(src_motd)
	local cur_time = os.time()

	local data = {  }
	local group_root = {}


	local src_categories = src_motd["boxes-live"] ~= nil and src_motd["boxes-live"][1] ~= nil and src_motd["boxes-live"][1].Category or nil
	if src_categories ~= nil then
		for cat, cat_data in pairs(src_categories) do
			local group_order = 1 -- this will be used to sort multiple groups within a category. The first box for a group will determin the order
			cat = string.lower(cat)
			for i, src_box in ipairs(cat_data) do
				if src_box.guid ~= nil and src_box.guid ~= "" then
					local box = {}
					box.category = category_order[cat] ~= nil and cat or "none"

					local expiry_time = tonumber(src_box["finish-time"]) or 0
					local start_time = tonumber(src_box["start-time"]) or 0
					box.hidden = (start_time > 0 and cur_time <= start_time) or (expiry_time > 0 and cur_time > expiry_time)

					box.title = src_box.title ~= nil and convert_epoch_time_str(src_box.title) or nil
					box.text = src_box.text ~= nil and convert_epoch_time_str(src_box.text) or nil
					box.details = src_box.details ~= nil and convert_epoch_time_str(src_box.details) or nil

					box.image_url = (src_box.image ~= nil and type(src_box.image) == "string" and string.match(src_box.image, ".tex")) and src_box.image or nil

					box.link_url = src_box.href
					if src_box.filter_discount ~= nil or src_box.filter_menu ~= nil then
						box.filter_info = { initial_item_key = src_box.filter_menu ~= "" and src_box.filter_menu or nil, initial_discount_key = src_box.filter_discount ~= "" and src_box.filter_discount or nil }
					end

					box.weight = tonumber(src_box.weight) or 1

					local box_id = "ID_" .. tostring(src_box.guid)
					if data[box_id] ~= nil then
						print("[MOTD] duplicate box id " .. tostring(box_id))
					end

					if src_box.group ~= nil and src_box.group ~= "" then
						local group_id = cat.."_"..src_box.group
						if group_root[group_id] == nil then
							group_root[group_id] = box_id

							box.group_order = group_order

							data[box_id] = {box}
						else
							box.group_order = data[ group_root[group_id] ][1].group_order
							table.insert( data[ group_root[group_id] ], box)
						end
					else
						box.group_order = group_order
						data[box_id] = {box}
					end

					group_order = group_order + 1
				else
					print("[MOTD] error parsing message:", tostring(src_box.guid), tostring(src_box.title))
				end
			end
		end
	end

	--print("raw motd")
	--dumptable(src_motd)

	--print("formatted motd")
	--dumptable(data)

	return data
end

local function pick_initial_box(boxes)
	if #boxes == 1 then
		return boxes[1]
	end

	local weighted_list = {}
	for _, box in ipairs(boxes) do
		if box.weight == nil or box.weight > 0  then -- nil defaults to 1, any value <=0 will not be selected
			weighted_list[box] = box.weight or 1
		end
	end

	return next(weighted_list) ~= nil and weighted_random_choice(weighted_list) or boxes[1]
end

function MotdManager:DownloadMotdInfo(remaining_retries)
	local url = TheSim:GetMOTDQueryURL()
	print("[MOTD] Downloading info from", url)

	TheSim:QueryServer( url, function(motd_json, isSuccessful, resultCode)
		local status, motd_src = "", ""
		if isSuccessful and string.len(motd_json) > 1 and resultCode == 200 then
			motd_json = fix_web_string(motd_json)
			status, motd_src = pcall( function() return json.decode(motd_json) end )
			local motd_info = {}
			if status and motd_src ~= nil then
				local live_build = motd_src["live-version"]
				motd_src = reformat_motd(motd_src)
				for box_id, src_boxes in pairs(motd_src) do
					local cell = {}
					cell.id = box_id
					cell.data = pick_initial_box(src_boxes)
					cell.sub_boxes = #src_boxes > 1 and src_boxes or nil

					if self.motd_info[box_id] ~= nil and self.motd_info[box_id].meta ~= nil and not ALWAYS_NEW then
						cell.meta = self.motd_info[box_id].meta
						cell.meta.is_new = cell.meta.last_seen == nil
						if cell.data.image_url ~= cell.meta.image_url or cell.data.hidden or ALWAYS_DOWNLOAD_IMAGES then
							cell.meta.image_file = nil -- the image has changed, download a new one
						end
					else
						cell.meta = {}
						cell.meta.is_new = true
					end

					cell.meta.is_sale = cell.data.filter_info ~= nil and cell.data.filter_info.initial_discount_key == "SALE"

					motd_info[box_id] = cell
				end

				-- check cached cells to see if their download image still exists on disk
				for _, cell in pairs(motd_info) do
					if cell.meta.image_file ~= nil then
						if not TheSim:HasMOTDImage(cell.meta.image_file) then
							cell.meta.image_file = nil -- reset if the file exists
						end
					end
				end

				self:SetMotdInfo(motd_info, live_build)
			else
				isSuccessful = false
			end
		else
			isSuccessful = false
		end

		--print("[MOTD]: isSuccessful", isSuccessful)

		if not isSuccessful then
			if remaining_retries >= 1 then
				print("[MOTD] Failed To Get MOTD Info from '"..url.."'. Result Code: "..tostring(resultCode)..", Status ".. tostring(status)..". Retrying ("..tostring(remaining_retries)..").")
				TheGlobalInstance:DoTaskInTime(1, function() self:DownloadMotdInfo(remaining_retries - 1) end)
			else
				print("[MOTD] Failed To Get MOTD Info. Too many retries.")
				self:SetLoadingDone()
			end
		else
			-- we got the MOTD data from the web and processed it, now its time for the images
			self:LoadCachedImages()
			self:SetLoadingDone()

			local images_to_download = self:GetImagesToDownload()
			self:DownloadMotdImages(images_to_download, 0)
		end
	end, "GET" )
end

function MotdManager:DownloadMotdImages(download_queue, retries)
	local itr, data = next(download_queue)
	if itr ~= nil then
		if data.image_url ~= nil then
			TheSim:DownloadMOTDImage(data.image_url, data.image_file, function(image_results)
				if image_results then
					self.motd_info[data.cell_id].meta.image_file = data.image_file
					self.motd_info[data.cell_id].meta.image_url = data.image_url or self.motd_info[data.cell_id].meta.image_url
					self:Save()
					TheGlobalInstance:PushEvent("motd_image_loaded", {cell_id = data.cell_id})

					download_queue[itr] = nil
					self:DownloadMotdImages(download_queue, 0)
				elseif retries < 2 then
					print("[MOTD] MotdManager: Failed to download image " .. tostring(data.image_file) .. " from " .. tostring(data.url) .. ", Retrying...")
					self:DownloadMotdImages(download_queue, retries + 1)
				else
					print("[MOTD] MotdManager: Failed to download image " .. tostring(data.image_file) .. ", using fallback image.")
					self.motd_info[data.cell_id].data.no_image = true
					TheGlobalInstance:PushEvent("motd_image_loaded", {cell_id = data.cell_id})

					download_queue[itr] = nil
					self:DownloadMotdImages(download_queue, 0)
				end
			end)
		end
	end
end


return MotdManager
