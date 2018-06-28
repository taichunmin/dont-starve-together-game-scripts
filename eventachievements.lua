local EventAchievements = Class(function(self)
	self._achievement_list = {}
	self._achievement_list_byid = {}
end)

function EventAchievements:LoadAchievementsForEvent(data)
	local eventid = data.eventid
	local achievements = data.achievements
	
	self._achievement_list[data.eventid] = achievements
	
	self._achievement_list_byid[eventid] = {}
	for _, cat in ipairs(achievements) do
		for i, achievement in ipairs(cat.data) do
			self._achievement_list_byid[eventid][achievement.achievementid] = achievement
		end
	end
end

function EventAchievements:GetAchievementsIdList(eventid)
	return self._achievement_list_byid[eventid];
end

function EventAchievements:GetAchievementsCategoryList(eventid)
	return self._achievement_list[eventid]
end

function EventAchievements:IsAchievementUnlocked(eventid, achievementid)
	return TheInventory:IsAchievementUnlocked(GetFestivalEventServerName(eventid), achievementid)
end

function EventAchievements:GetNumAchievementsUnlocked(eventid)
	local total = 0
	local unlocked = 0
	for k, v in pairs( self._achievement_list_byid[eventid]) do
		if EventAchievements:IsAchievementUnlocked(eventid, v.achievementid) then
			unlocked = unlocked + 1
		end
		total = total + 1
	end
	return unlocked, total
end

function EventAchievements:SetAchievementTempUnlocked(achievementid)
    local event_server_name = GetFestivalEventServerName(WORLD_FESTIVAL_EVENT)
	TheInventory:SetAchievementTempUnlocked(event_server_name, achievementid)
	print ("Temp Unlocking Achievement " .. achievementid .. " - " ..(TheInventory:IsAchievementUnlocked(event_server_name, achievementid) and "success" or "failed"))
end

function EventAchievements:IsAnAchievement(eventid, achievementid)
	return self._achievement_list_byid[eventid] ~= nil and self._achievement_list_byid[eventid][achievementid] ~= nil
end

return EventAchievements
