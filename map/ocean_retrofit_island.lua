require "constants"
require "mathutil"
require "map/terrain"

local obj_layout = require("map/object_layout")

local function AddSquareTopolopy(topology, left, top, size, room_id, tags)
	local index = #topology.ids + 1
	topology.ids[index] = room_id
	topology.story_depths[index] = 0

	local node = {}
	node.area = size * size
	node.c = 1 -- colour index
	node.cent = {left + (size / 2), top + (size / 2)}
	node.neighbours = {}
	node.poly = { {left, top},
				  {left + size, top},
				  {left + size, top + size},
				  {left, top + size}
				}
	node.tags  = tags
	node.type = NODE_TYPE.Default
	node.x = node.cent[1]
	node.y = node.cent[2]
	
	node.validedges = {}
	
	topology.nodes[index] = node
end

local function TurnOfTidesRetrofitting_MoonIsland(map, savedata)
	local obj_layout = require("map/object_layout")

	local topology = savedata.map.topology
	local map_width = savedata.map.width
	local map_height = savedata.map.height
	local entities = savedata.ents

	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset) 
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

	local function TryToAddLayout(name, area_size, topology_delta)
		topology_delta = topology_delta or 1
		local function isvalidarea(_left, _top)
			for x = 0, area_size do
				for y = 0, area_size do
					if not IsOceanTile(map:GetTile(_left + x, _top + y)) then
						return false
					end
				end
			end
			return true
		end

		local candidtates = {}
		local foundarea = false
		local num_steps = 50
		for x = 0, num_steps do
			for y = 0, num_steps do
				local left = 8 + (x > 0 and ((x * math.floor(map_width / num_steps)) - area_size - 16) or 0)
				local top  = 8 + (y > 0 and ((y * math.floor(map_height / num_steps)) - area_size - 16) or 0)
				if isvalidarea(left, top) then
					table.insert(candidtates, {top = top, left = left, distsq = VecUtil_LengthSq(left - map_width / 2, top - map_height / 2)})
				end
			end
		end

		if #candidtates > 0 then
			table.sort(candidtates, function(a, b) return a.distsq < b.distsq end)
			local top, left = candidtates[1].top, candidtates[1].left	

			obj_layout.Place({left, top}, name, add_fn, nil, map)
			local tags = {"moonhunt", "nohasslers", "lunacyarea", "not_mainland"}
			AddSquareTopolopy(topology, (left-topology_delta)*4 - (map_width * 0.5 * 4), (top-topology_delta)*4 - (map_height * 0.5 * 4), (area_size + (topology_delta*2))*4, "MoonIslandRetrofit:0:MoonIslandRetrofitRooms", tags)
		end
		return #candidtates > 0
	end

	local success = TryToAddLayout("retrofit_moonisland_large", 92, -3)
					or TryToAddLayout("retrofit_moonisland_medium", 50, 0)
					or TryToAddLayout("retrofit_moonisland_small", 20, 0)

	if success then
		print("Retrofitting for Return Of Them: Turn of Tides - Added moon island to the world.")
	else
		print("Retrofitting for Return Of Them: Turn of Tides - Failed to add moon island to the world!")
	end
end


return { TurnOfTidesRetrofitting_MoonIsland = TurnOfTidesRetrofitting_MoonIsland }