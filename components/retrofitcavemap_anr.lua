

--------------------------------------------------------------------------
--[[ RetrofitCaveMap_ANR class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "RetrofitCaveMapA_NR should not exist on client")

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
local retrofit_warts = false

local STRUCTURE_TAGS = {"structure"}
local ALTAR_TAGS = {"altar"}
local LOCOMOTOR_TAGS = {"locomotor"}


--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
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


local function RetrofitNewCaveContentPrefab(inst, prefab, min_space, dist_from_structures, nightmare, searchnodes_override, ignore_terrain)
	local attempt = 1
	local topology = TheWorld.topology

	local ret = nil

	nightmare = nightmare or false

    local searchnodes
    if searchnodes_override then
        searchnodes = searchnodes_override
    else
        searchnodes = {}
        for k = 1, #topology.nodes do
            if (nightmare == table.contains(topology.nodes[k].tags, "Nightmare"))
                and (not table.contains(topology.nodes[k].tags, "Atrium"))
                and (not table.contains(topology.nodes[k].tags, "lunacyarea"))
                and (not string.find(topology.ids[k], "RuinedGuarden")) then

                table.insert(searchnodes, k)
            end
        end
    end

	if #searchnodes == 0 then
		print ("Retrofitting world for " .. prefab .. " FAILED: Could not find any " .. (nightmare and "Ruins" or "Caves") .. " nodes to spawn in.")
		return
	end

	while attempt <= MAX_PLACEMENT_ATTEMPTS do
		local searchnode = searchnodes[math.random(#searchnodes)]
		local area =  topology.nodes[searchnode]

		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 1)
		if #points_x == 1 and #points_y == 1 then
			local x = points_x[1]
			local z = points_y[1]

			if ignore_terrain or TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x + min_space, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z + min_space, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x - min_space, 0, z, prefab) and
				TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z - min_space, prefab) then

				local ents = TheSim:FindEntities(x, 0, z, min_space)
				if #ents == 0 then
					if dist_from_structures ~= nil then
						ents = TheSim:FindEntities(x, 0, z, dist_from_structures, STRUCTURE_TAGS )
					end

					if #ents == 0 then
						ret = SpawnPrefab(prefab)
						ret.Transform:SetPosition(x, 0, z)
						break
					end
				end
			end
		end
		attempt = attempt + 1
	end
	print ("Retrofitting world for " .. prefab .. ": " .. (attempt < MAX_PLACEMENT_ATTEMPTS and ("Success after "..attempt.." attempts.") or ("Failed to find a valid tile in "..#searchnodes.." nodes.")))
	return attempt < MAX_PLACEMENT_ATTEMPTS, ret
end

--------------------------------------------------------------------------
--[[ Private Heart of the Ruins functions ]]
--------------------------------------------------------------------------

local function AddAtriumWorldTopolopy(left, top)
	local index = #TheWorld.topology.ids + 1
	TheWorld.topology.ids[index] = "AtriumMaze:0:AtriumMazeRooms"
	TheWorld.topology.story_depths[index] = 0

	local size = 4 * 8 * 6

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
	node.tags  = {"Atrium", "Nightmare"}
	node.type = NODE_TYPE.Default
	node.x = node.cent[1]
	node.y = node.cent[2]

	node.validedges = {}

	TheWorld.topology.nodes[index] = node
end

local function HeartOfTheRuinsAtriumRetrofitting(inst)
	local obj_layout = require("map/object_layout")
	local entities = {}

	local map_width, map_height = TheWorld.Map:GetSize()

	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
				local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
				local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
				x = math.floor(x*100)/100.0
				y = math.floor(y*100)/100.0
				if prefab == "wormhole_MARKER" then
					local p1 = SpawnPrefab("tentacle_pillar")
					p1.Transform:SetPosition(x, 0, y)

					local _,p2 = RetrofitNewCaveContentPrefab(inst, "tentacle_pillar", 3, 20)
					while p2 == nil do
						_, p2 = RetrofitNewCaveContentPrefab(inst, "tentacle_pillar", 3, 5)
					end

					p1.components.teleporter:Target(p2)
					p2.components.teleporter:Target(p1)
				else
					SpawnPrefab(prefab).Transform:SetPosition(x, 0, y)
				end
			end,
			args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
		}


	local top, left = 8, 8
	local area_size = 6*8

	local function isvalidarea(_left, _top)
		for x = 0, 5*8 do
			for y = 0, 5*8 do
				if not TileGroupManager:IsImpassableTile(TheWorld.Map:GetTile(_left + x, _top + y)) then
					return false
				end
			end
		end
		return true
	end

	local foundarea = false
	for x = 0, 6 do
		for y = 0, 6 do
			if (x == 0 or x == 6) or (y == 0 or y == 6) then
				left = 8 + (x > 0 and ((x * (map_width / 6)) - area_size - 16) or 0)
				top  = 8 + (y > 0 and ((y * (map_height / 6)) - area_size - 16) or 0)
				if isvalidarea(left, top) then
					foundarea = true
					break
				end
			end
		end
		if foundarea then
			break
		end
	end

	if foundarea then
		local maze = {	{ "SINGLE_NORTH",	"L_EAST",		"SINGLE_NORTH",	"L_EAST" },
						{ "L_NORTH",		"FOUR_WAY",		"TUNNEL_NS",	"THREE_WAY_E" },
						{ "L_SOUTH",		"TUNNEL_EW",	"SINGLE_EAST",	"TUNNEL_EW" },
						{ "",				"SINGLE_WEST",	"L_WEST",		"THREE_WAY_S" } }

		for x = 1, 4 do
			for y = 1, 4 do
				if maze[x][y] ~= "" then
					obj_layout.Place({left + (x*8), top + (y*8)}, maze[x][y], add_fn, {"atrium_hallway", "atrium_hallway_two"}, TheWorld.Map)
				end
			end
		end

		obj_layout.Place({left + (3*8), top }, "SINGLE_NORTH", add_fn, {"atrium_end"}, TheWorld.Map)
		obj_layout.Place({left + (4*8), top + (5*8)}, "SINGLE_SOUTH", add_fn, {"atrium_start"}, TheWorld.Map)

		AddAtriumWorldTopolopy((left * 4) - (map_width * 0.5 * 4), (top* 4) - (map_height * 0.5 * 4))

		self.requiresreset = true

		print ("Retrofitting for A New Reign: Heart of the Ruins - Successfully added atruim into the world.")
	else
		print ("Retrofitting for A New Reign: Heart of the Ruins - FAILED! Could not find anywhere to add the atruim into the world.")
	end
end


local function AddRuinsRespawner(prefab, spawnerprefab)
	local count = 0
	spawnerprefab = spawnerprefab or prefab
	for _, v in pairs(Ents) do
		if v ~= inst and v.prefab == prefab then
			local respawner = SpawnPrefab(spawnerprefab.."_ruinsrespawner_inst")
			respawner.Transform:SetPosition(v.Transform:GetWorldPosition())
			if prefab == spawnerprefab then
				respawner.components.objectspawner:TakeOwnership(v)
			end
			count = count + 1
		end
	end

	if count == 0 then
		print ("Retrofitting for A New Reign: Heart of the Ruins - Could not find any "..spawnerprefab.." to add respawners for.")
	else
		print ("Retrofitting for A New Reign: Heart of the Ruins - Added "..count.." respawners for "..spawnerprefab.."." )
	end

	return count
end

local function HeartOfTheRuinsRuinsRetrofitting(inst)
	local function RepopNear(count, spawnerprefab, target, radius, repop)
		if count < repop then
			local targets = {}
			for _, v in pairs(Ents) do
				if v.prefab == target then
					table.insert(targets, v)
				end
			end

			if #targets > 0 then
				targets = shuffleArray(targets)
				local num_spawned = 0
				for i = 1, (repop-count) do
					local pt = targets[math.random(#targets)]:GetPosition()
					local offset = FindWalkableOffset(pt, math.random(360), radius, 12, true, true)
					if offset ~= nil then
						local respawner = SpawnPrefab(spawnerprefab.."_ruinsrespawner_inst")
						respawner.Transform:SetPosition((pt+offset):Get())
						num_spawned = num_spawned + 1
					end
				end
				if num_spawned == 0 then
					print ("Retrofitting for A New Reign: Heart of the Ruins -   Could not find anywhere to added "..spawnerprefab.."_ruinsrespawner_inst.")
				else
					print ("Retrofitting for A New Reign: Heart of the Ruins -   Added "..num_spawned.." respawners for "..spawnerprefab.." near "..target.."." )
				end
			else
				print ("Retrofitting for A New Reign: Heart of the Ruins -   Could not find any "..target.." to add "..spawnerprefab.."_ruinsrespawner_inst near.")
			end
		end
	end

	local function RepopRandom(count, spawnerprefab, repop)
		if count < repop then
			print ("Retrofitting for A New Reign: Heart of the Ruins - Adding "..(repop-count).." new "..spawnerprefab.." to repopulate the ruins." )
			for i = count, (repop-1) do
				local _, respawner = RetrofitNewCaveContentPrefab(inst, spawnerprefab.."_ruinsrespawner_inst", 1, 1, true)
				if respawner ~= nil then
					count = count + 1
				end
			end
		end

		return count
	end

	RepopNear(AddRuinsRespawner("bishop_nightmare"), "bishop_nightmare", "nightmarelight", 6, 8)
	RepopNear(AddRuinsRespawner("knight_nightmare"), "knight_nightmare", "nightmarelight", 6, 8)
	RepopNear(AddRuinsRespawner("rook_nightmare"), "rook_nightmare", "nightmarelight", 6, 5)

	RepopRandom( AddRuinsRespawner("monkeybarrel"), "monkeybarrel", 15)
	RepopRandom( AddRuinsRespawner("slurper"), "slurper", 10)
	RepopRandom( AddRuinsRespawner("worm"), "worm", 7)

	local minotaur_respawner = true
	local minotaur_is_dead = false
	if AddRuinsRespawner("minotaur") == 0 then
		minotaur_is_dead = true
		if AddRuinsRespawner("minotaurchest", "minotaur") == 0 then
			minotaur_respawner = false
			for k,v in ipairs(TheWorld.topology.ids) do
				if string.find(v, "RuinedGuarden") then
					local node = TheWorld.topology.nodes[k]
					local respawner = SpawnPrefab("minotaur_ruinsrespawner_inst")
					respawner.Transform:SetPosition(node.cent[1], 0, node.cent[2])
					minotaur_respawner = true
					print ("Retrofitting for A New Reign: Heart of the Ruins - Added worst case respawner for the minotaur." )
				end
			end
		end
	end
	if minotaur_respawner == false then
		print ("Retrofitting for A New Reign: Heart of the Ruins - CRITICAL FAILURE - Could not find anywhere to add the Ancient Guardian respawern the world!")
		print ("Retrofitting for A New Reign: Heart of the Ruins - CRITICAL FAILURE - Could not find anywhere to add the Ancient Key!")
	else
		if minotaur_is_dead then
			for _, v in pairs(Ents) do
				if v.prefab == "minotaur_ruinsrespawner_inst" then
					local offset =
						FindWalkableOffset(v:GetPosition(), 0, 2, 8, true, true) or
						FindWalkableOffset(v:GetPosition(), 0, 4, 16, true, true) or
						Vector3(0, 0, 0)

						SpawnPrefab("atrium_key").Transform:SetPosition((v:GetPosition() + offset):Get())
						print ("Retrofitting for A New Reign: Heart of the Ruins - Added atrium_key to world." )
				end
			end
		else
			print ("Retrofitting for A New Reign: Heart of the Ruins - Added minotaur is alive so atrium_key does not require retrofitting." )
		end
	end

end

local function HeartOfTheRuinsRuinsRetrofittingRespawnerFix(inst, first_hotr_retrofit)
	if first_hotr_retrofit then
		return -- this step is not needed
	end

	local function NoSpawnOnLoadAndReduce(prefab, cap)
		local remove_spawners = {}
		local count = 0
		local spawner_prefab = prefab.."_ruinsrespawner_inst"
		for _, v in pairs(Ents) do
			if v.prefab == spawner_prefab then
				v.resetruins = nil

				count = count + 1
				if count > cap then
					table.insert(remove_spawners, v)
				end
			end
		end

		if #remove_spawners > 0 then
			print ("Retrofitting for A New Reign: Heart of the Ruins + Respawn Fix: Reducing from " .. count .. " to " .. cap .. " " .. prefab .. "'s.")

			inst:DoTaskInTime(0, function()
				for _,v in ipairs(remove_spawners) do
					if v.components.objectspawner ~= nil and (#v.components.objectspawner.objects == 1) then
						v.components.objectspawner.objects[1]:Remove()
					end
					v:Remove()
				end
			end)
		end
	end

	NoSpawnOnLoadAndReduce("bishop_nightmare", 10)
	NoSpawnOnLoadAndReduce("knight_nightmare", 14)
	NoSpawnOnLoadAndReduce("rook_nightmare", 5)
	NoSpawnOnLoadAndReduce("monkeybarrel", 20)
	NoSpawnOnLoadAndReduce("slurper", 10)
	NoSpawnOnLoadAndReduce("worm", 7)
	NoSpawnOnLoadAndReduce("minotaur", 1)
end

local function HeartOfTheRuinsRuinsRetrofittingAltar(inst)
	AddRuinsRespawner("ancient_altar_broken")
	AddRuinsRespawner("ancient_altar")

	for k,v in ipairs(TheWorld.topology.ids) do
		if string.sub(v, -string.len("Altar")) == "Altar" then
			local node = TheWorld.topology.nodes[k]

			if TheWorld.Map:IsAboveGroundAtPoint(node.x, 0, node.y) then
				local altars = TheSim:FindEntities(node.x, 0, node.y, 32, ALTAR_TAGS)
				if #altars == 0 then
					local respawner = SpawnPrefab("ancient_altar_broken_ruinsrespawner_inst")
					respawner.Transform:SetPosition(node.x, 0, node.y)
					print ("Retrofitting for A New Reign: Heart of the Ruins + Altar Respawner - Added respawner to " .. v .. " for missing ancient_altar_broken.")
				end
			end
		end
	end
end

local function HeartOfTheRuinsRuinsRetrofittingCaveHoles(inst)
	local count = 8
	for _,v in pairs(Ents) do
		if v.prefab == "cave_hole" then
			count = count - 1
		end
	end

	if count <= 0 then
		print ("Retrofitting for A New Reign: Heart of the Ruins + Cave Holes - Not Required!")
	else
		for i = 0, count do
			RetrofitNewCaveContentPrefab(inst, "cave_hole", 4, 20, true)
		end
	end

end

local function HeartOfTheRuinsRuinsRetrofitting_RepositionAtriumGate(inst)
	local function trypoint(pt1, pt2)
		local dir = pt2 - pt1
		if (math.abs(dir.x) < 1) or (math.abs(dir.z) < 1) then
			return pt1 + (dir * 0.5)
		end
	end

	local x, y, z = inst.Transform:GetWorldPosition()
	local pts = {}
	local ents = TheSim:FindEntities(x, y, z, 25)
	for _, ent in ipairs(ents) do
		if ent.prefab == "atrium_light" then
			if TheWorld.Map:GetTileAtPoint(ent.Transform:GetWorldPosition()) == WORLD_TILES.BRICK then
				table.insert(pts, ent:GetPosition())
			end
		end
	end
	if #pts == 3 then
		local pt = trypoint(pts[1], pts[2]) or trypoint(pts[1], pts[3]) or trypoint(pts[2], pts[3])
		print ("Retrofitting for A New Reign: Heart of the Ruins + Old Atrium Fixup: Moving gateway from " .. tostring(inst:GetPosition()) .. " to " .. tostring(pt))
		inst.Transform:SetPosition(pt:Get())
	else
		print ("Retrofitting for A New Reign: Heart of the Ruins + Old Atrium Fixup: Failed to adjust the Atrium Gateway's position.")
	end

end

local function HeartOfTheRuinsRuinsRetrofitting_StatueChessRespawners(inst)
	AddRuinsRespawner("chessjunk1", "chessjunk")
	AddRuinsRespawner("chessjunk2", "chessjunk")
	AddRuinsRespawner("chessjunk3", "chessjunk")

	AddRuinsRespawner("ruins_statue_head")
	AddRuinsRespawner("ruins_statue_head_nogem")
	AddRuinsRespawner("ruins_statue_mage")
	AddRuinsRespawner("ruins_statue_mage_nogem")
end

local function ArchiveDispencerFixup()

	local a = {}
	local b = {}
	local c = {}
	local dispencers = {}
	local lockboxes = {}

	for k,v in pairs(Ents) do
		if v.prefab == "archive_lockbox_dispencer" then
			table.insert(dispencers,v)
		end

		if v.prefab == "archive_lockbox" then
			table.insert(lockboxes,v)
		end

		if v.prefab == "archive_lockbox_dispencer" then
			if v.product_orchestrina ~= nil and v.product_orchestrina ~= "" then
				if v.product_orchestrina == "archive_resonator_item" then
					table.insert(b,v)
				elseif v.product_orchestrina == "refined_dust" then
					table.insert(c,v)
				elseif v.product_orchestrina == "turfcraftingstation" then
					table.insert(a,v)
				end
			end
		end
	end

	if #a < 1 or #b < 1 or #c < 1 then
		if #a >= 1 then
			for i,ent in ipairs(dispencers)	do
				if ent == a[1] then
					table.remove(dispencers,i)
					break
				end
			end
		else
			print("Retrofitting for Return of Them: Forgotten Knowledge - NO dispencer type A.")
		end
		if #b >= 1 then
			for i,ent in ipairs(dispencers)	do
				if ent == b[1] then
					table.remove(dispencers,i)
					break
				end
			end
		else
			print("Retrofitting for Return of Them: Forgotten Knowledge - NO dispencer type B.")
		end
		if #c >= 1 then
			for i,ent in ipairs(dispencers)	do
				if ent == c[1] then
					table.remove(dispencers,i)
					break
				end
			end
		else
			print("Retrofitting for Return of Them: Forgotten Knowledge - NO dispencer type C.")
		end
	end
	if #a == 0 and #dispencers > 0 then
		local rand = math.random(1,#dispencers)
		local ent = dispencers[rand]
		ent.product_orchestrina = "turfcraftingstation"
		ent.updateart(ent)
		table.remove(dispencers,rand)
		print("Retrofitting for Return of Them: Forgotten Knowledge - Making dispencer type A.")
	end
	if #b == 0 and #dispencers > 0 then
		local rand = math.random(1,#dispencers)
		local ent = dispencers[rand]
		ent.product_orchestrina = "archive_resonator_item"
		ent.updateart(ent)
		table.remove(dispencers,rand)
		print("Retrofitting for Return of Them: Forgotten Knowledge - Making dispencer type B.")
	end
	if #c == 0 and #dispencers > 0 then
		local rand = math.random(1,#dispencers)
		local ent = dispencers[rand]
		ent.product_orchestrina = "refined_dust"
		ent.updateart(ent)
		table.remove(dispencers,rand)
		print("Retrofitting for Return of Them: Forgotten Knowledge - Making dispencer type C.")
	end

	if #dispencers > 0 then
		local total  = 0
		for i, ent in ipairs(dispencers) do
			if ent.product_orchestrina == nil or ent.product_orchestrina == "" then
				total = total +1
				local list = {"turfcraftingstation","archive_resonator_item","refined_dust"}
				ent.product_orchestrina = list[math.random(1,#list)]
				ent.updateart(ent)
			end
		end
		if total > 0 then
			print("Retrofitting for Return of Them: Forgotten Knowledge - "..total.." Dispencers fixed.")
		end
	end

	if #lockboxes > 0 then
		local total  = 0
		for i, ent in ipairs(lockboxes) do
			if ent.product_orchestrina == nil or ent.product_orchestrina == "" then
				total = total +1
				local list = {"turfcraftingstation","archive_resonator_item","refined_dust"}
				ent.product_orchestrina = list[math.random(1,#list)]
			end
		end
		if total > 0 then
			print("Retrofitting for Return of Them: Forgotten Knowledge - "..total.." Distilled Knowledge fixed.")
		end
	end

end

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
	if retrofit_warts then
		print ("Retrofitting for A New Reign: Warts and All.")
		local success = false
		success = RetrofitNewCaveContentPrefab(inst, "toadstool_cap", 7, 40) or success
		success = RetrofitNewCaveContentPrefab(inst, "toadstool_cap", 7, 40) or success
		success = RetrofitNewCaveContentPrefab(inst, "toadstool_cap", 7, 40) or success
		while not success do
			print ("Retrofitting for A New Reign: Warts and All. - Trying really hard to find a spot for Toadstool.")
			success = RetrofitNewCaveContentPrefab(inst, "toadstool_cap", 4, 40)
		end
	end

	if self.retrofit_artsandcrafts then
		self.retrofit_artsandcrafts = nil

		local count = 10
	    for k,v in pairs(Ents) do
			if v ~= inst and v.prefab == "spiderhole" then
				count = count - 1
				if count == 0 then
					break
				end
			end
		end

		if count > 0 then
			print ("Retrofitting for A New Reign: Arts and Crafts.")
			for i = 1,count do
				RetrofitNewCaveContentPrefab(inst, "fossil_piece", 1)
			end
		else
			print ("Retrofitting for A New Reign: Arts and Crafts is not required.")
		end
	end

	local first_hotr_retrofit = self.retrofit_heartoftheruins ~= nil
	if self.retrofit_heartoftheruins then
		self.retrofit_heartoftheruins = nil

		print ("Retrofitting for A New Reign: Heart of the Ruins.")
		HeartOfTheRuinsAtriumRetrofitting(inst)
		HeartOfTheRuinsRuinsRetrofitting(inst)
	end

	if self.retrofit_heartoftheruins_respawnerfix then
		self.retrofit_heartoftheruins_respawnerfix = nil
		HeartOfTheRuinsRuinsRetrofittingRespawnerFix(inst, first_hotr_retrofit)
	end

	if self.retrofit_heartoftheruins_altars then
		self.retrofit_heartoftheruins_altars = nil

		print ("Retrofitting for A New Reign: Heart of the Ruins + Altar Respawner" )
		HeartOfTheRuinsRuinsRetrofittingAltar(inst)
	end

	if self.retrofit_heartoftheruins_caveholes then
		self.retrofit_heartoftheruins_caveholes = nil

		print ("Retrofitting for A New Reign: Heart of the Ruins + Cave Holes" )
		HeartOfTheRuinsRuinsRetrofittingCaveHoles(inst)
	end

	if self.retrofit_heartoftheruins_oldatriumfixup then
		self.retrofit_heartoftheruins_oldatriumfixup = nil

		print ("Retrofitting for A New Reign: Heart of the Ruins + Old Atrium Fixup")

		local needsatriumnodedata = true
		for k,v in ipairs(TheWorld.topology.ids) do
			if string.find(v, "AtriumMaze") then
				needsatriumnodedata = false
				break
			end
		end

		local gates = {}
		for _,v in pairs(Ents) do
			if v.prefab == "atrium_gate" and TheWorld.Map:GetTileAtPoint(v.Transform:GetWorldPosition()) == WORLD_TILES.BRICK then
				HeartOfTheRuinsRuinsRetrofitting_RepositionAtriumGate(v)

				-- check if this gate is not located in an existing node, if its not then we know the atrium zone needs node data
				if needsatriumnodedata then
					local isinthevoid = true
					local x, _, z = v.Transform:GetWorldPosition()
				    for i, node in ipairs(TheWorld.topology.nodes) do
						if TheSim:WorldPointInPoly(x, z, node.poly) then
							isinthevoid = false
							break
						end
					end
					if isinthevoid then
						table.insert(gates, v)
					end
				end
			end
		end

		if #gates > 0 then
			for k, gate in ipairs(gates) do
				local pos = gate:GetPosition()
				AddAtriumWorldTopolopy(pos.x - (4*8*2.5), pos.z - 16)
				print ("Retrofitting for A New Reign: Heart of the Ruins + Old Atrium Fixup: Converted the retrofitted atrium to have valid topology.")
			end
		else
			print ("Retrofitting for A New Reign: Heart of the Ruins + Old Atrium Fixup: Atrium already has valid topology.")
		end

	end

	if self.retrofit_heartoftheruins_statuechessrespawners then
		self.retrofit_heartoftheruins_statuechessrespawners = nil

		print ("Retrofitting for A New Reign: Heart of the Ruins + Statue and Broken Clockwork Respawners")
		HeartOfTheRuinsRuinsRetrofitting_StatueChessRespawners(inst)

	end

	if self.retrofit_sacred_chest then
		self.retrofit_sacred_chest = nil
		print ("Retrofitting for A New Reign: Sacred Chest")

		local altars = {}
		for _,v in pairs(Ents) do
			if v.prefab ~= nil and string.find(v.prefab, "ancient_altar") then
				table.insert(altars, v)
			end
		end

		local sacredaltar = nil
		for _,v in pairs(altars) do
		    for i, node in ipairs(TheWorld.topology.nodes) do
    			local x, _, z = v.Transform:GetWorldPosition()

		        if string.find(TheWorld.topology.ids[i], "SacredAltar") and TheSim:WorldPointInPoly(x, z, node.poly) then
					sacredaltar = v
					break
				end
			end
			if sacredaltar then
				break
			end
		end

		if sacredaltar then
			local x, y, z = sacredaltar.Transform:GetWorldPosition()

			local function TrySpawnAt(x, z)
				if #(TheSim:FindEntities(x, 0, z, .5, nil, LOCOMOTOR_TAGS)) == 0 then
					SpawnPrefab("sacred_chest").Transform:SetPosition(x, 0, z)
					return true
				end
			end

			local success = TrySpawnAt(x + 7, z) or TrySpawnAt(x - 7, z) or TrySpawnAt(x, z + 7) or TrySpawnAt(x, z - 7) or
							TrySpawnAt(x + 8, z) or TrySpawnAt(x - 8, z) or TrySpawnAt(x, z + 8) or TrySpawnAt(x, z - 8)

			if success then
				print ("Retrofitting for A New Reign: Sacred Chest: Added sacred_chest.")
			else
				print ("Retrofitting for A New Reign: Sacred Chest: FAILED to add sacred_chest, not enough room in the Sacred Altar to place it!")
			end
		else
			print ("Retrofitting for A New Reign: Sacred Chest: FAILED to add sacred_chest, could not find the Sacred Altar to place it in!")
		end
	end

	if self.retrofit_acientarchives then
		local success = false
		for _, v in pairs(Ents) do
			if v.prefab == "retrofit_archiveteleporter" then
				print("Retrofitting for Return of Them: Forgotten Knowledge - Found retrofit_archiveteleporter.")
				success = v:DoRetrofitting()
				break
			end
		end

		if success then
			print("Retrofitting for Return of Them: Forgotten Knowledge - Add a wormhole linking the blue mush forest to the retrofitted land.")
		else
			print("Retrofitting for Return of Them: Forgotten Knowledge - Failed to add a wormhole linking the blue mush forest to the retrofitted land!")
			print('Retrofitting for Return of Them: Forgotten Knowledge - An admin can force the wormhole link by running the command: c_findnext("retrofit_archiveteleporter"):DoRetrofitting(ThePlayer:GetPosition())')
			print("Retrofitting for Return of Them: Forgotten Knowledge - This will create a wormhole where the admin is currenlty standing, so make sure you are standing where you want it to be!")
		end
	end

	if self.retrofit_acientarchives_fixes then
		local success = false

		local topology = TheWorld.topology
		local is_retrofitted_world = false
		for k = 1, #topology.nodes do
			if topology.ids[k] == "AncientArchivesRetrofit:2:MoonMush" then
				if topology.nodes[k].tags == nil then
					topology.nodes[k].tags = {}
				end
				table.insert(topology.nodes[k].tags, "MushGnomeSpawnArea")
				print("Retrofitting for Return of Them: Forgotten Knowledge - Added MushGnomeSpawnArea tag to node " .. tostring(topology.ids[k]) .. " ("..tostring(k)..")")

				is_retrofitted_world = true
			end
			if topology.ids[k] == "AncientArchivesRetrofit:0:Archives" then
				if topology.nodes[k].tags == nil then
					topology.nodes[k].tags = {}
				end
				table.insert(topology.nodes[k].tags, "nocavein")
				print("Retrofitting for Return of Them: Forgotten Knowledge - Added nocavein tag to node " .. tostring(topology.ids[k]) .. " ("..tostring(k)..")")
			end
		end

		if not is_retrofitted_world then
			local num_removed = RemovePrefabs({"nightmaregrowth", "nightmaregrowth_spawner", "fissure_grottowar"})
			print("Retrofitting for Return of Them: Forgotten Knowledge - Removed " .. tostring(num_removed) .. " nightmaregrowth_spawner and fissure_grottowar objects")
		end
		-- remove all nightmaregrowth_spawner and fissure_grottowar
		-- add room MushGnomeSpawnArea to retrofitted blue mush forest
		-- add room tag nocavein to retrofitted archives

	end

	if self.retrofit_dispencer_fixes then
		print("Retrofitting for Return of Them: Forgotten Knowledge - Repairing Retrofitted Dispencers.")
		ArchiveDispencerFixup()
	end

	if self.retrofit_archives_navmesh then
		self.retrofit_archives_navmesh = nil

		TheWorld.Map:RetrofitNavGrid()
		print("Retrofitting for Return of Them: Forgotten Knowledge - Updated Nav Grid.")
		self.requiresreset = true
	end

	if self.retrofit_nodeidtilemap_atriummaze then
		self.retrofit_nodeidtilemap_atriummaze = nil

		local num_tiles_repaired = 0
		for i, id in ipairs(TheWorld.topology.ids) do
			if id == "AtriumMaze:0:AtriumMazeRooms" then
				local node = TheWorld.topology.nodes[i]
				num_tiles_repaired = TheWorld.Map:RepopulateNodeIdTileMap(i, node.x, node.y, node.poly, 500)
				break
			end
		end

		print ("Retrofitting for Return of Them: Forgotten Knowledge - Repaired " .. tostring(num_tiles_repaired) .. " tile node ids for Atrium.")
		self.requiresreset = self.requiresreset or num_tiles_repaired > 0
	end

	---------------------------------------------------------------------------
    
    if self.retrofit_daywalker_content then
		self.retrofit_daywalker_content = nil

		local requires_retrofitting_spawningground = true
	    for k,v in pairs(Ents) do
			if v ~= inst and v.prefab == "daywalkerspawningground" then
				print("Retrofitting for Daywalker spawningground is not required.")
				requires_retrofitting_spawningground = false
				break
			end
		end

        if requires_retrofitting_spawningground then
            print("Retrofitting for Daywalker spawningground.")
            local searchnodes_override = {}
            local topology = TheWorld.topology
            for k = 1, #topology.nodes do
                if string.find(topology.ids[k], "LightPlantField") then
                    table.insert(searchnodes_override, k)
                end
            end
            local success = false
            for i = 1, 5 do
                success = RetrofitNewCaveContentPrefab(inst, "daywalkerspawningground", 1, 10, nil, searchnodes_override) or success
            end
            if not success then
                -- Expand search area greatly.
                for k = 1, #topology.nodes do
                    if string.find(topology.ids[k], "WormPlantField") or
                        string.find(topology.ids[k], "FernGully") or
                        string.find(topology.ids[k], "SlurtlePlains") or
                        string.find(topology.ids[k], "MudWithRabbit") then
                        table.insert(searchnodes_override, k)
                    end
                end
                for i = 1, 5 do
                    success = RetrofitNewCaveContentPrefab(inst, "daywalkerspawningground", 1, 10, nil, searchnodes_override) or success
                end
                if not success then
                    -- Allow all tile types we need at least one to spawn somewhere it does not matter where at this point.
                    while not success do
                        print ("Retrofitting for Daywalker spawningground. - Trying really hard to find a spot for one spawningground.")
                        success = RetrofitNewCaveContentPrefab(inst, "daywalkerspawningground", 4, 40, nil, searchnodes_override, true)
                    end
                end
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
	if self.requiresreset then
		print ("Retrofitting: Worldgen retrofitting requires the server to save and restart to fully take effect.")
		print ("Restarting server in 45 seconds...")

        inst:DoTaskInTime(5,  function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 40})) end)
        inst:DoTaskInTime(10, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 35})) end)
        inst:DoTaskInTime(15, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 30})) end)
		inst:DoTaskInTime(25, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 20})) end)
		inst:DoTaskInTime(35, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 10})) end)
		inst:DoTaskInTime(37, function() TheWorld:PushEvent("ms_save") end)
		inst:DoTaskInTime(40, function() TheNet:Announce(subfmt(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT, {time = 5})) end)
		inst:DoTaskInTime(43, function() TheNet:Announce(STRINGS.UI.HUD.RETROFITTING_ANNOUNCEMENT_NOW) end)
		inst:DoTaskInTime(45, function() TheNet:SendWorldRollbackRequestToServer(0) end)
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
		self.requiresreset = data.requiresreset -- in case other retrofitting defined in savefileupgrades.lua needs a reset
		retrofit_warts = data.retrofit_warts or false
		self.retrofit_artsandcrafts = data.retrofit_artsandcrafts
		self.retrofit_heartoftheruins = data.retrofit_heartoftheruins
		self.retrofit_heartoftheruins_respawnerfix = data.retrofit_heartoftheruins_respawnerfix
		self.retrofit_heartoftheruins_altars = data.retrofit_heartoftheruins_altars
		self.retrofit_heartoftheruins_caveholes = data.retrofit_heartoftheruins_caveholes
		self.retrofit_heartoftheruins_oldatriumfixup = data.retrofit_heartoftheruins_oldatriumfixup
		self.retrofit_heartoftheruins_statuechessrespawners = data.retrofit_heartoftheruins_statuechessrespawners
		self.retrofit_sacred_chest = data.retrofit_sacred_chest
		self.retrofit_acientarchives = data.retrofit_acientarchives
		self.retrofit_acientarchives_fixes = data.retrofit_acientarchives_fixes
		self.retrofit_dispencer_fixes = data.retrofit_dispencer_fixes
		self.retrofit_archives_navmesh = data.retrofit_archives_navmesh
		self.retrofit_nodeidtilemap_atriummaze = data.retrofit_nodeidtilemap_atriummaze
        self.retrofit_daywalker_content = data.retrofit_daywalker_content or false
        self.console_beard_turf_fix = data.console_beard_turf_fix or false
    end
end

--------------------------------------------------------------------------
end)