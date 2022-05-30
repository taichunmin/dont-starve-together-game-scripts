local USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"


local LAG_TEST = false
local NUM_RETRIES = 4

FINAL_UNLOCK_DATA = {level = 10, percent = 1.0, unlock_order = {"trails", "book_elemental", "boarrior", "lavaarena_firebomb", "lavaarena_armor_hpextraheavy", "lavaarena_armor_hpdamager", "rhinodrill", "lavaarena_heavyblade", "lavaarena_armor_hprecharger", "lavaarena_armor_hppetmastery", "beetletaur"}}

-- self.mode values:
local IS_FRONTEND = 0
local IS_CLIENT_ONLY = 1
local IS_DEDICATED_SERVER = 2
local IS_CLIENT_HOSTED = 3

local unordered_unlocks =
{
	{id = "book_elemental",					alias = "spear_lance",								style = "item",		atlas = "images/lavaarena_unlocks.xml",	icon = "book_elemental.tex"},
	{id = "lavaarena_firebomb",																	style = "item",		atlas = nil,							icon = "lavaarena_firebomb.tex"},
	{id = "lavaarena_heavyblade",																style = "item",		atlas = nil,							icon = "lavaarena_heavyblade.tex"},
    {id = "lavaarena_armor_hpdamager",															style = "item",		atlas = nil,							icon = "lavaarena_armor_hpdamager.tex"},
    {id = "lavaarena_armor_hpextraheavy",														style = "item",		atlas = nil,							icon = "lavaarena_armor_hpextraheavy.tex"},
    {id = "lavaarena_armor_hppetmastery",														style = "item",		atlas = nil,							icon = "lavaarena_armor_hppetmastery.tex"},
	{id = "lavaarena_armor_hprecharger",														style = "item",		atlas = nil,							icon = "lavaarena_armor_hprecharger.tex"},
	{id = "trails",													progression_key = true,		style = "creature",	atlas = "images/lavaarena_unlocks.xml", icon = "trails.tex"},
	{id = "boarrior",												progression_key = true,		style = "boss",		atlas = "images/lavaarena_unlocks.xml", icon = "boarrior.tex"},
	{id = "rhinodrill",												progression_key = true,		style = "creature",	atlas = "images/lavaarena_unlocks.xml", icon = "rhinodrill.tex"},
	{id = "beetletaur",												progression_key = true,		style = "boss",		atlas = "images/lavaarena_unlocks.xml", icon = "beetletaur.tex"},
}
local unordered_unlocks_index = {}
for i, v in ipairs(unordered_unlocks) do
	unordered_unlocks_index[v.id] = i
	if v.alias ~= nil then
		unordered_unlocks_index[v.alias] = i
	end
end

local ordered_unlock_styles =
{
	{style = "creature"},
	{style = "item"},
	{style = "boss"},
	{style = "item"},
	{style = "item"},
	{style = "item"},
	{style = "creature"},
	{style = "item"},
	{style = "item"},
	{style = "item"},
	{style = "boss"},
}
assert(#ordered_unlock_styles == #unordered_unlocks)

local function GetUnlockData(id)
	return unordered_unlocks[unordered_unlocks_index[id]]
end

local item_unlock_level = {}
local progression_key_id = "trails"

local function ParseProgressionData(data)
	local progression_data = {}
	if data == nil then
		progression_data.level = 1
		progression_data.percent = 0
		progression_data.unlock_order = {}

		item_unlock_level = {}
		progression_key_id = "trails"
	else
		progression_data = deepcopy(data)
		progression_data.level = math.min(progression_data.level, #unordered_unlocks)
		progression_data.percent = math.min(progression_data.percent, 1)
		progression_data.unlock_order = progression_data.unlock_order or {}

		item_unlock_level = {}
		for level, id in ipairs(progression_data.unlock_order) do
			item_unlock_level[id] = level
			local unlock_data = GetUnlockData(id)
			if unlock_data.alias ~= nil then
				item_unlock_level[unlock_data.alias] = level
			end

			if unlock_data.progression_key then
				progression_key_id = id
			end
		end
	end

	return progression_data
end

local function GetQuestDataTable(self, userid)
	if self.quest_data[userid] == nil then
		self.quest_data[userid] = {	quest_data = {error_code = "Not Set"} }
	end
	return self.quest_data[userid]
end

local CommunityProgression = Class(function(self)
	self.progression_query_active = false
    self.progression_query_time = nil
	self.PROGRESSION_QUERY_EXPIRY = 60*10 -- 10 min

	self.progression_data = ParseProgressionData(nil)
	self.prev_progression_data = ParseProgressionData(nil)
	self.server_progression_json = ""

	self.quest_data = {}

	self.community_json = ""

	self.mode = IS_FRONTEND
end)

function CommunityProgression:GetUnlockData(id)
	return GetUnlockData(id)
end

function CommunityProgression:GetUnlockOrderStyles()
	return ordered_unlock_styles
end

function CommunityProgression:GetUnlockOrder()
	return self.progression_data.unlock_order
end

function CommunityProgression:IsLocked(id)
	return item_unlock_level[id] == nil
end

function CommunityProgression:IsUnlocked(id)
	return not self:IsLocked(id)
end

function CommunityProgression:GetProgression()
	return { level = self.progression_data.level, percent = self.progression_data.percent }
end

function CommunityProgression:GetLastSeenProgression()
	return self.prev_progression_data
end

function CommunityProgression:GetProgressionKeyBoss()
	return GetUnlockData(progression_key_id).id
end

function CommunityProgression:IsEverythingUnlocked()
	return self.progression_data.level == #unordered_unlocks
end

function CommunityProgression:GetNumTotalUnlocks()
	return #unordered_unlocks
end

function CommunityProgression:GetProgressionQuerySuccessful(userid)
	return self.progression_data.error_code  == nil
end

function CommunityProgression:GetQuestQuerySuccessful(userid)
	return GetQuestDataTable(self, userid).quest_data.error_code == nil
end

function CommunityProgression:IsNewUnlock(id)
	if item_unlock_level[id] == nil  then
		return false
	end

	local is_new = (self.progression_data.level >= item_unlock_level[id]) and (self.prev_progression_data.level < item_unlock_level[id])
	return is_new
end

function CommunityProgression:IsQueryActive()
	return self.both_queries_active or self.progression_query_active or GetQuestDataTable(self, TheNet:GetUserID()).quest_query_active
end

function CommunityProgression:IsProgressionQueryExpired()
	return self.progression_data.error_code ~= nil or (self.progression_query_time == nil and true or ((os.time() - self.progression_query_time) > self.PROGRESSION_QUERY_EXPIRY))
end

function CommunityProgression:IsQuestQueryExpired(userid)
	local cur_time = os.time()
	local quests = self.quest_data[userid]
	return quests == nil or quests.quest_data.error_code ~= nil or (math.min(os.difftime(quests.quest_data.daily_expiry or 0, cur_time), os.difftime(quests.quest_data.quest_expiry or 0, cur_time)) < 0)
end

function CommunityProgression:GetCurrentQuestData(userid)
	return GetQuestDataTable(self, userid).quest_data
end

function CommunityProgression:RemoveQuestData(userid)
	self.quest_data[userid] = nil
end

function CommunityProgression:GetServerProgressionJson()
	return self.server_progression_json
end

function CommunityProgression:GetServerQuestJson(userid)
	return self.quest_data[userid] ~= nil and self.quest_data[userid].server_json or ""
end

local function GenerateFakeWebProgression()
	print("[CommunityProgression] Running GenerateFakeWebProgression")
    local achievements = event_server_data("lavaarena", "lavaarena_achievement_quest_defs")
	if achievements then
		return achievemets.GenerateFakeWebProgression()
	end
	return {}
end

local function GenerateFakeWebQuests(userid, requested_date)
	print("[CommunityProgression] Running GenerateFakeWebQuests")
    local achievements = event_server_data("lavaarena", "lavaarena_achievement_quest_defs")
	if achievements then
		return achievements.GenerateFakeWebQuests(userid, requested_date)
	end
	return {}
end

local function ParseQuestData(source_quests)
	local quests = {}
	quests.version = source_quests.version
	quests.event_day = source_quests.event_day
	quests.quest_day = source_quests.quest_day
	quests.daily_win = {quest = source_quests.d_win, daily = true}
	quests.daily_match = {quest = source_quests.d_match, daily = true}
	quests.daily_expiry = source_quests.daily_expiry
	quests.quest_expiry = source_quests.quest_expiry

	quests.basic = {quest = source_quests.basic.quest}
	quests.challenge = {quest = source_quests.challenge.quest}

	quests.special1 = {character = source_quests.special1.character, quest = source_quests.special1.quest}
	quests.special2 = {character = source_quests.special2.character, quest = source_quests.special2.quest}

	print("[CommunityProgression] Event Day: " .. tostring(quests.event_day) .. ", Quest Day: " .. tostring(quests.quest_day))

	--print("ParseQuestData")
	--dumptable(quests)

	return quests
end

function CommunityProgression:OnClientQueryCompleted()
	if not self.both_queries_active and not self.progression_query_active and not GetQuestDataTable(self, TheNet:GetUserID()).quest_query_active then
		TheGlobalInstance:PushEvent("community_clientdata_updated")
	end
	self.both_queries_active = false
end

function CommunityProgression:OnProgressionQueryComplete(override_mode)
	self.progression_retries_remaining = nil

	if override_mode == IS_DEDICATED_SERVER or override_mode == IS_CLIENT_HOSTED then
		TheWorld:PushEvent("community_progression_request_complete")
	else
		self:OnClientQueryCompleted()
	end
end

local function OnHandleProgressionQueryResponce(self, result, isSuccessful, resultCode)
 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then
		----------
		--result = GenerateFakeWebProgression()
		--dumptable(result)
		----------
		local error = {}
		local status, data = pcall( function() return json.decode(result) end )
		if not status or not data then
	 		print("[CommunityProgression] Faild to parse progression json!", tostring(status), tostring(data))
			self.progression_data.error_code = "Faild to parse progression json."
			self.progression_data.error_msg = data
		else
			data.level = data.level + 1 -- +1 because lua is 1-based and the web is 0-based
			self.progression_data = ParseProgressionData(data)
			self.dirty = true
			-- TODO: ERROR HANDLING IF ParseProgressionData fails!
		end
 	else
		if self.progression_retries_remaining > 0 then
 			print("[CommunityProgression] Faild to download progression data (" .. tostring(resultCode) .. "), remaining retries: " .. tostring(self.progression_retries_remaining))
			self.progression_retries_remaining = self.progression_retries_remaining - 1
			self.progression_query_active = false -- set it to false so the retry will run
			self:RequestProgressionData(true, self.progression_query_time)
			return
		else
 			print("[CommunityProgression] Faild to get any progression data from the web! ", tostring(resultCode))
			self.progression_data.error_code = "Progression Query Failed: " .. tostring(resultCode)
		end
	end

	print("[CommunityProgression] Done Requesting Progression Data (" .. tostring(resultCode) .. ")")

	if self.mode == IS_DEDICATED_SERVER then
		self.progression_query_active = false
		self.server_progression_json = json.encode(self.progression_data)
	elseif self.mode == IS_CLIENT_HOSTED then
		self.server_progression_json = json.encode(self.progression_data)
	else
		self.progression_query_active = false
	end

	self:OnProgressionQueryComplete(self.mode)
end

function CommunityProgression:RequestProgressionData(force, time)

	if not IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self:OnProgressionQueryComplete(self.mode)
		return
	end

	if self.progression_query_active == true then
		return
	end
--[[
	-- everything is unlocked
	if true then
		print("[CommunityProgression] Requesting Progression Data - Final data")
		OnHandleProgressionQueryResponce(self, json.encode(FINAL_UNLOCK_DATA), true, 200)
		return
	end
]]
	if not force and not self:IsProgressionQueryExpired() then
		self:OnProgressionQueryComplete(self.mode)
		return
	end

	print("[CommunityProgression] Requesting Progression Data (" .. tostring(time) .. ")...")
	self.progression_data = ParseProgressionData(nil)
	self.server_progression_json = ""
	self.progression_query_active = true
	self.progression_query_time = time
	if self.progression_retries_remaining == nil then
		self.progression_retries_remaining = NUM_RETRIES
	end

	TheSim:QueryServer( "https://theforge.kleientertainment.com/wins",
		function(result, isSuccessful, resultCode)
			if not LAG_TEST then
				OnHandleProgressionQueryResponce(self, result, isSuccessful, resultCode)
			else
				TheGlobalInstance:DoTaskInTime(3, function() OnHandleProgressionQueryResponce(self, result, isSuccessful, resultCode) end)
			end
		end,
		"GET")
end

function CommunityProgression:OnQuestQueryComplete(userid, override_mode)
	GetQuestDataTable(self, userid).quest_retries_remaining = nil
	if override_mode == IS_DEDICATED_SERVER or override_mode == IS_CLIENT_HOSTED then
		TheWorld:PushEvent("community_quest_request_complete", {userid = userid})
	else
		EventAchievements:SetActiveQuests(GetQuestDataTable(self, userid).quest_data)
		self:OnClientQueryCompleted()
	end
end

local function OnHandleQuestQueryResponce(self, userid, result, isSuccessful, resultCode)
	local user_quests = GetQuestDataTable(self, userid)

 	if isSuccessful and string.len(result) > 1 and resultCode == 200 then
		----------
		--result = GenerateFakeWebQuests(userid, os.time())
		--print("FAKE QUESTS")
		--print(result)
		----------
		local error = {}
		local status, data = pcall( function() return json.decode(result) end )
		if not status or not data then
	 		print("[CommunityProgression] Faild to parse quest json for " .. tostring(userid) .."! ", tostring(status), tostring(data))
			user_quests.quest_data.error_code = "Faild to parse quest json for " .. tostring(userid)
			user_quests.quest_data.error_msg = data
			user_quests.quest_data.userid = userid
		else
			user_quests.quest_data = ParseQuestData(data)
			user_quests.quest_data.userid = userid
			self.dirty = true
			-- TODO: ERROR HANDLING IF ParseQuestData fails!
		end
 	else
		if user_quests.quest_retries_remaining ~= nil and user_quests.quest_retries_remaining > 0 then
 			print("[CommunityProgression] Faild to download quest data (" .. tostring(resultCode) .. "), remaining retries: " .. tostring(user_quests.quest_retries_remaining) .. " for user " .. tostring(userid))
			user_quests.quest_retries_remaining = user_quests.quest_retries_remaining - 1
			user_quests.quest_query_active = false
			self:RequestQuestData(true, userid, user_quests.quest_query_time)
			return
		else
	 		print("[CommunityProgression] Faild to get any quest data from the web for " .. tostring(userid) .."! ", tostring(resultCode))
			user_quests.quest_data.error_code = "Quest Query Failed: " .. tostring(resultCode)
			user_quests.quest_data.userid = userid
		end
	end

	print("[CommunityProgression] Done Requesting Quest Data for " .. tostring(userid) ..": ", tostring(resultCode))

	if self.mode == IS_DEDICATED_SERVER then
		user_quests.quest_query_active = false
		user_quests.server_json = json.encode(user_quests.quest_data)
	elseif self.mode == IS_CLIENT_HOSTED then
		if userid ~= TheNet:GetUserID() then
			user_quests.quest_query_active = false
		end

		user_quests.server_json = json.encode(user_quests.quest_data)
	else
		user_quests.quest_query_active = false
	end

	self:OnQuestQueryComplete(userid, self.mode)
end

function CommunityProgression:RequestQuestData(force, userid, time)
	if not IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self:OnQuestQueryComplete(userid, self.mode)
		return
	end

	userid = userid or TheNet:GetUserID()

	if GetQuestDataTable(self, userid).quest_query_active == true then
		return
	end

	if not force and not self:IsQuestQueryExpired(userid) then
		self:OnQuestQueryComplete(userid, self.mode)
		return
	end

	print("[CommunityProgression] Requesting Quest Data for user " .. tostring(userid) .. " (" .. tostring(time) .. ")...")
	local user_quests = GetQuestDataTable(self, userid)
	--user_quests.quest_data = {}
	user_quests.server_json = ""
	user_quests.quest_query_active = true
	user_quests.quest_query_time = time
	if user_quests.quest_retries_remaining == nil then
		user_quests.quest_retries_remaining = NUM_RETRIES
	end

	print("https://theforge.kleientertainment.com/quest?userid="..userid.."&date="..tostring(time))
	TheSim:QueryServer( "https://theforge.kleientertainment.com/quest?userid="..userid.."&date="..tostring(time),
		function(result, isSuccessful, resultCode)
			if not LAG_TEST then
				OnHandleQuestQueryResponce(self, userid, result, isSuccessful, resultCode)
			else
				TheGlobalInstance:DoTaskInTime(3, function() OnHandleQuestQueryResponce(self, userid, result, isSuccessful, resultCode) end)
			end
		end,
		"GET")
end

function CommunityProgression:RequestAllData(force, userid)
	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		local time = os.time()
		self.both_queries_active = true
		self:RequestProgressionData(force, time)
		self:RequestQuestData(force, userid, time)
	else
		self:OnProgressionQueryComplete(self.mode)
	end
end

local function OnNewProgressionFromServer(self)
	if self.mode ~= IS_DEDICATED_SERVER then
		local status, data = pcall( function() return json.decode(TheWorld.net.components.lavaarenaeventstate:GetServerProgressionJson()) end )
		if not status or not data then
	 		print("[CommunityProgression] Error: Faild to parse progression block send by server!", tostring(status), tostring(data))
			self.progression_data.error_code = "Faild to parse progression json sent by server"
			self.progression_data.error_msg = data
		else
			if data.error_code ~= nil then
	 			print("[CommunityProgression] Error: Server sent error code in progression block!", tostring(data.error_code), data.error_msg)
			end
			self.progression_data = ParseProgressionData(data)
			self.dirty = true

			print("[CommunityProgression] Recieved progression data from server (" .. tostring(self.progression_data.level) .. ", " .. tostring(self.progression_data.percent) .. ", " .. tostring(progression_key_id) .. ")")
		end

		self.progression_query_active = false
		self:OnProgressionQueryComplete(IS_CLIENT_ONLY)
	end
end

local function OnNewQuestFromServer(self, quest_slot)
	local userid = TheNet:GetUserID()
	local user_quests = GetQuestDataTable(self, userid)

	if self.mode ~= IS_DEDICATED_SERVER then
		local json_str = TheWorld.net.components.lavaarenaeventstate:GetServerPlayerQuestJson(quest_slot)
		if json_str ~= "" then
			local status, data = pcall( function() return json.decode(json_str) end )
			if not status or not data then
				if user_quests.quest_query_active then
	 				print("[CommunityProgression] Faild to parse quest block sent by server!", tostring(status), tostring(data))
					user_quests.quest_data.error_code = "Faild to parse quest json sent by server"
					user_quests.quest_data.error_msg = data

					user_quests.quest_query_active = false
					self:OnQuestQueryComplete(userid, IS_CLIENT_ONLY)
				end
			elseif data.userid == userid then
				if data.error_code ~= nil then
	 				print("[CommunityProgression] Error: Server sent error code in quest block!", tostring(data.error_code), data.error_msg)
				end
				--print("OnNewQuestFromServer")
				--dumptable(data)
				user_quests.quest_data = data
				self.dirty = true

				print("[CommunityProgression] Recieved quest data from server.")

				user_quests.quest_query_active = false
				self:OnQuestQueryComplete(userid, IS_CLIENT_ONLY)
			end
		end
	end
end

function CommunityProgression:RegisterForWorld()
	self.mode = TheWorld == nil and IS_FRONTEND
				or TheNet:IsDedicated() and IS_DEDICATED_SERVER
				or TheWorld.ismastersim and IS_CLIENT_HOSTED
				or IS_CLIENT_ONLY

	if IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		if self.mode == IS_CLIENT_ONLY then
			self.both_queries_active = true
			self.progression_query_active = true
			GetQuestDataTable(self, TheNet:GetUserID()).quest_query_active = true
		elseif self.mode == IS_CLIENT_HOSTED then
			self.both_queries_active = true
		end

		if self.mode ~= IS_DEDICATED_SERVER then
			TheWorld.net:ListenForEvent("progressionjsondirty", function() OnNewProgressionFromServer(self) end)

			for i = 1, TheNet:GetServerMaxPlayers() do
				TheWorld.net:ListenForEvent("playerquestjsondirty_"..i, function(net, data) OnNewQuestFromServer(self, i) end)
			end
		end
	end
end

function CommunityProgression:Load()
	if not IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self.quest_data = {}
		self.progression_data = ParseProgressionData(FINAL_UNLOCK_DATA)
		self.prev_progression_data = deepcopy(self.progression_data)
		return
	end

	TheSim:GetPersistentString(BRANCH == "dev" and "community_progression_dev" or "community_progression", function(load_success, json_data)
		if load_success and json_data ~= nil then
			local status, data = pcall( function() return json.decode(json_data) end )
		    if status and data and data.progression_data and self.quest_data then
				self.progression_data = ParseProgressionData(data.progression_data)
				self.prev_progression_data = deepcopy(self.progression_data)
				self.progression_query_time = data.progression_query_time
				self.quest_data = data.quest_data or {}
				print("[CommunityProgression] Progression and quest data loaded from file.")
			else
				print("[CommunityProgression] Invalid progression and quest data in save file.", tostring(status), tostring(json_data))
			end
		end
		self.dirty = false
	end)
end

function CommunityProgression:Save()
	if not IsFestivalEventActive(FESTIVAL_EVENTS.LAVAARENA) then
		self.dirty = false
		return
	end

	if self.dirty and not TheNet:IsDedicated() then
		local save_data = {}
		save_data.progression_data = self.progression_data
		save_data.progression_query_time = self.progression_query_time
		save_data.quest_data = self.quest_data

		local file_name = BRANCH == "dev" and "community_progression_dev" or "community_progression"
		local encode = BRANCH ~= "dev"

		TheSim:SetPersistentString(file_name, json.encode(save_data), encode)
		self.dirty = false
		self.prev_progression_data = deepcopy(save_data.progression_data)
	end
end

return CommunityProgression
