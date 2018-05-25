local tasksets = require("map/tasksets")
local tasks = require ("map/tasks")
local startlocations = require ("map/startlocations")
local Levels = require("map/levels")

local frequency_descriptions
if IsNotConsole() then
	frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
else
	frequency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
end

--local location_descriptions = {
    --{ text = STRINGS.UI.SANDBOXMENU.LOCATIONFOREST, data = "forest" },
    --{ text = STRINGS.UI.SANDBOXMENU.LOCATIONCAVE, data = "cave" },
--}

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
	{ text = STRINGS.UI.SANDBOXMENU.DEFAULT, data = "default"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER, data = "winter"},-- 	image = "season_start_winter.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SPRING, data = "spring"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.SUMMER, data = "summer"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.AUTUMN_SPRING, data = "autumnorspring"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WINTER_SUMMER, data = "winterorsummer"},-- 	image = "season_start_summer.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},-- 	image = "season_start_summer.tex" },
}

local size_descriptions = nil
if IsPS4() then
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.PS4_SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.PS4_SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
--		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
	}
else
	size_descriptions = {
		-- { text = STRINGS.UI.SANDBOXMENU.SLIDETINY, data = "teeny"},-- 		image = "world_size_tiny.tex"}, 	--1x1
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "small"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "default"},-- 	image = "world_size_large.tex"},	--550x550
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
		-- { text = STRINGS.UI.SANDBOXMENU.SLIDESHUMONGOUS, data = "humongous"},-- 		image = "world_size_huge.tex"},	--800x800
	}
end

local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
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
	{ text = STRINGS.UI.SANDBOXMENU.EVENT_DEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.EVENT_HALLOWEDNIGHTS_2016, data = SPECIAL_EVENTS.HALLOWED_NIGHTS },
	{ text = STRINGS.UI.SANDBOXMENU.EVENT_WINTERSFEAST_2016, data = SPECIAL_EVENTS.WINTERS_FEAST },
	{ text = STRINGS.UI.SANDBOXMENU.EVENT_YEAR_OF_THE_GOBBLER_2017, data = SPECIAL_EVENTS.YOTG },
    { text = STRINGS.UI.SANDBOXMENU.EVENT_YEAR_OF_THE_VARG_2018, data = SPECIAL_EVENTS.YOTV },
}

-- TODO: Read this from the tasks.lua
local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.YES, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.NO, data = "never" },
}

local GROUP = {
	["monsters"] = 	{	-- These guys come after you	
						order = 5,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMONSTERS, 
						desc = frequency_descriptions,
						enable = false,
						items={
							["spiders"] = {value = "default", enable = false, image = "spiders.tex", order = 1, world={"forest"}}, 
							["cave_spiders"] = {value = "default", enable = false, image = "spiders.tex", order = 1, world={"cave"}}, 
							["hounds"] = {value = "default", enable = false, image = "hounds.tex", order = 2, world={"forest"}}, 
							["houndmound"] = {value = "default", enable = false, image = "houndmound.tex", order = 3, world={"forest"}},
							["merm"] = {value = "default", enable = false, image = "merms.tex", order = 4, world={"forest"}}, 
							["tentacles"] = {value = "default", enable = false, image = "tentacles.tex", order = 5, world={"forest", "cave"}}, 
							["chess"] = {value = "default", enable = false, image = "chess_monsters.tex", order = 6, world={"forest", "cave"}}, 
							["lureplants"] = {value = "default", enable = false, image = "lureplant.tex", order = 7, world={"forest"}},
							["walrus"] = {value = "default", enable = false, image = "mactusk.tex", order = 8, world={"forest"}},  
							["liefs"] = {value = "default", enable = false, image = "liefs.tex", order = 9, world={"forest", "cave"}}, 
							["deciduousmonster"] = {value = "default", enable = false, image = "deciduouspoison.tex", order = 10, world={"forest"}},
							["krampus"] = {value = "default", enable = false, image = "krampus.tex", order = 11, world={"forest"}},
							["bearger"] = {value = "default", enable = false, image = "bearger.tex", order = 12, world={"forest"}},
							["deerclops"] = {value = "default", enable = false, image = "deerclops.tex", order = 13, world={"forest"}},
							["goosemoose"] = {value = "default", enable = false, image = "goosemoose.tex", order = 14, world={"forest"}},
							["dragonfly"] = {value = "default", enable = false, image = "dragonfly.tex", order = 15, world={"forest"}},
							["antliontribute"] = {value = "default", enable = false, image = "antlion_tribute.tex", order = 16, world={"forest"}},
							["bats"] = {value = "default", enable = false, image = "bats.tex", order = 16, world={"cave"}},
							["fissure"] = {value = "default", enable = false, image = "fissure.tex", order = 17, world={"cave"}},
							["wormattacks"] = {value = "default", enable = false, image = "wormattacks.tex", order = 18, world={"cave"}}, 
							["worms"] = {value = "default", enable = false, image = "worms.tex", order = 19, world={"cave"}},
						}
					},
	["animals"] =  	{	-- These guys live and let live
						order= 4,
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = frequency_descriptions,
						enable = false,
						items={
							-- ["mandrake"] = {value = "default", enable = false, image = "mandrake.tex", order = 1, world={"forest", "cave"}},
							["rabbits"] = {value = "default", enable = false, image = "rabbits.tex", order = 2, world={"forest"}},
							["moles"] = {value = "default", enable = false, image = "mole.tex", order = 3, world={"forest"}},
							["butterfly"] = {value = "default", enable = false, image = "butterfly.tex", order = 4, world={"forest"}},  
							["birds"] = {value = "default", enable = false, image = "birds.tex", order = 5, world={"forest"}},
							["buzzard"] = {value = "default", enable = false, image = "buzzard.tex", order = 6, world={"forest"}}, 
							["catcoon"] = {value = "default", enable = false, image = "catcoon.tex", order = 7, world={"forest"}}, 
							["perd"] = {value = "default", enable = false, image = "perd.tex", order = 8, world={"forest"}}, 
							["pigs"] = {value = "default", enable = false, image = "pigs.tex", order = 9, world={"forest"}}, 
							["lightninggoat"] = {value = "default", enable = false, image = "lightning_goat.tex", order = 10, world={"forest"}}, 
							["beefalo"] = {value = "default", enable = false, image = "beefalo.tex", order = 11, world={"forest"}}, 
							["beefaloheat"] = {value = "default", enable = false, image = "beefaloheat.tex", order = 12, world={"forest"}},
							["hunt"] = {value = "default", enable = false, image = "tracks.tex", order = 13, world={"forest"}},  
							["alternatehunt"] = {value = "default", enable = false, image = "alternatehunt.tex", order = 14, world={"forest"}},  
							["penguins"] = {value = "default", enable = false, image = "pengull.tex", order = 15, world={"forest"}},
							["ponds"] = {value = "default", enable = false, image = "ponds.tex", order = 16, world={"forest"}}, 
							["cave_ponds"] = {value = "default", enable = false, image = "ponds.tex", order = 16, world={"cave"}}, 
							["bees"] = {value = "default", enable = false, image = "beehive.tex", order = 17, world={"forest"}}, 
							["angrybees"] = {value = "default", enable = false, image = "wasphive.tex", order = 18, world={"forest"}}, 
							["tallbirds"] = {value = "default", enable = false, image = "tallbirds.tex", order = 19, world={"forest"}},  
							["slurper"] = {value = "default", enable = false, image = "slurper.tex", order = 20, world={"cave"}},
							["bunnymen"] = {value = "default", enable = false, image = "bunnymen.tex", order = 21, world={"cave"}},
							["slurtles"] = {value = "default", enable = false, image = "slurtles.tex", order = 22, world={"cave"}},
							["rocky"] = {value = "default", enable = false, image = "rocky.tex", order = 23, world={"cave"}},
							["monkey"] = {value = "default", enable = false, image = "monkey.tex", order = 24, world={"cave"}},
						}
					},
	["resources"] = {
						order= 2,
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = frequency_descriptions,
						enable = false,
						items={
							["flowers"] = {value = "default", enable = false, image = "flowers.tex", order = 1, world={"forest"}},
							["grass"] = {value = "default", enable = false, image = "grass.tex", order = 2, world={"forest", "cave"}}, 
							["sapling"] = {value = "default", enable = false, image = "sapling.tex", order = 3, world={"forest", "cave"}}, 
							["marshbush"] = {value = "default", enable = false, image = "marsh_bush.tex", order = 4, world={"forest", "cave"}}, 
							["tumbleweed"] = {value = "default", enable = false, image = "tumbleweeds.tex", order = 5, world={"forest"}}, 
							["reeds"] = {value = "default", enable = false, image = "reeds.tex", order = 6, world={"forest", "cave"}}, 
							["trees"] = {value = "default", enable = false, image = "trees.tex", order = 7, world={"forest", "cave"}}, 
							["flint"] = {value = "default", enable = false, image = "flint.tex", order = 8, world={"forest", "cave"}},
							["rock"] = {value = "default", enable = false, image = "rock.tex", order = 9, world={"forest", "cave"}}, 
							["rock_ice"] = {value = "default", enable = false, image = "iceboulder.tex", order = 10, world={"forest"}}, 
							["meteorspawner"] = {value = "default", enable = false, image = "burntground.tex", order = 11, world={"forest"}}, 
							["meteorshowers"] = {value = "default", enable = false, image = "meteor.tex", order = 12, world={"forest"}}, 
							["mushtree"] = {value = "default", enable = false, image = "mushtree.tex", order = 13, world={"cave"}},
							["fern"] = {value = "default", enable = false, image = "fern.tex", order = 14, world={"cave"}},
							["flower_cave"] = {value = "default", enable = false, image = "flower_cave.tex", order = 15, world={"cave"}},
							["wormlights"] = {value = "default", enable = false, image = "wormlights.tex", order = 16, world={"cave"}},
						}
					},
	["unprepared"] ={
						order= 3,
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = frequency_descriptions,
						enable = true,
						items={
							["berrybush"] = {value = "default", enable = true, image = "berrybush.tex", order = 1, world={"forest", "cave"}}, 
							["carrot"] = {value = "default", enable = true, image = "carrot.tex", order = 2, world={"forest"}}, 
							["mushroom"] = {value = "default", enable = false, image = "mushrooms.tex", order = 3, world={"forest", "cave"}}, 
							["cactus"] = {value = "default", enable = false, image = "cactus.tex", order = 4, world={"forest"}}, 
							["banana"] = {value = "default", enable = false, image = "banana.tex", order = 5, world={"cave"}},
							["lichen"] = {value = "default", enable = false, image = "lichen.tex", order = 6, world={"cave"}},
						}
					},
	["misc"] =		{
						order= 1,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
                            --["location"] = {value = "forest", enable = false, image = "world_map.tex", desc = location_descriptions, order = 0, world={"forest", "cave"}}, 
                            ["task_set"] = {value = "default", enable = false, image = "world_map.tex", desc = tasksets.GetGenTaskLists, order = 1, world={"forest", "cave"}}, 
                            ["start_location"] = {value = "default", enable = false, image = "world_start.tex", desc = startlocations.GetGenStartLocations, order = 2, world={"forest", "cave"}}, 
							["world_size"] = {value = "default", enable = false, image = "world_size.tex", desc = size_descriptions, order = 3, world={"forest", "cave"}}, 
							["branching"] = {value = "default", enable = false, image = "world_branching.tex", desc = branching_descriptions, order = 4, world={"forest", "cave"}}, 
							["loop"] = {value = "default", enable = false, image = "world_loop.tex", desc = loop_descriptions, order = 5, world={"forest", "cave"}}, 
                            ["specialevent"] = {value = "default", enable = false, image = "events.tex", desc = specialevent_descriptions, order = 5.5, world={"forest"}},
							["autumn"] = {value = "default", enable = true, image = "autumn.tex", desc = season_length_descriptions, master_controlled = true, order = 6, world={"forest", "cave"}},
							["winter"] = {value = "default", enable = true, image = "winter.tex", desc = season_length_descriptions, master_controlled = true, order = 7, world={"forest", "cave"}},
							["spring"] = {value = "default", enable = true, image = "spring.tex", desc = season_length_descriptions, master_controlled = true, order = 8, world={"forest", "cave"}},
							["summer"] = {value = "default", enable = true, image = "summer.tex", desc = season_length_descriptions, master_controlled = true, order = 9, world={"forest", "cave"}},
							["season_start"] = {value = "default", enable = false, image = "season_start.tex", desc = season_start_descriptions, master_controlled = true, order = 10, world={"forest", "cave"}}, 
							["day"] = {value = "default", enable = false, image = "day.tex", desc = day_descriptions, master_controlled = true, order = 11, world={"forest", "cave"}}, 
							["weather"] = {value = "default", enable = false, image = "rain.tex", desc = frequency_descriptions, order = 13, world={"forest", "cave"}}, 
							["lightning"] = {value = "default", enable = false, image = "lightning.tex", desc = frequency_descriptions, order = 14, world={"forest"}}, 
							["earthquakes"] = {value = "default", enable = false, image = "earthquakes.tex", desc = frequency_descriptions, order = 14, world={"cave"}}, 
							["frograin"] = {value = "default", enable = false, image = "frog_rain.tex", desc = frequency_descriptions, order = 15, world={"forest"}}, 
							["wildfires"] = {value = "default", enable = false, image = "smoke.tex", desc = frequency_descriptions, order = 16, world={"forest"}}, 
							["touchstone"] = {value = "default", enable = false, image = "resurrection.tex", desc = frequency_descriptions, order = 17, world={"forest", "cave"}}, 
							["boons"] = {value = "default", enable = false, image = "skeletons.tex", desc = frequency_descriptions, order = 18, world={"forest", "cave"}}, 
							["regrowth"] = {value = "default", enable = false, image = "regrowth.tex", desc = speed_descriptions, order = 17, world={"forest", "cave"}}, 						
							["cavelight"] = {value = "default", enable = false, image = "cavelight.tex", desc = speed_descriptions, order = 18, world={"cave"}},							
                            ["disease_delay"] = {value = "default", enable = false, image = "berrybush_diseased.tex", desc = disease_descriptions, order = 19, world={"forest", "cave"}},
							["prefabswaps_start"] = {value = "default", enable = false, image = "starting_variety.tex", desc = starting_swaps_descriptions, order = 20, world={"forest", "cave"}},	
                            ["petrification"] = {value = "default", enable = false, image = "petrified_tree.tex", desc = petrification_descriptions, order = 21, world={"forest", "cave"}}, 												
						}
					},
}

local function GetGroupForOption(target)
	for group,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == target then
				return group
			end
		end
	end
	return nil
end

local function GetOptions(location, is_master_world)
    local options = {}

    local groups = {}
    for k,v in pairs(GROUP) do
        table.insert(groups,k)
    end

    table.sort(groups, function(a,b) return GROUP[a].order < GROUP[b].order end)

    for i,groupname in ipairs(groups) do
        local items = {}
        local group = GROUP[groupname]
        for k,v in pairs(group.items) do
            if location == nil or v.world == nil or table.contains(v.world, location) then
				if is_master_world or not v.master_controlled then
	                table.insert(items, k)
	            end
            end
        end

        table.sort(items, function(a,b) return group.items[a].order < group.items[b].order end)

        for ii,itemname in ipairs(items) do
            local item = group.items[itemname]
            local values = item.desc and (type(item.desc)=="function" and item.desc(location) or item.desc) or group.desc
            table.insert(options, {name = itemname, image = item.image, options = values, default = item.value, group = groupname, grouplabel = group.text})
        end
    end

    return options
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

local function GetDefaultForOption(option)
	for group,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == option then
				return item.value -- pretty sure this is always "default"...
			end
		end
	end
end

local function GetLocationDefaultForOption(location, option)
    local locationdata = Levels.GetDataForLocation(location)
    return locationdata ~= nil and locationdata.overrides[option] or GetDefaultForOption(option)
end

local function ValidateOption(tweak, value, location)
    local group = GetGroupForOption(tweak)
    if group == nil or GROUP[group].items[tweak] == nil then
        --gjans: not printing this warning for now because there are some tweaks (e.g. wormholeprefab) which don't process via customise.
        --print(string.format("Customisation validation WARNING: Invalid override tweak %s:%s", tostring(group), tostring(tweak)))
        return false
    end

    if GROUP[group].items[tweak].desc ~= nil then
        local desc = type(GROUP[group].items[tweak].desc) == "function" and GROUP[group].items[tweak].desc(location) or GROUP[group].items[tweak].desc
        for i,d in ipairs(desc) do
            if d.data == value then
                return true
            end
        end
    end

    if GROUP[group].desc ~= nil then
        local desc = type(GROUP[group].desc) == "function" and GROUP[group].desc(location) or GROUP[group].desc
        for i,d in ipairs(desc) do
            if d.data == value then
                return true
            end
        end
    end

    --print(string.format("Customisation validation WARNING: Invalid value '%s' for %s:%s", tostring(value), tostring(group), tostring(tweak)))
    return false
end

return {
    GetOptions                     = GetOptions,
    GetOptionsWithLocationDefaults = GetOptionsWithLocationDefaults,
    GetGroupForOption              = GetGroupForOption,
    GetDefaultForOption            = GetDefaultForOption,
    GetLocationDefaultForOption    = GetLocationDefaultForOption,
    ValidateOption                 = ValidateOption,
}
