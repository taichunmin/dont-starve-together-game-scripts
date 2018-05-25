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

function EventAchievements:IsAchievementUnlocked(achievementid)
	return TheInventory:IsAchievementUnlocked(achievementid)
end

function EventAchievements:GetNumAchievementsUnlocked(eventid)
	local total = 0
	local unlocked = 0
	for k, v in pairs( self._achievement_list_byid[eventid]) do
		if EventAchievements:IsAchievementUnlocked(v.achievementid) then
			unlocked = unlocked + 1
		end
		total = total + 1
	end
	return unlocked, total
end

function EventAchievements:SetAchievementTempUnlocked(achievementid)
	TheInventory:SetAchievementTempUnlocked(achievementid)
end

function EventAchievements:IsAnAchievement(eventid, achievementid)
	return self._achievement_list_byid[eventid] ~= nil and self._achievement_list_byid[eventid][achievementid] ~= nil
end

return EventAchievements
