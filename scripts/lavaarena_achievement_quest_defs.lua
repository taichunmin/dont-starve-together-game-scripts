

local function TestMatchTime(user, data, max_time)
	return data.outcome.won and data.outcome.time <= max_time
end

local WXP_DAILY_WIN = 5000
local WXP_DAILY_MATCH = 500
local WXP_QUESTS_BASIC = 500
local WXP_QUESTS_CHALLENGE = 2500
local WXP_QUESTS_SPECIALIZED = 1500


local function TestForVictory(user, data)
	return data.outcome.won
end

local Lavaarena_Achievements =
{
    {
        category = "quests_daily",
        data =
        {
			{achievementid = "laq_dailywin",				daily = true, wxp = WXP_DAILY_WIN},
			{achievementid = "laq_dailymatch",				daily = true, wxp = WXP_DAILY_MATCH},
		},
	},
    {
        category = "quests_basic",
		category_wxp = WXP_QUESTS_BASIC,
        data =
        {
			{achievementid = "laq_battlestandards"},
			{achievementid = "laq_reviver"},
			{achievementid = "laq_specials_veryfast"},
			{achievementid = "laq_outofharmsway"},
			{achievementid = "laq_specials_somany"},
			{achievementid = "laq_nodashhounds"},
			{achievementid = "laq_nodeath_solo_easy"},
			{achievementid = "laq_rhinodrill1"},
			{achievementid = "laq_spinners_easy", team = true},
			{achievementid = "laq_boarons", team = true},
			{achievementid = "laq_nopoisondeath", team = true},
			{achievementid = "laq_beetle1", team = true},
		},
	},

    {
        category = "quests_challenge",
		category_wxp = WXP_QUESTS_CHALLENGE,
        data =
        {
			{achievementid = "laq_nodeath_r2", team = true},
			{achievementid = "laq_nodeath_r3", team = true},
			{achievementid = "laq_nodeath_r4", team = true},
			{achievementid = "laq_nodeath_r5", team = true},
			{achievementid = "laq_nodeath_r6", team = true},
			{achievementid = "laq_wintime_30", team = true},
			{achievementid = "laq_wintime_25", team = true},
			{achievementid = "laq_wintime_20", team = true},
			{achievementid = "laq_spinners_hard", team = true},
			{achievementid = "laq_rhinodrill_hard", team = true},
		},
	},

    {
        category = "quests_specialized",
		category_wxp = WXP_QUESTS_SPECIALIZED,
        data =
        {
			{achievementid = "laq_guardsbroken", character_set = {"webber", "willow", "wendy"}},
			{achievementid = "laq_hammer", character_set = {"wx78", "wolfgang", "winona"}},
			{achievementid = "laq_petrify", character_set = {"waxwell"}},
			{achievementid = "laq_meteorkill", character_set = {"wickerbottom", "waxwell", "willow"}},
			{achievementid = "laq_fasthealing", character_set = {"winona", "wilson"}},
			{achievementid = "laq_stronghealing", character_set = {"wickerbottom"}},
			{achievementid = "laq_distraction", character_set = {"wes"}},
			{achievementid = "laq_killingblows_lots", character_set = {"webber"}},
			{achievementid = "laq_axethrow", character_set = {"woodie"}},
			{achievementid = "laq_flip", character_set = {"wathgrithr"}},
			{achievementid = "laq_shock", character_set = {"wx78"}},
			{achievementid = "laq_spinstopper", character_set = {"wolfgang", "woodie", "wendy"}},

			{achievementid = "laq_battlecry", character_set = {"wathgrithr"}},
			{achievementid = "laq_meteors", character_set = {"willow"}},
			{achievementid = "laq_decoy", character_set = {"woodie", "wes"}},
			{achievementid = "laq_doctor", character_set = {"wilson", "wickerbottom"}},
			{achievementid = "laq_merciless", character_set = {"wolfgang", "wathgrithr"}},
			{achievementid = "laq_shadowkill", character_set = {"waxwell"}},
			{achievementid = "laq_fullhands", character_set = {"winona", "wilson"}},
			{achievementid = "laq_nodeath_solo_hard", character_set = {"webber", "wendy"}},
			{achievementid = "laq_heavyblade_special", character_set = {"wx"}},
			{achievementid = "laq_defeat_snapper", character_set = DST_CHARACTERLIST, team = true},
			{achievementid = "laq_defeat_trails", character_set = DST_CHARACTERLIST, team = true},
			{achievementid = "laq_defeat_boarrior", character_set = DST_CHARACTERLIST, team = true},
			{achievementid = "laq_defeat_rhinodrill", character_set = DST_CHARACTERLIST, team = true},
		},
	},
}

for _, cat in ipairs(Lavaarena_Achievements) do
	for i, achievement in ipairs(cat.data) do
		achievement.prefab = nil --(not cat.anycharacter) and cat.category or nil
		achievement.category = cat.category

		if cat.category_wxp ~= nil then
			achievement.wxp = cat.category_wxp
		end
	end
end

return
{
    seasons = { 2 },
	eventid = "lavaarena",
	achievements = Lavaarena_Achievements,
	impl = event_server_data("lavaarena", "lavaarena_achievement_quest_defs")
}