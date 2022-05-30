require("recipe")

mod_protect_Recipe = false

PROTOTYPER_DEFS =
{
	none						= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_none.tex",				is_crafting_station = false},

	researchlab					= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_science.tex",			is_crafting_station = false},
	researchlab2				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_science.tex",			is_crafting_station = false},
	researchlab4				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_arcane.tex",			is_crafting_station = false},
	researchlab3				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_arcane.tex",			is_crafting_station = false},
	seafaring_prototyper		= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_seafaring.tex",			is_crafting_station = false},
	tacklestation				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_fishing.tex",			is_crafting_station = false},
	turfcraftingstation			= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_turfcrafting.tex",		is_crafting_station = false},

    ancient_altar				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_crafting_table.tex",	is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.ANCIENT},
    ancient_altar_broken		= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_crafting_table.tex",	is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.ANCIENT},
	critterlab					= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_orphanage.tex",			is_crafting_station = true,		action_str = "CRITTERS",	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.ORPHANAGE},
	cartographydesk				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_cartography.tex",		is_crafting_station = true,		action_str = "CARTOGRAPHY",	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CARTOGRAPHY},
	sculptingtable				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_sculpt.tex",			is_crafting_station = true,		action_str = "SCULPTING",	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.SCULPTING},
	moonrockseed				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_celestial.tex",			is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL},
	moon_altar					= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_celestial.tex",			is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL},
	moon_altar_cosmic			= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_celestial.tex",			is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL},
	moon_altar_astral			= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_celestial.tex",			is_crafting_station = true,									filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL},
	hermitcrab					= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_hermitcrab_shop.tex",	is_crafting_station = true,		action_str = "TRADE",		filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.HERMITCRABSHOP},

	waxwelljournal				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_shadow.tex",			is_crafting_station = true,		action_str = "READ",		filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.SHADOW},
	portableblender				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_foodprocessing.tex",	is_crafting_station = true,		action_str = "USE",			filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.FOODPROCESSING},

	carnival_host				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_host.tex",				is_crafting_station = true,		action_str = "TRADE",		filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CARNIVAL_HOSTSHOP},
	carnival_prizebooth			= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_prizebooth.tex",		is_crafting_station = true,		action_str = "TRADE",		filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.CARNIVAL_PRIZESHOP},
	wintersfeastoven			= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_feast_oven.tex",		is_crafting_station = true,		action_str = "COOKING",		filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.WINTERSFEASTCOOKING},
	madscience_lab				= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_madscience_lab.tex",	is_crafting_station = true,		action_str = "EXPERIEMENT",	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.MADSCIENCE},
	perdshrine					= {icon_atlas = CRAFTING_ICONS_ATLAS, icon_image = "station_perd_offering.tex",		is_crafting_station = true,		action_str = "OFFERING",	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.YOT_SHRINE_DOFFERING},
}
PROTOTYPER_DEFS.wargshrine = PROTOTYPER_DEFS.perdshrine
PROTOTYPER_DEFS.pigshrine = PROTOTYPER_DEFS.perdshrine
PROTOTYPER_DEFS.yotc_carratshrine = PROTOTYPER_DEFS.perdshrine
PROTOTYPER_DEFS.yotb_beefaloshrine = PROTOTYPER_DEFS.perdshrine
PROTOTYPER_DEFS.yot_catcoonshrine = PROTOTYPER_DEFS.perdshrine



local function IsMarshLand(pt, rot)
	local ground_tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
	return ground_tile and ground_tile == GROUND.MARSH
end

local function telebase_testfn(pt, rot)
    --See telebase.lua
    local telebase_parts =
    {
        { x = -1.6, z = -1.6 },
        { x =  2.7, z = -0.8 },
        { x = -0.8, z =  2.7 },
    }
    rot = (45 - rot) * DEGREES
    local sin_rot = math.sin(rot)
    local cos_rot = math.cos(rot)
    for i, v in ipairs(telebase_parts) do
        if not TheWorld.Map:IsVisualGroundAtPoint(pt.x + v.x * cos_rot - v.z * sin_rot, pt.y, pt.z + v.z * cos_rot + v.x * sin_rot) then
            return false
        end
    end
    return true
end


-- Willow
Recipe2("lighter",						{Ingredient("rope", 1), Ingredient("goldnugget", 1), Ingredient("petals", 3)},					TECH.NONE,				{builder_tag="pyromaniac"})
Recipe2("bernie_inactive",				{Ingredient("beardhair", 2), Ingredient("beefalowool", 2), Ingredient("silk", 2)},				TECH.NONE,				{builder_tag="pyromaniac"})

-- Warly
Recipe2("portablecookpot_item",			{Ingredient("goldnugget", 2), Ingredient("charcoal", 6), Ingredient("twigs", 6)},				TECH.NONE,				{builder_tag="masterchef"})
Recipe2("portableblender_item",			{Ingredient("goldnugget", 2), Ingredient("transistor", 2), Ingredient("twigs", 4)},				TECH.NONE,				{builder_tag="masterchef"})
Recipe2("portablespicer_item",			{Ingredient("goldnugget", 2), Ingredient("cutstone", 3), Ingredient("twigs", 6)},				TECH.NONE,				{builder_tag="masterchef"})
Recipe2("spicepack",					{Ingredient("cutgrass", 4), Ingredient("twigs", 4), Ingredient("nitre", 2)},					TECH.NONE,				{builder_tag="masterchef"})
Recipe2("spice_garlic",					{Ingredient("garlic", 3, nil, nil, "quagmire_garlic.tex")},										TECH.FOODPROCESSING_ONE,{builder_tag="professionalchef", numtogive=2, nounlock=true})
Recipe2("spice_sugar",					{Ingredient("honey", 3)},																		TECH.FOODPROCESSING_ONE,{builder_tag="professionalchef", numtogive=2, nounlock=true})
Recipe2("spice_chili",					{Ingredient("pepper", 3)},																		TECH.FOODPROCESSING_ONE,{builder_tag="professionalchef", numtogive=2, nounlock=true})
Recipe2("spice_salt",					{Ingredient("saltrock", 3)},																	TECH.FOODPROCESSING_ONE,{builder_tag="professionalchef", numtogive=2, nounlock=true})

-- Wurt
Recipe2("mermhouse_crafted",			{Ingredient("boards", 4), Ingredient("cutreeds", 3), Ingredient("pondfish", 2)},				TECH.SCIENCE_ONE,		{builder_tag="merm_builder", placer="mermhouse_crafted_placer", testfn=IsMarshLand})
Recipe2("mermthrone_construction",		{Ingredient("boards", 5), Ingredient("rope", 5)},												TECH.SCIENCE_ONE,		{builder_tag="merm_builder", placer="mermthrone_construction_placer", testfn=IsMarshLand})
Recipe2("mermwatchtower",				{Ingredient("boards", 5), Ingredient("tentaclespots", 1), Ingredient("spear", 2)},				TECH.SCIENCE_ONE,		{builder_tag="merm_builder", placer="mermwatchtower_placer", testfn=IsMarshLand})
Recipe2("wurt_turf_marsh",				{Ingredient("cutreeds", 1), Ingredient("spoiled_food", 2)},										TECH.NONE,				{builder_tag="merm_builder", product="turf_marsh", numtogive = 4})
Recipe2("mermhat", 						{Ingredient("pondfish", 1), Ingredient("cutreeds", 1), Ingredient("twigs", 2)}, 				TECH.NONE,				{builder_tag="merm_builder"})

-- Wendy
Recipe2("abigail_flower",				{Ingredient("ghostflower", 1), Ingredient("nightmarefuel", 1)},									TECH.NONE,				{builder_tag="ghostlyfriend"})
Recipe2("sisturn",						{Ingredient("cutstone", 3), Ingredient("boards", 3), Ingredient("ash", 1)},						TECH.NONE,				{builder_tag="ghostlyfriend", placer="sisturn_placer"})
Recipe2("ghostlyelixir_slowregen",		{Ingredient("spidergland", 1), Ingredient("ghostflower", 1)},									TECH.NONE,				{builder_tag="elixirbrewer"})
Recipe2("ghostlyelixir_fastregen",		{Ingredient("reviver", 1), Ingredient("ghostflower", 3)},										TECH.NONE,				{builder_tag="elixirbrewer"})
Recipe2("ghostlyelixir_shield",			{Ingredient("log", 1), Ingredient("ghostflower", 1)},											TECH.NONE,				{builder_tag="elixirbrewer"})
Recipe2("ghostlyelixir_retaliation",	{Ingredient("livinglog", 1),Ingredient("ghostflower", 3)},										TECH.NONE,				{builder_tag="elixirbrewer"})
Recipe2("ghostlyelixir_attack",			{Ingredient("stinger", 1), Ingredient("ghostflower", 3)},										TECH.NONE,				{builder_tag="elixirbrewer"})
Recipe2("ghostlyelixir_speed",			{Ingredient("honey", 1), Ingredient("ghostflower", 1)},											TECH.NONE,				{builder_tag="elixirbrewer"})

-- Woodie
Recipe2("wereitem_goose",				{Ingredient("monstermeat", 3), Ingredient("seeds", 3)},											TECH.NONE,				{builder_tag="werehuman"})
Recipe2("wereitem_beaver",				{Ingredient("monstermeat", 3), Ingredient("log", 2)},											TECH.NONE,				{builder_tag="werehuman"})
Recipe2("wereitem_moose",				{Ingredient("monstermeat", 3), Ingredient("cutgrass", 2)},										TECH.NONE,				{builder_tag="werehuman"})

-- Wathgrithr
Recipe2("spear_wathgrithr",				{Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("goldnugget", 2)},											TECH.NONE,		{builder_tag="valkyrie"})
Recipe2("wathgrithrhat",				{Ingredient("goldnugget", 2), Ingredient("rocks", 2)},																	TECH.NONE,		{builder_tag="valkyrie"})
Recipe2("battlesong_durability",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("sewing_kit", 1)},								TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_healthgain",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("amulet", 1)}, 									TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_sanitygain",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("moonbutterflywings", 1)}, 						TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_sanityaura",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("nightmare_timepiece", 1)}, 						TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_fireresistance",	{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("oceanfish_small_9_inv", 1)}, 					TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_instant_taunt",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("tomato", 1, nil, nil, "quagmire_tomato.tex")}, 	TECH.NONE,		{builder_tag="battlesinger"})
Recipe2("battlesong_instant_panic",		{Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("purplegem", 1)}, 								TECH.NONE,		{builder_tag="battlesinger"})

-- Walter
Recipe2("slingshot",					{Ingredient("twigs", 1), Ingredient("mosquitosack", 2)},										TECH.NONE,				{builder_tag="pebblemaker"})
Recipe2("walterhat", 					{Ingredient("silk", 4)}, 																		TECH.NONE,				{builder_tag="pinetreepioneer"})
Recipe2("portabletent_item",			{Ingredient("bedroll_straw", 1), Ingredient("twigs", 4), Ingredient("rope", 2)},				TECH.SCIENCE_ONE,		{builder_tag="pinetreepioneer"})
Recipe2("slingshotammo_rock",			{Ingredient("rocks", 1)},											   							TECH.NONE,				{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_gold",			{Ingredient("goldnugget", 1)},									   								TECH.SCIENCE_ONE,		{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_marble",			{Ingredient("marble", 1)},										   								TECH.SCIENCE_TWO,		{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_poop",			{Ingredient("poop", 1)},											   							TECH.SCIENCE_ONE,		{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_freeze",			{Ingredient("moonrocknugget", 1), Ingredient("bluegem", 1)},		   							TECH.MAGIC_TWO,			{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_slow",			{Ingredient("moonrocknugget", 1), Ingredient("purplegem", 1)},	   								TECH.MAGIC_THREE,		{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })
Recipe2("slingshotammo_thulecite",		{Ingredient("thulecite_pieces", 1), Ingredient("nightmarefuel", 1)}, 							TECH.ANCIENT_TWO,		{builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, nounlock=true})

-- Wolfgang
Recipe2("mighty_gym",					{Ingredient("boards", 4), Ingredient("cutstone", 2), Ingredient("rope", 3)},					TECH.SCIENCE_ONE,		{builder_tag="strongman", placer="mighty_gym_placer"})
Recipe2("dumbbell",						{Ingredient("rocks", 4), Ingredient("twigs", 1)},												TECH.NONE,				{builder_tag="strongman"})
Recipe2("dumbbell_golden",				{Ingredient("goldnugget", 4), Ingredient("twigs", 1)},											TECH.NONE,				{builder_tag="strongman"})
Recipe2("dumbbell_marble",				{Ingredient("marble", 4), Ingredient("twigs", 1)},												TECH.NONE,				{builder_tag="strongman"})
Recipe2("dumbbell_gem",					{Ingredient("thulecite", 2), Ingredient("purplegem", 1), Ingredient("twigs", 1)},				TECH.NONE,				{builder_tag="strongman"})

-- Wickerbottom
Recipe2("book_birds",					{Ingredient("papyrus", 2), Ingredient("bird_egg", 2)},											TECH.NONE,				{builder_tag="bookbuilder"})
Recipe2("book_horticulture",			{Ingredient("papyrus", 2), Ingredient("seeds", 5), Ingredient("poop", 5)},						TECH.SCIENCE_ONE,		{builder_tag="bookbuilder"})
Recipe2("book_silviculture",			{Ingredient("papyrus", 2), Ingredient("livinglog", 1)},											TECH.SCIENCE_THREE,		{builder_tag="bookbuilder"})
Recipe2("book_sleep",					{Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2)},										TECH.MAGIC_TWO,			{builder_tag="bookbuilder"})
Recipe2("book_brimstone",				{Ingredient("papyrus", 2), Ingredient("redgem", 1)},											TECH.MAGIC_THREE,		{builder_tag="bookbuilder"})
Recipe2("book_tentacles",				{Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)},										TECH.SCIENCE_THREE,		{builder_tag="bookbuilder"})

-- Maxwell
Recipe2("waxwelljournal",				{Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2), Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)},													TECH.NONE,			{builder_tag="shadowmagic"})
Recipe2("shadowlumber_builder",			{Ingredient("nightmarefuel", 2), Ingredient("axe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWLUMBER)},		TECH.SHADOW_TWO,	{builder_tag="shadowmagic", nounlock=true})
Recipe2("shadowminer_builder",			{Ingredient("nightmarefuel", 2), Ingredient("pickaxe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWMINER)},	TECH.SHADOW_TWO,	{builder_tag="shadowmagic", nounlock=true})
Recipe2("shadowdigger_builder",			{Ingredient("nightmarefuel", 2), Ingredient("shovel", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDIGGER)},	TECH.SHADOW_TWO,	{builder_tag="shadowmagic", nounlock=true})
Recipe2("shadowduelist_builder",		{Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDUELIST)},	TECH.SHADOW_TWO,	{builder_tag="shadowmagic", nounlock=true})

-- Winona
Recipe2("sewing_tape",					{Ingredient("silk", 1), Ingredient("cutgrass", 3)},												TECH.NONE,				{builder_tag="handyperson"})
Recipe2("winona_catapult",				{Ingredient("sewing_tape", 1), Ingredient("twigs", 3), Ingredient("rocks", 15)},				TECH.NONE,				{builder_tag="handyperson", placer="winona_catapult_placer"})
Recipe2("winona_spotlight",				{Ingredient("sewing_tape", 1), Ingredient("goldnugget", 2), Ingredient("fireflies", 1)},		TECH.NONE,				{builder_tag="handyperson", placer="winona_spotlight_placer"})
Recipe2("winona_battery_low",			{Ingredient("sewing_tape", 1), Ingredient("log", 2), Ingredient("nitre", 2)},					TECH.NONE,				{builder_tag="handyperson", placer="winona_battery_low_placer"})
Recipe2("winona_battery_high",			{Ingredient("sewing_tape", 1), Ingredient("boards", 2), Ingredient("transistor", 2)},			TECH.NONE,				{builder_tag="handyperson", placer="winona_battery_high_placer"})

-- Webber
Recipe2("spidereggsack", 				{Ingredient("silk", 12), Ingredient("spidergland", 4), Ingredient("papyrus", 3)},				TECH.NONE,				{builder_tag="spiderwhisperer"})
Recipe2("spiderden_bedazzler",			{Ingredient("silk", 1), Ingredient("papyrus", 1), Ingredient("boards", 2) },					TECH.NONE,				{builder_tag="spiderwhisperer"})
Recipe2("spider_whistle",  				{Ingredient("silk", 3), Ingredient("twigs", 2) }, 												TECH.NONE,				{builder_tag="spiderwhisperer"})
Recipe2("spider_repellent",  			{Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope", 1) }, 				TECH.NONE,				{builder_tag="spiderwhisperer"})
Recipe2("spider_healer_item",  			{Ingredient("honey", 2), Ingredient("ash",  2), Ingredient("silk", 2) }, 						TECH.NONE,				{builder_tag="spiderwhisperer"})
Recipe2("mutator_warrior", 				{Ingredient("monstermeat", 2), Ingredient("silk", 1), Ingredient("pigskin", 1) },				TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_dropper", 				{Ingredient("monstermeat", 1), Ingredient("silk", 1), Ingredient("manrabbit_tail", 1)},			TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_hider",	  			{Ingredient("monstermeat", 1), Ingredient("silk", 2), Ingredient("cutstone", 2)},				TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_spitter", 				{Ingredient("monstermeat", 1), Ingredient("silk", 2), Ingredient("nitre", 4)},					TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_moon",	  				{Ingredient("monstermeat", 2), Ingredient("silk", 3), Ingredient("moonglass", 2)},				TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_healer",  				{Ingredient("monstermeat", 2), Ingredient("silk", 2), Ingredient("honey", 2)},					TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})
Recipe2("mutator_water",  				{Ingredient("monstermeat", 2), Ingredient("silk", 2), Ingredient("fig", 2)},					TECH.SPIDERCRAFT_ONE,	{builder_tag="spiderwhisperer"})

-- Wormwood
Recipe2("livinglog", 					{Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)},													TECH.NONE,				{builder_tag="plantkin", sg_state="form_log"})
Recipe2("armor_bramble",				{Ingredient("livinglog", 2), Ingredient("stinger", 4)},											TECH.NONE,				{builder_tag="plantkin"})
Recipe2("trap_bramble",					{Ingredient("livinglog", 1), Ingredient("stinger", 1)},											TECH.NONE,				{builder_tag="plantkin"})
Recipe2("compostwrap",					{Ingredient("poop", 5), Ingredient("spoiled_food", 2), Ingredient("nitre", 1)}, 				TECH.NONE,				{builder_tag="plantkin"})

-- Wanda --
local function pocketwatch_nodecon(inst) return not inst:HasTag("pocketwatch_inactive") end

Recipe2("pocketwatch_dismantler",		{Ingredient("goldnugget", 1), Ingredient("flint", 1), Ingredient("twigs", 3)},									TECH.NONE,			{builder_tag="clockmaker"})
Recipe2("pocketwatch_parts",			{Ingredient("pocketwatch_dismantler", 0), Ingredient("thulecite_pieces", 8),Ingredient("nightmarefuel", 2)},	TECH.NONE,			{builder_tag="clockmaker"})
Recipe2("pocketwatch_heal",				{Ingredient("pocketwatch_parts", 1), Ingredient("marble", 2), Ingredient("redgem", 1)},							TECH.NONE,			{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})
Recipe2("pocketwatch_revive",			{Ingredient("pocketwatch_parts", 1), Ingredient("livinglog", 2), Ingredient("boneshard", 4)},					TECH.NONE,			{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})
Recipe2("pocketwatch_warp",				{Ingredient("pocketwatch_parts", 1), Ingredient("goldnugget", 2)},												TECH.NONE,			{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})
Recipe2("pocketwatch_recall",			{Ingredient("pocketwatch_parts", 2), Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1)},				TECH.MAGIC_TWO,		{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})
Recipe2("pocketwatch_portal",			{Ingredient("pocketwatch_recall", 1, nil, true), Ingredient("purplegem", 1)},									TECH.MAGIC_TWO,		{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon, actionstr="SOCKET"})
Recipe2("pocketwatch_weapon",			{Ingredient("pocketwatch_parts", 3), Ingredient("marble", 4), Ingredient("nightmarefuel", 8)},					TECH.MAGIC_THREE,	{builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})

-- Wes						
Recipe2("balloons_empty",				{Ingredient("waterballoon", 4)},																				TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon"})
Recipe2("balloon",						{Ingredient("balloons_empty", 0), Ingredient(CHARACTER_INGREDIENT.SANITY, 5)},									TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon", dropitem = true})
Recipe2("balloonspeed",					{Ingredient("balloons_empty", 0), Ingredient(CHARACTER_INGREDIENT.SANITY, 5)},									TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon"})
Recipe2("balloonparty",					{Ingredient("balloons_empty", 0), Ingredient(CHARACTER_INGREDIENT.SANITY, 5)},									TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon", dropitem = true})
Recipe2("balloonvest",					{Ingredient("balloons_empty", 0), Ingredient(CHARACTER_INGREDIENT.SANITY, 5)},									TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon"})
Recipe2("balloonhat",					{Ingredient("balloons_empty", 0), Ingredient(CHARACTER_INGREDIENT.SANITY, 5)},									TECH.NONE,	{builder_tag="balloonomancer", sg_state="makeballoon"})




-- Gerneral Crafting

Recipe2("researchlab",						{Ingredient("goldnugget", 1),Ingredient("log", 4),Ingredient("rocks", 4)},						TECH.NONE,					{placer="researchlab_placer"})
Recipe2("researchlab2",						{Ingredient("boards", 4),Ingredient("cutstone", 2), Ingredient("transistor", 2)},				TECH.SCIENCE_ONE,			{placer="researchlab2_placer"})
Recipe2("seafaring_prototyper",				{Ingredient("boards", 4)},																		TECH.SCIENCE_ONE,			{placer="seafaring_prototyper_placer"})
Recipe2("tacklestation",					{Ingredient("driftwood_log", 1), Ingredient("transistor", 1), Ingredient("boneshard", 1)},		TECH.SCIENCE_ONE,			{placer="tacklestation_placer"})
Recipe2("cartographydesk",					{Ingredient("compass", 1),Ingredient("boards", 4)},												TECH.SCIENCE_ONE,			{placer="cartographydesk_placer"})
Recipe2("researchlab4",						{Ingredient("rabbit", 4), Ingredient("boards", 4), Ingredient("tophat", 1)},					TECH.SCIENCE_ONE,			{placer="researchlab4_placer"})
Recipe2("researchlab3",						{Ingredient("livinglog", 3), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 7)},		TECH.MAGIC_TWO,				{placer="researchlab3_placer"})
Recipe2("sculptingtable",					{Ingredient("cutstone", 2), Ingredient("boards", 2), Ingredient("twigs", 4) },					TECH.SCIENCE_ONE,			{placer="sculptingtable_placer"})
Recipe2("turfcraftingstation",				{Ingredient("thulecite", 1), Ingredient("cutstone", 3), Ingredient("wetgoop", 1)},				TECH.LOST,					{placer="turfcraftingstation_placer"})

Recipe2("axe",								{Ingredient("twigs", 1),Ingredient("flint", 1)},												TECH.NONE)
Recipe2("goldenaxe",						{Ingredient("twigs", 4),Ingredient("goldnugget", 2)},											TECH.SCIENCE_TWO)
Recipe2("pickaxe",							{Ingredient("twigs", 2),Ingredient("flint", 2)},												TECH.NONE)
Recipe2("goldenpickaxe",					{Ingredient("twigs", 4),Ingredient("goldnugget", 2)},											TECH.SCIENCE_TWO)
Recipe2("shovel",							{Ingredient("twigs", 2),Ingredient("flint", 2)},												TECH.SCIENCE_ONE)
Recipe2("goldenshovel",						{Ingredient("twigs", 4),Ingredient("goldnugget", 2)},											TECH.SCIENCE_TWO)
Recipe2("bugnet",							{Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)},							TECH.SCIENCE_ONE)
Recipe2("hammer",							{Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("cutgrass", 6)},						TECH.NONE)
Recipe2("pitchfork",						{Ingredient("twigs", 2),Ingredient("flint", 2)},												TECH.SCIENCE_ONE)
Recipe2("razor",							{Ingredient("twigs", 2), Ingredient("flint", 2)},												TECH.SCIENCE_ONE)
Recipe2("miniflare",						{Ingredient("twigs", 1), Ingredient("cutgrass", 1), Ingredient("nitre", 1)},					TECH.NONE)
Recipe2("compass",							{Ingredient("goldnugget", 1), Ingredient("flint", 1)},											TECH.NONE)
Recipe2("sentryward",						{Ingredient("purplemooneye", 1), Ingredient("compass", 1), Ingredient("boards", 2)},			TECH.MAGIC_TWO,				{placer="sentryward_placer", min_spacing=1.5})
Recipe2("featherpencil",					{Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)}, 			TECH.SCIENCE_ONE)
Recipe2("reskin_tool",						{Ingredient("twigs", 1), Ingredient("petals", 4)},												TECH.SCIENCE_TWO)
Recipe2("archive_resonator_item",			{Ingredient("moonrocknugget", 1), Ingredient("thulecite", 1)},									TECH.LOST)


Recipe2("healingsalve",						{Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)},							TECH.SCIENCE_ONE)
Recipe2("tillweedsalve",					{Ingredient("tillweed", 4), Ingredient("petals", 4), Ingredient("charcoal", 1)}, 						TECH.SCIENCE_TWO)
Recipe2("bandage",							{Ingredient("papyrus", 1), Ingredient("honey", 2)},														TECH.SCIENCE_TWO)
Recipe2("reviver",							{Ingredient("cutgrass", 3), Ingredient("spidergland", 1), Ingredient(CHARACTER_INGREDIENT.HEALTH, 40)},	TECH.NONE)
Recipe2("lifeinjector",						{Ingredient("spoiled_food", 8), Ingredient("nitre", 2), Ingredient("stinger",1)},						TECH.SCIENCE_TWO)
Recipe2("bedroll_straw",					{Ingredient("cutgrass", 6), Ingredient("rope", 1)},														TECH.SCIENCE_ONE)
Recipe2("bedroll_furry",					{Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 2)}, 										TECH.SCIENCE_TWO)

Recipe2("torch",							{Ingredient("cutgrass", 2),Ingredient("twigs", 2)},												TECH.NONE)
Recipe2("campfire",							{Ingredient("cutgrass", 3),Ingredient("log", 2)},												TECH.NONE,					{placer="campfire_placer"})
Recipe2("firepit",							{Ingredient("log", 2),Ingredient("rocks", 12)},													TECH.NONE,					{placer="firepit_placer"})
Recipe2("coldfire",							{Ingredient("cutgrass", 3), Ingredient("nitre", 2)},											TECH.SCIENCE_ONE,			{placer="coldfire_placer"})
Recipe2("coldfirepit",						{Ingredient("nitre", 2), Ingredient("cutstone", 4), Ingredient("transistor", 2)},				TECH.SCIENCE_TWO,			{placer="coldfirepit_placer"})
Recipe2("pumpkin_lantern",					{Ingredient("pumpkin", 1), Ingredient("fireflies", 1)},											TECH.SCIENCE_ONE)
Recipe2("minerhat",							{Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)},				TECH.SCIENCE_TWO)
Recipe2("molehat",							{Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)},				TECH.SCIENCE_TWO)
Recipe2("lantern",							{Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)},					TECH.SCIENCE_TWO)
Recipe2("nightlight",						{Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2), Ingredient("redgem", 1)},			TECH.MAGIC_TWO,				{placer="nightlight_placer"})
Recipe2("dragonflyfurnace",					{Ingredient("dragon_scales", 1), Ingredient("redgem", 2), Ingredient("charcoal", 10)},			TECH.LOST,					{placer="dragonflyfurnace_placer"})
Recipe2("mushroom_light",					{Ingredient("shroom_skin", 1), Ingredient("fertilizer", 1, nil, true)},							TECH.LOST,					{placer="mushroom_light_placer", min_spacing=1.5})
Recipe2("mushroom_light2",					{Ingredient("shroom_skin", 1), Ingredient("fertilizer", 1, nil, true), Ingredient("boards", 1)},TECH.LOST,					{placer="mushroom_light2_placer", min_spacing=1.5})

Recipe2("farm_hoe",							{Ingredient("twigs", 2), Ingredient("flint", 2)},												TECH.SCIENCE_ONE)
Recipe2("golden_farm_hoe",					{Ingredient("twigs", 4),Ingredient("goldnugget", 2)},											TECH.SCIENCE_TWO)
Recipe2("farm_plow_item",					{Ingredient("boards", 3), Ingredient("rope", 2), Ingredient("flint", 2)},						TECH.SCIENCE_ONE)
Recipe2("wateringcan",						{Ingredient("boards", 2), Ingredient("rope", 1)},												TECH.SCIENCE_ONE)
Recipe2("premiumwateringcan",				{Ingredient("driftwood_log", 2), Ingredient("rope", 1), Ingredient("malbatross_beak", 1)},		TECH.SCIENCE_TWO)
Recipe2("fertilizer",						{Ingredient("poop", 3), Ingredient("boneshard", 2), Ingredient("log", 4)},						TECH.SCIENCE_TWO)
Recipe2("soil_amender",						{Ingredient("messagebottleempty", 1), Ingredient("kelp", 1), Ingredient("ash", 1)},				TECH.SCIENCE_TWO)
Recipe2("treegrowthsolution",				{Ingredient("fig", 2), Ingredient("glommerfuel", 1)},											TECH.SCIENCE_TWO)
Recipe2("compostingbin",					{Ingredient("boards", 3), Ingredient("spoiled_food", 1), Ingredient("cutgrass", 1)},			TECH.SCIENCE_TWO,			{placer="compostingbin_placer"})
Recipe2("plantregistryhat",					{Ingredient("fertilizer", 1), Ingredient("seeds", 3), Ingredient("transistor", 1)},				TECH.SCIENCE_TWO)
Recipe2("mushroom_farm",					{Ingredient("spoiled_food", 8),Ingredient("poop", 5),Ingredient("livinglog", 2)},				TECH.SCIENCE_TWO,			{placer="mushroom_farm_placer"})
Recipe2("beebox",							{Ingredient("boards", 2),Ingredient("honeycomb", 1),Ingredient("bee", 4)},						TECH.SCIENCE_TWO,			{placer="beebox_placer"})
Recipe2("trap",								{Ingredient("twigs", 2),Ingredient("cutgrass", 6)},												TECH.NONE)
Recipe2("birdtrap",							{Ingredient("twigs", 3),Ingredient("silk", 4)},													TECH.SCIENCE_ONE)
Recipe2("birdcage",							{Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)},				TECH.SCIENCE_TWO,			{placer="birdcage_placer"})

Recipe2("heatrock",							{Ingredient("rocks", 10),Ingredient("pickaxe", 1), Ingredient("flint", 3)},						TECH.SCIENCE_TWO)

Recipe2("rope",								{Ingredient("cutgrass", 3)},																	TECH.SCIENCE_ONE)
Recipe2("boards",							{Ingredient("log", 4)}, 																		TECH.SCIENCE_ONE)
Recipe2("cutstone",							{Ingredient("rocks", 3)}, 																		TECH.SCIENCE_ONE)
Recipe2("papyrus",							{Ingredient("cutreeds", 4)}, 																	TECH.SCIENCE_ONE)
Recipe2("transistor",						{Ingredient("goldnugget", 2), Ingredient("cutstone", 1)},										TECH.SCIENCE_ONE)
Recipe2("waxpaper",							{Ingredient("papyrus", 1), Ingredient("beeswax", 1)}, 											TECH.SCIENCE_TWO)
Recipe2("beeswax",							{Ingredient("honeycomb", 1)}, 																	TECH.SCIENCE_TWO)
Recipe2("marblebean",						{Ingredient("marble", 1)}, 																		TECH.SCIENCE_TWO)

Recipe2("nightmarefuel",					{Ingredient("petals_evil", 4)}, 																TECH.MAGIC_TWO)
Recipe2("purplegem",						{Ingredient("redgem",1), Ingredient("bluegem", 1)}, 											TECH.MAGIC_TWO)
Recipe2("moonrockcrater",					{Ingredient("moonrocknugget", 3)}, 																TECH.SCIENCE_TWO)
Recipe2("bearger_fur",						{Ingredient("furtuft", 90)}, 																	TECH.SCIENCE_TWO,			{numtogive = 3})
Recipe2("malbatross_feathered_weave",		{Ingredient("malbatross_feather", 6), Ingredient("silk", 1)},									TECH.SCIENCE_TWO)
Recipe2("refined_dust",						{Ingredient("saltrock", 1), Ingredient("rocks", 2), Ingredient("nitre", 1)},					TECH.LOST)

Recipe2("cookbook",							{Ingredient("papyrus", 1), Ingredient("carrot", 1)},											TECH.SCIENCE_ONE)
Recipe2("cookpot",							{Ingredient("cutstone", 3), Ingredient("charcoal", 6), Ingredient("twigs", 6)},					TECH.SCIENCE_ONE,			{placer="cookpot_placer"})
Recipe2("meatrack",							{Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)},						TECH.SCIENCE_ONE,			{placer="meatrack_placer"})

Recipe2("spear",							{Ingredient("twigs", 2), Ingredient("rope", 1), Ingredient("flint", 1) },						TECH.SCIENCE_ONE)
Recipe2("whip",								{Ingredient("coontail", 3), Ingredient("tentaclespots", 1)},									TECH.SCIENCE_TWO)
Recipe2("hambat",							{Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)},						TECH.SCIENCE_TWO)
Recipe2("batbat",							{Ingredient("batwing", 3), Ingredient("livinglog", 2), Ingredient("purplegem", 1)},				TECH.MAGIC_THREE)
Recipe2("nightstick",						{Ingredient("lightninggoathorn", 1), Ingredient("transistor", 2), Ingredient("nitre", 2)},		TECH.SCIENCE_TWO)
Recipe2("nightsword",						{Ingredient("nightmarefuel", 5),Ingredient("livinglog", 1)},									TECH.MAGIC_THREE)
Recipe2("sleepbomb",						{Ingredient("shroom_skin", 1), Ingredient("canary_poisoned", 1)},								TECH.LOST,					{numtogive=4})
Recipe2("blowdart_pipe",					{Ingredient("cutreeds", 2),Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1)},	TECH.SCIENCE_TWO)
Recipe2("blowdart_fire",					{Ingredient("cutreeds", 2),Ingredient("charcoal", 1),Ingredient("feather_robin", 1)},			TECH.SCIENCE_TWO)
Recipe2("blowdart_yellow",					{Ingredient("cutreeds", 2),Ingredient("goldnugget", 1),Ingredient("feather_canary", 1)},		TECH.SCIENCE_TWO)
Recipe2("blowdart_sleep",					{Ingredient("cutreeds", 2),Ingredient("stinger", 1),Ingredient("feather_crow", 1)},				TECH.SCIENCE_TWO)
Recipe2("boomerang",						{Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)},						TECH.SCIENCE_TWO)
Recipe2("staff_tornado",					{Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)},	TECH.SCIENCE_TWO)
Recipe2("trident",							{Ingredient("gnarwail_horn", 3), Ingredient("kelp", 4), Ingredient("twigs", 2)},				TECH.LOST)
Recipe2("firestaff",						{Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)},				TECH.MAGIC_THREE)
Recipe2("icestaff",							{Ingredient("spear", 1),Ingredient("bluegem", 1)},												TECH.MAGIC_TWO)


Recipe2("armorgrass",						{Ingredient("cutgrass", 10), Ingredient("twigs", 2)},											TECH.NONE)
Recipe2("armorwood",						{Ingredient("log", 8),Ingredient("rope", 2)},													TECH.SCIENCE_ONE)
Recipe2("armordragonfly",					{Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)},			TECH.SCIENCE_TWO)

Recipe2("armor_sanity",						{Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)},										TECH.MAGIC_THREE)
Recipe2("armormarble",						{Ingredient("marble", 6),Ingredient("rope", 2)},												TECH.SCIENCE_TWO)
Recipe2("footballhat",						{Ingredient("pigskin", 1), Ingredient("rope", 1)},												TECH.SCIENCE_TWO)
Recipe2("cookiecutterhat",					{Ingredient("cookiecuttershell", 4), Ingredient("rope", 1)},									TECH.SCIENCE_TWO)

Recipe2("gunpowder",						{Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)},				TECH.SCIENCE_TWO)
Recipe2("panflute",							{Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)},					TECH.MAGIC_TWO)
Recipe2("beemine",							{Ingredient("boards", 1),Ingredient("bee", 4),Ingredient("flint", 1) },							TECH.SCIENCE_TWO)
Recipe2("trap_teeth",						{Ingredient("log", 1),Ingredient("rope", 1),Ingredient("houndstooth", 1)},						TECH.SCIENCE_TWO)

Recipe2("waterballoon",						{Ingredient("mosquitosack", 2), Ingredient("ice", 1)},											TECH.SCIENCE_ONE,			{numtogive = 4})

Recipe2("bundlewrap",						{Ingredient("waxpaper", 1), Ingredient("rope", 1)},												TECH.LOST)
Recipe2("backpack",							{Ingredient("cutgrass", 4), Ingredient("twigs", 4)},											TECH.SCIENCE_ONE)
Recipe2("seedpouch",						{Ingredient("slurtle_shellpieces", 2), Ingredient("cutgrass", 4), Ingredient("seeds", 2)},		TECH.SCIENCE_TWO)
Recipe2("piggyback",						{Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)},						TECH.SCIENCE_TWO)
Recipe2("icepack",							{Ingredient("bearger_fur", 1), Ingredient("gears", 1), Ingredient("transistor", 1)},			TECH.SCIENCE_TWO)

Recipe2("onemanband",						{Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 4),Ingredient("pigskin", 2)},			TECH.MAGIC_TWO)
Recipe2("armorslurper",						{Ingredient("slurper_pelt", 6),Ingredient("rope", 2),Ingredient("nightmarefuel", 2)},			TECH.MAGIC_THREE)

Recipe2("minifan",							{Ingredient("twigs", 3), Ingredient("petals",1)},												TECH.NONE)
Recipe2("grass_umbrella",					{Ingredient("twigs", 4) ,Ingredient("cutgrass", 3), Ingredient("petals", 6)},					TECH.NONE)
Recipe2("umbrella",							{Ingredient("twigs", 6) ,Ingredient("pigskin", 1), Ingredient("silk",2 )},						TECH.SCIENCE_ONE)
Recipe2("featherfan",						{Ingredient("goose_feather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)},				TECH.SCIENCE_TWO)

Recipe2("sewing_kit",						{Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)}, 					TECH.SCIENCE_TWO)
Recipe2("flowerhat", 						{Ingredient("petals", 12)}, 																	TECH.NONE)
Recipe2("strawhat", 						{Ingredient("cutgrass", 12)}, 																	TECH.NONE)
Recipe2("tophat", 							{Ingredient("silk", 6)}, 																		TECH.SCIENCE_ONE)
Recipe2("rainhat", 							{Ingredient("mole", 2), Ingredient("strawhat", 1), Ingredient("boneshard", 1)},					TECH.SCIENCE_TWO)
Recipe2("earmuffshat", 						{Ingredient("rabbit", 2), Ingredient("twigs",1)}, 												TECH.NONE)
Recipe2("beefalohat", 						{Ingredient("beefalowool", 8),Ingredient("horn", 1)}, 											TECH.SCIENCE_ONE)
Recipe2("winterhat", 						{Ingredient("beefalowool", 4),Ingredient("silk", 4)}, 											TECH.SCIENCE_TWO)
Recipe2("catcoonhat", 						{Ingredient("coontail", 1), Ingredient("silk", 4)}, 											TECH.SCIENCE_TWO)
Recipe2("kelphat", 							{Ingredient("kelp", 6)},																		TECH.NONE)
Recipe2("goggleshat", 						{Ingredient("goldnugget", 1), Ingredient("pigskin", 1)}, 										TECH.SCIENCE_ONE)
Recipe2("deserthat", 						{Ingredient("goggleshat", 1), Ingredient("pigskin", 1)}, 										TECH.LOST)
Recipe2("moonstorm_goggleshat", 			{Ingredient("moonglass", 2),Ingredient("potato", 1)}, 											TECH.LOST)
Recipe2("watermelonhat", 					{Ingredient("watermelon", 1), Ingredient("twigs", 3)}, 											TECH.SCIENCE_ONE)
Recipe2("icehat",							{Ingredient("transistor", 2), Ingredient("rope", 4), Ingredient("ice", 10)}, 					TECH.SCIENCE_TWO)
Recipe2("beehat", 							{Ingredient("silk", 8), Ingredient("rope", 1)}, 												TECH.SCIENCE_TWO)
Recipe2("featherhat", 						{Ingredient("feather_crow", 3),Ingredient("feather_robin", 2), Ingredient("tentaclespots", 2)}, TECH.SCIENCE_TWO)
Recipe2("bushhat",							{Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)},				TECH.SCIENCE_TWO)
Recipe2("raincoat", 						{Ingredient("tentaclespots", 2), Ingredient("rope", 2), Ingredient("boneshard", 2)}, 			TECH.SCIENCE_ONE)
Recipe2("sweatervest", 						{Ingredient("houndstooth", 8),Ingredient("silk", 6)}, 											TECH.SCIENCE_TWO)
Recipe2("trunkvest_summer", 				{Ingredient("trunk_summer", 1),Ingredient("silk", 8)},											TECH.SCIENCE_TWO)
Recipe2("trunkvest_winter", 				{Ingredient("trunk_winter", 1),Ingredient("silk", 8), Ingredient("beefalowool", 2)}, 			TECH.SCIENCE_TWO)
Recipe2("reflectivevest", 					{Ingredient("rope", 1), Ingredient("feather_robin", 3), Ingredient("pigskin", 2)}, 				TECH.SCIENCE_ONE)
Recipe2("hawaiianshirt", 					{Ingredient("papyrus", 3), Ingredient("silk", 3), Ingredient("cactus_flower", 5)},				TECH.SCIENCE_TWO)
Recipe2("cane", 							{Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)},			TECH.SCIENCE_TWO)
Recipe2("beargervest", 						{Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)},			TECH.SCIENCE_TWO)
Recipe2("eyebrellahat", 					{Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)}, 		TECH.SCIENCE_TWO)
Recipe2("red_mushroomhat", 					{Ingredient("red_cap", 6)}, 																	TECH.LOST)
Recipe2("green_mushroomhat",				{Ingredient("green_cap", 6)},																	TECH.LOST)
Recipe2("blue_mushroomhat",					{Ingredient("blue_cap", 6)}, 																	TECH.LOST)

Recipe2("treasurechest",					{Ingredient("boards", 3)},																		TECH.SCIENCE_ONE,			{placer="treasurechest_placer",		min_spacing=1})
Recipe2("dragonflychest",					{Ingredient("dragon_scales", 1), Ingredient("boards", 4), Ingredient("goldnugget", 10)},		TECH.SCIENCE_TWO,			{placer="dragonflychest_placer",	min_spacing=1.5})
Recipe2("icebox",							{Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("cutstone", 1)},				TECH.SCIENCE_TWO,			{placer="icebox_placer",			min_spacing=1.5})
Recipe2("saltbox",							{Ingredient("saltrock", 10), Ingredient("bluegem", 1), Ingredient("cutstone", 1)},				TECH.SCIENCE_TWO,			{placer="saltbox_placer",			min_spacing=1.5})

Recipe2("winterometer",						{Ingredient("boards", 2), Ingredient("goldnugget", 2)},											TECH.SCIENCE_ONE,			{placer="winterometer_placer"})
Recipe2("rainometer",						{Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)},					TECH.SCIENCE_ONE,			{placer="rainometer_placer"})
Recipe2("lightning_rod",					{Ingredient("goldnugget", 4), Ingredient("cutstone", 1)},										TECH.SCIENCE_ONE,			{placer="lightning_rod_placer"})
Recipe2("firesuppressor",					{Ingredient("gears", 2),Ingredient("ice", 15),Ingredient("transistor", 2)},						TECH.SCIENCE_TWO,			{placer="firesuppressor_placer"})
Recipe2("moondial",							{Ingredient("bluemooneye", 1), Ingredient("moonrocknugget", 2), Ingredient("ice", 2)},			TECH.MAGIC_TWO,				{placer="moondial_placer"})

Recipe2("tent",								{Ingredient("silk", 6),Ingredient("twigs", 4),Ingredient("rope", 3)},									TECH.SCIENCE_TWO,			{placer="tent_placer"})
Recipe2("siestahut",						{Ingredient("silk", 2),Ingredient("boards", 4),Ingredient("rope", 3)},									TECH.SCIENCE_TWO,			{placer="siestahut_placer"})
Recipe2("resurrectionstatue",				{Ingredient("boards", 4), Ingredient("beardhair", 4), Ingredient(CHARACTER_INGREDIENT.HEALTH, TUNING.EFFIGY_HEALTH_PENALTY)}, TECH.MAGIC_TWO,	{placer="resurrectionstatue_placer"})

Recipe2("pighouse",							{Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)},							TECH.SCIENCE_TWO,			{placer="pighouse_placer"})
Recipe2("rabbithouse",						{Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)},					TECH.SCIENCE_TWO,			{placer="rabbithouse_placer"})
Recipe2("saltlick",							{Ingredient("boards", 2), Ingredient("nitre", 4)},  													TECH.SCIENCE_TWO,			{placer="saltlick_placer"})
Recipe2("townportal",						{Ingredient("orangemooneye", 1), Ingredient("townportaltalisman", 1), Ingredient("cutstone", 3)},		TECH.LOST,		 			{placer="townportal_placer"})

Recipe2("scarecrow",						{Ingredient("pumpkin", 1), Ingredient("boards", 3), Ingredient("cutgrass", 3)},							TECH.SCIENCE_ONE,			{placer="scarecrow_placer", min_spacing=1.5})
Recipe2("endtable",							{Ingredient("marble", 2), Ingredient("boards", 2), Ingredient("turf_carpetfloor", 2)},					TECH.LOST,					{placer="endtable_placer", min_spacing=1.5})

Recipe2("moon_device_construction1",			{Ingredient("moonstorm_static_item", 1),Ingredient("moonstorm_spark", 5),Ingredient("transistor", 2)}, TECH.LOST,				{placer="moon_device_construction1_placer", min_spacing=0, no_deconstruction=true})

Recipe2("fence_gate_item",					{Ingredient("boards", 2), Ingredient("rope", 1)},														TECH.SCIENCE_TWO)
Recipe2("wall_hay_item",					{Ingredient("cutgrass", 4), Ingredient("twigs", 2)},													TECH.SCIENCE_ONE,			{numtogive=4})
Recipe2("fence_item",						{Ingredient("twigs", 3), Ingredient("rope", 1)},														TECH.SCIENCE_ONE,			{numtogive=6})
Recipe2("wall_wood_item",					{Ingredient("boards", 2), Ingredient("rope", 1)},														TECH.SCIENCE_ONE,			{numtogive=8})
Recipe2("wall_stone_item",					{Ingredient("cutstone", 2)},																			TECH.SCIENCE_TWO,			{numtogive=6})
Recipe2("wall_moonrock_item",				{Ingredient("moonrocknugget", 4)},																		TECH.SCIENCE_TWO,			{numtogive=4})

Recipe2("boat_item", 						{Ingredient("boards", 4)},																				TECH.SEAFARING_ONE)
Recipe2("boatpatch", 						{Ingredient("log", 2), Ingredient("stinger", 1)}, 														TECH.NONE)
Recipe2("oar", 								{Ingredient("log", 1)}, 																				TECH.NONE)
Recipe2("oar_driftwood", 					{Ingredient("driftwood_log", 1)}, 																		TECH.NONE)
Recipe2("anchor_item", 						{Ingredient("boards", 2), Ingredient("rope", 3), Ingredient("cutstone", 3)}, 							TECH.SEAFARING_ONE)
Recipe2("mast_item", 						{Ingredient("boards", 3), Ingredient("rope", 3), Ingredient("silk", 8)}, 								TECH.SEAFARING_ONE)
Recipe2("mast_malbatross_item",				{Ingredient("driftwood_log", 3), Ingredient("rope", 3), Ingredient("malbatross_feathered_weave", 4)},	TECH.SEAFARING_ONE)
Recipe2("steeringwheel_item",				{Ingredient("boards", 2), Ingredient("rope", 1)}, 														TECH.SEAFARING_ONE)
Recipe2("fish_box",							{Ingredient("cutstone", 1), Ingredient("rope", 3)}, 													TECH.SEAFARING_ONE,			{placer="fish_box_placer", min_spacing=1.5, testfn=function(pt) return TheWorld.Map:GetPlatformAtPoint(pt.x, 0, pt.z, -0.5) ~= nil end})
Recipe2("winch",							{Ingredient("boards", 2), Ingredient("cutstone", 1), Ingredient("rope", 2)},							TECH.LOST,					{placer="winch_placer", min_spacing=1.5})
Recipe2("mastupgrade_lamp_item",			{Ingredient("boards", 1), Ingredient("rope", 2), Ingredient("flint", 4)},								TECH.SEAFARING_ONE)
Recipe2("mastupgrade_lightningrod_item",	{Ingredient("goldnugget", 5)},																			TECH.SEAFARING_ONE)
Recipe2("waterpump",						{Ingredient("boards", 2), Ingredient("oceanfish_small_9_inv", 1)},										TECH.SEAFARING_ONE,			{placer="waterpump_placer", min_spacing=1.5, image="waterpump_item.tex"})
Recipe2("chesspiece_anchor_sketch",			{Ingredient("papyrus", 1)},																				TECH.SEAFARING_ONE)

	
Recipe2("fishingrod",						{Ingredient("twigs", 2), Ingredient("silk", 2)},														TECH.SCIENCE_ONE)
Recipe2("oceanfishingrod",					{Ingredient("boards", 1), Ingredient("silk", 6)},														TECH.SCIENCE_ONE)
Recipe2("pocket_scale",						{Ingredient("log", 1), Ingredient("cutstone", 1), Ingredient("goldnugget", 1)}, 						TECH.SCIENCE_ONE)

Recipe2("oceanfishingbobber_ball",			{Ingredient("log", 1)},																					TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_oval",			{Ingredient("driftwood_log", 1)},																		TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_crow",			{Ingredient("feather_crow", 1)},																		TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_robin",			{Ingredient("feather_robin", 1)},																		TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_robin_winter",	{Ingredient("feather_robin_winter", 1)},																TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_canary",		{Ingredient("feather_canary", 1)},																		TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_goose",			{Ingredient("goose_feather", 1)},																		TECH.FISHING_ONE)
Recipe2("oceanfishingbobber_malbatross",	{Ingredient("malbatross_feather", 1)},																	TECH.FISHING_ONE)
																																									
Recipe2("oceanfishinglure_spoon_red",		{Ingredient("flint", 2), Ingredient("red_cap", 1)},														TECH.FISHING_ONE)
Recipe2("oceanfishinglure_spoon_green",		{Ingredient("flint", 2), Ingredient("green_cap", 1)},													TECH.FISHING_ONE)
Recipe2("oceanfishinglure_spoon_blue",		{Ingredient("flint", 2), Ingredient("blue_cap", 1)},													TECH.FISHING_ONE)
Recipe2("oceanfishinglure_spinner_red",		{Ingredient("flint", 1), Ingredient("red_cap", 1), Ingredient("beefalowool", 1)},						TECH.FISHING_ONE)
Recipe2("oceanfishinglure_spinner_green",	{Ingredient("flint", 1), Ingredient("green_cap", 1), Ingredient("beefalowool", 1)},						TECH.FISHING_ONE)
Recipe2("oceanfishinglure_spinner_blue",	{Ingredient("flint", 1), Ingredient("blue_cap", 1), Ingredient("beefalowool", 1)},						TECH.FISHING_ONE)
																																									
Recipe2("oceanfishinglure_hermit_rain",		{Ingredient("cookiecuttershell", 1), Ingredient("mosquitosack", 1)},									TECH.LOST)		
Recipe2("oceanfishinglure_hermit_snow",		{Ingredient("cookiecuttershell", 1), Ingredient("ice", 1)},												TECH.LOST)		
Recipe2("oceanfishinglure_hermit_drowsy",	{Ingredient("cookiecuttershell", 1), Ingredient("stinger", 1)},											TECH.LOST)		
Recipe2("oceanfishinglure_hermit_heavy",	{Ingredient("cookiecuttershell", 1), Ingredient("beefalowool", 1)},										TECH.LOST)		


Recipe2("homesign",							{Ingredient("boards", 1)},																				TECH.SCIENCE_ONE,			{placer="homesign_placer"})
Recipe2("arrowsign_post",					{Ingredient("boards", 1)},																				TECH.SCIENCE_ONE,			{placer="arrowsign_post_placer"})
Recipe2("minisign_item",					{Ingredient("boards", 1)},																				TECH.SCIENCE_ONE,			{numtogive = 4})


Recipe2("amulet",							{Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)},					TECH.MAGIC_TWO)
Recipe2("blueamulet",						{Ingredient("goldnugget", 3), Ingredient("bluegem", 1)},												TECH.MAGIC_TWO)
Recipe2("purpleamulet",						{Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4),Ingredient("purplegem", 2)},				TECH.MAGIC_THREE)
Recipe2("telestaff",						{Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)},				TECH.MAGIC_THREE)
Recipe2("telebase",							{Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)},				TECH.MAGIC_THREE,			{placer="telebase_placer", testfn=telebase_testfn})

Recipe2("beef_bell",						{Ingredient("goldnugget", 3), Ingredient("flint", 1)}, 													TECH.SCIENCE_ONE)
Recipe2("saddlehorn",						{Ingredient("twigs", 2), Ingredient("boneshard", 2), Ingredient("feather_crow", 1)}, 					TECH.SCIENCE_TWO)
Recipe2("saddle_basic",						{Ingredient("beefalowool", 4), Ingredient("pigskin", 4), Ingredient("goldnugget", 4)},  				TECH.SCIENCE_TWO)
Recipe2("saddle_war",						{Ingredient("rabbit", 4), Ingredient("steelwool", 4), Ingredient("log", 10)},  							TECH.SCIENCE_TWO)
Recipe2("saddle_race",						{Ingredient("livinglog", 2), Ingredient("silk", 4), Ingredient("butterflywings", 68)},  				TECH.SCIENCE_TWO)
Recipe2("brush",							{Ingredient("steelwool", 1), Ingredient("walrus_tusk", 1), Ingredient("goldnugget", 2)},  				TECH.SCIENCE_TWO)

Recipe2("wardrobe",							{Ingredient("boards", 4), Ingredient("cutgrass", 3)},													TECH.SCIENCE_TWO,			{placer="wardrobe_placer"})
Recipe2("beefalo_groomer",					{Ingredient("boards", 4), Ingredient("beefalowool", 2)},												TECH.SCIENCE_TWO,			{placer="beefalo_groomer_item_placer"})
Recipe2("trophyscale_fish",					{Ingredient("ice", 4), Ingredient("boards", 2), Ingredient("cutstone", 1)},								TECH.SCIENCE_TWO,			{placer="trophyscale_fish_placer"})
Recipe2("trophyscale_oversizedveggies",		{Ingredient("boards", 4), Ingredient("cutgrass", 4)},													TECH.SCIENCE_TWO,			{placer="trophyscale_oversizedveggies_placer"})

Recipe2("turf_road",						{Ingredient("cutstone", 1), Ingredient("flint", 2)},													TECH.SCIENCE_TWO,			{numtogive=4})
Recipe2("turf_woodfloor",					{Ingredient("boards", 1)},																				TECH.SCIENCE_TWO,			{numtogive=4})
Recipe2("turf_checkerfloor",				{Ingredient("marble", 1)},																				TECH.SCIENCE_TWO,			{numtogive=4})
Recipe2("turf_carpetfloor",					{Ingredient("boards", 1), Ingredient("beefalowool", 1)},												TECH.SCIENCE_TWO,			{numtogive=4})
Recipe2("turf_dragonfly",					{Ingredient("dragon_scales", 1), Ingredient("cutstone", 1)},											TECH.SCIENCE_TWO,			{numtogive=4})
Recipe2("turf_shellbeach",					{Ingredient("rocks", 1), Ingredient("slurtle_shellpieces", 1)},											TECH.LOST,					{numtogive=4})

Recipe2("turf_forest",						{Ingredient("twigs", 1), Ingredient("pinecone", 1)},													TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_grass",						{Ingredient("cutgrass", 1), Ingredient("petals", 1)},													TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_savanna",						{Ingredient("cutgrass", 1), Ingredient("poop", 1)},														TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_deciduous",					{Ingredient("twigs", 1), Ingredient("acorn", 1)},														TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_desertdirt",					{Ingredient("rocks", 1), Ingredient("boneshard", 1)},													TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_pebblebeach",					{Ingredient("rocks", 1), Ingredient("driftwood_log", 1)},												TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_rocky",						{Ingredient("rocks", 1), Ingredient("flint", 1)},														TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_cave",						{Ingredient("guano", 2)},																				TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_underrock",					{Ingredient("rocks", 3)},																				TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_sinkhole",					{Ingredient("cutgrass", 1), Ingredient("foliage", 1)},													TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_mud",							{Ingredient("rocks", 1), Ingredient("ice", 1)},															TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_fungus",						{Ingredient("cutlichen", 1), Ingredient("spore_tall", 1)},												TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_fungus_red",					{Ingredient("cutlichen", 1), Ingredient("spore_medium", 1)},											TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_fungus_green",				{Ingredient("cutlichen", 1), Ingredient("spore_small", 1)},												TECH.TURFCRAFTING_TWO,		{numtogive=4})
Recipe2("turf_marsh",						{Ingredient("cutreeds", 1), Ingredient("spoiled_food", 2)},												TECH.MASHTURFCRAFTING_TWO,	{numtogive=4})

Recipe2("pottedfern",						{Ingredient("foliage", 2), Ingredient("slurtle_shellpieces", 1)},										TECH.SCIENCE_TWO,			{placer="pottedfern_placer", min_spacing=0.9})
Recipe2("succulent_potted",					{Ingredient("succulent_picked", 2), Ingredient("cutstone", 1)},											TECH.SCIENCE_TWO,			{placer="succulent_potted_placer", min_spacing=0.9})
Recipe2("ruinsrelic_plate",					{Ingredient("cutstone", 1)},																			TECH.LOST,					{placer="ruinsrelic_plate_placer", min_spacing=0.5})
Recipe2("ruinsrelic_chipbowl",				{Ingredient("cutstone", 1)},																			TECH.LOST,					{placer="ruinsrelic_chipbowl_placer", min_spacing=0.5})
Recipe2("ruinsrelic_bowl",					{Ingredient("cutstone", 2)},																			TECH.LOST,					{placer="ruinsrelic_bowl_placer", min_spacing=2})
Recipe2("ruinsrelic_vase",					{Ingredient("cutstone", 2)},																			TECH.LOST,					{placer="ruinsrelic_vase_placer", min_spacing=2})
Recipe2("ruinsrelic_chair",					{Ingredient("cutstone", 1)},																			TECH.LOST,					{placer="ruinsrelic_chair_placer", min_spacing=2})
Recipe2("ruinsrelic_table",					{Ingredient("cutstone", 1)},																			TECH.LOST,					{placer="ruinsrelic_table_placer"})

-- WX78 Items
Recipe2("wx78module_maxhealth",				{Ingredient("scandata", 2), Ingredient("spidergland", 1)},													TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_maxhealth2",			{Ingredient("scandata", 4), Ingredient("spidergland", 2), Ingredient("wx78module_maxhealth", 1)},			TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_maxsanity1",			{Ingredient("scandata", 1), Ingredient("petals", 1)},														TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_maxsanity",				{Ingredient("scandata", 3), Ingredient("nightmarefuel", 1), Ingredient("wx78module_maxsanity1", 1)},		TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_bee",					{Ingredient("scandata", 8), Ingredient("royal_jelly", 1), Ingredient("wx78module_maxsanity", 1)},			TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_music",					{Ingredient("scandata", 4), Ingredient("singingshell_octave3", 1, nil, nil, "singingshell_octave3_3.tex")},	TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_maxhunger1",			{Ingredient("scandata", 2), Ingredient("houndstooth", 1)},													TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_maxhunger",				{Ingredient("scandata", 3), Ingredient("slurper_pelt", 1), Ingredient("wx78module_maxhunger1", 1)},			TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_movespeed",				{Ingredient("scandata", 2), Ingredient("rabbit", 1)},														TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_movespeed2",			{Ingredient("scandata", 6), Ingredient("gears", 1), Ingredient("wx78module_movespeed", 1)},					TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_heat",					{Ingredient("scandata", 4), Ingredient("redgem", 1)},														TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_cold",					{Ingredient("scandata", 4), Ingredient("bluegem", 1)},														TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_taser",					{Ingredient("scandata", 5), Ingredient("goatmilk", 1)},														TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_nightvision",			{Ingredient("scandata", 4), Ingredient("mole", 1), Ingredient("fireflies", 1)},								TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78module_light",					{Ingredient("scandata", 6), Ingredient("lightbulb", 1)},													TECH.ROBOTMODULECRAFT_ONE,	{builder_tag="upgrademoduleowner"})
Recipe2("wx78_moduleremover",				{Ingredient("twigs", 2), Ingredient("rocks", 2)},															TECH.NONE,					{builder_tag="upgrademoduleowner"})
Recipe2("wx78_scanner_item",				{Ingredient("transistor", 1), Ingredient("silk", 1)},														TECH.NONE,					{builder_tag="upgrademoduleowner"})

------------------------------- CRAFTING STATIONS -------------------------------

-- ANCIENT
Recipe2("thulecite",						{Ingredient("thulecite_pieces", 6)},																	TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("wall_ruins_item",					{Ingredient("thulecite", 1)},																			TECH.ANCIENT_TWO,			{nounlock=true, numtogive=6})
Recipe2("nightmare_timepiece",				{Ingredient("thulecite", 2), Ingredient("nightmarefuel", 2)},											TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("orangeamulet",						{Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3), Ingredient("orangegem", 1)},				TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("yellowamulet",						{Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3), Ingredient("yellowgem", 1)},				TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("greenamulet",						{Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3), Ingredient("greengem", 1)},				TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("orangestaff",						{Ingredient("nightmarefuel", 2), Ingredient("cane", 1), Ingredient("orangegem", 2)},					TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("yellowstaff",						{Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("yellowgem", 2)},				TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("greenstaff",						{Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("greengem", 2)},				TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("multitool_axe_pickaxe",			{Ingredient("goldenaxe", 1), Ingredient("goldenpickaxe", 1), Ingredient("thulecite", 2)},				TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("nutrientsgoggleshat",				{Ingredient("plantregistryhat", 1), Ingredient("thulecite_pieces", 4), Ingredient("purplegem", 1)},		TECH.ANCIENT_TWO,			{nounlock=true})
Recipe2("ruinshat",							{Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)},											TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("armorruins",						{Ingredient("thulecite", 6), Ingredient("nightmarefuel", 4)},											TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("ruins_bat",						{Ingredient("livinglog", 3), Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)},				TECH.ANCIENT_FOUR,			{nounlock=true})
Recipe2("eyeturret_item",					{Ingredient("deerclops_eyeball", 1), Ingredient("minotaurhorn", 1), Ingredient("thulecite", 5)}, 		TECH.ANCIENT_FOUR,			{nounlock=true})

-- CARTOGRAPHY
Recipe2("mapscroll",						{Ingredient("featherpencil", 1), Ingredient("papyrus", 1)}, 											TECH.CARTOGRAPHY_TWO,		{nounlock=true, actionstr="CARTOGRAPHY"})

-- CRITTERS - Ingredients should be a themed item and a favorite food 
Recipe2("critter_kitten_builder",			{Ingredient("coontail", 1), Ingredient("fishsticks", 1)},												TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_puppy_builder",			{Ingredient("houndstooth", 1), Ingredient("monsterlasagna", 1)},										TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_lamb_builder",				{Ingredient("steelwool", 1), Ingredient("guacamole", 1)},												TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_perdling_builder",			{Ingredient("featherhat", 1), Ingredient("trailmix", 1)},												TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_dragonling_builder",		{Ingredient("lavae_cocoon", 1), Ingredient("hotchili", 1)},												TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_glomling_builder",			{Ingredient("glommerfuel", 1), Ingredient("taffy", 1)},													TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_lunarmothling_builder",	{Ingredient("moonbutterfly", 1), Ingredient("flowersalad", 1)},											TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})
Recipe2("critter_eyeofterror_builder",		{Ingredient("milkywhites", 1), Ingredient("baconeggs", 1)},												TECH.ORPHANAGE_ONE,			{nounlock=true, actionstr="ORPHANAGE"})

----CELESTIAL----
Recipe2("moonrockidol",								{Ingredient("moonrocknugget", 1), Ingredient("purplegem", 1)},									TECH.CELESTIAL_ONE,			{nounlock=true})
Recipe2("multiplayer_portal_moonrock_constr_plans", {Ingredient("boards", 1), Ingredient("rope", 1)},												TECH.CELESTIAL_ONE,			{nounlock=true})

----MOON_ALTAR-----
Recipe2("moonglassaxe",						{Ingredient("twigs", 2), Ingredient("moonglass", 3)},													TECH.CELESTIAL_THREE,		{nounlock=true})
Recipe2("glasscutter",						{Ingredient("boards", 1), Ingredient("moonglass", 6)},													TECH.CELESTIAL_THREE,		{nounlock=true})
Recipe2("turf_meteor",						{Ingredient("moonrocknugget", 1), Ingredient("moonglass", 2)},											TECH.CELESTIAL_THREE,		{nounlock=true, numtogive=4})
Recipe2("turf_fungus_moon",					{Ingredient("moonrocknugget", 1), Ingredient("moon_cap", 2)},											TECH.CELESTIAL_THREE,		{nounlock=true, numtogive=4})
Recipe2("bathbomb", 						{Ingredient("moon_tree_blossom", 6), Ingredient("nitre", 1)}, 											TECH.CELESTIAL_THREE,		{nounlock=true})
Recipe2("chesspiece_butterfly_sketch",		{Ingredient("papyrus", 1)},																				TECH.CELESTIAL_THREE,		{nounlock=true})
Recipe2("chesspiece_moon_sketch", 			{Ingredient("papyrus", 1)},																				TECH.CELESTIAL_THREE,		{nounlock=true})

----SCULPTING----
Recipe2("chesspiece_hornucopia_builder",	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.SCULPTING_ONE,			{nounlock = true, actionstr="SCULPTING", image="chesspiece_hornucopia.tex"})
Recipe2("chesspiece_pipe_builder", 			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.SCULPTING_ONE,			{nounlock = true, actionstr="SCULPTING", image="chesspiece_pipe.tex"})
Recipe2("chesspiece_anchor_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_anchor.tex"})
Recipe2("chesspiece_pawn_builder", 			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_pawn.tex"})
Recipe2("chesspiece_rook_builder", 			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_rook.tex"})
Recipe2("chesspiece_knight_builder", 		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_knight.tex"})
Recipe2("chesspiece_bishop_builder", 		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_bishop.tex"})
Recipe2("chesspiece_muse_builder", 			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_muse.tex"})
Recipe2("chesspiece_formal_builder", 		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_formal.tex"})
Recipe2("chesspiece_deerclops_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_deerclops.tex"})
Recipe2("chesspiece_bearger_builder", 		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_bearger.tex"})
Recipe2("chesspiece_moosegoose_builder",	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_moosegoose.tex"})
Recipe2("chesspiece_dragonfly_builder", 	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_dragonfly.tex"})
Recipe2("chesspiece_minotaur_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_minotaur.tex"})
Recipe2("chesspiece_toadstool_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_toadstool.tex"})
Recipe2("chesspiece_beequeen_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_beequeen.tex"})
Recipe2("chesspiece_klaus_builder",			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_klaus.tex"})
Recipe2("chesspiece_antlion_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_antlion.tex"})
Recipe2("chesspiece_stalker_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_stalker.tex"})
Recipe2("chesspiece_malbatross_builder",	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_malbatross.tex"})
Recipe2("chesspiece_crabking_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_crabking.tex"})
Recipe2("chesspiece_butterfly_builder", 	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_butterfly.tex"})
Recipe2("chesspiece_moon_builder", 			{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_moon.tex"})
Recipe2("chesspiece_guardianphase3_builder",{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_guardianphase3.tex"})
Recipe2("chesspiece_eyeofterror_builder",	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_eyeofterror.tex"})
Recipe2("chesspiece_twinsofterror_builder",	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_twinsofterror.tex"})
Recipe2("chesspiece_clayhound_builder", 	{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_clayhound.tex"})
Recipe2("chesspiece_claywarg_builder", 		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_claywarg.tex"})
Recipe2("chesspiece_carrat_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_carrat.tex"})
Recipe2("chesspiece_beefalo_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_beefalo.tex"})
Recipe2("chesspiece_kitcoon_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_kitcoon.tex"})
Recipe2("chesspiece_catcoon_builder",		{Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)},										TECH.LOST,					{nounlock = true, actionstr="SCULPTING", image="chesspiece_catcoon.tex"})

-- Hermitcrab
Recipe2("hermitshop_hermit_bundle_shells",				{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_ONE,	{nounlock = true, sg_state="give", product="hermit_bundle_shells",		image="hermit_bundle.tex"})
Recipe2("hermitshop_winch_blueprint",					{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_ONE,	{nounlock = true, sg_state="give", product="winch_blueprint",			image="blueprint_rare.tex"})
Recipe2("hermitshop_turf_shellbeach_blueprint",			{Ingredient("messagebottleempty", 3)},														TECH.HERMITCRABSHOP_ONE,	{nounlock = true, sg_state="give", product="turf_shellbeach_blueprint",	image="blueprint_rare.tex"})
Recipe2("hermitshop_oceanfishingbobber_crow",			{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_THREE,	{nounlock = true, sg_state="give", product="oceanfishingbobber_crow"})
Recipe2("hermitshop_oceanfishingbobber_robin",			{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_THREE,	{nounlock = true, sg_state="give", product="oceanfishingbobber_robin"})
Recipe2("hermitshop_oceanfishingbobber_robin_winter",	{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_THREE,	{nounlock = true, sg_state="give", product="oceanfishingbobber_robin_winter"})
Recipe2("hermitshop_oceanfishingbobber_canary",			{Ingredient("messagebottleempty", 1)},														TECH.HERMITCRABSHOP_THREE,	{nounlock = true, sg_state="give", product="oceanfishingbobber_canary"})
Recipe2("hermitshop_tacklecontainer",					{Ingredient("messagebottleempty", 3)},														TECH.HERMITCRABSHOP_THREE,	{nounlock = true, sg_state="give", product="tacklecontainer"})
Recipe2("hermitshop_oceanfishinglure_hermit_rain",		{Ingredient("messagebottleempty", 2)},														TECH.HERMITCRABSHOP_FIVE,	{nounlock = true, sg_state="give", product="oceanfishinglure_hermit_rain"})
Recipe2("hermitshop_oceanfishinglure_hermit_snow",		{Ingredient("messagebottleempty", 2)},														TECH.HERMITCRABSHOP_FIVE,	{nounlock = true, sg_state="give", product="oceanfishinglure_hermit_snow"})
Recipe2("hermitshop_oceanfishinglure_hermit_drowsy",	{Ingredient("messagebottleempty", 2)},														TECH.HERMITCRABSHOP_FIVE,	{nounlock = true, sg_state="give", product="oceanfishinglure_hermit_drowsy"})
Recipe2("hermitshop_oceanfishinglure_hermit_heavy",		{Ingredient("messagebottleempty", 2)},														TECH.HERMITCRABSHOP_FIVE,	{nounlock = true, sg_state="give", product="oceanfishinglure_hermit_heavy"})
Recipe2("hermitshop_oceanfishingbobber_goose",			{Ingredient("messagebottleempty", 3)},														TECH.HERMITCRABSHOP_SEVEN,	{nounlock = true, sg_state="give", product="oceanfishingbobber_goose"})
Recipe2("hermitshop_oceanfishingbobber_malbatross",		{Ingredient("messagebottleempty", 3)},														TECH.HERMITCRABSHOP_SEVEN,	{nounlock = true, sg_state="give", product="oceanfishingbobber_malbatross"})
Recipe2("hermitshop_chum",								{Ingredient("messagebottleempty", 3)},														TECH.HERMITCRABSHOP_SEVEN,	{nounlock = true, sg_state="give", product="chum",						image="chum.tex"})
Recipe2("hermitshop_supertacklecontainer",				{Ingredient("messagebottleempty", 8)},														TECH.LOST,					{nounlock = true, sg_state="give", product="supertacklecontainer"})
Recipe2("hermitshop_winter_ornament_boss_hermithouse",	{Ingredient("messagebottleempty", 8)},														TECH.LOST,					{nounlock = true, sg_state="give", product="winter_ornament_boss_hermithouse"})
Recipe2("hermitshop_winter_ornament_boss_pearl",		{Ingredient("messagebottleempty", 12)}, 													TECH.LOST,					{nounlock = true, sg_state="give", product="winter_ornament_boss_pearl"})



------------------------------- SPECIAL EVENTS -------------------------------


----YEAR OF THE X-----
Recipe2("ticoon_builder",					{Ingredient("lucky_goldnugget", 1)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING", canbuild = function(inst, builder) return (builder.components.leader == nil or builder.components.leader:CountFollowers("ticoon") == 0), "TICOON" end})
Recipe2("kitcoonden_kit",					{Ingredient("lucky_goldnugget", 1)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("kitcoon_nametag",					{Ingredient("lucky_goldnugget", 6)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("cattoy_mouse",                     {Ingredient("lucky_goldnugget", 6)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("kitcoondecor1_kit",				{Ingredient("lucky_goldnugget", 12)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("kitcoondecor2_kit",				{Ingredient("lucky_goldnugget", 12)},																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_catcoon_sketch",        {Ingredient("lucky_goldnugget", 8) },																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_kitcoon_sketch",        {Ingredient("lucky_goldnugget", 8) },																	TECH.CATCOONOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("yotb_stage_item",					{Ingredient("boards", 4), Ingredient("beefalowool", 2), Ingredient("goldnugget", 2)},   				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotb_post_item",					{Ingredient("boards", 2), Ingredient("goldnugget", 1)},                                 				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotb_sewingmachine_item",			{Ingredient("stinger", 1), Ingredient("goldnugget", 1), Ingredient("silk", 2)},         				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotb_pattern_fragment_1",			{Ingredient("lucky_goldnugget", 5)},                                                    				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotb_pattern_fragment_2",			{Ingredient("lucky_goldnugget", 5)},                                                    				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotb_pattern_fragment_3",			{Ingredient("lucky_goldnugget", 5)},                                                    				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_beefalo_sketch",		{Ingredient("lucky_goldnugget", 8)},                                                    				TECH.BEEFOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("yotc_carrat_race_start_item",      {Ingredient("goldnugget", 1)},																			TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_race_finish_item",     {Ingredient("goldnugget", 1)},																			TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_race_checkpoint_item", {Ingredient("lucky_goldnugget", 2)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_shrinecarrat",			    {Ingredient("goldnugget", 4)},																			TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING", product="carrat"})
Recipe2("yotc_carrat_gym_speed_item",       {Ingredient("lucky_goldnugget", 4)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_gym_reaction_item",    {Ingredient("lucky_goldnugget", 4)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_gym_stamina_item",     {Ingredient("lucky_goldnugget", 4)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_gym_direction_item",   {Ingredient("lucky_goldnugget", 4)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_carrat_scale_item",           {Ingredient("lucky_goldnugget", 1)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_seedpacket",					{Ingredient("lucky_goldnugget", 2)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotc_seedpacket_rare",		        {Ingredient("lucky_goldnugget", 4)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_carrat_sketch",         {Ingredient("lucky_goldnugget", 8)},																	TECH.CARRATOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("perdfan", 	                        {Ingredient("lucky_goldnugget", 3)},																	TECH.PERDOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("houndwhistle",                     {Ingredient("lucky_goldnugget", 3)},																	TECH.WARGOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_clayhound_sketch",      {Ingredient("lucky_goldnugget", 8) },																	TECH.WARGOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("chesspiece_claywarg_sketch",       {Ingredient("lucky_goldnugget", 16)},																	TECH.WARGOFFERING_THREE,	{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("yotp_food3", 	                    {Ingredient("lucky_goldnugget", 4)},																	TECH.PIGOFFERING_THREE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotp_food1", 	                    {Ingredient("lucky_goldnugget", 6)},																	TECH.PIGOFFERING_THREE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("yotp_food2", 	                    {Ingredient("lucky_goldnugget", 1)},																	TECH.PIGOFFERING_THREE,		{nounlock=true, actionstr="PERDOFFERING"})

Recipe2("firecrackers",                     {Ingredient("lucky_goldnugget", 1)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING", numtogive=3})
Recipe2("redlantern",                       {Ingredient("lucky_goldnugget", 3)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("miniboatlantern",                  {Ingredient("lucky_goldnugget", 3)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("dragonheadhat",                    {Ingredient("lucky_goldnugget", 8)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("dragonbodyhat",                    {Ingredient("lucky_goldnugget", 8)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING"})
Recipe2("dragontailhat",                    {Ingredient("lucky_goldnugget", 8)},																	TECH.PERDOFFERING_ONE,		{nounlock=true, actionstr="PERDOFFERING"})

--- summer carnival prize shop ---
Recipe2("carnival_popcorn",					{Ingredient("carnival_prizeticket", 12)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give", description="carnival_popcorn", numtogive=3, product="corn_cooked"})
Recipe2("carnival_seedpacket",				{Ingredient("carnival_prizeticket", 12)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivalfood_corntea",				{Ingredient("carnival_prizeticket", 12)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnival_vest_a",					{Ingredient("carnival_prizeticket", 24)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnival_vest_b",					{Ingredient("carnival_prizeticket", 48)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnival_vest_c",					{Ingredient("carnival_prizeticket", 48)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_figure_kit",			{Ingredient("carnival_prizeticket", 12)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivalcannon_confetti_kit",		{Ingredient("carnival_prizeticket", 18)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivalcannon_sparkle_kit",		{Ingredient("carnival_prizeticket", 18)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivalcannon_streamer_kit",		{Ingredient("carnival_prizeticket", 18)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_plant_kit",			{Ingredient("carnival_prizeticket", 24)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_eggride1_kit",		{Ingredient("carnival_prizeticket", 36)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_eggride2_kit",		{Ingredient("carnival_prizeticket", 36)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_eggride3_kit",		{Ingredient("carnival_prizeticket", 36)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})
Recipe2("carnivaldecor_lamp_kit",			{Ingredient("carnival_prizeticket", 48)}, 																TECH.CARNIVAL_PRIZESHOP_ONE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_PRIZESHOP", sg_state="give"})

--- summer carnival host
Recipe2("carnival_plaza_kit",				{Ingredient("goldnugget", 1), Ingredient("seeds", 3)},													TECH.CARNIVAL_HOSTSHOP_ONE,			{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})
Recipe2("carnival_prizebooth_kit",			{Ingredient("goldnugget", 1), Ingredient("seeds", 3)},													TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})
Recipe2("carnival_gametoken",				{Ingredient("seeds", 1)},																				TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})
Recipe2("carnival_gametoken_multiple",		{Ingredient("goldnugget", 1)},																			TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give", description="carnival_gametoken_multiple", numtogive=3, product="carnival_gametoken", image="carnival_gametoken_multiple.tex"})
Recipe2("carnivalgame_memory_kit",			{Ingredient("goldnugget", 1), Ingredient("seeds", 3)},													TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})
Recipe2("carnivalgame_feedchicks_kit",		{Ingredient("goldnugget", 1), Ingredient("seeds", 3)},													TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})
Recipe2("carnivalgame_herding_kit",			{Ingredient("goldnugget", 1), Ingredient("seeds", 3)},													TECH.CARNIVAL_HOSTSHOP_THREE,		{nounlock=true, no_deconstruction=true, actionstr="CARNIVAL_HOSTSHOP", sg_state="give"})

-- HALLOWED_NIGHTS
Recipe2("madscience_lab",				{Ingredient("cutstone", 2), Ingredient("transistor", 2)},																TECH.HALLOWED_NIGHTS,			{placer="madscience_lab_placer", hint_msg = "NEEDSHALLOWED_NIGHTS"})
Recipe2("candybag",						{Ingredient("cutgrass", 6)},																							TECH.HALLOWED_NIGHTS,			{hint_msg = "NEEDSHALLOWED_NIGHTS"})
Recipe2("halloween_experiment_bravery", {Ingredient("froglegs", 1), Ingredient("goldnugget", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)},					TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="halloweenpotion_bravery_small.tex"})
Recipe2("halloween_experiment_health", 	{Ingredient("mosquito", 1), Ingredient("red_cap", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)},						TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="halloweenpotion_health_small.tex"})
Recipe2("halloween_experiment_sanity", 	{Ingredient("crow", 1), Ingredient("petals_evil", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)},						TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="halloweenpotion_sanity_small.tex"})
Recipe2("halloween_experiment_volatile",{Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)},					TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="halloweenpotion_embers.tex"})
Recipe2("halloween_experiment_moon", 	{Ingredient("moonbutterflywings", 1), Ingredient("moon_tree_blossom", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="halloweenpotion_moon.tex"})
Recipe2("halloween_experiment_root", 	{Ingredient("batwing", 1), Ingredient("livinglog", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 20)},					TECH.MADSCIENCE_ONE,			{nounlock = true, manufactured=true, actionstr="MADSCIENCE", image ="livingtree_root.tex"})

-- WINTERSFEAST
Recipe2("wintersfeastoven",				{Ingredient("cutstone", 1), Ingredient("marble", 1), Ingredient("log", 1)},												TECH.WINTERS_FEAST,				{placer="wintersfeastoven_placer", hint_msg = "NEEDSWINTERS_FEAST"})
Recipe2("table_winters_feast",			{Ingredient("boards", 1), Ingredient("beefalowool", 1)},																TECH.WINTERS_FEAST,				{placer="table_winters_feast_placer", hint_msg = "NEEDSWINTERS_FEAST", min_spacing=2.8, testfn = function(pt) return TheWorld.Map:GetPlatformAtPoint(pt.x, 0, pt.z, 0.5) == nil end})
Recipe2("winter_treestand",				{Ingredient("poop", 2), Ingredient("boards", 1)},																		TECH.WINTERS_FEAST,				{placer="winter_treestand_placer", hint_msg = "NEEDSWINTERS_FEAST" })
Recipe2("giftwrap",						{Ingredient("papyrus", 1), Ingredient("petals", 1)},																	TECH.WINTERS_FEAST,				{numtogive=4, hint_msg = "NEEDSWINTERS_FEAST"})

-- WINTERSFEAST oven
Recipe2("wintercooking_berrysauce",		{Ingredient("wintersfeastfuel", 1), Ingredient("mosquitosack", 2)},														TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "berrysauce.tex"})
Recipe2("wintercooking_bibingka",		{Ingredient("wintersfeastfuel", 1), Ingredient("foliage", 2)},															TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "bibingka.tex"})
Recipe2("wintercooking_cabbagerolls",	{Ingredient("wintersfeastfuel", 1), Ingredient("cutreeds", 2)},															TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "cabbagerolls.tex"})
Recipe2("wintercooking_festivefish",	{Ingredient("wintersfeastfuel", 1), Ingredient("spoiled_fish_small", 1), Ingredient("petals", 1)},						TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "festivefish.tex"})
Recipe2("wintercooking_gravy",			{Ingredient("wintersfeastfuel", 1), Ingredient("spoiled_food", 1), Ingredient("boneshard", 1)},							TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "gravy.tex"})
Recipe2("wintercooking_latkes",			{Ingredient("wintersfeastfuel", 1), Ingredient("twigs", 1), Ingredient("cutgrass", 1)},									TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "latkes.tex"})
Recipe2("wintercooking_lutefisk",		{Ingredient("wintersfeastfuel", 1), Ingredient("spoiled_fish", 1), Ingredient("driftwood_log", 1)},						TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "lutefisk.tex"})
Recipe2("wintercooking_mulleddrink",	{Ingredient("wintersfeastfuel", 1), Ingredient("petals_evil", 1), Ingredient("ice", 1)},								TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "mulleddrink.tex"})
Recipe2("wintercooking_panettone",		{Ingredient("wintersfeastfuel", 1), Ingredient("rock_avocado_fruit", 2, nil, nil, "rock_avocado_fruit_rockhard.tex")},  TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "panettone.tex"})
Recipe2("wintercooking_pavlova",		{Ingredient("wintersfeastfuel", 1), Ingredient("moon_tree_blossom", 2)},												TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "pavlova.tex"})
Recipe2("wintercooking_pickledherring",	{Ingredient("wintersfeastfuel", 1), Ingredient("flint", 1), Ingredient("saltrock", 1)},									TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "pickledherring.tex"})
Recipe2("wintercooking_polishcookie",	{Ingredient("wintersfeastfuel", 1), Ingredient("butterflywings", 2)},													TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "polishcookie.tex"})
Recipe2("wintercooking_pumpkinpie",		{Ingredient("wintersfeastfuel", 1), Ingredient("ash", 1), Ingredient("phlegm", 1)},										TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "pumpkinpie.tex"})
Recipe2("wintercooking_roastturkey",	{Ingredient("wintersfeastfuel", 1), Ingredient("log", 1), Ingredient("charcoal", 1)},									TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "roastturkey.tex"})
Recipe2("wintercooking_stuffing",		{Ingredient("wintersfeastfuel", 1), Ingredient("beardhair", 2)},														TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "stuffing.tex"})
Recipe2("wintercooking_sweetpotato",	{Ingredient("wintersfeastfuel", 1), Ingredient("rocks", 2)},															TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "sweetpotato.tex"})
Recipe2("wintercooking_tamales",		{Ingredient("wintersfeastfuel", 1), Ingredient("stinger", 2)},															TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "tamales.tex"})
Recipe2("wintercooking_tourtiere",		{Ingredient("wintersfeastfuel", 1), Ingredient("acorn", 1), Ingredient("pinecone", 1)},									TECH.WINTERSFEASTCOOKING_ONE,	{nounlock = true, manufactured=true, actionstr="COOK", image = "tourtiere.tex"})

-- YOT Events
Recipe2("perdshrine",					{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOTG,						{placer="perdshrine_placer", hint_msg = "NEEDSYOTG"})
Recipe2("wargshrine",					{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOTV,						{placer="wargshrine_placer", hint_msg = "NEEDSYOTV"})
Recipe2("pigshrine",					{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOTP,						{placer="pigshrine_placer", hint_msg = "NEEDSYOTP"})
Recipe2("yotc_carratshrine",			{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOTC,						{placer="yotc_carratshrine_placer", hint_msg = "NEEDSYOTC"})
Recipe2("yotb_beefaloshrine",			{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOTB,						{placer="yotb_beefaloshrine_placer", hint_msg = "NEEDSYOTB"})
Recipe2("yot_catcoonshrine",			{Ingredient("goldnugget", 4), Ingredient("boards", 2)},																	TECH.YOT_CATCOON,				{placer="yot_catcoonshrine_placer", hint_msg = "NEEDSYOTCATCOON"})


----CONSTRUCTION PLANS----
CONSTRUCTION_PLANS =
{
    ["multiplayer_portal_moonrock_constr"] = { Ingredient("purplemooneye", 1), Ingredient("moonrocknugget", 20) },
	["mermthrone_construction"] = { Ingredient("kelp", 20), Ingredient("pigskin", 10), Ingredient("beefalowool", 15) },
	["hermithouse_construction1"] = { Ingredient("cookiecuttershell", 10), Ingredient("boards", 10) },
	["hermithouse_construction2"] = { Ingredient("marble", 10), Ingredient("rope", 10) },
	["hermithouse_construction3"] = { Ingredient("moonrocknugget", 5),   Ingredient("cactus_flower", 10) },

	["moon_device_construction1"] = { Ingredient("moonstorm_static_item", 1), Ingredient("moonstorm_spark", 10), Ingredient("moonglass_charged", 10) },
	["moon_device_construction2"] = { Ingredient("moonstorm_static_item", 1), Ingredient("moonglass_charged", 20), Ingredient("moonrockseed", 1) },
}


---- Deconstruction Recipes----
--NOTE: These recipes are for overriding the items returned when something is deconstructed or hammered.

--- summar carnival prize, return the kit when destroyed
DeconstructRecipe("carnivaldecor_plant",			{Ingredient("carnivaldecor_plant_kit", 1)})
DeconstructRecipe("carnivaldecor_figure",			{Ingredient("carnivaldecor_figure_kit", 1)})
DeconstructRecipe("carnivaldecor_eggride1",			{Ingredient("carnivaldecor_eggride1_kit", 1)})
DeconstructRecipe("carnivaldecor_eggride2",			{Ingredient("carnivaldecor_eggride2_kit", 1)})
DeconstructRecipe("carnivaldecor_eggride3",			{Ingredient("carnivaldecor_eggride3_kit", 1)})
DeconstructRecipe("carnivaldecor_lamp",				{Ingredient("carnivaldecor_lamp_kit", 1)})
DeconstructRecipe("carnivalcannon_confetti",		{Ingredient("carnivalcannon_confetti_kit", 1)})
DeconstructRecipe("carnivalcannon_sparkle",			{Ingredient("carnivalcannon_sparkle_kit", 1)})
DeconstructRecipe("carnivalcannon_streamer",		{Ingredient("carnivalcannon_streamer_kit", 1)})

--- summar carnival host, return the kit when destroyed
DeconstructRecipe("carnival_plaza",					{Ingredient("carnival_plaza_kit", 1)})
DeconstructRecipe("carnival_prizebooth",			{Ingredient("carnival_prizebooth_kit", 1)})
DeconstructRecipe("carnivalgame_memory_station",	{Ingredient("carnivalgame_memory_kit", 1)})
DeconstructRecipe("carnivalgame_feedchicks_station",{Ingredient("carnivalgame_feedchicks_kit", 1)})
DeconstructRecipe("carnivalgame_herding_station",	{Ingredient("carnivalgame_herding_kit", 1)})

-- world gen items
DeconstructRecipe("pighead",						{Ingredient("pigskin", 4), Ingredient("twigs", 4)})
DeconstructRecipe("mermhead",						{Ingredient("pondfish", 1), Ingredient("spoiled_food", 4), Ingredient("twigs", 4)})
DeconstructRecipe("sunkenchest",					{Ingredient("slurtle_shellpieces", 5)})
DeconstructRecipe("mastupgrade_lamp",				{Ingredient("boards", 1), Ingredient("rope", 2), Ingredient("flint", 4)})
DeconstructRecipe("mastupgrade_lightningrod",		{Ingredient("goldnugget", 5)})
DeconstructRecipe("wall_ruins_2_item",				{Ingredient("thulecite", 1)})
DeconstructRecipe("wall_stone_2_item",				{Ingredient("cutstone", 2)})
DeconstructRecipe("terrariumchest",					{Ingredient("boards", 3)})

--Hermit shop material recipes
DeconstructRecipe("tacklecontainer",				{Ingredient("cookiecuttershell", 2), Ingredient("rope", 1)})
DeconstructRecipe("chum",							{Ingredient("spoiled_food", 2)})
DeconstructRecipe("supertacklecontainer",			{Ingredient("cookiecuttershell", 3), Ingredient("rope", 2)})

--deployed and kit item
DeconstructRecipe("yotb_post",						{Ingredient("boards", 2), Ingredient("goldnugget", 1)})
DeconstructRecipe("portablecookpot",				{Ingredient("goldnugget", 2), Ingredient("charcoal", 6), Ingredient("twigs", 6)})
DeconstructRecipe("portableblender",				{Ingredient("goldnugget", 2), Ingredient("transistor", 2), Ingredient("twigs", 4)})
DeconstructRecipe("portablespicer",					{Ingredient("goldnugget", 2), Ingredient("cutstone", 3), Ingredient("twigs", 6)})
DeconstructRecipe("steeringwheel",					{Ingredient("boards", 2), Ingredient("rope", 1)})
DeconstructRecipe("anchor", 						{Ingredient("boards", 2), Ingredient("rope", 3), Ingredient("cutstone", 3)})
DeconstructRecipe("mast",   						{Ingredient("boards", 3), Ingredient("rope", 3), Ingredient("silk",     8)})
DeconstructRecipe("mast_malbatross",				{Ingredient("driftwood_log", 3), Ingredient("rope", 3), Ingredient("malbatross_feathered_weave", 4)})
DeconstructRecipe("purplemooneye",					{Ingredient("moonrockcrater", 1), Ingredient("purplegem", 1)})
DeconstructRecipe("bluemooneye",					{Ingredient("moonrockcrater", 1), Ingredient("bluegem",   1)})
DeconstructRecipe("redmooneye",						{Ingredient("moonrockcrater", 1), Ingredient("redgem",    1)})
DeconstructRecipe("orangemooneye",					{Ingredient("moonrockcrater", 1), Ingredient("orangegem", 1)})
DeconstructRecipe("yellowmooneye",					{Ingredient("moonrockcrater", 1), Ingredient("yellowgem", 1)})
DeconstructRecipe("greenmooneye",					{Ingredient("moonrockcrater", 1), Ingredient("greengem",  1)})
DeconstructRecipe("opalstaff",						{Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("opalpreciousgem", 1)})
DeconstructRecipe("mermthrone",						{Ingredient("kelp", 20), Ingredient("pigskin", 10), Ingredient("beefalowool", 15)})
DeconstructRecipe("yotc_carrat_race_start",			{Ingredient("goldnugget", 1)})
DeconstructRecipe("yotc_carrat_race_finish",		{Ingredient("goldnugget", 1)})
DeconstructRecipe("yotc_carrat_race_checkpoint",	{Ingredient("lucky_goldnugget", 1)})
DeconstructRecipe("yotc_carrat_gym_direction",		{Ingredient("lucky_goldnugget", 4)})
DeconstructRecipe("yotc_carrat_gym_speed",			{Ingredient("lucky_goldnugget", 4)})
DeconstructRecipe("yotc_carrat_gym_reaction",		{Ingredient("lucky_goldnugget", 4)})
DeconstructRecipe("yotc_carrat_gym_stamina",		{Ingredient("lucky_goldnugget", 4)})
DeconstructRecipe("yotc_carrat_scale",				{Ingredient("lucky_goldnugget", 1)})
DeconstructRecipe("kitcoondecor1",					{Ingredient("lucky_goldnugget", 12)})
DeconstructRecipe("kitcoondecor2",					{Ingredient("lucky_goldnugget", 12)})
DeconstructRecipe("kitcoonden",						{Ingredient("lucky_goldnugget", 1)})
DeconstructRecipe("potatosack",						{Ingredient("cutgrass", 2), Ingredient("rocks", 3)})
DeconstructRecipe("minisign",						{Ingredient("boards", 1)})

-- Loot drops
DeconstructRecipe("archive_resonator",				{Ingredient("moonrocknugget", 1), Ingredient("thulecite", 1)})
DeconstructRecipe("alterguardianhat",				{Ingredient("alterguardianhatshard", 5)})
DeconstructRecipe("hivehat",						{Ingredient("honeycomb", 4), Ingredient("honey", 3), Ingredient("royal_jelly", 2), Ingredient("bee", 4)})
DeconstructRecipe("spiderhat",						{Ingredient("silk", 4), Ingredient("spidergland", 2), Ingredient("monstermeat", 1)})
DeconstructRecipe("armorskeleton",					{Ingredient("boneshard", 10), Ingredient("nightmarefuel", 6)})
DeconstructRecipe("skeletonhat",					{Ingredient("boneshard", 10), Ingredient("nightmarefuel", 4)})
DeconstructRecipe("thurible",						{Ingredient("cutstone", 2), Ingredient("nightmarefuel", 6), Ingredient("ash", 1)})
DeconstructRecipe("eyemaskhat",						{Ingredient("milkywhites", 3), Ingredient("monstermeat", 2)})
DeconstructRecipe("shieldofterror",					{Ingredient("gears", 2), Ingredient("nightmarefuel", 3)})

-- old deprecated structures
DeconstructRecipe("slow_farmplot",					{Ingredient("cutgrass", 8), Ingredient("poop", 4), Ingredient("log", 4)})
DeconstructRecipe("fast_farmplot",					{Ingredient("cutgrass", 10), Ingredient("poop", 6),Ingredient("rocks", 4)})
DeconstructRecipe("book_gardening",					{Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)})




require("recipes_filter")
-- verify that all recipes are placed in at least one filter group
local filter_check_failed = false
for recipe_name, recipe in pairs(AllRecipes) do
	if not recipe.is_deconstruction_recipe then
		local found = false
		for _, filter in pairs(CRAFTING_FILTERS) do
			if filter.default_sort_values ~= nil and type(filter.default_sort_values) == "table" and filter.default_sort_values[recipe_name] ~= nil then
				found = true
				break
			end
		end
		if not found then
			filter_check_failed = true
			print("ERROR: Recipe '"..recipe_name.."' is not in any crafting menu filters.")
		end
	end
end
if filter_check_failed then
	assert(false, "The above recipes are not covered by a crafting menu filter")
end


mod_protect_Recipe = true