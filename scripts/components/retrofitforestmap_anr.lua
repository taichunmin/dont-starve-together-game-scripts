

--------------------------------------------------------------------------
--[[ RetrofitForestMap_ANR class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "RetrofitForestMapA_NR should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAX_PLACEMENT_ATTEMPTS = 50

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local retrofit_part1 = false


local STRUCTURE_TAGS = {"structure"}
local WALKABLEPLATFORM_TAGS = {"walkableplatform"}
local LAVA_TAGS = {"lava"}
local IMPORTANT_OBJECT_TAGS = {"irreplaceable", "playerghost", "ghost", "flying", "player", "character", "animal", "monster", "giant"}
local WATERSOURCE_TAGS = {"watersource"}
local THORNY_TAGS = {"thorny"}
local SCULPTURE_TAGS = {"sculpture"}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function RetrofitNewContentPrefab(inst, prefab, min_space, dist_from_structures, canplacefn, candidtate_nodes, on_add_prefab)
	local attempt = 1
	local topology = TheWorld.topology

	while attempt <= MAX_PLACEMENT_ATTEMPTS do
		local area = nil
		if candidtate_nodes ~= nil then
			area = candidtate_nodes[math.random(#candidtate_nodes)]
		else
			area = topology.nodes[math.random(#topology.nodes)]
		end

		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
		if #points_x == 1 and #points_y == 1 then
			local x = points_x[1]
			local z = points_y[1]

			if (canplacefn ~= nil and canplacefn(x, 0, z, prefab)) or
                (canplacefn == nil and TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, prefab)) then
				local ents = TheSim:FindEntities(x, 0, z, min_space)
				if #ents == 0 then
					if dist_from_structures ~= nil then
						ents = TheSim:FindEntities(x, 0, z, dist_from_structures, STRUCTURE_TAGS )
					end

					if #ents == 0 then
						local e = SpawnPrefab(prefab)
						e.Transform:SetPosition(x, 0, z)
						if on_add_prefab ~= nil then
							on_add_prefab(e)
						end
						break
					end
				end
			end
		end
		attempt = attempt + 1
	end
	print ("Retrofitting world for " .. prefab .. ": " .. (attempt <= MAX_PLACEMENT_ATTEMPTS and ("Success after "..attempt.." attempts.") or "Failed."))
	return attempt <= MAX_PLACEMENT_ATTEMPTS
end

local function RetrofitNewOceanContentPrefab(inst, width, height, prefab, min_space, dist_from_structures, canplacefn)
	local function dowork()
		local attempt = 1
		local topology = TheWorld.topology
		local world_width, world_width = width * TILE_SCALE, height * TILE_SCALE
		local start_x, start_y = math.random(width), math.random(0, height)
		local edge_dist = 8
		local tile_step = 7

		for zz = 1, height, tile_step do
			local z = ((start_y + zz) % height) + edge_dist
			z = z - (0.5*height) * TILE_SCALE
			for xx = 1, width, tile_step do
				local x = ((start_x + xx) % width) + edge_dist
				x = x - (0.5*width) * TILE_SCALE
				if canplacefn(x, 0, z, prefab) then
					local ents = TheSim:FindEntities(x, 0, z, min_space)
					if #ents == 0 then
						if dist_from_structures ~= nil then
							ents = TheSim:FindEntities(x, 0, z, dist_from_structures, STRUCTURE_TAGS )
						end

						if #ents == 0 then
							local e = SpawnPrefab(prefab)
							e.Transform:SetPosition(x, 0, z)
							return attempt
						end
					end
				end
				attempt = attempt + 1
			end
			attempt = attempt + 1
		end

		return nil
	end

	local attempts = dowork()
	print ("Retrofitting ocean for " .. prefab .. ": " .. (attempts ~= nil and ("Success after "..attempts.." attempts.") or "Failed."))
end

local function RemovePrefabs(prefabs_to_remove, biomes_to_cleanup)
	local count = 0
	for _,ent in pairs(Ents) do
		if ent:IsValid() and table.contains(prefabs_to_remove, ent.prefab) and (biomes_to_cleanup == nil or table.contains(biomes_to_cleanup, TheWorld.Map:GetTileAtPoint(ent.Transform:GetWorldPosition()))) then
			count = count + 1
			ent:Remove()
		end
	end

	return count
end

local function populate_ocean(tile_type, contents, width, height, on_spawnfn)
	for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
		for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
			if TheWorld.Map:GetTile(x, y) == tile_type then
				if math.random() < contents.distributepercent then
					local prefab = weighted_random_choice(contents.distributeprefabs)
					if prefab ~= nil then
						local obj = SpawnPrefab(prefab)
						obj.Transform:SetPosition((x - width/2.0)*TILE_SCALE + math.random()*2-1, 0, (y - height/2.0)*TILE_SCALE + math.random()*2-1)

						if on_spawnfn ~= nil then
							on_spawnfn(prefab, obj:GetPosition())
						end
					end
				end
			end
		end
	end
end

local function TurnOfTidesRetrofitting_PopulateOcean()
	local pop = {
		OCEAN_COASTAL =  {
			distributepercent = 0.01,
			distributeprefabs = {
				driftwood_log = 1,
				bullkelp_plant = 2,
			},
		},
		OCEAN_SWELL = {
			distributepercent = 0.01,
			distributeprefabs =
			{
				driftwood_log = 1,
				antchovies_group = 1,
				seastack = 1,
			},
		},
		OCEAN_ROUGH = {
			distributepercent = 0.03,
			distributeprefabs =
			{
				seastack = 1,
			},
		},
		OCEAN_HAZARDOUS = {
			distributepercent = 0.15,
			distributeprefabs =
			{
				boatfragment03 = 1,
				boatfragment04 = 1,
				boatfragment05 = 1,
				seastack = 1,
			},
		},
	}

	local width, height = TheWorld.Map:GetSize()
	for k, v in pairs(pop) do
		populate_ocean(WORLD_TILES[k], v, width, height)
	end

	print("Retrofitting for Return Of Them: Turn of Tides - Populated Ocean.")
end

local function TurnOfTidesRetrofitting_CleanupOceanPoution(inst)
	require "map/bunch_spawner"

	local items_to_remove = { "seastack", "antchovies_group", "driftwood_log" }
	local biomes_to_cleanup = { WORLD_TILES.OCEAN_SWELL, WORLD_TILES.OCEAN_ROUGH, WORLD_TILES.OCEAN_BRINEPOOL }

	local count = RemovePrefabs(items_to_remove, biomes_to_cleanup)
	count = count + RemovePrefabs(items_to_remove, biomes_to_cleanup)
	print ("Retrofitting for Turn of Tides Beta: Removed "..tostring(count).." ocean things.")


	local width, height = TheWorld.Map:GetSize()

	BunchSpawnerInit(nil, width, height)
	local function SpawnBoatingSafePrefab(prefab, x, z)
		if #TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4, WALKABLEPLATFORM_TAGS) == 0 then
			local obj = SpawnPrefab(prefab)
			obj.Transform:SetPosition(x, 0, z)
		end
	end

	local function populate(tile_type, contents)
		for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
			for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
				if TheWorld.Map:GetTile(x, y) == tile_type then
					if math.random() < contents.distributepercent then
						local spawn_x, spawn_z = (x - width/2.0)*TILE_SCALE + math.random()*2-1, (y - height/2.0)*TILE_SCALE + math.random()*2-1
						local prefab = weighted_random_choice(contents.distributeprefabs)
						if prefab ~= nil then
							if IsBunchSpawner( prefab ) then
								BunchSpawnerRunSingleBatchSpawner(TheWorld.Map, prefab, spawn_x, spawn_z, SpawnBoatingSafePrefab)
							else
								local obj = SpawnPrefab(prefab)
								obj.Transform:SetPosition(spawn_x, 0, spawn_z)
							end
						end
					end
				end
			end
		end
	end
	local pop = {
		OCEAN_SWELL = {
			distributepercent = 0.005,
			distributeprefabs =
			{
				seastack = 1,
				seastack_spawner_swell = 0.1,
			},
		},
		OCEAN_ROUGH = {
			distributepercent = 0.01,
			distributeprefabs =
			{
				seastack = 1,
				seastack_spawner_rough = 0.13,
			},
		},
	}

	for k, v in pairs(pop) do
		populate(WORLD_TILES[k], v)
	end

	print("Retrofitting for Return Of Them : Turn of Tides Beta - Repopulated Ocean.")
end

local function SaltyRetrofitting_PopulateShoalSpawner()
	local pop = {
		OCEAN_SWELL = {
			distributepercent = 0.0003,
			distributeprefabs =
			{
				oceanfish_shoalspawner = 1,
			},
		},
	}

	local width, height = TheWorld.Map:GetSize()
	for k, v in pairs(pop) do
		populate_ocean(WORLD_TILES[k], v, width, height)
	end
end


local function SaltyRetrofitting_PopulateBrinePools()
	require "map/bunch_spawner"

	local bunches = require "map/bunches"
	bunches.Bunches["SaltyRetrofitting_PopulateBrinePools"] =
	{
		prefab = "saltstack",
		range = 14,
		min = 4,
		max = 6,
		min_spacing = 3,
		valid_tile_types = {
			WORLD_TILES.OCEAN_BRINEPOOL,
		},
	}

	local num_spawners = 0
	local num_stacks = 0

	local width, height = TheWorld.Map:GetSize()
	BunchSpawnerInit(nil, width, height)

	local function SpawnBoatingSafePrefab(prefab, x, z)
		if #TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4, WALKABLEPLATFORM_TAGS) == 0 then
			local obj = SpawnPrefab(prefab)
			obj.Transform:SetPosition(x, 0, z)

			num_stacks = num_stacks + 1
		end
	end

	local function onspawn(prefab, pt)
		BunchSpawnerRunSingleBatchSpawner(TheWorld.Map, "SaltyRetrofitting_PopulateBrinePools", pt.x, pt.z, SpawnBoatingSafePrefab)
		num_spawners = num_spawners + 1
	end

	local pop = {
		OCEAN_BRINEPOOL = {
			distributepercent = 0.012,
			distributeprefabs =
			{
				cookiecutter_spawner = 1,
			},
		},
	}

	local width, height = TheWorld.Map:GetSize()
	for k, v in pairs(pop) do
		populate_ocean(WORLD_TILES[k], v, width, height, onspawn)
	end

	print("Retrofitting for Return Of Them: Salty Dog - Added " .. tostring(num_spawners) .. " 'cookiecutter_spawner' and " .. tostring(num_stacks) .. " 'saltstack' prefabs.")
end

local function SheSellsSeashellsRetrofitting_PopulateWobsterDens()
	require "map/bunch_spawner"
	local width, height = TheWorld.Map:GetSize()

	local count = 0

	BunchSpawnerInit(nil, width, height)
	local function SpawnBoatingSafePrefab(prefab, x, z)
		if #TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4, WALKABLEPLATFORM_TAGS) == 0 then
			local obj = SpawnPrefab(prefab)
			obj.Transform:SetPosition(x, 0, z)
			count = count + 1
		end
	end

	local function populate(tile_type, contents)
		for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
			for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
				if TheWorld.Map:GetTile(x, y) == tile_type then
					if math.random() < contents.distributepercent then
						local spawn_x, spawn_z = (x - width/2.0)*TILE_SCALE + math.random()*2-1, (y - height/2.0)*TILE_SCALE + math.random()*2-1
						local prefab = weighted_random_choice(contents.distributeprefabs)
						if prefab ~= nil then
							if IsBunchSpawner( prefab ) then
								BunchSpawnerRunSingleBatchSpawner(TheWorld.Map, prefab, spawn_x, spawn_z, SpawnBoatingSafePrefab)
							else
								local obj = SpawnPrefab(prefab)
								obj.Transform:SetPosition(spawn_x, 0, spawn_z)
							end
						end
					end
				end
			end
		end
	end
	local pop = {
		OCEAN_COASTAL_SHORE = {
			distributepercent = 0.005,
			distributeprefabs =
			{
				wobster_den_spawner_shore = 1,
			},
		},
	}

	for k, v in pairs(pop) do
		populate(WORLD_TILES[k], v)
	end

	print("Retrofitting for Return Of Them : She Sells Seashells - Added " .. tostring(count) .. " Wobster Dens.")
end

local function Barnacles_ReplaceSeastacks()
    require "map/bunch_spawner"

    local width, height = TheWorld.Map:GetSize()
    BunchSpawnerInit(nil, width, height)

    local seastack_swell_spawners = {}

    -- We know that seastack spawners can't be in the hermit space.
    -- However, we'd prefer not to spawn plants overlapping with the hermit island.
    -- Just using the house as an easy way to ID them
    local hermithouse = nil

    for _, ent in pairs(Ents) do
        if ent:IsValid() and ent.prefab then
            if ent.prefab == "seastack_spawner_rough" then
                -- NOTE: assume we don't have to test the tile, because the spawner is named as it is.
                table.insert(seastack_swell_spawners, ent)
            elseif hermithouse == nil and (ent.prefab:sub(1, 11) == "hermithouse") then
                hermithouse = ent
            end
        end
    end

    local plant_spawn_count = 0
    local function SpawnBoatingSafePrefab(prefab, x, z)
        if #TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4, WALKABLEPLATFORM_TAGS) == 0 then
            local obj = SpawnPrefab(prefab)
            obj.Transform:SetPosition(x, 0, z)
            plant_spawn_count = plant_spawn_count + 1
        end
    end

    local function spawn_waterplant_spawner_at(spawn_x, spawn_z)
        -- Spawn an actual spawner prefab here as well, because we may want to leverage it
        -- in the future, as this retrofit leverages the seastack ones.
        SpawnPrefab("waterplant_spawner_rough").Transform:SetPosition(spawn_x, 0, spawn_z)

        BunchSpawnerRunSingleBatchSpawner(
            TheWorld.Map,
            "waterplant_spawner_rough",
            spawn_x, spawn_z,
            SpawnBoatingSafePrefab
        )
    end

    -- IF #seastack_swell_spawners > 1 then
    --      replace 30%
    -- ELSE (can this actually happen?)
    --      do a regular bunch spawn for the waterplant spawners
    -- END

    local num_stack_swell_spawners = #seastack_swell_spawners
    if num_stack_swell_spawners > 1 then
        -- shuffle the stack spawners so we don't always just replace the ones near each other
        -- (since they're worldgenned, we expect their spawn to be ordered in some way)
        seastack_swell_spawners = shuffleArray(seastack_swell_spawners)

        -- Make a table to store the positions of stack spawners we're going to replace.
        local removed_stack_positions = {}

        -- Take the stack spawners we're going to replace, store their positions, and remove them.
        local num_plant_spawners = math.ceil(num_stack_swell_spawners * 0.3)
        for i=1,num_plant_spawners do
            local ss_spawner = seastack_swell_spawners[i]
            table.insert(removed_stack_positions, ss_spawner:GetPosition())
            ss_spawner:Remove()
        end

        -- Look for and delete every sea stack that's within a certain distance of
        -- our stored positions; this is an approximation for retrofitting, and precludes
        -- seastack overlaps, but is close to the worldgen version.
        for _, ent in pairs(Ents) do
            if ent:IsValid() and ent.prefab == "seastack" then
                local ex, ey, ez = ent.Transform:GetWorldPosition()
                for _, p in ipairs(removed_stack_positions) do
                    local xd, zd = p.x - ex, p.z - ez
                    local dsq = (xd * xd) + (zd * zd)

                    -- NOTE: 900 == 30 * 30; 30 is the range on the waterplant bunch spawner.
                    if dsq <= 900 then
                        ent:Remove()
                    end
                end
            end
        end

        -- Now that we've cleaned up the seastacks in the areas we're replacing,
        -- do the replacement!
        for _, p in ipairs(removed_stack_positions) do
            spawn_waterplant_spawner_at(p.x, p.z)
        end
    else
        local cx, cy, cz = nil, nil, nil
        if hermithouse ~= nil then
            cx, cy, cz = hermithouse.Transform:GetWorldPosition()
        end

        -- There's not enough seastack spawners to reliably replace...
        -- so let's just spawn new waterplant bunch spawners.
        -- Referencing terrain_ocean.lua, the spawn chance of waterplant spawners alone
        -- is 0.01 * (0.04 / (1.00 + 0.09 + 0.04)) ~= 0.000354.
        for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
            for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
                if TheWorld.Map:GetTile(x, y) == WORLD_TILES.OCEAN_ROUGH and
                        math.random() < 0.000354 then
                    local spawn_x = (x - width/2.0)*TILE_SCALE + math.random()*2-1
                    local spawn_z = (y - height/2.0)*TILE_SCALE + math.random()*2-1
                    if hermithouse == nil or distsq(spawn_x, spawn_z, cx, cz) > 900 then
                        spawn_waterplant_spawner_at(spawn_x, spawn_z)
                    end
                end
            end
        end
    end

    print("Retrofitting for Return Of Them: Troubled Waters - Added "..tostring(plant_spawn_count).." Barnacle Plants")
end

local function RepositionInaccessibleUnderwaterObjects()
	local sunken_objects_count = 0

	for _, ent in pairs(Ents) do
		if ent:IsValid() and ent.prefab == "underwater_salvageable" then
			if ent.components.winchtarget ~= nil then
				local sunken_object = ent.components.winchtarget:GetSunkenObject()
				local x, y, z = ent.Transform:GetWorldPosition()

				if sunken_object ~= nil  then
					ent.components.inventory:RemoveItem(sunken_object)
					sunken_object.Transform:SetPosition(x, y, z)

					local repositioned = false
					if sunken_object.components.submersible ~= nil then
						repositioned = sunken_object.components.submersible:OnLanded()
					end

					if repositioned and sunken_object ~= nil and sunken_object:IsValid() then
						local new_x, new_y, new_z = sunken_object.Transform:GetWorldPosition()
						print("Retrofitting for Return of Them: Forgotten Knowledge - Repositioning ", sunken_object, " from " .. x, z, "to", new_x, new_z)
					end
				end

				ent:Remove()

				sunken_objects_count = sunken_objects_count + 1
			end
		end
	end

	print("Retrofitting for Return of Them: Forgotten Knowledge - Validated positions of", sunken_objects_count, "sunken heavy objects.")
end

local function EyeOfTheStorm_RemoveExtraAltarPieces()
    local ALTAR_PIECES = {
        ["moon_altar_glass"] = true,
        ["moon_altar_seed"] = true,
        ["moon_altar_idol"] = true,
        ["moon_altar_icon"] = true,
        ["moon_altar_ward"] = true,
        ["moon_altar_crown"] = true,
    }

    local removed_pieces = 0
    for _, ent in pairs(Ents) do
        if ent:IsValid() and ent.prefab ~= nil then
            local prefab_name = ent.prefab
            if ALTAR_PIECES[prefab_name] ~= nil then
                local lx, ly, lz = ent.Transform:GetWorldPosition()
                if math.abs(lx) < 0.001 and math.abs(ly) < 0.001 and math.abs(lz) < 0.001 then
                    print("Retrofitting for Return of Them: Eye of the Storm - Removing erroneously placed Moon Altar piece around 0,0,0")
                    ent:Remove()

                    removed_pieces = removed_pieces + 1
                end
            end
        end
    end

    print("Retrofitting for Return of Them: Eye of the Storm - Removed", removed_pieces, "pieces around 0,0,0")
end

local function TerrariumChest_Retrofitting()
	if TheWorld.topology.overrides ~= nil and TheWorld.topology.overrides.terrariumchest == "never" then
		print("Retrofitting for Terraria: Terrarium Chest - Skipping due to overrides.terrariumchest")
		return
	end

	local node_indices = {}
	local candidtate_nodes = {}

	for i,v in ipairs(TheWorld.topology.ids) do
		if string.find(v, "BGForest") then
			table.insert(candidtate_nodes, TheWorld.topology.nodes[i])
		end
	end

	if #candidtate_nodes == 0 then
		print("Retrofitting for Terraria: Terrarium Chest - Failed to find any BGForest nodes!")
		return false
	end

	local function on_add_prefab(inst)
		inst:AddComponent("scenariorunner")
		inst.components.scenariorunner:SetScript("chest_terrarium")
		inst.components.scenariorunner:Run()
	end

	local forest_turf_fn = function(x, y, z, prefab)
		return TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.FOREST
	end

	if not RetrofitNewContentPrefab(inst, "terrariumchest", 2, 8, forest_turf_fn, candidtate_nodes, on_add_prefab) then -- first try a BGForest with a forest ground tile
		RetrofitNewContentPrefab(inst, "terrariumchest", 2, 4, nil, candidtate_nodes, on_add_prefab)
	end

end

--------------------------------------------------------------------------

local function CatcoonDen_Retrofitting()
	if TheWorld.topology.overrides ~= nil and TheWorld.topology.overrides.catcoon == "never" then		-- catcoon == catcoonden, catcoons = catcoon
		print("Retrofitting for Catcoon Den De-extinction: Skipping due to overrides.catcoon == never")
		return
	end

	local min_dens = 3

	-- see if we have enough catcoon dens
	local count = 0
	for _, ent in pairs(Ents) do
		if ent:IsValid() and ent.prefab == "catcoonden" then
			count = count + 1
			if count >= min_dens then
				print("Retrofitting for Catcoon Den De-extinction: Found enough Catcoon Dens in the world.")
				return
			end
		end
	end

	-- find the deciduous biome(s)
	local node_indices = {}
	local candidtate_nodes = {}

	for i,v in ipairs(TheWorld.topology.ids) do
		if string.find(v, "BGDeciduous") then
			table.insert(candidtate_nodes, TheWorld.topology.nodes[i])
		end
	end

	if #candidtate_nodes == 0 then
		print("Retrofitting for Catcoon Den De-extinction: Failed to find any BGDeciduous nodes!")
		return
	end

	local deciduous_turf_fn = function(x, y, z, prefab)
		return TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.DECIDUOUS
	end

	print("Retrofitting for Catcoon Den De-extinction: Found " .. tostring(count) .. " Catcoon Dens in the world. Adding "..tostring(min_dens - count) .. " more.")
	for i = count, min_dens-1 do
		if not RetrofitNewContentPrefab(inst, "catcoonden", 2, 8, deciduous_turf_fn, candidtate_nodes) then
			RetrofitNewContentPrefab(inst, "catcoonden", 2, 4, deciduous_turf_fn, candidtate_nodes)
		end
	end
end

local HAS_WATERSOURCE = {"watersource"}
local function MoonFissures()
	local moonfissures = {}

	for _, ent in pairs(Ents) do
		if ent:IsValid() and ent.prefab == "moon_fissure" then
			table.insert(moonfissures,ent)
		end
	end
	local options = {}
	for i, ent in ipairs(moonfissures) do
		local x,y,z = ent.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x,y,z, 12, HAS_WATERSOURCE)
		if #ents == 0 then
			table.insert(options,ent)
		end
	end
	if #options > 0 then
		for i, ent in ipairs(options) do
			local pos = Vector3(ent.Transform:GetWorldPosition())
			local startangle = math.random()*PI2
			local offset_a = FindWalkableOffset(pos, startangle, 12, 36, true, true) or FindWalkableOffset(pos, startangle, 15, 36, true, true) or FindWalkableOffset(pos, startangle, 9, 36, true, true)
			local offset_b = nil
			if offset_a then
				offset_b = FindWalkableOffset(pos, startangle+(PI/3), 12, 36, true, true) or FindWalkableOffset(pos, startangle, 15, 36, true, true) or FindWalkableOffset(pos, startangle, 9, 36, true, true)
			end
			if offset_b then
				local fissure_1 = SpawnPrefab("moon_fissure")
				fissure_1.Transform:SetPosition( pos.x+offset_a.x , 0 , pos.z+offset_a.z )

				local fissure_2 = SpawnPrefab("moon_fissure")
				fissure_2.Transform:SetPosition( pos.x+offset_b.x , 0 , pos.z+offset_b.z )
				print("Retrofitting: for Return of Them: Forgotten Knowledge - 2 Moon Fissures added ", pos.x+offset_a.x, pos.z+offset_a.z, ":", pos.x+offset_b.x, pos.z+offset_b.z)
				break
			end
		end
	else
		print("Retrofitting: for Return of Them: Forgotten Knowledge: No Moon Fissures added")
	end
end

local function AstralMarkers()

	local potential = {}
	for i, node in ipairs(TheWorld.topology.nodes) do
		if table.contains(node.tags, "ExitPiece") and not table.contains(node.tags, "lunacyarea") then
			table.insert(potential,node)
		end
	end

    for k,v in pairs(Ents) do
        if v.prefab == "moon_altar_astral_marker_1" or v.prefab == "moon_altar_astral_marker_2" then
        	print("Retrofitting: for Return of Them: Forgotten Knowledge: Astral Markets Exist")
    		return
        end
    end

	local potential_count = #potential

	local moon_altar_astral_marker_1 = false
	while moon_altar_astral_marker_1 == false do
		if potential_count == 0 then
			print("Retrofitting: for Return of Them: Forgotten Knowledge: No Astral Markers Added")
			return
		end
		local rand = potential_count == 1 and 1 or math.random(1,potential_count)
		local testnode = potential[rand]

		if TheWorld.Map:IsVisualGroundAtPoint(testnode.cent[1], 0, testnode.cent[2]) then
			local marker = SpawnPrefab("moon_altar_astral_marker_1")
			marker.Transform:SetPosition(testnode.cent[1], 0, testnode.cent[2])
			moon_altar_astral_marker_1 = true
			print("Retrofitting: for Return of Them: Forgotten Knowledge - Astral Marker added ", testnode.cent[1], 0, testnode.cent[2])
		end

		table.remove(potential,rand)
		potential_count = potential_count - 1
	end

	local moon_altar_astral_marker_2 = false
	while moon_altar_astral_marker_2 == false do
		if potential_count == 0 then
			print("Retrofitting: for Return of Them: Forgotten Knowledge: Second Astral Marker Not Added")
			return
		end
		local rand = potential_count == 1 and 1 or math.random(1,potential_count)
		local testnode = potential[rand]

		if TheWorld.Map:IsVisualGroundAtPoint(testnode.cent[1], 0, testnode.cent[2]) then
			local marker = SpawnPrefab("moon_altar_astral_marker_2")
			marker.Transform:SetPosition(testnode.cent[1], 0, testnode.cent[2])
			moon_altar_astral_marker_2 = true
			print("Retrofitting: for Return of Them: Forgotten Knowledge - Astral Marker added ", testnode.cent[1], 0, testnode.cent[2])
		end

		table.remove(potential,rand)
		potential_count = potential_count - 1
	end
end

--------------------------------------------------------------------------
--[[ Lightning Bluff Retrofit ]]
--------------------------------------------------------------------------

local function RetrofitAgainstTheGrain(area)
	local function FindAreas(candidtates)
		local lake_pt = nil
		for k,v in ipairs(candidtates) do
			local node = TheWorld.topology.nodes[v]
			local pt = Vector3(node.cent[1], 0, node.cent[2])
			if false and TheWorld.Map:IsPassableAtPoint(pt.x, pt.y, pt.z) then
				if lake_pt == nil then
					lake_pt = pt
				else
					return pt, lake_pt
				end
			elseif node.x ~= nil then
				pt.x, pt.z = node.x, node.y
				if TheWorld.Map:IsPassableAtPoint(pt.x, pt.y, pt.z) then
					if lake_pt == nil then
						lake_pt = pt
					else
						return pt, lake_pt
					end
				end
			end
		end

		return nil
	end

	print ("Retrofitting for Against the Grain: Trying to retrofit "..area..".")

	local node_indices = {}
	local candidtates = {}
	local lake_candidate = nil
	for k,v in ipairs(TheWorld.topology.ids) do
		if area == string.sub(v, 1, #area) then
			table.insert(node_indices, k)

			local node = TheWorld.topology.nodes[k]
			if string.find(v, "PondyGrass") then
				lake_candidate = k
			elseif not string.find(v, "HoundyBadlands") and (#(TheSim:FindEntities(node.cent[1], 0, node.cent[2], 30, LAVA_TAGS)) == 0) then
				table.insert(candidtates, k)
			end
		end
	end
	if #node_indices == 0 then
		print ("Retrofitting for Against the Grain: "..area.." task was not added to the world.")
		return false
	end
	if #candidtates < 2 then
		print ("Retrofitting for Against the Grain: "..area.." is too small to retrofit.")
		return false
	end

	shuffleArray(candidtates)

	local shortlist = {}
	for k,v in ipairs(candidtates) do
		local node = TheWorld.topology.nodes[v]
		if #(TheSim:FindEntities(node.cent[1], 0, node.cent[2], 20, STRUCTURE_TAGS)) < 3 then
			table.insert(shortlist, v)
		end
	end
	if lake_candidate ~= nil then
		table.insert(shortlist, 1, lake_candidate)
		table.insert(candidtates, 1, lake_candidate)
	end

	print ("Retrofitting for Against the Grain: " .. tostring(#node_indices) .. " nodes, " .. tostring(#candidtates) .. " canidates, ".. tostring(#shortlist).." short listed.")

	local antlion_pt, lake_pt = FindAreas(shortlist)
	if antlion_pt == nil then
		print "Retrofitting for Against the Grain: All nodes have structures."
		antlion_pt, lake_pt = FindAreas(candidtates)
	end
	if antlion_pt == nil then
		print "Retrofitting for Against the Grain: Failed to find a location for the antlion and oasis lake."
		return
	end

	print ("Retrofitting for Against the Grain: "..area.." will be retorfitted to include Lightning Bluff.")

	-- Add standstorm node tag to all of the oasis
	for k,v in ipairs(node_indices) do
		if not table.contains(TheWorld.topology.nodes[v].tags, "sandstorm") then
			if TheWorld.topology.nodes[v].tags == nil then
				TheWorld.topology.nodes[v].tags = {}
			end
			table.insert(TheWorld.topology.nodes[v].tags, "sandstorm")
		end
	end
	print "Retrofitting for Against the Grain: Sandstorm enabled."

	-- Add the Antlion Spawner
	local ents = TheSim:FindEntities(antlion_pt.x, 0, antlion_pt.z, 2, nil, IMPORTANT_OBJECT_TAGS)
	for _,ent in ipairs(ents) do
		if ent.brain == nil then
			print ("Retrofitting for Against the Grain: Warning - Removing object, " .. tostring(ent) .. " to make way for the antlion.")
			if ent.components.workable ~= nil then
				ent.components.workable:Destroy(ent)
			end
			if ent:IsValid() then
				ent:Remove()
			end
		end
	end
	SpawnPrefab("antlion_spawner").Transform:SetPosition(antlion_pt:Get())
	print "Retrofitting for Against the Grain: Added Antlion Spawner."

	-- Add the Oasis Lake and clearout the area around it
	local lake_ents = TheSim:FindEntities(lake_pt.x, 0, lake_pt.z, 6, nil, IMPORTANT_OBJECT_TAGS)
	for _,ent in ipairs(lake_ents) do
		if ent.brain == nil then
			print ("Retrofitting for Against the Grain: Warning - Removing object, " .. tostring(ent) .. " to make way for the oasis lake.")
			if ent.components.workable ~= nil then
				ent.components.workable:Destroy(ent)
			end
			if ent:IsValid() then
				ent:Remove()
			end
		end
	end
	local oasis_ponds = TheSim:FindEntities(lake_pt.x, 0, lake_pt.z, 50, WATERSOURCE_TAGS)
	for _,ent in ipairs(oasis_ponds) do
		print ("Retrofitting for Against the Grain: Removing pond, " .. tostring(ent) .. " to make way for the oasis lake.")
		ent:Remove()
	end
	SpawnPrefab("oasislake").Transform:SetPosition(lake_pt:Get())
	print "Retrofitting for Against the Grain: Added Oasis Lake."

	-- Convert cactus to oasis_cactus
	if area == "Oasis" then
		local num_cactus = 0
		for k,v in ipairs(node_indices) do
			local node = TheWorld.topology.nodes[v]
			local ents = TheSim:FindEntities(node.cent[1], 0, node.cent[2], 50, THORNY_TAGS)
			for _,ent in ipairs(ents) do
				if ent.prefab == "cactus" then
					local x,y,z = ent.Transform:GetWorldPosition()
					ent:Remove()
					SpawnPrefab("oasis_cactus").Transform:SetPosition(x,y,z)
					num_cactus = num_cactus + 1
				end
			end
		end
		print ("Retrofitting for Against the Grain: Converted " .. tostring(num_cactus) .. " cactus objects to oasis_cactus.")
	end

	print ("Retrofitting for Against the Grain: "..area.." has been retrofitted to include Lightning Bluff.")
	return true
end

--------------------------------------------------------------------------

local function ALittleDrama_NewContent_Retrofitting()
	if TheWorld.topology.overrides ~= nil and TheWorld.topology.overrides.stageplays == "never" then
		print("Retrofitting for A Little Drama stageplays: Skipping due to overrides.stageplays == never")
		return
	end

	-- Find appropriate biomes
	local VALID_STAGE_BACKGROUNDS = {
		"BGBadlands",
		"BGCrappyForest",
		"BGDeciduous",
		"BGDeepForest",
		"BGForest",
		"BGGrass",
		"BGGrassBurnt",
		"BGMarsh",
		"BGRocky",
		"BGSavanna",
	}
	local VALID_STATUE_BACKGROUNDS = {
		"BGCrappyForest",
		"BGDeciduous",
		"BGDeepForest",
		"BGForest",
		"BGGrass",
	}
	local node_indices, stage_candidate_nodes, statue_candidate_nodes = {}, {}, {}
	for node_index, id_string in ipairs(TheWorld.topology.ids) do
		for _, bg_string in ipairs(VALID_STAGE_BACKGROUNDS) do
			if id_string:find(bg_string) then
				table.insert(stage_candidate_nodes, TheWorld.topology.nodes[node_index])
			end
		end

		for _, bg_string in ipairs(VALID_STATUE_BACKGROUNDS) do
			if id_string:find(bg_string) then
				table.insert(statue_candidate_nodes, TheWorld.topology.nodes[node_index])
			end
		end
	end

	if #stage_candidate_nodes == 0 or #statue_candidate_nodes == 0 then
		print("Retrofitting for A Little Drama: Failed to find any appropriate nodes to spawn in.")
		return
	end

	print("Retrofitting for A Little Drama: Adding missing stageplay objects.")

	local VALID_ALITTLEDRAMA_WORLDTILES = {
		WORLD_TILES.DIRT_NOISE,
		WORLD_TILES.DECIDUOUS,
		WORLD_TILES.FOREST,
		WORLD_TILES.GRASS,
		WORLD_TILES.MARSH,
		WORLD_TILES.ROCKY,
		WORLD_TILES.SAVANNA,
	}
	local is_valid_alittledrama_turf = function(x, y, z, prefab)
		local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
		for _, tile_type in ipairs(VALID_ALITTLEDRAMA_WORLDTILES) do
			if tile_type == tile then
				return true
			end
		end
		return false
	end
	if not RetrofitNewContentPrefab(inst, "charlie_stage_post", 10.5, 11, is_valid_alittledrama_turf, stage_candidate_nodes)
			and not RetrofitNewContentPrefab(inst, "charlie_stage_post", 10.5, 11, nil, stage_candidate_nodes) then
		print("Retrofitting for A Little Drama: Failed to place a Stage in the world.")
	end

	local VALID_STATUE_WORLDTILES = {
		WORLD_TILES.DECIDUOUS,
		WORLD_TILES.FOREST,
		WORLD_TILES.GRASS,
	}
	local is_valid_statue_turf = function(x, y, z, prefab)
		local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
		for _, tile_type in ipairs(VALID_STATUE_WORLDTILES) do
			if tile_type == tile then
				return true
			end
		end
		return false
	end
	if not RetrofitNewContentPrefab(inst, "statueharp_hedgespawner", 4, 6, is_valid_statue_turf, statue_candidate_nodes)
			and not RetrofitNewContentPrefab(inst, "statueharp_hedgespawner", 4, 6, nil, statue_candidate_nodes) then
		print("Retrofitting for A Little Drama: Failed to place an Overgrown Statue in the world.")
	end
end


--------------------------------------------------------------------------

local function Junkyard_NewContent_Retrofitting()

	if TheWorld.topology.overrides ~= nil and TheWorld.topology.overrides.junkyard == "never" then
		print("Retrofitting for Junkyard: Skipping due to overrides.junkyard == never")
		return
	end

	-- Find appropriate biomes
	local VALID_JUNKYARD_BACKGROUNDS = {
		"BGBadlands",
		"BGCrappyForest",
		"BGDeciduous",
		"BGDeepForest",
		"BGForest",
		"BGGrass",
		"BGGrassBurnt",
		"BGRocky",
		"BGSavanna",
	}

	local node_indices, jy_candidate_nodes = {}, {}
	for node_index, id_string in ipairs(TheWorld.topology.ids) do
		for _, bg_string in ipairs(VALID_JUNKYARD_BACKGROUNDS) do
			if id_string:find(bg_string) then
				table.insert(jy_candidate_nodes, TheWorld.topology.nodes[node_index])
			end
		end
	end

	if #jy_candidate_nodes == 0 then
		print("Retrofitting for the Junk Yard: Failed to find any appropriate nodes to spawn in.")
		return
	end

    local needs_robot = true
    local needs_marker = true
    local bigjunkpile = nil
    for k, v in pairs(Ents) do
        if v.prefab == "storage_robot" then
            needs_robot = false
        elseif v.prefab == "wagstaff_machinery_marker" then
            needs_marker = false
        elseif v.prefab == "junk_pile_big" then
            bigjunkpile = v
        end
    end

    if bigjunkpile ~= nil and not needs_robot and not needs_marker then
		print("Retrofitting for the Junk Yard: Nothing needed.")
        return
    end

	print("Retrofitting for Junk Yard: Adding missing junkyard objects.")
    if bigjunkpile == nil then
        print("Going to try to add junk_pile_big.")
    end
    if needs_robot then
        print("Going to try to add storage_robot.")
    end
    if needs_marker then
        print("Going to try to add wagstaff_machinery_marker.")
    end

	local VALID_JUNKYARD_WORLDTILES = {
		WORLD_TILES.DIRT_NOISE,
		WORLD_TILES.DECIDUOUS,
		WORLD_TILES.FOREST,
		WORLD_TILES.GRASS,
		WORLD_TILES.ROCKY,
		WORLD_TILES.SAVANNA,
	}
	local is_valid_jy_turf = function(x, y, z, prefab)
		local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
		for _, tile_type in ipairs(VALID_JUNKYARD_WORLDTILES) do
			if tile_type == tile then
				return true
			end
		end
		return false
	end
    local is_valid_NO_DOCKS = function(x, y, z, prefab)
        return TheWorld.Map:IsLandTileAtPoint(x, y, z) and not TheWorld.Map:IsDockAtPoint(x, y, z)
    end

    local NO_JUNK_FLAG = {} -- NOTES(JBK): Using a table here in case RetrofitNewContentPrefab changes and no one updates this callback for a unique variable.
	local on_add_prefab = function(inst, nojunk)
		local MAX = 8
		local pos = Vector3(inst.Transform:GetWorldPosition())
        local offset = nil
        if needs_robot then
            for radius = math.random() * 5 + 3, 3, -0.5 do
                offset = FindWalkableOffset(pos, math.random() * PI / (MAX / 4), radius, 10, true, false)
                if offset then
                    break
                end
            end
            if offset then
                pos = pos + offset
            else
                local r = inst:GetPhysicsRadius()
                local theta = math.random() * PI2
                pos.x = pos.x + r * math.cos(theta)
                pos.z = pos.z + r * math.sin(theta)
            end
            local robot = SpawnPrefab("storage_robot") -- Required for retrofitting.
            robot.Transform:SetPosition(pos:Get())
            robot.components.fueled:SetPercent(0)
            robot.sg:GoToState("idle_broken")
        end

        pos = Vector3(inst.Transform:GetWorldPosition())
        offset = nil
        if needs_marker then
            for radius = math.random() * 5 + 3, 3, -0.5 do
                offset = FindWalkableOffset(pos, math.random() * PI / (MAX / 4), radius, 10, true, false)
                if offset then
                    break
                end
            end
            if offset then
                pos = pos + offset
            else
                local r = inst:GetPhysicsRadius()
                local theta = math.random() * PI2
                pos.x = pos.x + r * math.cos(theta)
                pos.z = pos.z + r * math.sin(theta)
            end
            local marker = SpawnPrefab("wagstaff_machinery_marker") -- Required for retrofitting.
            marker.Transform:SetPosition(pos:Get())
        end

        if nojunk == NO_JUNK_FLAG then
            for i = 1, MAX do
                local radius = math.random() * 5 + 3
                local offset = FindWalkableOffset(pos, i * (TWOPI / MAX) + (math.random() * PI / (MAX / 4) ), radius, 10, true, false)
                if offset then 
                    local junk = SpawnPrefab("junk_pile") -- Not needed for retrofitting.
                    junk.Transform:SetPosition(pos.x + offset.x, pos.y + offset.y, pos.z + offset.z)
                end
            end
        end
	end

	--RetrofitNewContentPrefab(inst, prefab, min_space, dist_from_structures, canplacefn, candidtate_nodes, on_add_prefab)
    local function TryReallyHardForThis()
        if RetrofitNewContentPrefab(inst, "junk_pile_big", 10.5, 8, is_valid_jy_turf, jy_candidate_nodes, on_add_prefab) then
            return
        end
        print("Retrofitting for Junk Yard: Failed to place a junk pile in the world for best spots retrying with any turf.")
        if RetrofitNewContentPrefab(inst, "junk_pile_big", 10.5, 8, is_valid_NO_DOCKS, jy_candidate_nodes, on_add_prefab) then
            print("Was a success.")
            return
        end
        print("Retrofitting for Junk Yard: Failed to place a junk pile in the world for non turf spots retrying with less space.")
        if RetrofitNewContentPrefab(inst, "junk_pile_big", 8, nil, is_valid_NO_DOCKS, jy_candidate_nodes, on_add_prefab) then
            print("Was a success.")
            return
        end
        print("Retrofitting for Junk Yard: Failed to place a junk pile in the world for less space retrying with even less space.")
        for i = 1, 10 do
            if RetrofitNewContentPrefab(inst, "junk_pile_big", 4, nil, is_valid_NO_DOCKS, jy_candidate_nodes, on_add_prefab) then
                print("Was a success.")
                return
            end
        end
        print("Retrofitting for Junk Yard: Failed to place a junk pile in the world for even less space.")
    end

    if bigjunkpile == nil then
        TryReallyHardForThis() -- NOTES(JBK): Retrofitting in the junk pile is mandatory somewhere in the world for the daywalker fight we can not let this slip by.
    else
        on_add_prefab(bigjunkpile, NO_JUNK_FLAG)
    end
end

local function SkilltreeSpotlightWinonaWurtRetrofitting_PopulateOtterDens()
	local width, height = TheWorld.Map:GetSize()

	local count = 0

	local function SpawnBoatingSafePrefab(prefab, x, z)
		if #TheSim:FindEntities(x, 0, z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS + 4, WALKABLEPLATFORM_TAGS) == 0 then
			local obj = SpawnPrefab(prefab)
			obj.Transform:SetPosition(x, 0, z)
			count = count + 1
		end
	end

	local function populate_ocean(tile_type, contents)
		for y = OCEAN_POPULATION_EDGE_DIST, height - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
			for x = OCEAN_POPULATION_EDGE_DIST, width - OCEAN_POPULATION_EDGE_DIST - 1, 1 do
				if math.random() < contents.distributepercent and TheWorld.Map:GetTile(x, y) == tile_type then
					SpawnBoatingSafePrefab(
						contents.distributeprefab,
						(x - width/2.0)*TILE_SCALE + math.random()*2-1,
						(y - height/2.0)*TILE_SCALE + math.random()*2-1
					)
				end
			end
		end
	end

	populate_ocean(WORLD_TILES.OCEAN_COASTAL, {
		distributepercent = 0.0009765625, -- 0.01 * 1/(3+6+1+0.24)
		distributeprefab = "boat_otterden",
	})

	print("Retrofitting for Skilltree Spotlight: Winona & Wurt - Added " .. tostring(count) .. " Otter Dens.")
end


--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
	if retrofit_part1 then
		local requires_retrofitting = true
	    for k,v in pairs(Ents) do
			if v ~= inst and v.prefab == "moonbase" then
				print ("Retrofitting for A New Reign Part1 is not required.")
				requires_retrofitting = false
				break
			end
		end

		if requires_retrofitting then
			print ("Retrofitting for A New Reign Part1.")
			RetrofitNewContentPrefab(inst, "stagehand", 2, 10)
			RetrofitNewContentPrefab(inst, "moonbase", 2, 40)
			RetrofitNewContentPrefab(inst, "sculpture_rookbody", 2, 40)
			RetrofitNewContentPrefab(inst, "sculpture_rooknose", 1, 10)
			RetrofitNewContentPrefab(inst, "sculpture_knightbody", 2, 40)
			RetrofitNewContentPrefab(inst, "sculpture_knighthead", 1, 10)
			RetrofitNewContentPrefab(inst, "sculpture_bishopbody", 2, 40)
			RetrofitNewContentPrefab(inst, "sculpture_bishophead", 1, 10)
		end
	end

	if self.retrofit_artsandcrafts then
		self.retrofit_artsandcrafts = nil

		local requires_retrofitting = true
		local missing_sculpture = {pawn=true, knight=true, rook=true, bishop=true, muse=true, formal=true}
	    for k,v in pairs(Ents) do
			if v ~= inst then
				if v.prefab == "statue_marble" then
					if v.typeid == 1 or v.typeid == 2 then
						missing_sculpture.muse = nil
					elseif v.typeid == 4 then
						missing_sculpture.pawn = nil
					end
				elseif v.prefab == "statuemaxwell" then
					missing_sculpture.formal = nil
				elseif v.prefab == "sculpture_rookbody" then
					missing_sculpture.rook = nil
				elseif v.prefab == "sculpture_knightbody" then
					missing_sculpture.knight = nil
				elseif v.prefab == "sculpture_bishopbody" then
					missing_sculpture.bishop = nil
				end

				if next(missing_sculpture) == nil then
					print ("Retrofitting for A New Reign: Arts and Crafts is not required.")
					break;
				end
			end
		end

		if next(missing_sculpture) ~= nil then
			print ("Retrofitting for A New Reign: Arts and Crafts.")
			for key,_ in pairs(missing_sculpture) do
				RetrofitNewContentPrefab(inst, "chesspiece_"..key.."_sketch", 1, 5)
			end
		end

	end

    if self.retrofit_artsandcrafts2 then
        self.retrofit_artsandcrafts2 = nil

        inst:PushEvent("ms_unlockchesspiece", "pawn")
        inst:PushEvent("ms_unlockchesspiece", "bishop")
        inst:PushEvent("ms_unlockchesspiece", "rook")
        inst:PushEvent("ms_unlockchesspiece", "knight")
        inst:PushEvent("ms_unlockchesspiece", "muse")
        inst:PushEvent("ms_unlockchesspiece", "formal")
    end

	if self.retrofit_cutefuzzyanimals then
		self.retrofit_cutefuzzyanimals = nil

		local missing_prefabs = {critterlab=true, beequeenhive=true}
	    for k,v in pairs(Ents) do
			if table.containskey(missing_prefabs, v.prefab) then
				missing_prefabs[v.prefab] = nil

				if next(missing_prefabs) == nil then
					print ("Retrofitting for A New Reign: Cute Fuzzy Animals is not required.")
					break
				end
			end
		end

		if next(missing_prefabs) ~= nil then
			print ("Retrofitting for A New Reign: Cute Fuzzy Animals.")
			for key,_ in pairs(missing_prefabs) do
				RetrofitNewContentPrefab(inst, key, 2, 10)
			end
		end
	end


	if self.retrofit_herdmentality then
		self.retrofit_herdmentality = nil

		local requires_retrofitting = true
	    for k,v in pairs(Ents) do
			if v ~= inst and v.prefab == "deerspawningground" then
				print ("Retrofitting for A New Reign: Herd Mentality is not required.")
				requires_retrofitting = false
				break
			end
		end

		if requires_retrofitting then
			local deciduousfn = function(x, y, z, prefab)
					return TheWorld.Map:GetTileAtPoint(x, y, z) == WORLD_TILES.DECIDUOUS
				end

			print ("Retrofitting for A New Reign: Herd Mentality.")
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
			RetrofitNewContentPrefab(inst, "deerspawningground", 1, 10, deciduousfn)
		end

	end

	if self.retrofit_againstthegrain then
		self.retrofit_againstthegrain = nil

		local requires_retrofitting = true
	    for k,v in pairs(Ents) do
			if v.prefab == "antlion_spawner" then
				print ("Retrofitting for A New Reign: Against the Grain is not required.")
				requires_retrofitting = false
				break
			end
		end

		if requires_retrofitting then
			if not RetrofitAgainstTheGrain("Oasis") then
				if not RetrofitAgainstTheGrain("Badlands") then
					print "Retrofitting for Against the Grain: FAILED!"
				end
			end
		end
	end

	if self.retrofit_penguinice then
		self.retrofit_penguinice = nil
		local count = 0
	    for k,v in pairs(Ents) do
			if v.prefab == "rock_ice" then
				local x, y, z = v.Transform:GetWorldPosition()
				local ents = TheSim:FindEntities(x, y, z, 15.1)
				for _,ent in ipairs(ents) do
					if ent.prefab == "penguin_ice" then
						v.remove_on_dryup = true
						count = count + 1
						break
					end
				end
			end
		end

		if count ~= 0 then
			print ("Retrofitting for Pengull spawned Mini Glaciers: Converted " .. count .. " Mini Glaciers near pengull colonies to be remove on dry up.")
		end
	end

	if self.retrofit_turnoftides then
		self.retrofit_turnoftides = nil

		print ("Retrofitting for Return Of Them: Turn of Tides")

		TurnOfTidesRetrofitting_PopulateOcean()

		self.requiresreset = true
	end

	if self.retrofit_turnoftides_betaupdate1 then
		TheWorld.Map:RetrofitNavGrid()
		print ("Retrofitting for Return Of Them: Turn of Tides - Updated Nav Grid")
		self.requiresreset = true
	end

	if self.retrofit_turnoftides_seastacks then
		print ("Retrofitting for Return Of Them: Turn of Tides - Balancing Seastacks")
		TurnOfTidesRetrofitting_CleanupOceanPoution(self.inst)
	end

	if self.retrofit_fix_sculpture_pieces then
		local count = 0
		for _,obj in pairs(Ents) do
			if obj:IsValid() then
				if obj.prefab == "sculpture_knighthead" or obj.prefab == "sculpture_bishophead" or obj.prefab == "sculpture_rooknose" then
					local x, y, z = obj.Transform:GetWorldPosition()
					local bodies = TheSim:FindEntities(x, y, z, 1.6, SCULPTURE_TAGS)
					for _, body in ipairs(bodies) do
						local radius = body.prefab == "sculpture_knightbody" and 0.8
									or body.prefab == "sculpture_bishopbody" and 0.8
									or body.prefab == "sculpture_rookbody" and 1.7
									or nil
						if radius ~= nil then
							local offset = FindWalkableOffset(body:GetPosition(), math.random() * TWOPI, radius, 60, false, false, NoHoles) or Vector3(2, 0, 0)
							obj.Transform:SetPosition((body:GetPosition() + offset):Get())

							count = count + 1
							break
						end
					end
				end
			end
		end

		if count > 0 then
			print("Retrofitting - Fixed "..tostring(count).." sculpture pieces positions.")
		else
			print("Retrofitting - No sculpture pieces required repositioning.")
		end
	end

	if self.retrofit_salty then
		-- add shoals for malbatross spawning, salt statcks and cookie citter spawners
		print ("Retrofitting for Return Of Them: Salty Dog - Adding Malbatross food sources.")
		SaltyRetrofitting_PopulateShoalSpawner()

--		print ("Retrofitting for Return Of Them: Salty Dog - Raising salt levels.")
--		SaltyRetrofitting_PopulateBrinePools()
	end


    if self.retrofit_shesellsseashells then
        print("Retrofitting for Return Of Them: She Sells Seashells - Adding Wobster Dens")
        SheSellsSeashellsRetrofitting_PopulateWobsterDens()
		self.requiresreset = true -- for hermit island retofitting (retrofit_shesellsseashells_hermitisland)
    end

    if self.retrofit_barnacles then
        print("Retrofitting for Return Of Them: Troubled Waters - Replacing Seastacks With Barnacle Plants")
        Barnacles_ReplaceSeastacks()
	end

	if self.retrofit_inaccessibleunderwaterobjects then
		print("Retrofitting for Return of Them: Forgotten Knowledge - Repositioning inaccessible underwater objects.")
		RepositionInaccessibleUnderwaterObjects()
	end

	if self.retrofit_moonfissures then
		print("Retrofitting for Return of Them: Forgotten Knowledge - Verifying moon fissure proximity.")
		MoonFissures()
	end

	if self.retrofit_astralmarkers then
		print("Retrofitting for Return of Them: Forgotten Knowledge - Placing Astral Markers.")
		AstralMarkers()
	end

	if self.retrofit_nodeidtilemap_secondpass then
		for i, node in ipairs(TheWorld.topology.nodes) do
			if table.contains(node.tags, "lunacyarea") then
				TheWorld.Map:RepopulateNodeIdTileMap(i, node.x, node.y, node.poly, 10000, 2.1)
			end
		end

		print ("Retrofitting for Return of Them: Forgotten Knowledge - Repaired tile node ids for lunar island.")
		self.requiresreset = true
	end

	if self.retrofit_nodeidtilemap_thirdpass then
		local num_tiles_repaired = 0
		for i, id in ipairs(TheWorld.topology.ids) do
			if id == "StaticLayoutIsland:HermitcrabIsland" then
				local node = TheWorld.topology.nodes[i]
				num_tiles_repaired = TheWorld.Map:RepopulateNodeIdTileMap(i, node.x, node.y, node.poly)
				break
			end
		end

		print ("Retrofitting for Return of Them: Forgotten Knowledge - Repaired " .. tostring(num_tiles_repaired) .. " tile node ids for hermit island.")
		self.requiresreset = self.requiresreset or num_tiles_repaired > 0
	end

    if self.retrofit_removeextraaltarpieces then
        print("Retrofitting for Return of Them: Eye of the Storm - Removing Erroneously Spawned Altar Pieces")
        EyeOfTheStorm_RemoveExtraAltarPieces()
    end

	if self.retrofit_terraria_terrarium then
		print ("Retrofitting for Terraria: Adding Terrarium chest.")
		TerrariumChest_Retrofitting()
	end

	if self.retrofit_catcoonden_deextinction then
		print ("Retrofitting for Catcoon Den De-extinction: Checking if catcoon dens need to restored in the world.")
		CatcoonDen_Retrofitting()
	end

	if self.retrofit_alittledrama_content then
		print ("Retrofitting for A Little Drama: Adding important prefabs normally found in new setpieces.")
		ALittleDrama_NewContent_Retrofitting()
	end

	---------------------------------------------------------------------------

    if self.retrofit_daywalker_content then
		self.retrofit_daywalker_content = nil

        -- NOTES(JBK): This is here to clean up old daywalker content from forest after it moved to caves.
        local should_delete = {
            daywalker = true,
            daywalker_pillar = true,
            daywalkerspawningground = true,
            shadow_leech = true,
        }
        for k,v in pairs(Ents) do
            if v ~= inst and should_delete[v.prefab] then
                print("Retrofitting BETA Daywalker entity, removing from forest:", v)
                v:Remove()
            end
        end
	end

    ---------------------------------------------------------------------------

    if self.console_beard_turf_fix then
        self.console_beard_turf_fix = nil
        -- NOTES(JBK): This fixup works only because the old beard turfs that got changed into rift moon turfs do not place under tile data.
        -- Do not use for other fixes in other cases without checking.
        local undertile = TheWorld.components.undertile
        if undertile then
            local map = TheWorld.Map
            local width, height = map:GetSize()
            local find_tile = WORLD_TILES.RIFT_MOON
            local replace_tile = WORLD_TILES.BEARD_RUG
            for x = 0, width - 1 do
                for y = 0, height - 1 do
                    if map:GetTile(x, y) == find_tile and undertile:GetTileUnderneath(x, y) == nil then
                        map:SetTile(x, y, replace_tile)
                    end
                end
            end
        end
    end


	---------------------------------------------------------------------------

    if self.retrofit_junkyard_content then
		print ("Retrofitting for Junk Yard: Adding important prefabs normally found in new setpieces.")
		Junkyard_NewContent_Retrofitting()
	end

    if self.retrofit_junkyardv3_content then
        print("Retrofitting for Junk Yard: Adding important prefabs normally found in new setpieces SECOND PASS.")
        Junkyard_NewContent_Retrofitting()
    end

	---------------------------------------------------------------------------

    if self.remove_rift_terraformers_fix then
        print("Removing stale rift_terraformer entities.")
        self.remove_rift_terraformers_fix = nil
        -- NOTES(JBK): This fixup exists from an issue with rift_terraformer not removing itself when the portal is finished with it.
        -- This fix needs to check for the portal to rift_terraformer link to not remove them.
        local tokeep = {}
        local terraformers = {}
        for _, v in pairs(Ents) do
            if v.prefab == "rift_terraformer" then
                terraformers[v] = true
                if v.components.timer and v.components.timer:TimerExists("remove") then
                    tokeep[v] = true -- This is self cleaning.
                end
            elseif v.prefab == "lunarrift_portal" then
                if v._terraformer then
                    tokeep[v._terraformer] = true
                end
            end
        end
        for v, _ in pairs(terraformers) do
            if not tokeep[v] then
                print(v, "removed.")
                v:Remove()
            end
        end
    end

	if self.retrofit_otterdens then
        print("Retrofitting for Skilltree Spotlight: Winona & Wurt: Adding Otter Dens.")
		SkilltreeSpotlightWinonaWurtRetrofitting_PopulateOtterDens()
	end

	---------------------------------------------------------------------------

	if self.requiresreset then
		print ("Retrofitting: Worldgen retrofitting requires the server to save and restart to fully take effect.")
		print ("Restarting server in 30 seconds...")

        inst:DoTaskInTime(5,  function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 25})) end)
        inst:DoTaskInTime(10, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 20})) end)
        inst:DoTaskInTime(15, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 15})) end)
		inst:DoTaskInTime(20, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 10})) end)
		inst:DoTaskInTime(22, function() TheWorld:PushEvent("ms_save") end)
		inst:DoTaskInTime(25, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 5})) end)
		inst:DoTaskInTime(29, function() TheNet:Announce(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT_NOW) end)
		inst:DoTaskInTime(30, function() TheNet:SendWorldRollbackRequestToServer(0) end)
	end

end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return {}
end

function self:OnLoad(data)
    if data ~= nil then
		-- flags for OnPostLoad
		retrofit_part1 = data.retrofit_part1 or false
		self.retrofit_artsandcrafts = data.retrofit_artsandcrafts or false
        self.retrofit_artsandcrafts2 = data.retrofit_artsandcrafts2 or false
        self.retrofit_cutefuzzyanimals = data.retrofit_cutefuzzyanimals or false
        self.retrofit_herdmentality = data.retrofit_herdmentality or false
        self.retrofit_againstthegrain = data.retrofit_againstthegrain or false
        self.retrofit_penguinice = data.retrofit_penguinice or false
        self.retrofit_turnoftides = data.retrofit_turnoftides or false
        self.retrofit_turnoftides_betaupdate1 = data.retrofit_turnoftides_betaupdate1 or false
        self.retrofit_turnoftides_seastacks = data.retrofit_turnoftides_seastacks or false
		self.retrofit_fix_sculpture_pieces = data.retrofit_fix_sculpture_pieces or false
		self.retrofit_salty = data.retrofit_salty or false
        self.retrofit_shesellsseashells = data.retrofit_shesellsseashells or false
		self.retrofit_barnacles = data.retrofit_barnacles or false
		self.retrofit_inaccessibleunderwaterobjects = data.retrofit_inaccessibleunderwaterobjects or false
		self.retrofit_moonfissures = data.retrofit_moonfissures or false
		self.retrofit_astralmarkers = data.retrofit_astralmarkers or false
		self.retrofit_nodeidtilemap_secondpass = data.retrofit_nodeidtilemap_secondpass or false
		self.retrofit_nodeidtilemap_thirdpass = data.retrofit_nodeidtilemap_thirdpass or false
        self.retrofit_removeextraaltarpieces = data.retrofit_removeextraaltarpieces or false
        self.retrofit_terraria_terrarium = data.retrofit_terraria_terrarium or false
		self.retrofit_alittledrama_content = data.retrofit_alittledrama_content or false
        self.retrofit_daywalker_content = data.retrofit_daywalker_content or false
        self.console_beard_turf_fix = data.console_beard_turf_fix or false
        self.retrofit_junkyard_content = data.retrofit_junkyard_content or false
        self.retrofit_junkyardv2_content = data.retrofit_junkyardv2_content or false
        self.retrofit_junkyardv3_content = data.retrofit_junkyardv3_content or false
        self.remove_rift_terraformers_fix = data.remove_rift_terraformers_fix or false
		self.retrofit_otterdens = data.retrofit_otterdens or false
    end
end


--------------------------------------------------------------------------
end)