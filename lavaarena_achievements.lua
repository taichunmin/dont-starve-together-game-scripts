

local function TestMatchTime(user, data, max_time)
	return data.outcome.won and data.outcome.time <= max_time
end

local XWP_VICTORY = 10000
local XWP_LEVEL1 = 500
local XWP_LEVEL2 = 1000
local XWP_LEVEL2_5 = 5000
local XWP_LEVEL3 = 10000
local XWP_LEVEL4 = 20000
local XWP_LEVEL5 = 30000

local function TestForVictory(user, data)
	return data.outcome.won
end

local Lavaarena_Achievements =
{
    {
        category = "encore",
        anycharacter = true,
        data =
        {
            {
                achievementid = "encore_boarons",
                wxp = XWP_LEVEL2,
                testfn = function(user, data)
					if data.round == 2 then -- called on start of round
						local statstracker = TheWorld.components.lavaarenamvpstatstracker
						if statstracker:GetStatTotal("player_damagetaken") < 800 then
							return true
						end
					end
					return false
				end,
            },
            {
                achievementid = "encore_boarons_hard",
                wxp = XWP_LEVEL2_5,
                testfn = function(user, data)
					if data.round == 2 then  -- called on start of round
						local statstracker = TheWorld.components.lavaarenamvpstatstracker
						if statstracker:GetStatTotal("player_damagetaken") < 600 then
							return true
						end
					end
					return false
				end,
            },
            {
                achievementid = "encore_turtillus",
                wxp = XWP_LEVEL2,
                shared_progress_fn = function(data, shared_scratchpad)
					shared_scratchpad.encore_turtillus = (shared_scratchpad.encore_turtillus or 0) + 1
                end,
                testfn = function(user, data, scratchpad, shared_scratchpad)
					return data.round == 3 and (shared_scratchpad.encore_turtillus == nil or shared_scratchpad.encore_turtillus <= 3)
				end,
            },
            {
                achievementid = "encore_turtillus_hard",
                wxp = XWP_LEVEL2_5,
                shared_progress_fn = function(data, shared_scratchpad)
					shared_scratchpad.encore_turtillus_hard_failed = true
                end,
                testfn = function(user, data, scratchpad, shared_scratchpad)
					return data.round == 3 and shared_scratchpad.encore_turtillus_hard_failed ~= true
				end,
            },
            {
                achievementid = "encore_peghook",
                wxp = XWP_LEVEL2_5,
                shared_progress_fn = function(data, shared_scratchpad)
					shared_scratchpad.encore_peghook_failed = true
                end,
                testfn = function(user, data, scratchpad, shared_scratchpad)
					return shared_scratchpad.encore_peghook_failed ~= true
				end,
            },
            {
                achievementid = "encore_nodeath_easy",
                wxp = XWP_LEVEL2_5,
                testfn = function(user, data)
					-- end of round 3 - turtillus wave
					return data.round == 3 and TheWorld.components.lavaarenamvpstatstracker:GetStatTotal("deaths") == 0
				end,
            },
            {
                achievementid = "encore_nodeath_medium",
                wxp = XWP_LEVEL3,
                testfn = function(user, data)
					return TheWorld.components.lavaarenaevent:GetCurrentRound() == 4 and TheWorld.components.lavaarenamvpstatstracker:GetStatTotal("deaths") == 0
				end,
            },
            {
                achievementid = "encore_nodeath_hard",
                wxp = XWP_LEVEL4,
                testfn = function(user, data)
					return TheWorld.components.lavaarenamvpstatstracker:GetStatTotal("deaths") == 0
				end,
            },




        },
    },

    {
        category = "nodeaths",
        anycharacter = true,
        data =
        {
            {
                achievementid = "nodeaths_self",
                wxp = 20000,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("deaths", user.userid) == 0 end,
            },
            {
                achievementid = "nodeaths_team",
                wxp = 30000,
                endofmatchfn = function(user, data)
						return data.outcome.won and data.outcome.total_deaths == 0
					end,
            },
            {
                achievementid = "nodeaths_uniqueteam",
                wxp = 30000,
                endofmatchfn = function(user, data)
						return data.outcome.won and data.outcome.total_deaths == 0 and data.outcome.unique_team
					end,
            },
        },
    },
    {
        category = "wintime",
        anycharacter = true,
        data =
        {
            {
                achievementid = "wintime_30",
                wxp = 10000,
                endofmatchfn = function(user, data) return TestMatchTime(user, data, 30*60) end,
            },
            {
                achievementid = "wintime_25",
                wxp = 20000,
                endofmatchfn = function(user, data) return TestMatchTime(user, data, 25*60) end,
            },
            {
                achievementid = "wintime_20",
                wxp = 30000,
                endofmatchfn = function(user, data) return TestMatchTime(user, data, 20*60) end,
            },
        },
    },
    {
        category = "wilson",
        data =
        {
            {
                achievementid = "wilson_battlestandards",
                wxp = XWP_LEVEL1,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("standards", user.userid) >= 3 end,
            },
            {
                achievementid = "wilson_reviver",
                wxp = XWP_LEVEL2,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("corpsesrevived", user.userid) >= 1 end,
            },
            {
                achievementid = "wilson_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "willow",
        data =
        {
            {
                achievementid = "willow_meteor",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					scratchpad.willow_meteor = (scratchpad.willow_meteor or 0) + data.count
					return scratchpad.willow_meteor >= 40
				end,
            },
            {
                achievementid = "willow_moltenbolt",
                wxp = XWP_LEVEL2,
                testfn = function(user, completed) return completed == true end,
            },
            {
                achievementid = "willow_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wolfgang",
        data =
        {
            {
                achievementid = "wolfgang_guardsbroken",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					scratchpad.wolfgang_guardsbroken = (scratchpad.wolfgang_guardsbroken or 0) + data.count
					return scratchpad.wolfgang_guardsbroken >= 5
				end,
            },
            {
                achievementid = "wolfgang_nospinning",
                wxp = XWP_LEVEL2,
                testfn = function(user, completed) return completed == true end,
            },
            {
                achievementid = "wolfgang_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wendy",
        data =
        {
            {
                achievementid = "wendy_guardsbroken",
                wxp = XWP_LEVEL1,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("guardsbroken", user.userid) >= 5 end,
            },
            {
                achievementid = "wendy_outofharmsway",
                wxp = XWP_LEVEL2,
                testfn = function(user, data)
					if data.round == 4 then -- peghook round
						local statstracker = TheWorld.components.lavaarenamvpstatstracker
						if statstracker:GetStatTotal("blowdarts", user.userid) >= 150 and statstracker:GetStatTotal("player_damagetaken", user.userid) < 100 then
							return true
						end
					end
					return false
				end,
            },
            {
                achievementid = "wendy_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wx78",
        data =
        {
            {
                achievementid = "wx78_anvil",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					scratchpad.wx78_anvil = (scratchpad.wx78_anvil or 0) + data.count
					return scratchpad.wx78_anvil >= 50
				end,
            },
            {
                achievementid = "wx78_shocks",
                wxp = XWP_LEVEL2,
                testfn = function(user, completed) return completed end,
            },
            {
                achievementid = "wx78_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wickerbottom",
        data =
        {
            {
                achievementid = "wickerbottom_meteor",
                wxp = XWP_LEVEL1,
                testfn = function(user, data) return data.kills >= 1 end,
            },
            {
                achievementid = "wickerbottom_healing",
                wxp = XWP_LEVEL2,
                nosave = true,
                testfn = function(user, data, scratchpad)
					if scratchpad.wickerbottom_healing == nil then
						scratchpad.wickerbottom_healing = {}
					end
					local cur_time = GetTime()
					scratchpad.wickerbottom_healing[#scratchpad.wickerbottom_healing + 1] = cur_time
					if (cur_time - scratchpad.wickerbottom_healing[1]) > 60 then
						table.remove(scratchpad.wickerbottom_healing, 1)
					end

					return #scratchpad.wickerbottom_healing >= 3
                end,
            },
            {
                achievementid = "wickerbottom_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "woodie",
        data =
        {
            {
                achievementid = "woodie_lucychuck",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					scratchpad.woodie_lucychuck = (scratchpad.woodie_lucychuck or 0) + 1
					return scratchpad.woodie_lucychuck >= 20
				end,
            },
            {
                achievementid = "woodie_nospinning",
                wxp = XWP_LEVEL2,
                testfn = function(user, completed) return completed end,
            },
            {
                achievementid = "woodie_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wes",
        data =
        {
            {
                achievementid = "wes_battlestandards",
                wxp = XWP_LEVEL1,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("standards", user.userid) >= 3 end,
            },
            {
                achievementid = "wes_decoy",
                wxp = XWP_LEVEL2,
                endofmatchfn = function(user, data)
					local cards = data.statstracker:GetMvpCards()
					if cards ~= nil then
						for _, v in ipairs(cards) do
							if v.beststat[1] == "aggroheld2" and v.user.userid == user.userid and not v.participation then
								return true
							end
						end
					end
					return false
				end,
            },
            {
                achievementid = "wes_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "waxwell",
        data =
        {
            {
                achievementid = "waxwell_petrify",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					if TheWorld.components.lavaarenaevent:GetCurrentRound() <= 3 then -- before the fireball staff drops
						scratchpad.waxwell_petrify = (scratchpad.waxwell_petrify or 0) + data.count
						return scratchpad.waxwell_petrify >= 25
					end
					return false
				end,
            },
            {
                achievementid = "waxwell_minion_kill",
                wxp = XWP_LEVEL2,
                testfn = function(user, data) return data.target ~= nil and data.target:IsValid() and data.target.components.health ~= nil and data.target.components.health:IsDead() end,
            },
            {
                achievementid = "waxwell_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "wathgrithr",
        data =
        {
            {
                achievementid = "wathgrithr_flip",
                wxp = XWP_LEVEL1,
                endofmatchfn = function(user, data) return data.statstracker:GetStatTotal("turtillusflips", user.userid) >= 20 end,
            },
            {
                achievementid = "wathgrithr_battlecry",
                wxp = XWP_LEVEL2,
                testfn = function(user, data, scratchpad)
					if data.count >= 3 then
						scratchpad.wathgrithr_battlecry = (scratchpad.wathgrithr_battlecry or 0) + 1
						return scratchpad.wathgrithr_battlecry >= 5
					end
					return false
				end,
            },
            {
                achievementid = "wathgrithr_victory",
                wxp = XWP_VICTORY,
                icon = "achievement_forge_15",
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "webber",
        data =
        {
            {
                achievementid = "webber_darts",
                wxp = XWP_LEVEL1,
                nosave = true,
                testfn = function(user, data, scratchpad)
					if scratchpad.webber_darts == nil then
						scratchpad.webber_darts = {}
					end
					local cur_time = GetTime()
					scratchpad.webber_darts[#scratchpad.webber_darts + 1] = cur_time
					if (cur_time - scratchpad.webber_darts[1]) > 20 then
						table.remove(scratchpad.webber_darts, 1)
					end

					return #scratchpad.webber_darts >= 3
                end,
            },
            {
                achievementid = "webber_merciless",
                wxp = XWP_LEVEL2,
                endofmatchfn = function(user, data)
					local cards = data.statstracker:GetMvpCards()
					if cards ~= nil then
						for _, v in ipairs(cards) do
							if v.beststat[1] == "total_damagedealt2" and v.user.userid == user.userid and not v.participation then
								return true
							end
						end
					end
					return false
				end,
            },
            {
                achievementid = "webber_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
    {
        category = "winona",
        data =
        {
            {
                achievementid = "winona_allweapons",
                wxp = XWP_LEVEL1,
                testfn = function(user, data, scratchpad)
					if data.weapontype ~= nil then
						if scratchpad.winona_allweapons == nil then
							scratchpad.winona_allweapons = {}
						end
						scratchpad.winona_allweapons[data.weapontype] = true
						return GetTableSize(scratchpad.winona_allweapons) == 3
					end
					return false
				end,
            },
            {
                achievementid = "winona_altattacks",
                wxp = XWP_LEVEL2,
                endofmatchfn = function(user, data) return (data.statstracker:GetStatTotal("spellscast", user.userid) + data.statstracker:GetStatTotal("altattacks", user.userid)) >= 40 end,
            },
            {
                achievementid = "winona_victory",
                wxp = XWP_VICTORY,
                endofmatchfn = TestForVictory,
            },
        },
    },
}

for _, cat in ipairs(Lavaarena_Achievements) do
	for i, achievement in ipairs(cat.data) do
		achievement.prefab = (not cat.anycharacter) and cat.category or nil
		achievement.category = cat.category
	end
end

return
{
    seasons = { 1 },
	eventid = "lavaarena",
	achievements = Lavaarena_Achievements,
}