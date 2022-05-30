local EventAchievements = Class(function(self)
	self._achievement_list = {}
	self._achievement_list_byid = {}

	self._quest_data = {}
end)

function EventAchievements:LoadAchievementsForEvent(data)
	local eventid = data.eventid
	local achievements = data.achievements
	local seasons = data.seasons


    for _,season in ipairs(seasons) do
        if self._achievement_list[eventid] == nil then
            self._achievement_list[eventid] = {}
        end
	    self._achievement_list[eventid][season] = achievements
    end

    --only load the flattened list if this is the active event + season
	if eventid == WORLD_FESTIVAL_EVENT and table.contains( seasons,GetFestivalEventSeasons(eventid) ) then
        self._achievement_list_byid = {}
	    for _, cat in ipairs(achievements) do
		    for _, achievement in ipairs(cat.data) do
			    self._achievement_list_byid[achievement.achievementid] = achievement
		    end
	    end

		if data.impl ~= nil then
			data.impl.AddTestFunctions(self._achievement_list_byid)
		end
    end
end

function EventAchievements:GetActiveAchievementsIdList()
	return self._achievement_list_byid;
end

function EventAchievements:GetAchievementsCategoryList(eventid, season)
	return self._achievement_list[eventid][season]
end

function EventAchievements:FindAchievementData(eventid, season, achievementid)
	for _, v in pairs(self._achievement_list[eventid][season]) do
		for _, achievement in ipairs(v.data) do
			if achievement.achievementid == achievementid then
				return achievement
			end
		end
	end
	return nil
end

function EventAchievements:IsAchievementUnlocked(eventid, season, achievementid)
	return TheInventory:IsAchievementUnlocked(GetFestivalEventServerName(eventid, season), achievementid)
end

function EventAchievements:GetNumAchievementsUnlocked(eventid, season)
	local total = 0
	local unlocked = 0
	for _, cat in ipairs(self._achievement_list[eventid][season]) do
		for _, achievement in ipairs(cat.data) do
            if EventAchievements:IsAchievementUnlocked(eventid, season, achievement.achievementid) then
			    unlocked = unlocked + 1
		    end
		    total = total + 1
        end
	end
	return unlocked, total
end

function EventAchievements:SetAchievementTempUnlocked(achievementid)
    local event_server_name = GetActiveFestivalEventServerName()
	TheInventory:SetAchievementTempUnlocked(event_server_name, achievementid)
	print ("Temp Unlocking Achievement " .. achievementid .. " - " ..(TheInventory:IsAchievementUnlocked(event_server_name, achievementid) and "success" or "failed"))
end

function EventAchievements:IsActiveAchievement(achievementid)
    local event_id = WORLD_FESTIVAL_EVENT
	return self._achievement_list_byid ~= nil and self._achievement_list_byid[achievementid] ~= nil
end

function EventAchievements:GetAllUnlockedAchievements(eventid, season)
	return TheInventory:GetAllUnlockedAchievements(GetFestivalEventServerName(eventid, season)) or {}
end

function EventAchievements:SetActiveQuests(quest_data)
	self._quest_data = quest_data
end

function EventAchievements:BuildFullQuestName(quest_id, character)
	local post_fix = "-" .. string.format("-%03d", self._quest_data.version) .. string.format("-%03d", self._achievement_list_byid[quest_id].daily and self._quest_data.event_day or self._quest_data.quest_day)

	if character ~= nil and (quest_id == self._quest_data.special1.quest or quest_id == self._quest_data.special2.quest) then
		post_fix = post_fix .. "-" .. character
	end

	return quest_id .. post_fix
end

function EventAchievements:ParseFullQuestName(quest_name)
	local data = string.split(quest_name, "-")
	local ret = {quest_id = data[1], version = tonumber(data[2]), day = tonumber(data[3]), character = data[4], daily = self._achievement_list_byid[data[1]] ~= nil and self._achievement_list_byid[data[1]].daily or nil}

	-- retrofitting code for per-version quests
	if ret.version == nil then
		if #data == 4 then
			ret.day = tonumber(data[4])
			ret.version = tonumber(data[3]) or 0
			ret.character = data[2]
		else
			ret.day = tonumber(data[3])
			ret.version = tonumber(data[2]) or 0
		end
	end

	return ret
end

return EventAchievements
