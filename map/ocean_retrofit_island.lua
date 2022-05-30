require "constants"
require "mathutil"
require "map/terrain"

local obj_layout = require("map/object_layout")

local function FindEntsInArea(entities, left, top, size, blocking_prefabs)
	local right, bottom = left + size, top + size

	local ents_in_area = {}
	for prefab, ents in pairs(entities) do
		for i, e in ipairs(ents) do
			if e.x > left and e.x < right and e.z > top and e.z < bottom then
				if table.contains(blocking_prefabs, prefab) then
					return nil
				end
				table.insert(ents_in_area, {prefab = prefab, index = i})
			end
		end
	end

	return ents_in_area
end

local function AddSquareTopology(topology, left, top, size, room_id, tags)
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
			AddSquareTopology(topology, (left-topology_delta)*4 - (map_width * 0.5 * 4), (top-topology_delta)*4 - (map_height * 0.5 * 4), (area_size + (topology_delta*2))*4, "MoonIslandRetrofit:0:MoonIslandRetrofitRooms", tags)
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

local function TurnOfTidesRetrofitting_HermitIsland(map, savedata)
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

	local function is_rough_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				if map:GetTile(_left + x, _top + y) ~= GROUND.OCEAN_ROUGH then
					return false
				end
			end
		end
		return true
	end
	local function is_swell_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				if map:GetTile(_left + x, _top + y) ~= GROUND.OCEAN_SWELL then
					return false
				end
			end
		end
		return true
	end
	local function is_rough_or_swell_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				local tile = map:GetTile(_left + x, _top + y)
				if tile ~= GROUND.OCEAN_ROUGH and tile ~= GROUND.OCEAN_SWELL then
					return false
				end
			end
		end
		return true
	end

	local function TryToAddLayout(name, topology_delta, isvalidareafn)
	    local layout = obj_layout.LayoutForDefinition(name)
		local tile_size = #layout.ground

		topology_delta = topology_delta or 1

		local candidtates = {}
		local foundarea = false
		local num_steps = math.floor((map_width - tile_size) / tile_size)
		for x = 0, num_steps do
			for y = 0, num_steps do
				local left = 8 + (x > 0 and ((x * math.floor(map_width / num_steps)) - tile_size - 16) or 0)
				local top  = 8 + (y > 0 and ((y * math.floor(map_height / num_steps)) - tile_size - 16) or 0)
				if isvalidareafn(left, top, tile_size) then
					table.insert(candidtates, {top = top, left = left})
				end
			end
		end
		print("   " ..tostring(#candidtates) .. " candidtate locations")

		if #candidtates > 0 then
			local world_size = (tile_size + (topology_delta*2))*4

			shuffleArray(candidtates)
			for _, candidtate in ipairs(candidtates) do
				local top, left = candidtates[1].top, candidtates[1].left
				local world_top, world_left = (left-topology_delta)*4 - (map_width * 0.5 * 4), (top-topology_delta)*4 - (map_height * 0.5 * 4)

				local ents_to_remove = FindEntsInArea(savedata.ents, world_top - 5, world_left - 5, world_size + 10, {"boat", "malbatross", "oceanfish_shoalspawner", "chester_eyebone", "glommerflower", "klaussackkey", "crabking", "oceantree", "waterplant_base"})
				if ents_to_remove ~= nil then
					print("   Removed " .. tostring(#ents_to_remove) .. " entities for static layout:")
					for i = #ents_to_remove, 1, -1 do
						print ("   - " .. tostring(ents_to_remove[i].prefab) .. " " )
						table.remove(savedata.ents[ents_to_remove[i].prefab], ents_to_remove[i].index)
					end

					obj_layout.Place({left, top}, name, add_fn, nil, map)
					if layout.add_topology ~= nil then
						AddSquareTopology(topology, world_top, world_left, world_size, layout.add_topology.room_id, layout.add_topology.tags)
					end

					return true
				end
			end
		end
		return false
	end

    print("Retrofitting for Return Of Them: She Sells Seashells - Adding HermitIsland")
	local success = TryToAddLayout("HermitcrabIsland", 0, is_rough_ocean)
					or TryToAddLayout("HermitcrabIsland", 0, is_rough_or_swell_ocean)
	if success then
		print("Retrofitting for Return Of Them: She Sells Seashells - Added HermitcrabIsland to the world.")
	else
		print("Retrofitting for Return Of Them: She Sells Seashells - Failed to add HermitcrabIsland to the world!")
	end

    print("Retrofitting for Return Of Them: She Sells Seashells - Adding CrabKing")
	local success = TryToAddLayout("CrabKing", 0, is_swell_ocean)
					or TryToAddLayout("CrabKing", 0, is_rough_or_swell_ocean)
	if success then
		print("Retrofitting for Return Of Them: She Sells Seashells - Added CrabKing to the world.")
	else
		print("Retrofitting for Return Of Them: She Sells Seashells - Failed to add CrabKing to the world!")
	end
end


local function WaterloggedRetrofitting_WaterlogSetpiece(map, savedata, max_count)
	max_count = max_count or 3
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

	local function is_rough_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				if map:GetTile(_left + x, _top + y) ~= GROUND.OCEAN_ROUGH then
					return false
				end
			end
		end
		return true
	end
	local function is_swell_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				if map:GetTile(_left + x, _top + y) ~= GROUND.OCEAN_SWELL then
					return false
				end
			end
		end
		return true
	end
	local function is_rough_or_swell_ocean(_left, _top, tile_size)
		for x = 0, tile_size do
			for y = 0, tile_size do
				local tile = map:GetTile(_left + x, _top + y)
				if tile ~= GROUND.OCEAN_ROUGH and tile ~= GROUND.OCEAN_SWELL then
					return false
				end
			end
		end
		return true
	end

	local function TryToAddLayout(name, topology_delta, isvalidareafn)
	    local layout = obj_layout.LayoutForDefinition(name)
		local tile_size = #layout.ground

		topology_delta = topology_delta or 1

		local candidtates = {}
		local foundarea = false
		local num_steps = math.floor((map_width - tile_size) / tile_size)
		for x = 0, num_steps do
			for y = 0, num_steps do
				local left = 8 + (x > 0 and ((x * math.floor(map_width / num_steps)) - tile_size - 16) or 0)
				local top  = 8 + (y > 0 and ((y * math.floor(map_height / num_steps)) - tile_size - 16) or 0)
				if isvalidareafn(left, top, tile_size) then
					table.insert(candidtates, {top = top, left = left})
				end
			end
		end
		print("   " ..tostring(#candidtates) .. " candidtate locations")

		if #candidtates > 0 then
			local world_size = (tile_size + (topology_delta*2))*4

			shuffleArray(candidtates)
			for _, candidtate in ipairs(candidtates) do
				local top, left = candidtates[1].top, candidtates[1].left
				local world_top, world_left = (left-topology_delta)*4 - (map_width * 0.5 * 4), (top-topology_delta)*4 - (map_height * 0.5 * 4)

				local ents_to_remove = FindEntsInArea(savedata.ents, world_top - 5, world_left - 5, world_size + 10, {"boat", "malbatross", "oceanfish_shoalspawner", "chester_eyebone", "glommerflower", "klaussackkey"})
				if ents_to_remove ~= nil then
					print("   Removed " .. tostring(#ents_to_remove) .. " entities for static layout:")
					for i = #ents_to_remove, 1, -1 do
						print ("   - " .. tostring(ents_to_remove[i].prefab) .. " " )
						table.remove(savedata.ents[ents_to_remove[i].prefab], ents_to_remove[i].index)
					end

					obj_layout.Place({left, top}, name, add_fn, nil, map)
					if layout.add_topology ~= nil then
						AddSquareTopology(topology, world_top, world_left, world_size, layout.add_topology.room_id, layout.add_topology.tags)
					end

					return true
				end
			end
		end
		return false
	end
	for i=1, max_count do 
	    print("Retrofitting for Return Of Them: Watterlogged - Adding Waterlog biome "..i)
		local success
		for j = 1, 4 do
			success = TryToAddLayout("Waterlogged"..j, 0, is_rough_ocean) or TryToAddLayout("Waterlogged"..j, 0, is_rough_or_swell_ocean)
			if success then break end
		end
		if success then
			print("Retrofitting for Return Of Them: Waterlogged - Added Waterlog setpiece "..i.." to the world.")
		else
			print("Retrofitting for Return Of Them: Waterlogged - Failed to add Waterlog setpiece "..i.." to the world!")
		end
	end
end


return {
	TurnOfTidesRetrofitting_MoonIsland = TurnOfTidesRetrofitting_MoonIsland,
	TurnOfTidesRetrofitting_HermitIsland = TurnOfTidesRetrofitting_HermitIsland,
	WaterloggedRetrofitting_WaterlogSetpiece = WaterloggedRetrofitting_WaterlogSetpiece,
}