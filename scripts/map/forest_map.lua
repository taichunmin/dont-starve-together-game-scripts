local startlocations = require"map/startlocations"

local SKIP_GEN_CHECKS = false

local trees = {"evergreen_short", "evergreen_normal", "evergreen_tall"}
local function tree()
    return "evergreen"--trees[math.random(#trees)]
end

require "map/terrain"
require "map/ocean_gen"
require "map/bunch_spawner"
require "map/archive_worldgen"
require "map/monkeyisland_worldgen"

local function pickspawnprefab(items_in, ground_type)
--	if ground_type == WORLD_TILES.ROAD then
--		return
--	end
	local items = {}
	if ground_type ~= nil then
		-- Filter the items
	    for item,v in pairs(items_in) do
	    	items[item] = items_in[item]
	        if terrain.filter[item]~= nil then
--	        	if ground_type == WORLD_TILES.ROAD then
--	        		print ("Filter", item, terrain.filter.Print(terrain.filter[item]), GROUND_NAMES[ground_type])
--	        	end

	            for idx,gt in ipairs(terrain.filter[item]) do
        			if gt == ground_type then
        				items[item] = nil
        				--print ("Filtered", item, GROUND_NAMES[ground_type], " (".. terrain.filter.Print(terrain.filter[item])..")")
        			end
   				end
	        end
	    end
	end
    local total = 0
    for k,v in pairs(items) do
        total = total + v
    end
    if total > 0 then
        local rnd = math.random()*total
        for k,v in pairs(items) do
            rnd = rnd - v
            if rnd <= 0 then
                return k
            end
        end
    end
end

local function pickspawngroup(groups)
    for k,v in pairs(groups) do
        if math.random() < v.percent then
            return v
        end
    end
end

local function pickspawncountprefabforground(prefabs, ground_type)
	local items = {}
	for item, _ in pairs(prefabs) do
		if terrain.filter[item] == nil then
			table.insert(items, item)
		else
			local add = true
	        for idx,gt in ipairs(terrain.filter[item]) do
        		if gt == ground_type then
					add = false
					break
				end
			end
			if add then
				table.insert(items, item)
			end
		end
	end
	if #items > 0 then
		return items[math.random(#items)]
	end
	return nil
end

local MULTIPLY = {
	["never"] = 0,
	["rare"] = 0.5,
	["uncommon"] = 0.75,
	["default"] = 1,
	["often"] = 1.5,
	["mostly"] = 2.2,
	["always"] = 3,
	["insane"] = 6,

	["ocean_never"] = 0,
	["ocean_rare"] = 0.65,
	["ocean_uncommon"] = 0.85,
	["ocean_default"] = 1,
	["ocean_often"] = 1.3,
	["ocean_mostly"] = 1.65,
	["ocean_always"] = 2,
	["ocean_insane"] = 4,
}

local CLUMP = {
	["often"] = 8,
	["mostly"] = 15,
	["always"] = 30,
	["insane"] = 60,

	["ocean_often"] = 15,
	["ocean_mostly"] = 25,
	["ocean_always"] = 40,
	["ocean_insane"] = 60,
}

local CLUMPSIZE = {
	["often"] = {1, 2},
	["mostly"] = {2, 3},
	["always"] = {3, 4},
	["insane"] = {5, 6},

	["ocean_often"] = {1, 2},
	["ocean_mostly"] = {2, 3},
	["ocean_always"] = {3, 4},
	["ocean_insane"] = {5, 6},
}

local SPAWNER_MUL = 1.2
local OCEAN_SPAWNER_MUL = 1.2
local function prefab_spawner_multiply(density, mult)
	if mult > 1 then
		return math.max(mult / SPAWNER_MUL, 1)
	elseif mult < 1 then
		return math.min(mult * SPAWNER_MUL, 1)
	end
	return mult
end
local function prefab_spawner_ocean_multiply(density, mult)
	if mult > 1 then
		return math.max(mult / OCEAN_SPAWNER_MUL, 1)
	elseif mult < 1 then
		return math.min(mult * OCEAN_SPAWNER_MUL, 1)
	end
	return mult
end

--spawners get a lower density, since spawners spawn multiple things.
local MULTIPLY_PREFABS = {
	["tumbleweedspawner"] = 		prefab_spawner_multiply,
	["buzzardspawner"] = 			prefab_spawner_multiply,
    ["slurper_spawner"] =           prefab_spawner_multiply,
    ["worm_spawner"] =             	prefab_spawner_multiply,
	["monkeybarrel_spawner"] =      prefab_spawner_multiply,

	--while it is an ocean setting, its spawning requirements mean it needs to get treated like a land setting.
	["wobster_den_spawner_shore"] =	prefab_spawner_multiply,
	--feels more impactful as a land setting multiplier.
	["oceanfish_shoalspawner"] =	prefab_spawner_multiply,

	["seastack_spawner_rough"] =	prefab_spawner_ocean_multiply,
	["seastack_spawner_swell"] =	prefab_spawner_ocean_multiply,
	["waterplant_spawner_rough"] =	prefab_spawner_ocean_multiply,
	["boat_otterden"] = 			prefab_spawner_ocean_multiply,
}

local TRANSLATE_TO_PREFABS = {
	["spiders"] = 			{"spiderden"},
	["cave_spiders"] = 		{"dropperweb", "spiderhole"},
	["tentacles"] = 		{"tentacle"},
	["tallbirds"] = 		{"tallbirdnest"},
	["pigs"] = 				{"pighouse"},
	["rabbits"] = 			{"rabbithole"},
	["moles"] =				{"molehill"},
	["beefalo"] = 			{"beefalo"},
	["ponds"] = 			{"pond", "pond_mos"},
	["cave_ponds"] = 		{"pond", "pond_cave"},
	["bees"] = 				{"beehive", "bee"},
	["grass"] = 			{"grass","grassgekko"},
	["rock"] = 				{"rocks", "rock1", "rock2", "rock_flintless","rock_petrified_tree"},
	["sapling"] = 			{"sapling","twiggytree","ground_twigs"},
	["reeds"] = 			{"reeds"},
	["trees"] = 			{"evergreen", "evergreen_sparse", "deciduoustree", "marsh_tree"},
	["evergreen"] = 		{"evergreen"},
	["carrot"] = 			{"carrot_planted"},
	["berrybush"] = 		{"berrybush", "berrybush2", "berrybush_juicy"},
	["maxwelllight"] = 		{"maxwelllight"},
	["maxwelllight_area"] = {"maxwelllight_area"},
	["fireflies"] = 		{"fireflies"},
	["cave_entrance"] = 	{"cave_entrance"},
	["tumbleweed"] = 		{"tumbleweedspawner"},
	["cactus"] = 			{"cactus", "oasis_cactus"},
	["lightninggoat"] = 	{"lightninggoat"},
	["catcoon"] = 			{"catcoonden"},
	["merm"] = 				{"mermhouse"},
	["buzzard"] = 			{"buzzardspawner"},
	["mushroom"] =			{"red_mushroom", "green_mushroom", "blue_mushroom"},
	["marshbush"] = 		{"marsh_bush"},
	["flint"] = 			{"flint"},
	["mandrake"] = 			{"mandrake"},
	["angrybees"] = 		{"wasphive", "killerbee"},
	["houndmound"] = 		{"houndmound"},
	["chess"] = 			{"knight", "bishop", "rook"}, --here for lowering the quantities of chess pieces.
	["walrus"] = 			{"walrus_camp"},
    ["mushtree"] =          {"mushtree_tall", "mushtree_medium", "mushtree_small", "mushtree_moon"},
    ["bats"] =              {"batcave"},
    ["fissure"] =           {"fissure", "fissure_lower"},
    ["fern"] =              {"cave_fern"},
    ["flower_cave"] =       {"flower_cave", "flower_cave_double", "flower_cave_triple"},
    ["slurper"] =           {"slurper", "slurper_spawner"},
    ["cavelight"] =         {"cavelight", "cavelight_small", "cavelight_tiny"},
    ["bunnymen"] =          {"rabbithouse"},
    ["wormlights"] =        {"wormlight_plant"},
    ["worms"] =             {"worm_spawner"},
    ["slurtles"] =          {"slurtlehole"},
    ["rocky"] =             {"rocky"},
    ["lichen"] =            {"lichen"},
    ["banana"] =            {"cave_banana_tree"},
    ["monkey"] =            {"monkeybarrel_spawner"},
	["mooncarrot"] =        {"mooncarrot_planted"},
    ["palmconetree"] =      {"palmconetree"},

	--lunar island stuff, all prefixed with "moon_"
	["moon_tree"] =			{"moon_tree"},
	["moon_sapling"] =		{"sapling_moon"},
	["moon_berrybush"] =	{"rock_avocado_bush"},
	["moon_rock"] = 		{"moonglass_rock", "rock_moon", "moonglass", "lunar_island_rocks", "lunar_island_rock1", "lunar_island_rock2"},
	["moon_spiders"] =		{"moonspiderden"},
	["moon_carrot"] =		{"carrat_planted"},
	["moon_fruitdragon"] =	{"fruitdragon"},
	["moon_hotspring"] =	{"hotspring"},
	["moon_fissure"] =		{"moon_fissure"},
	["moon_starfish"] =		{"trap_starfish"},
	["moon_bullkelp"] =		{"bullkelp_beachedroot"},

	--Ocean stuff all prefixed with "ocean_"
	["ocean_seastack"] =	{"seastack", "seastack_spawner_rough", "seastack_spawner_swell"},
	["ocean_shoal"] =		{"oceanfish_shoalspawner"},
	["ocean_waterplant"] =	{"waterplant_spawner_rough", "waterplant"},
	["ocean_wobsterden"] =	{"wobster_den_spawner_shore"},
	["ocean_bullkelp"] =	{"bullkelp_plant"},
	["ocean_otterdens"] =   {"boat_otterden"},

    -- Allow for the Terrarium to be a required world gen prefab, but still disable-able via World Gen settings
    ["terrariumchest"] =    {"terrariumchest"},

    -- Allow for the stageplays to be required world gen prefabs, but still disable-able via World Gen settings
	["stageplays"] =		{"charlie_stage_post", "statueharp_hedgespawner"},
	-- Allow for the junk piles to be required world gen prefabs, but still disable-able via World Gen settings
	["junkyard"] =		    {"junk_pile", "junk_pile_big"},
}

local TRANSLATE_TO_CLUMP = {
	["chess"] = 			{"worldgen_chesspieces"}, --here for increasing the quantities of chess pieces
}

local TRANSLATE_AND_OVERRIDE = { --These are entities that should be translated to prefabs for world gen but also have a postinit override to do
	["flowers"] =			{"flower", "flower_evil"},
	["rock_ice"] = 			{"rock_ice"},
}

local function TranslateWorldGenChoices(gen_params)
    if gen_params == nil or GetTableSize(gen_params) == 0 then
        return nil, nil
    end

    local translated_prefabs = {}
    local runtime_overrides = {}

    for tweak, v in pairs(gen_params) do
        if v ~= "default" then
            if TRANSLATE_AND_OVERRIDE[tweak] ~= nil then --Override and Translate
				for i,prefab in ipairs(TRANSLATE_AND_OVERRIDE[tweak]) do --Translate
					local mult = MULTIPLY[v]
					if MULTIPLY_PREFABS[prefab] then
						mult = MULTIPLY_PREFABS[prefab](v, mult)
					end
                    translated_prefabs[prefab] = mult
                end

                runtime_overrides[tweak] = v --Override
            elseif TRANSLATE_TO_PREFABS[tweak] ~= nil then --Translate only
                for i,prefab in ipairs(TRANSLATE_TO_PREFABS[tweak]) do
					local mult = MULTIPLY[v]
					if MULTIPLY_PREFABS[prefab] then
						mult = MULTIPLY_PREFABS[prefab](v, mult)
					end
                    translated_prefabs[prefab] = mult
                end
            else --Override only
                runtime_overrides[tweak] = v
            end

			if TRANSLATE_TO_CLUMP[tweak] then
                for i,prefab in ipairs(TRANSLATE_TO_CLUMP[tweak]) do
					local clump = CLUMP[v]
					if clump then
						translated_prefabs[prefab] = {clumpcount = clump, clumpsize = CLUMPSIZE[v]}
					end
                end
			end
        end
    end

    if GetTableSize(translated_prefabs) == 0 then
        translated_prefabs = nil
    end

    if GetTableSize(runtime_overrides) == 0 then
        runtime_overrides = nil
    end

    return translated_prefabs, runtime_overrides
end
local function seasonfn(friendly, winter)
	return function(season)
		local totaldaysinseason
		local remainingdaysinseason
		if friendly then
			totaldaysinseason = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT*2
			remainingdaysinseason = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT
		else
			totaldaysinseason = TUNING.SEASON_LENGTH_HARSH_DEFAULT
			remainingdaysinseason = TUNING.SEASON_LENGTH_HARSH_DEFAULT
		end
		local seasons = {
			season = season,
			totaldaysinseason = totaldaysinseason,
			elapseddaysinseason = 0,
			remainingdaysinseason = remainingdaysinseason,
		}
		return {seasons = seasons, weather = winter and {snowlevel = 1} or nil}
	end
end

local SEASONS = {
	["autumn"] = seasonfn(true),
	["winter"] = seasonfn(true, true),
	["spring"] = seasonfn(true),
	["summer"] = seasonfn(false),
}

local DEFAULT_SEASON = "autumn"

local function UpdatePercentage(distributeprefabs, gen_params)
	for selected, v in pairs(gen_params) do
		if v ~= "default" then
			for i, prefab in ipairs(TRANSLATE_TO_PREFABS[selected]) do
				if distributeprefabs[prefab] ~= nil then
					distributeprefabs[prefab] = distributeprefabs[prefab] * MULTIPLY[v]
				end
			end
		end
	end
end

local NoiseTileFunctions = require("noisetilefunctions")

local function GetTileForNoiseTile(tile, noise)
	if NoiseTileFunctions[tile] then
		return NoiseTileFunctions[tile](noise)
	end
	return NoiseTileFunctions.default(noise)
end

local function ValidateGroundTile(tile)
	if TileGroupManager:IsNoiseTile(tile) then
		return WORLD_TILES.DIRT
	end
	if not TileGroupManager:IsLandTile(tile) then
		return WORLD_TILES.ROCKY
	end
	return tile
end

local function Generate(prefab, map_width, map_height, tasks, level, level_type)
	WorldSim:SetPointsBarrenOrReservedTile(WORLD_TILES.ROAD)
	WorldSim:SetResolveNoiseFunction(GetTileForNoiseTile)
	WorldSim:SetValidateGroundTileFunction(ValidateGroundTile)

    local SpawnFunctions = {
        pickspawnprefab = pickspawnprefab,
        pickspawngroup = pickspawngroup,
		pickspawncountprefabforground = pickspawncountprefabforground,
    }

    assert(level.overrides ~= nil, "Level must have overrides specified.")
    local current_gen_params = deepcopy(level.overrides)

    local story_gen_params = {}

    local default_impassible_tile = WORLD_TILES.IMPASSABLE

    story_gen_params.impassible_value = default_impassible_tile
    story_gen_params.level_type = level_type

    if current_gen_params.start_location == nil then
        current_gen_params.start_location = "default"
    end
    if current_gen_params.start_location ~= nil then
        local start_loc = startlocations.GetStartLocation( current_gen_params.start_location )
        story_gen_params.start_setpeice = type(start_loc.start_setpeice) == "table" and start_loc.start_setpeice[math.random(#start_loc.start_setpeice)] or start_loc.start_setpeice
        story_gen_params.start_node = type(start_loc.start_node) == "table" and start_loc.start_node[math.random(#start_loc.start_node)] or start_loc.start_node
		if story_gen_params.start_node == nil then
			-- existing_start_node is no longer supported
			story_gen_params.start_node = type(start_loc.existing_start_node) == "table" and start_loc.existing_start_node[math.random(#start_loc.existing_start_node)] or start_loc.existing_start_node
		end
    end

    if  current_gen_params.islands ~= nil then
        local percent = {always=1, never=0,default=0.2, sometimes=0.1, often=0.8}
        story_gen_params.island_percent = percent[current_gen_params.islands]
    end

    if  current_gen_params.branching ~= nil then
        story_gen_params.branching = current_gen_params.branching
    end

    if  current_gen_params.loop ~= nil then
        local loop_percent = { never=0, default=nil, always=1.0 }
        local loop_target = { never="any", default=nil, always="end"}
        story_gen_params.loop_percent = loop_percent[current_gen_params.loop]
        story_gen_params.loop_target = loop_target[current_gen_params.loop]
    end

    if current_gen_params.layout_mode ~= nil then
        story_gen_params.layout_mode = current_gen_params.layout_mode
    end

    if current_gen_params.keep_disconnected_tiles ~= nil then
        story_gen_params.keep_disconnected_tiles = current_gen_params.keep_disconnected_tiles
    end

    if current_gen_params.no_joining_islands ~= nil then
        story_gen_params.no_joining_islands = current_gen_params.no_joining_islands
    end

    if current_gen_params.has_ocean ~= nil then
        story_gen_params.has_ocean = current_gen_params.has_ocean
    end

    if current_gen_params.no_wormholes_to_disconnected_tiles ~= nil then
        story_gen_params.no_wormholes_to_disconnected_tiles = current_gen_params.no_wormholes_to_disconnected_tiles
    end

    if current_gen_params.wormhole_prefab ~= nil then
        story_gen_params.wormhole_prefab = current_gen_params.wormhole_prefab
    end

	ApplySpecialEvent(current_gen_params.specialevent)
	for k, event_name in pairs(SPECIAL_EVENTS) do
		if current_gen_params[event_name] == "enabled" then
			ApplyExtraEvent(event_name)
		end
	end

    local min_size = 350
    if current_gen_params.world_size ~= nil then
        local sizes
        if PLATFORM == "PS4" then
            sizes = {
                ["default"] = 350,
                ["medium"] = 400,
                ["large"] = 425,
            }
        else
            sizes = {
                ["tiny"] = 1,
                ["small"] = 50,
                ["medium"] = 400,
                ["default"] = 425, -- default == large, at the moment...
                ["large"] = 425,
                ["huge"] = 450,
            }
        end

        if sizes[current_gen_params.world_size] then
            min_size = sizes[current_gen_params.world_size]
            print("New size:", min_size, current_gen_params.world_size)
        else
            print("ERROR: Worldgen preset had an invalid size: "..current_gen_params.world_size)
        end
	end
    map_width = min_size
    map_height = min_size
    WorldSim:SetWorldSize(map_width, map_height)

    print("Creating story...")
    require("map/storygen")
    local topology_save, storygen = BuildStory(tasks, story_gen_params, level)

	WorldSim:WorldGen_InitializeNodePoints();

	WorldSim:WorldGen_VoronoiPass(100)

	storygen:AddRegionsToMainland(function()
		WorldSim:WorldGen_AddNewPositions()
		WorldSim:WorldGen_VoronoiPass(50)
	end)

    print("... story created")


    print("Baking map...", min_size)

	if not WorldSim:WorldGen_Commit() then
        return nil
    end

    topology_save.root:ApplyPoisonTag()
    WorldSim:ConvertToTileMap(min_size)

	WorldSim:SeparateIslands()
    print("Map Baked!")
	map_width, map_height = WorldSim:GetWorldSize()

	local join_islands = not current_gen_params.no_joining_islands

	-- Note: This also generates land tiles
    WorldSim:ForceConnectivity(join_islands, false, WORLD_TILES.ROCKY)--prefab == "cave" )

    local entities = {}
	-- turning this off for now because its conflicting with the island tech and disconnected node stripping, causing wormholes in the atrium
	if false and not current_gen_params.no_wormholes_to_disconnected_tiles then
		topology_save.root:SwapWormholesAndRoadsExtra(entities, map_width, map_height)
		if topology_save.root.error == true then
			print ("ERROR: Node ", topology_save.root.error_string)
			if SKIP_GEN_CHECKS == false then
	    		return nil
			end
		end
	end

	if (current_gen_params.roads == nil or current_gen_params.roads ~= "never") and prefab ~= "cave" then
	    WorldSim:SetRoadParameters(
			ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
			ROAD_PARAMETERS.MIN_WIDTH, ROAD_PARAMETERS.MAX_WIDTH,
			ROAD_PARAMETERS.MIN_EDGE_WIDTH, ROAD_PARAMETERS.MAX_EDGE_WIDTH,
			ROAD_PARAMETERS.WIDTH_JITTER_SCALE )

		WorldSim:DrawRoads(join_islands, WORLD_TILES.DIRT)
	end

	-- Run Node specific functions here
	local nodes = topology_save.root:GetNodes(true)
	for k,node in pairs(nodes) do
		node:SetTilesViaFunction(entities, map_width, map_height)
	end

    print("Encoding...")

    local save = {}
    save.ents = {}
    save.map = {
        tiles = "",
		topology = {},
        prefab = prefab,
		has_ocean = current_gen_params.has_ocean,
    }
    topology_save.root:SaveEncode({width=map_width, height=map_height}, save.map.topology)
	WorldSim:CreateNodeIdTileMap(save.map.topology.ids)
    print("Encoding... DONE")

    -- TODO: Double check that each of the rooms has enough space (minimimum # tiles generated) - maybe countprefabs + %
    -- For each item in the topology list
    -- Get number of tiles for that node
    -- if any are less than minumum - restart the generation

    for idx,val in ipairs(save.map.topology.nodes) do
		if string.find(save.map.topology.ids[idx], "LOOP_BLANK_SUB") == nil  then
 	    	local area = WorldSim:GetSiteArea(save.map.topology.ids[idx])
	    	if area < 8 then
	    		print ("ERROR: Site "..save.map.topology.ids[idx].." area < 8: "..area)
	    		if SKIP_GEN_CHECKS == false then
	    			return nil
	    		end
	   		end
	   	end
	end

    local translated_prefabs, runtime_overrides = TranslateWorldGenChoices(current_gen_params)

    print("Checking Tags")
	local obj_layout = require("map/object_layout")

	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
				WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])

				local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
				local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
				x = math.floor(x*100)/100.0
				y = math.floor(y*100)/100.0
				if entitiesOut[prefab] == nil then
					entitiesOut[prefab] = {}
				end
				local save_data = {x=x, z=y}
				if prefab_data then

					if prefab_data.data then
						if type(prefab_data.data) == "function" then
							save_data["data"] = prefab_data.data()
						else
							save_data["data"] = prefab_data.data
						end
					end
					if prefab_data.id then
						save_data["id"] = prefab_data.id
					end
					if prefab_data.scenario then
						save_data["scenario"] = prefab_data.scenario
					end
				end
				table.insert(entitiesOut[prefab], save_data)
			end,
			args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
		}

   	if topology_save.GlobalTags["Labyrinth"] ~= nil and GetTableSize(topology_save.GlobalTags["Labyrinth"]) >0 then
   		for task, labyrinth_nodes in pairs(topology_save.GlobalTags["Labyrinth"]) do

	   		local val = math.floor(math.random()*10.0-2.5)
	   		local mazetype = MAZE_TYPE.MAZE_GROWINGTREE_4WAY

	   		local xs, ys, types = WorldSim:RunMaze(mazetype, val, WORLD_TILES.IMPASSABLE, WORLD_TILES.BRICK, labyrinth_nodes)
	   		-- TODO: place items of interest in these locations
			if xs ~= nil and #xs >0 then
				for idx = 1,#xs do
			   		if types[idx] == 0 then
			   			--Spawning chests within the labyrinth.
						local prefab = "pandoraschest"
						local x = (xs[idx]+1.5 - map_width/2.0)*TILE_SCALE --gjans: note the +1.5 instead of +0.5... RunMaze points are in a strange position.
						local y = (ys[idx]+1.5 - map_height/2.0)*TILE_SCALE
						--WorldSim:ReserveTile(xs[idx], ys[idx]) --gjans: This reseves the wrong tile, something wrong with the points returned by RunMaze.
						--print(task.." Labyrinth Point of Interest:",xs[idx], ys[idx], x, y)

						if entities[prefab] == nil then
							entities[prefab] = {}
						end
						local save_data = {x=x, z=y, scenario = "chest_labyrinth"}
						table.insert(entities[prefab], save_data)
					end
				end
			end
            -- The maze can cut itself off from land at the edge, so draw a little road to bring it together.
            for i,node in ipairs(topology_save.GlobalTags["LabyrinthEntrance"][task]) do
                local entrance_node = topology_save.root:GetNodeById(node)
                for id, edge in pairs(entrance_node.edges) do
                    if edge.node1.data.type ~= NODE_TYPE.Blank and edge.node2.data.type ~= NODE_TYPE.Blank then
                        WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, WORLD_TILES.BRICK)
                    end
                end
            end

            -- And same story on all it's exits and non-maze internal nodes
            for i,node in ipairs(labyrinth_nodes) do
                local real_node = nodes[node]
                for id, edge in pairs(real_node.edges) do
                    if edge.node1.data.type ~= NODE_TYPE.Blank and edge.node2.data.type ~= NODE_TYPE.Blank
                        and table.contains(topology_save.GlobalTags["Labyrinth"][task], edge.node1.id) ~= table.contains(topology_save.GlobalTags["Labyrinth"][task], edge.node2.id) then
                        WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, WORLD_TILES.BRICK)
                    end
                end
            end
        end
    end

   	if topology_save.GlobalTags["Maze"] ~= nil and GetTableSize(topology_save.GlobalTags["Maze"]) >0 then

   		for task, nodes in pairs(topology_save.GlobalTags["Maze"]) do
			local maze_tile_size = topology_save.root:GetNodeById(task).maze_tile_size or 8
	 		local xs, ys, types = WorldSim:GetPointsForMetaMaze(maze_tile_size, nodes)

			if xs ~= nil and #xs >0 then
				local choices = topology_save.root:GetNodeById(task).maze_tiles
				local c_x, c_y = WorldSim:GetSiteCentroid(topology_save.GlobalTags["MazeEntrance"][task][1])
				local centroid = Vector3(c_x, c_y, 0)

				local distances = {}
				for idx = 1,#xs do
					table.insert(distances, {idx=idx, dist=(centroid - Vector3(xs[idx], ys[idx], 0)):LengthSq()})
				end
				table.sort(distances, function(a,b) return a.dist < b.dist end)

				if choices.archive ~= nil then

					local ends = {}
					for _,d in ipairs(distances) do
						local maze_room = math.abs(types[d.idx])
						if maze_room == 1 or maze_room == 2 or maze_room == 4 or maze_room == 8 then
							table.insert(ends, d.idx)
						end
					end

					local choice = math.random(1,#ends)
					local endidx = ends[choice]
					table.remove(ends,choice)
					obj_layout.Place({xs[endidx], ys[endidx]}, MAZE_CELL_EXITS_INV[math.abs(types[endidx])], add_fn, choices.special.finish)

					choice = math.random(1,#ends)
					local startidx = ends[choice]
					obj_layout.Place({xs[startidx], ys[startidx]}, MAZE_CELL_EXITS_INV[math.abs(types[startidx])], add_fn, choices.special.start)

					local reservedindex = math.random(1,#xs)
					while reservedindex == endidx or reservedindex == startidx do
						reservedindex = math.random(1,#xs)
					end

					for idx = 1,#xs do
						if idx ~= reservedindex and idx ~= endidx and idx ~= startidx then
							if types[idx] > 0 then
								obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[types[idx] ], add_fn, choices.rooms)
							else
								obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[-types[idx] ], add_fn, choices.bosses)
							end
						end
					end
					if choices.archive.keyroom then
						obj_layout.Place({xs[reservedindex], ys[reservedindex]}, "SINGLE_NORTH", add_fn, choices.archive.keyroom)
					end

					local closest_index = distances[1].idx
					local x, y = xs[closest_index], ys[closest_index]
					local s_x, s_y = WorldSim:GetSite(topology_save.GlobalTags["MazeEntrance"][task][1])

					WorldSim:DrawGroundLine( x, y, s_x, s_y, WORLD_TILES.DIRT, true, true)
					WorldSim:DrawGroundLine( x+2, y+2, x-2, y-2, WORLD_TILES.DIRT, true, true)
					WorldSim:DrawGroundLine( x-2, y+2, x+2, y-2, WORLD_TILES.DIRT, true, true)

 					-- ARCHIVE SEALS
					local x_diff = s_x - x
					local y_diff = s_y - y
					local incx = (x_diff/2) *TILE_SCALE
					local incz = (y_diff/2) *TILE_SCALE

					local newx = x
					local newz = y

					newx = (newx - map_width/2.0)*TILE_SCALE --gjans: note the +1.5 instead of +0.5... RunMaze points are in a strange position.
					newz = (newz - map_height/2.0)*TILE_SCALE

					if not entities["rubble1"] then
						entities["rubble1"] = {}
					end
					if not entities["rubble2"] then
						entities["rubble2"] = {}
					end

					newx = newx + incx/2 -- /10
					newz = newz + incz/2 -- /10
					table.insert(entities["rubble1"],{ x = newx, z = newz })
					table.insert(entities["rubble2"],{ x = newx, z = newz })
--[[
					--for i=1,10 do
						newx = newx + incx -- /10
						newz = newz + incz -- /10
						table.insert(entities["rubble1"],{ x = newx, z = newz })
						table.insert(entities["rubble2"],{ x = newx, z = newz })
					--end
	]]
				elseif choices.special ~= nil then
					local ends = {}
					for _,d in ipairs(distances) do
						local maze_room = math.abs(types[d.idx])
						if maze_room == 1 or maze_room == 2 or maze_room == 4 or maze_room == 8 then
							table.insert(ends, d.idx)
						end
					end

					for idx = 1,#xs do
						if idx == ends[1] or idx == ends[#ends] then
							-- skip
						elseif types[idx] > 0 then
							obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[types[idx] ], add_fn, choices.rooms)
						else
							obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[-types[idx] ], add_fn, choices.bosses)
						end
					end

					local idx = ends[1]
					obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[math.abs(types[idx])], add_fn, choices.special.start)
					idx = ends[#ends]
					obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[math.abs(types[idx])], add_fn, choices.special.finish)
				else
					types[distances[1].idx] = MAZE_CELL_EXITS.FOUR_WAY
					for idx = 1,#xs do
						if types[idx] > 0 then
							obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[types[idx] ], add_fn, choices.rooms)
						else
							obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[-types[idx] ], add_fn, choices.bosses)
						end
					end
				end

                -- The maze can cut itself off from land at the edge, so draw a little road to attempt to bring it together.
                for i,node in ipairs(topology_save.GlobalTags["MazeEntrance"][task]) do
                    local entrance_node = topology_save.root:GetNodeById(node)
                    for id, edge in pairs(entrance_node.edges) do
                        if edge.node1.data.type ~= NODE_TYPE.Blank and edge.node2.data.type ~= NODE_TYPE.Blank then
                            WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, choices.bridge_ground or WORLD_TILES.BRICK, nil, true)

                            -- If the maze is force disconnected then double make sure that the maze is connected with the fake ground
                            local othernode = edge.node1 == entrance_node and edge.node2 or edge.node1
                            if table.contains(othernode.data.tags, "ForceDisconnected") then
								for id, edge in pairs(othernode.edges) do
									if edge.node1.data.type ~= NODE_TYPE.Blank and edge.node2.data.type ~= NODE_TYPE.Blank then
										WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, WORLD_TILES.FAKE_GROUND, nil, true)
									end
								end
                            end
                        end
                    end
                end

			end
		end
    end

    print("Populating voronoi...")

	topology_save.root:GlobalPrePopulate(entities, map_width, map_height)
    topology_save.root:ConvertGround(SpawnFunctions, entities, map_width, map_height)
	WorldSim:ReplaceSingleNonLandTiles()

	if not story_gen_params.keep_disconnected_tiles then
	    local replace_count = WorldSim:DetectDisconnect()
		--allow at most 5% of tiles to be disconnected
		if replace_count > math.floor(map_width * map_height * 0.05) then
			print("PANIC: Too many disconnected tiles...",replace_count)
			if SKIP_GEN_CHECKS == false then
				return nil
			end
		else
			print("disconnected tiles...",replace_count)
		end
	else
		print("Not checking for disconnected tiles.")
	end

    save.map.generated = {}
    save.map.generated.densities = {}

    topology_save.root:PopulateVoronoi(SpawnFunctions, entities, map_width, map_height, translated_prefabs, save.map.generated.densities)
	if story_gen_params.has_ocean then
		local ocean_gen_config = require("map/ocean_gen_config")
		Ocean_SetWorldForOceanGen(WorldSim)
		Ocean_PlaceSetPieces(level.ocean_prefill_setpieces, add_fn, obj_layout, WORLD_TILES.IMPASSABLE, ocean_gen_config.ocean_prefill_setpieces_min_land_dist, save.map.topology, map_width, map_height)
--		local required_treasure_placed = WorldGenPlaceTreasures(topology_save.root:GetChildren(), entities, map_width, map_height, 4600000, level)
--		if not required_treasure_placed then
--			print("PANIC: Missing required treasure!")
--			if SKIP_GEN_CHECKS == false then
--				return nil
--			end
--		end
		Ocean_ConvertImpassibleToWater(map_width, map_height, ocean_gen_config)
		PopulateOcean(SpawnFunctions, entities, map_width, map_height, storygen.ocean_population, translated_prefabs, ocean_gen_config.ocean_prefill_setpieces_min_land_dist, save.map.topology)
        MonkeyIsland_GenerateDocks(WorldSim, entities, map_width, map_height)
	end
    topology_save.root:GlobalPostPopulate(entities, map_width, map_height)

    for k,ents in pairs(entities) do
        for i=#ents, 1, -1 do
            local x = ents[i].x/TILE_SCALE + map_width/2.0
            local y = ents[i].z/TILE_SCALE + map_height/2.0

            local tiletype = WorldSim:GetVisualTileAtPosition(x,y) -- Warning: This does not quite work as expected. It thinks the ground type id is in rendering order, which it totally is not!
            if TileGroupManager:IsImpassableTile(tiletype) then
				print("Removing entity on IMPASSABLE", k, x, y, ""..ents[i].x..", 0, "..ents[i].z)
                table.remove(entities[k], i)
            end
        end
    end

    if translated_prefabs ~= nil then
        -- Filter out any etities over our overrides
        for prefab,mult in pairs(translated_prefabs) do
            if type(mult) == "number" and mult < 1 and entities[prefab] ~= nil and #entities[prefab] > 0 then
                local new_amt = math.floor(#entities[prefab]*mult)
                if new_amt == 0 then
                    entities[prefab] = nil
                else
                    entities[prefab] = shuffleArray(entities[prefab])
                    while #entities[prefab] > new_amt do
                        table.remove(entities[prefab], 1)
                    end
                end
            end
        end
    end

  	BunchSpawnerInit(entities, map_width, map_height)
	BunchSpawnerRun(WorldSim)

	AncientArchivePass(entities, map_width, map_height, WorldSim)

    local double_check = {}
    for i, prefab in ipairs(level.required_prefabs or {}) do
		if not translated_prefabs or translated_prefabs[prefab] ~= 0 then
			if double_check[prefab] == nil then
				double_check[prefab] = 1
			else
				double_check[prefab] = double_check[prefab] + 1
			end
		end
    end
    for prefab, count in pairs(topology_save.root:GetRequiredPrefabs()) do
		if not translated_prefabs or translated_prefabs[prefab] ~= 0 then
			if double_check[prefab] == nil then
				double_check[prefab] = count
			else
				double_check[prefab] = double_check[prefab] + count
			end
		end
    end
    if storygen.ocean_population ~= nil then
        for _, ocean_room in pairs(storygen.ocean_population) do
            if ocean_room.data ~= nil and ocean_room.data.required_prefabs ~= nil then
                for _, prefab in ipairs(ocean_room.data.required_prefabs) do
					if not translated_prefabs or translated_prefabs[prefab] ~= 0 then
						if double_check[prefab] == nil then
							double_check[prefab] = 1
						else
							double_check[prefab] = double_check[prefab] + 1
						end
					end
                end
            end
        end
    end

    for prefab,count in pairs(double_check) do
		print ("Checking Required Prefab " .. prefab .. " has at least " .. count .. " instances (" .. (entities[prefab] ~= nil and #entities[prefab] or 0) .. " found).")
		
        if entities[prefab] == nil or #entities[prefab] < count then
			if level.overrides[prefab] == "never" then
				print(string.format(" - missing required prefab [%s] was disabled in the world generation options!", prefab))
			else
				print(string.format("PANIC: missing required prefab [%s]! Expected %d, got %d", prefab, count, entities[prefab] == nil and 0 or #entities[prefab]))
				if SKIP_GEN_CHECKS == false then
					return nil
				end
			end
        end
    end

    save.ents = entities

    save.map.tiles, save.map.tiledata, save.map.nav, save.map.adj, save.map.nodeidtilemap = WorldSim:GetEncodedMap(join_islands)
	save.map.world_tile_map = GetWorldTileMap()

    save.map.topology.overrides = deepcopy(current_gen_params)
    if save.map.topology.overrides == nil then
        save.map.topology.overrides = {}
	end

	save.map.width, save.map.height = map_width, map_height

	local start_season = current_gen_params.season_start or "autumn"
	if string.find(start_season, "|", nil, true) then
		start_season = GetRandomItem(string.split(start_season, "|"))
	elseif start_season == "default" then
		start_season = DEFAULT_SEASON
	end

	local componentdata = SEASONS[start_season](start_season)

	if save.world_network == nil then
		save.world_network = {persistdata = {}}
	elseif save.world_network.persistdata == nil then
		save.world_network.persistdata = {}
	end

	for k, v in pairs(componentdata) do
		save.world_network.persistdata[k] = v
	end

	if (save.ents.spawnpoint_multiplayer == nil or #save.ents.spawnpoint_multiplayer == 0)
        and (save.ents.multiplayer_portal == nil or #save.ents.multiplayer_portal == 0)
        and (save.ents.quagmire_portal == nil or #save.ents.quagmire_portal == 0)
        and (save.ents.lavaarena_portal == nil or #save.ents.lavaarena_portal == 0) then
    	print("PANIC: No start location!")
    	if SKIP_GEN_CHECKS == false then
    		return nil
    	else
    		save.ents.spawnpoint={{x=0,y=0,z=0}}
    	end
    end

    save.map.roads = {}

    if current_gen_params.roads == nil or current_gen_params.roads ~= "never" then
        local num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(0, join_islands)
        local current_road = 1
        local min_road_length = math.random(3,5)
        --print("Building roads... Min Length:"..min_road_length, current_gen_params.roads)

        if #points_x>=min_road_length then
            save.map.roads[current_road] = {3}
            for current_pos_idx = 1, #points_x  do
                local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
                local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0

                table.insert(save.map.roads[current_road], {x, y})
            end
            current_road = current_road + 1
        end

        for current_road = current_road, num_roads  do

            num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(current_road-1, join_islands)

            if #points_x>=min_road_length then
                save.map.roads[current_road] = {road_weight}
                for current_pos_idx = 1, #points_x  do
                    local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
                    local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0

                    table.insert(save.map.roads[current_road], {x, y})
                end
            end
        end
    end

	print("Done "..prefab.." map gen!")

	return save
end

return {
    Generate = Generate,
	TRANSLATE_TO_PREFABS = TRANSLATE_TO_PREFABS,
	MULTIPLY = MULTIPLY,
	TRANSLATE_AND_OVERRIDE = TRANSLATE_AND_OVERRIDE,
	MULTIPLY_PREFABS = MULTIPLY_PREFABS,
	TRANSLATE_TO_CLUMP = TRANSLATE_TO_CLUMP,
	CLUMP = CLUMP,
	CLUMPSIZE = CLUMPSIZE,
	SEASONS = SEASONS,
	DEFAULT_SEASON = DEFAULT_SEASON,
}


