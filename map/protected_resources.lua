require("constants")
local StaticLayout = require("map/static_layout")


local Rare = {
}

local Forest = {
	["leif_forest"] = StaticLayout.Get("map/static_layouts/leif_forest"),--, { areas={["RandomTreeAndLeif"]={""}},}),
	["spider_forest"] = StaticLayout.Get("map/static_layouts/spider_forest"),
}

local Grasslands = {
	["pigguard_berries"] = StaticLayout.Get("map/static_layouts/pigguard_berries"),
	["pigguard_berries_easy"] = StaticLayout.Get("map/static_layouts/pigguard_berries_easy"),
	["wasphive_grass_easy"] = StaticLayout.Get("map/static_layouts/wasphive_grass_easy"),
}

local Dirt = {
	["hound_rocks"] = StaticLayout.Get("map/static_layouts/hound_rocks"),
}

local Swamp = {
	["tenticle_reeds"] = StaticLayout.Get("map/static_layouts/tenticle_reeds"),
}

local Rocky = {
	["tallbird_rocks"] = StaticLayout.Get("map/static_layouts/tallbird_rocks"),
}

local Savanna = {
	["pigguard_grass"] = StaticLayout.Get("map/static_layouts/pigguard_grass"),
	["pigguard_grass_easy"] = StaticLayout.Get("map/static_layouts/pigguard_grass_easy"),
}

local BlueFungal = {
}

local RedFungal = {
}

local GreenFungal = {
}

local Underrock = {
}

local Cave = {
}

local Mud = {
    ["lures_and_worms"] = StaticLayout.Get("map/static_layouts/lures_and_worms", {
        areas = {
            lures = function() return JoinArrays(PickSomeWithDups(10, {"wormlight_plant"}), PickSomeWithDups(3, {"worm_spawner"})) end,
        },
    }),
}

local Sinkhole = {
}

local Any = {
}

-- TODO: Add winter/summer, nighttime/dusk/day filters
local Winter = {
}

local ProtectedResources = {
	["Rare"] = Rare,
	["Any"] = Any,
	--["Winter"] = Winter,
	[GROUND.ROCKY] = Rocky,
	[GROUND.DIRT] = Dirt,
	[GROUND.SAVANNA] = Savanna,
	[GROUND.GRASS] = Grasslands,
	[GROUND.FOREST] = Forest,
	[GROUND.MARSH] = Swamp,
	[GROUND.FUNGUS] = BlueFungal,
	[GROUND.FUNGUSRED] = RedFungal,
	[GROUND.FUNGUSGREEN] = GreenFungal,
	[GROUND.UNDERROCK] = Underrock,
	[GROUND.CAVE] = Cave,
	[GROUND.MUD] = Mud,
	[GROUND.SINKHOLE] = Sinkhole,
}


local layouts = {}
for k,area in pairs(ProtectedResources) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = ProtectedResources, Layouts = layouts}
