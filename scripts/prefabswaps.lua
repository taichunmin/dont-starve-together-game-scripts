--------------------------------------------------------------------------
--PrefabSwap utils for WorldGen
--------------------------------------------------------------------------

local PrefabSwaps = {}
local WeightedList = require("util/weighted_list")

--------------------------------------------------------------------------

local _base_sets = {}

PrefabSwaps.AddPrefabSwap = function(t)
    if _base_sets[t.category] == nil then
        _base_sets[t.category] = { t }
        --force first entry to be primary just in case
        t.primary = true
    else
        if t.primary then
            --only one primary per category; replace existing one
            for i, v in ipairs(_base_sets[t.category]) do
                v.primary = nil
            end
        end
        table.insert(_base_sets[t.category], t)
    end
end

PrefabSwaps.GetBasePrefabSwaps = function()
    return _base_sets
end

-- GRASS
PrefabSwaps.AddPrefabSwap({
    category = "grass",
    name = "regular grass",
    prefabs = { "grass" },
    weight = 3,
    primary = true,
})

PrefabSwaps.AddPrefabSwap({
    category = "grass",
    name = "grass gekko",
    prefabs = { "grassgekko" },
    weight = 1,
    exclude_locations = { "cave" },
})

-- TWIGS
PrefabSwaps.AddPrefabSwap({
    category = "twigs",
    name = "regular twigs",
    prefabs = { "sapling" },
    weight = 3,
    primary = true,
})

PrefabSwaps.AddPrefabSwap({
    category = "twigs",
    name = "twiggy trees",
    prefabs = { "twiggytree", "ground_twigs" },
    weight = 1,
})

-- BERRIES
PrefabSwaps.AddPrefabSwap({
    category = "berries",
    name = "regular berries",
    prefabs = { "berrybush" },
    weight = 3,
    primary = true,
})

PrefabSwaps.AddPrefabSwap({
    category = "berries",
    name = "juicy berries",
    prefabs = { "berrybush_juicy" },
    weight = 1,
})

--------------------------------------------------------------------------
-- Some prefabs listed in the world gen tables are are not actually real prefabs.
-- After the filtering is done, these temp names need to be replaced with the real prefab names.

local _proxies = {}

PrefabSwaps.AddPrefabProxy = function(proxy, prefab)
    _proxies[proxy] = prefab
end

PrefabSwaps.ResolvePrefabProxy = function(proxy)
    return _proxies[proxy] or proxy
end

--perma stuff shouldn't get culled with the original prefab
PrefabSwaps.AddPrefabProxy("perma_grass", "grass")
PrefabSwaps.AddPrefabProxy("perma_sapling", "sapling")

--twigs on the ground only when twiggy trees are selected
PrefabSwaps.AddPrefabProxy("ground_twigs", "twigs")

--some prefabs in world gen tables are prefabs with a prefix, so that they can get controlled by a different customization setting.
--after all the entity spawning is done, replace the temp names with the actual prefabs

local _customization_proxies = {}

PrefabSwaps.AddCustomizationPrefab = function(proxy, prefab)
    assert(_customization_proxies[prefab] == nil, "multi level customization prefab proxies are not allowed.")
    _customization_proxies[proxy] = prefab
end

PrefabSwaps.ResolveCustomizationPrefab = function(proxy)
    return _customization_proxies[proxy]
end

--so that the moon island rocks will get controlled by the moon island settings.
PrefabSwaps.AddCustomizationPrefab("lunar_island_rock1", "rock1")
PrefabSwaps.AddCustomizationPrefab("lunar_island_rock2", "rock2")
PrefabSwaps.AddCustomizationPrefab("lunar_island_rocks", "rocks")

--some prefabs in world gen tables are prefabs with a prefix, so that they can get controlled by a different customization setting.
--after all the entity spawning is done, replace the temp names with the actual prefabs

local _randomization_proxies = {}

PrefabSwaps.AddRandomizationPrefab = function(proxy, prefabs)
    _randomization_proxies[proxy] = prefabs
end

PrefabSwaps.IsRandomizationPrefab = function(proxy)
    return _randomization_proxies[proxy] ~= nil
end

PrefabSwaps.ResolveRandomizationPrefab = function(proxy)
    return _randomization_proxies[proxy][math.random(#_randomization_proxies[proxy])]
end

--so that the moon island rocks will get controlled by the moon island settings.
PrefabSwaps.AddRandomizationPrefab("worldgen_chesspieces", {"knight", "bishop", "rook"})

--------------------------------------------------------------------------

local _selected_sets = nil
local _inactive_prefabs = {}

-- Defaults to partially support mods that generate set pieces too early.
for cat, v in pairs(_base_sets) do
    for i, set in ipairs(v) do
        if not set.primary then
            for _, prefab in ipairs(set.prefabs) do
                _inactive_prefabs[prefab] = true
            end
        end
    end
end

local function ActivateSet(set)
    print("Prefab Swap Selection: "..set.name)
    set.active = true
end

local function IsValidSetForLocation(set, location)
    return set.primary --primary sets have to be valid no matter what
        or not ((set.exclude_locations ~= nil and table.contains(set.exclude_locations, location)) or
                (set.required_locations ~= nil and not table.contains(set.required_locations, location)))
end

PrefabSwaps.SelectPrefabSwaps = function(location, world_gen_options, override_sets)
    _selected_sets = deepcopy(_base_sets)

    if override_sets ~= nil then
        print("Overriding Prefab Swaps")
        dumptable(override_sets)

        for cat, v in pairs(_selected_sets) do
            local primary_set = nil
            for i, set in ipairs(v) do
                if set.name == override_sets[cat] and IsValidSetForLocation(set, location) then
                    ActivateSet(set)
                    primary_set = nil
                    break
                elseif set.primary then
                    primary_set = set
                end
            end
            if primary_set ~= nil then
                ActivateSet(primary_set)
            end
        end
    elseif world_gen_options ~= nil and world_gen_options["prefabswaps_start"] == "classic" then
        print("Selecting Classic Prefabs")

        for cat, v in pairs(_selected_sets) do
            for i, set in ipairs(v) do
                if set.primary then
                    ActivateSet(set)
                    break
                end
            end
        end
    elseif world_gen_options ~= nil and world_gen_options["prefabswaps_start"] == "highly random" then
        for cat, v in pairs(_selected_sets) do
            local valid_sets = {}
            for i, set in ipairs(v) do
                if IsValidSetForLocation(set, location) then
                    table.insert(valid_sets, set)
                end
            end
            ActivateSet(valid_sets[math.random(#valid_sets)])
        end
    else
        for cat, v in pairs(_selected_sets) do
            local choices = WeightedList()
            for i, set in ipairs(v) do
                if IsValidSetForLocation(set, location) then
                    choices:addChoice(i, set.weight)
                end
            end
            ActivateSet(v[choices:getChoice(math.random() * choices:getTotalWeight())])
        end
    end

    _inactive_prefabs = {}
    for cat, v in pairs(_selected_sets) do
        for i, set in ipairs(v) do
            if not set.active then
                for _, prefab in ipairs(set.prefabs) do
                    _inactive_prefabs[prefab] = true
                end
            end
        end
    end
end

PrefabSwaps.IsPrefabInactive = function(prefab)
    return _inactive_prefabs[prefab] == true
end

--------------------------------------------------------------------------

return PrefabSwaps
