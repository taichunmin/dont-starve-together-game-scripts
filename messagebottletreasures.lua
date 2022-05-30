
local treasure_templates =
{
--	TREASUREPREFAB1 = -- Prefab to spawn at point
--	{
--		treasure_type_weight = 1, -- Relative container prefab appearance rate
--
--		presets = -- OPTIONAL! If there are no presets the treasureprefab will simply spawn as is
--		{
--			PRESET1 = -- Preset names have no functionality other than making it easier to keep track of which one is which
--			{
--				preset_weight = 1, -- Relative preset appearance rate
--
--				guaranteed_loot =
--				{
--					-- Container is guaranteed to contain this many of these prefabs
--					ITEMPREFAB1 = {5, 8},
--					ITEMPREFAB2 = 7,
--					ITEMPREFAB3 = 9,
--				},
--				randomly_selected_loot =
--				{
--					-- One entry from each of these tables is randomly chosen based on weight and added to the container
--					{
--						ITEMPREFAB4 = 10,
--						ITEMPREFAB5 = 5,
--						ITEMPREFAB6 = 1,
--					},
--					... {}, ...
--				},
--			},
--			... PRESET2, PRESET3 ...
--		}
--	},
--	... TREASUREPREFAB2, TREASUREPREFAB3 ...

	sunkenchest =
	{
		treasure_type_weight = 1,

		presets =
		{
			saltminer =
			{
				preset_weight = 3,

				guaranteed_loot =
				{
					cookiecuttershell = {4, 6},
					boatpatch = {2, 4},
					saltrock = {5, 8},
					goldenpickaxe = 1,
				},
				randomly_selected_loot =
				{
					{ bluegem = 1, redgem = 1 },
				},
			},
			---------------------------------------------------------------------------
			traveler =
			{
				preset_weight = 1,

				guaranteed_loot =
				{
					cane = 1,
					heatrock = 1,
					gnarwail_horn = 1,
					papyrus = {4, 8},
					featherpencil = {2, 4},
					spoiled_fish = {3, 5},
				},
				randomly_selected_loot =
				{
					{ compass = .25, goggleshat = .75 },
				},
			},
			---------------------------------------------------------------------------
			fisher =
			{
				preset_weight = 3,

				guaranteed_loot =
				{
					boatpatch = {4, 8},
					malbatross_feather = {4, 10},
					oceanfishingrod = 1,
					oceanfishingbobber_robin_winter = {2, 5},
					oceanfishinglure_spoon_green = {1, 4},
					oceanfishinglure_hermit_heavy = {0, 2},
				},
				randomly_selected_loot =
				{
					{ boat_item = 1, anchor_item = 1, mast_item = 1, steeringwheel_item = 1, fish_box_blueprint = 1 },
				},
			},
			---------------------------------------------------------------------------
			miner =
			{
				preset_weight = 2,

				guaranteed_loot =
				{
					cutstone = {3, 6},
					goldnugget = {3, 6},
					moonglass = {3, 6},
					moonrocknugget = {3, 6},
					goldenpickaxe = 1,
				},
				randomly_selected_loot =
				{
					{ purplegem = 0.5, greengem = 0.1, yellowgem = 0.2, orangegem = 0.2, },
				},

			},
			---------------------------------------------------------------------------
			splunker =
			{
				preset_weight = 1,

				guaranteed_loot =
				{
					gears = {1, 2},
					thulecite = {4, 8},
					multitool_axe_pickaxe = 1,
					armorruins = 1,
					lantern = 1,
				},
				randomly_selected_loot =
				{
					{ yellowgem = 1, orangegem = 1, },
					{ purplegem = .9, greengem = .1, },
				},
			},
		}
	}
}

local trinkets =
{
	"trinket_3",
	"trinket_4",
	"trinket_5",
	"trinket_6",
	"trinket_7",
	"trinket_8",
	"trinket_9",
	"trinket_17",
	"trinket_22",
	"trinket_27",
}

local TRINKET_CHANCE = 0.02

local weighted_treasure_prefabs = {}
local weighted_treasure_contents = {}
for prefabname, data in pairs(treasure_templates) do
	weighted_treasure_prefabs[prefabname] = data.treasure_type_weight

	if data.presets ~= nil then -- If nil the prefab being spawned is not a container
		weighted_treasure_contents[prefabname] = {}
		for _, loottable in pairs(data.presets) do
			weighted_treasure_contents[prefabname][loottable] = loottable.preset_weight
		end
	end
end

local function GenerateTreasure(pt, overrideprefab, spawn_as_empty, postfn)
	local prefab = overrideprefab or weighted_random_choice(weighted_treasure_prefabs)

	local treasure = SpawnPrefab(prefab)
	if treasure ~= nil then
		local x, y, z = pt.x, pt.y, pt.z
		treasure.Transform:SetPosition(x, y, z)

		-- If overrideprefab is supplied but it has no entry in the 'treasure_templates' loot
		-- table in this file the prefab instance will be empty regardless of spawn_as_empty.

		if not spawn_as_empty and (treasure.components.container ~= nil or treasure.components.inventory ~= nil) and weighted_treasure_contents[prefab] ~= nil and type(weighted_treasure_contents) == "table" and next(weighted_treasure_contents[prefab]) ~= nil then
			local lootpreset = weighted_random_choice(weighted_treasure_contents[prefab])
			local prefabstospawn = {}

			if lootpreset.guaranteed_loot ~= nil then
				for itemprefab, count in pairs(lootpreset.guaranteed_loot) do
					local total = type(count) ~= "table" and count or math.random(count[1], count[2])
					for i = 1, total do
						table.insert(prefabstospawn, itemprefab)
					end
				end
			end

			if lootpreset.randomly_selected_loot ~= nil then
				for i, one_of in ipairs(lootpreset.randomly_selected_loot) do
					table.insert(prefabstospawn, weighted_random_choice(one_of))
				end
			end


			local item = nil
			for i, itemprefab in ipairs(prefabstospawn) do
				item = SpawnPrefab(itemprefab)
				item.Transform:SetPosition(x, y, z)
				if treasure.components.container ~= nil then
					treasure.components.container:GiveItem(item)
				else
					treasure.components.inventory:GiveItem(item)
				end
			end

			if math.random() < TRINKET_CHANCE then
				if treasure.components.container ~= nil then
					if not treasure.components.container:IsFull() then
						treasure.components.container:GiveItem(SpawnPrefab(trinkets[math.random(#trinkets)]))
					end
				elseif treasure.components.inventory ~= nil then
					if not treasure.components.inventory:IsFull() then
						treasure.components.inventory:GiveItem(SpawnPrefab(trinkets[math.random(#trinkets)]))
					end
				end
			end
		end

		if postfn ~= nil then
			postfn(treasure)
		end
	end

	return treasure
end

local function GetPrefabs()
	local prefabscontain = {}
	for treasureprefab, weighted_lists in pairs(weighted_treasure_contents) do
		prefabscontain[treasureprefab] = true -- Chests, etc

		if weighted_lists ~= nil and type(weighted_lists) == "table" and next(weighted_lists) ~= nil then
			for weighted_list, _--[[weight]] in pairs(weighted_lists) do
				if weighted_list.guaranteed_loot ~= nil then
					for itemprefab, _--[[count]] in pairs(weighted_list.guaranteed_loot) do
						prefabscontain[itemprefab] = true
					end
				end

				if weighted_list.randomly_selected_loot ~= nil then
					for i, v in ipairs(weighted_list.randomly_selected_loot) do
						for itemprefab, _--[[weight]] in pairs(v) do
							prefabscontain[itemprefab] = true
						end
					end
				end
			end
		end
	end

	local prefablist = {}
	for prefab, _ in pairs(prefabscontain) do
		table.insert(prefablist, prefab)
	end

	for i, trinketprefab in ipairs(trinkets) do
		table.insert(prefablist, trinketprefab)
	end

	return prefablist
end

return { GenerateTreasure = GenerateTreasure, GetPrefabs = GetPrefabs, treasure_templates = treasure_templates }