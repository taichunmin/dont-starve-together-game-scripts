local tasksets = require("map/tasksets")
local tasks = require ("map/tasks")
local startlocations = require ("map/startlocations")
local Levels = require("map/levels")

local frequency_descriptions
local worldgen_frequency_descriptions
if IsNotConsole() then
	frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
	worldgen_frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEUNCOMMON, data = "uncommon" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEMOSTLY, data = "mostly" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEINSANE, data = "insane" },
	}
else
	frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
	worldgen_frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEUNCOMMON, data = "uncommon" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEMOSTLY, data = "mostly" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
end
local ocean_worldgen_frequency_descriptions = {}
for i, data in ipairs(worldgen_frequency_descriptions) do
	ocean_worldgen_frequency_descriptions[i] = {text = data.text, data = "ocean_"..data.data}
end

local starting_swaps_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.CLASSIC, data = "classic" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.HIGHLYRANDOM, data = "highly random" },
}

local petrification_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.QTYNONE, data = "none" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "few" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "many" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "max" },
}

local speed_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local disease_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.QTYNONE, data = "none" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "long" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "short" },
}

local day_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "longday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "longdusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "longnight" },

	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "noday" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "nodusk" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "nonight" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "onlyday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "onlydusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "onlynight" },
}

local season_length_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "noseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSHORT, data = "veryshortseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHORT, data = "shortseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG, data = "longseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYLONG, data = "verylongseason" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},
}

local season_start_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER, data = "winter" },
	{ text = STRINGS.UI.SANDBOXMENU.SPRING, data = "spring" },
	{ text = STRINGS.UI.SANDBOXMENU.SUMMER, data = "summer" },
	{ text = STRINGS.UI.SANDBOXMENU.AUTUMN_SPRING, data = "autumn|spring" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER_SUMMER, data = "winter|summer" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "autumn|winter|spring|summer" },
}

local size_descriptions = nil
if IsPS4() then
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.PS4_SLIDESMALL, data = "default"},
		{ text = STRINGS.UI.SANDBOXMENU.PS4_SLIDESMEDIUM, data = "medium"},
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},
	}
else
	size_descriptions = {
		-- { text = STRINGS.UI.SANDBOXMENU.SLIDETINY, data = "teeny"},
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "small"},
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "default"},
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},
		-- { text = STRINGS.UI.SANDBOXMENU.SLIDESHUMONGOUS, data = "humongous"},
	}
end

local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random" },
}

local loop_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.LOOPNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPRANDOM, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPALWAYS, data = "always" },
}

local complexity_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSIMPLE, data = "verysimple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESIMPLE, data = "simple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDECOMPLEX, data = "complex" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYCOMPLEX, data = "verycomplex" },
}

local specialevent_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "none" },
	{ text = STRINGS.UI.SANDBOXMENU.SPECIAL_EVENTS.DEFAULT, data = "default" },
}

local extraevent_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.DETECT_ALWAYS, data = "enabled" },
}

local extrastartingitems_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.DETECT_ALWAYS, data = "0" },
	{ text = STRINGS.UI.SANDBOXMENU.DAY_5, data = "5" },
	{ text = STRINGS.UI.SANDBOXMENU.DAY_10, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.DAY_15, data = "15" },
	{ text = STRINGS.UI.SANDBOXMENU.DAY_20, data = "20" },
	{ text = STRINGS.UI.SANDBOXMENU.DETECT_NEVER, data = "none" },
}

local atrium_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local autodetect = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.DETECT_AUTO, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.DETECT_ALWAYS, data = "always" },
}

local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
}

local dropeverythingondespawn_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.EVERYTHING, data = "always" },
}

local descriptions = {
	frequency_descriptions = frequency_descriptions,
	worldgen_frequency_descriptions = worldgen_frequency_descriptions,
	ocean_worldgen_frequency_descriptions = ocean_worldgen_frequency_descriptions,
	starting_swaps_descriptions = starting_swaps_descriptions,
	petrification_descriptions = petrification_descriptions,
	speed_descriptions = speed_descriptions,
	disease_descriptions = disease_descriptions,
	day_descriptions = day_descriptions,
	season_length_descriptions = season_length_descriptions,
	season_start_descriptions = season_start_descriptions,
	size_descriptions = size_descriptions,
	branching_descriptions = branching_descriptions,
	loop_descriptions = loop_descriptions,
	complexity_descriptions = complexity_descriptions,
	specialevent_descriptions = specialevent_descriptions,
	extraevent_descriptions = extraevent_descriptions,
	yesno_descriptions = yesno_descriptions,
	extrastartingitems_descriptions = extrastartingitems_descriptions,
	autodetect = autodetect,
	dropeverythingondespawn_descriptions = dropeverythingondespawn_descriptions,
	atrium_descriptions = atrium_descriptions,
}

local WORLDGEN_GROUP = {
	["monsters"] = {
		order = 5,
		text = STRINGS.UI.SANDBOXMENU.WORLDGENERATION_HOSTILE_CREATURES,
		desc = worldgen_frequency_descriptions,
		atlas = "images/worldgen_customization.xml",
		items={
			["spiders"] = {value = "default", image = "spiderden.tex", world={"forest", "cave"}},
			["cave_spiders"] = {value = "default", image = "cave_spiderden.tex", world={"cave"}},
			["houndmound"] = {value = "default", image = "houndmound.tex", world={"forest"}},
			["merm"] = {value = "default", image = "mermhut.tex", world={"forest"}},
			["tentacles"] = {value = "default", image = "tentacles.tex", world={"forest", "cave"}},
			["chess"] = {value = "default", image = "chess_monsters.tex", world={"forest", "cave"}},
			["walrus"] = {value = "default", image = "mactuskcamp.tex", world={"forest"}},
			["bats"] = {value = "default", image = "batcave.tex", world={"cave"}},
			["fissure"] = {value = "default", image = "fissure.tex", world={"cave"}},
			["worms"] = {value = "default", image = "worms.tex", world={"cave"}},
			["moon_spiders"] = {value = "default", image = "moon_spiders.tex", world = {"forest"}},
			["ocean_waterplant"] = {value = "ocean_default", image = "ocean_waterplant.tex", desc = ocean_worldgen_frequency_descriptions, world = {"forest"}},
			["angrybees"] = {value = "default", image = "wasphive.tex", world={"forest"}},
			["tallbirds"] = {value = "default", image = "tallbirdnest.tex", world={"forest"}},
		}
	},
	["animals"] = {
		order= 4,
		text = STRINGS.UI.SANDBOXMENU.WORLDGENERATION_ANIMALS,
		desc = worldgen_frequency_descriptions,
		atlas = "images/worldgen_customization.xml",
		items={
			-- ["mandrake"] = {value = "default", image = "mandrake.tex", world={"forest", "cave"}},
			["rabbits"] = {value = "default", image = "rabbithole.tex", world={"forest"}},
			["moles"] = {value = "default", image = "molehill.tex", world={"forest"}},
			["buzzard"] = {value = "default", image = "buzzard.tex", world={"forest"}},
			["catcoon"] = {value = "default", image = "catcoonden.tex", world={"forest"}},
			["pigs"] = {value = "default", image = "pighouse.tex", world={"forest"}},
			["lightninggoat"] = {value = "default", image = "lightning_goat.tex", world={"forest"}},
			["beefalo"] = {value = "default", image = "beefalo.tex", world={"forest"}},
			["bees"] = {value = "default", image = "beehive.tex", world={"forest"}},
			["slurper"] = {value = "default", image = "slurper.tex", world={"cave"}},
			["bunnymen"] = {value = "default", image = "bunnyhutch.tex", world={"cave"}},
			["slurtles"] = {value = "default", image = "slurtleden.tex", world={"cave"}},
			["rocky"] = {value = "default", image = "rocky.tex", world={"cave"}},
			["monkey"] = {value = "default", image = "monkeybarrel.tex", world={"cave"}},
			["moon_carrot"] = {value = "default", image = "moon_carrot.tex", world = {"forest"}},
			["moon_fruitdragon"] = {value = "default", image = "moon_fruitdragon.tex", world = {"forest"}},
			["ocean_shoal"] = {value = "default", image = "ocean_shoal.tex", world = {"forest"}},
			["ocean_wobsterden"] = {value = "default", image = "ocean_wobsterden.tex", world = {"forest"}},
		}
	},
	["resources"] = {
		order= 3,
		text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES,
		desc = worldgen_frequency_descriptions,
		atlas = "images/worldgen_customization.xml",
		items={
			["flowers"] = {value = "default", image = "flowers.tex", world={"forest"}},
			["grass"] = {value = "default", image = "grass.tex", world={"forest", "cave"}},
			["sapling"] = {value = "default", image = "sapling.tex", world={"forest", "cave"}},
			["marshbush"] = {value = "default", image = "marsh_bush.tex", world={"forest", "cave"}},
			["tumbleweed"] = {value = "default", image = "tumbleweeds.tex", world={"forest"}},
			["reeds"] = {value = "default", image = "reeds.tex", world={"forest", "cave"}},
			["trees"] = {value = "default", image = "trees.tex", world={"forest", "cave"}},
			["flint"] = {value = "default", image = "flint.tex", world={"forest", "cave"}},
			["rock"] = {value = "default", image = "rock.tex", world={"forest", "cave"}},
			["rock_ice"] = {value = "default", image = "iceboulder.tex", world={"forest"}},
			["meteorspawner"] = {value = "default", image = "burntground.tex", world={"forest"}},
			["mushtree"] = {value = "default", image = "mushtree.tex", world={"cave"}},
			["fern"] = {value = "default", image = "fern.tex", world={"cave"}},
			["flower_cave"] = {value = "default", image = "flower_cave.tex", world={"cave"}},
			["wormlights"] = {value = "default", image = "wormlights.tex", world={"cave"}},
			["berrybush"] = {value = "default", image = "berrybush.tex", world={"forest", "cave"}},
			["carrot"] = {value = "default", image = "carrot.tex", world={"forest"}},
			["mushroom"] = {value = "default", image = "mushrooms.tex", world={"forest", "cave"}},
			["cactus"] = {value = "default", image = "cactus.tex", world={"forest"}},
			["banana"] = {value = "default", image = "banana.tex", world={"cave"}},
			["lichen"] = {value = "default", image = "lichen.tex", world={"cave"}},
			["moon_tree"] = {value = "default", image = "moon_tree.tex", world = {"forest"}},
			["moon_sapling"] = {value = "default", image = "moon_sapling.tex", world = {"forest"}},
			["moon_berrybush"] = {value = "default", image = "moon_berrybush.tex", world = {"forest"}},
			["moon_rock"] = {value = "default", image = "moon_rock.tex", world = {"forest"}},
			["moon_hotspring"] = {value = "default", image = "moon_hotspring.tex", world = {"forest"}},
			["moon_starfish"] = {value = "default", image = "moon_starfish.tex", world = {"forest"}},
			["moon_bullkelp"] = {value = "default", image = "moon_bullkelp.tex", world = {"forest"}},
			["ponds"] = {value = "default", image = "ponds.tex", world={"forest"}},
			["cave_ponds"] = {value = "default", image = "ponds.tex", world={"cave"}},
			["ocean_bullkelp"] = {value = "default", image = "ocean_bullkelp.tex", world = {"forest"}},
			["ocean_seastack"] = {value = "ocean_default", image = "ocean_seastack.tex", desc = ocean_worldgen_frequency_descriptions, world = {"forest"}},
		}
	},
	["misc"] = {
		order= 2,
		text = STRINGS.UI.SANDBOXMENU.CHOICEMISC,
		desc = nil,
		atlas = "images/worldgen_customization.xml",
		items={
			--["location"] = {value = "forest", image = "world_map.tex", desc = location_descriptions, order = 0, world={"forest", "cave"}},
			["task_set"] = {value = "default", image = "world_map.tex", options_remap = {img = "blank_world.tex", atlas = "images/customisation.xml"}, desc = tasksets.GetGenTaskLists, order = 1, world={"forest", "cave"}},
			["start_location"] = {value = "default", image = "world_start.tex", options_remap = {img = "blank_world.tex", atlas = "images/customisation.xml"}, desc = startlocations.GetGenStartLocations, order = 2, world={"forest", "cave"}},
			["world_size"] = {value = "default", image = "world_size.tex", options_remap = {img = "blank_world.tex", atlas = "images/customisation.xml"}, desc = size_descriptions, order = 3, world={"forest", "cave"}},
			["branching"] = {value = "default", image = "world_branching.tex", options_remap = {img = "blank_world.tex", atlas = "images/customisation.xml"}, desc = branching_descriptions, order = 4, world={"forest", "cave"}},
			["loop"] = {value = "default", image = "world_loop.tex", options_remap = {img = "blank_world.tex", atlas = "images/customisation.xml"}, desc = loop_descriptions, order = 5, world={"forest", "cave"}},
			["roads"] = {value = "default", image = "roads.tex", desc = yesno_descriptions, order = 6, world={"forest"}},
			["touchstone"] = {value = "default", image = "touchstone.tex", desc = worldgen_frequency_descriptions, order = 17, world={"forest", "cave"}},
			["boons"] = {value = "default", image = "skeletons.tex", desc = worldgen_frequency_descriptions, order = 18, world={"forest", "cave"}},
			["cavelight"] = {value = "default", image = "cavelight.tex", desc = speed_descriptions, order = 18, world={"cave"}},
			["prefabswaps_start"] = {value = "default", image = "starting_variety.tex", options_remap = {img = "blank_grassy.tex", atlas = "images/customisation.xml"}, desc = starting_swaps_descriptions, order = 20, world={"forest", "cave"}},
			["moon_fissure"] = {value = "default", image = "moon_fissure.tex", desc = worldgen_frequency_descriptions, world = {"forest"}},
			["terrariumchest"] = {value = "default", image = "terrarium.tex", desc = yesno_descriptions, world={"forest"}},
		}
	},
	["global"] = {
		order = 1,
		text = STRINGS.UI.SANDBOXMENU.CHOICEGLOBAL,
		desc = nil,
		atlas = "images/worldgen_customization.xml",
		items = {
			["season_start"] = {value = "default", image = "season_start.tex", options_remap = {img = "blank_season_red.tex", atlas = "images/customisation.xml"}, desc = season_start_descriptions, master_controlled = true, order = 1},
		}
	}
}

local WORLDGEN_MISC = {
	"has_ocean",
	"keep_disconnected_tiles",
	"layout_mode",
	"no_joining_islands",
	"no_wormholes_to_disconnected_tiles",
	"wormhole_prefab",
}

local MOD_WORLDGEN_GROUP = {}
local MOD_WORLDGEN_MISC = {}

local WORLDSETTINGS_GROUP = {
	["giants"] = {
		order = 7,
		text = STRINGS.UI.SANDBOXMENU.CHOICEGIANTS,
		desc = frequency_descriptions,
		atlas = "images/worldsettings_customization.xml",
		items={
			["liefs"] = {value = "default", image = "liefs.tex", world={"forest", "cave"}},
			["deciduousmonster"] = {value = "default", image = "deciduouspoison.tex", world={"forest"}},
			["bearger"] = {value = "default", image = "bearger.tex", world={"forest"}},
			["deerclops"] = {value = "default", image = "deerclops.tex", world={"forest"}},
			["goosemoose"] = {value = "default", image = "goosemoose.tex", world={"forest"}},
			["dragonfly"] = {value = "default", image = "dragonfly.tex", world={"forest"}},
			["antliontribute"] = {value = "default", image = "antlion_tribute.tex", world={"forest"}},
			["crabking"] = {value = "default", image = "crabking.tex", world={"forest"}},
			["beequeen"] = {value = "default", image = "beequeen.tex", world={"forest"}},
			["toadstool"] = {value = "default", image = "toadstool.tex", world={"cave"}},
			["malbatross"] = {value = "default", image = "malbatross.tex", world={"forest"}},
			["fruitfly"] = {value = "default", image = "fruitfly.tex", world={"forest", "cave"}},
			["klaus"] = {value = "default", image = "klaus.tex", world={"forest"}},
			["spiderqueen"] = {value = "default", image = "spiderqueen.tex", world={"forest", "cave"}},
			["eyeofterror"] = {value = "default", image = "eyeofterror.tex", world={"forest"}},
			--NO_BOSS_TIME?
		}
	},
	["monsters"] = {
		order = 6,
		text = STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_HOSTILE_CREATURES,
		desc = frequency_descriptions,
		atlas = "images/worldsettings_customization.xml",
		items={
			["mutated_hounds"] = {value = "default", desc = yesno_descriptions, image = "mutated_hounds.tex", world={"forest"}},
			["lureplants"] = {value = "default", image = "lureplants.tex", world={"forest"}},
			["hound_mounds"] = {value = "default", image = "hounds.tex", world={"forest"}},
			["mosquitos"] = {value = "default", image = "mosquitos.tex", world={"forest"}},
			["sharks"] = {value = "default", image = "sharks.tex", world={"forest"}},
			["squid"] = {value = "default", image = "squid.tex", world={"forest"}},
			["wasps"] = {value = "default", image = "wasps.tex", world={"forest"}},
			["frogs"] = {value = "default", image = "frogs.tex", world={"forest"}},
			["penguins_moon"] = {value = "default", desc = yesno_descriptions, image = "moon_pengull.tex", world={"forest"}},
			["moon_spider"] = {value = "default", image = "moon_spider.tex", world={"forest"}},
			["walrus_setting"] = {value = "default", image = "mactusk.tex", world={"forest"}},
			["cookiecutters"] = {value = "default", image = "cookiecutters.tex", world={"forest"}},

			["merms"] = {value = "default", image = "merms.tex", world={"forest", "cave"}},
			["spiders_setting"] = {value = "default", image = "spiders.tex", world={"forest", "cave"}},
			["spider_warriors"] = {value = "default", desc = yesno_descriptions, image = "spider_warriors.tex", world={"forest", "cave"}},
			["bats_setting"] = {value = "default", image = "bats.tex", world={"forest", "cave"}},

			["nightmarecreatures"] = {value = "default", image = "nightmarecreatures.tex", world={"cave"}},
			["spider_hider"] = {value = "default", image = "spider_hider.tex", world={"cave"}},
			["spider_spitter"] = {value = "default", image = "spider_spitter.tex", world={"cave"}},
			["spider_dropper"] = {value = "default", image = "spider_dropper.tex", world={"cave"}},
			["molebats"] = {value = "default", image = "molebats.tex", world={"cave"}},
		}
	},
	["animals"] = {
		order= 5,
		text = STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_ANIMALS,
		desc = frequency_descriptions,
		atlas = "images/worldsettings_customization.xml",
		items={
			["butterfly"] = {value = "default", image = "butterfly.tex", world={"forest"}},
			["birds"] = {value = "default", image = "birds.tex", world={"forest"}},
			["perd"] = {value = "default", image = "perd.tex", world={"forest"}},
			["penguins"] = {value = "default", image = "pengull.tex", world={"forest"}},
			["bees_setting"] = {value = "default", image = "bees.tex", world={"forest"}},
			["catcoons"] = {value = "default", image = "catcoons.tex", world={"forest"}},
			["rabbits_setting"] = {value = "default", image = "rabbits.tex", world={"forest"}},
			["wobsters"] = {value = "default", image = "wobsters.tex", world={"forest"}},
			["gnarwail"] = {value = "default", image = "gnarwail.tex", world={"forest"}},
			["fishschools"] = {value = "default", image = "fishschool.tex", world={"forest"}},

			["pigs_setting"] = {value ="default", image = "pigs.tex", world={"forest", "cave"}},
			["bunnymen_setting"] = {value ="default", image = "bunnymen.tex", world={"forest", "cave"}},
			["moles_setting"] = {value = "default", image = "moles.tex", world={"forest", "cave"}},
			["grassgekkos"] = {value = "default", image = "grassgekkos.tex", world={"forest", "cave"}},

			["slurtles_setting"] = {value ="default", image = "slurtles.tex", world={"cave"}},
			["snurtles"] = {value ="default", image = "snurtles.tex", world={"cave"}},
			["rocky_setting"] = {value ="default", image = "rock_lobsters.tex", world={"cave"}},
			["monkey_setting"] = {value ="default", image = "monkeys.tex", world={"cave"}},
			["dustmoths"] = {value ="default", image = "dustmoths.tex", world={"cave"}},
			["lightfliers"] = {value ="default", image = "lightfliers.tex", world={"cave"}},
			["mushgnome"] = {value = "default", image = "mushgnome.tex", world={"cave"}},
		}
	},
	["resources"] = {
		order= 4,
		text = STRINGS.UI.SANDBOXMENU.WORLDSETTINGS_RESOURCEREGROWTH,
		desc = speed_descriptions,
		atlas = "images/worldsettings_customization.xml",
		items={
			["regrowth"] = {value = "default", image = "regrowth.tex", order = 1, world={"forest", "cave"}},

			["evergreen_regrowth"] = {value = "default", image = "evergreen.tex", world={"forest"}},
			["deciduoustree_regrowth"] = {value = "default", image = "deciduoustree.tex", world={"forest"}},
			["twiggytrees_regrowth"] = {value = "default", image = "twiggytrees.tex", world={"forest"}},
			["moon_tree_regrowth"] = {value = "default", image = "moon_tree.tex", world={"forest"}},
			["flowers_regrowth"] = {value = "default", image = "flowers.tex", world={"forest"}},
			["carrots_regrowth"] = {value = "default", image = "carrots.tex", world={"forest"}},
			["saltstack_regrowth"] = {value = "default", image = "saltstack.tex", world={"forest"}},

			["flower_cave_regrowth"] = {value = "default", image = "flower_cave.tex", world={"cave"}},
			["lightflier_flower_regrowth"] = {value = "default", image = "lightflier_flower.tex", world={"cave"}},
			["mushtree_regrowth"] = {value = "default", image = "mushtree.tex", world={"cave"}},
			["mushtree_moon_regrowth"] = {value = "default", image = "mushtree_moon.tex", world={"cave"}},
		}
	},
	["misc"] = {
		order= 3,
		text = STRINGS.UI.SANDBOXMENU.CHOICEMISC,
		desc = nil,
		atlas = "images/worldsettings_customization.xml",
		items={
			["lightning"] = {value = "default", image = "lightning.tex", desc = frequency_descriptions, world={"forest"}},
			["frograin"] = {value = "default", image = "frog_rain.tex", desc = frequency_descriptions, world={"forest"}},
			["wildfires"] = {value = "default", image = "smoke.tex", desc = frequency_descriptions, world={"forest"}},
			["petrification"] = {value = "default", image = "petrified_tree.tex", desc = petrification_descriptions, world={"forest"}},
			["meteorshowers"] = {value = "default", image = "meteor.tex", desc = frequency_descriptions, world={"forest"}},
			["hunt"] = {value = "default", image = "tracks.tex", desc = frequency_descriptions, world={"forest"}},
			["alternatehunt"] = {value = "default", image = "alternatehunt.tex", desc = frequency_descriptions, world={"forest"}},
			["hounds"] = {value = "default", image = "houndattacks.tex", desc = frequency_descriptions, world={"forest"}, order = 1},
			["winterhounds"] = {value = "default", image = "winterhounds.tex", desc = yesno_descriptions, world={"forest"}, order = 2},
			["summerhounds"] = {value = "default", image = "summerhounds.tex", desc = yesno_descriptions, world={"forest"}, order = 3},

			["weather"] = {value = "default", image = "rain.tex", desc = frequency_descriptions, world={"forest", "cave"}},

			["earthquakes"] = {value = "default", image = "earthquakes.tex", desc = frequency_descriptions, world={"cave"}},
			["wormattacks"] = {value = "default", image = "wormattacks.tex", desc = frequency_descriptions, world={"cave"}},
			["atriumgate"] = {value = "default", image = "atriumgate.tex", desc = atrium_descriptions, world={"cave"}},

			--["disease_delay"] = {value = "default", image = "berrybush_diseased.tex", desc = disease_descriptions, world={"forest", "cave"}},
		}
	},
	["survivors"] = {
		order = 2,
		text = STRINGS.UI.SANDBOXMENU.CHOICESURVIVORS,
		desc = nil,
		atlas = "images/worldsettings_customization.xml",
		items = {
			["extrastartingitems"] = {value = "default", image = "extrastartingitems.tex", desc = extrastartingitems_descriptions, order = 1, masteroption = true, master_controlled = true},
			["seasonalstartingitems"] = {value = "default", image = "seasonalstartingitems.tex", desc = yesno_descriptions, order = 2, masteroption = true, master_controlled = true},
			["spawnprotection"] = {value = "default", image = "spawnprotection.tex", desc = autodetect, order = 3, masteroption = true, master_controlled = true},
			["dropeverythingondespawn"] = {value = "default", image = "dropeverythingondespawn.tex", desc = dropeverythingondespawn_descriptions, order = 4, masteroption = true, master_controlled = true},
			["shadowcreatures"] = {value = "default", image = "shadowcreatures.tex", desc = frequency_descriptions, order = 5, masteroption = true, master_controlled = true},
			["brightmarecreatures"] = {value = "default", image = "brightmarecreatures.tex", desc = frequency_descriptions, order = 5, masteroption = true, master_controlled = true},
		}
	},
	["events"] = {
		order = 1,
		text = STRINGS.UI.SANDBOXMENU.CHOICEEVENTS,
		desc = extraevent_descriptions,
		atlas = "images/worldsettings_customization.xml",
		items = {
			["crow_carnival"] = {value = "default", image = "crowcarnival.tex", masteroption = true, master_controlled = true, order = 1},
			["hallowed_nights"] = {value = "default", image = "hallowednights.tex", masteroption = true, master_controlled = true, order = 2},
			["winters_feast"] = {value = "default", image = "wintersfeast.tex", masteroption = true, master_controlled = true, order = 3},
			["year_of_the_gobbler"] = {value = "default", image = "perdshrine.tex", masteroption = true, master_controlled = true, order = 4},
			["year_of_the_varg"] = {value = "default", image = "wargshrine.tex", masteroption = true, master_controlled = true, order = 5},
			["year_of_the_pig"] = {value = "default", image = "pigshrine.tex", masteroption = true, master_controlled = true, order = 6},
			["year_of_the_carrat"] = {value = "default", image = "yotc_carratshrine.tex", masteroption = true, master_controlled = true, order = 7},
			["year_of_the_beefalo"] = {value = "default", image = "yotb_beefaloshrine.tex", masteroption = true, master_controlled = true, order = 8},
			["year_of_the_catcoon"] = {value = "default", image = "yot_catcoonshrine.tex", masteroption = true, master_controlled = true, order = 9},
		}
	},
	["global"] = {
		order = 0,
		text = STRINGS.UI.SANDBOXMENU.CHOICEGLOBAL,
		desc = nil,
		atlas = "images/worldsettings_customization.xml",
		items = {
			["specialevent"] = {value = "default", image = "events.tex", desc = specialevent_descriptions, masteroption = true, master_controlled = true, order = 1},
			["autumn"] = {value = "default", image = "autumn.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, master_controlled = true, order = 2},
			["winter"] = {value = "default", image = "winter.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, master_controlled = true, order = 3},
			["spring"] = {value = "default", image = "spring.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, master_controlled = true, order = 4},
			["summer"] = {value = "default", image = "summer.tex", options_remap = {img = "blank_season_yellow.tex", atlas = "images/customisation.xml"}, desc = season_length_descriptions, master_controlled = true, order = 5},
			["day"] = {value = "default", image = "day.tex", desc = day_descriptions, masteroption = true, master_controlled = true, order = 6},
			["beefaloheat"] = {value = "default", image = "beefaloheat.tex", desc = frequency_descriptions, masteroption = true, master_controlled = true, order = 7},
			["krampus"] = {value = "default", image = "krampus.tex", desc = frequency_descriptions, masteroption = true, master_controlled = true, order = 8},
		}
	},
}
local WORLDSETTINGS_MISC = {

}

local MOD_WORLDSETTINGS_GROUP = {}
local MOD_WORLDSETTINGS_MISC = {}

--only add something to this list if it won't get processed via WorldSettings_Overrides
local EXEMPT_OPTIONS = {
	specialevent = true,
	spawnprotection = true,
}

for k, v in pairs(SPECIAL_EVENTS) do
	if v ~= SPECIAL_EVENTS.NONE then
		local found = false
		for _, group_data in pairs(WORLDSETTINGS_GROUP) do
			for name in pairs(group_data.items) do
				if name == v then
					found = true
					break
				end
			end
		end
		assert(found, "Missing customize option for special event: "..tostring(k))
		EXEMPT_OPTIONS[v] = true
	end
end

local WorldSettings_Overrides = require("worldsettings_overrides")
for _, group_data in pairs(WORLDSETTINGS_GROUP) do
	for name in pairs(group_data.items) do
		assert(WorldSettings_Overrides.Pre[name] or WorldSettings_Overrides.Post[name] or EXEMPT_OPTIONS[name], "Missing WorldSettings_Override for customization option "..name)
	end
end

local OPTIONS = {}
for _, group in ipairs({WORLDGEN_GROUP, WORLDSETTINGS_GROUP}) do
	for group_name, group_data in pairs(group) do
		group_data.master_group = group
		group_data.group_name = group_name
		group_data.category = (group == WORLDGEN_GROUP and LEVELCATEGORY.WORLDGEN) or (group == WORLDSETTINGS_GROUP and LEVELCATEGORY.SETTINGS) or nil
		for name, item in pairs(group_data.items) do
			item.name = name
			item.master_group = group
			item.group = group_data
			item.category = group_data.category
			OPTIONS[name] = item
		end
	end
end

local OPTIONS_MISC = {}
for _, group in ipairs({WORLDGEN_MISC, WORLDSETTINGS_MISC}) do
	for _, name in ipairs(group) do
		local item = {}
		item.name = name
		if group == WORLDGEN_MISC then
			item.category = LEVELCATEGORY.WORLDGEN
		elseif group == WORLDSETTINGS_MISC then
			item.category = LEVELCATEGORY.SETTINGS
		end
		OPTIONS_MISC[name] = item
	end
end

local MOD_OPTIONS = {}
local MOD_OPTIONS_MISC = {}

local MOD_DISABLE_GROUP = {}
local MOD_DISABLE_ITEM = {}

local function IsGroupDisabled(category, groupname)
	return MOD_DISABLE_GROUP[category] and MOD_DISABLE_GROUP[category][groupname] and not IsTableEmpty(MOD_DISABLE_GROUP[category][groupname])
end

local function IsItemDisabled(itemname)
	return MOD_DISABLE_ITEM[itemname] and not IsTableEmpty(MOD_DISABLE_ITEM[itemname])
end

local function GetOption(override)
	local option = OPTIONS[override]
	if option then
		if IsGroupDisabled(option.category, option.group.group_name) or IsItemDisabled(override) then return end
		return option
	end

	for modname, modoptions in pairs(MOD_OPTIONS) do
		option = modoptions[override]
		if option then return option end
	end
end

local function GetMiscOption(override)
	local option_misc = OPTIONS_MISC[override]
	if option_misc then
		if IsItemDisabled(override) then return end
		return option_misc
	end

	for modname, modoptionsmisc in pairs(MOD_OPTIONS_MISC) do
		option_misc = modoptionsmisc[override]
		if option_misc then return option_misc end
	end
end

local function GetGroupForOption(target)
	return nil
end

local ITEM_EXPORTS = {
	atlas = function(item) return item.atlas or item.group.atlas end,
	name = function(item) return item.name end,
	image = function(item) return item.image end,
	options = function(item, location) return FunctionOrValue(item.desc or item.group.desc, location) end,
	default = function(item) return item.value end,
	group = function(item) return item.group.group_name end,
	grouplabel = function(item) return item.group.text end,
	widget_type = function(item) return item.widget_type or "optionsspinner" end,
	options_remap = function(item) return item.options_remap end,
}

local DUPLICATE_AND_MOVE = {
	["flowers"] = "flowers_regrowth",
	["flower_cave"] = "flower_cave_regrowth",
}
local function GetWorldSettingsFromLevelSettings(overrides)
	local settings = {}
	for override, value in pairs(overrides) do
		local option = GetOption(override)
		if option and option.category == LEVELCATEGORY.SETTINGS then
			settings[override] = value
		elseif option and DUPLICATE_AND_MOVE[override] then
			settings[DUPLICATE_AND_MOVE[override]] = value
		end
	end
	return settings
end

local function GetMasterOptions()
	local options = {}
	for option_name, option in pairs(OPTIONS) do
		if not (IsGroupDisabled(option.category, option.group.group_name) or IsItemDisabled(option_name)) then
			if option.masteroption then
				options[option_name] = true
			end
		end
    end
    for modname, modoptions in pairs(MOD_OPTIONS) do
		for option_name, option in pairs(modoptions) do
			if option.masteroption then
				options[option_name] = true
			end
		end
	end
	return options
end

--only used for validating settings
local function GetOptions(location, is_master_world)
	local options = {}
	for option_name, option in pairs(OPTIONS) do
		if not (IsGroupDisabled(option.category, option.group.group_name) or IsItemDisabled(option_name)) then
			if location == nil or option.world == nil or table.contains(option.world, location) then
				if is_master_world or not option.master_controlled then
					table.insert(options, {name = option_name, options = FunctionOrValue(option.desc or option.group.desc, location), default = option.value, group = option.group.group_name})
				end
			end
		end
    end
    for modname, modoptions in pairs(MOD_OPTIONS) do
		for option_name, option in pairs(modoptions) do
			if location == nil or option.world == nil or table.contains(option.world, location) then
				if is_master_world or not option.master_controlled then
					table.insert(options, {name = option_name, options = FunctionOrValue(option.desc or option.group.desc, location), default = option.value, group = option.group.group_name})
				end
			end
		end
    end

    return options
end

local function GetOptionsFromGroup(GROUP, MOD_GROUP, location, is_master_world)
	local options = {}
	for group_name, group in pairs(GROUP) do
		if not IsGroupDisabled(group.category, group.group_name) then
			for item_name, item in pairs(group.items) do
				if not IsItemDisabled(item_name) then
					if location == nil or item.world == nil or table.contains(item.world, location) then
						if is_master_world or not item.master_controlled then
							local export = {}
							for name, exportfn in pairs(ITEM_EXPORTS) do
								export[name] = exportfn(item, location)
							end
							table.insert(options, export)
						end
					end
				end
			end
		end
	end

	for modname, modgroups in pairs(MOD_GROUP) do
		for group_name, group in pairs(modgroups) do
			for item_name, item in pairs(group.items) do
				if location == nil or item.world == nil or table.contains(item.world, location) then
					if is_master_world or not item.master_controlled then
						local export = {}
						for name, exportfn in pairs(ITEM_EXPORTS) do
							export[name] = exportfn(item, location)
						end
						table.insert(options, export)
					end
				end
			end
		end
	end


	table.sort(options, function(a, b)
		local item_a = GetOption(a.name)
		local item_b = GetOption(b.name)


		if item_a.group.order ~= item_b.group.order then
			return item_a.group.order < item_b.group.order
		elseif item_a.group.text ~= item_b.group.text then
			return item_a.group.text < item_b.group.text
		end

		local item_a_order = item_a.order
		local item_b_order = item_b.order

		if item_a_order == item_b_order then
			return (STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(item_a.name)] or "") < (STRINGS.UI.CUSTOMIZATIONSCREEN[string.upper(item_b.name)]  or "")
		elseif item_a_order == nil or item_b_order == nil then
			return item_a_order ~= nil
		end
		return item_a_order < item_b_order
	end)

	return options

end

local function GetWorldGenOptions(location, is_master_world)
	return GetOptionsFromGroup(WORLDGEN_GROUP, MOD_WORLDGEN_GROUP, location, is_master_world)
end

local function GetWorldSettingsOptions(location, is_master_world)
	return GetOptionsFromGroup(WORLDSETTINGS_GROUP, MOD_WORLDSETTINGS_GROUP, location, is_master_world)
end

local function GetOptionsWithLocationDefaults(location, is_master_world)
    local options = GetOptions(location, is_master_world)

    local locationdata = Levels.GetDataForLocation(location)
    if locationdata ~= nil then -- custom locations won't show on the client
        for i,option in ipairs(options) do
            if locationdata.overrides[option.name] ~= nil then
                option.default = locationdata.overrides[option.name]
            end
        end
    end

    return options
end

local function GetWorldGenOptionsWithLocationDefaults(location, is_master_world)
    local options = GetWorldGenOptions(location, is_master_world)

    local locationdata = Levels.GetDataForLocation(location)
    if locationdata ~= nil then -- custom locations won't show on the client
        for i,option in ipairs(options) do
            if locationdata.overrides[option.name] ~= nil then
                option.default = locationdata.overrides[option.name]
            end
        end
    end

    return options
end

local function GetWorldSettingsOptionsWithLocationDefaults(location, is_master_world)
    local options = GetWorldSettingsOptions(location, is_master_world)

    local locationdata = Levels.GetDataForLocation(location)
    if locationdata ~= nil then -- custom locations won't show on the client
        for i,option in ipairs(options) do
            if locationdata.overrides[option.name] ~= nil then
                option.default = locationdata.overrides[option.name]
            end
        end
    end

    return options
end

local function GetDefaultForOption(option_name)
	local option = GetOption(option_name)
	if option then
		return option.value
	end
end

local function GetLocationDefaultForOption(location, option)
    local locationdata = Levels.GetDataForLocation(location)
    return locationdata ~= nil and locationdata.overrides[option] or GetDefaultForOption(option)
end

local function ValidateOption(option_name, option_value, location)
	local option = GetOption(option_name)

	if option == nil then
        --gjans: not printing this warning for now because there are some tweaks (e.g. wormholeprefab) which don't process via Customize.
        --print(string.format("Customisation validation WARNING: Invalid override tweak %s:%s", tostring(group), tostring(tweak)))
		return false
	end

	local desc = option.desc or option.group.desc
	if desc then
		desc = FunctionOrValue(desc, location)
        for _, d in ipairs(desc) do
            if d.data == option_value then
                return true
            end
        end
	end

    --print(string.format("Customisation validation WARNING: Invalid value '%s' for %s:%s", tostring(value), tostring(group), tostring(tweak)))
    return false
end

local function GetCategoryForOption(option_name)
	local option = GetOption(option_name)
	if option then
		return option.category
	end

	local option_misc = GetMiscOption(option_name)
	if option_misc then
		return option_misc.category
	end
end

local function IsCustomizeOption(option_name)
	return GetOption(option_name) ~= nil
end

local function GetGroupFromName(category, group)
	local GROUP
	local MOD_GROUP
	if category == LEVELCATEGORY.SETTINGS then
		GROUP = WORLDSETTINGS_GROUP
		MOD_GROUP = MOD_WORLDSETTINGS_GROUP
	elseif category == LEVELCATEGORY.WORLDGEN then
		GROUP = WORLDGEN_GROUP
		MOD_GROUP = MOD_WORLDGEN_GROUP
	end

	if GROUP and GROUP[group] then
		return GROUP[group], GROUP
	end

	if MOD_GROUP then
		for mod, mod_group in pairs(MOD_GROUP) do
			if mod_group[group] then
				return mod_group[group], MOD_GROUP
			end
		end
	end
end

local function GetItemFromName(name)
	local option = GetOption(name)
	if option then
		return option
	end

	local option_misc = GetMiscOption(name)
	if option_misc then
		return option_misc
	end
end

local function RefreshWorldTabs()
	if not rawget(_G, "TheFrontEnd") then return end
	--HACK probably need a better way to update the world tabs when the customize data changes
	local servercreationscreen
    for _, screen_in_stack in pairs(TheFrontEnd.screenstack) do
        if screen_in_stack.name == "ServerCreationScreen" then
			servercreationscreen = screen_in_stack
			break
        end
	end
    if servercreationscreen then
		for k, v in pairs(servercreationscreen.world_tabs) do
			v:RefreshOptionItems()
        end
    end
end

local function AddCustomizeGroup(modname, category, name, text, desc, atlas, order)
	if GetGroupFromName(category, name) ~= nil then return end

	local MOD_GROUP
	if category == LEVELCATEGORY.SETTINGS then
		MOD_GROUP = MOD_WORLDSETTINGS_GROUP
	elseif category == LEVELCATEGORY.WORLDGEN then
		MOD_GROUP = MOD_WORLDGEN_GROUP
	end
	if MOD_GROUP then
		if MOD_GROUP[modname] == nil then
			MOD_GROUP[modname] = {}
		end
		MOD_GROUP[modname][name] = {
			order = order or GetTableSize(MOD_GROUP[modname]) + 1,
			atlas = atlas,
			master_group = MOD_GROUP,
			group_name = name,
			modname = modname,
			category = category,
			text = text,
			desc = desc,
			items = {},
		}
	end
end

local function RemoveCustomizeGroup(modname, category, name)
	local GROUP
	local MOD_GROUP
	if category == LEVELCATEGORY.SETTINGS then
		GROUP = WORLDSETTINGS_GROUP
		MOD_GROUP = MOD_WORLDSETTINGS_GROUP
	elseif category == LEVELCATEGORY.WORLDGEN then
		GROUP = WORLDGEN_GROUP
		MOD_GROUP = MOD_WORLDGEN_GROUP
	end
	if MOD_GROUP and MOD_GROUP[modname] and MOD_GROUP[modname][name] then
		MOD_GROUP[modname][name] = nil
		if MOD_OPTIONS[modname] then
			for item_name, item in pairs(MOD_OPTIONS[modname]) do
				if item.group.group_name == name then
					MOD_OPTIONS[modname][item_name] = nil
				end
			end
		end
	elseif GROUP and GROUP[name] then
		if MOD_DISABLE_GROUP[category] == nil then
			MOD_DISABLE_GROUP[category] = {}
		end
		if MOD_DISABLE_GROUP[category][name] == nil then
			MOD_DISABLE_GROUP[category][name] = {}
		end
		MOD_DISABLE_GROUP[category][name][modname] = true
	end
	RefreshWorldTabs()
end

local function AddCustomizeItem(modname, category, group, name, itemsettings)
	if GetItemFromName(name) ~= nil then return end

	if group then
		local GROUP, MASTER_GROUP = GetGroupFromName(category, group)
		if GROUP and not GROUP.items[name] then
			local settings = shallowcopy(itemsettings)
			settings.category = category
			settings.name = name
			settings.group = GROUP
			settings.master_group = MASTER_GROUP
			settings.modname = modname
			GROUP.items[name] = settings

			if MOD_OPTIONS[modname] == nil then
				MOD_OPTIONS[modname] = {}
			end
			MOD_OPTIONS[modname][name] = settings
			RefreshWorldTabs()
		end
	else
		local MOD_GROUP_MISC = (category == LEVELCATEGORY.SETTINGS and MOD_WORLDSETTINGS_MISC) or (category == LEVELCATEGORY.WORLDGEN and MOD_WORLDGEN_MISC)
		if MOD_GROUP_MISC[modname] == nil then
			MOD_GROUP_MISC[modname] = {}
		end
		MOD_GROUP_MISC[modname][name] = true

		if MOD_OPTIONS_MISC[modname] == nil then
			MOD_OPTIONS_MISC[modname] = {}
		end
		MOD_OPTIONS_MISC[modname][name] = {category = category}
	end
end

local function RemoveCustomizeItem(modname, category, name)
	local item = GetItemFromName(name)
	if item == nil or item.category ~= category then return end

	if item.modname == modname then
		if item.group then
			item.group.items[name] = nil
			MOD_OPTIONS[modname][name] = nil
			RefreshWorldTabs()
		else
			local MOD_GROUP_MISC = (category == LEVELCATEGORY.SETTINGS and MOD_WORLDSETTINGS_MISC) or (category == LEVELCATEGORY.WORLDGEN and MOD_WORLDGEN_MISC)
			if MOD_GROUP_MISC and MOD_GROUP_MISC[modname] then
				MOD_GROUP_MISC[modname][name] = nil
				MOD_OPTIONS_MISC[modname][name] = nil
			end
		end
	elseif item.modname == nil then
		if MOD_DISABLE_ITEM[name] == nil then
			MOD_DISABLE_ITEM[name] = {}
		end
		MOD_DISABLE_ITEM[name][modname] = true

		if item.group then
			RefreshWorldTabs()
		end
	end
end

local function GetDescription(description)
	if descriptions[description] then
		return deepcopy(descriptions[description])
	end
end

local function ClearModData(modname)
	if modname == nil then
		MOD_WORLDSETTINGS_MISC = {}
		MOD_WORLDGEN_MISC = {}
		MOD_OPTIONS_MISC = {}

		for _modname, options in pairs(MOD_OPTIONS) do
			for name, option in pairs(options) do
				local item = GetItemFromName(name)
				if item and item.group then
					item.group.items[name] = nil
					MOD_OPTIONS[_modname][name] = nil
				end
			end
			assert(IsTableEmpty(MOD_OPTIONS[_modname]))
			MOD_OPTIONS[_modname] = nil
		end

		MOD_WORLDSETTINGS_GROUP = {}
		MOD_WORLDGEN_GROUP = {}
		assert(IsTableEmpty(MOD_OPTIONS))
		MOD_OPTIONS = {}
	else
		MOD_WORLDSETTINGS_MISC[modname] = nil
		MOD_WORLDGEN_MISC[modname] = nil
		MOD_OPTIONS_MISC[modname] = nil

		--clear out all items inside any groups this mod has
		--this can include items from other mods if they added them to this mods groups
		if MOD_WORLDSETTINGS_GROUP[modname] then
			for name, group in pairs(MOD_WORLDSETTINGS_GROUP[modname]) do
				for itemname, item in pairs(group.items) do
					group.items[itemname] = nil
					MOD_OPTIONS[item.modname][itemname] = nil
				end
				assert(IsTableEmpty(group.items))
			end
			MOD_WORLDSETTINGS_GROUP[modname] = nil
		end

		if MOD_WORLDGEN_GROUP[modname] then
			for name, group in pairs(MOD_WORLDGEN_GROUP[modname]) do
				for itemname, item in pairs(group.items) do
					group.items[itemname] = nil
					MOD_OPTIONS[item.modname][itemname] = nil
				end
				assert(IsTableEmpty(group.items))
			end
			MOD_WORLDGEN_GROUP[modname] = nil
		end

		--clear out any items from this mod that are in other groups, modded or otherwise.
		if MOD_OPTIONS[modname] then
			for name, option in pairs(MOD_OPTIONS[modname]) do
				local item = GetItemFromName(name)
				if item and item.group then
					item.group.items[name] = nil
					MOD_OPTIONS[modname][name] = nil
				end
			end
			assert(IsTableEmpty(MOD_OPTIONS[modname]))
			MOD_OPTIONS[modname] = nil
		end
	end
	RefreshWorldTabs()
end

return {
	--BACKEND ONLY
	GetOptions                     				= GetOptions,
	GetOptionsWithLocationDefaults 				= GetOptionsWithLocationDefaults,

	GetWorldSettingsOptions		   				= GetWorldSettingsOptions,
	GetWorldSettingsOptionsWithLocationDefaults = GetWorldSettingsOptionsWithLocationDefaults,

	GetWorldGenOptions			   				= GetWorldGenOptions,
	GetWorldGenOptionsWithLocationDefaults 		= GetWorldGenOptionsWithLocationDefaults,

	GetWorldSettingsFromLevelSettings			= GetWorldSettingsFromLevelSettings,

	GetMasterOptions							= GetMasterOptions,

    GetLocationDefaultForOption    				= GetLocationDefaultForOption,
	ValidateOption                 				= ValidateOption,

	--modding interface
	AddCustomizeGroup							= AddCustomizeGroup,
	RemoveCustomizeGroup						= RemoveCustomizeGroup,
	AddCustomizeItem							= AddCustomizeItem,
	RemoveCustomizeItem							= RemoveCustomizeItem,

	GetDescription								= GetDescription,
	ITEM_EXPORTS				   				= ITEM_EXPORTS,

	ClearModData								= ClearModData,
	GetDefaultForOption            				= GetDefaultForOption,
	GetCategoryForOption						= GetCategoryForOption,
	IsCustomizeOption							= IsCustomizeOption,
	GetGroupForOption              				= GetGroupForOption, --depreciated
}
