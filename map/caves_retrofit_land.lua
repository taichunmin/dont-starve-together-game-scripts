require "constants"
require "mathutil"
require "map/terrain"

local obj_layout = require("map/object_layout")

local function FindOpenArea(map, map_width, map_height, tiles_wide, tiles_high)
	local function isvalidarea(map, _left, _top)
		for x = 0, tiles_wide do
			for y = 0, tiles_high do
				if map:GetTile(_left + x, _top + y) ~= GROUND.IMPASSABLE then
					return false
				end
			end
		end
		return true
	end

	local padding = 2-- we don't want to start right on the edge of the world
	local top, left = padding, padding

	local step_size = 5
	local num_steps = math.floor((map_width - 2*padding)/step_size)
	for x = 0, num_steps do
		for y = 0, num_steps do
			if isvalidarea(map, left, top) then
				return true, top, left
			end
			top = top + step_size
		end
		top = padding
		left = left + step_size
	end
	return false
end

local function AddTopologyData(topology, left, top, width, height, room_id, tags)
	local index = #topology.ids + 1
	topology.ids[index] = room_id
	topology.story_depths[index] = 0

	local node = {}
	node.area = width * height
	node.c = 1 -- colour index
	node.cent = {left + (width / 2), top + (height / 2)}
	node.neighbours = {}
	node.poly = { {left, top},
				  {left + width, top},
				  {left + width, top + height},
				  {left, top + height}
				}
	node.tags  = tags
	node.type = NODE_TYPE.Default
	node.x = node.cent[1]
	node.y = node.cent[2]

	node.validedges = {}

	topology.nodes[index] = node

	return index
end

local function AddTileNodeIdsForArea(world_map, node_index, left, top, width, height)
	for x = left, left + width do
		for y = top, top + height do
			world_map:SetTileNodeId(x, y, node_index)
		end
	end
end

local function add_fn_fn(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
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
end

local function ReturnOfThemRetrofitting_AcientArchives(world_map, savedata)
	local obj_layout = require("map/object_layout")

	local topology = savedata.map.topology
	local map_width = savedata.map.width
	local map_height = savedata.map.height
	local entities = savedata.ents

	local add_fn = {fn=add_fn_fn, args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}}

	local maze_width, maze_height = 4+2, 4+1 -- leave a 1 maze size perimeter
	local maze_tiles_size = 8
	local mush_area_size = 38

	local foundarea, top, left = FindOpenArea(world_map, map_width, map_height, maze_width * maze_tiles_size, maze_height * maze_tiles_size + mush_area_size) -- +32 for the moon mush area
	if foundarea then
		local maze = {	{ "L_NORTH",		"L_EAST",			"L_NORTH",		"" },
						{ "SINGLE_WEST",	"THREE_WAY_W",		"THREE_WAY_E",	"SINGLE_EAST" },
						{ "",				"L_SOUTH",			"THREE_WAY_W",	"FOUR_WAY" },
						{ "L_WEST",			"SINGLE_SOUTH",		"",				"SINGLE_WEST" } }

		for x = 1, 4 do
			for y = 1, 4 do
				if maze[x][y] ~= "" then
					obj_layout.Place({left + (x*maze_tiles_size), top + (y*maze_tiles_size)}, maze[x][y], add_fn, {"archive_hallway", "archive_hallway_two"}, world_map)
				end
			end
		end

		obj_layout.Place({left + (3*8), top + (1*8)}, "SINGLE_SOUTH", add_fn, {"archive_keyroom"}, world_map)
		obj_layout.Place({left + (1*8), top + (4*8)}, "SINGLE_SOUTH", add_fn, {"archive_start"}, world_map)
		obj_layout.Place({left + (4*8), top + (3*8)}, "SINGLE_WEST", add_fn, {"archive_end"}, world_map)

		local topology_width = ((maze_width-2) * maze_tiles_size)
		local topology_height = ((maze_height-1) * maze_tiles_size)

		local topology_node_index

		local tags = {}
		topology_node_index = AddTopologyData(topology, (left + maze_tiles_size + 0.5)*TILE_SCALE - (map_width * 0.5 * TILE_SCALE), (top + maze_tiles_size + 0.5)*TILE_SCALE - (map_height * 0.5 * TILE_SCALE), topology_width*TILE_SCALE, topology_height*TILE_SCALE, "AncientArchivesRetrofit:0:Archives", tags)
		AddTileNodeIdsForArea(world_map, topology_node_index, left + maze_tiles_size + 1, top + maze_tiles_size + 1, topology_width - 1, topology_height - 1)

		left = left + math.floor(maze_tiles_size/2)
		top = top + maze_height * maze_tiles_size

		obj_layout.Place({left, top}, "retrofit_moonmush", add_fn, nil, world_map)

		topology_width = mush_area_size
		topology_height = mush_area_size

		local blue_mush_height = 7
		tags = {}
		topology_node_index = AddTopologyData(topology, (left + 0.5)*TILE_SCALE - (map_width * 0.5 * TILE_SCALE), (top + 0.5)*TILE_SCALE - (map_height * 0.5 * TILE_SCALE), blue_mush_height*TILE_SCALE, topology_height*TILE_SCALE, "AncientArchivesRetrofit:1:MoonMush", tags)
		AddTileNodeIdsForArea(world_map, topology_node_index, left + 1, top + 1, blue_mush_height-1, topology_height-1)

		left = left + blue_mush_height
		topology_width = topology_width - blue_mush_height

		local bridge_width = 6
		tags = {}
		topology_node_index = AddTopologyData(topology, (left + 0.5)*TILE_SCALE - (map_width * 0.5 * TILE_SCALE), (top + 0.5)*TILE_SCALE - (map_height * 0.5 * TILE_SCALE), topology_width*TILE_SCALE, bridge_width*TILE_SCALE, "AncientArchivesRetrofit:3:Bridge", tags)
		AddTileNodeIdsForArea(world_map, topology_node_index, left + 1, top + 1, topology_width-1, bridge_width-1)

		top = top + bridge_width
		topology_height = topology_height - bridge_width

		tags = {"lunacyarea", "GrottoWarEntrance"}
		topology_node_index = AddTopologyData(topology, (left + 0.5)*TILE_SCALE - (map_width * 0.5 * TILE_SCALE), (top + 0.5)*TILE_SCALE - (map_height * 0.5 * TILE_SCALE), topology_width*TILE_SCALE, topology_height*TILE_SCALE, "AncientArchivesRetrofit:2:MoonMush", tags)
		AddTileNodeIdsForArea(world_map, topology_node_index, left + 1, top + 1, topology_width-1, topology_height-1)

		print ("Retrofitting for Return of Them: Forgotten Knowledge - Successfully added archives into the world.")
	else
		print ("Retrofitting for Return of Them: Forgotten Knowledge - FAILED! Could not find anywhere to add the archives into the world.")
	end
end

return {
	ReturnOfThemRetrofitting_AcientArchives = ReturnOfThemRetrofitting_AcientArchives,
}