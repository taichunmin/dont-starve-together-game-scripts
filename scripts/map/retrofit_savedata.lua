

local function TryToAddLayout(name, num, isvalidtile, savedata, world_map, valid_spawn_position)
	local layouts = require("map/object_layout")
    local layout = layouts.LayoutForDefinition(name)

	local map_width = savedata.map.width
	local map_height = savedata.map.height

	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
			local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
			local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
			x = math.floor(x*100)/100.0
			y = math.floor(y*100)/100.0
			if valid_spawn_position ~= nil and not valid_spawn_position(x, y, prefab) then
				return
			end
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
		args={entitiesOut=savedata.ents, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
	}

	local function isvalidarea(_left, _top, size, map)
		for x = 0, size do
			for y = 0, size do
				local tile = map:GetTile(_left + x, _top + y)
				if not isvalidtile(tile) then
					return false
				end
			end
		end
		return true
	end

	local candidtates = {}
	local layout_size = #layout.ground
	local num_steps = map_width / (layout_size + 1)

	for x = 0, num_steps do
		for y = 0, num_steps do
			local left = 8 + (x > 0 and ((x * math.floor(map_width / num_steps)) - layout_size - 16) or 0)
			local top  = 8 + (y > 0 and ((y * math.floor(map_height / num_steps)) - layout_size - 16) or 0)
			if isvalidarea(left, top, layout_size, world_map) then
				table.insert(candidtates, {top = top, left = left})
			end
		end
	end

	if #candidtates > 0 then
		shuffleArray(candidtates)
		for i = 1, math.min(num, #candidtates) do
			layouts.Place({candidtates[i].left, candidtates[i].top}, name, add_fn, nil, world_map)
		end
	end
	return {success = #candidtates >= num, num_added = math.min(#candidtates, num)}
end

local function FixNoBrinePools(savedata, world_map)
	local function HasBrinePool(width, height)
		for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
			for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
				if world_map:GetTile(x, y) == WORLD_TILES.OCEAN_BRINEPOOL then
					return true
				end
			end
		end
	end

	local function NoBoatCheck(x, z, prefab)
		if prefab == "saltstack" and GetTableSize(savedata.ents["boat"]) > 0 then
			for _, ent in pairs(savedata.ents["boat"]) do
				if VecUtil_LengthSq(ent.x - x, ent.z - z) < 4.25*4.25 then
					return false
				end
			end
		end
		return true
	end

	local map_width = savedata.map.width
	local map_height = savedata.map.height

	local num_saltstacks = GetTableSize(savedata.ents["saltstack"])
	local num_cookiecutterspawners = GetTableSize(savedata.ents["cookiecutter_spawner"])

	if num_cookiecutterspawners <= 4 or num_saltstacks <= 20 then
		print("Retrofitting for Return Of Them: Brine Pools Fixup - Not enough cookie cutters or salt formations. Repopulating Brine Pools...")
		savedata.ents["saltstack"] = {}
		savedata.ents["cookiecutter_spawner"] = {}
		savedata.ents["cookiecutter"] = {}

		local has_brinepools = HasBrinePool(map_width, map_height)
		if has_brinepools then
			print("Retrofitting for Return Of Them: Brine Pool Fixup - Brine Pool tiles found, populating with layouts...")
			local function isbrinepooltile(tile) return tile == WORLD_TILES.OCEAN_BRINEPOOL end
			local num_layouts_added = 0
			num_layouts_added = num_layouts_added + TryToAddLayout("retrofit_brinepool_tiny", 20, isbrinepooltile, savedata, world_map, NoBoatCheck).num_added

			num_saltstacks = GetTableSize(savedata.ents["saltstack"])
			num_cookiecutterspawners = GetTableSize(savedata.ents["cookiecutter_spawner"])

			print("Retrofitting for Return Of Them: Brine Pools Fixup - Added " .. tostring(num_layouts_added) .. " of 20 Brine Pools (".. tostring(num_cookiecutterspawners) .. " 'cookiecutter_spawner' and " .. tostring(num_saltstacks) .. " 'saltstack' prefabs)")

			local extra_brine_pools_required = 8 - math.floor(num_layouts_added/2) -- /2 because the retrofitted layouts are so small
			if extra_brine_pools_required > 0 then
				local function isopenoceantile(tile) return tile == WORLD_TILES.OCEAN_ROUGH or tile == WORLD_TILES.OCEAN_SWELL end
				print("Retrofitting for Return Of Them: Brine Pools Fixup - Brine pools are not dence enough, adding some more...")
				local num_extras_added = TryToAddLayout("BrinePool1", extra_brine_pools_required, isopenoceantile, savedata, world_map, NoBoatCheck).num_added
				num_saltstacks = GetTableSize(savedata.ents["saltstack"])
				num_cookiecutterspawners = GetTableSize(savedata.ents["cookiecutter_spawner"])
				print("Retrofitting for Return Of Them: Brine Pools Fixup - Added an extra " .. tostring(num_extras_added) .. " Brine Pools to the ocean (Total: ".. tostring(num_cookiecutterspawners) .. " 'cookiecutter_spawner' and " .. tostring(num_saltstacks) .. " 'saltstack' prefabs)")
				num_layouts_added = num_layouts_added + num_extras_added
			end
		else
			print("Retrofitting for Return Of Them: Brine Pools Fixup - No Brine Pools found, adding some now...")
			local function isvalidtile(tile) return tile == WORLD_TILES.OCEAN_ROUGH or tile == WORLD_TILES.OCEAN_SWELL end
			local num_layouts_added = 0
			num_layouts_added = num_layouts_added + TryToAddLayout("BrinePool1", 4, isvalidtile, savedata, world_map, NoBoatCheck).num_added
			num_layouts_added = num_layouts_added + TryToAddLayout("BrinePool2", 2, isvalidtile, savedata, world_map, NoBoatCheck).num_added
			num_layouts_added = num_layouts_added + TryToAddLayout("BrinePool3", 2, isvalidtile, savedata, world_map, NoBoatCheck).num_added

			num_saltstacks = GetTableSize(savedata.ents["saltstack"])
			num_cookiecutterspawners = GetTableSize(savedata.ents["cookiecutter_spawner"])

			print("Retrofitting for Return Of Them: Brine Pools Fixup - Added " .. tostring(num_layouts_added) .. " of 8 Brine Pools (".. tostring(num_cookiecutterspawners) .. " 'cookiecutter_spawner' and " .. tostring(num_saltstacks) .. " 'saltstack' prefabs)")
		end

		print ("Retrofitting for Return Of Them: Brine Pools Fixup - Finished adding missing brine pools.")
	else
		print ("Retrofitting for Return Of Them: Brine Pools Fixup - World has enough brine pools.")
	end

end

local function RepopulateNodeIdTileMap(world_map, savedata)
	for i = 1, #savedata.map.topology.nodes do
		local node = savedata.map.topology.nodes[i]
		world_map:RepopulateNodeIdTileMap(i, node.x, node.y, node.poly)
	end

	print ("Retrofitting for Return of Them: Forgotten Knowledge - Added Node Id's to the world.")
end




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local function DoRetrofitting(savedata, world_map)
	local dirty = false
	if savedata.retrofit_oceantiles then
		savedata.retrofit_oceantiles = nil

		print ("Retrofitting for Return Of Them: Turn of Tides - Converting Ocean...")
		Ocean_SetWorldForOceanGen(world_map)
		Ocean_ConvertImpassibleToWater(savedata.map.width, savedata.map.height, require("map/ocean_gen_config"))
		print ("Retrofitting for Return Of Them: Turn of Tides - Converting Ocean done")
		require("map/ocean_retrofit_island").TurnOfTidesRetrofitting_MoonIsland(TheWorld.Map, savedata)
		dirty = true
	end

	if savedata.retrofit_savedata_fixupbrinepools then
		savedata.retrofit_savedata_fixupbrinepools = nil
		print ("Retrofitting for Return Of Them: Brine Pools Fixup - Checking for missing brine pools...")
		FixNoBrinePools(savedata, world_map)
		dirty = true
	end

	if savedata.retrofit_shesellsseashells_hermitisland then
		savedata.retrofit_shesellsseashells_hermitisland = nil
		require("map/ocean_retrofit_island").TurnOfTidesRetrofitting_HermitIsland(TheWorld.Map, savedata)
		dirty = true
	end

	if savedata.retrofit_nodeidtilemap then
		savedata.retrofit_nodeidtilemap = nil
		RepopulateNodeIdTileMap(world_map, savedata)
		dirty = true
	end

	if savedata.retrofit_acientarchives then
		savedata.retrofit_acientarchives = nil
		require("map/caves_retrofit_land").ReturnOfThemRetrofitting_AcientArchives(TheWorld.Map, savedata)
		dirty = true
	end

	if savedata.retrofit_waterlogged_waterlog_setpiece then
		savedata.retrofit_waterlogged_waterlog_setpiece = nil
		require("map/ocean_retrofit_island").WaterloggedRetrofitting_WaterlogSetpiece(TheWorld.Map, savedata)
		dirty = true
	end

	if savedata.retrofit_waterlogged_waterlog_setpiece_retry then
		savedata.retrofit_waterlogged_waterlog_setpiece_retry = nil
		require("map/ocean_retrofit_island").WaterloggedRetrofitting_WaterlogSetpiece(TheWorld.Map, savedata, savedata.retrofit_waterlogged_waterlog_place_count)
		savedata.retrofit_waterlogged_waterlog_place_count = nil
		dirty = true
	end

	if savedata.retrofit_remove_ocean_brinepool_shore then
		savedata.retrofit_remove_ocean_brinepool_shore = nil
		world_map:Replace(WORLD_TILES.OCEAN_BRINEPOOL_SHORE, WORLD_TILES.OCEAN_BRINEPOOL)
	end

    if savedata.retrofit_moonquay_monkeyisland_setpiece then
        savedata.retrofit_moonquay_monkeyisland_setpiece = nil
        require("map/ocean_retrofit_island").CurseOfMoonQuayRetrofitting_MonkeyIsland(TheWorld.Map, savedata)
        dirty = true
    end

    if savedata.retrofit_junkyardv2_content then
        savedata.retrofit_junkyardv2_content = nil

        print("Retrofitting for Junk Yard: Removing fence_junk_pre_rotator instances.")
        savedata.ents["fence_junk_pre_rotator"] = nil
    end

	if dirty then
		savedata.map.tiles = world_map:GetStringEncode()
		savedata.map.nodeidtilemap = world_map:GetNodeIdTileMapStringEncode()

		-- if we could trigger a save here then we would not need to rest after
	end
end

return {DoRetrofitting = DoRetrofitting}