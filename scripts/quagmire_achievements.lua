

local function TestMatchTime(user, data, max_time)
	return data.outcome.won and data.outcome.time <= max_time
end

local function TestForVictory(user, data)
	return data.outcome.won
end

local WXP_LEVEL1 = 500
local WXP_LEVEL2 = 1000
local WXP_LEVEL2_5 = 5000
local WXP_LEVEL3 = 10000
local WXP_LEVEL4 = 20000
local WXP_LEVEL5 = 30000

local meat_ingredients =
{
	"quagmire_salmon", "quagmire_salmon_cooked",
	"quagmire_crabmeat", "quagmire_crabmeat_cooked",
	"quagmire_smallmeat", "quagmire_cookedsmallmeat",
	"meat", "cookedmeat",
}


local Quagmire_Achievements =
{
--[[
    {
        category = "example",
        anycharacter = true,
        data =
        {
            {
                achievementid = "example",
                wxp = WXP_LEVEL3,
                shared_progress_fn = function(data, shared_scratchpad)
					--shared_scratchpad.encore_turtillus = (shared_scratchpad.encore_turtillus or 0) + 1
                end,
                testfn = function(user, data, scratchpad, shared_scratchpad)
					--return data.round == 3 and (shared_scratchpad.encore_turtillus == nil or shared_scratchpad.encore_turtillus <= 3)
				end,
                endofmatchfn = function(user, data, scratchpad, shared_scratchpad)
					--return data.statstracker:GetStatTotal("deaths", user.userid) == 0
				end,

            },
        },
    },
]]
    {
        category = "encore",
        anycharacter = true,
        data =
        {
            {
                achievementid = "quag_encore_nomatches",
                wxp = WXP_LEVEL5,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_success") == 0
				end,
            },
            {
                achievementid = "quag_encore_notrees",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.statstracker:GetStatTotal("logs") == 0
				end,
			},
            {
                achievementid = "quag_encore_meaty",
                wxp = WXP_LEVEL4,
                shared_progress_fn = function(data, shared_scratchpad)
					if not shared_scratchpad.quag_encore_meaty_failed and data.product ~= "quagmire_syrup" then
						for _, ingredient in ipairs(data.ingredients) do
							if table.contains(meat_ingredients, ingredient) then
								return
							end
						end
						shared_scratchpad.quag_encore_meaty_failed = true
					end
                end,
                endofmatchfn = function(user, data, scratchpad, shared_scratchpad)
					return data.outcome.won and not shared_scratchpad.quag_encore_meaty_failed
				end,
			},
            {
                achievementid = "quag_encore_veggie",
                wxp = WXP_LEVEL4,
                shared_progress_fn = function(data, shared_scratchpad)
					if not shared_scratchpad.quag_encore_veggie_failed then
						for _, ingredient in ipairs(data.ingredients) do
							if table.contains(meat_ingredients, ingredient) then
								shared_scratchpad.quag_encore_veggie_failed = true
								return
							end
						end
					end
                end,
                endofmatchfn = function(user, data, scratchpad, shared_scratchpad)
					return data.outcome.won and not shared_scratchpad.quag_encore_veggie_failed
				end,
			},
			{
				achievementid = "quag_encore_allcooks",
				wxp = WXP_LEVEL2_5,
				endofmatchfn = function(user, data)
					if GetTableSize(data.statstracker._seenplayers) >= 3 then
						for userid, player in pairs(data.statstracker._seenplayers) do
							if data.statstracker:GetStatTotal("meals_made", userid) < 2 then
								return false
							end
						end
						return true
					end
					return false
				end,
			},
			{
				achievementid = "quag_encore_all_stations_large",
				wxp = WXP_LEVEL2_5,
				testfn = function(user, data, scratchpad)
					if scratchpad.quag_encore_all_stations_large == nil then
						scratchpad.quag_encore_all_stations_large = {}
					end
					if data.stewer ~= nil and data.stewer:IsValid() and data.stewer.components.container ~= nil and data.stewer.components.container:GetNumSlots() == 4 then
						scratchpad.quag_encore_all_stations_large[data.recipe.station] = true
					end
					return GetTableSize(scratchpad.quag_encore_all_stations_large) == 3
				end,
			},
			{
				achievementid = "quag_encore_tribute_coin3",
				wxp = WXP_LEVEL2_5,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("coins")[3] >= 3
				end,
			},
			{
				achievementid = "quag_encore_tribute_coin2",
				wxp = WXP_LEVEL2,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("coins")[2] >= 3
				end,
			},
		},
	},


    {
        category = "victory",
        anycharacter = true,
        data =
        {
            {
                achievementid = "quag_win_first",
                wxp = WXP_LEVEL3,
                endofmatchfn = function(user, data)
					return data.outcome.won
				end,
            },
            {
                achievementid = "quag_win_nosilver",
                wxp = WXP_LEVEL5,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_silvered") == 0
				end,
            },
            {
                achievementid = "quag_win_nosalt",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_salted") == 0
				end,
            },
            {
                achievementid = "quag_win_perfect",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_failed") == 0
				end,
            },
            {
                achievementid = "quag_win_nodups",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and not data.analytics:GetGaveDuplicateTributed()
				end,
            },
            {
                achievementid = "quag_win_noburnt",
                wxp = WXP_LEVEL3,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.statstracker:GetStatTotal("meals_burnt") == 0
				end,
            },
            {
                achievementid = "quag_win_veryfast",
                wxp = WXP_LEVEL5,
                endofmatchfn = function(user, data)
					return data.outcome.won and (data.analytics:GetMatchStat("tributes_success") + data.analytics:GetMatchStat("tributes_failed")) <= 7
				end,
            },
            {
                achievementid = "quag_win_fast",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and (data.analytics:GetMatchStat("tributes_success") + data.analytics:GetMatchStat("tributes_failed")) <= 10
				end,
            },
            {
                achievementid = "quag_win_verylong",
                wxp = WXP_LEVEL5,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_success") >= 18
				end,
            },
            {
                achievementid = "quag_win_long",
                wxp = WXP_LEVEL4,
                endofmatchfn = function(user, data)
					return data.outcome.won and data.analytics:GetMatchStat("tributes_success") >= 15
				end,
            },
        },
	},
	{
		category = "tributes",
		anycharacter = true,
		data =
		{
			{
				achievementid = "tribute_fast",
				wxp = WXP_LEVEL3,
                nosave = true,
                testfn = function(user, data, scratchpad)
					if scratchpad.tribute_fast == nil then
						scratchpad.tribute_fast = {}
					end
					if data.matchedcraving ~= nil then
						local cur_time = GetTime()
						scratchpad.tribute_fast[#scratchpad.tribute_fast + 1] = cur_time
						if (cur_time - scratchpad.tribute_fast[1]) > 180 then
							table.remove(scratchpad.tribute_fast, 1)
						end
					end
					return #scratchpad.tribute_fast >= 3
                end,
			},
			{
				achievementid = "tribute_coin4",
				wxp = WXP_LEVEL2_5,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("coins")[4] > 0
				end,
			},
			{
				achievementid = "tribute_coin3",
				wxp = WXP_LEVEL2,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("coins")[3] > 0
				end,
			},
			{
				achievementid = "tribute_coin2",
				wxp = WXP_LEVEL1,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("coins")[2] > 0
				end,
			},
			{
				achievementid = "tribute_num_high",
				wxp = WXP_LEVEL2_5,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("tributes_success") >= 9
				end,
			},
			{
				achievementid = "tribute_num_med",
				wxp = WXP_LEVEL2,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("tributes_success") >= 6
				end,
			},
			{
				achievementid = "tribute_num_low",
				wxp = WXP_LEVEL1,
				endofmatchfn = function(user, data)
					return data.analytics:GetMatchStat("tributes_success") >= 3
				end,
			},
		},
	},
	{
		category = "chef",
		anycharacter = true,
		data =
		{
			{
				achievementid = "cook_full_book",
				wxp = WXP_LEVEL5,
				endofmatchfn = function(user, data)
					return false
				end,
			},
			{
				achievementid = "cook_noburnt",
				wxp = WXP_LEVEL2,
				endofmatchfn = function(user, data)
					return data.statstracker:GetStatTotal("meals_made", user.userid) >= 6 and data.statstracker:GetStatTotal("meals_burnt", user.userid) == 0
				end,
			},
			{
				achievementid = "cook_first",
				wxp = WXP_LEVEL1,
				endofmatchfn = function(user, data)
					return data.statstracker:GetStatTotal("meals_made", user.userid) > 0
				end,
			},
			{
				achievementid = "cook_large",
				wxp = WXP_LEVEL1,
				testfn = function(user, data)
					return #data.recipe.ingredients == 4
				end,
			},
			{
				achievementid = "cook_all_stations",
				wxp = WXP_LEVEL1,
				testfn = function(user, data, scratchpad)
					if scratchpad.cook_all_stations == nil then
						scratchpad.cook_all_stations = {}
					end
					scratchpad.cook_all_stations[data.recipe.station] = true
					return GetTableSize(scratchpad.cook_all_stations) == 3
				end,
			},
			{
				achievementid = "cook_silver",
				wxp = WXP_LEVEL1,
				testfn = function(user, completed)
					return completed == true
				end,
			},
		},
	},
	{
		category = "farmer",
		anycharacter = true,
		data =
		{
			{
				achievementid = "farm_sow",
				wxp = WXP_LEVEL2,
				endofmatchfn = function(user, data)
					return data.statstracker:GetStatTotal("crops_planted", user.userid) >= 30
				end,
			},
			{
				achievementid = "farm_fertilize",
				wxp = WXP_LEVEL1,
				testfn = function(user, data, scratchpad)
					scratchpad.farm_fertilize = (scratchpad.farm_fertilize or 0) + 1
					return scratchpad.farm_fertilize >= 20
				end,
			},
			{
				achievementid = "farm_till",
				wxp = WXP_LEVEL1,
				testfn = function(user, data, scratchpad)
					scratchpad.farm_till = (scratchpad.farm_till or 0) + 1
					return scratchpad.farm_till >= 50
				end,
			},
			{
				achievementid = "farm_sow_all",
				wxp = WXP_LEVEL1,
				testfn = function(user, seed_prefab, scratchpad)
					if scratchpad.farm_sow_all == nil then
						scratchpad.farm_sow_all = {}
					end
					scratchpad.farm_sow_all[seed_prefab] = true
					return GetTableSize(scratchpad.farm_sow_all) == 7
				end,
			},
		},
	},
	{
		category = "gatherer",
		anycharacter = true,
		data =
		{
			{
				achievementid = "gather_crab",
				wxp = WXP_LEVEL2,
				testfn = function(user, completed)
					return completed == true
				end,
			},
			{
				achievementid = "gather_logs",
				wxp = WXP_LEVEL1,
				endofmatchfn = function(user, data)
					return data.statstracker:GetStatTotal("logs", user.userid) >= 80
				end,
			},
			{
				achievementid = "gather_safe",
				wxp = WXP_LEVEL1,
				testfn = function(user, completed)
					return completed == true
				end,
			},
			{
				achievementid = "gather_sap",
				wxp = WXP_LEVEL1,
				testfn = function(user, sap_prefab, scratchpad)
					if sap_prefab == "quagmire_sap" then
						scratchpad.gather_sap = (scratchpad.gather_sap or 0) + 1
						return scratchpad.gather_sap >= 9
					end
					return false
				end,
			},
			{
				achievementid = "gather_spice",
				wxp = WXP_LEVEL1,
				testfn = function(user, data, scratchpad)
					if data.recipe.product == "quagmire_spotspice_ground" then
						scratchpad.gather_spice = (scratchpad.gather_spice or 0) + 1
						return scratchpad.gather_spice >= 5
					end
					return false
				end,
			},
		},
	},
}

-- store the category in each achievement
for _, cat in ipairs(Quagmire_Achievements) do
	for i, achievement in ipairs(cat.data) do
		achievement.prefab = (not cat.anycharacter) and cat.category or nil
		achievement.category = cat.category
	end
end

return
{
    seasons = { 1 },
	eventid = "quagmire",
	achievements = Quagmire_Achievements,
}