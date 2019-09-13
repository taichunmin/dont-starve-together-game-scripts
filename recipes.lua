require("recipe")

--Note: If you want to add a new tech tree you must also add it into the "TECH" constant in constants.lua

mod_protect_Recipe = false


--LIGHT
Recipe("campfire", {Ingredient("cutgrass", 3),Ingredient("log", 2)}, RECIPETABS.LIGHT, TECH.NONE, "campfire_placer")
Recipe("firepit", {Ingredient("log", 2),Ingredient("rocks", 12)}, RECIPETABS.LIGHT, TECH.NONE, "firepit_placer")
Recipe("lighter", {Ingredient("rope", 1), Ingredient("goldnugget", 1), Ingredient("petals", 3)}, RECIPETABS.LIGHT, TECH.NONE, nil, nil, nil, nil, "pyromaniac")
Recipe("torch", {Ingredient("cutgrass", 2),Ingredient("twigs", 2)}, RECIPETABS.LIGHT, TECH.NONE)
Recipe("coldfire", {Ingredient("cutgrass", 3), Ingredient("nitre", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_ONE, "coldfire_placer")
Recipe("coldfirepit", {Ingredient("nitre", 2), Ingredient("cutstone", 4), Ingredient("transistor", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, "coldfirepit_placer")

Recipe("minerhat", {Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)
Recipe("molehat", {Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO)
Recipe("pumpkin_lantern", {Ingredient("pumpkin", 1), Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)
Recipe("lantern", {Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)

Recipe("mushroom_light", {Ingredient("shroom_skin", 1), Ingredient("fertilizer", 1, nil, true)}, RECIPETABS.LIGHT, TECH.LOST, "mushroom_light_placer", 1.5)
Recipe("mushroom_light2", {Ingredient("shroom_skin", 1), Ingredient("fertilizer", 1, nil, true), Ingredient("boards", 1)}, RECIPETABS.LIGHT, TECH.LOST, "mushroom_light2_placer", 1.5)

--STRUCTURES
Recipe("spidereggsack", {Ingredient("silk", 12), Ingredient("spidergland", 6), Ingredient("papyrus", 6)}, RECIPETABS.TOWN, TECH.NONE, nil, nil, nil, nil, "spiderwhisperer")
Recipe("treasurechest", {Ingredient("boards", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "treasurechest_placer",1)
Recipe("homesign", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "homesign_placer")
Recipe("arrowsign_post", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "arrowsign_post_placer")
Recipe("minisign_item", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil, nil, nil, 4)
Recipe("minisign", {Ingredient("boards", 1)}, nil, TECH.LOST) --so it can be deconstructed
Recipe("fence_gate_item", {Ingredient("boards", 2), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,1)
Recipe("fence_item", {Ingredient("twigs", 3), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE,nil,nil,nil,6)
Recipe("wall_hay_item", {Ingredient("cutgrass", 4), Ingredient("twigs", 2) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE,nil,nil,nil,4)
Recipe("wall_wood_item", {Ingredient("boards", 2),Ingredient("rope", 1)}, RECIPETABS.TOWN,  TECH.SCIENCE_ONE,nil,nil,nil,8)
Recipe("wall_stone_item", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,6)
Recipe("wall_moonrock_item", {Ingredient("moonrocknugget", 12)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,4)

Recipe("wardrobe", {Ingredient("boards", 4), Ingredient("cutgrass", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "wardrobe_placer")

Recipe("pighouse", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "pighouse_placer")
Recipe("rabbithouse", {Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "rabbithouse_placer")
Recipe("birdcage", {Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "birdcage_placer")
Recipe("scarecrow", {Ingredient("pumpkin", 1), Ingredient("boards", 3), Ingredient("cutgrass", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, "scarecrow_placer", 1.5)

Recipe("turf_road", {Ingredient("turf_rocky", 1), Ingredient("boards", 1)}, RECIPETABS.TOWN,  TECH.SCIENCE_TWO)
Recipe("turf_woodfloor", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)
Recipe("turf_checkerfloor", {Ingredient("marble", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)
Recipe("turf_carpetfloor", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)
Recipe("turf_dragonfly", {Ingredient("dragon_scales", 1), Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, nil, nil, nil, 6)

Recipe("winter_treestand", {Ingredient("poop", 2), Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.WINTERS_FEAST, "winter_treestand_placer")
Recipe("perdshrine", {Ingredient("goldnugget", 8), Ingredient("boards", 2)}, RECIPETABS.TOWN, TECH.YOTG, "perdshrine_placer")
Recipe("wargshrine", {Ingredient("goldnugget", 8), Ingredient("boards", 2)}, RECIPETABS.TOWN, TECH.YOTV, "wargshrine_placer")
Recipe("pigshrine", {Ingredient("goldnugget", 8), Ingredient("boards", 2)}, RECIPETABS.TOWN, TECH.YOTP, "pigshrine_placer")
Recipe("pottedfern", {Ingredient("foliage", 5), Ingredient("slurtle_shellpieces", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "pottedfern_placer", 0.9)
Recipe("succulent_potted", {Ingredient("succulent_picked", 5), Ingredient("cutstone", 1)}, RECIPETABS.TOWN, TECH.LOST, "succulent_potted_placer", 0.9)
Recipe("endtable", {Ingredient("marble", 2), Ingredient("boards", 2), Ingredient("turf_carpetfloor", 2)}, RECIPETABS.TOWN, TECH.LOST, "endtable_placer", 1.5)

Recipe("ruinsrelic_plate", {Ingredient("cutstone", 1)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_plate_placer", 0.5)
Recipe("ruinsrelic_chipbowl", {Ingredient("cutstone", 1)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_chipbowl_placer", 0.5)
Recipe("ruinsrelic_bowl", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_bowl_placer", 2)
Recipe("ruinsrelic_vase", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_vase_placer", 2)
Recipe("ruinsrelic_chair", {Ingredient("cutstone", 3)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_chair_placer", 2)
Recipe("ruinsrelic_table", {Ingredient("cutstone", 4)}, RECIPETABS.TOWN, TECH.LOST, "ruinsrelic_table_placer")

Recipe("dragonflychest", {Ingredient("dragon_scales", 1), Ingredient("boards", 4), Ingredient("goldnugget", 10)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "dragonflychest_placer", 1.5)
Recipe("dragonflyfurnace", {Ingredient("dragon_scales", 1), Ingredient("redgem", 2), Ingredient("charcoal", 10)}, RECIPETABS.TOWN, TECH.LOST, "dragonflyfurnace_placer")

--FARM
Recipe("slow_farmplot", {Ingredient("cutgrass", 8),Ingredient("poop", 4),Ingredient("log", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, "slow_farmplot_placer")
Recipe("fast_farmplot", {Ingredient("cutgrass", 10),Ingredient("poop", 6),Ingredient("rocks", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, "fast_farmplot_placer")
Recipe("fertilizer", {Ingredient("poop",3), Ingredient("boneshard", 2), Ingredient("log", 4)}, RECIPETABS.FARM, TECH.SCIENCE_TWO)
Recipe("mushroom_farm", {Ingredient("spoiled_food", 8),Ingredient("poop", 5),Ingredient("livinglog", 2)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "mushroom_farm_placer", 2.5)
Recipe("beebox", {Ingredient("boards", 2),Ingredient("honeycomb", 1),Ingredient("bee", 4)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "beebox_placer")
Recipe("meatrack", {Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, "meatrack_placer")
Recipe("cookpot", {Ingredient("cutstone", 3), Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, "cookpot_placer")
--NOTE: add portable cookware to UNCRAFTABLE section as well!
Recipe("portablecookpot_item", {Ingredient("goldnugget", 2), Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM, TECH.NONE, nil, nil, nil, nil, "masterchef")
Recipe("portableblender_item", {Ingredient("goldnugget", 2), Ingredient("transistor", 2), Ingredient("twigs", 4)}, RECIPETABS.FARM, TECH.NONE, nil, nil, nil, nil, "masterchef")
Recipe("portablespicer_item",  {Ingredient("goldnugget", 2), Ingredient("cutstone", 3), Ingredient("twigs", 6)}, RECIPETABS.FARM, TECH.NONE, nil, nil, nil, nil, "masterchef")
--
Recipe("icebox", {Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("cutstone", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, "icebox_placer", 1.5)

--SURVIVAL
Recipe("reviver", {Ingredient("cutgrass", 3), Ingredient("spidergland", 1), Ingredient(CHARACTER_INGREDIENT.HEALTH, 40)}, RECIPETABS.SURVIVAL,  TECH.NONE)
Recipe("healingsalve", {Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_ONE)
Recipe("bandage", {Ingredient("papyrus", 1), Ingredient("honey", 2)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
Recipe("lifeinjector", {Ingredient("spoiled_food", 8), Ingredient("nitre", 2), Ingredient("stinger",1)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
Recipe("bernie_inactive", {Ingredient("beardhair", 2), Ingredient("beefalowool", 2), Ingredient("silk", 2)}, RECIPETABS.SURVIVAL,  TECH.NONE, nil, nil, nil, nil, "pyromaniac")
Recipe("trap", {Ingredient("twigs", 2),Ingredient("cutgrass", 6)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("birdtrap", {Ingredient("twigs", 3),Ingredient("silk", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("bugnet", {Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("fishingrod", {Ingredient("twigs", 2),Ingredient("silk", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("miniflare", {Ingredient("twigs", 1), Ingredient("cutgrass", 1), Ingredient("nitre", 1)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("grass_umbrella", {Ingredient("twigs", 4) ,Ingredient("cutgrass", 3), Ingredient("petals", 6)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("umbrella", {Ingredient("twigs", 6) ,Ingredient("pigskin", 1), Ingredient("silk",2 )}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("waterballoon", {Ingredient("mosquitosack", 2), Ingredient("ice", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, nil, nil, nil, 4)
Recipe("balloons_empty", {Ingredient("waterballoon", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, nil, nil, nil, nil, "balloonomancer")
Recipe("compass", {Ingredient("goldnugget", 1), Ingredient("flint", 1)}, RECIPETABS.SURVIVAL,  TECH.NONE)
Recipe("heatrock", {Ingredient("rocks", 10),Ingredient("pickaxe", 1), Ingredient("flint", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("giftwrap", {Ingredient("papyrus", 1), Ingredient("petals", 1)}, RECIPETABS.SURVIVAL, TECH.WINTERS_FEAST, nil, nil, nil, 4)
Recipe("bundlewrap", {Ingredient("waxpaper", 1), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.LOST)
Recipe("spicepack", {Ingredient("cutgrass", 4), Ingredient("twigs", 4), Ingredient("nitre", 2)}, RECIPETABS.SURVIVAL, TECH.NONE, nil, nil, nil, nil, "masterchef")
Recipe("backpack", {Ingredient("cutgrass", 4), Ingredient("twigs", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("candybag", {Ingredient("cutgrass", 6)}, RECIPETABS.SURVIVAL, TECH.HALLOWED_NIGHTS)
Recipe("piggyback", {Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("icepack", {Ingredient("bearger_fur", 1), Ingredient("gears", 3), Ingredient("transistor", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("bedroll_straw", {Ingredient("cutgrass", 6), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("bedroll_furry", {Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("tent", {Ingredient("silk", 6),Ingredient("twigs", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, "tent_placer")
Recipe("siestahut", {Ingredient("silk", 2),Ingredient("boards", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, "siestahut_placer")
Recipe("minifan", {Ingredient("twigs", 3), Ingredient("petals",1)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("featherfan", {Ingredient("goose_feather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)

--TOOLS
Recipe("axe", {Ingredient("twigs", 1),Ingredient("flint", 1)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("pickaxe", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenpickaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("shovel", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("goldenshovel", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("hammer", {Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("cutgrass", 6)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("pitchfork", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("razor", {Ingredient("twigs", 2), Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("featherpencil", {Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("saddlehorn", {Ingredient("twigs", 2), Ingredient("boneshard", 2), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saddle_basic", {Ingredient("beefalowool", 4), Ingredient("pigskin", 4), Ingredient("goldnugget", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saddle_war", {Ingredient("rabbit", 4), Ingredient("steelwool", 4), Ingredient("log", 10)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saddle_race", {Ingredient("livinglog", 2), Ingredient("silk", 4), Ingredient("butterflywings", 68)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("brush", {Ingredient("steelwool", 1), Ingredient("walrus_tusk", 1), Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)
Recipe("saltlick", {Ingredient("boards", 2), Ingredient("nitre", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, "saltlick_placer")


--SCIENCE
Recipe("madscience_lab", {Ingredient("cutstone", 2), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE, TECH.HALLOWED_NIGHTS, "madscience_lab_placer")
Recipe("researchlab", {Ingredient("goldnugget", 1),Ingredient("log", 4),Ingredient("rocks", 4)}, RECIPETABS.SCIENCE, TECH.NONE, "researchlab_placer")
Recipe("researchlab2", {Ingredient("boards", 4),Ingredient("cutstone", 2), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "researchlab2_placer")
Recipe("transistor", {Ingredient("goldnugget", 2), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE)
--Recipe("diviningrod", {Ingredient("twigs", 1), Ingredient("nightmarefuel", 4), Ingredient("gears", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO)
Recipe("seafaring_prototyper", {Ingredient("boards", 4)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE, "seafaring_prototyper_placer")
Recipe("cartographydesk", {Ingredient("compass", 1),Ingredient("boards", 4)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE, "cartographydesk_placer")
Recipe("sculptingtable", {Ingredient("cutstone", 2), Ingredient("boards", 2), Ingredient("twigs", 4) }, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE, "sculptingtable_placer")
Recipe("winterometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "winterometer_placer")
Recipe("rainometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "rainometer_placer")
Recipe("gunpowder", {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO)
Recipe("lightning_rod", {Ingredient("goldnugget", 4), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, "lightning_rod_placer")
Recipe("firesuppressor", {Ingredient("gears", 2),Ingredient("ice", 15),Ingredient("transistor", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO, "firesuppressor_placer")

--MAGIC
Recipe("abigail_flower", {Ingredient("petals", 6), Ingredient("nightmarefuel", 1)}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "ghostlyfriend")
Recipe("wereitem_goose", {Ingredient("monstermeat", 3), Ingredient("seeds", 3)}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "werehuman")
Recipe("wereitem_beaver", {Ingredient("monstermeat", 3), Ingredient("log", 2)}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "werehuman")
Recipe("wereitem_moose", {Ingredient("monstermeat", 3), Ingredient("cutgrass", 2)}, RECIPETABS.MAGIC, TECH.NONE, nil, nil, nil, nil, "werehuman")
Recipe("researchlab4", {Ingredient("rabbit", 4), Ingredient("boards", 4), Ingredient("tophat", 1)}, RECIPETABS.MAGIC, TECH.SCIENCE_ONE, "researchlab4_placer")
Recipe("researchlab3", {Ingredient("livinglog", 3), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 7)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, "researchlab3_placer")
Recipe("resurrectionstatue", {Ingredient("boards", 4),Ingredient("beardhair", 4), Ingredient(CHARACTER_INGREDIENT.HEALTH, TUNING.EFFIGY_HEALTH_PENALTY)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, "resurrectionstatue_placer")
Recipe("panflute", {Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("onemanband", {Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 4),Ingredient("pigskin", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO)
Recipe("nightlight", {Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, "nightlight_placer")
Recipe("armor_sanity", {Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("nightsword", {Ingredient("nightmarefuel", 5),Ingredient("livinglog", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("batbat", {Ingredient("batwing", 5), Ingredient("livinglog", 2), Ingredient("purplegem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("armorslurper", {Ingredient("slurper_pelt", 6),Ingredient("rope", 2),Ingredient("nightmarefuel", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)

Recipe("amulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("blueamulet", {Ingredient("goldnugget", 3), Ingredient("bluegem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("purpleamulet", {Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4),Ingredient("purplegem", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("firestaff", {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("icestaff", {Ingredient("spear", 1),Ingredient("bluegem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("telestaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("telebase", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, "telebase_placer", nil, nil, nil, nil, nil, nil,
    function(pt, rot)
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
    end)
Recipe("sentryward", {Ingredient("purplemooneye", 1), Ingredient("compass", 1), Ingredient("boards", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, "sentryward_placer", 1.5)
Recipe("moondial", {Ingredient("bluemooneye", 1), Ingredient("moonrocknugget", 2), Ingredient("ice", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, "moondial_placer")
Recipe("townportal", {Ingredient("orangemooneye", 1), Ingredient("townportaltalisman", 1), Ingredient("cutstone", 3)}, RECIPETABS.MAGIC, TECH.LOST, "townportal_placer")

--REFINE
Recipe("rope", {Ingredient("cutgrass", 3)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("boards", {Ingredient("log", 4)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("cutstone", {Ingredient("rocks", 3)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("papyrus", {Ingredient("cutreeds", 4)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("waxpaper", {Ingredient("papyrus", 1), Ingredient("beeswax", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("beeswax", {Ingredient("honeycomb", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("marblebean", {Ingredient("marble", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_TWO)
Recipe("bearger_fur", {Ingredient("furtuft", 90)}, RECIPETABS.REFINE, TECH.SCIENCE_TWO, nil, nil, nil, 3)
Recipe("nightmarefuel", {Ingredient("petals_evil", 4)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)
Recipe("purplegem", {Ingredient("redgem",1), Ingredient("bluegem", 1)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)
Recipe("moonrockcrater", {Ingredient("moonrocknugget", 3)}, RECIPETABS.REFINE, TECH.SCIENCE_TWO)

--WAR
Recipe("spear_wathgrithr", {Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("goldnugget", 2)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "valkyrie")
Recipe("wathgrithrhat", {Ingredient("goldnugget", 2), Ingredient("rocks", 2)}, RECIPETABS.WAR, TECH.NONE, nil, nil, nil, nil, "valkyrie")
Recipe("spear", {Ingredient("twigs", 2), Ingredient("rope", 1), Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("hambat", {Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("nightstick", {Ingredient("lightninggoathorn", 1), Ingredient("transistor", 2), Ingredient("nitre", 2)}, RECIPETABS.WAR, TECH.SCIENCE_TWO)
Recipe("whip", {Ingredient("coontail", 3), Ingredient("tentaclespots", 3)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("armorgrass", {Ingredient("cutgrass", 10), Ingredient("twigs", 2)}, RECIPETABS.WAR,  TECH.NONE)
Recipe("armorwood", {Ingredient("log", 8),Ingredient("rope", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("armormarble", {Ingredient("marble", 12),Ingredient("rope", 4)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("footballhat", {Ingredient("pigskin", 1), Ingredient("rope", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("sleepbomb", {Ingredient("shroom_skin", 1), Ingredient("canary_poisoned", 1)}, RECIPETABS.WAR, TECH.LOST, nil, nil, nil, 4)
Recipe("blowdart_sleep", {Ingredient("cutreeds", 2),Ingredient("stinger", 1),Ingredient("feather_crow", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_fire", {Ingredient("cutreeds", 2),Ingredient("charcoal", 1),Ingredient("feather_robin", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_pipe", {Ingredient("cutreeds", 2),Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_yellow", {Ingredient("cutreeds", 2),Ingredient("goldnugget", 1),Ingredient("feather_canary", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("boomerang", {Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("beemine", {Ingredient("boards", 1),Ingredient("bee", 4),Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("trap_teeth", {Ingredient("log", 1),Ingredient("rope", 1),Ingredient("houndstooth", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("armordragonfly", {Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("staff_tornado", {Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)


--DRESSUP

Recipe("sewing_kit", {Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)

Recipe("flowerhat", {Ingredient("petals", 12)}, RECIPETABS.DRESS, TECH.NONE)
Recipe("strawhat", {Ingredient("cutgrass", 12)}, RECIPETABS.DRESS,  TECH.NONE)
Recipe("tophat", {Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("rainhat", {Ingredient("mole", 2), Ingredient("strawhat", 1), Ingredient("boneshard", 1)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
Recipe("earmuffshat", {Ingredient("rabbit", 2), Ingredient("twigs",1)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE)
Recipe("beefalohat", {Ingredient("beefalowool", 8),Ingredient("horn", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("winterhat", {Ingredient("beefalowool", 4),Ingredient("silk", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("catcoonhat", {Ingredient("coontail", 4), Ingredient("silk", 4)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
Recipe("kelphat", {Ingredient("kelp", 12)}, RECIPETABS.DRESS, TECH.NONE)
Recipe("goggleshat", {Ingredient("goldnugget", 1), Ingredient("pigskin", 1)}, RECIPETABS.DRESS, TECH.LOST)
Recipe("deserthat", {Ingredient("goggleshat", 1), Ingredient("pigskin", 1)}, RECIPETABS.DRESS, TECH.LOST)
Recipe("watermelonhat", {Ingredient("watermelon", 1), Ingredient("twigs", 3)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE)
Recipe("icehat", {Ingredient("transistor", 2), Ingredient("rope", 4), Ingredient("ice", 10)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("beehat", {Ingredient("silk", 8), Ingredient("rope", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("featherhat", {Ingredient("feather_crow", 3),Ingredient("feather_robin", 2), Ingredient("tentaclespots", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("bushhat", {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("raincoat", {Ingredient("tentaclespots", 2), Ingredient("rope", 2), Ingredient("boneshard", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE)
Recipe("sweatervest", {Ingredient("houndstooth", 8),Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("trunkvest_summer", {Ingredient("trunk_summer", 1),Ingredient("silk", 8)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("trunkvest_winter", {Ingredient("trunk_winter", 1),Ingredient("silk", 8), Ingredient("beefalowool", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("reflectivevest", {Ingredient("rope", 1), Ingredient("feather_robin", 3), Ingredient("pigskin", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("hawaiianshirt", {Ingredient("papyrus", 3), Ingredient("silk", 3), Ingredient("cactus_flower", 5)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("beargervest", {Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("eyebrellahat", {Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
Recipe("red_mushroomhat", {Ingredient("red_cap", 6)}, RECIPETABS.DRESS, TECH.LOST)
Recipe("green_mushroomhat", {Ingredient("green_cap", 6)}, RECIPETABS.DRESS, TECH.LOST)
Recipe("blue_mushroomhat", {Ingredient("blue_cap", 6)}, RECIPETABS.DRESS, TECH.LOST)


----GEMS----


----ANCIENT----
Recipe("thulecite", {Ingredient("thulecite_pieces", 6)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("wall_ruins_item", {Ingredient("thulecite", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true, 6)

Recipe("nightmare_timepiece", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("orangeamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("orangegem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("yellowamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("yellowgem", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)
Recipe("greenamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("greengem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_TWO, nil, nil, true)

Recipe("orangestaff", {Ingredient("nightmarefuel", 2), Ingredient("cane", 1), Ingredient("orangegem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("yellowstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("yellowgem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)
Recipe("greenstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("greengem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, nil, nil, true)

Recipe("multitool_axe_pickaxe", {Ingredient("goldenaxe", 1),Ingredient("goldenpickaxe", 1), Ingredient("thulecite", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)

Recipe("ruinshat", {Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("armorruins", {Ingredient("thulecite", 6), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("ruins_bat", {Ingredient("livinglog", 3), Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)
Recipe("eyeturret_item", {Ingredient("deerclops_eyeball", 1), Ingredient("minotaurhorn", 1), Ingredient("thulecite", 5)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, nil, nil, true)

----CELESTIAL----
Recipe("moonrockidol", {Ingredient("moonrocknugget", 1), Ingredient("purplegem", 1)}, RECIPETABS.CELESTIAL, TECH.CELESTIAL_ONE, nil, nil, true)
Recipe("multiplayer_portal_moonrock_constr_plans", {Ingredient("boards", 1), Ingredient("rope", 1)}, RECIPETABS.CELESTIAL, TECH.CELESTIAL_ONE, nil, nil, true)

----MOON_ALTAR-----
Recipe("moonglassaxe", {Ingredient("twigs", 2), Ingredient("moonglass", 3)}, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true)
Recipe("glasscutter", {Ingredient("boards", 1), Ingredient("moonglass", 6) }, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true)
Recipe("turf_meteor", {Ingredient("moonrocknugget", 1), Ingredient("moonglass", 2)}, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true, 6)
Recipe("bathbomb", {Ingredient("moon_tree_blossom", 6), Ingredient("nitre", 1)}, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true)
Recipe("chesspiece_butterfly_sketch", {Ingredient("papyrus", 1)}, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true)
Recipe("chesspiece_moon_sketch", {Ingredient("papyrus", 1)}, RECIPETABS.MOON_ALTAR, TECH.MOON_ALTAR_TWO, nil, nil, true)

----BOOK----
Recipe("book_birds", {Ingredient("papyrus", 2), Ingredient("bird_egg", 2)}, CUSTOM_RECIPETABS.BOOKS, TECH.NONE, nil, nil, nil, nil, "bookbuilder")
Recipe("book_gardening", {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)}, CUSTOM_RECIPETABS.BOOKS, TECH.SCIENCE_ONE, nil, nil, nil, nil, "bookbuilder")
Recipe("book_sleep", {Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2)}, CUSTOM_RECIPETABS.BOOKS, TECH.MAGIC_TWO, nil, nil, nil, nil, "bookbuilder")
Recipe("book_brimstone", {Ingredient("papyrus", 2), Ingredient("redgem", 1)}, CUSTOM_RECIPETABS.BOOKS, TECH.MAGIC_THREE, nil, nil, nil, nil, "bookbuilder")
Recipe("book_tentacles", {Ingredient("papyrus", 2), Ingredient("tentaclespots", 1)}, CUSTOM_RECIPETABS.BOOKS, TECH.SCIENCE_THREE, nil, nil, nil, nil, "bookbuilder")

----SHADOW----
Recipe("waxwelljournal", {Ingredient("papyrus", 2), Ingredient("nightmarefuel", 2), Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)}, CUSTOM_RECIPETABS.SHADOW, TECH.NONE, nil, nil, nil, nil, "shadowmagic")
Recipe("shadowlumber_builder", {Ingredient("nightmarefuel", 2), Ingredient("axe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWLUMBER)}, CUSTOM_RECIPETABS.SHADOW, TECH.SHADOW_TWO, nil, nil, true, nil, "shadowmagic")
Recipe("shadowminer_builder", {Ingredient("nightmarefuel", 2), Ingredient("pickaxe", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWMINER)}, CUSTOM_RECIPETABS.SHADOW, TECH.SHADOW_TWO, nil, nil, true, nil, "shadowmagic")
Recipe("shadowdigger_builder", {Ingredient("nightmarefuel", 2), Ingredient("shovel", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDIGGER)}, CUSTOM_RECIPETABS.SHADOW, TECH.SHADOW_TWO, nil, nil, true, nil, "shadowmagic")
Recipe("shadowduelist_builder", {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient(CHARACTER_INGREDIENT.MAX_SANITY, TUNING.SHADOWWAXWELL_SANITY_PENALTY.SHADOWDUELIST)}, CUSTOM_RECIPETABS.SHADOW, TECH.SHADOW_TWO, nil, nil, true, nil, "shadowmagic")

----ENGINEERING----
Recipe("sewing_tape", {Ingredient("silk", 1), Ingredient("cutgrass", 3)}, CUSTOM_RECIPETABS.ENGINEERING, TECH.NONE, nil, nil, nil, nil, "handyperson")
Recipe("winona_catapult", {Ingredient("sewing_tape", 1), Ingredient("twigs", 3), Ingredient("rocks", 15)}, CUSTOM_RECIPETABS.ENGINEERING, TECH.NONE, "winona_catapult_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "handyperson")
Recipe("winona_spotlight", {Ingredient("sewing_tape", 1), Ingredient("goldnugget", 2), Ingredient("fireflies", 1)}, CUSTOM_RECIPETABS.ENGINEERING, TECH.NONE, "winona_spotlight_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "handyperson")
Recipe("winona_battery_low", {Ingredient("sewing_tape", 1), Ingredient("log", 2), Ingredient("nitre", 2)}, CUSTOM_RECIPETABS.ENGINEERING, TECH.NONE, "winona_battery_low_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "handyperson")
Recipe("winona_battery_high", {Ingredient("sewing_tape", 1), Ingredient("boards", 2), Ingredient("transistor", 2)}, CUSTOM_RECIPETABS.ENGINEERING, TECH.NONE, "winona_battery_high_placer", TUNING.WINONA_ENGINEERING_SPACING, nil, nil, "handyperson")

----NATURE----
Recipe("livinglog", {Ingredient(CHARACTER_INGREDIENT.HEALTH, 20)}, CUSTOM_RECIPETABS.NATURE, TECH.NONE, nil, nil, nil, nil, "plantkin")
Recipe("armor_bramble", {Ingredient("livinglog", 2), Ingredient("boneshard", 4)}, CUSTOM_RECIPETABS.NATURE, TECH.NONE, nil, nil, nil, nil, "plantkin")
Recipe("trap_bramble", {Ingredient("livinglog", 1), Ingredient("stinger", 1)}, CUSTOM_RECIPETABS.NATURE, TECH.NONE, nil, nil, nil, nil, "plantkin")
Recipe("compostwrap", {Ingredient("poop", 5), Ingredient("spoiled_food", 2), Ingredient("nitre", 1)}, CUSTOM_RECIPETABS.NATURE, TECH.NONE, nil, nil, nil, nil, "plantkin")

----CARTOGRAPHY----
Recipe("mapscroll", {Ingredient("featherpencil", 1), Ingredient("papyrus", 1)}, RECIPETABS.CARTOGRAPHY, TECH.CARTOGRAPHY_TWO, nil, nil, true, nil, nil, nil, function() return TheWorld.worldprefab == "forest" and "mapscroll.tex" or ("mapscroll_"..TheWorld.worldprefab..".tex") end)

----SEAFARING----
Recipe("boat_item", {Ingredient("boards", 4)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("boatpatch", {Ingredient("boards", 1), Ingredient("stinger", 2)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("oar", {Ingredient("log", 1)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("oar_driftwood", {Ingredient("driftwood_log", 1)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("anchor_item", {Ingredient("boards", 2), Ingredient("rope", 3), Ingredient("cutstone", 3)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("mast_item", {Ingredient("boards", 3), Ingredient("rope", 3), Ingredient("silk", 8)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
Recipe("steeringwheel_item", {Ingredient("boards", 2), Ingredient("rope", 1)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)
--Recipe("fishingnet", {Ingredient("silk", 6)}, RECIPETABS.SEAFARING, TECH.SEAFARING_ONE, nil, nil, true)
Recipe("chesspiece_anchor_sketch", {Ingredient("papyrus", 1)}, RECIPETABS.SEAFARING, TECH.SEAFARING_TWO)

----SCULPTING----
Recipe("chesspiece_hornucopia_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.SCULPTING_ONE, nil, nil, true, nil, nil, nil, "chesspiece_hornucopia.tex")
Recipe("chesspiece_pipe_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.SCULPTING_ONE, nil, nil, true, nil, nil, nil, "chesspiece_pipe.tex")
Recipe("chesspiece_pawn_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_pawn.tex")
Recipe("chesspiece_rook_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_rook.tex")
Recipe("chesspiece_knight_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_knight.tex")
Recipe("chesspiece_bishop_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_bishop.tex")
Recipe("chesspiece_muse_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_muse.tex")
Recipe("chesspiece_formal_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_formal.tex")
Recipe("chesspiece_deerclops_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("deerclops_eyeball", 1)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_deerclops.tex")
Recipe("chesspiece_bearger_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("bearger_fur", 1)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_bearger.tex")
Recipe("chesspiece_moosegoose_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("goose_feather", 5)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_moosegoose.tex")
Recipe("chesspiece_dragonfly_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("dragon_scales", 1)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_dragonfly.tex")
Recipe("chesspiece_clayhound_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("houndstooth", 1)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_clayhound.tex")
Recipe("chesspiece_claywarg_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2), Ingredient("houndstooth", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_claywarg.tex")
Recipe("chesspiece_butterfly_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_butterfly.tex")
Recipe("chesspiece_anchor_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_anchor.tex")
Recipe("chesspiece_moon_builder", {Ingredient(TECH_INGREDIENT.SCULPTING, 2), Ingredient("rocks", 2)}, RECIPETABS.SCULPTING, TECH.LOST, nil, nil, true, nil, nil, nil, "chesspiece_moon.tex")

----CRITTERS----
Recipe("critter_kitten_builder", {Ingredient("coontail", 1), Ingredient("fishsticks", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_puppy_builder", {Ingredient("houndstooth", 4), Ingredient("monsterlasagna", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_lamb_builder", {Ingredient("steelwool", 1), Ingredient("guacamole", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_perdling_builder", {Ingredient("featherhat", 1), Ingredient("trailmix", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_dragonling_builder", {Ingredient("lavae_cocoon", 1), Ingredient("hotchili", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_glomling_builder", {Ingredient("glommerfuel", 1), Ingredient("taffy", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)
Recipe("critter_lunarmothling_builder", {Ingredient("moonbutterfly", 1), Ingredient("flowersalad", 1)}, RECIPETABS.ORPHANAGE, TECH.ORPHANAGE_ONE, nil, nil, true)

----PERDSHRINE-----
Recipe("firecrackers", {Ingredient("lucky_goldnugget", 1)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_ONE, nil, nil, true, 3)
Recipe("redlantern", {Ingredient("lucky_goldnugget", 3)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_ONE, nil, nil, true)
Recipe("perdfan", {Ingredient("lucky_goldnugget", 3)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_THREE, nil, nil, true)
Recipe("houndwhistle", {Ingredient("lucky_goldnugget", 3)}, RECIPETABS.PERDOFFERING, TECH.WARGOFFERING_THREE, nil, nil, true)
Recipe("chesspiece_clayhound_sketch", {Ingredient("lucky_goldnugget", 8)}, RECIPETABS.PERDOFFERING, TECH.WARGOFFERING_THREE, nil, nil, true)
Recipe("chesspiece_claywarg_sketch", {Ingredient("lucky_goldnugget", 16)}, RECIPETABS.PERDOFFERING, TECH.WARGOFFERING_THREE, nil, nil, true)
Recipe("yotp_food3", {Ingredient("lucky_goldnugget", 4)}, RECIPETABS.PERDOFFERING, TECH.PIGOFFERING_THREE, nil, nil, true)
Recipe("yotp_food1", {Ingredient("lucky_goldnugget", 6)}, RECIPETABS.PERDOFFERING, TECH.PIGOFFERING_THREE, nil, nil, true)
Recipe("yotp_food2", {Ingredient("lucky_goldnugget", 1)}, RECIPETABS.PERDOFFERING, TECH.PIGOFFERING_THREE, nil, nil, true)
Recipe("dragonheadhat", {Ingredient("lucky_goldnugget", 8)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_ONE, nil, nil, true)
Recipe("dragonbodyhat", {Ingredient("lucky_goldnugget", 8)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_ONE, nil, nil, true)
Recipe("dragontailhat", {Ingredient("lucky_goldnugget", 8)}, RECIPETABS.PERDOFFERING, TECH.PERDOFFERING_ONE, nil, nil, true)

----MADSCIENCE-----
Recipe("halloween_experiment_bravery", {Ingredient("froglegs", 1), Ingredient("goldnugget", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, RECIPETABS.MADSCIENCE, TECH.MADSCIENCE_ONE, nil, nil, true, nil, nil, nil, "halloweenpotion_bravery_small.tex")
Recipe("halloween_experiment_health", {Ingredient("mosquito", 1), Ingredient("red_cap", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, RECIPETABS.MADSCIENCE, TECH.MADSCIENCE_ONE, nil, nil, true, nil, nil, nil, "halloweenpotion_health_small.tex")
Recipe("halloween_experiment_sanity", {Ingredient("crow", 1), Ingredient("petals_evil", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, RECIPETABS.MADSCIENCE, TECH.MADSCIENCE_ONE, nil, nil, true, nil, nil, nil, "halloweenpotion_sanity_small.tex")
Recipe("halloween_experiment_volatile", {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 10)}, RECIPETABS.MADSCIENCE, TECH.MADSCIENCE_ONE, nil, nil, true, nil, nil, nil, "halloweenpotion_embers.tex")
Recipe("halloween_experiment_root", {Ingredient("batwing", 1), Ingredient("livinglog", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 20)}, RECIPETABS.MADSCIENCE, TECH.MADSCIENCE_ONE, nil, nil, true, nil, nil, nil, "livingtree_root.tex")

----FOODPROCESSING-----
Recipe("spice_garlic", {Ingredient("garlic", 3, nil, nil, "quagmire_garlic.tex")}, RECIPETABS.FOODPROCESSING, TECH.FOODPROCESSING_ONE, nil, nil, true, 2, "professionalchef")
Recipe("spice_sugar", {Ingredient("honey", 3)}, RECIPETABS.FOODPROCESSING, TECH.FOODPROCESSING_ONE, nil, nil, true, 2, "professionalchef")
Recipe("spice_chili", {Ingredient("pepper", 3)}, RECIPETABS.FOODPROCESSING, TECH.FOODPROCESSING_ONE, nil, nil, true, 2, "professionalchef")

----UNCRAFTABLE----
--NOTE: These recipes are not supposed to be craftable!
Recipe("pighead", {Ingredient("pigskin", 4), Ingredient("twigs", 4)}, nil, TECH.LOST, nil, nil, true)
Recipe("mermhead", {Ingredient("spoiled_food", 4), Ingredient("twigs", 4)}, nil, TECH.LOST, nil, nil, true)
--this is so you can use deconstruction staff on portable cookware when deployed
Recipe("portablecookpot", {Ingredient("goldnugget", 2), Ingredient("charcoal",   6), Ingredient("twigs", 6)}, nil, TECH.LOST, nil, nil, true)
Recipe("portableblender", {Ingredient("goldnugget", 2), Ingredient("transistor", 2), Ingredient("twigs", 4)}, nil, TECH.LOST, nil, nil, true)
Recipe("portablespicer",  {Ingredient("goldnugget", 2), Ingredient("cutstone",   3), Ingredient("twigs", 6)}, nil, TECH.LOST, nil, nil, true)

Recipe("steeringwheel", {Ingredient("boards", 2), Ingredient("rope", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("anchor", {Ingredient("boards", 2), Ingredient("rope", 3), Ingredient("cutstone", 3)}, nil, TECH.LOST, nil, nil, true)
Recipe("mast", {Ingredient("boards", 3), Ingredient("rope", 3), Ingredient("silk", 8)}, nil, TECH.LOST, nil, nil, true)

Recipe("purplemooneye", {Ingredient("moonrockcrater", 1), Ingredient("purplegem", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("bluemooneye", {Ingredient("moonrockcrater", 1), Ingredient("bluegem", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("redmooneye", {Ingredient("moonrockcrater", 1), Ingredient("redgem", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("orangemooneye", {Ingredient("moonrockcrater", 1), Ingredient("orangegem", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("yellowmooneye", {Ingredient("moonrockcrater", 1), Ingredient("yellowgem", 1)}, nil, TECH.LOST, nil, nil, true)
Recipe("greenmooneye", {Ingredient("moonrockcrater", 1), Ingredient("greengem", 1)}, nil, TECH.LOST, nil, nil, true)

Recipe("opalstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("opalpreciousgem", 1)}, nil, TECH.LOST, nil, nil, true)

----CONSTRUCTION PLANS----
CONSTRUCTION_PLANS =
{
    ["multiplayer_portal_moonrock_constr"] = { Ingredient("purplemooneye", 1), Ingredient("moonrocknugget", 20) },
}

mod_protect_Recipe = true
