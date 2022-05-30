

local PLANT_DEFS = {}

PLANT_DEFS.randomseed	= {build = "farm_soil", bank = "farm_soil"}
PLANT_DEFS.asparagus	= {}
PLANT_DEFS.garlic		= {}
PLANT_DEFS.pumpkin		= {}
PLANT_DEFS.corn			= {build = "farm_plant_corn_build", bank = "farm_plant_pumpkin"}
PLANT_DEFS.onion		= {build = "farm_plant_onion_build", bank = "farm_plant_pumpkin"}
PLANT_DEFS.potato		= {}
PLANT_DEFS.dragonfruit	= {build = "farm_plant_dragonfruit_build", bank = "farm_plant_potato"}
PLANT_DEFS.pomegranate	= {build = "farm_plant_pomegranate_build", bank = "farm_plant_potato"}
PLANT_DEFS.eggplant		= {build = "farm_plant_eggplant_build", bank = "farm_plant_potato"}
PLANT_DEFS.tomato		= {}
PLANT_DEFS.watermelon	= {build = "farm_plant_watermelon_build", bank = "farm_plant_tomato"}
PLANT_DEFS.pepper		= {}
PLANT_DEFS.durian		= {build = "farm_plant_durian_build", bank = "farm_plant_pepper"}
PLANT_DEFS.carrot		= {}

local function MakeGrowTimes(germination_min, germination_max, full_grow_min, full_grow_max)
	local grow_time = {}

	-- germination time
	grow_time.seed		= {germination_min, germination_max}

	-- grow time
	grow_time.sprout	= {full_grow_min * 0.5, full_grow_max * 0.5}
	grow_time.small		= {full_grow_min * 0.3, full_grow_max * 0.3}
	grow_time.med		= {full_grow_min * 0.2, full_grow_max * 0.2}

	-- harvestable perish time
	grow_time.full		= 4 * TUNING.TOTAL_DAY_TIME
	grow_time.oversized	= 6 * TUNING.TOTAL_DAY_TIME
	grow_time.regrow	= {4 * TUNING.TOTAL_DAY_TIME, 5 * TUNING.TOTAL_DAY_TIME} -- min, max

	return grow_time
end
														-- germination min / max						full grow time min / max (will be devided between the growth stages)
PLANT_DEFS.randomseed.grow_time			= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		0, 0)

PLANT_DEFS.carrot.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.corn.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.potato.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.tomato.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
--
PLANT_DEFS.asparagus.grow_time			= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.eggplant.grow_time			= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.pumpkin.grow_time			= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.watermelon.grow_time			= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
--
PLANT_DEFS.dragonfruit.grow_time		= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.durian.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.garlic.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.onion.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.pepper.grow_time				= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)
PLANT_DEFS.pomegranate.grow_time		= MakeGrowTimes(12 * TUNING.SEG_TIME, 16 * TUNING.SEG_TIME,		4 * TUNING.TOTAL_DAY_TIME, 7 * TUNING.TOTAL_DAY_TIME)

-- moisture
local drink_low = TUNING.FARM_PLANT_DRINK_LOW
local drink_med = TUNING.FARM_PLANT_DRINK_MED
local drink_high = TUNING.FARM_PLANT_DRINK_HIGH
PLANT_DEFS.randomseed.moisture			= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
--
PLANT_DEFS.carrot.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.corn.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.potato.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.tomato.moisture				= {drink_rate = drink_high, min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
--
PLANT_DEFS.asparagus.moisture			= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.eggplant.moisture			= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.pumpkin.moisture				= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.watermelon.moisture			= {drink_rate = drink_high, min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
--
PLANT_DEFS.dragonfruit.moisture			= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.durian.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.garlic.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.onion.moisture				= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.pepper.moisture				= {drink_rate = drink_low,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}
PLANT_DEFS.pomegranate.moisture			= {drink_rate = drink_med,	min_percent = TUNING.FARM_PLANT_DROUGHT_TOLERANCE}

-- season preferences
PLANT_DEFS.randomseed.good_seasons		= {autumn = true,					spring = true				 }
--
PLANT_DEFS.carrot.good_seasons			= {autumn = true,	winter = true,	spring = true				 }
PLANT_DEFS.corn.good_seasons			= {autumn = true,					spring = true,	summer = true}
PLANT_DEFS.potato.good_seasons			= {autumn = true,	winter = true,	spring = true				 }
PLANT_DEFS.tomato.good_seasons			= {autumn = true,					spring = true,	summer = true}
--
PLANT_DEFS.asparagus.good_seasons		= {					winter = true,	spring = true				 }
PLANT_DEFS.eggplant.good_seasons		= {autumn = true,					spring = true				 }
PLANT_DEFS.pumpkin.good_seasons			= {autumn = true,	winter = true,								 }
PLANT_DEFS.watermelon.good_seasons		= {									spring = true,	summer = true}
--
PLANT_DEFS.dragonfruit.good_seasons		= {									spring = true,	summer = true}
PLANT_DEFS.durian.good_seasons			= {									spring = true				 }
PLANT_DEFS.garlic.good_seasons			= {autumn = true,	winter = true,	spring = true,	summer = true}
PLANT_DEFS.onion.good_seasons			= {autumn = true,					spring = true,	summer = true}
PLANT_DEFS.pepper.good_seasons			= {autumn = true,									summer = true}
PLANT_DEFS.pomegranate.good_seasons		= {									spring = true,	summer = true}

-- Nutrients
local S = TUNING.FARM_PLANT_CONSUME_NUTRIENT_LOW
local M = TUNING.FARM_PLANT_CONSUME_NUTRIENT_MED
local L = TUNING.FARM_PLANT_CONSUME_NUTRIENT_HIGH

PLANT_DEFS.randomseed.nutrient_consumption		= {0, 0, 0}
--
PLANT_DEFS.carrot.nutrient_consumption			= {M, 0, 0}
PLANT_DEFS.corn.nutrient_consumption			= {0, M, 0}
PLANT_DEFS.potato.nutrient_consumption			= {0, 0, M}
PLANT_DEFS.tomato.nutrient_consumption			= {S, S, 0}
--
PLANT_DEFS.asparagus.nutrient_consumption		= {0, M, 0}
PLANT_DEFS.eggplant.nutrient_consumption		= {0, 0, M}
PLANT_DEFS.pumpkin.nutrient_consumption			= {M, 0, 0}
PLANT_DEFS.watermelon.nutrient_consumption		= {0, S, S}
--
PLANT_DEFS.dragonfruit.nutrient_consumption		= {0, 0, L}
PLANT_DEFS.durian.nutrient_consumption			= {0, L, 0}
PLANT_DEFS.garlic.nutrient_consumption			= {0, L, 0}
PLANT_DEFS.onion.nutrient_consumption			= {L, 0, 0}
PLANT_DEFS.pepper.nutrient_consumption			= {0, 0, L}
PLANT_DEFS.pomegranate.nutrient_consumption		= {L, 0, 0}

for _, data in pairs(PLANT_DEFS) do
	data.nutrient_restoration = {}
	for i = 1, #data.nutrient_consumption do
		data.nutrient_restoration[i] = data.nutrient_consumption[i] == 0 or nil
	end
end

-- Killjoys
PLANT_DEFS.randomseed.max_killjoys_tolerance	= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
--
PLANT_DEFS.carrot.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.corn.max_killjoys_tolerance			= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.potato.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.tomato.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
--
PLANT_DEFS.asparagus.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.eggplant.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.pumpkin.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.watermelon.max_killjoys_tolerance	= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
--
PLANT_DEFS.dragonfruit.max_killjoys_tolerance	= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.durian.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.garlic.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.onion.max_killjoys_tolerance			= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.pepper.max_killjoys_tolerance		= TUNING.FARM_PLANT_KILLJOY_TOLERANCE
PLANT_DEFS.pomegranate.max_killjoys_tolerance	= TUNING.FARM_PLANT_KILLJOY_TOLERANCE

-- Misc
PLANT_DEFS.randomseed.is_randomseed = true
PLANT_DEFS.dragonfruit.fireproof = true

-- Weight data							min			max			sigmoid%
PLANT_DEFS.carrot.weight_data		= { 361.51,     506.04,     .28 }
PLANT_DEFS.corn.weight_data			= { 384.90,     444.47,     .34 }
PLANT_DEFS.potato.weight_data		= { 340.20,     582.64,     .48 }
PLANT_DEFS.tomato.weight_data		= { 328.14,     455.31,     .22 }
--
PLANT_DEFS.asparagus.weight_data	= { 323.11,     398.46,     .06 }
PLANT_DEFS.eggplant.weight_data		= { 372.82,     465.65,     .26 }
PLANT_DEFS.pumpkin.weight_data		= { 424.55,     659.01,     .39 }
PLANT_DEFS.watermelon.weight_data	= { 462.37,     688.45,     .93 }
--
PLANT_DEFS.dragonfruit.weight_data	= { 384.59,     662.77,     .18 }
PLANT_DEFS.durian.weight_data		= { 525.14,     592.92,     .21 }
PLANT_DEFS.garlic.weight_data		= { 421.89,     510.10,     .15 }
PLANT_DEFS.onion.weight_data		= { 463.85,     518.73,     .32 }
PLANT_DEFS.pepper.weight_data		= { 368.55,     486.32,     .11 }
PLANT_DEFS.pomegranate.weight_data	= { 404.38,     547.80,     .48 }

PLANT_DEFS.carrot.pictureframeanim = {anim = "emote_happycheer", time = 12*FRAMES}
PLANT_DEFS.corn.pictureframeanim = {anim = "emoteXL_loop_dance6", time = 31*FRAMES}
PLANT_DEFS.potato.pictureframeanim = {anim = "emoteXL_loop_dance7", time = 37*FRAMES}
PLANT_DEFS.tomato.pictureframeanim = {anim = "emote_strikepose", time = 23*FRAMES}
PLANT_DEFS.asparagus.pictureframeanim = {anim = "emote_flex", time = 21*FRAMES}
PLANT_DEFS.eggplant.pictureframeanim = {anim = "emoteXL_loop_dance8", time = 93*FRAMES}
PLANT_DEFS.pumpkin.pictureframeanim = {anim = "emote_strikepose", time = 47*FRAMES}
PLANT_DEFS.watermelon.pictureframeanim = {anim = "emote_jumpcheer", time = 19*FRAMES}
PLANT_DEFS.dragonfruit.pictureframeanim = {anim = "emoteXL_loop_dance0", time = 7*FRAMES}
PLANT_DEFS.durian.pictureframeanim = {anim = "emoteXL_loop_dance6", time = 97*FRAMES}
PLANT_DEFS.garlic.pictureframeanim = {anim = "emoteXL_waving3", time = 18*FRAMES}
PLANT_DEFS.onion.pictureframeanim = {anim = "emote_waving", time = 13*FRAMES}
PLANT_DEFS.pepper.pictureframeanim = {anim = "emote_swoon", time = 37*FRAMES}
PLANT_DEFS.pomegranate.pictureframeanim = {anim = "emoteXL_loop_dance8", time = 27*FRAMES}

-- Sounds
PLANT_DEFS.randomseed.sounds =
{
}

PLANT_DEFS.asparagus.sounds =
{
	grow_oversized = "farming/common/farm/asparagus/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}

PLANT_DEFS.garlic.sounds =
{
	grow_oversized = "farming/common/farm/garlic/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}

PLANT_DEFS.pumpkin.sounds =
{
	grow_oversized = "farming/common/farm/pumpkin/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.corn.sounds = PLANT_DEFS.pumpkin.sounds
PLANT_DEFS.onion.sounds = PLANT_DEFS.pumpkin.sounds

PLANT_DEFS.potato.sounds =
{
	grow_oversized = "farming/common/farm/potato/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.dragonfruit.sounds = PLANT_DEFS.potato.sounds
PLANT_DEFS.pomegranate.sounds = PLANT_DEFS.potato.sounds
PLANT_DEFS.eggplant.sounds = PLANT_DEFS.potato.sounds

PLANT_DEFS.tomato.sounds =
{
	grow_oversized = "farming/common/farm/tomato/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.watermelon.sounds = PLANT_DEFS.tomato.sounds

PLANT_DEFS.pepper.sounds =
{
	grow_oversized = "farming/common/farm/pepper/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}
PLANT_DEFS.durian.sounds = PLANT_DEFS.pepper.sounds

PLANT_DEFS.carrot.sounds =
{
	grow_oversized = "farming/common/farm/carrot/grow_oversized",
	grow_full = "farming/common/farm/grow_full",
	grow_rot = "farming/common/farm/rot",
}



------------------------------------------------
for veggie, data in pairs(PLANT_DEFS) do
	data.prefab = "farm_plant_"..veggie

	if data.bank == nil then data.bank = "farm_plant_"..veggie end
	if data.build == nil then data.build = "farm_plant_"..veggie end

	if data.is_randomseed then
		data.seed = "seeds"
		data.plant_type_tag = "farm_plant_randomseed"
		data.family_min_count = 0
	else
		data.product = veggie
		data.product_oversized = veggie.."_oversized"
		data.seed = veggie.."_seeds"
		data.plant_type_tag = "farm_plant_"..veggie -- note: this is used for pollin_sources stress

		data.loot_oversized_rot = {"spoiled_food", "spoiled_food", "spoiled_food", data.seed, "fruitfly", "fruitfly"}

		-- all plants are going to use the same settings for now, maybe some will have special cases
		if data.family_min_count == nil then data.family_min_count = TUNING.FARM_PLANT_SAME_FAMILY_MIN end
		if data.family_check_dist == nil then data.family_check_dist = TUNING.FARM_PLANT_SAME_FAMILY_RADIUS end

		if data.stage_netvar == nil then
			data.stage_netvar = net_tinybyte
		end

		if data.plantregistryinfo == nil then
			data.plantregistryinfo = {
				{
					text = "seed",
					anim = "crop_seed",
					grow_anim = "grow_seed",
					learnseed = true,
					growing = true,
				},
				{
					text = "sprout",
					anim = "crop_sprout",
					grow_anim = "grow_sprout",
					growing = true,
				},
				{
					text = "small",
					anim = "crop_small",
					grow_anim = "grow_small",
					growing = true,
				},
				{
					text = "medium",
					anim = "crop_med",
					grow_anim = "grow_med",
					growing = true,
				},
				{
					text = "grown",
					anim = "crop_full",
					grow_anim = "grow_full",
					revealplantname = true,
					fullgrown = true,
				},
				{
					text = "oversized",
					anim = "crop_oversized",
					grow_anim = "grow_oversized",
					revealplantname = true,
					fullgrown = true,
					hidden = true,
				},
				{
					text = "rotting",
					anim = "crop_rot",
					grow_anim = "grow_rot",
					stagepriority = -100,
					is_rotten = true,
					hidden = true,
				},
				{
					text = "oversized_rotting",
					anim = "crop_rot_oversized",
					grow_anim = "grow_rot_oversized",
					stagepriority = -100,
					is_rotten = true,
					hidden = true,
				},
			}
		end
		if data.plantregistrywidget == nil then
			--the path to the widget
			data.plantregistrywidget = "widgets/redux/farmplantpage"
		end
		if data.plantregistrysummarywidget == nil then
			data.plantregistrysummarywidget = "widgets/redux/farmplantsummarywidget"
		end
		if data.pictureframeanim == nil then
			data.pictureframeanim = {anim = "emoteXL_happycheer", time = 0.5} --fallback data
		end
	end
end

setmetatable(PLANT_DEFS, {
	__newindex = function(t, k, v)
		v.modded = true
		rawset(t, k, v)
	end,
})


return {PLANT_DEFS = PLANT_DEFS}