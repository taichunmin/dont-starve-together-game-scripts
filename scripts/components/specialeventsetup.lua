

--------------------------------------------------------------------------
--[[ SpecialEventSetup class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "SpecialEventSetup should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------
local CURRENT_HALLOWEEN = os.date("%Y") -- deprecated

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

self.halloween_bat_grave_spawn_chance = 0 -- this is an accumulating chance for bats to spawn from digging graves
self.prev_event = SPECIAL_EVENTS.NONE
self.prev_extra_events = {}

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------
function self:_SetupHallowedNights()
	-- retrofitting code to support changing from halloweentrinkets as a bool or number to using prev_event

	-- figure out if there are enough trinkets already in the world (for worlds with last year's halloween trinkets still around)
	if self.prev_event ~= nil or (self.halloweentrinkets and self.halloweentrinkets ~= CURRENT_HALLOWEEN) then
		local count = 0
		for k,v in pairs(Ents) do
			if v.prefab ~= nil then
				local split_table = string.split(v.prefab, "trinket_")
				if #split_table == 1 then
					local trinket_num = tonumber(split_table[1])
					if trinket_num ~= nil and trinket_num >= HALLOWEDNIGHTS_TINKET_START and trinket_num <= HALLOWEDNIGHTS_TINKET_END then
						count = count + 1
						if count > 15 then
							print("[Hallowed Nights] Enough Halloween Trinkets founds, no need to add more.")
							return
						end
					end
				end
			end
		end
	end

	-- spawn halloween trinkets throughout the world
	if self.prev_event ~= nil or (not self.halloweentrinkets) or self.halloweentrinkets ~= CURRENT_HALLOWEEN then
		local count = 0

		local trinkets = {}
		for i = HALLOWEDNIGHTS_TINKET_START, HALLOWEDNIGHTS_TINKET_END do
			table.insert(trinkets, "trinket_"..i)
			table.insert(trinkets, "trinket_"..i)
		end
		for i = 1, NUM_HALLOWEEN_ORNAMENTS do
			table.insert(trinkets, "halloween_ornament_"..i)
		end

		trinkets = shuffleArray(trinkets)

		for i,area in pairs(TheWorld.topology.nodes) do
			if (i % 4) == 0 then
				local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(area.x, area.y, area.poly, 5)
				local pi = 1
				while points_x[pi] ~= nil do
					local x = points_x[pi]
					local z = points_y[pi]
					if TheWorld.Map:IsAboveGroundAtPoint(x, 0, z, false) then
						local ents =  TheSim:FindEntities(x, 0, z, 1)
						if #ents == 0 then
							local e = SpawnPrefab(trinkets[(count % #trinkets) + 1])
							e.Transform:SetPosition(x, 0, z)
							count = count + 1
							break
						end
					end
					pi = pi + 1
				end
			end
		end

		print("[Hallowed Nights] Halloween Trinkets added: " ..count)
	end
end


function self:_yotcatcoon_HideKitcoon(kitcoon_data, emergency_hidingspot_prefabs)
	local kitcoon = kitcoon_data.kitcoon

	local candidtate_nodes = {}
	if kitcoon_data.biome_name ~= nil then
		for i,v in ipairs(TheWorld.topology.ids) do
			if string.find(v, kitcoon_data.biome_name) then
				table.insert(candidtate_nodes, TheWorld.topology.nodes[i])
			end
		end

		shuffleArray(candidtate_nodes)
	end

	for i, node in ipairs(candidtate_nodes) do
		local pt = Vector3(node.cent[1], 0, node.cent[2])

		local hiding_spots = TheSim:FindEntities(pt.x, pt.y, pt.z, 30, kitcoon_data.hiding_spot_all_tags, kitcoon_data.hiding_spot_notags, kitcoon_data.hiding_spot_some_tags)
		if #hiding_spots > 1 then
			shuffleArray(hiding_spots)
		end
	
		for h, hiding_spot in ipairs(hiding_spots) do
			if hiding_spot.components.hideandseekhidingspot == nil
				and TheWorld.Map:FindVisualNodeAtPoint(hiding_spot.Transform:GetWorldPosition()) == node 
				and (kitcoon_data.hiding_spot_fn == nil or kitcoon_data.hiding_spot_fn(hiding_spot)) then

				if kitcoon.components.hideandseekhider:GoHide(hiding_spot, 0) then
					print("[YOT Catcoon] "..tostring(kitcoon).." found hiding spot '"..tostring(hiding_spot).."'")
					return
				end
			end
		end
	end

	-- We could not find a good hiding spot, so spawn one
	for i, node in ipairs(candidtate_nodes) do
		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(node.x, node.y, node.poly, 10)
		local pi = 1
		while points_x[pi] ~= nil do
			local x = points_x[pi]
			local z = points_y[pi]
			if TheWorld.Map:CanPlacePrefabFilteredAtPoint(x, 0, z, kitcoon_data.fallback_prefab) then
				if TheSim:CountEntities(x, 0, z, 1) == 0 then
					local hiding_spot = SpawnPrefab(kitcoon_data.fallback_prefab)
					hiding_spot.Transform:SetPosition(x, 0, z)

					if kitcoon.components.hideandseekhider:GoHide(hiding_spot, 0) then
						print("[YOT Catcoon] "..tostring(kitcoon).." spawned new hiding spot '"..tostring(hiding_spot).."'")
						return
					else
						hiding_spot:Remove()
					end
				end
			end
			pi = pi + 1
		end
	end

	-- since we failed to find a valid hiding spot, just spawn it out in the open somewhere within the biome
	for i, node in ipairs(candidtate_nodes) do
		local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(node.x, node.y, node.poly, 10)
		local pi = 1
		while points_x[pi] ~= nil do
			local x = points_x[pi]
			local z = points_y[pi]
			if TheWorld.Map:IsAboveGroundAtPoint(x, 0, z, false) then
				if TheSim:CountEntities(x, 0, z, 0.5) == 0 then
					local hiding_spot = SpawnPrefab(emergency_hidingspot_prefabs[math.random(#emergency_hidingspot_prefabs)])
					hiding_spot.Transform:SetPosition(x, 0, z)

					if kitcoon.components.hideandseekhider:GoHide(hiding_spot, 0) then
						print("[YOT Catcoon] "..tostring(kitcoon).." spawned an emergency hiding spot '"..tostring(hiding_spot).."'")
						return
					else
						hiding_spot:Remove()
					end
				end
			end
			pi = pi + 1
		end
	end

	-- last ditch effort, we are not worrying about biomes any more...
	local node = TheWorld.topology.nodes[math.random(#TheWorld.topology.nodes)]
	local points_x, points_y = TheWorld.Map:GetRandomPointsForSite(node.x, node.y, node.poly, 10)
	local pi = 1
	while points_x[pi] ~= nil do
		local x = points_x[pi]
		local z = points_y[pi]
		if TheWorld.Map:IsAboveGroundAtPoint(x, 0, z, false) then
			if TheSim:CountEntities(x, 0, z, 0.5) == 0 then
				local hiding_spot = SpawnPrefab(emergency_hidingspot_prefabs[math.random(#emergency_hidingspot_prefabs)])
				hiding_spot.Transform:SetPosition(x, 0, z)

				if kitcoon.components.hideandseekhider:GoHide(hiding_spot, 0) then
					print("[YOT Catcoon] "..tostring(kitcoon).." spawned an emergency hiding spot '"..tostring(hiding_spot).."' somewhere in the world.")
					return
				else
					hiding_spot:Remove()
				end
			end
		end
		pi = pi + 1
	end

	-- Well, just spawn near a player spawner, that's gotta work, right?
	local pt = Vector3(TheWorld.components.playerspawner:GetAnySpawnPoint())
	local offset = FindWalkableOffset(pt, math.random()*PI2, 15 + math.random()*5, 16, function(o) return TheSim:CountEntities(pt.x + o.x, pt.y + o.y, pt.z + o.z, 1) == 0 end )
				or FindWalkableOffset(pt, math.random()*PI2, 10 + math.random()*5, 16, function(o) return TheSim:CountEntities(pt.x + o.x, pt.y + o.y, pt.z + o.z, 1) == 0 end )
				or FindWalkableOffset(pt, math.random()*PI2, 5 + math.random()*5, 16, function(o) return TheSim:CountEntities(pt.x + o.x, pt.y + o.y, pt.z + o.z, 1) == 0 end )
	if offset ~= nil then
		pt = pt + offset
	end

	local hiding_spot = SpawnPrefab(emergency_hidingspot_prefabs[math.random(#emergency_hidingspot_prefabs)])
	hiding_spot.Transform:SetPosition(pt.x, pt.y, pt.z)
	if kitcoon.components.hideandseekhider:GoHide(hiding_spot, 0) then
		print("[YOT Catcoon] "..tostring(kitcoon).." spawned an emergency hiding spot '"..tostring(hiding_spot).."' near a player spawner point.")
		return
	else
		hiding_spot:Remove()
	end
		
	-- wow... I give up...
	kitcoon.Transform:SetPosition(pt.x, pt.y, pt.z)
	print("[YOT Catcoon] Failed to find a hiding spot for "..tostring(kitcoon)..". Spawned near a player spawn point.")
end


function self:_SetupYearOfTheCatcoon()
	print("[YOT Catcoon] Setting up for the event.")

	local emergency_hidingspot_prefabs = {"rocks", "twigs", "cutgrass", "log"}

	local HIDINGSPOT_NO_TAGS = {"fire", "wall", "INLIMBO", "no_hideandseek", "locomotor"}
	local HIDINGSPOT_TAGS = {"pickable", "structure", "plant"}

	local kitten_hiding_data =
	{
		kitcoon_forest	   = { biome_name = "Forest hunters",		fallback_prefab = "evergreen_short",		hiding_spot_all_tags = {"evergreens"},			hiding_spot_notags = {"monster", "fire"},	hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
		kitcoon_savanna	   = { biome_name = "Great Plains",			fallback_prefab = "grass",					hiding_spot_all_tags = {"plant"},				hiding_spot_notags = {"fire"},				hiding_spot_some_tags = nil,				hiding_spot_fn = function(obj) return obj.prefab == "grass" end},
		kitcoon_deciduous  = { biome_name = "Speak to the king",	fallback_prefab = "deciduoustree_short",	hiding_spot_all_tags = {"plant"},				hiding_spot_notags = {"monster", "fire"},	hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
		kitcoon_marsh	   = { biome_name = "Squeltch",				fallback_prefab = "marsh_bush",				hiding_spot_all_tags = {"thorny"},				hiding_spot_notags = {"fire"},				hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
		kitcoon_grass	   = { biome_name = "Beeeees!",				fallback_prefab = "flower",					hiding_spot_all_tags = {"flower"},				hiding_spot_notags = nil,					hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
		kitcoon_rocky	   = { biome_name = "Dig that rock",		fallback_prefab = "rock_moon",				hiding_spot_all_tags = {"boulder"},				hiding_spot_notags = nil,					hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
		kitcoon_desert	   = { biome_name = "Lightning Bluff",		fallback_prefab = "houndbone",				hiding_spot_all_tags = nil,						hiding_spot_notags = nil,					hiding_spot_some_tags = {"bone", "thorny"}, hiding_spot_fn = nil},
		kitcoon_moon	   = { biome_name = "MoonIsland_",			fallback_prefab = "moonglass_rock",			hiding_spot_all_tags = {"moonglass", "boulder"},hiding_spot_notags = {"fire"},				hiding_spot_some_tags = nil,				hiding_spot_fn = nil},
	}

	-- TODO: add a hook for modders to add/modify kitten_hiding_data and emergency_hidingspot_prefabs
	

	-- remove all the existing kitcoons in the world, its far easier than trying to reuse existing ones
	local collected_kitcoons = { kitcoons = {} }
	TheWorld:PushEvent("ms_collectallkitcoons", collected_kitcoons)
	for _, kitcoon in ipairs(collected_kitcoons.kitcoons) do
		kitten_hiding_data[kitcoon.prefab] = nil
		print("[YOT Catcoon] Using existing kitcoon '"..tostring(kitcoon).."'.")
	end

	for prefab, data in pairs(kitten_hiding_data) do
		if data.kitcoon == nil then
			data.kitcoon = SpawnPrefab(prefab)
			print("[YOT Catcoon] Adding new kitcoon '"..tostring(data.kitcoon).."'.")
		end
	end

	for kit_prefab, data in pairs(kitten_hiding_data) do
		if data.kitcoon ~= nil then
			self:_yotcatcoon_HideKitcoon(data, emergency_hidingspot_prefabs)
		end
	end

end

function self:SetupNewSpecialEvent(event)
	if not event then return end
	-- todo: add any event stup logic here
	if event == SPECIAL_EVENTS.YOT_CATCOON then
		self:_SetupYearOfTheCatcoon()
	elseif event == SPECIAL_EVENTS.HALLOWED_NIGHTS then
		self:_SetupHallowedNights()
	end

	-- for mod support
	TheWorld:PushEvent("ms_setupspecialevent", event)
end

function self:ShutdownPrevSpecialEvent(event)
	if not event then return end

	if event == SPECIAL_EVENTS.HALLOWED_NIGHTS then
		-- TODO: clean up halloween trinkets out in the world that were not touched by the players
	end

	-- for mod support
	TheWorld:PushEvent("ms_shutdownspecialevent", event)
end


--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
	require("prefabs/oceanfishdef").SpecialEventSetup()

	local previous_events = GetAllActiveEvents(self.prev_event, self.prev_extra_events)
	local current_events = GetAllActiveEvents(WORLD_SPECIAL_EVENT, WORLD_EXTRA_EVENTS)

	for special_event in pairs(previous_events) do
		if special_event ~= SPECIAL_EVENTS.NONE and not current_events[special_event] then
			print("[Special Event] Shutting down "..tostring(special_event))
			self:ShutdownPrevSpecialEvent(special_event)
		end
	end

	for special_event in pairs(current_events) do
		if special_event ~= SPECIAL_EVENTS.NONE and not previous_events[special_event] then
			print("[Special Event] Setting up "..tostring(special_event))
			self:SetupNewSpecialEvent(special_event)
		end
	end
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return
	{
		halloween_bats = self.halloween_bat_grave_spawn_chance,
		current_event = WORLD_SPECIAL_EVENT,
		current_extra_events = WORLD_EXTRA_EVENTS
	}
end

function self:OnLoad(data)
    if data ~= nil then
		self.halloweentrinkets = data.halloweentrinkets	-- deprecated, kept for migrating to new prev_event format 

		self.halloween_bat_grave_spawn_chance = data.halloween_bats or 0
		self.prev_event = data.current_event
		self.prev_extra_events = data.current_extra_events or {}
    end
end


--------------------------------------------------------------------------
end)